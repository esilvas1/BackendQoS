CREATE OR REPLACE PROCEDURE BRAE.QA_PTT11_REPORTE(FECHAOPERACION DATE) AS

  TYPE VAR_TABLE IS TABLE OF QA_TTT11_REPORTE%ROWTYPE;
  QA_VTT11_REPORTE VAR_TABLE;
  
  NO_REPORT NUMBER := 0 ;
  CANTIDAD NUMBER;

BEGIN
--IDENTIFICAR EL ESTADO DE LA CERTIFICACION DEL FORMATO
    /*SELECT DISTINCT TT11_CERTIFICADO
    INTO NO_REPORT
    FROM BRAE.QA_TTT11_REGISTRO
    WHERE TT11_PERIODO_OP =  TRUNC(FECHAOPERACION);*/
    
    ---IDENTIFICA EXISTENCIA DE UN REPORTE
    SELECT COUNT(*)
    INTO CANTIDAD
    FROM BRAE.QA_TTT11_REPORTE
    WHERE TT11_PERIODO_OP =  TRUNC(FECHAOPERACION);
    

    --INICIA EL PROCEDIMIENTO  QA_PTT3_REPORTE()   
    IF (CANTIDAD=0) THEN -- NO_REPORT = 0; Y 1 TEMPORALEMNTE PARA RETROACTIVO
    
        --BORRA LOS REGISTROS ALMACENADOS DE LA GENERACION DEL REPORTE ANTERIOR
        DELETE FROM QA_TTT11_REPORTE
        WHERE  TT11_PERIODO_OP = TRUNC(FECHAOPERACION);
        COMMIT;
        
        --INSERCCION DE LOS REGISTROS DEL REPORTE TT3 
        SELECT * 
        BULK COLLECT INTO QA_VTT11_REPORTE
        FROM(        
            WITH TC1_CODIGOS AS
            (
                SELECT DISTINCT T1.TC1_CODCIRC
                            ,T1.TC1_IUA
                            ,COUNT(T1.TC1_IUA) AS CANT_USRS_T
                            ,T2.CANT_USRS      AS CANT_USRS_C
                FROM   QA_TTC1 T1
                LEFT OUTER JOIN (
                                 SELECT DISTINCT TC1_CODCIRC
                                             ,COUNT(TC1_CODCIRC) AS CANT_USRS
                                 FROM   QA_TTC1
                                 WHERE  TC1_PERIODO = TO_NUMBER(TO_CHAR(ADD_MONTHS(FECHAOPERACION,-2),'YYYYMM'))
                                 AND    TC1_TIPCONEX = 'T'
                                 GROUP BY TC1_CODCIRC    
                                 ) T2 ON T2.TC1_CODCIRC =  T1.TC1_CODCIRC
                WHERE  T1.TC1_PERIODO = TO_NUMBER(TO_CHAR(ADD_MONTHS(FECHAOPERACION,-2),'YYYYMM'))
                AND    T1.TC1_TIPCONEX = 'T'
                GROUP BY T1.TC1_CODCIRC,TC1_IUA,T2.CANT_USRS
            )
            
                SELECT  TRUNC(FECHAOPERACION)                          AS PERIODO_OP
                      , RG.TT11_ID                                     AS IDENTIFICACION  
                      , TO_NUMBER(CASE WHEN(RG.TT11_TIPOPROYECTO='MODERNIZACION')  THEN '2'
                                       WHEN(RG.TT11_TIPOPROYECTO='REPOSICION') THEN '1'                       
                         END)                                          AS ACTIVIDAD
                      , TRIM(REPLACE(REPLACE(REPLACE(RG.TT11_ALCANCE,CHR(10),' ') ,CHR(13),' ') ,'  ',' '))   AS OBJETIVO
                      , TC.TC1_IUA                                     AS CODIGOS_IUA_IUL --CRUCE TC1
                      , NVL(TC.CANT_USRS_T,0)                          AS USUARIOS_AFECTADOS --CRUCE TC1
                      , RG.TT11_FINICIAL                               AS FECHA_INICIAL
                      , RG.TT11_FFINAL                                 AS FECHA_FINAL
                      , ROUND((RG.TT11_FFINAL-RG.TT11_FINICIAL)*24,2)  AS DURACION
                      ,'MSJ TEXTO-CORREO-CARTA OFICIO'                 AS MEDIO_PUBLICACION
                      , TRUNC(RG.TT11_FINICIAL)-8                      AS FECHA_ESTIMADA_PUBLICACION --CONFIGURAR CON EL PROCEDIMIENTO
                      , TO_CHAR(RG.TT11_FINICIAL,'MM')                 AS MES_PROYECCION
                FROM BRAE.QA_TTT11_REGISTRO RG
                LEFT OUTER JOIN (SELECT * 
                                 FROM BRAE.QA_TTT3_AFECTACION 
                                 WHERE TT3_PERIODO_OP = TO_DATE('01/01/'||TO_CHAR(FECHAOPERACION,'YYYY'),'DD/MM/YYYY')
                                 )                      AF ON AF.TT3_ID      = RG.TT11_ID              
                LEFT OUTER JOIN TC1_CODIGOS             TC ON TC.TC1_CODCIRC = AF.TT3_IUL
                WHERE RG.TT11_PERIODO_OP = FECHAOPERACION

            UNION ALL

                SELECT  TRUNC(FECHAOPERACION)                          AS PERIODO_OP
                      , RG.TT11_ID                                     AS IDENTIFICACION  
                      , TO_NUMBER(CASE WHEN(RG.TT11_TIPOPROYECTO='MODERNIZACION')  THEN '2'
                                       WHEN(RG.TT11_TIPOPROYECTO='REPOSICION') THEN '1'                       
                         END)                                          AS ACTIVIDAD
                      , TRIM(REPLACE(REPLACE(REPLACE(RG.TT11_ALCANCE,CHR(10),' ') ,CHR(13),' ') ,'  ',' '))   AS OBJETIVO
                      , AF.TT3_IUL                                     AS CODIGOS_IUA_IUL --CRUCE TC1
                      , NVL(TC.CANT_USRS_C,0)                          AS USUARIOS_AFECTADOS --CRUCE TC1
                      , RG.TT11_FINICIAL                               AS FECHA_INICIAL
                      , RG.TT11_FFINAL                                 AS FECHA_FINAL
                      , ROUND((RG.TT11_FFINAL-RG.TT11_FINICIAL)*24,2)  AS DURACION
                      ,'MSJ TEXTO-CORREO-CARTA OFICIO'                 AS MEDIO_PUBLICACION
                      , TRUNC(RG.TT11_FINICIAL)-8                      AS FECHA_ESTIMADA_PUBLICACION --CONFIGURAR CON EL PROCEDIMIENTO
                      , TO_CHAR(RG.TT11_FINICIAL,'MM')                 AS MES_PROYECCION
                FROM BRAE.QA_TTT11_REGISTRO RG
                LEFT OUTER JOIN (SELECT * 
                                 FROM BRAE.QA_TTT3_AFECTACION 
                                 WHERE TT3_PERIODO_OP = TO_DATE('01/01/'||TO_CHAR(FECHAOPERACION,'YYYY'),'DD/MM/YYYY')
                                 )                      AF ON AF.TT3_ID      = RG.TT11_ID              
                LEFT OUTER JOIN (SELECT DISTINCT TC1_CODCIRC
                                       ,CANT_USRS_C
                                       FROM TC1_CODIGOS)              TC ON TC.TC1_CODCIRC = AF.TT3_IUL
                WHERE RG.TT11_PERIODO_OP = FECHAOPERACION
                
            )--CIERRE DEL FROM GENERAL
            ;
            
            --DML INSERT DEL CURSOR ANTERIOR
            IF   QA_VTT11_REPORTE IS NOT EMPTY THEN
                 FOR i IN QA_VTT11_REPORTE.FIRST..QA_VTT11_REPORTE.LAST LOOP
                       INSERT INTO BRAE.QA_TTT11_REPORTE
                       VALUES QA_VTT11_REPORTE(i);
                 END LOOP;
                 COMMIT;
            END IF;--CIERRE IF DML
            
            --ELIMINAR LOS REGISTRSO CON CANTIDAD DE USUARIO = 0
            DELETE FROM QA_TTT11_REPORTE
            WHERE TT11_PERIODO_OP=TRUNC(FECHAOPERACION)
            AND TT11_USRS_AFECTADOS IN '0'
            ;
            COMMIT;

            --ELIMINA Y LIMIPIA LA TABLA QA_TTT2_REGISTRO
            DELETE FROM QA_TTT11_REGISTRO WHERE ROWNUM >= 0;
            COMMIT;

    END IF;--NO GENERA REPORTE SI YA EXISTE UN REPORTE
    
END QA_PTT11_REPORTE;