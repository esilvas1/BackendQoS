CREATE OR REPLACE PROCEDURE BRAE.QA_PTC1_REGISTRO_FASE1(FECHAOPERACION  DATE)
AS

MAX_PERIODO_TC1 NUMBER;

BEGIN
    
    --MAX PERIODO TC1
    SELECT MAX(TC1_PERIODO)
    INTO MAX_PERIODO_TC1
    FROM QA_TTC1;

    IF TRUNC(FECHAOPERACION) = ADD_MONTHS(TO_DATE('01/'||SUBSTR(MAX_PERIODO_TC1,5,6)||'/'||SUBSTR(MAX_PERIODO_TC1,1,4),'DD/MM/YYYY'),1) 
       THEN -- PERMITE EJECUTARLO SOLO CUANDO SE ESTA REALIZANDO EL PERIODO ULTIMO FINALIZADO
            --*falta configurarlo para que en ejecuciones del mismo no corrompa la informacion

            --ELIMINAR LOS USURIOS DE OTROS COMERCIALIZADORES
            DELETE FROM QA_TTC1_TEMP
            WHERE TC1_IDCOMER <> '604'
            ;
            COMMIT
            ;

            --ELIMINAR LOS USURIOS DE TIPO CONEXION P
            DELETE FROM QA_TTC1_TEMP
            WHERE TC1_TIPCONEX =  'P'
            ;
            COMMIT
            ;

            --ELIMINAR LAS CALPs CONTENIDAS ACTAULAMENTE EN EL ARCHIVO,
            -- POSTERIORMENTE AGREGADO POR PROCEDIMIENTO QA_PTRANSFOR
            DELETE FROM QA_TTC1_TEMP
            WHERE TC1_TC1 LIKE 'CALP%'
            ;
            COMMIT
            ;
            
            --PEGAR LOS DATOS DE LA COLUMNA TC1_CODTRANSF EN LA COLUMNA TC1_CODCONEX
            --y ACTUALIZAR EL CAMPO TC1_TIPCONEX = 'T'
            UPDATE QA_TTC1_TEMP
            SET 
                TC1_CODCONEX =  TC1_CODTRANSF
               ,TC1_TIPCONEX = 'T'--Solucionar a futuro que no cambie los tipo P
            ;
            COMMIT
            ;
            
            --AGREGAR REGISTROS DE COMERCIALIZADORAS  TIPO T (PASO QUE SE EJECUTA UNA UNICA VEZ)
            INSERT INTO QA_TTC1_TEMP
            SELECT * FROM QA_TTC1_USRS_COMER
            ;
            COMMIT
            ;

            --AGREGAR REGISTROS DE COMERCIALIZADORAS  TIPO P (PASO QUE SE EJECUTA UNA UNICA VEZ)
            INSERT INTO QA_TTC1_TEMP
            SELECT * FROM QA_TTC1_USRS_TIPOP
            ;
            COMMIT
            ;

            --AGREGAMOS ESTOS USUARIOS DIRECTAMENTE DEL TC1 ANTERIOR(t-1) DEBIDO A UN ERROR EN LA DESCARGA SAC
            --*Alzate se pondra en contacto con los desarrolladores de SAC a traves de mesa de ayuda para solucionar este inconveniente

            INSERT INTO QA_TTC1_TEMP
            SELECT * FROM QA_TTC1
            WHERE TC1_TC1 IN (      SELECT DISTINCT TC1_TC1 
                                    FROM  QA_TTC1 
                                    WHERE     TC1_PERIODO = MAX_PERIODO_TC1
                                        AND   TC1_TC1 NOT LIKE 'CALP%' 
                                        AND   TC1_CODCONEX NOT LIKE 'ALPM%' 
                                        AND   TC1_TIPCONEX = 'T'
                                        AND   TC1_IDCOMER = '604'
                                MINUS
                                    SELECT DISTINCT TC1_TC1
                                    FROM  QA_TTC1_TEMP
                                    WHERE     TC1_TC1 NOT LIKE 'CALP%'
                                        AND   TC1_CODCONEX NOT LIKE 'ALPM%'
                                        AND   TC1_TIPCONEX = 'T'
                                        AND   TC1_IDCOMER = '604'
                              )
            AND TC1_PERIODO = MAX_PERIODO_TC1;
            COMMIT;

            --CAMBIAR VALORES DE TIPO_CONEXION (1,2) A (T,P)
            UPDATE QA_TTC1_TEMP
            SET TC1_TIPCONEX = 'P'
            WHERE TC1_TIPCONEX = '1';   
            COMMIT;
            
            UPDATE QA_TTC1_TEMP
            SET TC1_TIPCONEX = 'T'
            WHERE TC1_TIPCONEX = '2';
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('SUCESSFUL EJECUTION');
            DBMS_OUTPUT.PUT_LINE('PLEASE EXECUTE THE PROCEDURE QA_PTT2_REGISTRO()'); 
    
    ELSE 
            DBMS_OUTPUT.PUT_LINE('ISN´T POSIBLE THE EJECUCIÓN, ALREADY WAS EXCECUTED');
    
    END IF;

    --EJECUTAR PROECEDIMIENTO QA_PTTT2_REGISTRO()    
  
END QA_PTC1_REGISTRO_FASE1;


