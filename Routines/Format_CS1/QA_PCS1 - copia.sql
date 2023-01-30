CREATE OR REPLACE PROCEDURE BRAE.QA_PCS1(FECHAOPERACION DATE)
AS

 TYPE T_CS1 IS TABLE OF QA_TCS1%ROWTYPE;
 V_CS1 T_CS1;
 V_UIXTI_M NUMBER;
 V_UI_M NUMBER;
 V_UT_M NUMBER;
 V_SAIDI NUMBER;
 V_SAIFI NUMBER;
 V_SAIDI_MAT NUMBER;
 V_SAIFI_MAT NUMBER;
 V_UI_C1 NUMBER;
 V_MAIFI NUMBER;
 V_MAIFI_MAT NUMBER;


 BEGIN

  -- ASIGNAR VALOR A UIXTI_M Y UI_M -- Usuarios*transformador del mes,
    SELECT SUM(TX.CSX_DIUM*UTR.USER_TRAFO) AS UIXTI_M, SUM(TX.CSX_FIUM*UTR.USER_TRAFO) AS UI_M, SUM(TX.CSX_FRECUENCIA_C1*UTR.USER_TRAFO) AS UI_C1
    INTO V_UIXTI_M, V_UI_M, V_UI_C1
    FROM QA_TCSX TX
    LEFT OUTER JOIN (SELECT TC1_CODCONEX, COUNT(TC1_TC1) AS USER_TRAFO
                    FROM QA_TTC1
                    WHERE TC1_TIPCONEX='T'
                    AND TC1_PERIODO= TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'))
                    GROUP BY TC1_CODCONEX) UTR
    ON UTR.TC1_CODCONEX=TX.CSX_TRANSFOR
    WHERE TX.CSX_PERIODO_OP=TRUNC(FECHAOPERACION)
    GROUP BY TX.CSX_PERIODO_OP;

  --ASIGNAR VALOR A UT_M - Usuarios Totales del Mes
    SELECT COUNT(TC1_TC1) AS USUARIOS_TR
    INTO V_UT_M
    FROM QA_TTC1
    WHERE TC1_PERIODO= TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'))
    AND TC1_TIPCONEX='T'
    GROUP BY TC1_PERIODO;

 --INSERTAR PERIODO OPERACION

    INSERT INTO QA_TCS1 (CS1_PERIODO_OP,CS1_IDMERCADO,CS1_UIXTI_M,CS1_UI_M,CS1_UT_M)
                                                       VALUES(
                                                              TRUNC(FECHAOPERACION)
                                                              ,'161'
                                                              ,V_UIXTI_M
                                                              ,V_UI_M
                                                              ,V_UT_M
                                                       );


 -- ACTUALIZAR CAMPOS INDICADORES DE CALIDAD MEDIA PARA EL MES
   UPDATE BRAE.QA_TCS1
   SET CS1_SAIDI_M=(V_UIXTI_M/V_UT_M),
       CS1_SAIFI_M=(V_UI_M/V_UT_M)
   WHERE CS1_PERIODO_OP=TRUNC(FECHAOPERACION);

 -- ACTUALIZAR INDICADORES DE CALIDAD MEDIA
 -- ACTUALIZAR INDICADORES SAIDI Y SAIFI DEL AÑO EN CURSO
  SELECT SUM(CS1_SAIDI_M), SUM(CS1_SAIFI_M)
        INTO V_SAIDI, V_SAIFI
        FROM QA_TCS1
        WHERE TO_NUMBER(TO_CHAR(TRUNC(CS1_PERIODO_OP),'YYYY')) = TO_NUMBER(TO_CHAR(TRUNC(FECHAOPERACION),'YYYY'));

    UPDATE BRAE.QA_TCS1
    SET CS1_SAIDI=V_SAIDI,
        CS1_SAIFI=V_SAIFI
    WHERE CS1_PERIODO_OP=TRUNC(FECHAOPERACION);

 -- ACTUALIZAR INDICADORES SAIDI Y SAIFI DEL AÑO CORRIDO MAT
 SELECT SUM(CS1_SAIDI_M), SUM(CS1_SAIFI_M)
        INTO V_SAIDI_MAT, V_SAIFI_MAT
        FROM QA_TCS1
        WHERE CS1_PERIODO_OP IN (TRUNC(FECHAOPERACION),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-11));

    UPDATE BRAE.QA_TCS1
    SET CS1_SAIDI_MAT=V_SAIDI_MAT,
        CS1_SAIFI_MAT=V_SAIFI_MAT
    WHERE CS1_PERIODO_OP=TRUNC(FECHAOPERACION);

 -- ACTUALIZAR MAIFI PARA EL MES, ACUMULADO AÑO Y MAT
 -- MAIFI MES
   UPDATE BRAE.QA_TCS1
   SET CS1_MAIFI_M=(V_UI_C1/V_UT_M)
   WHERE CS1_PERIODO_OP=TRUNC(FECHAOPERACION);
 -- MAIFI_AÑO
 SELECT SUM(CS1_MAIFI_M)
        INTO V_MAIFI
        FROM QA_TCS1
        WHERE TO_NUMBER(TO_CHAR(TRUNC(CS1_PERIODO_OP),'YYYY')) = TO_NUMBER(TO_CHAR(TRUNC(FECHAOPERACION),'YYYY'));
 UPDATE BRAE.QA_TCS1
    SET CS1_MAIFI=V_MAIFI
    WHERE CS1_PERIODO_OP=TRUNC(FECHAOPERACION);
 --MAIFI_MAT
  SELECT SUM(CS1_MAIFI_M)
        INTO V_MAIFI_MAT
        FROM QA_TCS1
        WHERE CS1_PERIODO_OP IN (TRUNC(FECHAOPERACION),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
                                ADD_MONTHS(TRUNC(FECHAOPERACION),-11));
  UPDATE BRAE.QA_TCS1
    SET CS1_MAIFI_MAT=V_MAIFI_MAT
    WHERE CS1_PERIODO_OP=TRUNC(FECHAOPERACION);

 -- ACTUALIZAR CAIDI PARA EL MES Y ACUMULADO
   UPDATE BRAE.QA_TCS1
   SET CS1_CAIDI_M=(V_UIXTI_M/V_UI_M),
       CS1_CAIDI=(V_SAIDI/V_SAIFI)
   WHERE CS1_PERIODO_OP=TRUNC(FECHAOPERACION);
  COMMIT;
END QA_PCS1;