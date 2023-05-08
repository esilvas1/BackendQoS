CREATE OR REPLACE PROCEDURE QA_PTT12_REPORTE(FECHAOPERACION DATE) AS


BEGIN
    ---IDENTIFICA EXISTENCIA DE UN REPORTE
 
    
    --INSERTAR LOS REGISTROS DE EVENTOS PROGRAMADOS PERO NO EJECUTADOS    
    INSERT INTO QA_TTT12_REPORTE
    SELECT FECHAOPERACION AS TT12_PERIODO_OP   
        ,TO_NUMBER(TT3_ID)	AS	TT12_ID
        ,TO_CHAR(NOMBRE_CIRCUITO)	AS	TT12_NOMBRE_CIRCUITO
        ,TO_CHAR(CIRCUITO)	AS	TT12_CIRCUITO
        ,TO_NUMBER(ACTIVIDAD)	AS	TT12_ACTIVIDAD
        ,TO_CHAR(CODIGO_IUA_IUL)	AS	TT12_CODIGO_IUA_IUL
        ,TO_NUMBER(USUARIOS_AFECTADOS)	AS	TT12_USUARIOS_AFECTADOS
        ,TRUNC(FECHA_INICIAL)	AS	TT12_FINICIAL
        ,TRUNC(FECHA_FINAL)		AS	TT12_FFINAL
        ,ROUND(DURACION,2)	AS	TT12_DURACION
        ,TO_CHAR(MES_EJECUCION)	AS	TT12_MES_EJECUCION 
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
                             WHERE  TC1_PERIODO  = TO_CHAR(ADD_MONTHS(FECHAOPERACION,-2),'YYYYMM')
                             AND    TC1_TIPCONEX = 'T'
                             GROUP BY TC1_CODCIRC    
                             ) T2 ON T2.TC1_CODCIRC =  T1.TC1_CODCIRC
            WHERE  T1.TC1_PERIODO  = TO_CHAR(ADD_MONTHS(FECHAOPERACION,-2),'YYYYMM')
            AND    T1.TC1_TIPCONEX = 'T'
            GROUP BY T1.TC1_CODCIRC,TC1_IUA,T2.CANT_USRS
        )
        
                
                    SELECT  TO_NUMBER(AF.TT3_ID) AS TT3_ID
                          , AF.TT3_CIRCUITO NOMBRE_CIRCUITO
                          , AF.TT3_IUL AS CIRCUITO
                          , TO_NUMBER(RG.TT11_ACTIVIDAD) AS ACTIVIDAD
                          --, RG.TT11_DESCRIPCION                            AS OBJETIVO
                          , TO_CHAR(TC.TC1_IUA)                                     AS CODIGO_IUA_IUL --CRUCE TC1
                          , NVL(TC.CANT_USRS_T,0)                          AS USUARIOS_AFECTADOS --CRUCE TC1
                          , RG.TT11_FINICIAL AS FECHA_INICIAL
                          , RG.TT11_FFINAL AS FECHA_FINAL
                          ,0   AS DURACION
                          , TO_CHAR(RG.TT11_FINICIAL,'MM')                 AS MES_EJECUCION
                    FROM (SELECT DISTINCT TT11_ID,TT11_ACTIVIDAD,TT11_FINICIAL,TT11_FFINAL FROM QA_TTT11_REPORTE
                          WHERE TT11_PERIODO_OP = TRUNC(FECHAOPERACION)) RG
                    LEFT OUTER JOIN (SELECT * FROM BRAE.QA_TTT3_AFECTACION
                                     WHERE TT3_PERIODO_OP =  TRUNC(FECHAOPERACION,'YYYY')) AF ON AF.TT3_ID     = RG.TT11_ID
                    LEFT OUTER JOIN  TC1_CODIGOS             TC ON TC.TC1_CODCIRC = AF.TT3_IUL
                    
                
        UNION ALL
                
                    SELECT  TO_NUMBER(AF.TT3_ID) AS TT3_ID
                          , AF.TT3_CIRCUITO
                          , AF.TT3_IUL
                          , TO_NUMBER(RG.TT11_ACTIVIDAD) AS ACTIVIDAD
                          , TO_CHAR(AF.TT3_IUL)                                    AS CODIGOS_IUA_IUL --CRUCE TC1
                          , NVL(TC.CANT_USRS_C,0)                          AS USUARIOS_AFECTADOS --CRUCE TC1
                          , RG.TT11_FINICIAL AS FECHA_INICIAL
                          , RG.TT11_FFINAL AS FECHA_FINAL
                          , 0   AS DURACION
                          , TO_CHAR(RG.TT11_FINICIAL,'MM')                 AS MES_EJECUCION
                    FROM (SELECT DISTINCT TT11_ID,TT11_ACTIVIDAD,TT11_FINICIAL,TT11_FFINAL FROM QA_TTT11_REPORTE
                          WHERE TT11_PERIODO_OP = TRUNC(FECHAOPERACION)) RG
                    LEFT OUTER JOIN (SELECT * FROM BRAE.QA_TTT3_AFECTACION
                                     WHERE TT3_PERIODO_OP =  TRUNC(FECHAOPERACION,'YYYY')) AF ON AF.TT3_ID     = RG.TT11_ID
                    LEFT OUTER JOIN (SELECT DISTINCT TC1_CODCIRC
                                           ,CANT_USRS_C
                                           FROM TC1_CODIGOS)              TC ON TC.TC1_CODCIRC = AF.TT3_IUL
                
        )
        WHERE TT3_ID IN (
                        SELECT DISTINCT TT11_ID FROM QA_TTT11_REPORTE
                        WHERE TT11_PERIODO_OP=TRUNC(FECHAOPERACION)
                        MINUS
                        SELECT  DISTINCT TT12_ID FROM QA_TTT12_TEMP        
                        )
        AND TO_NUMBER(USUARIOS_AFECTADOS)<>0;
        COMMIT;
        
    --INSERTAR LOS REGISTROS DE EVENTOS PROGRAMADOS Y EJECUTADOS          
        INSERT INTO QA_TTT12_REPORTE        
        SELECT FECHAOPERACION AS TT12_PERIODO_OP
        ,TO_NUMBER(TT3_ID)	AS	TT3_ID
        ,TO_CHAR(NOMBRE_CIRCUITO)	AS	NOMBRE_CIRCUITO
        ,TO_CHAR(CIRCUITO)	AS	CIRCUITO
        ,TO_NUMBER(ACTIVIDAD)	AS	ACTIVIDAD
        ,TO_CHAR(CODIGO_IUA_IUL)	AS	CODIGO_IUA_IUL
        ,TO_NUMBER(USUARIOS_AFECTADOS)	AS	USUARIOS_AFECTADOS
        ,FECHA_INICIAL	AS	FECHA_INICIAL
        ,FECHA_FINAL	AS	FECHA_FINAL
        ,DURACION	AS	DURACION
        ,TO_CHAR(MES_EJECUCION)	AS	MES_EJECUCION 
        FROM    (

                SELECT T2.TT12_ID AS TT3_ID
                      ,T1.TT1_NOMBRECIRCUITO AS NOMBRE_CIRCUITO
                      , T.TC1_CODCIRC AS CIRCUITO
                      , T2.TT12_ACTIVIDAD AS ACTIVIDAD
                      , FDD_IUA AS CODIGO_IUA_IUL
                      , T.CANT_USRS AS USUARIOS_AFECTADOS      
                      , TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') AS FECHA_INICIAL
                      , TO_DATE(TO_CHAR(FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') AS FECHA_FINAL
                      , ROUND((TO_DATE(TO_CHAR(FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
                      - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24,2) AS DURACION
                      ,TO_CHAR(FECHAOPERACION,'MM') AS MES_EJECUCION
                FROM QA_TFDDREGISTRO R
                LEFT OUTER JOIN (
                                SELECT DISTINCT 
                                       TC1_CODCONEX
                                      ,TC1_CODCIRC
                                      ,COUNT(TC1_CODCONEX) AS CANT_USRS
                                FROM QA_TTC1
                                WHERE TC1_PERIODO = TO_CHAR(FECHAOPERACION,'YYYYMM')
                                AND   TC1_TIPCONEX =  'T'
                                AND   TC1_CODCONEX NOT LIKE 'ALPM%'
                                GROUP BY TC1_CODCONEX
                                        ,TC1_CODCIRC
                                 ) T ON T.TC1_CODCONEX = R.FDD_CODIGOELEMENTO 
                LEFT OUTER JOIN QA_TTT1_REGISTRO T1 ON T1.TT1_CODIGOCIRCUITO = T.TC1_CODCIRC
                LEFT OUTER JOIN (SELECT DISTINCT TT12_CODIGOEVENTO,TT12_ID, TT12_ACTIVIDAD FROM QA_TTT12_TEMP) T2 ON T2.TT12_CODIGOEVENTO = R.FDD_CODIGOEVENTO
                WHERE TO_CHAR(FDD_FINICIAL,'MM/YYYY') = TO_CHAR(FECHAOPERACION,'MM/YYYY')
                --AND FDD_CAUSA_SSPD IN ('14')
                AND FDD_CAUSA_CREG IN ('10')
       

        UNION ALL
        
                SELECT ID AS TT3_ID
                      ,TT1_NOMBRECIRCUITO
                      ,CIRCUITO AS CIRC1
                      ,ACTIVIDAD
                      ,CIRCUITO AS CIRC2
                      ,SUM(NUM_USRS) AS NUM_USRS
                      ,FINICIAL AS FINICIAL
                      ,FFINAL AS FFINAL
                      ,DURACION
                      ,MES_EJECUCION
                        FROM(
                            SELECT T2.TT12_ID AS ID
                                  ,T1.TT1_NOMBRECIRCUITO
                                  ,T.TC1_CODCIRC AS CIRCUITO
                                  ,T2.TT12_ACTIVIDAD AS ACTIVIDAD
                                  --, FDD_IUA AS CODIGO_CIR_TRA
                                  , T.CANT_USRS AS NUM_USRS
                                  , TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') AS FINICIAL
                                  , TO_DATE(TO_CHAR(FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') AS FFINAL
                                  , ROUND((TO_DATE(TO_CHAR(FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
                                  - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24,2) AS DURACION
                                  ,TO_CHAR(FECHAOPERACION,'MM') AS MES_EJECUCION
                            FROM QA_TFDDREGISTRO R
                            LEFT OUTER JOIN (
                                            SELECT DISTINCT
                                                   TC1_CODCONEX
                                                  ,TC1_CODCIRC
                                                  ,COUNT(TC1_CODCONEX) AS CANT_USRS
                                            FROM QA_TTC1
                                            WHERE TC1_PERIODO = TO_CHAR(FECHAOPERACION,'YYYYMM')
                                            AND   TC1_TIPCONEX =  'T'
                                            AND   TC1_CODCONEX NOT LIKE 'ALPM%'
                                            GROUP BY TC1_CODCONEX
                                                    ,TC1_CODCIRC
                                             ) T ON T.TC1_CODCONEX = R.FDD_CODIGOELEMENTO
                            LEFT OUTER JOIN QA_TTT1_REGISTRO T1 ON T1.TT1_CODIGOCIRCUITO = T.TC1_CODCIRC
                            LEFT OUTER JOIN (SELECT DISTINCT TT12_CODIGOEVENTO,TT12_ID, TT12_ACTIVIDAD FROM QA_TTT12_TEMP) T2 ON T2.TT12_CODIGOEVENTO = R.FDD_CODIGOEVENTO
                            WHERE TO_CHAR(FDD_FINICIAL,'MM/YYYY') = TO_CHAR(FECHAOPERACION,'MM/YYYY')
                            --AND FDD_CAUSA_SSPD IN ('14')
                            AND FDD_CAUSA_CREG IN ('10')
                            )
                         GROUP BY ID
                                ,TT1_NOMBRECIRCUITO
                                ,CIRCUITO
                                ,FINICIAL
                                ,FFINAL
                                ,DURACION
                                ,MES_EJECUCION
                                ,ACTIVIDAD
                ) ;
            COMMIT;
            
            --BORRAR TABLA QA_TTT12_TEMP;
            DELETE FROM QA_TTT12_TEMP WHERE ROWNUM >= 0;
            COMMIT;

            --Marcar las actividades ejecutadas en QA_TTT3_REGISTRO
            update QA_TTT3_REGISTRO
            SET TT3_EJECUTADO = 1
            where TT3_ID in (select distinct TT12_ID from QA_TTT12_REPORTE
                             where TT12_PERIODO_OP = trunc(FECHAOPERACION)
                             and TT12_DURACION <> 0
                            )
            and TT3_PERIODO_OP = trunc(FECHAOPERACION,'yyyy') ;
            commit;
     
    
END QA_PTT12_REPORTE;