 
 SET SERVEROUTPUT ON;
  
 DECLARE

    CODIGOELEMENTO BRAE.QA_TTT2_REGISTRO.TT2_CODIGOELEMENTO%TYPE;
        
 BEGIN
 
     SELECT TT2_CODIGOELEMENTO
     INTO CODIGOELEMENTO
     FROM QA_TTT2_REGISTRO
     WHERE TT2_CODIGOELEMENTO LIKE 'XT%';
     
     DBMS_OUTPUT.PUT_LINE(CODIGOELEMENTO);
    
 END;

 /
 
/**************************************************************************/
SET SERVEROUTPUT ON;

DECLARE

    CURSOR CUR IS 
    SELECT * FROM QA_TTT2_REGISTRO
    WHERE TT2_CODE_CALP<>'0';
    
    i CUR%ROWTYPE;

BEGIN
    FOR i IN CUR LOOP
        DBMS_OUTPUT.PUT_LINE(i.TT2_CODIGOELEMENTO||'-'||i.TT2_CODE_IUA);
    END LOOP;
END;
/

 
/*****************************************************************************************/
SET SERVEROUTPUT ON;

DECLARE
    CURSOR QA_CTT2_REGISTRO IS
    SELECT * FROM QA_TTT2_REGISTRO;
    
    i QA_CTT2_REGISTRO%ROWTYPE;
    
BEGIN
    FOR i IN QA_CTT2_REGISTRO LOOP
        DBMS_OUTPUT.PUT_LINE(i.TT2_UNIDAD_CONSTRUCTIVA);
    END LOOP;
END;
 
 /
/********************************************************************************************/

SET SERVEROUTPUT ON;

DECLARE
    CURSOR QA_CTT2_REGISTRO IS
    SELECT * FROM QA_TTT2_REGISTRO;
    
    i QA_CTT2_REGISTRO%ROWTYPE;
BEGIN
    FOR i IN QA_CTT2_REGISTRO LOOP
        DBMS_OUTPUT.PUT_LINE('EL TRANSFORMADOR '||i.TT2_CODE_IUA);
    END LOOP;
END;
/

/****************************************************************************************************/
--CURSOR QUE INSERTA TODOS LOS VALORES DE UN SOLO CAMPO LUEGO DE CONSTRUIR UN RECORD VIA CURSOR...
SET SERVEROUTPUT ON;
DECLARE

    CURSOR QA_CTT2_REGISTRO IS
    SELECT TT2_CODIGOELEMENTO FROM QA_TTT2_REGISTRO;
    
    i QA_CTT2_REGISTRO%ROWTYPE;
    
BEGIN

    FOR i IN QA_CTT2_REGISTRO LOOP
        INSERT INTO QA_TX (CAMPO_TRA)
        VALUES (i.TT2_CODIGOELEMENTO);
        --DBMS_OUTPUT.PUT_LINE(i.TT2_CODIGOELEMENTO);
    END LOOP;
    
END;
/


/***************************************************************************************************/
--CREAR UN RECORD CON TODOS LOS VALORES DE UNA TABLA Y LUEGO INSERTARLOS TODOS EN OTRA TABLA SIMILAR

DECLARE
    CURSOR CUR IS
    SELECT * FROM QA_TTT2_REGISTRO;
    
    i CUR%ROWTYPE;

BEGIN
    FOR i IN CUR LOOP
        INSERT INTO QA_TX
        VALUES i;    
    END LOOP;
END;

/

/****************************************************************************************/
--NESTED RECORDS
DECLARE

   TYPE VAR_RECORD IS RECORD(
    VAR1 VARCHAR2(20),
    VAR2 VARCHAR2(20)
   ); 

   TYPE VAR_RECORD2 IS RECORD(
    VAR1# VAR_RECORD,
    VAR2# VAR_RECORD
   ); 

    
BEGIN
    NULL;
END;
/


/*************************************************************************************/



SELECT * FROM QA_TCOMPENSAR;

ALTER TABLE QA_TCOMPENSAR
DROP COLUMN CLASIFICACION
;
--(TIPO_COMPENSA,VC_NEW,VC_AJUSTE,VALOR_DT,CLASIFICACION);

DESC QA_TCOMPENSAR;


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 