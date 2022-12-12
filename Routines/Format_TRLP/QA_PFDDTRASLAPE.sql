CREATE OR REPLACE PROCEDURE BRAE.QA_PFDDTRASLAPE(FECHAOPERACION DATE)
AS
          --TABLA A Y B
          TYPE RECORD_A IS RECORD
          ( CODIGOEVENTO_I       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
            --CODIGOEVENTO_F       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
            CODIGOEVENTO_F       VARCHAR2(10),
            CODIGOELEMENTO       BRAE.QA_TFDDREGISTRO.FDD_CODIGOELEMENTO%TYPE,
            FINICIAL             BRAE.QA_TFDDREGISTRO.FDD_FINICIAL%TYPE,   
            FFINAL               BRAE.QA_TFDDREGISTRO.FDD_FFINAL%TYPE,
            CAUSA                BRAE.QA_TFDDREGISTRO.FDD_CAUSA%TYPE
          );
          TYPE TABLE_A IS TABLE OF RECORD_A;
          VAR_A TABLE_A;
          VAR_B TABLE_A;

          --VAR C
          TYPE RECORD_C IS RECORD
          ( CODIGOEVENTO       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE);
          TYPE TABLE_C IS TABLE OF RECORD_C;
          VAR_C TABLE_C;

          BANDERA BOOLEAN;
BEGIN
        --DEPURACION DE LA TABLA A
        SELECT DISTINCT MINICIAL 
        BULK COLLECT INTO VAR_C
        FROM(
             SELECT  I.MINICIAL
                   , I.MFINAL
                   , I.TRAFO
                   , I.FINICIAL
                   , I.FFINAL
                   , M.CAUSA
             FROM OMS.INTERUPC I
             LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
             WHERE I.FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1)
             --AND   M.CAUSA<>'PRUEBA'
             MINUS
             SELECT * FROM QA_TFDDBACKUP_TRASLAPE
            );    
            IF VAR_C IS NOT EMPTY THEN
              FOR i IN VAR_C.FIRST .. VAR_C.LAST LOOP
                DELETE FROM QA_TFDDBACKUP_TRASLAPE
                WHERE TRA_CODIGOEVENTO_I = VAR_C(i).CODIGOEVENTO;
              END LOOP;
            END IF;
            COMMIT;
            
        --BORRAR TABLA 
        DELETE FROM QA_TFDDTRASLAPE;
        COMMIT;
        
        --GENEAR INFORMACION PRELIMINAR A
        SELECT * 
        BULK COLLECT INTO VAR_A
        FROM QA_TFDDBACKUP_TRASLAPE
        WHERE TRA_FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1);
        
        --GENERAR INFORMACION PRELIMINAR B
        SELECT * 
        BULK COLLECT INTO VAR_B
         FROM(
             SELECT I.MINICIAL,I.MFINAL,I.TRAFO, I.FINICIAL, I.FFINAL , M.CAUSA
             FROM OMS.INTERUPC I
             LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
             WHERE I.FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1)
             AND   M.CAUSA<>'PRUEBA'
             AND   I.TYPEEQUIP = 'Transformer'
             MINUS
             SELECT * FROM QA_TFDDBACKUP_TRASLAPE       
             ORDER BY 1,3);


        --INICIA LA VALIDACION COMPARANDO A CON B
        FOR i IN 1 .. VAR_A.LAST LOOP
          FOR j IN 1 .. VAR_B.LAST LOOP
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

       --IDENTIFCAR TRASLAPE SOLO EN LOS DATOS DE ENTRADA (B*B)
        --GENEAR INFORMACION PRELIMINAR B
        
        VAR_A.DELETE;
        
        SELECT * 
        BULK COLLECT INTO VAR_A
         FROM(
             SELECT I.MINICIAL,I.MFINAL,I.TRAFO, I.FINICIAL, I.FFINAL, M.CAUSA
             FROM OMS.INTERUPC I
             LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
             WHERE I.FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1)
             AND   M.CAUSA<>'PRUEBA'
             MINUS
             SELECT * FROM QA_TFDDBACKUP_TRASLAPE       
             ORDER BY 1,3);


        --INICIA LA VALIDACION COMPARANDO A CON B
        FOR i IN 1 .. VAR_A.LAST - 1 LOOP
          FOR j IN  i+1 .. VAR_B.LAST LOOP
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

        --AGREGAR LOS REGISTROS DE LA VARIABLE B QUE NO TRASLAPAN A LA TABLA QA_TFDDBUCKUP_TRASLAPE
        VAR_C.DELETE;
        SELECT DISTINCT TRA_CODIGOEVENTO_B 
        BULK COLLECT INTO VAR_C
        FROM QA_TFDDTRASLAPE; 
        
        BANDERA:=FALSE;
        IF VAR_B IS NOT EMPTY THEN
           FOR i IN VAR_B.FIRST .. VAR_B.LAST LOOP
             IF VAR_C IS NOT EMPTY THEN
               FOR j IN VAR_C.FIRST .. VAR_C.LAST LOOP
               IF VAR_B(i).CODIGOEVENTO_I = VAR_C(j).CODIGOEVENTO THEN
                 BANDERA:=TRUE;
               END IF;
               END LOOP;
             END IF;
            
            IF BANDERA = FALSE THEN
              INSERT INTO QA_TFDDBACKUP_TRASLAPE
              VALUES VAR_B(i);
              COMMIT;
            END IF;
            BANDERA:=FALSE; 
           END LOOP;
        END IF;


END QA_PFDDTRASLAPE;


--1. optimizar el procedimento con backup de procesos anteriores con el fin de opitimizar la busqueda de traslape* --OK
  --1.1 Llenar tabla A con los registros de B que no traslaparon -OK
--2. cambiar registros por trafo y visualizar registros por eventos (puede ser un condicional en la impresion)
--2.1 Validar las modificaciones que ya no se permitirian en la tabla de registro
--2.2 Advertencia de fechas simuladas en el oms que no se pueden reportar, (cierres tardios)
--3. generar observaciones o sugerencias de solucion
--4. generar registros de error por causas diferentes entre la apertura y el cierre
--5. verificar que la fecha incial siempre sea menor que la fecha final
--6. implementar el procedimiento QA_PFDDTRASLAPE en QoS
--7. socializar el modulo de gestion de traslape
--8. explicacion de como vamos a Michael





