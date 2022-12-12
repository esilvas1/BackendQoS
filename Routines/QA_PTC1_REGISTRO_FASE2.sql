CREATE OR REPLACE PROCEDURE BRAE.QA_PTC1_REGISTRO_FASE2(FECHAOPERACION  DATE)--EJECUTAR TODOS LOS DIAS 2 CALENDARIO DE CADA MES
AS

CANT_REG_TT2 NUMBER;
AJUSTADO     NUMBER;

BEGIN

     --DEPURACION Y RECONFIGURACION DEL FORMATO TC1 PERIODO ACTUAL
     --ELIMINAR USUARIOS CON TRANSFORMADORES XT
     -->INGRESAR DENTRO DE AJUSTES DE EVENTOS LOS AJUSTES CON RESPECTO A LA MARCACION DE ALUMBRADO PUBLICO
     -->MARCAR LOS TRANSFORMADORES DE AUTOGENERADORES Y APLICAR FORMATO DE AJUSTE PARA LA MARCACION DE AUTOGENERADORES
     -->COLOCAR DIRECCION (ADDRESS) A LAS CUENTAS CALPS A TRAVES DE UNA CAMPO NUEVO EN TTX
        
     --VERIFICACION DE EJECUCION PREVIA DEL PROCEDIMIENTO TT2 DEL PERIODO (t)
      SELECT COUNT(*)
      INTO CANT_REG_TT2
      FROM BRAE.QA_TTT2_REGISTRO
      WHERE TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
    
     --VERIFICACION DE ACCION DE AJUSTES REALIZADOS EN LA BASE DE DATOS PARA EL PERIODO 
      SELECT COUNT(DISTINCT FDD_AJUSTADO) AS AJUSTADO
      INTO AJUSTADO
      FROM QA_TFDDREGISTRO
      WHERE TRUNC(FDD_FINICIAL,'MM') = TRUNC(FECHAOPERACION)
      AND   FDD_AJUSTADO = 'S'
      ;    
        
        
        IF CANT_REG_TT2 > 0
           --AND AJUSTADO     = 0
           THEN

            --AGREGAR REGISTROS CALP DESDE TT2 --Autogeneracion (por replicas de reportes)
            DELETE FROM QA_TTC1_TEMP
            WHERE TC1_TC1 LIKE 'CALP%';
            COMMIT;
            
            INSERT INTO QA_TTC1_TEMP
            SELECT 	TT2_CODE_CALP      AS	TC1_TC1
                ,	TT2_CODIGOELEMENTO AS	TC1_CODCONEX
                ,	'T' AS	TC1_TIPCONEX
                ,	1  AS	TC1_NT
                ,	2  AS	TC1_NTP
                ,	(CASE WHEN(TT2_PROPIEDAD = 'CENS'      ) THEN(100)
                          WHEN(TT2_PROPIEDAD = 'COMPARTIDO') THEN(50 )
                          WHEN(TT2_PROPIEDAD = 'PARTICULAR') THEN(0  )    
                    END) AS	TC1_PROPACTIV
                ,	(CASE WHEN(TT2_LOCALIZACION = 'AEREO'      ) THEN('1')
                          WHEN(TT2_LOCALIZACION = 'SUBTERRANEO') THEN('2')
                    END) AS	TC1_CONEXRED
                ,	(CASE WHEN(TT2_MUNICIPIO IN ('VILLA DEL ROSARIO','CÚCUTA','LOS PATIOS'))
                          THEN('564')
                          ELSE('604')
                     END)  AS	TC1_IDCOMER
                ,	161  AS	TC1_IDMERC
                ,   TT2_GRUPOCALIDAD AS	TC1_GC
                ,	(CASE WHEN(TT2_MUNICIPIO = 'LOS PATIOS'       ) THEN('FRT28459')
                          WHEN(TT2_MUNICIPIO = 'CÚCUTA'           ) THEN('FRT28702')
                          WHEN(TT2_MUNICIPIO = 'VILLA DEL ROSARIO') THEN('FRT28703')
                          ELSE('OR0001')
                     END)  AS	TC1_CODFRONCOM
                ,	TT2_IUL AS	TC1_CODCIRC
                ,	TT2_CODE_IUA AS	TC1_CODTRANSF
                ,	MUN.CODIGO_MUNICIPIO||'000'  AS	TC1_CODDANE
                ,	(CASE WHEN(TT2_POBLACION='URBANO') THEN('2')
                          WHEN(TT2_POBLACION='RURAL' ) THEN('1')
                          ELSE('NA') END) AS TC1_UBIC
                ,	TT2_MUNICIPIO  AS	TC1_DIREC
                ,	'0'  AS	TC1_CONESP
                ,	'0'  AS	TC1_CODARESP
                ,	'0'  AS	TC1_TIPARESP
                ,	'11' AS	TC1_ESTSECT
                ,	TT2_ALTITUD   AS	TC1_ALTITUD
                ,	TT2_LONGITUD  AS	TC1_LONGITUD
                ,	TT2_LATITUD   AS	TC1_LATITUD
                ,	'3'   AS	TC1_AUTOGEN
                ,	NULL  AS	TC1_EXPENER
                ,	NULL  AS	TC1_CAPAUTOGENR
                ,	NULL  AS	TC1_TIPGENR
                ,	NULL  AS	TC1_CODFRONEXP
                ,	NULL  AS	TC1_FENTGEN
                ,	NULL  AS	TC1_CONTRESP
                ,	NULL  AS	TC1_CAPCONTRESP
                ,	NULL  AS	TC1_PERIODO --ASIGNADO POR EL PROCEDIMIENTO
                ,	TT2_CODE_IUA AS	TC1_IUA
            FROM BRAE.QA_TTT2_REGISTRO
            LEFT OUTER JOIN (    SELECT DISTINCT
                                        NOMBRE_DEPARTAMENTO
                                       ,NOMBRE_MUNICIPIO
                                       ,CODIGO_MUNICIPIO 
                                 FROM QA_TDIVIPOLA_DANE) MUN 
                             ON (    MUN.NOMBRE_MUNICIPIO    = TT2_MUNICIPIO 
                                 AND MUN.NOMBRE_DEPARTAMENTO = TT2_DEPARTAMENTO
                                 )
            WHERE TT2_CODE_CALP <> '0'
            AND   TT2_ESTADO = 'OPERACION'
            ;            
            COMMIT
            ;

            /*AGREGAR LOS REGISTRO DE LA TABLA OBSERVACION; esto con el fin de poder ejecutar varias veces*/

            INSERT INTO QA_TTC1_TEMP
            SELECT * FROM QA_TTC1_OBS
                WHERE TC1_PERIODO = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'));
            COMMIT;

            /*ACTUALIZACION DE LOS CAMPOS TC1_IUA, TC1_CODTRANSF, TC1_CODCIR, TC1_GC---
            A TRAVES DE LEFT OUTER JOIN E INSERT Y DELETE SOBRE LA MISMA TABLA QA_TTC1_TEMP*/

            UPDATE BRAE.QA_TTC1_TEMP
            SET TC1_PERIODO = NULL
            WHERE TC1_PERIODO IS NOT NULL
            ;
            COMMIT
            ;-- ESTA ACTUALIZACION GARANTIZA EL PROCEDIMIENTO DELETE MAS ADELANTE
            
            INSERT INTO QA_TTC1_TEMP
            SELECT   TC1_TC1
                    ,TC1_CODCONEX
                    ,TC1_TIPCONEX
                    ,TC1_NT
                    ,TC1_NTP
                    ,TC1_PROPACTIV
                    ,TC1_CONEXRED
                    ,TC1_IDCOMER
                    ,TC1_IDMERC
                    ,(CASE WHEN (TC1_TIPCONEX = 'P'                                  ) THEN (TC1_GC                    )
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX NOT LIKE 'ALPM%') THEN (NVL(TT2_GRUPOCALIDAD,'NA'))
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX     LIKE 'ALPM%') THEN (TO_CHAR(MUND_GRCU)        )
                      END) AS TC1_GC
                    ,TC1_CODFRONCOM
                    ,(CASE WHEN (TC1_TIPCONEX = 'P'                                  ) THEN (TC1_CODCIRC      )
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX NOT LIKE 'ALPM%') THEN (NVL(TT2_IUL,'NA'))
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX     LIKE 'ALPM%') THEN (NULL             )
                      END) AS TC1_CODCIRC
                    ,(CASE WHEN (TC1_TIPCONEX = 'P'                                  ) THEN (NULL                  )
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX NOT LIKE 'ALPM%') THEN (NVL(TT2_CODE_IUA,'NA'))
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX     LIKE 'ALPM%') THEN ('ALPM0001'            )
                      END) AS TC1_CODTRANSF
                    ,TC1_CODDANE
                    ,TC1_UBIC
                    ,TC1_DIREC
                    ,TC1_CONESP
                    ,TC1_CODARESP
                    ,TC1_TIPARESP
                    ,TC1_ESTSECT
                    ,TC1_ALTITUD
                    ,TC1_LONGITUD
                    ,TC1_LATITUD
                    ,TC1_AUTOGEN
                    ,TC1_EXPENER
                    ,TC1_CAPAUTOGENR
                    ,TC1_TIPGENR
                    ,TC1_CODFRONEXP
                    ,TC1_FENTGEN
                    ,TC1_CONTRESP
                    ,TC1_CAPCONTRESP
                    ,TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM')) AS TC1_PERIODO
                    ,(CASE WHEN (TC1_TIPCONEX = 'P'                                  ) THEN (TC1_CODCIRC           )
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX NOT LIKE 'ALPM%') THEN (NVL(TT2_CODE_IUA,'NA'))
                           WHEN (TC1_TIPCONEX = 'T' AND TC1_CODCONEX     LIKE 'ALPM%') THEN ('ALPM0001'            )
                      END) AS TC1_IUA
            FROM BRAE.QA_TTC1_TEMP 
            LEFT OUTER JOIN (SELECT TT2_CODIGOELEMENTO
                                   ,TT2_CODE_IUA
                                   ,TT2_IUL
                                   ,TT2_GRUPOCALIDAD
                             FROM BRAE.QA_TTT2_REGISTRO
                             WHERE TT2_ESTADO='OPERACION') ON TT2_CODIGOELEMENTO = TC1_CODCONEX
            LEFT OUTER JOIN QA_TMUNDANE ON MUND_MUNDANE = SUBSTR(TC1_CODDANE,1,5)
            ;
            COMMIT 
            ;
            
            DELETE FROM BRAE.QA_TTC1_TEMP
            WHERE TC1_PERIODO IS NULL
            ;
            COMMIT
            ;     

            --REVISAR LOS REGISTROS SIN IUA Y PASARLOS A TABLA DE OBSERVACIONES DE TC1

            DELETE FROM QA_TTC1_OBS
            WHERE TC1_PERIODO = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'))
            ;
            COMMIT
            ;
            
            INSERT   INTO QA_TTC1_OBS
            SELECT * FROM QA_TTC1_TEMP
            WHERE TC1_IUA = 'NA'
            ;
            COMMIT
            ;
            
            DELETE FROM QA_TTC1_TEMP
            WHERE TC1_IUA = 'NA'
            ;
            COMMIT
            ;


            --REVISAR LOS REGISTROS SIN IUL Y PASARLOS A TABLA DE OBSERVACIONES DE TC1
            
            INSERT   INTO QA_TTC1_OBS
            SELECT * FROM QA_TTC1_TEMP
            WHERE TC1_CODCIRC = 'NA'
            ;
            COMMIT
            ;          
            
            DELETE FROM QA_TTC1_TEMP
            WHERE TC1_CODCIRC = 'NA'
            ;
            COMMIT
            ;

            
            --VERIFICACION DE QUE LOS USUARIOS NO APAREZCAN MAS DE DOS VECES, TENIENDO EN CUENTA LOS CAMBIOS ENTRE COMERCIALIZADORA

            insert into QA_TTC1_TEMP
            select distinct
                    TC1_TC1
            ,	TC1_CODCONEX
            ,	TC1_TIPCONEX
            ,	TC1_NT
            ,	TC1_NTP
            ,	TC1_PROPACTIV
            ,	TC1_CONEXRED
            ,	TC1_IDCOMER
            ,	TC1_IDMERC
            ,	TC1_GC
            ,	TC1_CODFRONCOM
            ,	TC1_CODCIRC
            ,	TC1_CODTRANSF
            ,	TC1_CODDANE
            ,	TC1_UBIC
            ,	TC1_DIREC
            ,	TC1_CONESP
            ,	TC1_CODARESP
            ,	TC1_TIPARESP
            ,	TC1_ESTSECT
            ,	TC1_ALTITUD
            ,	TC1_LONGITUD
            ,	TC1_LATITUD
            ,	TC1_AUTOGEN
            ,	TC1_EXPENER
            ,	TC1_CAPAUTOGENR
            ,	TC1_TIPGENR
            ,	TC1_CODFRONEXP
            ,	TC1_FENTGEN
            ,	TC1_CONTRESP
            ,	TC1_CAPCONTRESP
            ,	null as TC1_PERIODO
            ,	TC1_IUA
                from QA_TTC1_TEMP
                where TC1_TC1||TC1_IDCOMER in (
                                                select TC1_TC1||TC1_IDCOMER
                                                from QA_TTC1_TEMP
                                                group by TC1_TC1,TC1_IDCOMER
                                                having  count(TC1_TC1||TC1_IDCOMER) > 1
                                              )
            ;

            delete
                from QA_TTC1_TEMP
                where TC1_TC1||TC1_IDCOMER in (
                                                select TC1_TC1||TC1_IDCOMER
                                                from QA_TTC1_TEMP
                                                group by TC1_TC1,TC1_IDCOMER
                                                having  count(TC1_TC1||TC1_IDCOMER) > 1
                                              )
                and TC1_PERIODO is not null
            ;

            update QA_TTC1_TEMP
            set    TC1_PERIODO = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'))
            where  TC1_PERIODO is null;

            commit;




            --REALIZAR CODIGO PARA LA GESTION DE LA TRANSICION DE LOS USUARIOS ENTRE COMERCIALIZADORAS PARA ELIMINACION Y ADICION
            --ACTUALIZAR INFORMACION GENERAL DE LOS USUARIOS DE COMERCIALIZADORA CONTRASTADO CON EL ARCHIVO DE DESCARGA SAC
            
            --PASAR LA INFORMACION DE QA_TTC1_TEMP A QA_TTC1
            --DAR LUZ VERDE AL FORMATO DE AJUSTE Y EL PRIMER FORMATO DIARIO DEL PERIODO (t+1)
           
            /*************************************** P R O C E D I M I E N T O - P A R A - E L - R E G I S T R O - D I A R I O - L A C ***********************************************/        
            -->GENERACION DE LOS DATOS DE LA TABLA DE REFERENCIA LAC
            /*DELETE FROM QA_TFDDREFERENCIA
            WHERE FDD_PERIODO_OP = ADD_MONTHS(TRUNC(FECHAOPERACION),1);
            COMMIT;
            
            INSERT INTO BRAE.QA_TFDDREFERENCIA
            SELECT ADD_MONTHS(TRUNC(FECHAOPERACION),1) AS FDD_PERIODO_OP --periodo + 1
                  ,TT2_CODIGOELEMENTO                  AS FDD_CODIGOELEMENTO
                  ,TT2_CODE_IUA                        AS FDD_IUA
                  ,(CASE WHEN TT2_CODE_CALP = '0'
                         THEN 0
                         ELSE 1
                    END)                               AS FDD_ALUMBRADO_CALP
                  ,0                                   AS FDD_AUTOGENERADOR --pendiente por importar este valor
                  ,0                                   AS FDD_ZONA_NO_INTER
                  ,0                                   AS FDD_CONSUMO --pendiente por importar este valor; consumo (m-1)
                  ,0                                   AS FDD_CANTIDAD_USRS --Pendiente por importar este valor
            FROM BRAE.QA_TTT2_REGISTRO
            WHERE TT2_ESTADO = 'OPERACION';
            COMMIT;
            
                                    
            --Actualizar campo FDD_AUTOGENERADOR en la tabla QA_TFDDREFERENCIA, se cre� INDEX para esta busqueda en tabla QA_TTC1_TEMP
            UPDATE BRAE.QA_TFDDREFERENCIA
            SET    FDD_AUTOGENERADOR  = 1
            WHERE  FDD_CODIGOELEMENTO IN (
                                          SELECT DISTINCT TC1_CODCONEX 
                                          FROM QA_TTC1_TEMP 
                                          WHERE TC1_PERIODO = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY')||TO_CHAR(FECHAOPERACION,'MM'))
                                          AND TC1_AUTOGEN = 1
                                          )
            AND    FDD_PERIODO_OP = ADD_MONTHS(TRUNC(FECHAOPERACION),1);
            COMMIT;          
                                          
            --Actualizar campo FDD_CANTIDAD_USRS en la tabla QA_TFDDREFERENCIA
            UPDATE   BRAE.QA_TFDDREFERENCIA T1
            SET      FDD_CANTIDAD_USRS  = NVL((
                                              SELECT   COUNT(TC1_CODCONEX) AS CANT_USRS 
                                              FROM     QA_TTC1_TEMP
                                              WHERE    TC1_PERIODO  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY')||TO_CHAR(FECHAOPERACION,'MM'))
                                              AND      TC1_TIPCONEX = 'T'
                                              AND      TC1_CODCONEX = T1.FDD_CODIGOELEMENTO
                                              GROUP BY TC1_CODCONEX),0
                                              )
            WHERE    FDD_PERIODO_OP = TRUNC(ADD_MONTHS(FECHAOPERACION,1))                              
            ;
            COMMIT;*/        
            
            DBMS_OUTPUT.PUT_LINE('Se ha actualizado el formato TC1 para el periodo: '||FECHAOPERACION);


        END IF; -- "IF" CONDICIONAL 

        


END QA_PTC1_REGISTRO_FASE2;


