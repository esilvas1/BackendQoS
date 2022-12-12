CREATE OR REPLACE PROCEDURE BRAE.QA_PTT2_REPORTE(FECHAOPERACION DATE)
AS

REPORTE_0 NUMBER;
PERIODO_ACTUAL DATE;


BEGIN
    --CANTIDAD DE REGISTROS SIN REPORTAR
    SELECT COUNT(*) 
    INTO REPORTE_0
    FROM QA_TTT2_REGISTRO
    WHERE TT2_PERIODO_OP = TRUNC(FECHAOPERACION)
    AND   TT2_ESTADOREPORTE=0;

    SELECT MAX(TT2_PERIODO_OP)
    INTO PERIODO_ACTUAL
    FROM QA_TTT2_REGISTRO;
    

    IF REPORTE_0 > 0 AND TRUNC(PERIODO_ACTUAL) = TRUNC(FECHAOPERACION) THEN
        --Borrado de los registros de reporte almacenado de la misma fecha de operacion
        DELETE FROM QA_TTT2_REPORTE
        WHERE TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
        COMMIT;
     
        --Insercion de registros del periodo de operacion    
        INSERT INTO QA_TTT2_REPORTE
        SELECT TRUNC(FECHAOPERACION) AS TT2_PERIODO_OP
              ,TT2_CODIGOELEMENTO 
              ,TT2_CODE_IUA
              ,TO_NUMBER(TT2_GRUPOCALIDAD) AS TT2_GRUPOCALIDAD
              ,TO_NUMBER(TT2_IDMERCADO) AS TT2_IDMERCADO
              ,TT2_CAPACIDAD
              ,(CASE WHEN TT2_PROPIEDAD ='CENS'
                     THEN 1
                     ELSE 2
                END) AS TT2_PROPIEDAD
              ,TT2_TSUBESTACION
              ,TT2_LONGITUD
              ,TT2_LATITUD
              ,TT2_ALTITUD
              ,(CASE WHEN(TT2_ESTADO = 'OPERACION'   ) THEN(2) 
                     WHEN(TT2_ESTADO = 'RETIRADO'    ) THEN(3)
                     --WHEN(TT2_ESTADO = 'CONSTRUCCION') THEN(2)
                END)AS TT2_ESTADO
              ,TT2_FESTADO
              ,TT2_RESMETODOLOGIA
          FROM QA_TTT2_REGISTRO
          ;
          COMMIT;
          DBMS_OUTPUT.PUT_LINE('Reporte generado para el periodo: '||TRUNC(FECHAOPERACION));
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ya existe un reporte certificado para el periodo: '||TRUNC(FECHAOPERACION));
    END IF;

END QA_PTT2_REPORTE;
/