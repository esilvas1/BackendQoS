CREATE OR REPLACE PROCEDURE BRAE.QA_PFDDREVERSAR(FECHAOPERACION DATE)
AS

MAX_PERIODO DATE;
PUBLICADO VARCHAR2(2);
CANTIDAD NUMBER;


BEGIN

    SELECT MAX(FDD_PERIODO_OP) 
    INTO MAX_PERIODO
    FROM QA_TFDDREGISTRO
    ;
    
    SELECT COUNT(DISTINCT FDD_PUBLICADO) 
    INTO CANTIDAD 
    FROM QA_TFDDREGISTRO;
    
    IF CANTIDAD = 1 THEN
        SELECT DISTINCT FDD_PUBLICADO 
        INTO PUBLICADO 
        FROM QA_TFDDREGISTRO;
    END IF;

    IF MAX_PERIODO = FECHAOPERACION AND PUBLICADO = 'N' AND CANTIDAD = 1 THEN
  --ELIMINA LOS REGISTROS DE RECONFIG N
				DELETE FROM QA_TFDDREGISTRO
				WHERE FDD_PERIODO_OP = FECHAOPERACION
				AND FDD_RECONFIG ='N';
				COMMIT;
  --ACTUALIZA A LA FORMA ANTERIOR LOS REGISTROS RECONFIG S
				UPDATE QA_TFDDREGISTRO
				SET
				FDD_FFINAL =  NULL,
				FDD_CONTINUIDAD = 'S',
				FDD_FREG_CIERRE = NULL,
				FDD_PERIODO_OP = TRUNC(FDD_FINICIAL),
				FDD_RECONFIG = 'N'
				WHERE FDD_PERIODO_OP = FECHAOPERACION
				AND FDD_RECONFIG = 'S';
				COMMIT;

  --ELIMINA EL REPORTE CREADO
				DELETE FROM QA_TFDDREPORTE
				WHERE FDR_PERIODO_OP=FECHAOPERACION;
				COMMIT;
                
    --ESCRITURA EN TABLA LOG
                INSERT INTO QA_TLOG_EJECUCION
                SELECT SYSDATE,'QA_PFDDREVERSAR','PROCEDIMIENTO','UNKNOWN','EXITOSO','NA' FROM DUAL;
    ELSE
    --ESCRITURA EN TABLA LOG
                IF MAX_PERIODO <> FECHAOPERACION THEN
                    INSERT INTO QA_TLOG_EJECUCION
                    SELECT SYSDATE,'QA_PFDDREVERSAR','PROCEDIMIENTO','UNKNOWN','FALLIDO','Intento de reversión a un periodo no permitido' FROM DUAL;
                ELSE
                    IF CANTIDAD > 1 THEN
                        INSERT INTO QA_TLOG_EJECUCION
                        SELECT SYSDATE,'QA_PFDDREVERSAR','PROCEDIMIENTO','UNKNOWN','FALLIDO','Existe incongruencia en los valores del campo FDD_PUBLICADO' FROM DUAL;
                    ELSE
                        IF PUBLICADO = 'S' THEN
                            INSERT INTO QA_TLOG_EJECUCION
                            SELECT SYSDATE,'QA_PFDDREVERSAR','PROCEDIMIENTO','UNKNOWN','FALLIDO','Intento de reversión a un periodo publicado' FROM DUAL;
                        END IF;
                    END IF;
                END IF;
    END IF;
    



END QA_PFDDREVERSAR;
/