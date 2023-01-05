create or replace PROCEDURE      QA_PFDDTRASLAPE(FECHAOPERACION DATE)
AS
          --TABLA A
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

          --TABLA B
          TYPE RECORD_B IS RECORD
          ( CODIGOEVENTO_I       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
            --CODIGOEVENTO_F       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE,
            CODIGOEVENTO_F       VARCHAR2(10),
            CODIGOELEMENTO       BRAE.QA_TFDDREGISTRO.FDD_CODIGOELEMENTO%TYPE,
            FINICIAL             BRAE.QA_TFDDREGISTRO.FDD_FINICIAL%TYPE,
            FFINAL               BRAE.QA_TFDDREGISTRO.FDD_FFINAL%TYPE,
            CAUSA                BRAE.QA_TFDDREGISTRO.FDD_CAUSA%TYPE
          );
          TYPE TABLE_B IS TABLE OF RECORD_B;
          VAR_B TABLE_B;

          --VAR C --CODIGOS DE LOS MODIFICADOS
          TYPE RECORD_C IS RECORD
          ( CODIGOEVENTO       BRAE.QA_TFDDREGISTRO.FDD_CODIGOEVENTO%TYPE);
          TYPE TABLE_C IS TABLE OF RECORD_C;
          VAR_C TABLE_C;

          BANDERA BOOLEAN;
          MIN_DATE DATE;
          COUNT_A NUMBER;
          COUNT_B NUMBER;
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
             AND I.TYPEEQUIP = 'Transformer'
             --AND   M.CAUSA<>'PRUEBA' --Para tener en cuenta las pasadas a prueba y que existian en el backup
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


        --IDENTFICAR ERORRES EN LA ASIGNACION DE INTERVALOS
             INSERT INTO QA_TFDDTRASLAPE
             SELECT I.MINICIAL AS TRA_CODIGOEVENTO_A
                   ,I.TRAFO AS TRA_CODIGOELEMENTO_A
                   ,I.FINICIAL AS TRA_FINICIAL_A
                   ,I.FFINAL AS TRA_FFINAL_A
                   ,NULL AS TRA_CODIGOEVENTO_B
                   ,NULL AS TRA_CODIGOELEMENTO_B
                   ,NULL AS TRA_FINICIAL_B
                   ,NULL AS TRA_FFINAL_B
                   ,'Error en tiempos de apertura y cierre' AS TRA_CASO
             FROM OMS.INTERUPC I
             LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
             WHERE I.FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1)
             AND   M.CAUSA<>'PRUEBA'
             AND   I.TYPEEQUIP = 'Transformer'
             AND   I.FFINAL <= I.FINICIAL;


        --GENERAR INFORMACION PRELIMINAR B
        SELECT *
        BULK COLLECT INTO VAR_B
         FROM(
                 SELECT  SUBSTR(I.MINICIAL,1,10) AS MINICIAL
                       , SUBSTR(I.MFINAL,1,10) AS MFINAL
                       , SUBSTR(I.TRAFO,1,16) AS TRAFO
                       , I.FINICIAL
                       , I.FFINAL
                       , SUBSTR(M.CAUSA,1,50) AS CAUSA
                 FROM OMS.INTERUPC I
                 LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
                 WHERE I.FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1)
                 AND   I.FINICIAL <= FECHAOPERACION
                 AND   M.CAUSA<>'PRUEBA'
                 AND   I.TYPEEQUIP = 'Transformer'
                 AND   I.MINICIAL NOT IN (SELECT DISTINCT TRA_CODIGOEVENTO_A FROM QA_TFDDTRASLAPE)
             MINUS
                 SELECT * FROM QA_TFDDBACKUP_TRASLAPE
             );
        --LLENADO TEMPORAL DE LOS TRANSFORMADORES POSIBLEMENTE AFECTADOS
        /*DELETE FROM QA_TTRASLAPE_TEMP;
        COMMIT;*/

        IF VAR_B IS NOT EMPTY THEN
             FOR i IN VAR_B.FIRST..VAR_B.LAST LOOP
                   INSERT INTO BRAE.QA_TTRASLAPE_TEMP
                   VALUES VAR_B(i);
             END LOOP;
             --COMMIT;
        END IF;


        --GENEAR INFORMACION PRELIMINAR A

        SELECT MIN(TRA_FINICIAL)
        INTO MIN_DATE
        FROM QA_TTRASLAPE_TEMP;


        SELECT *
        BULK COLLECT INTO VAR_A
        FROM QA_TFDDBACKUP_TRASLAPE
        --WHERE TRA_FINICIAL >=  ADD_MONTHS(FECHAOPERACION,-1)
        WHERE TRA_FINICIAL >=  MIN_DATE
        AND   TRA_CODIGOELEMENTO IN (SELECT DISTINCT TRA_CODIGOELEMENTO FROM QA_TTRASLAPE_TEMP)
        ;

        COUNT_B := VAR_B.LAST;
        COUNT_A := VAR_A.LAST;

        DBMS_OUTPUT.PUT_LINE ('Registros de A: '|| COUNT_A);
        DBMS_OUTPUT.PUT_LINE ('Registros de B: '|| COUNT_B);
        DBMS_OUTPUT.PUT_LINE ('Fecha minima: '|| MIN_DATE);



        ROLLBACK; --avoid the paste to the information of table QA_TFDDTRASLAPE_TEMP

        IF COUNT_B IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('NO EXISTEN MANIOBRAS NUEVAS NI MODIFICADAS PARA VALIDAR');
        ELSE
            --INICIA LA VALIDACION COMPARANDO A CON B
            FOR i IN VAR_A.FIRST .. VAR_A.LAST LOOP
              FOR j IN VAR_B.FIRST .. VAR_B.LAST LOOP
                IF(VAR_A(i).FFINAL IS NOT NULL AND VAR_B(j).FFINAL IS NOT NULL) THEN
                    IF (VAR_A(i).CODIGOELEMENTO = VAR_B(j).CODIGOELEMENTO) THEN
                      IF (VAR_A(i).FINICIAL<=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL>=VAR_B(j).FFINAL) THEN
                        INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                            VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                            'Error de Traslape de tiempos' );
                        COMMIT;
                      ELSE
                        IF (VAR_A(i).FINICIAL>=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL>=VAR_B(j).FFINAL AND VAR_A(i).FINICIAL<=VAR_B(j).FFINAL ) THEN
                          INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                              VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                              'Error de Traslape de tiempos' );
                          COMMIT;
                        ELSE
                          IF (VAR_A(i).FINICIAL<=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL <= VAR_B(j).FFINAL AND VAR_A(i).FFINAL>=VAR_B(j).FINICIAL) THEN
                            INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                                'Error de Traslape de tiempos' );
                            COMMIT;
                          ELSE
                            IF (VAR_A(i).FINICIAL>=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL<=VAR_B(j).FFINAL) THEN
                              INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                  VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                                  'Error de Traslape de tiempos' );
                              COMMIT;
                            END IF;
                          END IF;
                        END IF;
                      END IF;
                    END IF;
                ELSE
                  IF(VAR_A(i).FFINAL IS NULL OR VAR_B(j).FFINAL IS NULL) THEN
                    IF (VAR_A(i).CODIGOELEMENTO = VAR_B(j).CODIGOELEMENTO) THEN
                      IF (VAR_A(i).FINICIAL >= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NULL AND VAR_A(i).FFINAL IS NOT NULL) THEN
                        INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                            VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                            'Error de Traslape de tiempos' );
                        COMMIT;
                      ELSE
                        IF (VAR_A(i).FINICIAL <= VAR_B(j).FINICIAL AND VAR_A(i).FFINAL > VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NULL AND VAR_A(i).FFINAL IS NOT NULL) THEN
                          INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                              VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                              'Error de Traslape de tiempos' );
                          COMMIT;
                        ELSE
                          IF (VAR_A(i).FINICIAL >= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL>VAR_A(i).FINICIAL AND VAR_B(j).FFINAL IS NOT NULL AND VAR_A(i).FFINAL IS NULL) THEN
                            INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                                'Error de Traslape de tiempos' );
                            COMMIT;
                          ELSE
                            IF (VAR_A(i).FINICIAL <= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NOT NULL AND VAR_A(i).FFINAL IS NULL) THEN
                              INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                  VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                                  'Error de Traslape de tiempos' );
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
                 AND   I.FINICIAL <= FECHAOPERACION
                 AND   M.CAUSA<>'PRUEBA'
                 AND   I.TYPEEQUIP = 'Transformer'
                 AND   I.MINICIAL NOT IN (SELECT DISTINCT TRA_CODIGOEVENTO_A FROM QA_TFDDTRASLAPE)
                 MINUS
                 SELECT * FROM QA_TFDDBACKUP_TRASLAPE
                 );

            --INICIA LA VALIDACION COMPARANDO A CON B
            FOR i IN 1 .. VAR_A.LAST - 1 LOOP
              FOR j IN  i+1 .. VAR_B.LAST LOOP
                IF(VAR_A(i).FFINAL IS NOT NULL AND VAR_B(j).FFINAL IS NOT NULL) THEN
                    IF (VAR_A(i).CODIGOELEMENTO = VAR_B(j).CODIGOELEMENTO) THEN
                      IF (VAR_A(i).FINICIAL<=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL>=VAR_B(j).FFINAL) THEN
                        INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                            VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'Error de Traslape de tiempos' );
                        COMMIT;
                      ELSE
                        IF (VAR_A(i).FINICIAL>=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL>=VAR_B(j).FFINAL AND VAR_A(i).FINICIAL<=VAR_B(j).FFINAL ) THEN
                          INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                              VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'Error de Traslape de tiempos' );
                          COMMIT;
                        ELSE
                          IF (VAR_A(i).FINICIAL<=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL <= VAR_B(j).FFINAL AND VAR_A(i).FFINAL>=VAR_B(j).FINICIAL) THEN
                            INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'Error de Traslape de tiempos' );
                            COMMIT;
                          ELSE
                            IF (VAR_A(i).FINICIAL>=VAR_B(j).FINICIAL AND VAR_A(i).FFINAL<=VAR_B(j).FFINAL) THEN
                              INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                  VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL, 'Error de Traslape de tiempos' );
                              COMMIT;
                            END IF;
                          END IF;
                        END IF;
                      END IF;
                    END IF;
                ELSE
                  IF(VAR_A(i).FFINAL IS NULL OR VAR_B(j).FFINAL IS NULL) THEN
                    IF (VAR_A(i).CODIGOELEMENTO = VAR_B(j).CODIGOELEMENTO) THEN
                      IF (VAR_A(i).FINICIAL >= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NULL AND VAR_A(i).FFINAL IS NOT NULL) THEN
                        INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                            VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                            'Error de Traslape de tiempos' );
                        COMMIT;
                      ELSE
                        IF (VAR_A(i).FINICIAL <= VAR_B(j).FINICIAL AND VAR_A(i).FFINAL > VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NULL AND VAR_A(i).FFINAL IS NOT NULL) THEN
                          INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                              VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                              'Error de Traslape de tiempos' );
                          COMMIT;
                        ELSE
                          IF (VAR_A(i).FINICIAL >= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL>VAR_A(i).FINICIAL AND VAR_B(j).FFINAL IS NOT NULL AND VAR_A(i).FFINAL IS NULL) THEN
                            INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                                'Error de Traslape de tiempos' );
                            COMMIT;
                          ELSE
                            IF (VAR_A(i).FINICIAL <= VAR_B(j).FINICIAL AND VAR_B(j).FFINAL IS NOT NULL AND VAR_A(i).FFINAL IS NULL) THEN
                              INSERT INTO QA_TFDDTRASLAPE VALUES (VAR_A(i).CODIGOEVENTO_I, VAR_A(i).CODIGOELEMENTO, VAR_A(i).FINICIAL, VAR_A(i).FFINAL,
                                                                  VAR_B(j).CODIGOEVENTO_I, VAR_B(j).CODIGOELEMENTO, VAR_B(j).FINICIAL, VAR_B(j).FFINAL,
                                                                  'Error de Traslape de tiempos' );
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
            SELECT *
            BULK COLLECT INTO VAR_C --REGISTROS TRASLAPADOS
            FROM (
                SELECT DISTINCT TRA_CODIGOEVENTO_A
                FROM QA_TFDDTRASLAPE
                UNION ALL
                SELECT DISTINCT TRA_CODIGOEVENTO_B
                FROM QA_TFDDTRASLAPE
                );
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
                 IF BANDERA=FALSE THEN
                      INSERT INTO QA_TFDDBACKUP_TRASLAPE
                      VALUES VAR_B(i);
                      COMMIT;
                      BANDERA := FALSE;
                 END IF;
               END LOOP;
            END IF;


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
