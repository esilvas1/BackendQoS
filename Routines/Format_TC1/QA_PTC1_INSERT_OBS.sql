CREATE OR REPLACE PROCEDURE BRAE.QA_PTC1_INSERT_OBS(FECHAOPERACION IN  DATE, USR IN VARCHAR2, ESTADO OUT NUMBER, MESSAGE OUT VARCHAR2)
AS

QUANTITY_1 NUMBER;
ID_COMER NUMBER;

BEGIN

	--Verificar duplicidad de usuario
	SELECT TC1_IDCOMER INTO ID_COMER
	FROM   QA_TTC1_OBS
	WHERE  TC1_PERIODO = TO_CHAR(FECHAOPERACION,'YYYYMM')
	AND    TC1_TC1 = USR
	;

	SELECT COUNT(DISTINCT TC1_TC1) AS QUANTITY
	INTO QUANTITY_1
	FROM QA_TTC1_TEMP 
	WHERE TC1_TC1 = USR
	AND   TC1_IDCOMER = ID_COMER
	AND   TC1_PERIODO = TO_CHAR(FECHAOPERACION,'YYYYMM')
	;

	SELECT COUNT(TC1_TC1) AS QUANTITY
	INTO QUANTITY_2
	FROM QA_TTC1_TEMP 
	WHERE TC1_TC1 = USR
	AND   TC1_PERIODO = TO_CHAR(FECHAOPERACION,'YYYYMM')
	;

	IF (QUANTITY_1 = 0 AND QUANTITY_2 < 2) THEN
		--ADD IT
	  INSERT INTO QA_TTC1_TEMP
	  SELECT TC1_TC1 --Verificar duplicidad de usuario
			,TC1_CODCONEX --Verificar
			,TC1_TIPCONEX --Verificar
			,TC1_NT
			,TC1_NTP
			,TC1_PROPACTIV
			,TC1_CONEXRED 
			,TC1_IDCOMER --Verificar duplicidad de usuario
			,TC1_IDMERC --Asignar
			,TC1_GC --Asignar
			,TC1_CODFRONCOM
			,TC1_CODCIRC --Asignar
			,TC1_CODTRANSF --Asignar
			,TC1_CODDANE --Verificar
			,TC1_UBIC
			,TC1_DIREC
			,TC1_CONESP
			,TC1_CODARESP
			,TC1_TIPARESP
			,TC1_ESTSECT
			,TC1_ALTITUD --Formatear
			,TC1_LONGITUD --Formatear
			,TC1_LATITUD --Formatear
			,TC1_AUTOGEN
			,TC1_EXPENER
			,TC1_CAPAUTOGENR
			,TC1_TIPGENR
			,TC1_CODFRONEXP
			,TC1_FENTGEN
			,TC1_CONTRESP
			,TC1_CAPCONTRESP
			,NULL TC1_PERIODO --Asignar
			,NULL TC1_IUA --Asignar 
		FROM  QA_TTC1_OBS 
		WHERE TC1_PERIODO = TO_CHAR(FECHAOPERACION,'YYYYMM')
		AND   TC1_TC1 = USR;
		COMMIT;

	ELSE
		--DO NOT ADD IT
		MESSAGE := 'El usuario que intenta agregar ya existe en la tabla temporal TC1';
	END IF;

	

	--Verificar TC1_CODCONEX
	--Verificar TC1_TIPCONEX
	--Asignar 	TC1_IDCOMER
	--Asignar 	TC1_CODTRANSF
	--Verficar 	TC1_CODDANE
	--Formatear TC1_ALTITUD
	--Formatear TC1_LONGITUD
	--Formatear TC1_LATITUD
	--Asignar 	TC1_IUA
	--Asignar 	TC1_PERIODO

	--Eliminar el usuario de la tabla observaciones, luego de verificar que todo ha sido exitoso
	DELETE FROM QA_TTC1_OBS 
	WHERE TC1_PERIODO = TO_CHAR(FECHAOPERACION,'YYYYMM')
	AND   TC1_TC1 = USR;
	COMMIT;

END QA_PTC1_INSERT_OBS;


