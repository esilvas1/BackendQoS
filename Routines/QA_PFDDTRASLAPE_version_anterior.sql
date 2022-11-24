CREATE OR REPLACE PROCEDURE BRAE.QA_PFDDTRASLAPE(FECHAOPERACION DATE)
AS
          --TABLA A
          TYPE RECORD_A IS RECORD
          ( CODIGOEVENTO_I       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
            CODIGOEVENTO_F       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
            CODIGOELEMENTO       BRAE.QA_TFDDREGISTRO.FDD_CODIGOELEMENTO%TYPE,
            FINICIAL             BRAE.QA_TFDDREGISTRO.FDD_FINICIAL%TYPE,   
            FFINAL               BRAE.QA_TFDDREGISTRO.FDD_FFINAL%TYPE
          );
          TYPE TABLE_A IS TABLE OF RECORD_A;
          VAR_A TABLE_A;
          VAR_B TABLE_A;

BEGIN
        --BORRAR TABLA 
        DELETE FROM QA_TFDDTRASLAPE;
        COMMIT;
        --GENEAR INFORMACION PRELIMINAR A
        SELECT * 
        BULK COLLECT INTO VAR_A
        FROM QA_TFDDBUCKUP_TRASLAPE
        WHERE TRA_FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1);
        
        --GENERAR INFORMACION PRELIMINAR B
        SELECT * 
        BULK COLLECT INTO VAR_B
         FROM(
             SELECT I.MINICIAL,I.MFINAL,I.TRAFO, I.FINICIAL, I.FFINAL
             FROM OMS.INTERUPC I
             LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
             WHERE I.FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1)
             AND   M.CAUSA<>'PRUEBA'
             MINUS
             SELECT * FROM QA_TFDDBUCKUP_TRASLAPE       
             ORDER BY 1,3);


        --INICIA LA VALIDACION COMPARANDO A CON B
        FOR i IN 1 .. VAR_A.LAST LOOP
          FOR j IN  1 .. VAR_B.LAST LOOP
            IF(VAR_A(i).FFINAL IS NOT NULL AND VAR_B(j).FFINAL IS NOT NULL) THEN
                IF (VAR_A(i).CODIGOELEMENTO = VAR_B(j).CODIGOELEMENTO) THEN
                  DBMS_OUTPUT.put_line ('Compare intervalos');
                  IF (VAR_A(i).FINICIAL<=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL>=VAR_B(j).FFINAL) THEN
                    DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO1');
                    INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                        VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C1' );
                    COMMIT;
                  ELSE
                    IF (VAR_A(i).FINICIAL>=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL>=VAR_B(j).FFINAL AND VAR_A(i).FINICIAL<=VAR_B(j).FFINAL ) THEN
                      DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO2');
                      INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                          VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C2' );
                      COMMIT;
                    ELSE
                      IF (VAR_A(i).FINICIAL<=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL <= VAR_B(j).FFINAL AND VAR_A(i).FFINAL>=VAR_B(j).FINICIAL) THEN
                        DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO3');
                        INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL, 
                                                            VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C3' );
                        COMMIT;
                      ELSE
                        IF (VAR_A(i).FINICIAL>=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL<=VAR_B(j).FFINAL) THEN
                          DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO4');
                          INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                              VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C4' );
                          COMMIT;
                        END IF;  
                      END IF;
                    END IF;
                    DBMS_OUTPUT.put_line ('NO EXISTE TRASLAPE');
                  END IF;         
                END IF;
            ELSE
              IF(VAR_A(i).FFINAL IS NULL OR VAR_B(j).FFINAL IS NULL) THEN
                IF (VAR_A(i).CODIGOELEMENTO = VAR_B(j).CODIGOELEMENTO) THEN
                  IF (VAR_A(i).FINICIAL >= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NULL AND VAR_A(i).FFINAL IS NOT NULL) THEN
                    DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO5');
                    INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                        VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C5' );
                    COMMIT;
                  ELSE
                    IF (VAR_A(i).FINICIAL <= VAR_B(j).FINICIAL AND VAR_A(i).FFINAL > VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NULL AND VAR_A(i).FFINAL IS NOT NULL) THEN
                      DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO6');
                      INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                          VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C6' );
                      COMMIT;
                    ELSE
                      IF (VAR_A(i).FINICIAL >= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL>VAR_A(i).FINICIAL AND VAR_B(j).FFINAL IS NOT NULL AND VAR_A(i).FFINAL IS NULL) THEN
                        DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO7');
                        INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                            VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C7' );
                        COMMIT;
                      ELSE
                        IF (VAR_A(i).FINICIAL <= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NOT NULL AND VAR_A(i).FFINAL IS NULL) THEN
                          DBMS_OUTPUT.put_line ('EXISTE TRASLAPE CASO8');
                          INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                              VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'C8' );
                          COMMIT;
                        END IF; 
                      END IF;
                    END IF;
                  END IF;              
                END IF;
              END IF;
            END IF;
          END LOOP;
        END LOOP;                   

END QA_PFDDTRASLAPE;

--1. optimizar el procedimento con backup de procesos anteriores con el fin de opitimizar la busqueda de traslape*
--2. cambiar registros por trafo y visualizar registros por eventos (puede ser un condicional en la impresion)
--3. generar observaciones o sugerencias de solucion
--4. generar registros de error por causas diferentes entre la apertura y el cierre
--5. verificar que la fecha incial siempre sea menor que la fecha final
--6. implementar el procedimiento QA_PFDDTRASLAPE en QoS
--7. socializar el modulo de gestion de traslape
--8. explicacion de como vamos a Michael





