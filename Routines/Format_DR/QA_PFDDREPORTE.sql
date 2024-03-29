CREATE OR REPLACE PROCEDURE BRAE.QA_PFDDREPORTE(FECHAOPERACION DATE)
AS

  FECHAFRM1         NUMBER;
  CANTIDAD_REPORTE  NUMBER;
  CANTIDAD_REGISTRO NUMBER;
  V_FDR_IUA            BRAE.QA_TFDDREPORTE.FDR_IUA%TYPE;
  V_FDR_CODIGOELEMENTO BRAE.QA_TFDDREPORTE.FDR_CODIGOELEMENTO%TYPE;

  CURSOR C_TRANSFORMADORES_NA IS
    SELECT DISTINCT(TC1_CODCONEX), TC1_IUA FROM BRAE.QA_TTC1 WHERE TC1_PERIODO=FECHAFRM1 AND TC1_TIPCONEX = 'T' AND TC1_CODCONEX NOT LIKE 'ALPM%'
    MINUS
    SELECT DISTINCT(FDR_CODIGOELEMENTO), FDR_IUA FROM BRAE.QA_TFDDREPORTE  WHERE FDR_PERIODO_OP = FECHAOPERACION;

BEGIN
  --DETERMINA EL FORMATO DE USUARIOS EXISTENTE
  BEGIN
    SELECT MAX(TC1_PERIODO) INTO FECHAFRM1 FROM BRAE.QA_TTC1;
  END;
  --DETERMINA CANTIDAD DE REGISTROS DE LA CARGA DEL DIA ANTERIOR
  BEGIN
    SELECT COUNT(*) INTO CANTIDAD_REGISTRO
    FROM BRAE.QA_TFDDREGISTRO
    WHERE FDD_PERIODO_OP = TRUNC(FECHAOPERACION);
  END;

  --DETERMINAR CANTIDAD DE REGISTROS DE REPORTES EN EL REGISTRO DEL DIA ANTERIOR
  BEGIN
    SELECT COUNT(*) INTO CANTIDAD_REPORTE
    FROM BRAE.QA_TFDDREPORTE
    WHERE FDR_PERIODO_OP = TRUNC(FECHAOPERACION);
  END;


  IF CANTIDAD_REPORTE = 0 AND CANTIDAD_REGISTRO > 0 THEN

    -- CARGA LOS EVENTOS DEL PERIODO DESDE LA TABLA QA_TFDDREGISTRO A LA TABLA QA_TFDDREPORTE
    BEGIN
        INSERT INTO
        BRAE.QA_TFDDREPORTE (FDR_PERIODO_OP,
                             FDR_CODIGOEVENTO,
                             FDR_FINICIAL,
                             FDR_FFINAL,
                             FDR_CODIGOELEMENTO,
                             FDR_TIPOELEMENTO,
                             FDR_CAUSA,
                             FDR_CONTINUIDAD,
                             FDR_EXCLUIDOZNI,
                             FDR_AFECTACONGEN,
                             FDR_USUARIOAP,
                             FDR_IUA)
                      SELECT FDD_PERIODO_OP,
                             FDD_CODIGOEVENTO,
                  (CASE WHEN FDD_FINICIAL<TRUNC(FECHAOPERACION) THEN NULL ELSE FDD_FINICIAL END),
                             FDD_FFINAL,
                             FDD_CODIGOELEMENTO,
                  (CASE WHEN FDD_TIPOELEMENTO = 'Transformer' THEN '1' ELSE '0' END)
                          AS FDD_TIPOELEMENTO,
                             FDD_CAUSA_CREG,
                             FDD_CONTINUIDAD,
                      '0' AS FDR_EXCLUIDOZNI,
                      '0' AS FDR_AFECTACONGEN,
                  (CASE WHEN FDD_USUARIOAP = 'S' THEN '1' ELSE '0' END),
                             FDD_IUA
                        FROM BRAE.QA_TFDDREGISTRO
                       WHERE FDD_PERIODO_OP=TRUNC(FECHAOPERACION);
    END;
    COMMIT;

    -- ASIGNA EL VALOR 'S' AL CAMPO FDD_ESTADOREPORTE EN LA TABLA QA_FDDREGISTRO
    BEGIN
        UPDATE BRAE.QA_TFDDREGISTRO
                          SET
                             FDD_ESTADOREPORTE='S'
                       WHERE FDD_PERIODO_OP=TRUNC(FECHAOPERACION)
                       AND FDD_TIPOELEMENTO = 'Transformer';
    END;
    COMMIT;

    --INSERTA LOS TRANSFORMADORES NO AFECTADOS POR EVENTOS

    BEGIN
      OPEN C_TRANSFORMADORES_NA;
      LOOP
        FETCH C_TRANSFORMADORES_NA INTO V_FDR_CODIGOELEMENTO, V_FDR_IUA;
        EXIT WHEN C_TRANSFORMADORES_NA%NOTFOUND;
        BEGIN
          INSERT INTO BRAE.QA_TFDDREPORTE (FDR_PERIODO_OP,
                                           FDR_CODIGOEVENTO,
                                           FDR_CODIGOELEMENTO,
                                           FDR_TIPOELEMENTO,
                                           FDR_IUA)
                                   VALUES (FECHAOPERACION,
                                           'NA',
                                           V_FDR_CODIGOELEMENTO,
                                           '1',
                                           V_FDR_IUA);
        END;
      END LOOP;
      CLOSE C_TRANSFORMADORES_NA;
      COMMIT;
    END;
    
        --ESCRITURA EN TABLA LOG
         INSERT INTO QA_TLOG_EJECUCION
         SELECT SYSDATE,'QA_PFDDREPORTE','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'EXITOSO','NA' FROM DUAL;
         
 ELSE
        --ESCRITURA EN TABLA LOG
         INSERT INTO QA_TLOG_EJECUCION
         SELECT SYSDATE,'QA_PFDDREPORTE','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'FALLIDO','Intenta realizar un periodo ejecutado o un periodo anterior' FROM DUAL;
         
 END IF;

END QA_PFDDREPORTE;
/