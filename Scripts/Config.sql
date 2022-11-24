﻿
--BORRAR INFORMACION DESDE EL PRIMER DIA DE CORTE CON IUA
DELETE FROM QA_TFDDREGISTRO
WHERE FDD_PERIODO_OP>=TO_DATE('01/05/2020','DD/MM/YYYY');
COMMIT;

--INSERTAR INFORMACION DESDE EL PRIMER DIA DE CORTE CON IUA
INSERT INTO QA_TFDDREGISTRO
SELECT * FROM QA_TFDDREGISTRO@BRAEPROD
WHERE FDD_PERIODO_OP>=TO_DATE('01/05/2020','DD/MM/YYYY');
COMMIT;

INSERT INTO QA_TFDDREPORTE
SELECT * FROM QA_TFDDREPORTE@BRAEPROD
WHERE FDR_PERIODO_OP=:FECHAOPERACION;
COMMIT;

EXEC QA_PFDDREGISTRO(TO_DATE(:FECHAOPERACION));

SELECT * FROM QA_TFDDREGISTRO
WHERE FDD_PERIODO_OP=:FECHAOPERACION;







----------------------------REVERSAR REGISTRO
DELETE FROM QA_TFDDREGISTRO
WHERE FDD_PERIODO_OP = :FECHAOPERACION
AND FDD_RECONFIG ='N';
COMMIT;

UPDATE QA_TFDDREGISTRO
SET
FDD_FFINAL =  NULL,
FDD_CONTINUIDAD = 'S',
FDD_FREG_CIERRE = NULL,
FDD_PERIODO_OP = TRUNC(FDD_FINICIAL),
FDD_RECONFIG = 'N'
WHERE FDD_PERIODO_OP = :FECHAOPERACION
AND FDD_RECONFIG = 'S';
COMMIT;

DELETE FROM QA_TFDDREPORTE
WHERE FDR_PERIODO_OP=:FECHAOPERACION;
COMMIT;

----------------------------pruebas
			SELECT A.FDD_CODIGOEVENTO
			      ,COUNT(A.FDD_CODIGOELEMENTO)
			      ,COUNT(B.FDD_CODIGOELEMENTO)
			FROM   QA_TFDDREGISTRO A
			LEFT   JOIN (
			             SELECT DISTINCT FDD_CODIGOELEMENTO
			             FROM   QA_TFDDREGISTRO
			             WHERE  FDD_PERIODO_OP        =  :FECHAOPERACION
			             AND    FDD_TIPOCARGA        <> 'NR'
	  	            ) B ON  B.FDD_CODIGOELEMENTO  =  A.FDD_CODIGOELEMENTO
			WHERE A.FDD_PERIODO_OP =  :FECHAOPERACION
			AND   A.FDD_TIPOCARGA  = 'NR'
			HAVING   COUNT(B.FDD_CODIGOELEMENTO)>0
			GROUP BY A.FDD_CODIGOEVENTO;

SELECT *
FROM(
			SELECT A.FDD_CODIGOEVENTO
			FROM   QA_TFDDREGISTRO A
			LEFT   JOIN (
			             SELECT DISTINCT FDD_CODIGOELEMENTO
			             FROM   QA_TFDDREGISTRO
			             WHERE  FDD_PERIODO_OP        =  :FECHAOPERACION
			             AND    FDD_TIPOCARGA        <> 'NR'
	  	            ) B ON  B.FDD_CODIGOELEMENTO  =  A.FDD_CODIGOELEMENTO
			WHERE A.FDD_PERIODO_OP =  :FECHAOPERACION
			AND   A.FDD_TIPOCARGA  = 'NR'
			HAVING   COUNT(B.FDD_CODIGOELEMENTO)>0
			GROUP BY A.FDD_CODIGOEVENTO
    ) T1
LEFT OUTER JOIN (
                 SELECT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO,FDD_FINICIAL,FDD_FFINAL
                 FROM QA_TFDDREGISTRO
                 WHERE FDD_PERIODO_OP=:FECHAOPERACION
                ) T2 ON T2.FDD_CODIGOEVENTO=T1.FDD_CODIGOEVENTO;


SELECT T1.FDD_CODIGOEVENTO    AS EVENTO_NR
      --,T1.FDD_CODIGOELEMENTO  AS ELEMENTO_NR
      --,T2.FDD_CODIGOEVENTO    AS EVENTO_CD
      --,T2.FDD_CODIGOELEMENTO  AS ELEMENTO_CD
      --,T2.FDD_FINICIAL        AS FINICIAL_CD
      --,T2.FDD_FFINAL          AS FFINAL_CD
      ,TO_DATE(TO_CHAR(MIN(T2.FDD_FINICIAL),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')   AS MIN_FINICIAL
      ,TO_DATE(TO_CHAR(MAX(T2.FDD_FFINAL)  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')   AS MAX_FFINAL
FROM QA_TFDDREGISTRO T1
LEFT OUTER JOIN ( SELECT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO
                        ,FDD_FINICIAL    ,FDD_FFINAL
									FROM QA_TFDDREGISTRO
									WHERE FDD_PERIODO_OP = :FECHAOPERACION
									AND   FDD_TIPOCARGA <> 'NR'
                ) T2 ON T2.FDD_CODIGOELEMENTO = T1.FDD_CODIGOELEMENTO
WHERE T1.FDD_PERIODO_OP = :FECHAOPERACION
AND   T1.FDD_TIPOCARGA = 'NR'
AND   T2.FDD_CODIGOELEMENTO IS NOT NULL-- PARA NO TRAER LOS ELEMENTOS QUE NO TRASLAPARON PERO SI DEL EVENTO TRASLAPADO
GROUP BY T1.FDD_CODIGOEVENTO
;

SELECT FDD_CODIGOEVENTO
     , MIN_IZQ - ROWNUM/86400
     , MAX_DER + ROWNUM/86400
      ,(
        CASE WHEN((MIN_IZQ - ROWNUM/86400) >= TRUNC(:FECHAOPERACION)+(2/86400))
             THEN(1)
             ELSE(0)
        END
        ) AS VAL_IZQ
      ,(
        CASE WHEN((MAX_DER + ROWNUM/86400) <= TRUNC(:FECHAOPERACION)+1-(2/86400)) --VALIDAR CUANDO FFINAL IS NULL
             THEN(1)
             ELSE(0)
        END
        ) AS VAL_DER
FROM(
SELECT T1.FDD_CODIGOEVENTO
      ,(
        CASE WHEN(TO_DATE(TO_CHAR(MIN(T2.FDD_FINICIAL),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')>=TRUNC(:FECHAOPERACION)+(2/86400))
             THEN(TO_DATE(TO_CHAR(MIN(T2.FDD_FINICIAL),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))
             ELSE(NULL)
        END
        ) AS MIN_IZQ
      ,(
        CASE WHEN(TO_DATE(TO_CHAR(MAX(T2.FDD_FFINAL)  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')<=TRUNC(:FECHAOPERACION)+1-(2/86400))
             THEN(TO_DATE(TO_CHAR(MAX(T2.FDD_FFINAL)  ,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))
             ELSE(NULL)
        END
        ) AS MAX_DER
FROM QA_TFDDREGISTRO T1
LEFT OUTER JOIN ( SELECT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO
                        ,FDD_FINICIAL    ,(CASE WHEN(FDD_FFINAL IS NULL) THEN(:FECHAOPERACION + 1 - (1/86400)) ELSE(FDD_FFINAL) END) AS FDD_FFINAL
									FROM QA_TFDDREGISTRO
									WHERE FDD_PERIODO_OP = :FECHAOPERACION
									AND   FDD_TIPOCARGA <> 'NR'
                ) T2 ON T2.FDD_CODIGOELEMENTO = T1.FDD_CODIGOELEMENTO
WHERE T1.FDD_PERIODO_OP = :FECHAOPERACION
AND   T1.FDD_TIPOCARGA = 'NR'
AND   T2.FDD_CODIGOELEMENTO IS NOT NULL-- PARA NO TRAER LOS ELEMENTOS QUE NO TRASLAPARON PERO SI DEL EVENTO TRASLAPADO
GROUP BY T1.FDD_CODIGOEVENTO
ORDER BY MAX_DER ASC);




--CONSULTA PARA LA CONSTRUCCION DEL FORMATO TT2
     SELECT T1.CODE AS CODE
           ,T1.UIA  AS IUA
           ,TO_NUMBER(T1.GRUPO015) AS GRUPO015
           ,TO_NUMBER('161') AS ID_MERCADO
           ,TO_NUMBER(T2.KVA) AS CAPACIDAD_TRF
           ,(CASE WHEN(T1.OWNER1='S') THEN(1) ELSE(2) END) AS PROPIEDAD
           ,TO_NUMBER(T1.TIPOSUB) AS TIPOSUB
           ,T1.LONGITUD
           ,T1.LATITUD
           ,TO_NUMBER(T1.Z)
           ,TO_NUMBER('2') AS ESTADO
           ,TO_CHAR(T1.DATE_INST,'DD-MM-YYYY') AS FECHA_ESTADO
           ,'CREG015' AS RESOLUCION
     FROM SPARD.TRANSFOR@BRAEPROD T1
     LEFT OUTER JOIN SPARD.TRFTYPES@BRAEPROD T2 ON T2.CODE=T1.TRFTYPE
     WHERE T1.CODE IN ('1T03007',	'1T07830',	'1T01340',	'1T10472',	'1T00605',	'1T00726',	'1T00285',	'1T03104',	'1T04440',	'1T01456',	'1T04787',	'1T07773',	'1T09330',	'1T06278',	'1T04224',	'1T06404',	'1T03641',	'1T06419',	'1T03544',	'1T07741',	'1T05041',	'1T04173',	'1T06122',	'1T06200',	'1T03755',	'2T00083',	'5T00457',	'2T01171',	'5T00753',	'5T00693',	'5T00056',	'5T00670',	'5T00862',	'5T01057',	'2T01552',	'1T02360',	'5T00809',	'5T00268',	'5T00365',	'3T00258',	'5T00158',	'5T00853',	'5T01079',	'5T01305',	'5T01143',	'3T00259',	'1T04499',	'5T01463',	'4T00682',	'5T01282',	'5T01550',	'1T08630',	'4T00162',	'5T01387',	'4T00199',	'4T00185',	'5T01838',	'5T01675',	'5T01657',	'2T01700',	'5T01658',	'5T01622',	'5T01715',	'5T02030',	'4T01165',	'4T01317',	'4T01227',	'4T01328',	'4T01104',	'4T00896',	'5T02549',	'1T12863',	'1T12869',	'1T06276',	'1T12871',	'1T12872',	'2T01103',	'3T04772',	'5T01965',	'5T00737',	'2T00999',	'5T02239',	'5T00748',	'1T00421',	'5T00740',	'5T00749',	'1T12877',	'5T02869',	'5T02870',	'1T12856',	'1T12857',	'1T12858',	'1T12859',	'1T12860',	'1T12861',	'1T12862',	'1T12878',	'1T12867',	'3T04812',	'3T04813',	'3T04814',	'3T04815',	'3T04816',	'3T04817',	'3T04818',	'3T04819',	'3T04820',	'3T04821',	'3T04822',	'3T04823',	'3T04824',	'3T04825',	'5T00733',	'1T12868',	'1T12873',	'1T12874',	'1T12875',	'4T01632',	'3T04826',	'3T04827',	'3T04828',	'3T04829',	'1T12865',	'4T01629',	'4T01630',	'3T04811',	'1T12870',	'2T01598',	'1T12864',	'1T12876',	'1T12866',	'1T12855',	'4T01631')
     ;



     SELECT MINICIAL,COUNT(TRAFO) AS CANT_TRAFOS
     FROM OMS.INTERUPC@BRAEPROD
     WHERE (FINICIAL>=TO_DATE('01/07/2020','DD/MM/YYYY') AND FINICIAL<TO_DATE('01/08/2020','DD/MM/YYYY'))
     AND TRAFO IN ('1T10472',	'1T12863',	'1T12869',	'1T12871',	'1T12872',	'1T12877',	'1T12879',	'5T02869',	'5T02870',	'1T112869',	'1T12856',	'1T12857',	'1T12858',	'1T12859',	'1T12860',	'1T12861',	'1T12862',	'1T12878',	'1T12867',	'3T04812',	'3T04813',	'3T04814',	'3T04815',	'3T04816',	'3T04817',	'3T04818',	'3T04819',	'3T04820',	'3T04821',	'3T04822',	'3T04823',	'3T04824',	'3T04825',	'1T12868',	'1T12873',	'1T12874',	'1T12875',	'4T01632',	'3T04826',	'3T04827',	'3T04828',	'3T04829',	'1T12865',	'4T01629',	'4T01630',	'3T04811',	'1T12870',	'1T12864',	'1T12876',	'1T12866',	'4T01631')
     GROUP BY MINICIAL
     ORDER BY MINICIAL;



     SELECT DISTINCT MINICIAL
     FROM OMS.INTERUPC@BRAEPROD
     WHERE (FINICIAL>=TO_DATE('01/07/2020','DD/MM/YYYY') AND FINICIAL<TO_DATE('01/08/2020','DD/MM/YYYY'))
     AND TRAFO IN (	'1T12863',	'1T12869',	'1T12871',	'1T12872',	'1T12877',	'1T12879',	'5T02869',	'5T02870',	'1T112869',	'1T12856',	'1T12857',	'1T12858',	'1T12859',	'1T12860',	'1T12861',	'1T12862',	'1T12878',	'1T12867',	'3T04812',	'3T04813',	'3T04814',	'3T04815',	'3T04816',	'3T04817',	'3T04818',	'3T04819',	'3T04820',	'3T04821',	'3T04822',	'3T04823',	'3T04824',	'3T04825',	'1T12868',	'1T12873',	'1T12874',	'1T12875',	'4T01632',	'3T04826',	'3T04827',	'3T04828',	'3T04829',	'1T12865',	'4T01629',	'4T01630',	'3T04811',	'1T12870',	'1T12864',	'1T12876',	'1T12866',	'4T01631',	'5T02857')
     ;


     SELECT  MINICIAL,COUNT(TRAFO)
     FROM OMS.INTERUPC@BRAEPROD
     WHERE (FINICIAL>=TO_DATE('01/07/2020','DD/MM/YYYY') AND FINICIAL<TO_DATE('01/08/2020','DD/MM/YYYY'))
     AND TRAFO IN ('3T04826','3T04811','3T04827')
     GROUP BY MINICIAL;



SELECT MINICIAL, COUNT(TRAFO)
FROM OMS.INTERUPC@BRAEPROD
WHERE MINICIAL IN (
							     SELECT  DISTINCT MINICIAL
							     FROM OMS.INTERUPC@BRAEPROD
							     WHERE (FINICIAL>=TO_DATE('01/07/2020','DD/MM/YYYY') AND FINICIAL<TO_DATE('01/08/2020','DD/MM/YYYY'))
							     AND TRAFO IN ('3T04826','3T04811','3T04827')
                  )
GROUP BY MINICIAL;


SELECT * FROM SPARD.TRANSFOR@BRAEPROD;



SELECT FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO FROM QA_TFDDREGISTRO
WHERE FDD_TIPOCARGA ='XR'
MINUS
SELECT FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO FROM QA_TFDDPRELIMINAR_NR@BRAEPROD
;



SELECT FDR_CODIGOEVENTO,
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')) ELSE(TO_CHAR(FDR_FINICIAL,'DD/MM/YYYY hh24:mi:ss')) END) FDR_FINICIAL,
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss'))  ELSE(TO_CHAR(FDR_FFINAL,'DD/MM/YYYY hh24:mi:ss'))  END) FDR_FFINAL,
                    FDR_CODIGOELEMENTO,
                    FDR_TIPOELEMENTO,
                    FDR_CAUSA,
                    FDR_CONTINUIDAD,
                    FDR_EXCLUIDOZNI,
                    FDR_AFECTACONGEN,
                    FDR_USUARIOAP,
                    FDR_TIPOCARGA,
                   (FDR_CODIGOEVENTO||','||
                    --(CASE)
                    TO_CHAR(FDR_FINICIAL,'DD/MM/YYYY hh24:mi:ss')||','||
                    TO_CHAR(FDR_FFINAL,'DD/MM/YYYY hh24:mi:ss')||','||
                    FDR_CODIGOELEMENTO||','||
                    FDR_TIPOELEMENTO||','||
                    FDR_CAUSA||','||
                    FDR_CONTINUIDAD||','||
                    FDR_EXCLUIDOZNI||','||
                    FDR_AFECTACONGEN||','||
                    FDR_USUARIOAP) AS CONCAT
                    FROM QA_TFDDREPORTE@BRAEPROD QA
                    LEFT OUTER JOIN (SELECT DISTINCT MINICIAL,FINICIAL,(CASE WHEN(TRUNC(FFINAL) > :FECHAOPERACION) THEN(NULL) ELSE(FFINAL) END) FFINAL, TRAFO AS ELEMENTO
                                     FROM OMS.INTERUPC@BRAEPROD
                                     WHERE TYPEEQUIP = 'Transformer'
                                     AND MINICIAL IN (SELECT DISTINCT FDD_CODIGOEVENTO FROM QA_TFDDREGISTRO@BRAEPROD)
                                    ) I ON I.MINICIAL||I.ELEMENTO = QA.FDR_CODIGOEVENTO||QA.FDR_CODIGOELEMENTO
                    WHERE FDR_PERIODO_OP=:FECHAOPERACION
                    AND FDR_CODIGOEVENTO <> 'NA'
                    ORDER BY FDR_CODIGOEVENTO ASC;






                    SELECT FDR_CODIGOEVENTO,
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')) ELSE(TO_CHAR(FDR_FINICIAL,'DD/MM/YYYY hh24:mi:ss')) END) FDR_FINICIAL,
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss'))  ELSE(TO_CHAR(FDR_FFINAL,'DD/MM/YYYY hh24:mi:ss'))  END) FDR_FFINAL,
                    FDR_CODIGOELEMENTO,
                    FDR_TIPOELEMENTO,
                    FDR_CAUSA,
                    FDR_CONTINUIDAD,
                    FDR_EXCLUIDOZNI,
                    FDR_AFECTACONGEN,
                    FDR_USUARIOAP,
                    FDR_TIPOCARGA,
                    (FDR_CODIGOEVENTO||','||
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')) ELSE(TO_CHAR(FDR_FINICIAL,'DD/MM/YYYY hh24:mi:ss')) END)||','||
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss'))  ELSE(TO_CHAR(FDR_FFINAL,'DD/MM/YYYY hh24:mi:ss'))  END)||','||
                    FDR_CODIGOELEMENTO||','||
                    FDR_TIPOELEMENTO||','||
                    FDR_CAUSA||','||
                    FDR_CONTINUIDAD||','||
                    FDR_EXCLUIDOZNI||','||
                    FDR_AFECTACONGEN||','||
                    FDR_USUARIOAP) AS CONCAT
                    FROM QA_TFDDREPORTE@BRAEPROD QA
                    LEFT OUTER JOIN (SELECT MINICIAL,FINICIAL,(CASE WHEN(TRUNC(FFINAL) > :FECHAOPERACION) THEN(NULL) ELSE(FFINAL) END) FFINAL, TRAFO AS ELEMENTO
                                     FROM OMS.INTERUPC@BRAEPROD
                                     WHERE TYPEEQUIP = 'Transformer'
                                     AND FINICIAL>= TO_DATE('01/'||TO_CHAR(:FECHAOPERACION,'MM/YYYY'),'DD/MM/YYYY')
                                    ) I ON I.MINICIAL||I.ELEMENTO = QA.FDR_CODIGOEVENTO||QA.FDR_CODIGOELEMENTO
                    WHERE FDR_PERIODO_OP=:FECHAOPERACION
                    AND FDR_CODIGOEVENTO <> 'NA'
                    ORDER BY FDR_CODIGOEVENTO ASC
                    ;



  SELECT * FROM QA_TFDDREGISTRO@BRAEPROD
  WHERE FDD_CODIGOEVENTO IN ('746199','746201','746203','746205');

  SELECT * FROM QA_TFDDREPORTE@BRAEPROD
  WHERE FDR_CODIGOEVENTO IN ('746199','746201','746203','746205');





                    SELECT FDR_CODIGOEVENTO,
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')) ELSE(TO_CHAR(FDR_FINICIAL,'DD/MM/YYYY hh24:mi:ss')) END) FDR_FINICIAL,
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss'))   ELSE(TO_CHAR(FDR_FFINAL,'DD/MM/YYYY hh24:mi:ss'))  END) FDR_FFINAL,
                    FDR_CODIGOELEMENTO,
                    FDR_TIPOELEMENTO,
                    FDR_CAUSA,
                    FDR_CONTINUIDAD,
                    FDR_EXCLUIDOZNI,
                    FDR_AFECTACONGEN,
                    FDR_USUARIOAP,
                    FDR_TIPOCARGA,
                    (FDR_CODIGOEVENTO||','||
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FINICIAL,'DD/MM/YYYY hh24:mi:ss')) ELSE(TO_CHAR(FDR_FINICIAL,'DD/MM/YYYY hh24:mi:ss')) END)||','||
                    (CASE WHEN(FDR_TIPOCARGA='XR') THEN(TO_CHAR(I.FFINAL,'DD/MM/YYYY hh24:mi:ss'))   ELSE(TO_CHAR(FDR_FFINAL,'DD/MM/YYYY hh24:mi:ss'))  END)||','||
                    FDR_CODIGOELEMENTO||','||
                    FDR_TIPOELEMENTO||','||
                    FDR_CAUSA||','||
                    FDR_CONTINUIDAD||','||
                    FDR_EXCLUIDOZNI||','||
                    FDR_AFECTACONGEN||','||
                    FDR_USUARIOAP) AS CONCAT
                    FROM QA_TFDDREPORTE@BRAEPROD QA
                    LEFT OUTER JOIN (SELECT MINICIAL
                                     , FINICIAL
                                     , (CASE WHEN(TRUNC(FFINAL  ) > :FECHAOPERACION) THEN(NULL) ELSE(FFINAL  ) END) FFINAL
                                     , TRAFO AS ELEMENTO
                                     FROM OMS.INTERUPC@BRAEPROD
                                     WHERE TYPEEQUIP = 'Transformer'
                                     AND FINICIAL>= ADD_MONTHS(:FECHAOPERACION,-1)
                                    ) I ON I.MINICIAL||I.ELEMENTO = QA.FDR_CODIGOEVENTO||QA.FDR_CODIGOELEMENTO
                    WHERE FDR_PERIODO_OP = :FECHAOPERACION
                    AND FDR_CODIGOEVENTO <> 'NA'
                    AND FDR_TIPOCARGA = 'XR'
                    ORDER BY FDR_CODIGOEVENTO ASC;



SELECT MINICIAL, FINICIAL, FFINAL FROM OMS.INTERUPC@BRAEPROD
WHERE MINICIAL IN ('746199','746201','746203','746205');

SELECT * FROM QA_TFDDREGISTRO@BRAEPROD
WHERE FDD_CODIGOEVENTO IN ('746199','746201','746203','746205');

SELECT * FROM QA_TFDDREPORTE@BRAEPROD
WHERE FDR_CODIGOEVENTO IN ('746199','746201','746203','746205');


SELECT  ADD_MONTHS(:FECHAOPERACION, -1) FROM DUAL;


SELECT DISTINCT FDD_CODIGOELEMENTO
FROM QA_TFDDREGISTRO@BRAEPROD
WHERE FDD_PERIODO_OP=:FECHAOPERACION
AND   FDD_RECONFIG = 'N'
AND   FDD_CODIGOELEMENTO IN ('1T00285',	'1T00605',	'1T00726',	'1T01340',	'1T01456',	'1T03007',	'1T03104',	'1T03544',	'1T03641',	'1T03755',	'1T03914',	'1T04173',	'1T04224',	'1T04440',	'1T04499',	'1T04787',	'1T05041',	'1T06122',	'1T06200',	'1T06278',	'1T06404',	'1T06419',	'1T07773',	'1T07830',	'1T09330',	'1T10472',	'2T00075',	'2T00083',	'2T00999',	'2T01103',	'2T01552',	'2T01598',	'2T01700',	'3T00258',	'3T00259',	'4T00162',	'4T00185',	'4T00199',	'4T00282',	'4T00498',	'4T00655',	'4T00896',	'4T01104',	'4T01227',	'4T01328',	'5T00056',	'5T00158',	'5T00268',	'5T00365',	'5T00457',	'5T00733',	'5T00737',	'5T00740',	'5T00749',	'5T00753',	'5T00862',	'5T01057',	'5T01079',	'5T01143',	'5T01282',	'5T01305',	'5T01387',	'5T01463',	'5T01550',	'5T01622',	'5T01657',	'5T01658',	'5T01715',	'5T01838',	'5T01965',	'5T02239',	'5T02549',	'1T00421',	'1T04732',	'1T06276',	'1T07741',	'2T01171',	'4T01317',	'5T00670',	'5T00693',	'5T00748',	'5T00853',	'5T02030')
;

SELECT CODE, TPARENT
FROM SPARD.CUSTMETR@BRAEPROD
WHERE CODE IN ('1000858',	'1008496',	'1015318',	'1022267',	'1028113',	'119682',	'119690',	'119691',	'119692',	'119693',	'130177',	'130180',	'133415',	'139013',	'139014',	'139015',	'139016',	'139017',	'139018',	'139019',	'144870',	'144871',	'144872',	'144873',	'144874',	'144875',	'144876',	'144877',	'144878',	'144879',	'144880',	'144881',	'144882',	'144883',	'144884',	'144885',	'144886',	'144887',	'144888',	'144889',	'144890',	'144891',	'144892',	'144893',	'144894',	'144895',	'144896',	'144897',	'144898',	'144900',	'144901',	'144902',	'144903',	'144904',	'144905',	'144906',	'144907',	'144908',	'144909',	'144910',	'144911',	'144912',	'209977',	'211055',	'263598',	'283725',	'295809',	'313232',	'314363',	'318416',	'321277',	'325395',	'403705',	'419144',	'427594',	'429399',	'438552',	'454696',	'454697',	'454698',	'458700',	'465874',	'465875',	'465876',	'465877',	'467912',	'472217',	'473093',	'475111',	'540564',	'571008',	'583203',	'600140',	'621367',	'636400',	'646680',	'689153');


SELECT CODE, UIA
FROM SPARD.TRANSFOR@BRAEPROD
WHERE CODE IN ('2T00075',	'1T03914',	'5T02857',	'2T00075',	'2T00075',	'1T04732',	'1T04732',	'1T04732',	'1T04732',	'1T04732',	'1T03914',	'1T03914',	'4T00282',	'4T00498',	'4T00498',	'4T00498',	'4T00498',	'4T00498',	'4T00498',	'4T00498',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'1T03914',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'2T00075',	'1T04732',	'2T00075',	'2T00075',	'2T00075',	'1T03914',	'4T00655',	'4T00655',	'4T00655',	'2T00075',	'1T03914',	'1T03914',	'1T03914',	'1T03914',	'2T00075',	'1T03914',	'1T03914',	'2T00075',	'4T00282',	'2T00075',	'2T00075',	'2T00075',	'4T00282',	'2T00075',	'4T00498',	'2T00075');


--ACTUALIZAR PERIODO TC1 PARA EL MES DE JULIO EN LA TABLA DE REGISTRO
SELECT DISTINCT FDD_PERIODO_TC1 FROM  QA_TFDDREGISTRO
WHERE FDD_FINICIAL >= :FECHAOPERACION;


--ACTUALIZAR PERIODO TC1 PARA EL MES DE JULIO EN LA TABLA DE REGISTRO
UPDATE  QA_TFDDREGISTRO
SET FDD_PERIODO_TC1 = 202007
WHERE FDD_FINICIAL >= :FECHAOPERACION;
COMMIT;


SELECT DISTINCT FDD_PERIODO_TC1 FROM  QA_TFDDREGISTRO
WHERE FDD_FINICIAL >= :FECHAOPERACION;


SELECT  MAX(TC1_PERIODO) FROM QA_TTC1 ;


INSERT INTO QA_TTC1
SELECT * FROM QA_TTC1_TEMP@BRAEPROD;
COMMIT;


SELECT DISTINCT FDD_TIPOCARGA
FROM QA_TFDDREGISTRO;

UPDATE QA_TFDDREGISTRO
SET FDD_TIPOCARGA='DR'
WHERE FDD_TIPOCARGA='CARGA DIARIA';

SELECT COUNT(FDD_TIPOCARGA) FROM QA_TFDDREGISTRO WHERE FDD_TIPOCARGA = 'CARGA DIARIA';

DESC QA_TFDDREGISTRO;




SELECT MINICIAL,FINICIAL,FFINAL,FSISTEMA FROM OMS.INTERUPC@BRAEPROD
LEFT OUTER JOIN OMS.MANIOBRAS@BRAEPROD ON CODE=MINICIAL
WHERE MINICIAL IN (
									SELECT DISTINCT FDD_CODIGOEVENTO
									FROM QA_TFDDREGISTRO
									WHERE FDD_TIPOCARGA='XR'
									AND FDD_PERIODO_OP=:FECHAOPERACION
									)
ORDER BY FSISTEMA;


CREATE TABLE QA_TTIPOCARGA (
 TC_CODIGO VARCHAR2(4 BYTE)
,TC_DEFINICION VARCHAR(20 BYTE)
,TC_DESCRIPCION VARCHAR2(100 BYTE)
);

INSERT INTO QA_TTIPOCARGA VALUES ('DR','DAY REPORT','Eventos que son tomados del sistema de forma diaria');
INSERT INTO QA_TTIPOCARGA VALUES ('NR','NOT REPORT','Eventos que son tomados del sistema de forma posterior');
INSERT INTO QA_TTIPOCARGA VALUES ('XR','X REPORT'  ,'Eventos configurados de forma temporal para su ajuste');
INSERT INTO QA_TTIPOCARGA VALUES ('MR','MODIFIED REPORT','Eventos ajustados y procedentes de modificaciones');
INSERT INTO QA_TTIPOCARGA VALUES ('AR','ACTIVE RETRO','Eventos antiguos registrados al sistema de forma masiva');
INSERT INTO QA_TTIPOCARGA VALUES ('UR','UNKNOWN RECORD','Eventos que en el cierre se desconoce temporalmente su origen');
INSERT INTO QA_TTIPOCARGA VALUES ('TR','TRANSVERSAL TC1','Eventos agregados o eliminados segun reporte oficial TC1');

SELECT * FROM QA_TTIPOCARGA;

COMMIT;


SELECT * FROM QA_TFDDREPORTE; --@BRAEPROD;
SELECT * FROM QA_TFDDREPORTE@BRAEPROD;

ALTER TABLE QA_TFDDREPORTE
DROP COLUMN FDR_IUA;

DESC QA_TFDDREGISTRO;

ALTER TABLE QA_TFDDREPORTE
--ADD  FDR_TIPOCARGA VARCHAR2(20)
 ADD FDR_IUA VARCHAR2(20);



 SELECT FDD_CODIGOEVENTO,FDD_CODIGOELEMENTO,FDD_FINICIAL,FDD_FFINAL,FDD_CAUSA,FDD_CAUSA_CREG,FDD_CAUSA_SSPD,
        I.FINICIAL,I.FFINAL,M.CAUSA,C.CAUSA015
 FROM QA_TFDDREGISTRO@BRAEPROD
 LEFT OUTER JOIN OMS.INTERUPC@BRAEPROD I ON FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO=I.MINICIAL||I.TRAFO
 LEFT OUTER JOIN OMS.MANIOBRAS@BRAEPROD M ON FDD_CODIGOEVENTO=M.CODE
 LEFT OUTER JOIN OMS.CAUSAS@BRAEPROD C ON C.CODE=M.CAUSA
 WHERE FDD_TIPOCARGA = 'XR'
 AND FDD_FINICIAL > = :FECHA1
 AND FDD_FINICIAL <   :FECHA2;


 (SELECT FDD_CODIGOEVENTO,FDD_FINICIAL,FDD_FFINAL,FDD_CODIGOELEMENTO,FDD_TIPOELEMENTO,FDD_CAUSA_CREG,'OMS' AS FDD_ORIGEN
 FROM QA_TFDDPRELIMINAR_AJ
 WHERE FDD_TIPOCARGA IN ('MR','XR')
 MINUS
 SELECT * FROM QA_TFDDMODIFICADOS@BRAEPROD
 WHERE FDD_ORIGEN='OMS'
 AND FDD_FINICIAL>=:FECHA1
 AND FDD_FINICIAL  <:FECHA2)
 UNION ALL
 (SELECT * FROM QA_TFDDMODIFICADOS@BRAEPROD
 WHERE FDD_ORIGEN='OMS'
 AND FDD_FINICIAL>=:FECHA1
 AND FDD_FINICIAL  <:FECHA2
 MINUS
 SELECT FDD_CODIGOEVENTO,FDD_FINICIAL,FDD_FFINAL,FDD_CODIGOELEMENTO,FDD_TIPOELEMENTO,FDD_CAUSA_CREG,'OMS' AS FDD_ORIGEN
 FROM QA_TFDDPRELIMINAR_AJ
 WHERE FDD_TIPOCARGA IN ('MR','XR'));

 SELECT * FROM QA_TFDDPRELIMINAR_AJ WHERE FDD_CODIGOEVENTO = '739206'
 UNION ALL
 SELECT * FROM QA_TFDDPRELIMINAR_AJ@BRAEPROD WHERE FDD_CODIGOEVENTO = '739206';

 DESC QA_TFDDPRELIMINAR_AJ;

 SELECT FDD_CODIGOEVENTO
,FDD_FINICIAL
,FDD_FFINAL
,FDD_CODIGOELEMENTO
,FDD_TIPOELEMENTO
,FDD_CONSUMODIA
,FDD_ENS_ELEMENTO
,FDD_ENS_EVENTO
,FDD_ENEG_EVENTO
,FDD_ENEG_ELEMENTO
,FDD_CODIGOGENERADOR
,FDD_CAUSA
,FDD_CAUSA_CREG
,FDD_USUARIOAP
,FDD_CONTINUIDAD
,FDD_ESTADOREPORTE
,FDD_PUBLICADO
,FDD_RECONFIG
,FDD_PERIODO_OP
--,FDD_FREG_APERTURA
--,FDD_FREG_CIERRE
--,FDD_FPUB_APERTURA
--,FDD_FPUB_CIERRE
,FDD_PERIODO_TC1
,FDD_TIPOCARGA
,FDD_EXCLUSION
,FDD_CAUSA_SSPD
,FDD_AJUSTADO
,FDD_TIPOAJUSTE
,FDD_RADICADO
,FDD_APROBADO
,FDD_IUA
 FROM QA_TFDDPRELIMINAR_AJ -- WHERE FDD_CODIGOEVENTO = '739064'
 MINUS
  SELECT FDD_CODIGOEVENTO
,FDD_FINICIAL
,FDD_FFINAL
,FDD_CODIGOELEMENTO
,FDD_TIPOELEMENTO
,FDD_CONSUMODIA
,FDD_ENS_ELEMENTO
,FDD_ENS_EVENTO
,FDD_ENEG_EVENTO
,FDD_ENEG_ELEMENTO
,FDD_CODIGOGENERADOR
,FDD_CAUSA
,FDD_CAUSA_CREG
,FDD_USUARIOAP
,FDD_CONTINUIDAD
,FDD_ESTADOREPORTE
,FDD_PUBLICADO
,FDD_RECONFIG
,FDD_PERIODO_OP
--,FDD_FREG_APERTURA
--,FDD_FREG_CIERRE
--,FDD_FPUB_APERTURA
--,FDD_FPUB_CIERRE
,FDD_PERIODO_TC1
,FDD_TIPOCARGA
,FDD_EXCLUSION
,FDD_CAUSA_SSPD
,FDD_AJUSTADO
,FDD_TIPOAJUSTE
,FDD_RADICADO
,FDD_APROBADO
,FDD_IUA
 FROM QA_TFDDPRELIMINAR_AJ@BRAEPROD; -- WHERE FDD_CODIGOEVENTO = '739064';

 SELECT *
 FROM QA_TFDDREGISTRO@BRAEPROD
 WHERE FDD_CODIGOEVENTO = '739864'
 UNION ALL
 SELECT *
 FROM QA_TFDDPRELIMINAR_AJ@BRAEPROD
 WHERE FDD_CODIGOEVENTO = '739864';


 SELECT FDD_TIPOCARGA,COUNT(FDD_TIPOCARGA)
 FROM QA_TFDDPRELIMINAR_AJ@BRAEPROD
 GROUP BY FDD_TIPOCARGA
 ;

 SELECT COUNT(*) FROM QA_TFDDPRELIMINAR_AJ@BRAEPROD;


 SELECT DISTINCT FDR_PERIODO_OP FROM QA_TFDDREPORTE_AJ@BRAEPROD
 ORDER BY 1;


--Coherencia entre causas CREG-SSPD-OR
SELECT DISTINCT FDD_CODIGOEVENTO,FDD_CAUSA,FDC_CAUSA_OMS,FDD_CAUSA_CREG, FDC_CAUSA_015,FDD_CAUSA_SSPD, FDC_CAUSA_SSPD,FDD_EXCLUSION,FDC_EXCLUSION,FDD_AJUSTADO
FROM QA_TFDDREGISTRO@BRAEPROD
LEFT OUTER JOIN QA_TFDDCAUSAS@BRAEPROD ON FDC_CAUSA_OMS=FDD_CAUSA
WHERE (FDD_CAUSA_CREG <> FDC_CAUSA_015 OR FDD_CAUSA_SSPD <> FDC_CAUSA_SSPD OR FDD_EXCLUSION <> FDC_EXCLUSION)
AND  (TO_DATE(TO_CHAR(FDD_FFINAL,  'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
     -TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24*60>3
AND FDD_FFINAL IS NOT NULL
UNION ALL
SELECT DISTINCT FDD_CODIGOEVENTO,FDD_CAUSA,FDC_CAUSA_OMS,FDD_CAUSA_CREG, FDC_CAUSA_015,FDD_CAUSA_SSPD, FDC_CAUSA_SSPD,FDD_EXCLUSION,FDC_EXCLUSION,FDD_AJUSTADO
FROM QA_TFDDREGISTRO@BRAEPROD
LEFT OUTER JOIN QA_TFDDCAUSAS@BRAEPROD ON FDC_CAUSA_OMS=FDD_CAUSA
WHERE (FDD_CAUSA_CREG <> FDC_CAUSA_015 OR FDD_EXCLUSION <> FDC_EXCLUSION)
AND  (TO_DATE(TO_CHAR(FDD_FFINAL,  'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
     -TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24*60<=3
AND FDD_FFINAL IS NOT NULL
;

SELECT DISTINCT FDD_CODIGOEVENTO
               ,FDD_FINICIAL
               ,FDD_FFINAL
               ,FDD_CAUSA
               ,FDD_CAUSA_CREG
               ,FDD_CAUSA_SSPD
               ,FDD_EXCLUSION
               ,FDD_AJUSTADO
FROM QA_TFDDREGISTRO@BRAEPROD
where FDD_CODIGOEVENTO IN ('697741','709107','654868','673442','703266','703766');

SELECT * FROM QA_TFDDREGISTRO@BRAEPROD
WHERE FDD_CODIGOEVENTO ='703766';

SELECT * FROM QA_TFDDCAUSAS@BRAEPROD
WHERE FDC_CAUSA_OMS='6FL03.';




SELECT DISTINCT FDD_CODIGOEVENTO
               ,FDD_FINICIAL
               ,FDD_FFINAL
               ,FDD_CAUSA
               ,FDD_CAUSA_CREG
               ,FDR_CAUSA AS FDR_CAUSA_CREG
               ,FDC_CAUSA_015
               ,FDD_CAUSA_SSPD
               ,FDC_CAUSA_SSPD
               ,FDD_EXCLUSION
               ,FDC_EXCLUSION
               ,FDD_AJUSTADO
               ,FDD_RECONFIG
FROM QA_TFDDREGISTRO@BRAEPROD
LEFT OUTER JOIN QA_TFDDREPORTE@BRAEPROD ON FDR_CODIGOEVENTO = FDD_CODIGOEVENTO
LEFT OUTER JOIN QA_TFDDCAUSAS@BRAEPROD ON FDC_CAUSA_OMS = FDD_CAUSA
WHERE FDD_CODIGOEVENTO IN ('697741','709107','673442','703266','703766');


SELECT * FROM QA_TFDDREGISTRO
WHERE FDD_CODIGOEVENTO='751060';


SELECT MAX(FDD_PERIODO_OP) FROM QA_TFDDREGISTRO;


SELECT DISTINCT *
FROM(
		SELECT RIA.EVENTOID
		      ,RIA.ELEMENTO
		      ,TO_CHAR(RIA.FECHAINI,'DD/MM/YYYY HH24:MI:SS') AS FECHAINI
		      ,TO_CHAR(RIA.FECHAFIN,'DD/MM/YYYY HH24:MI:SS') AS FECHAFIN
		      ,TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS') AS FINICIAL
		      ,TO_CHAR(REG.FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS') AS FFINAL
		      ,RIA.CAUSAREGISTRADAID
		      ,REG.FDD_CAUSA_CREG
		      ,REG.FDD_AJUSTADO
		      ,REG.FDD_RADICADO
		FROM BRAE.QA_TRIA_CNSD RIA
		LEFT OUTER JOIN QA_TFDDREGISTRO REG ON (REG.FDD_CODIGOEVENTO=RIA.EVENTOID AND REG.FDD_CODIGOELEMENTO=RIA.ELEMENTO)
		WHERE RIA.ELEMENTO LIKE '_T_____'
		UNION ALL
		SELECT RIA.EVENTOID
		      ,RIA.ELEMENTO
		      ,TO_CHAR(RIA.FECHAINI,'DD/MM/YYYY HH24:MI:SS') AS FECHAINI
		      ,TO_CHAR(RIA.FECHAFIN,'DD/MM/YYYY HH24:MI:SS') AS FECHAFIN
		      ,TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS') AS FINICIAL
		      ,TO_CHAR(REG.FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS') AS FFINAL
		      ,RIA.CAUSAREGISTRADAID
		      ,REG.FDD_CAUSA_CREG
		      ,REG.FDD_AJUSTADO
		      ,REG.FDD_RADICADO
		FROM BRAE.QA_TRIA_CNSD RIA
		LEFT OUTER JOIN QA_TFDDREGISTRO REG ON (REG.FDD_CODIGOEVENTO=RIA.EVENTOID AND REG.FDD_IUA=RIA.ELEMENTO)
		WHERE RIA.ELEMENTO NOT LIKE '_T_____'
		)
WHERE EVENTOID NOT IN (SELECT DISTINCT FDD_CODIGOEVENTO
                           FROM QA_TFDDREGISTRO
													 WHERE FDD_FFINAL IS NULL)
;

SELECT * FROM OMS.INTERUPC@BRAEPROD
WHERE MINICIAL='739050';

SELECT * FROM QA_TTC1@BRAEPROD
WHERE TC1_CODCONEX='2T01687'
AND TC1_PERIODO=202006;


SELECT * FROM QA_TFDDREPORTE@BRAEPROD
WHERE FDR_CODIGOEVENTO='739050';


CREATE OR REPLACE VIEW QA_VRIA_CNSD
AS
SELECT DISTINCT *
FROM(
		SELECT RIA.EVENTOID
		      ,RIA.ELEMENTO
		      ,TO_CHAR(RIA.FECHAINI,'DD/MM/YYYY HH24:MI:SS') AS FECHAINI
		      ,TO_CHAR(RIA.FECHAFIN,'DD/MM/YYYY HH24:MI:SS') AS FECHAFIN
		      ,TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS') AS FINICIAL
		      ,TO_CHAR(REG.FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS') AS FFINAL
		      ,RIA.CAUSAREGISTRADAID
		      ,REG.FDD_CAUSA_CREG
		      ,REG.FDD_AJUSTADO
		      ,REG.FDD_RADICADO
		FROM BRAE.QA_TRIA_CNSD RIA
		LEFT OUTER JOIN QA_TFDDREGISTRO REG ON (REG.FDD_CODIGOEVENTO=RIA.EVENTOID AND REG.FDD_CODIGOELEMENTO=RIA.ELEMENTO)
		WHERE RIA.ELEMENTO LIKE '_T_____'
		UNION ALL
		SELECT RIA.EVENTOID
		      ,RIA.ELEMENTO
		      ,TO_CHAR(RIA.FECHAINI,'DD/MM/YYYY HH24:MI:SS') AS FECHAINI
		      ,TO_CHAR(RIA.FECHAFIN,'DD/MM/YYYY HH24:MI:SS') AS FECHAFIN
		      ,TO_CHAR(REG.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS') AS FINICIAL
		      ,TO_CHAR(REG.FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS') AS FFINAL
		      ,RIA.CAUSAREGISTRADAID
		      ,REG.FDD_CAUSA_CREG
		      ,REG.FDD_AJUSTADO
		      ,REG.FDD_RADICADO
		FROM BRAE.QA_TRIA_CNSD RIA
		LEFT OUTER JOIN QA_TFDDREGISTRO REG ON (REG.FDD_CODIGOEVENTO=RIA.EVENTOID AND REG.FDD_IUA=RIA.ELEMENTO)
		WHERE RIA.ELEMENTO NOT LIKE '_T_____'
		)
WHERE EVENTOID NOT IN (SELECT DISTINCT FDD_CODIGOEVENTO
                           FROM QA_TFDDREGISTRO
													 WHERE FDD_FFINAL IS NULL)
;

SELECT * FROM QA_VRIA_CNSD;



---FROMATO TT3 VERSION SUI
SELECT C.IUS AS TT3_IUS,
(CASE WHEN (TC.TC1_TIPCONEX='T') THEN (2) ELSE (1) END) AS TT3_CLASIFICACION,
TC.TC1_IUA,
TO_CHAR(R.TT3_FINICIO,'DD-MM-YYYY HH24:MI') AS TT3_FECHA_INICIO,
TO_CHAR(R.TT3_FFIN,'DD-MM-YYYY HH24:MI') AS TT3_FECHA_FINALIZACION,
R.TT3_DESCRIPCION,
SUBSTR(R.TT3_CODIGO_PROYECTO,13,2)||SUBSTR(R.TT3_CODIGO_PROYECTO,16,5)||SUBSTR(R.TT3_CODIGO_PROYECTO,22,4)||SUBSTR(R.TT3_CODIGO_PROYECTO,27,3)||SUBSTR(R.TT3_CODIGO_PROYECTO,31,4) AS TT3_CODIGO_PROYECTO
FROM QA_TT3_RESUMEN R
LEFT OUTER JOIN QA_TT3_LLAVEBUSCAR L ON L.TT3_LLAVE_BUSCADOR=R.TT3_BUSCADOR
LEFT OUTER JOIN (SELECT DISTINCT IUS,SUBSTR(SUBESTACION,13) AS SUBESTACION FROM QA_CIRCUITO_SUBESTACION) C ON C.SUBESTACION=R.TT3_SUBESTACION
LEFT OUTER JOIN SPARD.TRANSFOR T ON T.FPARENT=L.TT3_LLAVE_CIRCUITO
LEFT OUTER JOIN (SELECT DISTINCT TC1_CODCONEX,TC1_TIPCONEX,TC1_IUA,COUNT(TC1_TC1) AS USUARIOS FROM QA_TTC1 WHERE TC1_PERIODO=:PERIODO_YYYYMM GROUP BY TC1_CODCONEX,TC1_TIPCONEX,TC1_IUA) TC ON TC.TC1_CODCONEX=T.CODE
WHERE T.CODE IS NOT NULL
AND TC.TC1_IUA IS NOT NULL
ORDER BY R.TT3_ID_DESCONEXION, R.TT3_FINICIO, L.TT3_LLAVE_CIRCUITO, T.CODE
;


---
SELECT TC1.TC1_IUA AS CODIGO_IUA  
      , I.MINICIAL AS CODIGOEVENTO_OMS  
      , I.FINICIAL AS FINICIAL_OMS 
      , I.FFINAL  AS FFINAL_OMS 
      , I.TRAFO AS CODIGOELEMENTO_OMS  
      , S.FDC_CAUSA_015 AS CAUSA_OMS 
FROM OMS.INTERUPC I  
LEFT OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL  
LEFT OUTER JOIN OMS.CAUSAS CS ON CS.CODE = MI.CAUSA  
LEFT OUTER JOIN (SELECT DISTINCT TC1_CODCONEX, TC1_IUA FROM BRAE.QA_TTC1 WHERE TC1_PERIODO = 202012) TC1 ON TC1.TC1_CODCONEX=I.TRAFO  
LEFT OUTER JOIN BRAE.QA_TFDDCAUSAS S ON S.FDC_CAUSA_OMS = MI.CAUSA 
WHERE MI.CAUSA <> 'PRUEBA'  
AND MI.TIPO <> 'PRUEBA' ---REVISA ENERGY  
AND I.TYPEEQUIP IN ('Transformer')  
AND (TO_CHAR(I.FINICIAL,'YYYYMM') = '202012' OR TO_CHAR(I.FFINAL,'YYYYMM') = '202012')  
AND TC1.TC1_IUA IS NOT NULL 
AND MI.SCADA = 1 
; 


SELECT TC1.TC1_IUA AS CODIGO_IUA  
      , I.MINICIAL AS CODIGOEVENTO_OMS  
      , I.FINICIAL AS FINICIAL_OMS 
      , I.FFINAL  AS FFINAL_OMS 
      , I.TRAFO AS CODIGOELEMENTO_OMS  
      , S.FDC_CAUSA_015 AS CAUSA_OMS 
      , R.FDD_CODIGOEVENTO AS CODIGOEVENTO_LAC 
      , TO_DATE(TO_CHAR(R.FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') AS FINICIAL_LAC 
      , TO_DATE(TO_CHAR(R.FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') AS FFINAL_LAC 
      , R.FDD_CODIGOELEMENTO AS CODIGOELEMENTO_LAC 
      , R.FDD_CAUSA_CREG AS CAUSA_LAC 
FROM OMS.INTERUPC I  
LEFT OUTER JOIN OMS.MANIOBRAS MI ON MI.CODE = I.MINICIAL  
LEFT OUTER JOIN OMS.CAUSAS CS ON CS.CODE = MI.CAUSA  
LEFT OUTER JOIN (SELECT DISTINCT TC1_CODCONEX, TC1_IUA FROM BRAE.QA_TTC1 WHERE TC1_PERIODO = 202012) TC1 ON TC1.TC1_CODCONEX=I.TRAFO  
LEFT OUTER JOIN BRAE.QA_TFDDCAUSAS S ON S.FDC_CAUSA_OMS = MI.CAUSA 
LEFT OUTER JOIN (SELECT * FROM BRAE.QA_TFDDREGISTRO  
                 WHERE TO_CHAR(FDD_FINICIAL,'YYYYMM')='202010') R ON R.FDD_CODIGOEVENTO = I.MINICIAL AND R.FDD_CODIGOELEMENTO = I.TRAFO 
WHERE MI.CAUSA <> 'PRUEBA'  
AND MI.TIPO <> 'PRUEBA' ---REVISA ENERGY  
AND I.TYPEEQUIP IN ('Transformer')  
AND (TO_CHAR(I.FINICIAL,'YYYYMM') = '202010' OR TO_CHAR(I.FFINAL,'YYYYMM') = '202010')  
AND TC1.TC1_IUA IS NOT NULL 
AND MI.SCADA = 1 
;





