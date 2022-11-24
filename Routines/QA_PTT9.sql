CREATE OR REPLACE PROCEDURE BRAE.QA_PTT9(FECHAOPERACION  DATE)
AS

	TYPE T_QA_TTT9 IS TABLE OF QA_TTT9%ROWTYPE;
    V_QA_TTT9 T_QA_TTT9;
    
    AJUSTADO NUMBER;
BEGIN

 --VERIFICACION DE ACCION DE AJUSTES REALIZADOS EN LA BASE DE DATOS PARA EL PERIODO 
  SELECT COUNT(DISTINCT FDD_AJUSTADO) AS AJUSTADO
  INTO AJUSTADO
  FROM BRAE.QA_TFDDREGISTRO
  WHERE TRUNC(FDD_FINICIAL,'MM') = TRUNC(FECHAOPERACION)
  AND   FDD_AJUSTADO = 'S'
  ;


  IF  AJUSTADO = 0 THEN
  --Ejecuta el procedimeinto

     --ELIMINAR POSIBLES REGISTROS ESCRITOS DEL MISMO PERIODO
       DELETE
       FROM QA_TTT9
       WHERE TT9_PERIODO_OP=TRUNC(FECHAOPERACION);
       COMMIT;

     --INSERTAR REGISTROS EN LA TABLA QA_TFDDREPORTE_AJ
			SELECT 161 AS TT9_CODIGOMERCADO
			      ,TO_NUMBER(AJS.FDD_CODIGOEVENTO) AS TT9_CODIGOEVENTO
			      ,(
			       CASE WHEN(   AJS.FDD_TIPOCARGA='MR'
			                 OR AJS.FDD_TIPOCARGA='XR') THEN(REG.FDD_FINICIAL)
			             WHEN(  AJS.FDD_TIPOCARGA='TR') THEN(AJS.FDD_FINICIAL)
			       END
			       ) AS TT9_FINICIAL
			      ,AJS.FDD_IUA AS TT9_CODIGOELEMENTO
			      ,1 AS TT9_TIPOELEMENTO
			      ,AJS.FDD_TIPOAJUSTE AS TT9_TIPOAJUSTE
			      ,TRUNC(FECHAOPERACION) AS TT9_PERIODO_OP
			BULK COLLECT INTO V_QA_TTT9
			FROM QA_TFDDPRELIMINAR_AJ AJS
			LEFT OUTER JOIN QA_TFDDREGISTRO REG ON (REG.FDD_CODIGOEVENTO||REG.FDD_CODIGOELEMENTO
			                                      = AJS.FDD_CODIGOEVENTO||AJS.FDD_CODIGOELEMENTO);

      IF V_QA_TTT9 IS NOT EMPTY THEN
         FORALL i IN V_QA_TTT9.FIRST .. V_QA_TTT9.LAST
            INSERT INTO QA_TTT9
            VALUES V_QA_TTT9(i);
      END IF;
      COMMIT;
    DBMS_OUTPUT.PUT_LINE('EJECUTADO EXITOSAMENTE');  
  ELSE 
    DBMS_OUTPUT.PUT_LINE('NO EJECUTADO');
  END IF;---IF DE EJECUCION

END QA_PTT9;


