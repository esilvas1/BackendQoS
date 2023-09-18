CREATE OR REPLACE PROCEDURE BRAE.QA_PDIFERENCIAS_LAC_OR(FECHAOPERACION IN DATE, ESTADO OUT NUMBER)
AS 
CANT_USUARIOS_LAC NUMBER;
CANT_EVENTOS_LAC  NUMBER;
CANT_USUARIOS_OR NUMBER;
CANT_EVENTOS_OR  NUMBER;

BEGIN
	
	
	--VERIFICAR QUE LAS TABLAS QA_TCONSOLIDADO_LAC_ENVENTOS Y QA_TCONSOLIDADO_LAC_USUARIOS ESTEN POBLADAS PARA EL MISMO PERIODO.
	SELECT COUNT(1) INTO CANT_EVENTOS_LAC 
	FROM QA_TCONSOLIDADO_LAC_EVENTOS 
	WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'));

	SELECT COUNT(1) INTO CANT_USUARIOS_LAC 
	FROM QA_TCONSOLIDADO_LAC_USUARIOS 
	WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'));

	IF (CANT_EVENTOS_LAC = 0) THEN
		
		ESTADO := 0;
		
		INSERT INTO QA_TLOG_EJECUCION
    	SELECT SYSDATE,'QA_PDIFERENCIAS_LAC_OR','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'FALLIDO','No ha cargado informacion de eventos LAC' FROM DUAL;
   		COMMIT;
   	
   		RETURN;

	END IF;

	IF (CANT_USUARIOS_LAC = 0) THEN
		
		ESTADO := 0;
		
		INSERT INTO QA_TLOG_EJECUCION
    	SELECT SYSDATE,'QA_PDIFERENCIAS_LAC_OR','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'FALLIDO','No ha cargado informacion de usuarios LAC' FROM DUAL;
   		COMMIT;
   	
   		RETURN;

	END IF;

	
	--BORRAR LA INFORMACION EXISTENTE DEL PERIODO A EJECUTAR
	DELETE FROM QA_TCONSOLIDADO_OR_EVENTOS
	WHERE FDD_YEAR  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   FDD_MES = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'  ))
	;
	COMMIT;

	DELETE FROM QA_TCONSOLIDADO_OR_USUARIOS
	WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'  ))
	;
	COMMIT;

	--INSERTAR INFORMACION DEL PERIORODO A LA TABLA CONSOLIDADO DE EVENTOS DEL OR
	INSERT INTO QA_TCONSOLIDADO_OR_EVENTOS
		SELECT TO_CHAR(FECHAOPERACION,'YYYY') AS FDD_YEAR
	      ,TO_CHAR(FECHAOPERACION, 'MM') AS FDD_MONTH
	      ,'CNSD' AS FDD_COD_ASIC
	      ,FDD_CODIGOEVENTO AS FDD_CODIGOEVENTO
	      ,FDD_CAUSA_CREG AS FDD_CAUSA_CREG
	      ,FDD_IUA
	      ,(case when FDD_TIPOELEMENTO = 'Transformer' then 1 else 0 end) AS FDD_TIPOELEMENTO
	               ,ROUND((CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(FECHAOPERACION), + 1) OR FDD_FFINAL IS NULL )
	                     THEN
	                      (
	----------------------FDD_FFINAL ES MAYOR AL TIEMPO DE OPERACION O ES NULL
	                         ((CASE WHEN (TRUNC(FDD_FINICIAL)<>(ADD_MONTHS(TRUNC(FECHAOPERACION), + 1) - 1))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
	                                        THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6)-- CASO 1
	                                                  THEN (
	                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                       + 6
	                                                       + (ADD_MONTHS(TRUNC(FECHAOPERACION), + 1)-(TRUNC(FDD_FINICIAL)+1))*24/2
	                                                       )
	                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18)--CASO2
	                                                             THEN (
	                                                                   6
	                                                                   + (ADD_MONTHS(TRUNC(FECHAOPERACION), + 1)-(TRUNC(FDD_FINICIAL)+1))*24/2
	                                                                   )
	                                                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18)--CASO 3
	                                                                        THEN (
	                                                                             ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                             + (ADD_MONTHS(TRUNC(FECHAOPERACION), + 1)-(TRUNC(FDD_FINICIAL)+1))*24/2
	                                                                             )
	                                                                   END)
	                                                        END)
	                                             END))--INICIA BLOQUE 2 (EN EL MISMO DIA)
	                                         ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6)--CASO 4
	                                                  THEN (
	                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                       + 6
	                                                       )
	                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18)--CASO 5
	                                                            THEN (
	                                                                 6
	                                                                 )
	                                                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18)-- CASO 6
	                                                                       THEN (
	                                                                            (ADD_MONTHS(TRUNC(FECHAOPERACION), + 1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                            )
	                                                                  END)
	                                                       END)
	                                             END)
	                                        END))
	----------------------
	                      )
	                     ELSE
	                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(FECHAOPERACION))
	                        THEN
	                           (
	---------------------------FDD_FINICIAL ES MENOR AL TIEMPO DE OPERACION
	                             ((CASE WHEN (TRUNC(FDD_FFINAL)<>(TRUNC(FECHAOPERACION)))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
	                                            THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL) < 6)-- CASO 7
	                                                      THEN (
	                                                           (TRUNC(FDD_FFINAL)-TRUNC(FECHAOPERACION)) * 24 / 2
	                                                           + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TRUNC(FDD_FFINAL)) * 24
	                                                           )
	                                                      ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL) < 18)--CASO8
	                                                                 THEN (
	                                                                      (TRUNC(FDD_FFINAL)-TRUNC(FECHAOPERACION)) * 24 / 2
	                                                                      + 6
	                                                                      )
	                                                                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 9
	                                                                            THEN (
	                                                                                 (TRUNC(FDD_FFINAL)-TRUNC(FECHAOPERACION)) * 24 / 2
	                                                                                 + 6
	                                                                                 + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-(TRUNC(FDD_FFINAL) + 18 / 24)) * 24
	                                                                                 )
	                                                                       END)
	                                                            END)
	                                                 END))--INICIA BLOQUE 2 (EN EL MISMO DIA)
	                                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 10
	                                                      THEN (
	                                                           (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)))*24
	                                                           )
	                                                      ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 11
	                                                                THEN (
	                                                                     6
	                                                                     )
	                                                                ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=18)-- CASO 12
	                                                                           THEN (
	                                                                                6
	                                                                                + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+18/24))*24
	                                                                                )
	                                                                      END)
	                                                           END)
	                                                 END)
	                                            END))
	---------------------------
	                           )
	                        ELSE
	                         (
	-------------------------- FDD_FINICIAL Y FDD_FFINAL ESTAN DENTRO DEL PERIODO
	                         ((CASE WHEN (TRUNC(FDD_FINICIAL)<>TRUNC(FDD_FFINAL))--BLOQUE 1
	                                        THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 13
	                                                  THEN (
	                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                       + 6
	                                                       + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                       + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')- TRUNC(FDD_FFINAL))*24
	                                                       )
	                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 14
	                                                                 THEN (
	                                                                      ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                      + 6
	                                                                      + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                      + 6
	                                                                      + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
	                                                                      )
	                                                                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 15
	                                                                           THEN (
	                                                                                ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                                + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                                + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - TRUNC(FDD_FFINAL))*24
	                                                                                )
	                                                                           ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 16
	                                                                                     THEN (
	                                                                                          ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                                          + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                                          + 6
	                                                                                          + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
	                                                                                          )
	                                                                                     ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 17
	                                                                                               THEN (
	                                                                                                    6
	                                                                                                    + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                                                    + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - TRUNC(FDD_FFINAL))*24
	                                                                                                    )
	                                                                                               ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 18
	                                                                                                         THEN (
	                                                                                                              6
	                                                                                                              + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                                                              + 6
	                                                                                                              )
	                                                                                                         ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 19
	                                                                                                                        THEN (
	                                                                                                                             6
	                                                                                                                             + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                                                                             + 6
	                                                                                                                             + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
	                                                                                                                             )
	                                                                                                                        ELSE(CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 20
	                                                                                                                                  THEN(
	                                                                                                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                                                                                       + 6
	                                                                                                                                       + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                                                                                       + 6
	                                                                                                                                       )
	                                                                                                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18) --CASO 21
	                                                                                                                                            THEN (
	                                                                                                                                                 ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                                                                                                 + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
	                                                                                                                                                 + 6
	                                                                                                                                                 )
	                                                                                                                                       END)
	                                                                                                                             END)
	                                                                                                                   END)
	                                                                                                    END)
	                                                                                          END)
	                                                                                END)
	                                                                      END)
	                                                            END)
	                                             END))--INICIA BLOQUE 2
	                                        ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 22
	                                                  THEN (
	                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                       )
	                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 23
	                                                            THEN (
	                                                                 ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                 + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
	                                                                 )
	                                                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 24
	                                                                           THEN (
	                                                                                (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
	                                                                                )
	                                                                           ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 25
	                                                                                     THEN (
	                                                                                          (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                                          )
	                                                                                     ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)-- CASO 26
	                                                                                               THEN (
	                                                                                                    (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
	                                                                                                    )
	                                                                                               ELSE (TO_NUMBER(0))
	                                                                                          END)
	                                                                                END)
	                                                                      END)
	                                                       END)
	                                             END)
	                                        END))
	--------------------------
	                         )
	                         END
	       END),13) AS FDD_DUR_NOCTURNA
	               ,ROUND((CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(FECHAOPERACION),+1) OR FDD_FFINAL IS NULL )
	                     THEN
	                      (ADD_MONTHS(TRUNC(FECHAOPERACION),+1) - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
	                     ELSE
	                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(FECHAOPERACION))
	                        THEN
	                           (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TRUNC(FECHAOPERACION))*24
	                        ELSE
	                         (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
	                         END
	                END),13) AS FDD_DURACION
	      ,CANT_USERS AS FDD_USRS_AFECTADOS
	FROM QA_TFDDREGISTRO
	LEFT OUTER JOIN (
	                select TC1_CODCONEX, count(TC1_CODCONEX) as CANT_USERS from QA_TTC1
	                where TC1_PERIODO =  TO_CHAR(FECHAOPERACION,'YYYYMM')
	                and TC1_CODCONEX not like 'ALPM%'
	                and TC1_TIPCONEX = 'T'
	                group by TC1_CODCONEX
	) ON TC1_CODCONEX = FDD_CODIGOELEMENTO
	LEFT OUTER JOIN (SELECT DISTINCT FDC_CAUSA_015, FDC_EXCLUSION FROM QA_TFDDCAUSAS) ON FDC_CAUSA_015 = FDD_CAUSA_CREG
	WHERE (TO_CHAR(FDD_FINICIAL, 'MM/YYYY') = TO_CHAR(FECHAOPERACION,'MM/YYYY')
	           OR TO_CHAR(FDD_FFINAL, 'MM/YYYY') = TO_CHAR(FECHAOPERACION,'MM/YYYY'))
	AND FDC_EXCLUSION = 'NO EXCLUIDA'
	
	UNION ALL
	
	SELECT TO_CHAR(FECHAOPERACION,'YYYY') AS FDD_YEAR
	      ,TO_CHAR(FECHAOPERACION, 'MM') AS FDD_MONTH
	      ,'CNSD' AS FDD_COD_ASIC
	      ,FDD_CODIGOEVENTO AS FDD_CODIGOEVENTO
	      ,FDD_CAUSA_CREG AS FDD_CAUSA_CREG
	      ,FDD_IUA
	      ,(case when FDD_TIPOELEMENTO = 'Transformer' then 1 else 0 end) AS FDD_TIPOELEMENTO
	      ,(ADD_MONTHS(FECHAOPERACION,+1) - FECHAOPERACION)*24/2 AS FDD_DUR_NOCTURNA
	      ,(ADD_MONTHS(FECHAOPERACION,+1) - FECHAOPERACION)*24 AS FDD_DURACION
	      ,CANT_USERS AS FDD_USRS_AFECTADOS
	FROM QA_TFDDREGISTRO
	LEFT OUTER JOIN (
	                select TC1_CODCONEX, count(TC1_CODCONEX) as CANT_USERS from QA_TTC1
	                where TC1_PERIODO =  TO_CHAR(FECHAOPERACION,'YYYYMM')
	                and TC1_CODCONEX not like 'ALPM%'
	                and TC1_TIPCONEX = 'T'
	                group by TC1_CODCONEX
	) ON TC1_CODCONEX = FDD_CODIGOELEMENTO
	LEFT OUTER JOIN (SELECT DISTINCT FDC_CAUSA_015, FDC_EXCLUSION FROM QA_TFDDCAUSAS) ON FDC_CAUSA_015 = FDD_CAUSA_CREG
	WHERE (  FDD_FINICIAL < FECHAOPERACION
	AND (FDD_FFINAL >= ADD_MONTHS(FECHAOPERACION,+1) OR FDD_FFINAL IS NULL))
	AND FDC_EXCLUSION = 'NO EXCLUIDA'
	;
	COMMIT;


	--INSERTAR INFORMACION DEL OR A LA TABLA QA_TCONSOLIDADO_OR_USUARIOS
	INSERT INTO QA_TCONSOLIDADO_OR_USUARIOS
	SELECT TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY')) AS FDD_YEAR
	      ,TO_NUMBER(TO_CHAR(FECHAOPERACION, 'MM')) AS FDD_MES
	      ,'CNSD' AS FDD_COD_ASIC
	      ,CSU_NIU AS FDD_NIU
	      ,TT2_CODE_IUA AS FDD_CODIGOELEMENTO
	      ,(CASE WHEN TC1_TIPCONEX = 'T' THEN '1' ELSE '2' END) AS FDD_TIPOELEMENTO
	      ,TO_CHAR(TC1_GC) AS FDD_GRUPOCALIDAD
	      ,TC1_NT AS FDD_NIVEL
	      ,CSU_DIUM AS FDD_TIEMPONETO
	      ,CSU_DIUM AS FDD_TIEMPO_SIN_EXCLU_AP
	      ,(CASE WHEN CSU_NIU LIKE 'CALP%' THEN 1 ELSE 0 END) AS FDD_ES_ALUMBRADO
	FROM   QA_TCSU
	LEFT OUTER JOIN (SELECT TC1_TC1, TC1_CODCONEX, TC1_TIPCONEX, TC1_GC, TC1_NT 
					 FROM QA_TTC1 
					 WHERE TC1_PERIODO = TO_CHAR(FECHAOPERACION, 'YYYYMM')
					 ) ON TC1_TC1 = CSU_NIU
	LEFT OUTER JOIN (
					SELECT TT2_CODE_TRAFO, TT2_CODE_IUA 
					FROM QA_TTT2_REPORTE 
					WHERE TT2_PERIODO_OP = FECHAOPERACION
					AND TT2_ESTADO = 2
					AND TT2_CODE_TRAFO NOT IN (SELECT DISTINCT TT2_CODE_TRAFO 
					   						   FROM QA_TTT2_REPORTE 
											   WHERE TT2_PERIODO_OP = FECHAOPERACION
											   AND TT2_ESTADO = 3
											  )
					UNION ALL
					
					SELECT TT2_CODE_TRAFO, TT2_CODE_IUA 
					FROM QA_TTT2_REPORTE 
					WHERE TT2_PERIODO_OP = FECHAOPERACION
					AND TT2_ESTADO = 3
					) ON TT2_CODE_TRAFO = TC1_CODCONEX
	WHERE  CSU_PERIODO_OP = FECHAOPERACION
	;
	COMMIT;

	--VERIFCACION DE GENERACION DE INFORMACION PARA EL OR
	SELECT COUNT(1) INTO CANT_EVENTOS_OR 
	FROM QA_TCONSOLIDADO_OR_EVENTOS 
	WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'));

	SELECT COUNT(1) INTO CANT_USUARIOS_OR 
	FROM QA_TCONSOLIDADO_OR_USUARIOS 
	WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'));


	IF (CANT_USUARIOS_OR = 0) THEN
		
		ESTADO := 0;
		
		INSERT INTO QA_TLOG_EJECUCION
    	SELECT SYSDATE,'QA_PDIFERENCIAS_LAC_OR','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'FALLIDO','No hubo generación de usuarios para el OR' FROM DUAL;
   		COMMIT;
   	
   		RETURN;
 
	END IF;

	IF (CANT_EVENTOS_OR = 0) THEN
		
		ESTADO := 0;
		
		INSERT INTO QA_TLOG_EJECUCION
    	SELECT SYSDATE,'QA_PDIFERENCIAS_LAC_OR','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'FALLIDO','No hubo generación de eventos para el OR' FROM DUAL;
   		COMMIT;
   	
   		RETURN;
   	
	END IF;


	--CRUZAR LAS DOS TABLAS DE EVENTOS Y SACAR DIFERENCIAS, PRIMERO BORRAMOS INFO PARA EJECUCIONES MULTIPLES
	DELETE FROM QA_TDIFERENCIA_EVENTOS 
	WHERE  FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND    FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
	;
	COMMIT;

	--DIFERENCIAS QUE CONSISTEN EN EVENETOS EXISTENTES SOLO EN XM
	INSERT INTO QA_TDIFERENCIA_EVENTOS
		SELECT LAC.FDD_YEAR 
		      ,LAC.FDD_MES
		      ,LAC.FDD_CODIGOEVENTO
		      ,LAC.FDD_CAUSA_CREG 
		      ,LAC.FDD_IUA 
		      ,LAC.FDD_DURACION
		      ,LAC.FDD_USRS_AFECTADOS
		      ,RAD.FDD_TIPOAJUSTE
		      ,RAD.FDD_RADICADO
		      ,TRUNC(RAD.FDD_PERIODO_OP,'MM') AS FDD_PERIODO_OP
		      ,'Eventos que solo existen en XM' FDD_OBSERVACIONES
		FROM QA_TCONSOLIDADO_LAC_EVENTOS LAC
		LEFT OUTER JOIN (
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP
						FROM QA_TFDDREGISTRO
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						
						UNION ALL
						
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP 
						FROM QA_TFDDELIMINADOS 
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						) RAD ON RAD.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND RAD.FDD_IUA = LAC.FDD_IUA 
		WHERE LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA IN (
		  						                   SELECT FDD_CODIGOEVENTO||FDD_IUA FROM QA_TCONSOLIDADO_LAC_EVENTOS
	 						                   	   WHERE  FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
												   AND    FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
								                   MINUS
								                   SELECT FDD_CODIGOEVENTO||FDD_IUA FROM QA_TCONSOLIDADO_OR_EVENTOS
	 						                   	   WHERE  FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
												   AND    FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
								                   )
	   AND    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	   AND    LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
	  ;
	 COMMIT;
	
	
	--EVENOTS QUE SOLO EXISTEN EN EL OR Y NO LOS TIENE XM
	INSERT INTO QA_TDIFERENCIA_EVENTOS 
	SELECT LAC.FDD_YEAR 
	      ,LAC.FDD_MES
	      ,LAC.FDD_CODIGOEVENTO
	      ,LAC.FDD_CAUSA_CREG 
	      ,LAC.FDD_IUA 
	      ,LAC.FDD_DURACION
	      ,LAC.FDD_USRS_AFECTADOS
	      ,RAD.FDD_TIPOAJUSTE
	      ,RAD.FDD_RADICADO
	      ,TRUNC(RAD.FDD_PERIODO_OP,'MM') AS FDD_PERIODO_OP
	      ,'Eventos que solo existen en OR' FDD_OBSERVACIONES
	FROM QA_TCONSOLIDADO_OR_EVENTOS LAC
	LEFT OUTER JOIN (
					SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP
					FROM QA_TFDDREGISTRO
					WHERE FDD_AJUSTADO = 'S'
					AND FDD_IUA IS NOT NULL
					
					UNION ALL
					
					SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP 
					FROM QA_TFDDELIMINADOS 
					WHERE FDD_AJUSTADO = 'S'
					AND FDD_IUA IS NOT NULL
					) RAD ON RAD.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND RAD.FDD_IUA = LAC.FDD_IUA 
	WHERE LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA IN (
							                   SELECT FDD_CODIGOEVENTO||FDD_IUA FROM QA_TCONSOLIDADO_OR_EVENTOS
 						                   	   WHERE  FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
											   AND    FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
											   MINUS
											   SELECT FDD_CODIGOEVENTO||FDD_IUA FROM QA_TCONSOLIDADO_LAC_EVENTOS
							                   WHERE  FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
											   AND    FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
							                   )
    AND    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
    AND    LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
    ;
	COMMIT;

	--EVENTOS CON DIFERENCIA EN LA CANTIDAD DE USUARIOS
	INSERT INTO QA_TDIFERENCIA_EVENTOS
		SELECT LAC.FDD_YEAR 
		      ,LAC.FDD_MES
		      ,LAC.FDD_CODIGOEVENTO
		      ,LAC.FDD_CAUSA_CREG 
		      ,LAC.FDD_IUA 
		      ,LAC.FDD_DURACION
		      ,LAC.FDD_USRS_AFECTADOS
		      ,NVL(RAD.FDD_TIPOAJUSTE,0)   AS FDD_TIPOAJUSTE
		      ,NVL(RAD.FDD_RADICADO,0)   AS FDD_TIPOAJUSTE
		      ,TRUNC(RAD.FDD_PERIODO_OP,'MM') AS FDD_PERIODO_OP
		      ,'Eventos con diferencia en la cantidad de usuarios' FDD_OBSERVACIONES
		FROM QA_TCONSOLIDADO_LAC_EVENTOS LAC
		LEFT OUTER JOIN (
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP
						FROM QA_TFDDREGISTRO
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						
						UNION ALL
						
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP 
						FROM QA_TFDDELIMINADOS 
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						) RAD ON RAD.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND RAD.FDD_IUA = LAC.FDD_IUA 
		WHERE LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA IN (
													SELECT LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA  
													FROM QA_TCONSOLIDADO_LAC_EVENTOS LAC
													LEFT OUTER JOIN (SELECT * FROM QA_TCONSOLIDADO_OR_EVENTOS 
																	 WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY')) 
													                 AND FDD_MES = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
													                 ) ORR ON ORR.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND ORR.FDD_IUA = LAC.FDD_IUA 
													WHERE    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
													AND      LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
													AND LAC.FDD_USRS_AFECTADOS <> ORR.FDD_USRS_AFECTADOS
								                   )
	   AND    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	   AND    LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
	  ;
	 COMMIT;

	--EVENTOS CON DIFERENCIA EN LA DURACION DEL INTERVALO DE TIEMPO
	INSERT INTO QA_TDIFERENCIA_EVENTOS
		SELECT LAC.FDD_YEAR 
		      ,LAC.FDD_MES
		      ,LAC.FDD_CODIGOEVENTO
		      ,LAC.FDD_CAUSA_CREG 
		      ,LAC.FDD_IUA 
		      ,LAC.FDD_DURACION
		      ,LAC.FDD_USRS_AFECTADOS
		      ,NVL(RAD.FDD_TIPOAJUSTE,0)   AS FDD_TIPOAJUSTE
		      ,NVL(RAD.FDD_RADICADO,0)   AS FDD_TIPOAJUSTE
		      ,TRUNC(RAD.FDD_PERIODO_OP,'MM') AS FDD_PERIODO_OP
		      ,'Eventos con diferencia en la duración' FDD_OBSERVACIONES
		FROM QA_TCONSOLIDADO_LAC_EVENTOS LAC
		LEFT OUTER JOIN (
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP
						FROM QA_TFDDREGISTRO
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						
						UNION ALL
						
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP 
						FROM QA_TFDDELIMINADOS 
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						) RAD ON RAD.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND RAD.FDD_IUA = LAC.FDD_IUA 
		WHERE LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA IN (
													SELECT LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA   
													FROM QA_TCONSOLIDADO_LAC_EVENTOS LAC
													LEFT OUTER JOIN (SELECT * FROM QA_TCONSOLIDADO_OR_EVENTOS 
																     WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
																     AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
																     ) ORR ON ORR.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND ORR.FDD_IUA = LAC.FDD_IUA 
													WHERE    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
													AND      LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
													AND ROUND(LAC.FDD_DUR_NOCTURNA,10) <> ROUND(ORR.FDD_DURACION,10)
													AND ABS(ROUND(LAC.FDD_DUR_NOCTURNA,10) - ROUND(ORR.FDD_DURACION,10)) > 0.001
								                   )
	   AND    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	   AND    LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
	  ;
	  COMMIT;
	 
	 --EVENTOS CON DIFERENCIA LA ASIGNACION DE LA CAUSA
	 INSERT INTO QA_TDIFERENCIA_EVENTOS 
		SELECT LAC.FDD_YEAR 
		      ,LAC.FDD_MES
		      ,LAC.FDD_CODIGOEVENTO
		      ,LAC.FDD_CAUSA_CREG 
		      ,LAC.FDD_IUA 
		      ,LAC.FDD_DURACION
		      ,LAC.FDD_USRS_AFECTADOS
		      ,NVL(RAD.FDD_TIPOAJUSTE,0)   AS FDD_TIPOAJUSTE
		      ,NVL(RAD.FDD_RADICADO,0)   AS FDD_TIPOAJUSTE
		      ,TRUNC(RAD.FDD_PERIODO_OP,'MM') AS FDD_PERIODO_OP
		      ,'Eventos con diferencia en la asignación de la causa' FDD_OBSERVACIONES
		FROM QA_TCONSOLIDADO_LAC_EVENTOS LAC
		LEFT OUTER JOIN (
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP
						FROM QA_TFDDREGISTRO
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						
						UNION ALL
						
						SELECT FDD_CODIGOEVENTO, FDD_IUA, FDD_TIPOAJUSTE , FDD_RADICADO , FDD_PERIODO_OP 
						FROM QA_TFDDELIMINADOS 
						WHERE FDD_AJUSTADO = 'S'
						AND FDD_IUA IS NOT NULL
						) RAD ON RAD.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND RAD.FDD_IUA = LAC.FDD_IUA 
		WHERE LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA IN (
													SELECT LAC.FDD_CODIGOEVENTO||LAC.FDD_IUA   
													FROM QA_TCONSOLIDADO_LAC_EVENTOS LAC
													LEFT OUTER JOIN (SELECT * FROM QA_TCONSOLIDADO_OR_EVENTOS 
																	 WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
																	 AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
																	 ) ORR ON ORR.FDD_CODIGOEVENTO = LAC.FDD_CODIGOEVENTO AND ORR.FDD_IUA = LAC.FDD_IUA 
													WHERE    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
													AND      LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
													AND 	 LAC.FDD_CAUSA_CREG <> ORR.FDD_CAUSA_CREG
								                   )
	   AND    LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	   AND    LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
	  ;
	 COMMIT;
	
	--DIFERENCIA DE USUARIOS, USUARIOS SOLO EN XM
	INSERT INTO QA_TDIFERENCIA_USUARIOS
	SELECT LAC.FDD_YEAR
		  ,LAC.FDD_MES
		  ,LAC.FDD_NIU
		  ,LAC.FDD_CODIGOELEMENTO
		  ,LAC.FDD_GRUPOCALIDAD
		  ,LAC.FDD_NIVEL
		  ,LAC.FDD_TIEMPONETO 
		  ,LAC.FDD_ES_ALUMBRADO 
		  ,'Usuarios que solo existen en el consolidado XM' AS FDD_OBSERVACIONES
	FROM QA_TCONSOLIDADO_LAC_USUARIOS LAC
	WHERE LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
	AND   LAC.FDD_NIU IN (
						  SELECT FDD_NIU FROM QA_TCONSOLIDADO_LAC_USUARIOS 
						  WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
						  AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))
						  MINUS 
						  SELECT FDD_NIU FROM QA_TCONSOLIDADO_OR_USUARIOS 
						  WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
						  AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'))					  
						 );

	COMMIT;	
	
	--DIFERENCIA DE USUARIOS, USUARIOS SOLO EN EL OR
	INSERT INTO QA_TDIFERENCIA_USUARIOS
	SELECT LAC.FDD_YEAR
		  ,LAC.FDD_MES
		  ,LAC.FDD_NIU
		  ,LAC.FDD_CODIGOELEMENTO
		  ,LAC.FDD_GRUPOCALIDAD
		  ,LAC.FDD_NIVEL
		  ,LAC.FDD_TIEMPONETO 
		  ,LAC.FDD_ES_ALUMBRADO 
		  ,'Usuarios que solo existen en el consolidado del OR' AS FDD_OBSERVACIONES
	FROM QA_TCONSOLIDADO_LAC_USUARIOS LAC
	WHERE LAC.FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
	AND   LAC.FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'  ))
	AND   LAC.FDD_NIU IN (
						  SELECT FDD_NIU FROM QA_TCONSOLIDADO_OR_USUARIOS 
						  WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
						  AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'  ))
						  MINUS 
						  SELECT FDD_NIU FROM QA_TCONSOLIDADO_LAC_USUARIOS 
						  WHERE FDD_YEAR = TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY'))
						  AND   FDD_MES  = TO_NUMBER(TO_CHAR(FECHAOPERACION,'MM'  ))					  
						 )
	;
	COMMIT;	


	--FINALIZACION DEL PROCEDIMIENTO DE FORMA EXITOSA
	ESTADO := 1;   	
	INSERT INTO QA_TLOG_EJECUCION
	SELECT SYSDATE,'QA_PDIFERENCIAS_LAC_OR','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'EXITOSO','Se ha ejecutado correctamente...!' FROM DUAL;
	COMMIT;
  	
END QA_PDIFERENCIAS_LAC_OR;