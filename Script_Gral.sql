
SELECT * FROM QA_TTC1 qt ;

SELECT * FROM QA_TBRA11_REPORTE qtr ;

SELECT * FROM QA_TCOMPENSAR qt ;

SELECT * FROM QA_TTT12_REPORTE qtr ;

SELECT * FROM QA_TFDDREGISTRO qt
WHERE FDD_PERIODO_OP = DATE'2023-07-04';

SELECT * FROM QA_TLOG_EJECUCION
ORDER BY 1 DESC;


SELECT * FROM QA_TFDDREGISTRO
WHERE FDD_PERIODO_OP = DATE'2023-07-01'
--WHERE FDD_CODIGOEVENTO IN ('1009277','1010400') ;

SELECT * FROM QA_TTC1_TEMP qtt 
WHERE TC1_TC1 IN ('154298','1040382');


SELECT * FROM QA_TTT2_TEMP
WHERE TT2_CODIGOELEMENTO = '4T01967';

SELECT * FROM QA_TTT2_REGISTRO
WHERE TT2_CODIGOELEMENTO IN ('1T08618',	'1T00556',	'1T02673',	'1T10482',	'1T12267',	'5T00299',	'1T10895',	'SAC00000',	'4T01883',	'4T01884',	'4T01967',	'4T01969');

SELECT * FROM qa_ttt2_temp
WHERE TT2_CODIGOELEMENTO IN ('1T08618',	'1T12267',	'4T01883',	'4T01884',	'4T01967',	'4T01969');

SELECT * FROM qa_ttt2_obs WHERE TT2_CODIGOELEMENTO IN ('4T01884',	'4T01969',	'4T01967',	'4T01883 ');


  SELECT CODIGOEVENTO
		,MANIOBRA_APERTURA,
		,MANIOBRA_CIERRE
		,FECHA_INICIAL
		,FECHA_FINAL
		,CODIGOELEMENTO
		,TIPOELEMENTO
		,CAUSA
		,CONTINUIDAD
		  FROM ( --1.1 CARGA DIARIA DE EVENTOS NUEVOS 
		         SELECT  CODIGOEVENTO
						,MANIOBRA_APERTURA,
						,MANIOBRA_CIERRE
						,FECH_AINICIAL
						,FECHA_FINAL
						,CODIGOELEMENTO
						,TIPOELEMENTO
						,CAUSA
						,CONTINUIDAD
		        FROM OMS.INTERUPC
		        WHERE TRUNC(FECHA_INICIAL) = TRUNC(FECHAOPERACION)
		        
          UNION ALL --1.2 CARGA DE REGISTROS DE CIERRES 
          
		         SELECT  CODIGOEVENTO
						,MANIOBRA_APERTURA,
						,MANIOBRA_CIERRE
						,FECH_AINICIAL
						,FECHA_FINAL
						,CODIGOELEMENTO
						,TIPOELEMENTO
						,CAUSA
						,CONTINUIDAD
		        FROM OMS.INTERUPC
		        WHERE TRUNC(FECHA_FINAL) = TRUNC(FECHAOPERACION)		               
	      	);


SELECT * FROM QA_TTC1_TEMP;

SELECT DISTINCT TC1_TC1 FROM QA_TTC1
WHERE TC1_TC1 IN ('407624',	'486616',	'601226',	'640154',	'675264',	'1043997',	'1043997',	'1111480',	'1111494',	'1111497',	'1113297',	'1113566',	'1113569',	'1113570',	'1113570',	'1113574',	'1113582',	'1113583',	'1113584',	'1113585',	'1113588',	'1113589',	'1113619',	'1113620',	'1113621',	'1113624',	'1113624',	'1113625',	'1113626',	'1113628',	'1113629',	'1113630',	'1113631',	'1113636',	'1113637',	'1113638',	'1113640',	'1113641',	'1113642',	'1113645',	'1113729');


INSERT INTO QA_TTC1_TEMP
SELECT * FROM QA_TTC1
WHERE TC1_TC1 IN ('407624'
,'486616'
,'601226'
,'640154'
,'1043997'
)
AND TC1_PERIODO = 202305;

SELECT DISTINCT TC1_CODCONEX FROM QA_TTC1_TEMP
WHERE TC1_PERIODO = 202305
INTERSECT
SELECT DISTINCT TC1_CODCONEX FROM QA_TTC1 TEMP 
WHERE TC1_PERIODO = 202306;

SELECT DISTINCT TC1_CODCONEX, TC1_IUA FROM QA_TTC1_TEMP
WHERE TC1_PERIODO = 202306
AND TC1_CODCONEX IN (
					SELECT DISTINCT TC1_CODCONEX FROM QA_TTC1_TEMP
					WHERE TC1_PERIODO = 202305
					INTERSECT
					SELECT DISTINCT TC1_CODCONEX FROM QA_TTC1 TEMP 
					WHERE TC1_PERIODO = 202306
					);





SELECT * FROM QA_TTC1_TEMP
WHERE TC1_PERIODO = 202305;

SELECT COUNT(1) FROM QA_TTC1_TEMP;

SELECT COUNT(1) FROM QA_TTC1 WHERE TC1_PERIODO = 202306;

DELETE FROM QA_TTC1 
WHERE TC1_PERIODO = 202306;

INSERT INTO QA_TTC1 
SELECT * FROM QA_TTC1_TEMP;

SELECT * FROM QA_TTT2_REGISTRO;

SELECT TC1_TC1
      , TC1_CODCONEX
      , TT2_AP_POTENCIA AS TC1_POTENCIA
      , TC1_IDCOMER
      , TC1_CODDANE
      , MUND_DESCRIPCION
FROM QA_TTC1_TEMP 
LEFT OUTER JOIN (SELECT TT2_CODIGOELEMENTO
                       ,TT2_AP_POTENCIA
                 FROM QA_TTT2_BACKUP
                 WHERE TT2_ESTADO='OPERACION') ON TT2_CODIGOELEMENTO = TC1_CODCONEX
LEFT OUTER JOIN QA_TMUNDANE ON MUND_MUNDANE = SUBSTR(TC1_CODDANE,1,5)
WHERE TC1_TC1 LIKE 'CALP%'
;

SELECT * FROM ALL_TABLES
WHERE OWNER LIKE 'BRAE'
AND TABLE_NAME  LIKE 'QA_TTT2%';

SELECT * FROM QA_TTT2_CODIGO_UC;


CREATE TABLE BRAE.QA_TTT2_UNIDAD_CONSTRUCTIVA (
	 TT2_TIPO_SUBESTACION NUMBER
	,TT2_FASE_DESCRIPCION VARCHAR2(400)
	,TT2_POBLACION VARCHAR2(100)
	,TT2_CAPACIDAD NUMBER
	,TT2_UNIDAD_CONSTRUCTIVA VARCHAR2(20)
	,TT2_OBSERVACIONES VARCHAR2(100)
);

SELECT * FROM QA_TTT2_UNIDAD_CONSTRUCTIVA;



SELECT TT2_CODIGOELEMENTO,TT2_UNIDAD_CONSTRUCTIVA ,TT2_CODE_IUA, TT2_IUL, TT2_GRUPOCALIDAD  FROM QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'OPERACION'
AND TT2_CODIGOELEMENTO NOT IN (SELECT TT2_CODIGOELEMENTO FROM QA_TTT2_REGISTRO
							   WHERE TT2_ESTADO = 'RETIRADO')
UNION ALL 
SELECT TT2_CODIGOELEMENTO,TT2_UNIDAD_CONSTRUCTIVA ,TT2_CODE_IUA, TT2_IUL, TT2_GRUPOCALIDAD  FROM QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'RETIRADO'
;



SELECT TT2_CODIGOELEMENTO FROM QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'RETIRADO';

SELECT DISTINCT TC1_CODCONEX  FROM QA_TTC1_TEMP qtt 
WHERE TC1_CODCONEX IN ('4T01878',	'4T01877',	'4T01882',	'4T01881',	'1T00556',	'1T02673',	'1T10482',	'5T00299');

SELECT * FROM QA_TTC1_TEMP 
WHERE TC1_AUTOGEN = 3
AND TC1_TIPGENR = 1;


SELECT * FROM QA_TTC1_TEMP qtt
WHERE TC1_CONEXRED  = 'A';

COMMIT;


SELECT * FROM QA_TTC1_TEMP qtt 
WHERE TC1_TC1 IS NULL;


SELECT * FROM QA_TTC1_TEMP qtt ;




SELECT * FROM QA_TTC1_TEMP qtt 
WHERE TC1_AUTOGEN = 1;

SELECT *  FROM QA_TTT2_REGISTRO qtr ;

SELECT * FROM QA_TTC1 qt 
WHERE UPPER(TC1_CODFRONCOM) = 'FRT04088'
ORDER BY TC1_PERIODO DESC;



SELECT DISTINCT TT2_CODE_TRAFO FROM QA_TTT2_REPORTE
WHERE TO_CHAR(TT2_PERIODO_OP,'YYYY') = '2021'
AND TT2_ESTADO = 3;


--Script for transfors
SELECT COUNT(DISTINCT BRA11_CODIGOELEMENTO) 
FROM QA_TBRA11_REPORTE
LEFT OUTER JOIN (SELECT TT2_CODIGOELEMENTO, TT2_FASES 
				 FROM QA_TTT2_REGISTRO 
				 WHERE TT2_ESTADO = 'OPERACION'
				)
				ON BRA11_CODIGOELEMENTO = TT2_CODIGOELEMENTO 
WHERE TO_CHAR(BRA11_PERIODO_OP,'YYYY') = '2022'
AND BRA11_ESTADO = 3	
AND TT2_FASES IN ('S','T','R','SN','TN','RN');

SELECT DISTINCT BRA11_CODIGOELEMENTO 
FROM QA_TBRA11_REPORTE
WHERE TO_CHAR(BRA11_PERIODO_OP,'YYYY') = '2022'
AND BRA11_ESTADO = 3
;


CREATE OR REPLACE PROCEDURE BRAE.EMITE_BOOLEAN(VAR_ENTRADA IN NUMBER,VAR_SALIDA OUT NUMBER)
IS
BEGIN 
	VAR_SALIDA := VAR_ENTRADA;
END EMITE_BOOLEAN;	
/
	
--CALL
DECLARE
VAR_SALIDA NUMBER;
BEGIN
	EMITE_BOOLEAN(324,VAR_SALIDA);
	IF VAR_SALIDA = 1 THEN
		DBMS_OUTPUT.PUT_LINE('Valor ES 1');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Valor NO ES 1');
	END IF;
END;

/
SELECT * FROM QA_TFDDREGISTRO@BRAEPROD;



--------CONSOLIDADS LAC vs OR


SELECT TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'YYYY') AS FDD_YEAR
      ,TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'), 'MM') AS FDD_MONTH
      ,'CNSD' AS FDD_COD_ASIC
      ,FDD_CODIGOEVENTO AS FDD_CODIGOEVENTO
      ,FDD_CAUSA_CREG AS FDD_CAUSA_CREG
      ,FDD_IUA
      ,(case when FDD_TIPOELEMENTO = 'Transformer' then 1 else 0 end) AS FDD_TIPOELEMENTO
               ,ROUND((CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1) OR FDD_FFINAL IS NULL )
                     THEN
                      (
----------------------FDD_FFINAL ES MAYOR AL TIEMPO DE OPERACION O ES NULL
                         ((CASE WHEN (TRUNC(FDD_FINICIAL)<>(ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1)-1))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                        THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6)-- CASO 1
                                                  THEN (
                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                       + 6
                                                       + (ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2
                                                       )
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18)--CASO2
                                                             THEN (
                                                                   6
                                                                   + (ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2
                                                                   )
                                                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18)--CASO 3
                                                                        THEN (
                                                                             ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                             + (ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2
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
                                                                            (ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                            )
                                                                  END)
                                                       END)
                                             END)
                                        END))
----------------------
                      )
                     ELSE
                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')))
                        THEN
                           (
---------------------------FDD_FINICIAL ES MENOR AL TIEMPO DE OPERACION
                             ((CASE WHEN (TRUNC(FDD_FFINAL)<>(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'))))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                            THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 7
                                                      THEN (
                                                           (TRUNC(FDD_FFINAL)-TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')))*24/2
                                                           + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TRUNC(FDD_FFINAL))*24
                                                           )
                                                      ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO8
                                                                 THEN (
                                                                      (TRUNC(FDD_FFINAL)-TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')))*24/2
                                                                      + 6
                                                                      )
                                                                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 9
                                                                            THEN (
                                                                                 (TRUNC(FDD_FFINAL)-TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')))*24/2
                                                                                 + 6
                                                                                 + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-(TRUNC(FDD_FFINAL)+18/24))*24
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
               ,ROUND((CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1) OR FDD_FFINAL IS NULL )
                     THEN
                      (ADD_MONTHS(TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')),+1) - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
                     ELSE
                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')))
                        THEN
                           (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')))*24
                        ELSE
                         (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
                         END
                END),13) AS FDD_DURACION
      ,CANT_USERS AS FDD_USRS_AFECTADOS
FROM QA_TFDDREGISTRO
LEFT OUTER JOIN (
                select TC1_CODCONEX, count(TC1_CODCONEX) as CANT_USERS from QA_TTC1
                where TC1_PERIODO =  TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'YYYYMM')
                and TC1_CODCONEX not like 'ALPM%'
                and TC1_TIPCONEX = 'T'
                group by TC1_CODCONEX
) ON TC1_CODCONEX = FDD_CODIGOELEMENTO
LEFT OUTER JOIN (SELECT DISTINCT FDC_CAUSA_015, FDC_EXCLUSION FROM QA_TFDDCAUSAS) ON FDC_CAUSA_015 = FDD_CAUSA_CREG
WHERE (TO_CHAR(FDD_FINICIAL, 'MM/YYYY') = TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'MM/YYYY')
           OR TO_CHAR(FDD_FFINAL, 'MM/YYYY') = TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'MM/YYYY'))
AND FDC_EXCLUSION = 'NO EXCLUIDA'

UNION ALL

SELECT TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'YYYY') AS FDD_YEAR
      ,TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'), 'MM') AS FDD_MONTH
      ,'CNSD' AS FDD_COD_ASIC
      ,FDD_CODIGOEVENTO AS FDD_CODIGOEVENTO
      ,FDD_CAUSA_CREG AS FDD_CAUSA_CREG
      ,FDD_IUA
      ,(case when FDD_TIPOELEMENTO = 'Transformer' then 1 else 0 end) AS FDD_TIPOELEMENTO
      ,(ADD_MONTHS(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),+1) - TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'))*24/2 AS FDD_DUR_NOCTURNA
      ,(ADD_MONTHS(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),+1) - TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'))*24 AS FDD_DURACION
      ,CANT_USERS AS FDD_USRS_AFECTADOS
FROM QA_TFDDREGISTRO
LEFT OUTER JOIN (
                select TC1_CODCONEX, count(TC1_CODCONEX) as CANT_USERS from QA_TTC1
                where TC1_PERIODO =  TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'YYYYMM')
                and TC1_CODCONEX not like 'ALPM%'
                and TC1_TIPCONEX = 'T'
                group by TC1_CODCONEX
) ON TC1_CODCONEX = FDD_CODIGOELEMENTO
LEFT OUTER JOIN (SELECT DISTINCT FDC_CAUSA_015, FDC_EXCLUSION FROM QA_TFDDCAUSAS) ON FDC_CAUSA_015 = FDD_CAUSA_CREG
WHERE (  FDD_FINICIAL < TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')
AND (FDD_FFINAL >= ADD_MONTHS(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),+1) OR FDD_FFINAL IS NULL))
AND FDC_EXCLUSION = 'NO EXCLUIDA'
;


SELECT * FROM QA_TFDDREGISTRO WHERE FDD_CODIGOEVENTO = '787232';




SELECT * FROM ALL_TABLES
WHERE TABLE_NAME LIKE 'QA_TCON%';

SELECT MAX(FDD_YEAR) FROM QA_TCONSOLIDADO_SUI_USUARIOS;

SALES = '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=CENS-PO02)(PORT=1521)))
   (CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=SPARD)))';


   
CREATE DATABASE LINK BRAEPROD 
    CONNECT TO BRAE IDENTIFIED BY "Bra968*+-"
    USING '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=CENS-PO02)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=SPARD)))'
   ;   
   
 
CREATE DATABASE LINK BRAEPROD
CONNECT TO BRAE IDENTIFIED BY iKEjvbvP
USING '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=CENS-PO02)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=SPARD)))';


SELECT MAX(FDD_PERIODO_OP) FROM QA_TFDDREGISTRO@BRAEPROD;

SELECT TC1_PERIODO,COUNT(TC1_TC1) 
FROM QA_TTC1@BRAEPROD
WHERE SUBSTR(TC1_PERIODO,1,4) = 2021
GROUP BY TC1_PERIODO
;



SELECT FDD_CODIGOEVENTO ,FDD_CODIGOELEMENTO, FDD_IUA  , FDD_TIPOAJUSTE , FDD_RADICADO  
FROM qa_tfddregistro@BRAEPROD
WHERE TO_CHAR(FDD_PERIODO_OP,'YYYY') IN  ('2021','2020')
AND FDD_TIPOAJUSTE != 0;

SELECT * FROM QA_TFDDREGISTRO 
WHERE FDD_RADICADO = '2020062810739805';

SELECT * FROM ALL_TABLES
WHERE TABLE_NAME LIKE 'QA_TC%';



--•	Enero a Junio 2023 en orden de  mayor a menor por alimentador el UiTi o aporte en minutos al saidi.

SELECT TT1_NOMBRECIRCUITO, ROUND(SUM(UIXTI),2) AS UIXTI
FROM (
		SELECT CSX_PERIODO_OP, CSX_TRANSFOR, TT1_NOMBRECIRCUITO, CSX_DIU, CANT_USRS, (CANT_USRS * CSX_DIU) AS UIXTI 
		FROM QA_TCSX
		LEFT OUTER JOIN (
						SELECT TC1_PERIODO, TC1_CODCONEX, TC1_CODCIRC , COUNT(TC1_TC1) AS CANT_USRS
						FROM QA_TTC1
						WHERE TC1_CODCONEX NOT LIKE 'ALPM%'
						AND TC1_TIPCONEX = 'T'
						GROUP BY TC1_CODCONEX, TC1_PERIODO, TC1_CODCIRC
						) ON TC1_CODCONEX = CSX_TRANSFOR AND TC1_PERIODO = TO_NUMBER(TO_CHAR(CSX_PERIODO_OP,'YYYYMM'))
		LEFT OUTER JOIN QA_TTT1_REGISTRO ON TT1_CODIGOCIRCUITO = TC1_CODCIRC				
		WHERE TO_CHAR(CSX_PERIODO_OP,'MMYYYY') IN ('012023','022023','032023','042023','052023','062023')
	 )
WHERE UIXTI != 0
GROUP BY TT1_NOMBRECIRCUITO
ORDER BY UIXTI DESC
;


--•	Enero a Junio 2023 en orden de  mayor a menor por reconectador el UiTi o aporte en minutos al saidi.
SELECT RECONECTADOR, ROUND(SUM(UIXTI),2) AS UIXTI
FROM(
	SELECT REG.FDD_CODIGOEVENTO 
			,(TO_DATE(TO_CHAR(REG.FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') -
			  TO_DATE(TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')) * 24 AS DURACION 
			, TIP.BREAKER AS RECONECTADOR
			, REG.FDD_CODIGOELEMENTO
			, TC.CANT_USRS
			, TC.CANT_USRS * ((TO_DATE(TO_CHAR(REG.FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') -
			  TO_DATE(TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')) * 24) AS UIXTI
	FROM QA_TFDDREGISTRO REG
	LEFT OUTER JOIN            (
								SELECT M.CODE AS MANIOBRA, TIPOS.BREAKER, TIPOS.TIPO_BREAKER
								FROM OMS.MANIOBRAS M
								LEFT OUTER JOIN (
												SELECT CODE AS BREAKER, 'CABECERA_CIRCUITO' AS TIPO_BREAKER, DESCRIPTIO AS DIRECCION, CODE AS CIRCUITO FROM OMS.FEEDERS
												UNION ALL
												SELECT CODE, 'RECONECTADOR_RED', ADDRESS, FPARENT FROM OMS.RECLOSER
												UNION ALL
												SELECT CODE, (CASE WHEN(TYPE = 1 ) THEN 'CORTACIRCUITO' 
												                   WHEN(TYPE = 2 ) THEN 'CUCHILLAS' 
												                   WHEN(TYPE = 3  OR TYPE = 4  ) THEN 'SECCIONADOR' 
												                   WHEN(TYPE = 11 OR TYPE = 12 ) THEN 'INTERRUPTOR' 
												                   WHEN(TYPE = 14) THEN 'CORTACIRCUITO_REPETICION' 
												                   ELSE 'ESTANDAR'
												              END) , ADDRESS, FPARENT FROM OMS.SWITCHES
												UNION ALL
												SELECT ELNODE, 'TRANSFORMADOR', ADDRESS, FPARENT FROM OMS.TRANSFOR
												UNION ALL
												SELECT INTERRUP1, 'HVTRANS_HEREDADO', NODO1||'|'||NODO2, 'CTO_P' FROM OMS.HVTRANS WHERE INTERRUP1 IS NOT NULL
												UNION ALL
												SELECT INTERRUP2, 'HVTRANS_HEREDADO', NODO1||'|'||NODO2, 'CTO_P' FROM OMS.HVTRANS WHERE INTERRUP2 IS NOT NULL
												UNION ALL
												SELECT INTERRUP1, 'HVLINSEC_HEREDADO', ELNODE1||'|'||ELNODE2, 'CTO_P' FROM OMS.HVLINSEC WHERE INTERRUP1 IS NOT NULL
												UNION ALL
												SELECT INTERRUP2, 'HVLINSEC_HEREDADO', ELNODE1||'|'||ELNODE2, 'CTO_P' FROM OMS.HVLINSEC WHERE INTERRUP2 IS NOT NULL
												) TIPOS ON TIPOS.BREAKER = M.BREAKER
								WHERE TIPOS.TIPO_BREAKER = 'RECONECTADOR_RED'
								AND M.ESTADO = 0
							  ) TIP ON TIP.MANIOBRA = REG.FDD_CODIGOEVENTO
	LEFT OUTER JOIN (
					SELECT TC1_PERIODO, TC1_CODCONEX, COUNT(TC1_TC1) AS CANT_USRS
					FROM QA_TTC1
					WHERE TC1_CODCONEX NOT LIKE 'ALPM%'
					AND TC1_TIPCONEX = 'T'
					GROUP BY TC1_CODCONEX, TC1_PERIODO
					) TC ON TC.TC1_CODCONEX = REG.FDD_CODIGOELEMENTO AND TC1_PERIODO = TO_NUMBER(TO_CHAR(REG.FDD_FINICIAL ,'YYYYMM'))
	WHERE TO_CHAR(REG.FDD_FINICIAL,'MMYYYY') IN ('012023','022023','032023','042023','052023','062023')
	AND REG.FDD_FFINAL IS NOT NULL
	AND TIP.BREAKER IS NOT NULL
	)
GROUP BY RECONECTADOR
ORDER BY 2 DESC
;			
		
--•	Enero a Junio 2023 en orden de  mayor a menor por arranque el UiTi o aporte en minutos al saidi.
SELECT ARRANQUE, ROUND(SUM(UIXTI),2) AS UIXTI, COUNT(DISTINCT FDD_CODIGOEVENTO) AS FRECUENCIA
FROM(
	SELECT REG.FDD_CODIGOEVENTO 
			,(TO_DATE(TO_CHAR(REG.FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') -
			  TO_DATE(TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')) * 24 AS DURACION 
			, TIP.BREAKER AS ARRANQUE
			, REG.FDD_CODIGOELEMENTO
			, TC.CANT_USRS
			, TC.CANT_USRS * ((TO_DATE(TO_CHAR(REG.FDD_FFINAL  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') -
			  TO_DATE(TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')) * 24) AS UIXTI
	FROM QA_TFDDREGISTRO REG
	LEFT OUTER JOIN            (
								SELECT M.CODE AS MANIOBRA, TIPOS.BREAKER, TIPOS.TIPO_BREAKER
								FROM OMS.MANIOBRAS M
								LEFT OUTER JOIN (
												SELECT CODE AS BREAKER, 'CABECERA_CIRCUITO' AS TIPO_BREAKER, DESCRIPTIO AS DIRECCION, CODE AS CIRCUITO FROM OMS.FEEDERS
												UNION ALL
												SELECT CODE, 'RECONECTADOR_RED', ADDRESS, FPARENT FROM OMS.RECLOSER
												UNION ALL
												SELECT CODE, (CASE WHEN(TYPE = 1 ) THEN 'CORTACIRCUITO' 
												                   WHEN(TYPE = 2 ) THEN 'CUCHILLAS' 
												                   WHEN(TYPE = 3  OR TYPE = 4  ) THEN 'SECCIONADOR' 
												                   WHEN(TYPE = 11 OR TYPE = 12 ) THEN 'INTERRUPTOR' 
												                   WHEN(TYPE = 14) THEN 'CORTACIRCUITO_REPETICION' 
												                   ELSE 'ESTANDAR'
												              END) , ADDRESS, FPARENT FROM OMS.SWITCHES
												UNION ALL
												SELECT ELNODE, 'TRANSFORMADOR', ADDRESS, FPARENT FROM OMS.TRANSFOR
												UNION ALL
												SELECT INTERRUP1, 'HVTRANS_HEREDADO', NODO1||'|'||NODO2, 'CTO_P' FROM OMS.HVTRANS WHERE INTERRUP1 IS NOT NULL
												UNION ALL
												SELECT INTERRUP2, 'HVTRANS_HEREDADO', NODO1||'|'||NODO2, 'CTO_P' FROM OMS.HVTRANS WHERE INTERRUP2 IS NOT NULL
												UNION ALL
												SELECT INTERRUP1, 'HVLINSEC_HEREDADO', ELNODE1||'|'||ELNODE2, 'CTO_P' FROM OMS.HVLINSEC WHERE INTERRUP1 IS NOT NULL
												UNION ALL
												SELECT INTERRUP2, 'HVLINSEC_HEREDADO', ELNODE1||'|'||ELNODE2, 'CTO_P' FROM OMS.HVLINSEC WHERE INTERRUP2 IS NOT NULL
												) TIPOS ON TIPOS.BREAKER = M.BREAKER
								WHERE TIPOS.TIPO_BREAKER LIKE 'CORTACIRCUITO%'
								AND M.ESTADO = 0
							  ) TIP ON TIP.MANIOBRA = REG.FDD_CODIGOEVENTO
	LEFT OUTER JOIN (
					SELECT TC1_PERIODO, TC1_CODCONEX, COUNT(TC1_TC1) AS CANT_USRS
					FROM QA_TTC1
					WHERE TC1_CODCONEX NOT LIKE 'ALPM%'
					AND TC1_TIPCONEX = 'T'
					GROUP BY TC1_CODCONEX, TC1_PERIODO
					) TC ON TC.TC1_CODCONEX = REG.FDD_CODIGOELEMENTO AND TC1_PERIODO = TO_NUMBER(TO_CHAR(REG.FDD_FINICIAL ,'YYYYMM'))
	WHERE TO_CHAR(REG.FDD_FINICIAL,'MMYYYY') IN ('012023','022023','032023','042023','052023','062023')
	AND REG.FDD_FFINAL IS NOT NULL
	AND TIP.BREAKER IS NOT NULL
	)
GROUP BY ARRANQUE
ORDER BY 2 DESC
;			


--•	Enero a Junio 2023 en orden de  mayor a menor por Transformador UiTi o aporte en minutos al saidi.

SELECT CSX_TRANSFOR, ROUND(SUM(UIXTI),2) AS UIXTI
FROM (
		SELECT CSX_PERIODO_OP, CSX_TRANSFOR, CSX_DIU, CANT_USRS, (CANT_USRS * CSX_DIU) AS UIXTI 
		FROM QA_TCSX
		LEFT OUTER JOIN (
						SELECT TC1_PERIODO, TC1_CODCONEX, COUNT(TC1_TC1) AS CANT_USRS
						FROM QA_TTC1
						WHERE TC1_CODCONEX NOT LIKE 'ALPM%'
						AND TC1_TIPCONEX = 'T'
						GROUP BY TC1_CODCONEX, TC1_PERIODO
						) ON TC1_CODCONEX = CSX_TRANSFOR AND TC1_PERIODO = TO_NUMBER(TO_CHAR(CSX_PERIODO_OP,'YYYYMM'))
		WHERE TO_CHAR(CSX_PERIODO_OP,'MMYYYY') IN ('012023','022023','232023','042023','052023','062023')
)
WHERE UIXTI != 0
GROUP BY CSX_TRANSFOR
ORDER BY UIXTI DESC
;

SELECT COUNT(1) FROM QA_TTC1
WHERE TC1_PERIODO = 202101;


SELECT * FROM QA_TCS1
WHERE CS1_PERIODO_OP = DATE'2021-03-01';


SELECT DISTINCT TO_CHAR(FDD_FINICIAL,'YYYYMM') AS PERIODO , FDD_RADICADO  FROM QA_TFDDREGISTRO
WHERE FDD_RADICADO != 'NA'
ORDER BY 1;


SELECT LENGTH('SLKFJSALJF')
FROM DUAL;




SELECT DISTINCT(TO_CHAR(TT2_PERIODO_OP ,'YYYY')) FROM QA_TTT2_REGISTRO;


SELECT * FROM ALL_TABLES@BRAEPROD
WHERE TABLE_NAME LIKE 'QA_TTT2%';

SELECT * FROM QA_TTC1_DIVIPOLA
WHERE TC1_COD_MUNICIPIO LIKE '54261%';


SELECT * FROM QA_TTT2_UNIDAD_CONSTRUCTIVA@BRAEPROD;

SELECT * FROM QA_TFDDREGISTRO_AI;


		    SELECT REG.FDD_CODIGOEVENTO
							,REG.FDD_FINICIAL
							,REG.FDD_FFINAL
							,REG.FDD_CODIGOELEMENTO
							,'Transformer' AS FDD_TIPOELEMENTO
							,NULL AS FDD_CONSUMODIA        --RECALCULADO POR EL PL
							,NULL AS FDD_ENS_ELEMENTO      --RECALCULADO POR EL PL
							,NULL AS FDD_ENS_EVENTO        --RECALCULADO POR EL PL
							,NULL AS FDD_ENEG_EVENTO       --RECALCULADO POR EL PL
							,NULL AS FDD_ENEG_ELEMENTO     --RECALCULADO POR EL PL
							,NULL AS FDD_CODIGOGENERADOR   --RECALCULADO POR EL PL
							,REG.FDD_CAUSA
							,NULL AS FDD_CAUSA_CREG        --RECALCULADO POR EL PL
							,'N' AS FDD_USUARIOAP          --LO RECTIFICA EL PL
							,REG.FDD_CONTINUIDAD
							,'N' AS FDD_ESTADOREPORTE
							,'N' AS FDD_PUBLICADO
							,'N' AS FDD_RECONFIG
							,TO_DATE(:FECHAOPERACION,'DD/MM/YYYY') AS FDD_PERIODO_OP
							,SYSDATE AS FDD_FREG_APERTURA
							,REG.FDD_FREG_CIERRE
							,NULL AS FDD_FPUB_APERTURA
							,NULL AS FDD_FPUB_CIERRE
                            ,TO_NUMBER(0) AS FDD_PERIODO_TC1
							,REG.FDD_TIPOCARGA
							,NULL AS FDD_EXCLUSION         --RECALCULADO POR EL PL
							,NULL AS FDD_CAUSA_SSPD        --RECALCULADO POR EL PL
							,'N'  AS FDD_AJUSTADO
							,'0'  AS FDD_TIPOAJUSTE
							,'NA' AS FDD_RADICADO
							,'NA' AS FDD_APROBADO
							,NULL AS FDD_IUA               --RECALCULADO POR EL PL
		  --BULK COLLECT INTO V_QA_TFDDREGISTRO
		  FROM ( --1.1 CARGA DIARIA DE REGISTROS NUEVOS DR
		         SELECT  I.MINICIAL AS FDD_CODIGOEVENTO,
		                (CASE WHEN I.FINICIAL<TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) THEN NULL ELSE TO_TIMESTAMP(TO_CHAR(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MI.FECHAMS<0) THEN(0) ELSE(MI.FECHAMS) END)),3,'0')),'DD/MM/YYYY hh24:mi:ss.FF3') END) AS FDD_FINICIAL,
		                (CASE WHEN I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 THEN NULL ELSE TO_TIMESTAMP(CASE WHEN I.FFINAL IS NULL THEN NULL ELSE TO_CHAR(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MF.FECHAMS<0) THEN(0) ELSE(MF.FECHAMS) END)),3,'0')) END,'DD/MM/YYYY hh24:mi:ss.FF3') END) AS FDD_FFINAL,
		                I.TRAFO AS FDD_CODIGOELEMENTO,
		                MI.CAUSA AS FDD_CAUSA,
		                (CASE WHEN (I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 OR I.FFINAL IS NULL) THEN 'S'           ELSE 'N'           END) AS FDD_CONTINUIDAD,
		                (CASE WHEN (I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 OR I.FFINAL IS NULL) THEN NULL ELSE SYSDATE END) AS FDD_FREG_CIERRE,
		                'DR' AS FDD_TIPOCARGA
		        FROM OMS.INTERUPC I
		        LEFT OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL
		        LEFT OUTER JOIN OMS.MANIOBRAS MF ON MF.CODE = I.MFINAL
		        LEFT OUTER JOIN OMS.CAUSAS CS ON CS.CODE = MI.CAUSA
                LEFT OUTER JOIN QA_TFDDREGISTRO R ON (R.FDD_CODIGOEVENTO = I.MINICIAL AND R.FDD_CODIGOELEMENTO = I.TRAFO)
		        WHERE MI.CAUSA <> 'PRUEBA'
		        AND MI.TIPO <> 'PRUEBA' ---REVISA ENERGY
		        AND MI.EJECUTADO = 1
		        AND I.TYPEEQUIP IN ('Transformer')
                AND R.FDD_CODIGOEVENTO IS NULL --CONDICION PARA NUEVOS REGISTROS  
                AND ((I.FINICIAL >= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) AND I.FINICIAL < TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) + 1)
		              --OR (I.FFINAL >= TRUNC(FECHAOPERACION) AND I.FFINAL < TRUNC(FECHAOPERACION) + 1)
                    )
          UNION ALL --1.2 CARGA DE CIERRES DR
		         SELECT  I.MINICIAL AS FDD_CODIGOEVENTO,
		                 NULL AS FDD_FINICIAL,
		                (CASE WHEN I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 THEN NULL ELSE TO_TIMESTAMP(CASE WHEN I.FFINAL IS NULL THEN NULL ELSE TO_CHAR(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MF.FECHAMS<0) THEN(0) ELSE(MF.FECHAMS) END)),3,'0')) END,'DD/MM/YYYY hh24:mi:ss.FF3') END) AS FDD_FFINAL,
		                I.TRAFO AS FDD_CODIGOELEMENTO,
		                MI.CAUSA AS FDD_CAUSA,
		                (CASE WHEN (I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 OR I.FFINAL IS NULL) THEN 'S'           ELSE 'N'           END) AS FDD_CONTINUIDAD,
		                (CASE WHEN (I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 OR I.FFINAL IS NULL) THEN NULL ELSE SYSDATE END) AS FDD_FREG_CIERRE,
		                'DR' AS FDD_TIPOCARGA
		        FROM OMS.INTERUPC I
		        LEFT OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL
		        LEFT OUTER JOIN OMS.MANIOBRAS MF ON MF.CODE = I.MFINAL
		        LEFT OUTER JOIN OMS.CAUSAS CS ON CS.CODE = MI.CAUSA
                LEFT OUTER JOIN QA_TFDDREGISTRO R ON (R.FDD_CODIGOEVENTO = I.MINICIAL AND R.FDD_CODIGOELEMENTO = I.TRAFO)
		        WHERE MI.CAUSA <> 'PRUEBA'
		        AND MI.TIPO <> 'PRUEBA' ---REVISA ENERGY
		        AND MI.EJECUTADO = 1
		        AND I.TYPEEQUIP IN ('Transformer')
                AND R.FDD_CODIGOEVENTO IS NOT NULL AND R.FDD_FFINAL IS NULL --CONDICION PARA CIERRES DE EVENTOS DR
                AND (--(I.FINICIAL >= TRUNC(FECHAOPERACION) AND I.FINICIAL < TRUNC(FECHAOPERACION) + 1) OR
		               (I.FFINAL >= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) AND I.FFINAL < TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) + 1)) 
		  UNION ALL --2. CARGA DE CIERRES TARDIOS
		        SELECT  I.MINICIAL AS FDD_CODIGOEVENTO,
		                NULL AS FDD_FINICIAL,
		                TO_DATE(:FECHAOPERACION,'DD/MM/YYYY') + (1/86400) AS FDD_FFINAL,
		                --TO_TIMESTAMP(CASE WHEN I.FFINAL IS NULL THEN NULL ELSE TO_CHAR(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MF.FECHAMS<0) THEN(0) ELSE(MF.FECHAMS) END)),3,'0')) END,'DD/MM/YYYY hh24:mi:ss.FF3') AS FDD_FFINAL,
		                I.TRAFO AS FDD_CODIGOELEMENTO,
		                MI.CAUSA AS FDD_CAUSA,
		                (CASE WHEN (I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 OR I.FFINAL IS NULL) THEN 'S'           ELSE 'N'           END) AS FDD_CONTINUIDAD,
		                (CASE WHEN (I.FFINAL>=TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'))+1 OR I.FFINAL IS NULL) THEN NULL ELSE SYSDATE END) AS FDD_FREG_CIERRE,
		                'DR' AS FDD_TIPOCARGA
		        FROM OMS.INTERUPC I
		        LEFT OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL
		        LEFT OUTER JOIN OMS.MANIOBRAS MF ON MF.CODE = I.MFINAL
		        LEFT OUTER JOIN OMS.CAUSAS CS ON CS.CODE = MI.CAUSA
		        WHERE MI.CAUSA <> 'PRUEBA'
		        AND MI.TIPO <> 'PRUEBA' ---REVISA ENERGY
		        AND MI.EJECUTADO = 1
		        AND I.TYPEEQUIP IN ('Transformer')
		        AND (I.FFINAL >= TO_DATE('01/'||TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'),'MM/YYYY'),'DD/MM/YYYY') AND I.FFINAL < TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')))
		        AND I.MINICIAL||I.TRAFO IN (SELECT FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO FROM QA_TFDDREGISTRO WHERE FDD_FFINAL IS NULL)
		  UNION ALL --3. CARGA DE REGISTROS NR
            SELECT  I.MINICIAL AS FDD_CODIGOEVENTO
                    ,TO_TIMESTAMP(TO_CHAR(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MI.FECHAMS<0) THEN(0) ELSE(MI.FECHAMS) END)),3,'0')),'DD/MM/YYYY hh24:mi:ss.FF3') AS FDD_FINICIAL
                    ,(CASE WHEN I.FFINAL>=TO_DATE(:FECHAOPERACION,'DD/MM/YYYY') + 1 THEN NULL ELSE TO_TIMESTAMP(CASE WHEN I.FFINAL IS NULL THEN NULL ELSE TO_CHAR(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss')||'.'||LPAD(TO_CHAR((CASE WHEN (MF.FECHAMS<0) THEN(0) ELSE(MF.FECHAMS) END)),3,'0')) END,'DD/MM/YYYY hh24:mi:ss.FF3') END) AS FDD_FFINAL
                    ,I.TRAFO AS FDD_CODIGOELEMENTO
                    ,MI.CAUSA AS FDD_CAUSA
                    ,(CASE WHEN (I.FFINAL>=TO_DATE(:FECHAOPERACION,'DD/MM/YYYY') + 1 OR I.FFINAL IS NULL) THEN 'S'  ELSE 'N'           END) AS FDD_CONTINUIDAD
                    ,(CASE WHEN (I.FFINAL>=TO_DATE(:FECHAOPERACION,'DD/MM/YYYY') + 1 OR I.FFINAL IS NULL) THEN NULL ELSE SYSDATE END) AS FDD_FREG_CIERRE
                    ,'NR' AS FDD_TIPOCARGA
              FROM  OMS.INTERUPC I
              LEFT  OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL
              LEFT  OUTER JOIN OMS.MANIOBRAS MF ON MF.CODE = I.MFINAL
              LEFT  OUTER JOIN QA_TFDDREGISTRO R ON (R.FDD_CODIGOEVENTO = I.MINICIAL AND R.FDD_CODIGOELEMENTO = I.TRAFO)
              WHERE MI.CAUSA <> 'PRUEBA'
              AND   MI.TIPO  <> 'PRUEBA'
              AND   MI.EJECUTADO = 1
              AND   I.TYPEEQUIP IN ('Transformer')
              AND   (    I.FINICIAL >= TO_DATE('01/'||TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY'),'MM/YYYY'),'DD/MM/YYYY')
                     AND I.FINICIAL <  TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')
                    )
              AND   R.FDD_CODIGOEVENTO IS NULL
		        ) REG
		      WHERE REG.FDD_CODIGOEVENTO = '1021770';




SELECT * FROM QA_TFDDREGISTRO
WHERE FDD_CODIGOEVENTO =  '1021519';

SELECT * FROM QA_TTC1 
WHERE TC1_PERIODO = 202305
AND TC1_CODCONEX = '1T09039';

SELECT * FROM QA_TFDDAJUSTES qt 
WHERE FDR_PERIODO_OP = DATE'2023-06-01';

SELECT * FROM ALL_TABLES
WHERE TABLE_NAME LIKE 'QA_TFDD%';

SELECT TRUNC(SYSDATE) + 24 / 24  FROM DUAL;


    SELECT I.MINICIAL      AS FDD_CODIGOEVENTO
          ,I.FINICIAL      AS FDD_FINICIAL
          ,I.FFINAL        AS FDD_FFINAL
          ,M.DESCRIPTIO    AS FDD_DECRIPCION
          ,'A'             AS FDD_CAUSANTE_AFECTADO
          ,I.TRAFO         AS FDD_CODIGOELEMENTO
          ,'1'             AS FDD_TIPOELEMENTO
          ,C.FDC_CAUSA_015 AS FDD_CAUSA_CREG
          ,SYSDATE         AS FDD_FESTIMADA --RECIBIR POR INTERFACE COMO DATO DE ENTRADA
          ,CANT_USRS       AS FDD_AFECTADOS
          ,NULL            AS FDD_AFECTADOS_TOTALES --REALIZADA POR PROCEDIMIENTO
    FROM OMS.INTERUPC I
    LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
    LEFT OUTER JOIN BRAE.QA_TFDDCAUSAS C ON C.FDC_CAUSA_OMS = M.CAUSA
    LEFT OUTER JOIN (
                     SELECT  TC1_CODCONEX,COUNT(TC1_CODCONEX) AS CANT_USRS
                     FROM QA_TTC1 
                     WHERE TC1_PERIODO = 202306 --MAX_PERIODO_TC1
                     GROUP BY TC1_CODCONEX
                     ) ON TC1_CODCONEX = I.TRAFO
    WHERE TRUNC(FINICIAL) = TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) 
    --WHERE TRUNC(FINICIAL) >= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) - 04 / 24
    --AND   TRUNC(FINICIAL) <= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) + 24 / 24
    AND M.TIPO <> 'PRUEBA' 
    AND M.EJECUTADO = 1
    AND I.TYPEEQUIP IN ('Transformer')
    AND TC1_CODCONEX IS NOT NULL
    ;
   /
   
   BEGIN
	   QA_PTT2_REGISTRO(DATE'2023-07-01');
   END;
   
  
     SELECT CON.NODO_TRANSFORM_V,TO_NUMBER(LUM.POTENCIA) AS LONGITUD--,REGEXP_REPLACE(LUM.POTENCIA, '[0-9]', '') AS cadena --  SUBSTR(CON.NODO_TRANSFORM_V,1,20) AS NODO_TRANSFORM_V,SUM(LUM.POTENCIA) AS POTENCIA_INSTALADA
	 FROM CCONECTIVIDAD_E@GTECH CON
	 JOIN CCOMUN@GTECH COM ON CON.G3E_FID = COM.G3E_FID
	 JOIN ELUMINAR_AT@GTECH LUM ON  LUM.G3E_FID = CON.G3E_FID
	 WHERE CON.G3E_FNO = 21400   
	 AND CON.NODO_TRANSFORM_V IS NOT NULL
	 --AND REGEXP_REPLACE(LUM.POTENCIA, '[0-9]', '') NOT IN ('.')
	 ;--GROUP BY CON.NODO_TRANSFORM_V;

        SELECT  SUBSTR(CON.NODO_TRANSFORM_V,1,20) AS NODO_TRANSFORM_V, SUM(LUM.POTENCIA) AS POTENCIA_INSTALADA
         FROM CCONECTIVIDAD_E@GTECH CON
         JOIN CCOMUN@GTECH COM ON CON.G3E_FID=COM.G3E_FID
         JOIN ELUMINAR_AT@GTECH LUM ON  LUM.G3E_FID = CON.G3E_FID
         WHERE CON.G3E_FNO = 21400
         AND CON.NODO_TRANSFORM_V IS NOT NULL
         GROUP BY CON.NODO_TRANSFORM_V;

         SELECT  SUBSTR(CON.NODO_TRANSFORM_V,1,20) AS NODO_TRANSFORM_V,SUM(TO_NUMBER(TRIM(REPLACE(LUM.POTENCIA,'.',',')))) AS POTENCIA_INSTALADA
         FROM CCONECTIVIDAD_E@GTECH CON
         JOIN CCOMUN@GTECH COM ON CON.G3E_FID=COM.G3E_FID
         JOIN ELUMINAR_AT@GTECH LUM ON  LUM.G3E_FID = CON.G3E_FID
         WHERE CON.G3E_FNO = 21400
         AND  COM.ESTADO <> 'RETIRADO' 
         GROUP BY CON.NODO_TRANSFORM_V;
        

        
         SELECT *-- SUBSTR(CON.NODO_TRANSFORM_V,1,20) AS NODO_TRANSFORM_V,LUM.POTENCIA AS POTENCIA_INSTALADA
         FROM CCONECTIVIDAD_E@GTECH CON
         JOIN CCOMUN@GTECH COM ON CON.G3E_FID=COM.G3E_FID
         JOIN ELUMINAR_AT@GTECH LUM ON  LUM.G3E_FID = CON.G3E_FID
         WHERE CON.G3E_FNO = 21400
         AND NODO_TRANSFORM_V IS NULL
         --AND CON.ESTADO = 'RETIRADO';
;

DELETE FROM QA_TTT2_TEMP;
COMMIT;

INSERT INTO QA_TTT2_TEMP
         WITH INFO_AP AS
        (SELECT  SUBSTR(CON.NODO_TRANSFORM_V,1,20) AS NODO_TRANSFORM_V,SUM(TO_NUMBER(TRIM(REPLACE(LUM.POTENCIA,'.',',')))) AS POTENCIA_INSTALADA
         FROM CCONECTIVIDAD_E@GTECH CON
         JOIN CCOMUN@GTECH COM ON CON.G3E_FID=COM.G3E_FID
         JOIN ELUMINAR_AT@GTECH LUM ON  LUM.G3E_FID = CON.G3E_FID
         WHERE CON.G3E_FNO = 21400
         AND  COM.ESTADO <> 'RETIRADO'
         GROUP BY CON.NODO_TRANSFORM_V)

        SELECT SUBSTR(CON.NODO_TRANSFORM_V,1,20)          AS TT2_CODIGOELEMENTO
            ,NULL                                         AS TT2_CODE_IUA --GESTIONADO POR PROCEDIMIENTO
            ,SUBSTR(COM.GRUPO_CALIDAD,1,2)                AS TT2_GRUPOCALIDAD
            ,SUBSTR(COM.ID_MERCADO,1,20)                  AS TT2_IDMERCADO
            ,TO_NUMBER(CON.CAPACIDAD_NOMINAL)             AS TT2_CAPACIDAD_TRAFO
            ,SUBSTR(CPRO.PROPIETARIO_1,1,20)              AS TT2_PROPIEDAD
            ,TO_NUMBER(ET.TIPO_SUBESTACION)               AS TT2_TSUBESTACION
            ,REPLACE(TRIM(COM.COOR_GPS_LON),',','.')      AS TT2_LONGITUD
            ,REPLACE(TRIM(COM.COOR_GPS_LAT),',','.')      AS TT2_LATITUD
            ,TO_NUMBER(COM.COOR_Z)                        AS TT2_ALTITUD
            ,COM.ESTADO                                   AS TT2_ESTADO
            ,(CASE WHEN(ET.PROVISIONAL = 'SI')
                   THEN('PLANEACION'         )
                   ELSE(COM.ESTADO           )
              END)                                        AS TT2_ESTADO_BRA11
            ,'015-2018'                                   AS TT2_RESMETODOLOGIA
            ,'0'                                          AS TT2_CLASS_CARGA
            ,SUBSTR(CON.CIRCUITO,1,20)                    AS TT2_NOMBRE_CIRCUITO
            ,SUBSTR(TT1.TT1_CODIGOCIRCUITO,1,5)           AS TT2_IUL
            ,NULL                                         AS TT2_CODIGOPROYECTO --INDEFINIDO
            ,NULL                                         AS TT2_UNIDAD_CONSTRUCTIVA
            ,DECODE(CPRO.PROPIETARIO_1,'ESTADO',1,0)      AS TT2_RPP
            ,DECODE(COM.SALINIDAD, 'SI', '1', '2')        AS TT2_SALINIDAD
            ,(CASE WHEN (COM.TIPO_PROYECTO = 'T4')
                   THEN ('T4'                    )
                   ELSE (NULL                    )
              END)                                        AS TT2_TIPOINVERSION -- CONFIGURADO POR PROCEDIMIENTO
            ,2                                            AS TT2_REMUNERACION_PENDIENTE
            ,DECODE
              (DECODE(ET.PROVISIONAL,'SI','PLANEACION',COM.ESTADO)
                       ,'PLANEACION','INVA'
                       ,'OPERACION','BRAEN'
                       ,'RETIRADO','BRAFO'
               )                                          AS TT2_ALTERNATIVA_VALORACION
            ,NULL                                         AS TT2_ID_PLAN
            ,0                                            AS TT2_CANTIDAD_REPOSICIONES --GESTIONADO POR PROCEDIMIENTO
            ,COM.FECHA_OPERACION                          AS TT2_FESTADO --FECHA MANUAL DE OPERACION DEL ACTIVO
            ,COM.FECHA_COLOCACION                         AS TT2_FCOLOCACION -- FECHA SISTEMA DE CREACION DE ACTIVO
            ,COM.FECHA_MODIFICACION                       AS TT2_FMODIFICACION --FECHA SISTEMA DE MODIFICACION DE ACTIVO
            ,COM.USUARIO_COLOCACION                       AS TT2_USR_COLOCACION --PERS
            ,COM.USUARIO_MODIFICACION                     AS TT2_USR_MODFICACION
            ,TRUNC(TO_DATE('01/07/2023','DD/MM/YYYY')) AS TT2_PERIODO_OP
            ,0                                            AS TT2_ESTADOREPORTE
            ,SYSDATE                                      AS TT2_FSISTEMA
            ,0                                            AS TT2_ACTIVOCONEXION --PENDIENTE TRAER DEL SISTEMA GTECH
            ,(CASE WHEN ET.PROVISIONAL='SI'
                   THEN 1
                   ELSE 0
              END)                                        AS TT2_ACTIVOPROVISIONAL --PENDIENTE TRAER DEL SISTEMA
            ,NVL(AP.POTENCIA_INSTALADA,0)                 AS TT2_AP_POTENCIA
            ,0                                            AS TT2_CODE_CALP
            ,CON.FASES                                    AS TT2_FASES
            ,COM.CLASIFICACION_MERCADO                    AS TT2_POBLACION
            ,NULL                                         AS TT2_VALOR_UC
            ,NULL                                         AS TT2_OBSERVACIONES
            ,CON.LOCALIZACION                             AS TT2_LOCALIZACION
            ,COM.MUNICIPIO                                AS TT2_MUNICIPIO
            ,COM.DEPARTAMENTO                             AS TT2_DEPARTAMENTO
            ,/*TO_NUMBER(CON.TENSION)*/ 0                      AS TT2_NT_PRIMARIA
            ,/*TO_NUMBER(CON.TENSION_SECUNDARIA)*/ 0            AS TT2_NT_SECUNDARIA
            ,0                                            AS TT2_ACTIVONR
            ,COM.G3E_FID                                  AS TT2_G3E_FID
            ,COM.FID_ANTERIOR                             AS TT2_FID_ANTERIOR
        --BULK COLLECT INTO   V_QA_TTT2_REGISTRO
        FROM                CCONECTIVIDAD_E@GTECH  CON
            LEFT OUTER JOIN CCOMUN@GTECH           COM  ON  COM.G3E_FID            = CON.G3E_FID
            LEFT OUTER JOIN ETRANSFO_AT@GTECH      ET   ON  ET.G3E_FID             = COM.G3E_FID
            LEFT OUTER JOIN CPROPIETARIO@GTECH     CPRO ON  CPRO.G3E_FID           = CON.G3E_FID
            LEFT OUTER JOIN QA_TTT1_REGISTRO       TT1  ON  TT1.TT1_NOMBRECIRCUITO = CON.CIRCUITO
            LEFT OUTER JOIN INFO_AP                AP   ON AP.NODO_TRANSFORM_V     = SUBSTR(CON.NODO_TRANSFORM_V,1,20)
        WHERE               COM.G3E_FNO = 20400
        AND                 COM.ESTADO <> 'CONSTRUCCION'
        AND CON.NODO_TRANSFORM_V <> '4T00937'
        ;

       
       SELECT COM.CLASIFICACION_MERCADO, CON.NODO_TRANSFORM_V ,COM.USUARIO_MODIFICACION 
               FROM                CCONECTIVIDAD_E@GTECH  CON
            LEFT OUTER JOIN CCOMUN@GTECH           COM  ON  COM.G3E_FID            = CON.G3E_FID
            LEFT OUTER JOIN ETRANSFO_AT@GTECH      ET   ON  ET.G3E_FID             = COM.G3E_FID
            LEFT OUTER JOIN CPROPIETARIO@GTECH     CPRO ON  CPRO.G3E_FID           = CON.G3E_FID
            LEFT OUTER JOIN QA_TTT1_REGISTRO       TT1  ON  TT1.TT1_NOMBRECIRCUITO = CON.CIRCUITO
            --LEFT OUTER JOIN INFO_AP                AP   ON AP.NODO_TRANSFORM_V     = SUBSTR(CON.NODO_TRANSFORM_V,1,20)
        WHERE               COM.G3E_FNO = 20400
        AND LENGTH (COM.CLASIFICACION_MERCADO) > 10
        AND                 COM.ESTADO <> 'CONSTRUCCION'
        ;

       
       SELECT * FROM QA_TTT2_OBS;
      
      SELECT * FROM QA_TTC1_TEMP;
     
     DELETE FROM QA_TTC1_TEMP;
    
    COMMIT;
   
   
   SELECT DISTINCT TC1_GC 
  FROM QA_TTC1_TEMP
 WHERE TC1_TIPCONEX = 'T'
;

SELECT MAX(TC1_PERIODO) FROM QA_TTC1;



INSERT INTO QA_TTC1
SELECT * FROM QA_TTC1_TEMP;

COMMIT;

SELECT COUNT(1) FROM QA_TTC1
WHERE TC1_PERIODO = '202307';


    --AGREGA INFORMACION A LA TABLA DE REGISTRO PARA SU POSTERIOR ANALISIS
    --INSERT INTO QA_TFDDREGISTRO_AI 
    SELECT I.MINICIAL      AS FDD_CODIGOEVENTO
    	  ,(CASE WHEN I.FFINAL IS NULL THEN SYSDATE ELSE I.FFINAL END) AS FDD_FFINAL
          ,I.FINICIAL      AS FDD_FINICIAL
          ,I.FFINAL        AS FDD_FFINAL
          ,M.DESCRIPTIO    AS FDD_DECRIPCION
          ,'A'             AS FDD_CAUSANTE_AFECTADO
          ,I.TRAFO         AS FDD_CODIGOELEMENTO
          ,'1'             AS FDD_TIPOELEMENTO
          ,C.FDC_CAUSA_015 AS FDD_CAUSA_CREG
          ,SYSDATE         AS FDD_FESTIMADA --RECIBIR POR INTERFACE COMO DATO DE ENTRADA
          ,CANT_USRS       AS FDD_AFECTADOS
          ,NULL            AS FDD_AFECTADOS_TOTALES --REALIZADA POR PROCEDIMIENTO
    --SELECT COUNT(1)
    FROM OMS.INTERUPC I
    LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
    LEFT OUTER JOIN BRAE.QA_TFDDCAUSAS C ON C.FDC_CAUSA_OMS = M.CAUSA
    LEFT OUTER JOIN (
                     SELECT  TC1_CODCONEX,COUNT(TC1_CODCONEX) AS CANT_USRS
                     FROM QA_TTC1
                     WHERE TC1_PERIODO = 202307--MAX_PERIODO_TC1
                     GROUP BY TC1_CODCONEX
                     ) ON TC1_CODCONEX = I.TRAFO
    --WHERE TRUNC(FINICIAL) = TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) 
    WHERE TRUNC(FINICIAL) >= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) - 04 / 24
    AND   TRUNC(FINICIAL) <= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) + 24 / 24
    AND M.TIPO <> 'PRUEBA' 
    AND M.EJECUTADO = 1
    AND I.TYPEEQUIP IN ('Transformer')
    AND TC1_CODCONEX IS NOT NULL
    AND I.FFINAL IS NULL
    ;



/
--DECLARE
BEGIN
	 QA_PFDDREGISTRO_AI(DATE'2023-08-02');
END;

SELECT * FROM QA_TFDDREGISTRO_AI;


--EVENTOS ABIERTOS EN OMS, REPORTAR PARA REALIZAR DEPURACION
    SELECT DISTINCT I.MINICIAL      AS FDD_CODIGOEVENTO
          ,I.FINICIAL      AS FDD_FINICIAL
          ,I.FFINAL        AS FDD_FFINAL
    FROM OMS.INTERUPC I
    LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
    WHERE I.FFINAL IS NULL
    AND M.TIPO <> 'PRUEBA' 
    AND M.EJECUTADO = 1
    AND I.TYPEEQUIP IN ('Transformer')
    ORDER BY 2
 	;

 
SELECT A.FDD_CODIGOEVENTO
          ,A.FDD_FINICIAL
          ,A.FDD_FFINAL
          ,A.FDD_DESCRIPCION
          ,A.FDD_CAUSANTE_AFECTADO
          ,A.FDD_CODIGOELEMENTO
          ,A.FDD_TIPOELEMENTO
          ,A.FDD_CAUSA
          ,A.FDD_FESTIMADA
          ,A.FDD_AFECTADOS
          ,U.FDD_AFECTADOS_TOTALES
FROM QA_TFDDREGISTRO_AI A
LEFT OUTER JOIN (
				SELECT FDD_CODIGOEVENTO , SUM(CANT_USERS) AS FDD_AFECTADOS_TOTALES 
						FROM(
				   			 SELECT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO,CANT_USERS  
							 FROM QA_TFDDREGISTRO_AI
							 LEFT OUTER JOIN (SELECT TC1_CODCONEX, COUNT(TC1_CODCONEX) AS CANT_USERS 
							 				  FROM QA_TTC1 
											  WHERE TC1_PERIODO = 202307
											  AND   TC1_CODCONEX NOT LIKE 'ALPM%'
											  AND   TC1_TIPCONEX = 'T'
											  GROUP BY TC1_CODCONEX) ON TC1_CODCONEX = FDD_CODIGOELEMENTO			 
							 ) 
				GROUP BY FDD_CODIGOEVENTO 			 				
				) U ON U.FDD_CODIGOEVENTO = A.FDD_CODIGOEVENTO
;





SELECT I.MINICIAL      AS FDD_CODIGOEVENTO
          ,I.FINICIAL      AS FDD_FINICIAL
          ,(CASE WHEN I.FFINAL IS NULL 
          		 THEN SYSDATE 
          		 ELSE I.FFINAL 
          	END)	 	   AS FDD_FFINAL
          ,M.DESCRIPTIO    AS FDD_DECRIPCION
          ,'A'             AS FDD_CAUSANTE_AFECTADO
          ,I.TRAFO         AS FDD_CODIGOELEMENTO
          ,'1'             AS FDD_TIPOELEMENTO
          ,C.FDC_CAUSA_015 AS FDD_CAUSA_CREG
          ,SYSDATE         AS FDD_FESTIMADA --RECIBIR POR INTERFACE COMO DATO DE ENTRADA
          ,CANT_USRS       AS FDD_AFECTADOS
          ,NULL            AS FDD_AFECTADOS_TOTALES --REALIZADA POR PROCEDIMIENTO
    SELECT COUNT(1)
    FROM OMS.INTERUPC I
    LEFT OUTER JOIN OMS.MANIOBRAS M ON M.CODE=I.MINICIAL
    LEFT OUTER JOIN BRAE.QA_TFDDCAUSAS C ON C.FDC_CAUSA_OMS = M.CAUSA
    LEFT OUTER JOIN (
                     SELECT  TC1_CODCONEX,COUNT(TC1_CODCONEX) AS CANT_USRS
                     FROM QA_TTC1
                     WHERE TC1_PERIODO = 202307--MAX_PERIODO_TC1
                     GROUP BY TC1_CODCONEX
                     ) ON TC1_CODCONEX = I.TRAFO
    WHERE TRUNC(FINICIAL) >= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) --entrada jasper
    AND   TRUNC(FINICIAL) <= TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY')) --entrada jasper
    AND M.TIPO <> 'PRUEBA' 
    AND M.EJECUTADO = 1
    AND I.TYPEEQUIP IN ('Transformer')
    AND TC1_CODCONEX IS NOT NULL
    AND (I.FFINAL - I.FINICIAL) * 24 >= 2.5 --HRS
    ;
    

   
   
SELECT  FDD_CODIGOEVENTO
		,FDD_FINICIAL
		,FDD_FFINAL
		,FDD_DESCRIPCION
		,FDD_CAUSANTE_AFECTADO
		,FDD_CODIGOELEMENTO
		,FDD_TIPOELEMENTO
		,FDD_CAUSA
		,FDD_FESTIMADA
		,FDD_AFECTADOS
		,FDD_AFECTADOS_TOTALES
DELETE
FROM QA_TFDDREGISTRO_AI
WHERE FDD_AFECTADOS_TOTALES < 1000
;
COMMIT;

SELECT COUNT(1) 
FROM QA_TFDDREGISTRO_AI;


   
   
    	
DECLARE
 VAR NUMBER;
BEGIN 
	QA_PFDDREGISTRO_AI(DATE'2023-08-01',VAR);
	IF (VAR = 1) THEN
		DBMS_OUTPUT.PUT_LINE('EXISTE EVENTO DE ALTO IMPACTO');
	ELSE
		DBMS_OUTPUT.PUT_LINE('NO EXISTE EVENTO DE ALTO IMPACTO');
	END IF;
END;


SELECT * FROM QA_TFDDREGISTRO_AI;



SELECT  TO_CHAR(CS1_PERIODO_OP,'DD-MM-YYYY') AS PERIODO, ROUND(CS1_CAIDI_M,2) AS CAIDI , ROUND(CS1_MAIFI_M,2) AS MAIFI  
FROM QA_TCS1
WHERE TO_CHAR(CS1_PERIODO_OP,'YYYY') IN ('2019','2020','2021')
ORDER BY CS1_PERIODO_OP ;

SELECT * FROM QA_TCS1 ORDER BY 1;



SELECT * FROM QA_TTC1_TEMP;

SELECT * FROM QA_TFDDREGISTRO_AI;

SELECT * FROM QA_TTC1 WHERE TC1_PERIODO = 201912;

SELECT CSU_NIU
,(CASE WHEN T1.TC1_GC IS NULL THEN T2.TC1_GC ELSE T1.TC1_GC END) AS TC1_GC
,(CASE WHEN T1.TC1_NT IS NULL THEN T2.TC1_NT ELSE T1.TC1_NT END) AS TC1_NT 
FROM QA_TCSU 
LEFT OUTER JOIN (SELECT * FROM QA_TTC1 WHERE TC1_PERIODO = 202002) T1 ON T1.TC1_TC1 = CSU_NIU
LEFT OUTER JOIN (SELECT DISTINCT TC1_CODCONEX, TC1_NT, TC1_GC FROM QA_TTC1 WHERE TC1_PERIODO = 202002) T2 ON T2.TC1_CODCONEX = T1.TC1_CODCONEX
WHERE CSU_PERIODO_OP = DATE'2019-12-01';


SELECT TC1_TC1, TC1_CODCONEX 
FROM QA_TTC1

WHERE TC1_PERIODO = 201912
AND TC1_TC1 LIKE 'CALP%';




SELECT * FROM QA_TFDDREGISTRO qt WHERE FDD_CODIGOEVENTO = '1029928';

SELECT MAX(FDD_PERIODO_OP) FROM QA_TFDDREGISTRO qt ;

				UPDATE QA_TFDDREGISTRO
				SET
				FDD_FFINAL =  NULL,
				FDD_CONTINUIDAD = 'S',
				FDD_FREG_CIERRE = NULL,
				FDD_FPUB_CIERRE = NULL,
				FDD_PERIODO_OP = TRUNC(FDD_FINICIAL),
				FDD_RECONFIG = 'N',
				FDD_ENS_ELEMENTO = NULL,
				FDD_ENS_EVENTO = NULL,
				FDD_ENEG_EVENTO	= NULL,
				FDD_ENEG_ELEMENTO =NULL
				WHERE FDD_RECONFIG = 'S'
			    AND FDD_CODIGOEVENTO = '1029928'
			    AND FDD_CODIGOELEMENTO = '5T01471' ;
			   
			
				COMMIT;


		SELECT * FROM QA_TFDDREPORTE 
		WHERE FDR_CODIGOEVENTO = '1029928'
	    AND FDR_CODIGOELEMENTO = '5T01471';
	   
	   
	   
	   SELECT  SUBSTR(CON.NODO_TRANSFORM_V,1,20) AS NODO_TRANSFORM_V,SUM(TO_NUMBER(TRIM(REPLACE(LUM.POTENCIA,'.',',')))) AS POTENCIA_INSTALADA
         FROM CCONECTIVIDAD_E@GTECH CON
         JOIN CCOMUN@GTECH COM ON CON.G3E_FID=COM.G3E_FID
         JOIN ELUMINAR_AT@GTECH LUM ON  LUM.G3E_FID = CON.G3E_FID
         WHERE CON.G3E_FNO = 21400
         AND  COM.ESTADO <> 'RETIRADO'
         AND  CON.NODO_TRANSFORM_V IS NOT NULL
         GROUP BY CON.NODO_TRANSFORM_V;
        
        
        SELECT * FROM QA_TFDDREPORTE qt WHERE FDR_CODIGOEVENTO = '753786';
		SELECT * FROM QA_TFDDREGISTRO qt WHERE FDD_CODIGOEVENTO = '753786';	
		
	
	
	SELECT FDD_CODIGOEVENTO
		,FDD_FINICIAL
		,FDD_FFINAL
		,FDD_DESCRIPCION
		,FDD_CAUSANTE_AFECTADO
		,FDD_CODIGOELEMENTO
		,FDD_TIPOELEMENTO
		,FDD_CAUSA
		,FDD_FESTIMADA
		,FDD_AFECTADOS_TOTALES
FROM QA_TFDDREPORTE_AI 
WHERE FDD_PERIODO_OP = TO_DATE('XX/XX/2023','DD/MM/YYYY');

SELECT * FROM QA_TLOG_EJECUCION qte ;


SELECT * FROM QA_TTC1_OBS;



DROP PROCEDURE QA_PTC1_REGISTRO_FASE2;
DROP PROCEDURE EMITE_BOOLEAN;
/



DECLARE
ESTADO NUMBER;
MESSAGE VARCHAR2(100);
BEGIN
	QA_PTC1_INSERT_OBS(DATE'2023-07-01','1020646',ESTADO,MESSAGE);
END
;


SELECT * FROM QA_TTC1_TEMP
WHERE TC1_PERIODO = 202307
AND TC1_TC1 = '1020646';


SELECT DISTINCT TC1_CODCONEX FROM QA_TTC1_TEMP;
COMMIT;

SELECT * FROM QA_TTC1_TEMP WHERE TC1_CODCONEX = '5T00125';


DELETE FROM QA_TTC1_TEMP
WHERE TC1_PERIODO = 202307
AND TC1_TC1 = '1020646';

COMMIT;


SELECT * FROM QA_TMUNDANE;


SELECT * FROM QA_TTT2_REPORTE
WHERE TT2_CODE_TRAFO IN (
'5T03041'
);

SELECT * FROM QA_TTC1_OBS WHERE TC1_PERIODO = 202307
AND TC1_TC1 IN(
'24102'
,'24104'
,'420279'
,'1099721'
,'1100530'
);


SELECT * FROM QA_TTT2_REPORTE
WHERE TT2_CODE_TRAFO  IN(
'1T08618')
;


SELECT * FROM QA_TTC1_OBS
WHERE TC1_PERIODO = 202307
AND TC1_TC1 = '407624';






SELECT * FROM QA_TTT2_REPORTE 
WHERE TT2_CODE_TRAFO IN ('5T03041','1T12267');

SELECT DISTINCT TC1_CODCONEX , TC1_PERIODO 
FROM QA_TTC1 
WHERE TC1_CODCONEX IN ('5T03041','1T12267')
ORDER BY TC1_PERIODO;

SELECT * FROM qa_ttc1
WHERE tc1_tc1 = '675264';
SELECT * FROM qa_ttt2_registro WHERE TT2_CODIGOELEMENTO = '1T11426';

SELECT * FROM qa_ttc1 WHERE tc1_codconex = '1T11426';


SELECT * FROM QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'RETIRADO'
AND TT2_CODIGOELEMENTO = '5T03041'
;

SELECT * FROM QA_TTT2_REGISTRO
WHERE TT2_CODIGOELEMENTO IN 
(
'1T11426'
,'1T04696'
,'5T03041'
,'XT00001'
,'1T06962'
,'1T07100'
,'5T03009'
)
AND TT2_ESTADO = 'OPERACION';



SELECT * FROM QA_TTC1_TEMP qtt 
WHERE TC1_CODCONEX = '5T03041';



 SELECT * FROM QA_TTT2_REGISTRO;

INSERT INTO QA_TTC1_OBS
SELECT * FROM QA_TTC1_OBS@BRAEPROD
WHERE TC1_PERIODO = 202307;

SELECT * FROM QA_TTT2_REGISTRO
WHERE TT2_CODIGOELEMENTO = '3T00380';

SELECT * FROM ALL_TABLES 
WHERE OWNER LIKE 'BRAE'
AND TABLE_NAME LIKE 'QA_TTT2%';

CREATE TABLE QA_TTT2_UNIDAD_CONSTRUCTIVA AS
SELECT * FROM QA_TTT2_UNIDAD_CONSTRUCTIVA@BRAEPROD;

DELETE FROM QA_TTT2_UNIDAD_CONSTRUCTIVA;
COMMIT;

UPDATE QA_TTT2_UNIDAD_CONSTRUCTIVA qtuc 
SET TT2_CAPACIDAD = MONOFASICO;	

SELECT * FROM QA_TTT2_UNIDAD_CONSTRUCTIVA qtuc ;
COMMIT;

ALTER TABLE QA_TTT2_UNIDAD_CONSTRUCTIVA 
DROP COLUMN MONOFASICO;


UPDATE QA_TTT2_REGISTRO
SET TT2_UNIDAD_CONSTRUCTIVA = NULL
WHERE TT2_PERIODO_OP = DATE'2023-06-01'
AND TT2_ESTADO = 'OPERACION'
;
COMMIT;

INSERT INTO QA_TTT2_REGISTRO
SELECT   TR.TT2_CODIGOELEMENTO
		,TR.TT2_CODE_IUA
		,TR.TT2_GRUPOCALIDAD
		,TR.TT2_IDMERCADO
		,TR.TT2_CAPACIDAD
		,TR.TT2_PROPIEDAD
		,TR.TT2_TSUBESTACION
		,TR.TT2_LONGITUD
		,TR.TT2_LATITUD
		,TR.TT2_ALTITUD
		,TR.TT2_ESTADO
		,TR.TT2_ESTADO_BRA11
		,TR.TT2_RESMETODOLOGIA
		,TR.TT2_CLASS_CARGA
		,TR.TT2_NOMBRE_CIRCUITO
		,TR.TT2_IUL
		,TR.TT2_CODIGOPROYECTO
		,NVL(UC.TT2_UNIDAD_CONSTRUCTIVA,'NA') AS TT2_UNIDAD_CONSTRUCTIVA 
		,TR.TT2_RPP
		,TR.TT2_SALINIDAD
		,TR.TT2_TIPOINVERSION
		,TR.TT2_REMUNERACION_PENDIENTE
		,TR.TT2_ALTERNATIVA_VALORACION
		,TR.TT2_ID_PLAN
		,TR.TT2_CANTIDAD
		,TR.TT2_FESTADO
		,TR.TT2_FCOLOCACION
		,TR.TT2_FMODIFICACION
		,TR.TT2_USR_COLOCACION
		,TR.TT2_USR_MODFICACION
		,TR.TT2_PERIODO_OP
		,TR.TT2_ESTADOREPORTE
		,TR.TT2_FSISTEMA
		,TR.TT2_ACTIVOCONEXION
		,TR.TT2_ACTIVOPROVISIONAL
		,TR.TT2_AP_POTENCIA
		,TR.TT2_CODE_CALP
		,TR.TT2_FASES
		,TR.TT2_POBLACION
		,TR.TT2_VALOR_UC
		,TR.TT2_OBSERVACIONES
		,TR.TT2_LOCALIZACION
		,TR.TT2_MUNICIPIO
		,TR.TT2_DEPARTAMENTO
		,TR.TT2_NT_PRIMARIA
		,TR.TT2_NT_SECUNDARIA
		,TR.TT2_ACTIVONR
		,TR.TT2_G3E_FID
		,TR.TT2_FID_ANTERIOR 
FROM QA_TTT2_REGISTRO TR
LEFT OUTER JOIN (SELECT * FROM QA_TTT2_UNIDAD_CONSTRUCTIVA) UC 
			  ON UC.TT2_TIPO_SUBESTACION = TR.TT2_TSUBESTACION
			  AND UC.TT2_FASE_DESCRIPCION = (CASE WHEN LENGTH(REPLACE(TT2_FASES, 'N', '')) = 3  
			                                      THEN 'TRIFASICO' 
			                                      ELSE 'MONOFASICO' 
			                                 END)
			  AND UC.TT2_POBLACION = TR.TT2_POBLACION
			  AND UC.TT2_CAPACIDAD = TR.TT2_CAPACIDAD 
WHERE TR.TT2_UNIDAD_CONSTRUCTIVA IS NULL;
COMMIT;

DELETE FROM QA_TTT2_REGISTRO qtr WHERE TT2_UNIDAD_CONSTRUCTIVA IS NULL;

DECLARE
BEGIN
	QA_PTT2_REGISTRO(DATE'2023-07-01');
END;


SELECT * FROM QA_TTT2_REGISTRO qtr 
WHERE TT2_PERIODO_OP = DATE'2023-07-01';

SELECT * FROM QA_TTT2_OBS 
WHERE TT2_PERIODO_OP = DATE'2023-07-01';


SELECT * FROM QA_TTT2_UNIDAD_CONSTRUCTIVA qtuc ;
COMMIT;

--CREATE DBLINK FOR DEVELOPER SPACE
CREATE DATABASE LINK BRAEDEV
CONNECT TO BRAE IDENTIFIED BY iKEjvbvP
USING '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=CENS-TO08)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=SPARD)))';


	
	UPDATE QA_TTT2_REGISTRO RT
	SET  TT2_PROPIEDAD       = (SELECT DISTINCT (TT2_PROPIEDAD) 
								FROM QA_TTT2_TEMP 
								WHERE TT2_ESTADO = 'OPERACION' 
								AND TT2_CODIGOELEMENTO = RT.TT2_CODIGOELEMENTO
							    )
		,TT2_LONGITUD        = (SELECT DISTINCT (TT2_LONGITUD) 
								FROM QA_TTT2_TEMP 
								WHERE TT2_ESTADO = 'OPERACION' 
								AND TT2_CODIGOELEMENTO = RT.TT2_CODIGOELEMENTO
							    )
		,TT2_LATITUD         = (SELECT DISTINCT (TT2_LATITUD) 
								FROM QA_TTT2_TEMP 
								WHERE TT2_ESTADO = 'OPERACION' 
								AND TT2_CODIGOELEMENTO = RT.TT2_CODIGOELEMENTO
							    )
		,TT2_ALTITUD         = (SELECT DISTINCT (TT2_ALTITUD) 
								FROM QA_TTT2_TEMP 
								WHERE TT2_ESTADO = 'OPERACION' 
								AND TT2_CODIGOELEMENTO = RT.TT2_CODIGOELEMENTO
								)
		,TT2_NOMBRE_CIRCUITO = (SELECT DISTINCT (TT2_NOMBRE_CIRCUITO) 
								FROM QA_TTT2_TEMP 
								WHERE TT2_ESTADO = 'OPERACION' 
								AND TT2_CODIGOELEMENTO = RT.TT2_CODIGOELEMENTO
								)
		,TT2_IUL             = (SELECT DISTINCT (TT2_IUL) 
								FROM QA_TTT2_TEMP 
								WHERE TT2_ESTADO = 'OPERACION' 
								AND TT2_CODIGOELEMENTO = RT.TT2_CODIGOELEMENTO
								)
	WHERE TT2_CODIGOELEMENTO IN(
								SELECT DISTINCT TT2_CODIGOELEMENTO 
								FROM(
									SELECT TT2_CODIGOELEMENTO  
									      ,TT2_PROPIEDAD
										  ,TT2_LONGITUD
										  ,TT2_LATITUD
										  ,TT2_ALTITUD
									      ,TT2_NOMBRE_CIRCUITO 
										  ,TT2_IUL
									FROM QA_TTT2_REGISTRO
									WHERE TT2_ESTADO = 'OPERACION'
									
									MINUS
									
									SELECT TT2_CODIGOELEMENTO  
									      ,TT2_PROPIEDAD
										  ,TT2_LONGITUD
										  ,TT2_LATITUD
										  ,TT2_ALTITUD
										  ,TT2_NOMBRE_CIRCUITO 
										  ,TT2_IUL 
									FROM QA_TTT2_TEMP
									WHERE TT2_ESTADO = 'OPERACION'
									)
								WHERE TT2_CODIGOELEMENTO NOT LIKE 'XT%'
							   )
	AND TT2_CODIGOELEMENTO NOT IN (
								  SELECT TT2_CODIGOELEMENTO 
								  FROM QA_TTT2_TEMP 
								  WHERE TT2_PROPIEDAD       IS NULL 
								  OR    TT2_LONGITUD        IS NULL 
								  OR    TT2_LATITUD         IS NULL
								  OR    TT2_ALTITUD         IS NULL 
								  OR    TT2_NOMBRE_CIRCUITO IS NULL
								  OR    TT2_IUL             IS NULL
								  )						   
	;
						
						
						
						

UPDATE QA_TTT2_REGISTRO RT
SET  TT2_ALTITUD        = (SELECT DISTINCT (TT2_ALTITUD) 
							FROM QA_TTT2_TEMP 
							WHERE TT2_ESTADO = 'OPERACION' 
							AND TT2_CODIGOELEMENTO = RT.TT2_CODIGOELEMENTO
						    )
WHERE TT2_CODIGOELEMENTO IN(
							SELECT DISTINCT TT2_CODIGOELEMENTO 
							FROM(
								SELECT TT2_CODIGOELEMENTO  
								      --,TT2_PROPIEDAD
									  --,TT2_LONGITUD
									  --,TT2_LATITUD
									  ,TT2_ALTITUD
								      --,TT2_NOMBRE_CIRCUITO 
									  --,TT2_IUL
								FROM QA_TTT2_REGISTRO
								WHERE TT2_ESTADO = 'OPERACION'
								
								MINUS
								
								SELECT TT2_CODIGOELEMENTO  
								      --,TT2_PROPIEDAD
									  --,TT2_LONGITUD
									  --,TT2_LATITUD
									  ,TT2_ALTITUD
									  --,TT2_NOMBRE_CIRCUITO 
									  --,TT2_IUL 
								FROM QA_TTT2_TEMP
								WHERE TT2_ESTADO = 'OPERACION'
								)
							WHERE TT2_CODIGOELEMENTO NOT LIKE 'XT%'
						   )
AND TT2_CODIGOELEMENTO NOT IN (
							  SELECT*
							  FROM QA_TTT2_TEMP 
							  WHERE TT2_PROPIEDAD       IS NULL 
							  OR    TT2_LONGITUD        IS NULL 
							  OR    TT2_LATITUD         IS NULL
							  OR    TT2_ALTITUD         IS NULL 
							  OR    TT2_NOMBRE_CIRCUITO IS NULL
							  OR    TT2_IUL             IS NULL
							  )						   
;
						
COMMIT;						
						
						
						
						
						
SELECT * FROM QA_TTT2_REGISTRO;						

SELECT * FROM QA_TBRA11_REGISTRO;


ALTER TABLE QA_TBRA11_REGISTRO
ADD (BRA11_G3E_FID      VARCHAR2(20)
,   BRA11_FID_ANTERIOR VARCHAR2(20))
;



SELECT 						
(SELECT COUNT(1) FROM QA_TBRA11_REGISTRO qtr 
WHERE BRA11_PERIODO_OP = DATE'2023-03-01') AS REGISTRO
,
(SELECT COUNT(1) FROM QA_TBRA11_REPORTE qtr 
WHERE BRA11_PERIODO_OP = DATE'2023-03-01') AS REPORTE
FROM DUAL;


UPDATE QA_TBRA11_REGISTRO BR 
SET BRA11_PERIODO_OP = (SELECT TT2_PERIODO_OP FROM QA_TTT2_REGISTRO WHERE TT2_ESTADO = 'OPERACION' AND TT2_CODIGOELEMENTO = BR.BRA11_CODIGOELEMENTO)
;


SELECT * FROM QA_TBRA11_REGISTRO qtr 
WHERE BRA11_PERIODO_OP IS NULL;


SELECT * FROM QA_TBRA11_REGISTRO WHERE BRA11_CODIGOELEMENTO = '5T01261';

SELECT * FROM QA_TTT2_REPORTE qtr  WHERE TT2_CODE_TRAFO  = '5T01261';



---TEST NUMBER TWO OF PROCEDURE QA_PTC1_INSERT_OBS						
DECLARE
ESTADO NUMBER;
MESSAGE VARCHAR2(100);
BEGIN
	QA_PTC1_INSERT_OBS(DATE'2023-07-01','1070869',ESTADO,MESSAGE);
END
;

SELECT * FROM QA_TTC1_OBS WHERE TC1_PERIODO = 202307 AND TC1_TC1 = '1070869';
SELECT * FROM QA_TTC1_TEMP WHERE TC1_PERIODO = 202307 AND TC1_TC1 = '1070869';


SELECT DISTINCT TC1_TC1 FROM QA_TTC1_OBS
WHERE TC1_PERIODO = 202307
AND TC1_TC1 NOT IN (SELECT DISTINCT TC1_TC1 FROM QA_TTC1_TEMP WHERE TC1_PERIODO = 202307);


