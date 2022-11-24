CREATE OR REPLACE PROCEDURE QA_PTT3_REPORTE(FECHAOPERACION DATE) AS

  TYPE VAR_TABLE IS TABLE OF QA_TTT3_REPORTE%ROWTYPE;
  QA_VTT3_REPORTE VAR_TABLE;
  
  NO_REPORT NUMBER := 1 ;
  
BEGIN
--IDENTIFICAR EL ESTADO DE LA CERTIFICACION DEL FORMATO
    SELECT DISTINCT TT3_CERTIFICADO
    INTO NO_REPORT
    FROM BRAE.QA_TTT3_REGISTRO
    WHERE TT3_PERIODO_OP =  TRUNC(FECHAOPERACION);

    --INICIA EL PROCEDIMIENTO  QA_PTT3_REPORTE()   
    IF (NO_REPORT = 0) THEN 
    
        --BORRA LOS REGISTROS ALMACENADOS DE LA GENERACION DEL REPORTE ANTERIOR
        DELETE FROM QA_TTT3_REPORTE
        WHERE  TT3_PERIODO_OP = TRUNC(FECHAOPERACION);
        COMMIT;
        
        --INSERCCION DE LOS REGISTROS DEL REPORTE TT3 
        SELECT * 
        BULK COLLECT INTO QA_VTT3_REPORTE
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
                                 WHERE  TC1_PERIODO  = (TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))-1)||'12'
                                 AND    TC1_TIPCONEX = 'T'
                                 AND    TC1_CODCONEX NOT LIKE 'ALPM%'
                                 GROUP BY TC1_CODCIRC    
                                 ) T2 ON T2.TC1_CODCIRC =  T1.TC1_CODCIRC
                WHERE  T1.TC1_PERIODO  = (TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))-1)||'12'
                AND    T1.TC1_TIPCONEX = 'T'
                GROUP BY T1.TC1_CODCIRC,TC1_IUA,T2.CANT_USRS
            )--CIRRE DEL WITH
    
                SELECT  TRUNC(FECHAOPERACION)                          AS TT3_PERIODO_OP
                      , RG.TT3_IUS                                     AS TT3_IUS
                      , 2                                              AS TT3_CLASIFICACION
                      , TC.TC1_IUA                                     AS TT3_IUA_IUL --CRUCE TC1
                      , RG.TT3_FINICIAL                                AS TT3_FINICIAL
                      , RG.TT3_FFINAL                                  AS TT3_FFINAL
                      , TRIM(REPLACE(REPLACE(REPLACE(RG.TT3_ALCANCE,CHR(10),' ') ,CHR(13),' ') ,'  ',' '))   AS TT3_ALCANCE
                      , RG.TT3_CODIGOPROYECTO                          AS TT3_CODIGOPROYECTO
                      , 161                                            AS TT3_ID_MERCADO
                FROM BRAE.QA_TTT3_REGISTRO RG
                LEFT OUTER JOIN (SELECT * 
                                 FROM BRAE.QA_TTT3_AFECTACION 
                                 WHERE TT3_PERIODO_OP = TRUNC(FECHAOPERACION)
                                 ) AF ON AF.TT3_ID = RG.TT3_ID    
                LEFT OUTER JOIN  TC1_CODIGOS            TC ON TC.TC1_CODCIRC = AF.TT3_IUL
                WHERE RG.TT3_PERIODO_OP = TRUNC(FECHAOPERACION)
                AND TC.TC1_IUA IS NOT NULL
    
            UNION ALL
     
                SELECT  TRUNC(FECHAOPERACION)                          AS TT3_PERIODO_OP
                      , RG.TT3_IUS                                     AS IUS
                      , 1                                              AS CLASIFICACION
                      , AF.TT3_IUL                                     AS CODIGOS_TRF_CIR --CRUCE TC1
                      , RG.TT3_FINICIAL                                AS FECHA_INICIAL
                      , RG.TT3_FFINAL                                  AS FECHA_FINAL
                      , TRIM(REPLACE(REPLACE(REPLACE(RG.TT3_ALCANCE,CHR(10),' ') ,CHR(13),' ') ,'  ',' '))   AS TT3_ALCANCE
                      , RG.TT3_CODIGOPROYECTO                          AS CODIGO_PROYECTO
                      , 161                                            AS ID_MERCADO
                FROM BRAE.QA_TTT3_REGISTRO RG
                LEFT OUTER JOIN (SELECT * 
                                 FROM BRAE.QA_TTT3_AFECTACION 
                                 WHERE TT3_PERIODO_OP = TRUNC(FECHAOPERACION)
                                 ) AF ON AF.TT3_ID = RG.TT3_ID
                WHERE RG.TT3_PERIODO_OP = TRUNC(FECHAOPERACION)
    
            )--CIERRE DEL FROM GENERAL
            ;
            
            --DML INSERT DEL CURSOR ANTERIOR
            IF   QA_VTT3_REPORTE IS NOT EMPTY THEN
                 FOR i IN QA_VTT3_REPORTE.FIRST..QA_VTT3_REPORTE.LAST LOOP
                       INSERT INTO BRAE.QA_TTT3_REPORTE
                       VALUES QA_VTT3_REPORTE(i);
                 END LOOP;
                 COMMIT;
            END IF;--CIERRE IF DML
   
        END IF;--NO GENERA EL REPORTE DESPUES DE CERTIFICADO EL FORMATO

END QA_PTT3_REPORTE;