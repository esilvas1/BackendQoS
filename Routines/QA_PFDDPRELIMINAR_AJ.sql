CREATE OR REPLACE PROCEDURE BRAE.QA_PFDDPRELIMINAR_AJ(FECHAOPERACION IN DATE)
AS
--En el sigueinte se definen los tipos de ajustes segun su naturalidad, y con el cual se presentan los siguientes casos:
--CASO 1: EVENTOS NR  (Modificar Eventos), FDD_TIPOAJUSTE=2
--CASO 2: AJUSTE TC1  (Agregar   Eventos), FDD_TIPOAJUSTE=1
--CASO 3: AJUSTE TC1  (Eliminar  Eventos), FDD_TIPOAJUSTE=3
--CASO 4: EVENTOS MOD (Modificar Eventos), FDD_TIPOAJUSTE=2
--CASO 5: EVENTOS MOD (Eliminar  Eventos), FDD_TIPOAJUSTE=3

  CONTADOR             NUMBER;
  PERIODO_TC1          NUMBER;
  FECHAREGISTRO        DATE;
  PERIODO_MAX_REG      DATE;
  AJUSTADO             NUMBER;
  CANT_REG_TC1         NUMBER;

  TYPE T_QA_TFDDPRELIMINAR_AJ IS TABLE OF QA_TFDDPRELIMINAR_AJ%ROWTYPE;
  V_QA_TFDDPRELIMINAR_AJ T_QA_TFDDPRELIMINAR_AJ;

   --VAR_A
  TYPE RECORD_A IS RECORD
  ( TC1_CODCONEX       BRAE.QA_TTC1.TC1_CODCONEX%TYPE);
  TYPE TABLE_A IS TABLE OF RECORD_A;
  VAR_A TABLE_A;

  --VAR_B
  TYPE RECORD_B IS RECORD
  ( CAUSA_OR   OMS.CAUSAS.CODE%TYPE,
    CAUSA015   OMS.CAUSAS.CAUSA015%TYPE);
  TYPE TABLE_B IS TABLE OF RECORD_B;
  VAR_B TABLE_B;

  --VAR_C
  TYPE RECORD_C IS RECORD
  ( ELEMENTO      QA_TCONSUMOSDIA.CONS_ELEMENTO%TYPE,
    CONSUMO       QA_TCONSUMOSDIA.CONS_DIARIO%TYPE);
  TYPE TABLE_C IS TABLE OF RECORD_C;
  VAR_C TABLE_C;


  --VAR_D
  TYPE RECORD_D IS RECORD
  ( FDD_CODIGOEVENTO   QA_TFDDPRELIMINAR_AJ.FDD_CODIGOEVENTO%TYPE,
    FDD_ENS_EVENTO     QA_TFDDPRELIMINAR_AJ.FDD_ENS_EVENTO%TYPE);
  TYPE TABLE_D IS TABLE OF RECORD_D;
  VAR_D TABLE_D;

  --VAR_E
  TYPE RECORD_E IS RECORD
  ( FDC_CAUSA_OMS   BRAE.QA_TFDDCAUSAS.FDC_CAUSA_OMS%TYPE,
    FDC_EXCLUSION   BRAE.QA_TFDDCAUSAS.FDC_EXCLUSION%TYPE);
  TYPE TABLE_E IS TABLE OF RECORD_E;
  VAR_E TABLE_E;

  --VAR_F
  TYPE RECORD_F IS RECORD
  ( FDC_CAUSA_OMS    BRAE.QA_TFDDCAUSAS.FDC_CAUSA_OMS%TYPE,
    FDC_CAUSA_SSPD   BRAE.QA_TFDDCAUSAS.FDC_CAUSA_SSPD%TYPE);
  TYPE TABLE_F IS TABLE OF RECORD_F;
  VAR_F TABLE_F;

  --VAR_G
  TYPE RECORD_G IS RECORD
  ( FDD_CODIGOEVENTO     BRAE.QA_TFDDPRELIMINAR_AJ.FDD_CODIGOEVENTO%TYPE,
    FDD_FINICIAL         BRAE.QA_TFDDPRELIMINAR_AJ.FDD_FINICIAL%TYPE,
    FDD_FFINAL           BRAE.QA_TFDDPRELIMINAR_AJ.FDD_FFINAL%TYPE,
    FDD_CODIGOELEMENTO   BRAE.QA_TFDDPRELIMINAR_AJ.FDD_CODIGOELEMENTO%TYPE);
  TYPE TABLE_G IS TABLE OF RECORD_G;
  VAR_G TABLE_G;

  --VAR_H
  TYPE RECORD_H IS RECORD
  ( FDD_CODIGOEVENTO     BRAE.QA_TFDDPRELIMINAR_AJ.FDD_CODIGOEVENTO%TYPE,
    FDD_FINICIAL         BRAE.QA_TFDDPRELIMINAR_AJ.FDD_FINICIAL%TYPE,
    FDD_FFINAL           BRAE.QA_TFDDPRELIMINAR_AJ.FDD_FFINAL%TYPE,
    FDD_CODIGOELEMENTO   BRAE.QA_TFDDPRELIMINAR_AJ.FDD_CODIGOELEMENTO%TYPE);
  TYPE TABLE_H IS TABLE OF RECORD_H;
  VAR_H TABLE_H;

  --VAR_I
  TYPE RECORD_I IS RECORD
  ( FDD_CODIGOEVENTO    BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
    FDD_CODIGOELEMENTO  BRAE.QA_TFDDREGISTRO.FDD_CODIGOELEMENTO%TYPE);
  TYPE TABLE_I IS TABLE OF RECORD_I;
  VAR_I TABLE_I;

  --VAR_J
  TYPE RECORD_J IS RECORD
  ( FDD_CODIGOEVENTO    BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
    FDD_CODIGOELEMENTO  BRAE.QA_TFDDREGISTRO.FDD_CODIGOELEMENTO%TYPE);
  TYPE TABLE_J IS TABLE OF RECORD_J;
  VAR_J TABLE_J;


BEGIN

  --DETERMINA LA CANTIDAD DE REGISTROS EXISTENTES DEL FORMATO TC1 DEL PERIODO DESEADO
    SELECT COUNT(*)
    INTO CANT_REG_TC1
    FROM QA_TTC1
    WHERE TC1_PERIODO=TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'));
    
    IF CANT_REG_TC1 > 0 THEN
        DBMS_OUTPUT.PUT_LINE('EXISTE TC1');
        
      --ALINEAR EL CAMPO FDD_PERIODO_TC1 DE LA TABLA QA_TFDDREGISTRO, DEL PERIODO (m) AL TC1 CORRESPONDIENTE
         UPDATE BRAE.QA_TFDDREGISTRO
             SET   FDD_PERIODO_TC1 = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'))
             WHERE FDD_FINICIAL   >= FECHAOPERACION
             AND   FDD_FINICIAL   <  ADD_MONTHS(FECHAOPERACION,1);
             COMMIT;
    
    
      --EXTRAER LAS FECHAS PRINCIPALES PARA EL CALCULO DE LOS CONSUMOS Y PARA LA CANTDAD DE USUARIOS POR MES
        SELECT TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM')) INTO PERIODO_TC1 FROM DUAL;
        SELECT SYSDATE                    INTO FECHAREGISTRO   FROM DUAL;
        SELECT TRUNC(MAX(FDD_PERIODO_OP)) INTO PERIODO_MAX_REG FROM BRAE.QA_TFDDREGISTRO;
    
    
      --BORRAR REGISTROS ALMACENADOS ANTERIORMENTE
        DELETE FROM BRAE.QA_TFDDPRELIMINAR_AJ
        COMMIT;
    
        SELECT COUNT(DISTINCT FDD_AJUSTADO) AS AJUSTADO
        INTO AJUSTADO
        FROM QA_TFDDREGISTRO
        WHERE TRUNC(FDD_FINICIAL,'MM') = TRUNC(FECHAOPERACION)
        AND   FDD_AJUSTADO = 'S'
        ;
            
        IF AJUSTADO = 0 THEN    
            DELETE FROM BRAE.QA_TFDDRESUMEN_AJ
            WHERE FDD_PERIODO_OP = TRUNC(FECHAOPERACION);
            COMMIT;
        END IF;
    
      --COLOCAR CADA REGISTRO EN LA TABLA QA_TFDDPRELIMINAR_AJ
    
                    SELECT  I.MINICIAL AS FDD_CODIGOEVENTO
                            ,TO_TIMESTAMP(TO_CHAR(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MI.FECHAMS<0) THEN(0) ELSE(MI.FECHAMS) END)),3,'0')),'DD/MM/YYYY hh24:mi:ss.FF3') AS FDD_FINICIAL
                            ,(CASE WHEN I.FFINAL>=PERIODO_MAX_REG + 1 THEN NULL ELSE TO_TIMESTAMP(CASE WHEN I.FFINAL IS NULL THEN NULL ELSE TO_CHAR(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MF.FECHAMS<0) THEN(0) ELSE(MF.FECHAMS) END)),3,'0')) END,'DD/MM/YYYY hh24:mi:ss.FF3') END) AS FDD_FFINAL
                            ,I.TRAFO AS FDD_CODIGOELEMENTO
                            ,I.TYPEEQUIP AS FDD_TIPOELEMENTO
                            ,NULL AS FDD_CONSUMODIA
                            ,NULL AS FDD_ENS_ELEMENTO
                            ,NULL AS FDD_ENS_EVENTO
                            ,NULL AS FDD_ENEG_EVENTO
                            ,NULL AS FDD_ENEG_ELEMENTO
                            ,NULL AS FDD_CODIGOGENERADOR
                            ,MI.CAUSA AS FDD_CAUSA
                            ,NULL AS FDD_CAUSA_CREG
                            ,'N' AS FDD_USUARIOAP
                            ,(CASE WHEN (I.FFINAL>=PERIODO_MAX_REG + 1 OR I.FFINAL IS NULL) THEN 'S' ELSE 'N' END) AS FDD_CONTINUIDAD
                            ,'N' AS FDD_ESTADOREPORTE
                            ,'N' AS FDD_PUBLICADO
                            ,'N' AS FDD_RECONFIG
                            ,TRUNC(FECHAOPERACION) AS FDD_PERIODO_OP
                            ,FECHAREGISTRO AS FDD_FREG_APERTURA
                            ,(CASE WHEN (I.FFINAL>=PERIODO_MAX_REG + 1 OR I.FFINAL IS NULL) THEN NULL ELSE FECHAREGISTRO END) AS FDD_FREG_CIERRE
                            ,NULL AS FDD_FPUB_APERTURA
                            ,NULL AS FDD_FPUB_CIERRE
                            ,NVL(R.FDD_PERIODO_TC1,0) AS FDD_PERIODO_TC1
                            ,'NR' AS FDD_TIPOCARGA
                            ,NULL AS FDD_EXCLUSION
                            ,NULL AS FDD_CAUSA_SSPD
                            ,'N' AS FDD_AJUSTADO
                            ,'2' AS FDD_TIPOAJUSTE
                            ,'*' AS FDD_RADICADO
                            ,'N' AS FDD_APROBADO
                            ,NULL AS FDD_IUA
                      BULK  COLLECT INTO V_QA_TFDDPRELIMINAR_AJ
                      FROM  OMS.INTERUPC I
                      LEFT  OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL
                      LEFT  OUTER JOIN OMS.MANIOBRAS MF ON MF.CODE = I.MFINAL
                      LEFT  OUTER JOIN QA_TFDDREGISTRO R ON (R.FDD_CODIGOEVENTO = I.MINICIAL AND R.FDD_CODIGOELEMENTO = I.TRAFO)
                      WHERE MI.CAUSA <> 'PRUEBA'
                      AND   MI.TIPO  <> 'PRUEBA'
                      AND   MI.EJECUTADO = 1
                      AND   I.TYPEEQUIP IN ('Transformer')
                      AND   NVL(R.FDD_PERIODO_TC1,0) = 0
                      AND   ((   I.FINICIAL >= TO_DATE('01/'||TO_CHAR(FECHAOPERACION,'MM/YYYY'),'DD/MM/YYYY')
                             AND I.FINICIAL <  LAST_DAY(FECHAOPERACION) + 1)
                          OR (   I.FFINAL   >= TO_DATE('01/'||TO_CHAR(FECHAOPERACION,'MM/YYYY'),'DD/MM/YYYY')
                             AND I.FFINAL   <  LAST_DAY(FECHAOPERACION) + 1));
    
                      IF V_QA_TFDDPRELIMINAR_AJ IS NOT EMPTY THEN
                        FOR i IN V_QA_TFDDPRELIMINAR_AJ.FIRST..V_QA_TFDDPRELIMINAR_AJ.LAST LOOP
                          --IF V_QA_TFDDPRELIMINAR_AJ(i).FDD_PERIODO_TC1 = 0 THEN -- INSERTAR SOLO LOS QUE PERIODO ES IGUAL A CERO
                              IF V_QA_TFDDPRELIMINAR_AJ(i).FDD_FINICIAL IS NOT NULL THEN
                                  INSERT INTO QA_TFDDPRELIMINAR_AJ
                                  VALUES V_QA_TFDDPRELIMINAR_AJ(i);
                              END IF;
                          --END IF;
                        END LOOP;
                        COMMIT;
                      END IF;
    
    
        --SELECCIONAR LOS REGISTROS NR Y ALOJARLOS SOBRE LA VARIABLE V_QA_TFDDPRELIMINAR_AJ
                  -- Cargamos los registros en la colección V_QA_TFDDPRELIMINAR_AJ con ayuda de BULK COLLECT
                  SELECT Q.FDD_CODIGOEVENTO
                        ,Q.FDD_FINICIAL
                        ,Q.FDD_FFINAL
                        ,Q.FDD_CODIGOELEMENTO
                        ,Q.FDD_TIPOELEMENTO
                        ,Q.FDD_CONSUMODIA
                        ,Q.FDD_ENS_ELEMENTO
                        ,Q.FDD_ENS_EVENTO
                        ,Q.FDD_ENEG_EVENTO
                        ,Q.FDD_ENEG_ELEMENTO
                        ,Q.FDD_CODIGOGENERADOR
                        ,Q.FDD_CAUSA
                        ,Q.FDD_CAUSA_CREG
                        ,Q.FDD_USUARIOAP
                        ,Q.FDD_CONTINUIDAD
                        ,Q.FDD_ESTADOREPORTE
                        ,Q.FDD_PUBLICADO
                        ,Q.FDD_RECONFIG
                        ,Q.FDD_PERIODO_OP
                        ,Q.FDD_FREG_APERTURA
                        ,Q.FDD_FREG_CIERRE
                        ,Q.FDD_FPUB_APERTURA
                        ,Q.FDD_FPUB_CIERRE
                        ,T.TC1_PERIODO--Q.FDD_PERIODO_TC1
                        ,Q.FDD_TIPOCARGA
                        ,Q.FDD_EXCLUSION
                        ,Q.FDD_CAUSA_SSPD
                        ,Q.FDD_AJUSTADO
                        ,Q.FDD_TIPOAJUSTE
                        ,Q.FDD_RADICADO
                        ,Q.FDD_APROBADO
                        ,T.TC1_IUA
                  BULK  COLLECT INTO V_QA_TFDDPRELIMINAR_AJ
                  FROM  QA_TFDDPRELIMINAR_AJ Q
                  LEFT  OUTER JOIN (
                                    SELECT DISTINCT(TC1_CODCONEX ),TC1_PERIODO,TC1_IUA
                                      FROM QA_TTC1
                                     WHERE TC1_PERIODO=PERIODO_TC1
                                   ) T ON (
                                           T.TC1_CODCONEX = Q.FDD_CODIGOELEMENTO
                                          )
                  WHERE T.TC1_PERIODO IS NOT NULL;
    
                  IF V_QA_TFDDPRELIMINAR_AJ IS NOT EMPTY THEN
                      FORALL i IN V_QA_TFDDPRELIMINAR_AJ.FIRST .. V_QA_TFDDPRELIMINAR_AJ.LAST
                      INSERT INTO QA_TFDDPRELIMINAR_AJ
                      VALUES V_QA_TFDDPRELIMINAR_AJ(i);
                  END IF;
                  COMMIT;
    
        --BORRAR LOS REGISTROS DE ELEMENTOS QUE NO EXISTEN EN TC1 ACTUAL
                    DELETE FROM QA_TFDDPRELIMINAR_AJ WHERE FDD_IUA IS NULL;
                    COMMIT;
    
        --REASIGNAR EL CAMPO FDD_TIPOCARGA PARA LOS AGREGADOS POR AJUSTE TC1; FDD_TIPOCARGA='TR'
    
                          SELECT  T1.FDD_CODIGOEVENTO
                                 ,T1.FDD_CODIGOELEMENTO
                            BULK COLLECT INTO VAR_I
                            FROM QA_TFDDPRELIMINAR_AJ T1
                            LEFT OUTER JOIN (
                                            SELECT DISTINCT FDD_CODIGOEVENTO
                                              FROM QA_TFDDREGISTRO
                                             WHERE (
                                                        FDD_FINICIAL >= TO_DATE('01/'||TO_CHAR(FECHAOPERACION,'MM/YYYY'),'DD/MM/YYYY')
                                                    AND FDD_FINICIAL <  LAST_DAY(FECHAOPERACION) + 1
                                                   )
                                            ) T2 ON T2.FDD_CODIGOEVENTO=T1.FDD_CODIGOEVENTO
                           WHERE T2.FDD_CODIGOEVENTO IS NOT NULL;
    
                      IF VAR_I IS NOT NULL THEN
                          FORALL i IN VAR_I.FIRST .. VAR_I.LAST
                            UPDATE QA_TFDDPRELIMINAR_AJ
                               SET FDD_TIPOCARGA      = 'TR',
                                   FDD_TIPOAJUSTE     = '1'
                             WHERE FDD_CODIGOEVENTO   = VAR_I(i).FDD_CODIGOEVENTO
                               AND FDD_CODIGOELEMENTO = VAR_I(i).FDD_CODIGOELEMENTO;
                      END IF;
                      COMMIT;
             --ELMINACION DE LOS REGISTROS NR 'NO PROVENIENTES DE TC1'
                       DELETE
                         FROM QA_TFDDPRELIMINAR_AJ
                        WHERE FDD_TIPOCARGA = 'NR';
                        COMMIT;
    
            --MARCAR EL CAMPO FDD_USUARIOAP CON 'S' PARA TODOS LOS REGISTROS
    
                      SELECT DISTINCT TC1_CODCONEX
                        BULK COLLECT INTO VAR_A
                        FROM QA_TTC1 TC1
                        LEFT OUTER JOIN QA_TFDDPRELIMINAR_AJ NR ON NR.FDD_CODIGOELEMENTO =  TC1.TC1_CODCONEX
                       WHERE TC1_PERIODO=PERIODO_TC1
                         AND TC1_TC1 LIKE 'CALP%'
                         AND NR.FDD_CODIGOELEMENTO IS NOT NULL;
    
                  IF VAR_A IS NOT EMPTY THEN
                       FOR i IN VAR_A.FIRST..VAR_A.LAST LOOP
                             UPDATE BRAE.QA_TFDDPRELIMINAR_AJ SET FDD_USUARIOAP='S'
                             WHERE FDD_CODIGOELEMENTO=VAR_A(i).TC1_CODCONEX;
                       END LOOP;
                       COMMIT;
                  END IF;
    
             --AGRAGAR LOS CONSUMOS A LOS TRAFOS
    
                  SELECT DISTINCT CON.CONS_ELEMENTO,CON.CONS_DIARIO
                      BULK COLLECT INTO VAR_C
                      FROM BRAE.QA_TCONSUMOSDIA CON
                      LEFT OUTER JOIN BRAE.QA_TFDDPRELIMINAR_AJ PRE ON PRE.FDD_CODIGOELEMENTO=CON.CONS_ELEMENTO
                    WHERE CON.CONS_PERIODO = (SELECT MAX(CONS_PERIODO) FROM BRAE.QA_TCONSUMOSDIA)
                      AND PRE.FDD_CODIGOELEMENTO IS NOT NULL;
    
                IF VAR_C IS NOT EMPTY THEN
                    FOR i IN VAR_C.FIRST..VAR_C.LAST LOOP
                        UPDATE BRAE.QA_TFDDPRELIMINAR_AJ
                        SET FDD_CONSUMODIA = VAR_C(i).CONSUMO
                        WHERE FDD_CODIGOELEMENTO = VAR_C(i).ELEMENTO;
                    END LOOP;
                    COMMIT;
                END IF;
    
        -- CALCUALAR ENS_ELEMENTO
                UPDATE BRAE.QA_TFDDPRELIMINAR_AJ
                SET FDD_ENS_ELEMENTO = FDD_CONSUMODIA*(CAST(FDD_FFINAL AS DATE)-CAST(FDD_FINICIAL AS DATE));
                COMMIT;
    
    
        --COMPLETAR EL CAMPO ENS_EVENTO PARA TODOS LOS REGISTROS ALMACENADOS
    
                    SELECT FDD_CODIGOEVENTO,SUM(FDD_ENS_ELEMENTO)
                      BULK COLLECT INTO VAR_D
                      FROM BRAE.QA_TFDDPRELIMINAR_AJ
                    GROUP BY FDD_CODIGOEVENTO;
    
                IF VAR_D IS NOT EMPTY THEN
                    FOR i IN VAR_D.FIRST..VAR_D.LAST LOOP
                        UPDATE BRAE.QA_TFDDPRELIMINAR_AJ
                        SET FDD_ENS_EVENTO=VAR_D(i).FDD_ENS_EVENTO
                        WHERE FDD_CODIGOEVENTO=VAR_D(i).FDD_CODIGOEVENTO
                        AND FDD_PERIODO_OP=FECHAOPERACION;
                    END LOOP;
                    COMMIT;
                END IF;
    
            --AGREGAR LOS REGISTROS QUE HAN SIDO MODIFICADOS EN OMS
            --BULK COLLECT INTO PARA LA INFORMACION DE REGISTROS MODIFICADOS
    
                      SELECT R.FDD_CODIGOEVENTO
                            ,(CASE WHEN(MI.CAUSA='PRUEBA')
                                   THEN(R.FDD_FINICIAL)
                                   ELSE(M.FDD_FINICIAL)
                              END) AS FDD_FINICIAL
                            ,(CASE WHEN(MI.CAUSA='PRUEBA')
                                   THEN(R.FDD_FFINAL)
                                   ELSE(M.FDD_FFINAL)
                              END) AS FDD_FFINAL
                            ,R.FDD_CODIGOELEMENTO
                            ,R.FDD_TIPOELEMENTO
                            ,R.FDD_CONSUMODIA
                            ,R.FDD_ENS_ELEMENTO
                            ,R.FDD_ENS_EVENTO
                            ,R.FDD_ENEG_EVENTO
                            ,R.FDD_ENEG_ELEMENTO
                            ,R.FDD_CODIGOGENERADOR
                            ,(CASE WHEN(MI.CAUSA='PRUEBA')
                                   THEN(R.FDD_CAUSA)
                                   ELSE(MI.CAUSA)
                              END) AS FDD_CAUSA
                            ,(CASE WHEN(MI.CAUSA='PRUEBA')
                                   THEN(R.FDD_CAUSA_CREG)
                                   ELSE(NULL) --LO RECALCULA EL PL
                              END) AS FDD_CAUSA_CREG
                            ,R.FDD_USUARIOAP---FUTURAS MODIFICACIONES DE AP
                            ,(CASE WHEN (    M.FDD_FFINAL >= PERIODO_MAX_REG + 1
                                          OR M.FDD_FFINAL IS NULL)
                                   THEN 'S'
                                   ELSE 'N'
                              END) AS FDD_CONTINUIDAD
                            ,R.FDD_ESTADOREPORTE
                            ,R.FDD_PUBLICADO
                            ,R.FDD_RECONFIG
                            ,R.FDD_PERIODO_OP
                            ,R.FDD_FREG_APERTURA
                            ,R.FDD_FREG_CIERRE
                            ,R.FDD_FPUB_APERTURA
                            ,R.FDD_FPUB_CIERRE
                            ,R.FDD_PERIODO_TC1
                            ,(CASE WHEN(M.FDD_CAUSA_CREG = R.FDD_CAUSA_CREG)
                                   THEN('XR')
                                   ELSE('MR') END) AS FDD_TIPOCARGA
                            ,(CASE WHEN(MI.CAUSA='PRUEBA')
                                   THEN(R.FDD_EXCLUSION)
                                   ELSE(NULL) --LO RECALCULA EL PL
                              END) AS FDD_EXCLUSION
                            ,(CASE WHEN(MI.CAUSA='PRUEBA')
                                   THEN(R.FDD_CAUSA_SSPD)
                                   ELSE(NULL) --LO RECALCULA EL PL
                              END) AS FDD_CAUSA_SSPD
                            ,'S'   AS FDD_AJUSTADO
                            ,(CASE WHEN(MI.CAUSA='PRUEBA')
                                   THEN(3)
                                   ELSE(2)
                              END) AS FDD_TIPOAJUSTE
                            ,'*'   AS FDD_RADICADO
                            ,'N'   AS FDD_APROBADO
                            ,R.FDD_IUA
                    BULK COLLECT INTO V_QA_TFDDPRELIMINAR_AJ
                    FROM QA_TFDDREGISTRO R
                    LEFT OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE=R.FDD_CODIGOEVENTO
                    LEFT OUTER JOIN ((SELECT  I.MINICIAL AS FDD_CODIGOEVENTO,
                                             I.TRAFO AS FDD_CODIGOELEMENTO,
                                             TO_TIMESTAMP(
                                                          TO_CHAR(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')
                                                                  ||'.'
                                                                  ||LPAD(TO_CHAR(CASE WHEN (MI.FECHAMS<0)
                                                                                      THEN (0)
                                                                                      ELSE (MI.FECHAMS)
                                                                                  END)
                                                                        ,3,'0'))
                                                          ,'DD/MM/YYYY hh24:mi:ss.FF3') AS FDD_FINICIAL,
                                             (CASE WHEN I.FFINAL>=(PERIODO_MAX_REG + 1)
                                                   THEN NULL
                                                   ELSE TO_TIMESTAMP((CASE WHEN I.FFINAL IS NULL
                                                                          THEN NULL
                                                                          ELSE TO_CHAR(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss')
                                                                                      ||'.'
                                                                                      ||LPAD(TO_CHAR(CASE WHEN (MF.FECHAMS<0)
                                                                                                           THEN(0)
                                                                                                           ELSE(MF.FECHAMS)
                                                                                                       END)
                                                                                              ,3,'0'))
                                                                       END)
                                                                      ,'DD/MM/YYYY hh24:mi:ss.FF3')
                                                END) AS FDD_FFINAL,
                                             TO_NUMBER(CS.CAUSA015) AS FDD_CAUSA_CREG
                                      FROM OMS.INTERUPC I
                                      LEFT OUTER JOIN QA_TFDDREGISTRO R ON (R.FDD_CODIGOEVENTO = I.MINICIAL AND R.FDD_CODIGOELEMENTO = I.TRAFO)
                                      LEFT OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL
                                      LEFT OUTER JOIN OMS.MANIOBRAS MF ON MF.CODE = I.MFINAL
                                      LEFT OUTER JOIN OMS.CAUSAS CS ON CS.CODE = MI.CAUSA
                                      WHERE (   I.FINICIAL >= TO_DATE('01/'||TO_CHAR(FECHAOPERACION,'MM/YYYY'),'DD/MM/YYYY')
                                            AND I.FINICIAL <  LAST_DAY(FECHAOPERACION) + 1)
                                      AND R.FDD_PERIODO_TC1 IS NOT NULL)
    
                                    MINUS
    
                                    (SELECT FDD_CODIGOEVENTO,
                                            FDD_CODIGOELEMENTO,
                                            FDD_FINICIAL,
                                            FDD_FFINAL,
                                            TO_NUMBER(FDD_CAUSA_CREG)
                                    FROM BRAE.QA_TFDDREGISTRO
                                    WHERE (    FDD_FINICIAL >= TO_DATE('01/'||TO_CHAR(FECHAOPERACION,'MM/YYYY'),'DD/MM/YYYY')
                                           AND FDD_FINICIAL <  LAST_DAY(FECHAOPERACION) + 1))
    
                                    ) M ON M.FDD_CODIGOEVENTO||M.FDD_CODIGOELEMENTO=R.FDD_CODIGOEVENTO||R.FDD_CODIGOELEMENTO
                    WHERE M.FDD_CODIGOEVENTO||M.FDD_CODIGOELEMENTO IS NOT NULL;
    
                    IF V_QA_TFDDPRELIMINAR_AJ IS NOT EMPTY THEN
                      FORALL i IN V_QA_TFDDPRELIMINAR_AJ.FIRST .. V_QA_TFDDPRELIMINAR_AJ.LAST
                      INSERT INTO QA_TFDDPRELIMINAR_AJ
                      VALUES V_QA_TFDDPRELIMINAR_AJ(i);
                    END IF;
                    COMMIT;
    
            --COMPLETAR EL CAMPO DE CAUSA_CREG_015
    
    
                    SELECT CODE, CAUSA015
                    BULK COLLECT INTO VAR_B
                    FROM OMS.CAUSAS;
    
                    FOR i IN VAR_B.FIRST..VAR_B.LAST LOOP
                          UPDATE BRAE.QA_TFDDPRELIMINAR_AJ
                          SET FDD_CAUSA_CREG = VAR_B(i).CAUSA015
                          WHERE FDD_CAUSA = VAR_B(i).CAUSA_OR
                            AND FDD_TIPOAJUSTE <> 3;
                    END LOOP;
                    COMMIT;
    
    
            --COMPLETAR EL CAMPO FDD_EXCLUSION
    
                SELECT FDC_CAUSA_OMS,FDC_EXCLUSION
                BULK COLLECT INTO VAR_E
                FROM BRAE.QA_TFDDCAUSAS;
    
                FOR i IN VAR_E.FIRST..VAR_E.LAST LOOP
                    UPDATE BRAE.QA_TFDDPRELIMINAR_AJ
                    SET FDD_EXCLUSION=VAR_E(i).FDC_EXCLUSION
                    WHERE FDD_CAUSA=VAR_E(i).FDC_CAUSA_OMS
                      AND FDD_TIPOAJUSTE <> 3;
                END LOOP;
                COMMIT;
    
    
    
        --COMPLETAR EL CAMPO FDD_CAUSA_SSPD
    
                SELECT FDC_CAUSA_OMS,NVL(FDC_CAUSA_SSPD,0) AS FDC_CAUSA_SSPD
                  BULK COLLECT INTO VAR_F
                  FROM BRAE.QA_TFDDCAUSAS
                 WHERE FDC_CAUSA_OMS IN (SELECT DISTINCT FDD_CAUSA FROM QA_TFDDPRELIMINAR_AJ);
    
                IF VAR_F IS NOT EMPTY THEN
                    FOR i IN VAR_F.FIRST..VAR_F.LAST LOOP
                            UPDATE BRAE.QA_TFDDPRELIMINAR_AJ
                            SET FDD_CAUSA_SSPD =
                                    (CASE
                                        WHEN (  (  TO_DATE (
                                                      TO_CHAR (FDD_FFINAL, 'DD/MM/YYYY hh24:mi:ss'),
                                                      'DD/MM/YYYY hh24:mi:ss')
                                                - TO_DATE (
                                                      TO_CHAR (FDD_FINICIAL, 'DD/MM/YYYY hh24:mi:ss'),
                                                      'DD/MM/YYYY hh24:mi:ss'))
                                              * 24) <= 0.05
                                        THEN
                                          1
                                        ELSE
                                          NVL (VAR_F(i).FDC_CAUSA_SSPD, 0)
                                    END)
                          WHERE FDD_CAUSA = VAR_F(i).FDC_CAUSA_OMS
                            AND FDD_TIPOAJUSTE <> 3;
                  END LOOP;
                  COMMIT;
                END IF;
    
    
         -- VERIFICAR CAUSAS_SSPD ASIGNADAS CON EL VALOR DIFERENTE DE '1'
    
                        SELECT I.MINICIAL,
                                I.FINICIAL,
                                I.FFINAL,
                                I.TRAFO
                        BULK COLLECT INTO VAR_G
                        FROM OMS.INTERUPC I
                        WHERE I.FINICIAL >= TO_DATE(TO_CHAR(TRUNC(FECHAOPERACION)+(23.95/24),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
                        AND I.FINICIAL < TRUNC (FECHAOPERACION+1)
                        AND I.FFINAL IS NOT NULL
                        AND ((I.FFINAL-I.FINICIAL)*24)<=0.05;
    
                IF VAR_G IS NOT EMPTY THEN
                        FOR i IN VAR_G.FIRST..VAR_G.LAST LOOP
                                SELECT FDD_CODIGOEVENTO,
                                      FDD_FINICIAL,
                                      FDD_FFINAL,
                                      FDD_CODIGOELEMENTO
                                BULK COLLECT INTO VAR_H
                                FROM BRAE.QA_TFDDPRELIMINAR_AJ;
    
                                      FOR j IN VAR_H.FIRST .. VAR_H.LAST LOOP
    
                                      IF (VAR_G(i).FDD_CODIGOEVENTO=VAR_H(j).FDD_CODIGOEVENTO AND
                                          VAR_G(i).FDD_CODIGOELEMENTO=VAR_H(j).FDD_CODIGOELEMENTO) THEN
                                        -- CAMBIAR CAUSA_SSPD A 1 DE LA TABLA QA_TFDDPRELIMINAR_AJ
                                        UPDATE BRAE.QA_TFDDPRELIMINAR_AJ
                                          SET FDD_CAUSA_SSPD=1
                                        WHERE FDD_CODIGOEVENTO   = VAR_G(i).FDD_CODIGOEVENTO
                                          AND FDD_CODIGOELEMENTO = VAR_G(i).FDD_CODIGOELEMENTO
                                          AND FDD_TIPOAJUSTE<>3;
                                      END IF;
    
                                    END LOOP;
                          END LOOP;
                          COMMIT;
                END IF;
    
    
          --INSERCION DE LOS REGISTROS AJUSTADOS POR TC1 TIPOAJUSTE=3
                                  SELECT T1.FDD_CODIGOEVENTO
                                        ,T1.FDD_FINICIAL
                                        ,T1.FDD_FFINAL
                                        ,T1.FDD_CODIGOELEMENTO
                                        ,T1.FDD_TIPOELEMENTO
                                        ,T1.FDD_CONSUMODIA
                                        ,T1.FDD_ENS_ELEMENTO
                                        ,T1.FDD_ENS_EVENTO
                                        ,T1.FDD_ENEG_EVENTO
                                        ,T1.FDD_ENEG_ELEMENTO
                                        ,T1.FDD_CODIGOGENERADOR
                                        ,T1.FDD_CAUSA
                                        ,T1.FDD_CAUSA_CREG
                                        ,T1.FDD_USUARIOAP
                                        ,T1.FDD_CONTINUIDAD
                                        ,T1.FDD_ESTADOREPORTE
                                        ,T1.FDD_PUBLICADO
                                        ,T1.FDD_RECONFIG
                                        ,T1.FDD_PERIODO_OP
                                        ,T1.FDD_FREG_APERTURA
                                        ,T1.FDD_FREG_CIERRE
                                        ,T1.FDD_FPUB_APERTURA
                                        ,T1.FDD_FPUB_CIERRE
                                        ,T1.FDD_PERIODO_TC1
                                        ,'TR' AS FDD_TIPOCARGA
                                        ,T1.FDD_EXCLUSION
                                        ,T1.FDD_CAUSA_SSPD
                                        ,'N' AS FDD_AJUSTADO
                                        ,3   AS FDD_TIPOAJUSTE
                                        ,'*' AS FDD_RADICADO
                                        ,'N' AS FDD_APROBADO
                                        ,T1.FDD_IUA
                  BULK COLLECT INTO V_QA_TFDDPRELIMINAR_AJ
                  FROM QA_TFDDREGISTRO T1
                  LEFT OUTER JOIN (SELECT DISTINCT FDD_CODIGOELEMENTO
                                   FROM QA_TFDDREGISTRO
                                   LEFT OUTER JOIN (SELECT DISTINCT TC1_CODCONEX,TC1_PERIODO
                                                    FROM QA_TTC1
                                                    WHERE TC1_PERIODO=PERIODO_TC1
                                                    )ON TC1_CODCONEX=FDD_CODIGOELEMENTO
                                   WHERE (   FDD_FINICIAL >= TRUNC(FECHAOPERACION)
                                         AND FDD_FINICIAL <  LAST_DAY(FECHAOPERACION) + 1)
                                   AND TC1_PERIODO IS NULL
                                   )T2 ON T2.FDD_CODIGOELEMENTO=T1.FDD_CODIGOELEMENTO
                  WHERE (    T1.FDD_FINICIAL >= TRUNC(FECHAOPERACION)
                         AND T1.FDD_FINICIAL <  LAST_DAY(FECHAOPERACION) + 1)
                  AND T2.FDD_CODIGOELEMENTO IS NOT NULL;
    
                  IF V_QA_TFDDPRELIMINAR_AJ IS NOT EMPTY THEN
                      FORALL i IN V_QA_TFDDPRELIMINAR_AJ.FIRST .. V_QA_TFDDPRELIMINAR_AJ.LAST
                        INSERT INTO QA_TFDDPRELIMINAR_AJ
                        VALUES V_QA_TFDDPRELIMINAR_AJ(i);
                      COMMIT;
                  END IF;
    
    
    -----------------------------------------------------------------------RESOLUCION DE COINCIDENCIAS ENTRES BLOQUES----------------------------------------------------
    
    
              --01--RESOLUCION DE POSIBLES COINCIDENCIAS ENTRE CASO 1 - CASO 2
                --CASO 1: EVENTOS NR  (Modificar Eventos), FDD_TIPOAJUSTE=2
                --CASO 2: AJUSTE TC1  (Agregar   Eventos), FDD_TIPOAJUSTE=1
                  /*Todos los registros agragados por ajuste TC1 inicialmente son tipo NR, que consiguiente a la ejecucion
                  del procedimiento son convertidos en tipo de ajustes TC1 al comprobar que dentro de la tabla de registro
                  ya existen eventos reportados con el mismo codigo de evento con el que intenta ingresar al sistema,es decir
                  que en el momento de haber coincidencias este es resuelto por codigo al convertirlo en registros ajuste TC1
                  (Agregar), FDD_TIPOAJUSTE=1, y si por el contrario los registros NR son tomados de la tabla QA_TFDDREGISTRO
                  y son expuestos en este recopilado de registros, entonces si pueden haber eventos con registros NR y al mismo
                  tiempo algunos de sus registros activados por actualizacion de TC1 sean agregados, en este sentido se deben
                  dejar los dos tipos de registros ya que estos no duplican*/
                  --CODE N/A
    
    
              --02--RESOLUCION DEL CASO 1 - CASO 3
                --CASO 1: EVENTOS XR  (Modificar Eventos), FDD_TIPOAJUSTE=2
                --CASO 3: EVENTOS TR  (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                  /*Si los eventos-registros NR son tomados de la tabla QA_TFDDREGISTRO estos podrian ser al mismo tiempo
                  objeto de eliminacion de algunos de sus registros (transformadores) por causa de actualizacion en el
                  formato TC1, Para esta coincidencia se excluyen los registros cargados mediante el INSERT que trae los
                  Registros NR de la tabla QA_TFDDREGISTRO, De manera que no dupliquen, permitiendo asi la elminacion en
                  el formato de ajustes de registros que en su reporte se encuentran con intervalos de tiempos temporales*/
    
                  SELECT DISTINCT T1.FDD_CODIGOEVENTO,T1.FDD_CODIGOELEMENTO
                  BULK   COLLECT INTO VAR_I
                  FROM   QA_TFDDPRELIMINAR_AJ T1
                  LEFT   OUTER JOIN (SELECT DISTINCT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO
                                    FROM   QA_TFDDPRELIMINAR_AJ
                                    WHERE  FDD_TIPOCARGA  = 'TR'
                                    AND    FDD_TIPOAJUSTE = 3
                                    ) T2
                                    ON T2.FDD_CODIGOEVENTO||T2.FDD_CODIGOELEMENTO
                                    =  T1.FDD_CODIGOEVENTO||T1.FDD_CODIGOELEMENTO
                  WHERE T1.FDD_TIPOCARGA     = 'XR'
                  AND   T1.FDD_TIPOAJUSTE    = 2
                  AND   T2.FDD_CODIGOELEMENTO IS NOT NULL;
    
                  IF VAR_I IS NOT EMPTY THEN
                    FOR i IN VAR_I.FIRST .. VAR_I.LAST LOOP
                      DELETE FROM QA_TFDDPRELIMINAR_AJ
                      WHERE  FDD_CODIGOEVENTO   = VAR_I(i).FDD_CODIGOEVENTO
                      AND    FDD_CODIGOELEMENTO = VAR_I(i).FDD_CODIGOELEMENTO
                      AND    FDD_TIPOCARGA      = 'XR'
                      AND    FDD_TIPOAJUSTE     = 2;
                    END LOOP;
                  END IF;
                  COMMIT;
    
    
              --03--RESOLUCION DEL CASO 1 - CASO 4
                --CASO 1: EVENTOS XR  (Modificar Eventos), FDD_TIPOAJUSTE=2
                --CASO 4: EVENTOS MR  (Modificar Eventos), FDD_TIPOAJUSTE=2
                /*Los eventos traidos de la tabla QA_TFDDREGISTRO con la etiqueta NR pueden sufrir modificaciones
                adicionales por lo que pertenecerian a dos grupos de registros, al bloque de regsitros MOD y al--
                bloque de registros NR, por lo que se hace necesario eliminar o excluir los  regsitros del bloque
                NR dejando asi, solamente a los que pertenecen a los registros MOD, debido a que estos contienen-
                la informacion original del registro NR y la modificacion adicional.*/
    
                SELECT DISTINCT T1.FDD_CODIGOEVENTO,T1.FDD_CODIGOELEMENTO
                BULK   COLLECT INTO VAR_I
                FROM   QA_TFDDPRELIMINAR_AJ T1
                LEFT   OUTER JOIN (  SELECT DISTINCT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO
                                     FROM   QA_TFDDPRELIMINAR_AJ
                                     WHERE  FDD_TIPOCARGA  = 'MR'
                                     AND    FDD_TIPOAJUSTE = 2
                                   ) T2
                                  ON T2.FDD_CODIGOEVENTO||T2.FDD_CODIGOELEMENTO
                                  =  T1.FDD_CODIGOEVENTO||T1.FDD_CODIGOELEMENTO
                WHERE  T1.FDD_TIPOCARGA     = 'XR'
                AND    T1.FDD_TIPOAJUSTE    =  2
                AND    T2.FDD_CODIGOELEMENTO IS NOT NULL;
    
                IF VAR_I IS NOT EMPTY THEN
                  FOR i IN VAR_I.FIRST .. VAR_I.LAST LOOP
                    DELETE FROM QA_TFDDPRELIMINAR_AJ
                    WHERE FDD_CODIGOEVENTO   = VAR_I(i).FDD_CODIGOEVENTO
                    AND   FDD_CODIGOELEMENTO = VAR_I(i).FDD_CODIGOELEMENTO
                    AND   FDD_TIPOCARGA  = 'XR'
                    AND   FDD_TIPOAJUSTE =  2;
                  END LOOP;
                END IF;
                COMMIT;
    
              --04--RESOLUCION DEL CASO 1 - CASO 5
                --CASO 1: EVENTOS XR  (Modificar Eventos), FDD_TIPOAJUSTE=2
                --CASO 5: EVENTOS MR  (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                /*Los eventos traidos de la tabla QA_TFDDREGISTRO con la etiqueta NR pueden sufrir modificaciones
                adicionales por lo que pertenecerian a dos grupos de registros, al bloque de regsitros MOD y al--
                bloque de registros NR, por lo que se hace necesario eliminar o excluir los  regsitros del bloque
                NR dejando asi, solamente a los que pertenecen a los registros MOD, debido a que estos contienen-
                la informacion original del registro NR y la modificacion adicional.*/
    
                SELECT DISTINCT T1.FDD_CODIGOEVENTO,T1.FDD_CODIGOELEMENTO
                BULK   COLLECT INTO VAR_I
                FROM   QA_TFDDPRELIMINAR_AJ T1
                LEFT   OUTER JOIN (  SELECT DISTINCT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO
                                     FROM   QA_TFDDPRELIMINAR_AJ
                                     WHERE  FDD_TIPOCARGA  = 'MR'
                                     AND    FDD_TIPOAJUSTE =  3
                                   ) T2
                                  ON T2.FDD_CODIGOEVENTO||T2.FDD_CODIGOELEMENTO
                                  =  T1.FDD_CODIGOEVENTO||T1.FDD_CODIGOELEMENTO
                WHERE  T1.FDD_TIPOCARGA     = 'XR'
                AND    T1.FDD_TIPOAJUSTE    =  2
                AND    T2.FDD_CODIGOELEMENTO IS NOT NULL;
    
                IF VAR_I IS NOT EMPTY THEN
                  FOR i IN VAR_I.FIRST .. VAR_I.LAST LOOP
                    DELETE FROM QA_TFDDPRELIMINAR_AJ
                    WHERE FDD_CODIGOEVENTO   = VAR_I(i).FDD_CODIGOEVENTO
                    AND   FDD_CODIGOELEMENTO = VAR_I(i).FDD_CODIGOELEMENTO
                    AND   FDD_TIPOCARGA  = 'XR'
                    AND   FDD_TIPOAJUSTE =  2;
                  END LOOP;
                END IF;
                COMMIT;
    
    
              --05--RESOLUCION DEL CASO 2 - CASO 3
                --CASO 2: AJUSTE TR  (Agregar   Eventos), FDD_TIPOAJUSTE=1
                --CASO 3: AJUSTE TR  (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                /*Por cada actualizacion del formato TC1, este genera la eliminacion y el agreagdo de algunos----
                registros pertenecientes a eventos reportados, por lo que no es posible que ocurra una coinciden-
                cia entre estos dos casos debido a que son totalmente excluyentes*/
                --CODE N/A
    
    
              --06--RESOLUCION DEL CASO 2 - CASO 4
                --CASO 2: AJUSTE TR  (Agregar   Eventos), FDD_TIPOAJUSTE=1
                --CASO 4: EVENTOS MR (Modificar Eventos), FDD_TIPOAJUSTE=2
                /*Un evento puede tener varios registros que entren por el proceso de NR y en la ejecucion del PL
                estos se conviertan en registros de ajustes TC1 (agregar)  y al mismo tiempo estos  eventos  sean
                objetos de modificaciones, en este caso los registros que apenas ingrensan no pueden ser al mismo
                tiempo  modificados  debido  a  que  anteriormente no habian sido registrados, la informacion que
                contengan los registros-de-eventos nuevos ingresados por ajustes TC1 deberan traer la informacion
                tal cual como se  esta modificando en los eventos MOD, en conclusion se deben dejar los dos tipos
                de registros ya que estos no duplican*/
                --CODE N/A
    
    
              --07--RESOLUCION DEL CASO 2 - CASO 5
                --CASO 2: AJUSTE TC1  (Agregar   Eventos), FDD_TIPOAJUSTE=1
                --CASO 5: EVENTOS MR (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                /*Un evento puede tener varios registros que entren por el proceso de NR y en la ejecucion del PL
                estos se conviertan en registros de ajustes TC1 (agregar)  y al mismo tiempo estos  eventos  sean
                objetos de modificaciones, en este caso los registros que apenas ingrensan no pueden ser al mismo
                tiempo  modificados  debido  a  que  anteriormente no habian sido registrados, la informacion que
                contengan los registros-de-eventos nuevos ingresados por ajustes TC1 deberan traer la informacion
                tal cual como se  esta modificando en los eventos MOD, en conclusion se deben eliminar los regist
                ros de AJUSTE TC1*/
    
    
                DELETE FROM QA_TFDDPRELIMINAR_AJ
                WHERE  FDD_TIPOCARGA  = 'TR'
                AND    FDD_CAUSA_CREG = '0';
                COMMIT;
    
    
              --08--RESOLUCION DEL CASO 3 - CASO 4
                --CASO 3: AJUSTE TC1  (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                --CASO 4: EVENTOS MR (Modificar Eventos), FDD_TIPOAJUSTE=2
                /*Si pueden haber coincidencias en estos dos casos, debido a que algunos registro de eliminacion por ajuste
                TC1 pueden pertenecer a eventos que son objeto de modificacion (registro MOD), En este caso siempre se ----
                eliminaran de esta vista los registros duplicados pertencientes a los registros (MOD) y nunca eliminar los
                pertencientes a registro de eliminacion por ajuste TC1, es decir, que es posible que a un evento se le-----
                modifiquen las caracteristicas cuando al mismo tiempo se eliminan algunos registros en el procedimiento de
                ajustes*/
    
                SELECT DISTINCT T1.FDD_CODIGOEVENTO,T1.FDD_CODIGOELEMENTO
                BULK   COLLECT INTO VAR_I
                FROM   QA_TFDDPRELIMINAR_AJ T1
                LEFT   OUTER JOIN (  SELECT DISTINCT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO
                                     FROM   QA_TFDDPRELIMINAR_AJ
                                     WHERE  FDD_TIPOCARGA  = 'MR'
                                     AND    FDD_TIPOAJUSTE =  2
                                   ) T2
                                  ON T2.FDD_CODIGOEVENTO||T2.FDD_CODIGOELEMENTO
                                  =  T1.FDD_CODIGOEVENTO||T1.FDD_CODIGOELEMENTO
                WHERE  T1.FDD_TIPOCARGA     = 'TR'
                AND    T1.FDD_TIPOAJUSTE    =  3
                AND    T2.FDD_CODIGOELEMENTO IS NOT NULL;
    
                IF VAR_I IS NOT EMPTY THEN
                  FOR i IN VAR_I.FIRST .. VAR_I.LAST LOOP
                    DELETE FROM QA_TFDDPRELIMINAR_AJ
                    WHERE FDD_CODIGOEVENTO   = VAR_I(i).FDD_CODIGOEVENTO
                    AND   FDD_CODIGOELEMENTO = VAR_I(i).FDD_CODIGOELEMENTO
                    AND   FDD_TIPOCARGA  = 'MR'
                    AND   FDD_TIPOAJUSTE =  2;
                  END LOOP;
                END IF;
                COMMIT;
    
    
              --09--RESOLUCION DEL CASO 3 - CASO 5
                --CASO 3: AJUSTE TC1  (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                --CASO 5: EVENTOS MR (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                /*Si puede existir coincidencia en estos dos casos pero siempre eliminar los pertenecientes aL bloque de los re
                gistros (AJUSTE TC1 DEL), es decir debido a que los registros de modificacion eliminan o pasan a prueba eventos
                completos, este abarcaria tambien intrisicamente los de eliminacion por ajsute TC1*/
    
                SELECT DISTINCT T1.FDD_CODIGOEVENTO,T1.FDD_CODIGOELEMENTO
                BULK   COLLECT INTO VAR_I
                FROM   QA_TFDDPRELIMINAR_AJ T1
                LEFT   OUTER JOIN (  SELECT DISTINCT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO
                                     FROM   QA_TFDDPRELIMINAR_AJ
                                     WHERE  FDD_TIPOCARGA  = 'MR'
                                     AND    FDD_TIPOAJUSTE =  3
                                   ) T2
                                  ON T2.FDD_CODIGOEVENTO||T2.FDD_CODIGOELEMENTO
                                  =  T1.FDD_CODIGOEVENTO||T1.FDD_CODIGOELEMENTO
                WHERE  T1.FDD_TIPOCARGA     = 'TR'
                AND    T1.FDD_TIPOAJUSTE    =  3
                AND    T2.FDD_CODIGOELEMENTO IS NOT NULL;
    
                IF VAR_I IS NOT EMPTY THEN
                  FOR i IN VAR_I.FIRST .. VAR_I.LAST LOOP
                    DELETE FROM QA_TFDDPRELIMINAR_AJ
                    WHERE FDD_CODIGOEVENTO   = VAR_I(i).FDD_CODIGOEVENTO
                    AND   FDD_CODIGOELEMENTO = VAR_I(i).FDD_CODIGOELEMENTO
                    AND   FDD_TIPOCARGA  = 'TR'
                    AND   FDD_TIPOAJUSTE =  3;
                  END LOOP;
                END IF;
                COMMIT;
                
              --10--RESOLUCION DEL CASO 4 - CASO 5
                --CASO 4: EVENTOS MOD (Modificar Eventos), FDD_TIPOAJUSTE=2
                --CASO 5: EVENTOS MOD (Eliminar  Eventos), FDD_TIPOAJUSTE=3
                /*Los dos casos presentados en este proceso es un cambio en el valor de la causa u otra modificacion---
                del evento, con el cual se permite tomar una clasificacion de esas modificaciones como una eliminacion-
                de eventos, esto hace que estos dos caso sean excluyentes y no existe manera que dupliquen entre si*/
                --CODE N/A
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('NO EXISTE TC1');
    END IF;


END QA_PFDDPRELIMINAR_AJ;


