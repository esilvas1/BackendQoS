SELECT FDD_EXCLUSION,COUNT(FDD_EXCLUSION) 
FROM QA_TFDDREGISTRO
GROUP BY FDD_EXCLUSION;

SELECT DISTINCT(FDD_EXCLUSION) FROM QA_TFDDREGISTRO;


SELECT * FROM QA_TFDDCAUSAS;

SELECT * FROM QA_TFDDREGISTRO WHERE FDD_PERIODO_OP='09/07/2019';



/*UPDATE QA_TFDDREGISTRO R
SET
R.FDD_EXCLUSION = (SELECT FDC_EXCLUSION
                   FROM QA_TFDDCAUSAS C
                   WHERE C.FDC_CAUSA_OMS = R.FDD_CAUSA);*/
 

SELECT FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO AS CONCAT,
FDD_FINICIAL,FDD_FFINAL,
(TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss')-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24 AS "DURACION HH.hh",
(CASE WHEN ((TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss')
                                        -TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24) <= 0.05 THEN 1
                                        ELSE 20 END) AS CC
FROM QA_TFDDREGISTRO
--WHERE FDD_FFINAL IS NULL;
--WHERE FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO = '6604203T03629';      
;

SELECT TO_DATE(TO_CHAR(TRUNC(SYSDATE)+(23.95/24),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') FROM DUAL; 



SELECT CODE, CAUSA FROM OMS.MANIOBRAS@OMSPROD WHERE CODE ='662712';

   SELECT  I.MINICIAL,
           I.FINICIAL,
           I.FFINAL,
           I.TRAFO
           --(I.FFINAL-I.FINICIAL)*24 AS D,
          -- M.CAUSA
   FROM OMS.INTERUPC@OMSPROD I
   --LEFT OUTER JOIN OMS.MANIOBRAS@OMSPROD M ON I.MINICIAL=M.CODE 
   WHERE --M.CAUSA <> 'PRUEBA' 
   I.FINICIAL >= TO_DATE(TO_CHAR(TRUNC(SYSDATE-1)+(23.95/24),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
   AND I.FINICIAL < TRUNC (SYSDATE)
   AND I.FFINAL IS NOT NULL
   --AND (I.FFINAL-I.FINICIAL)*24<=0.05
   --ORDER BY I.FINICIAL;
   
   
  
;
    SELECT I.MINICIAL,
           I.FINICIAL,
           I.FFINAL,
           I.TRAFO
   FROM OMS.INTERUPC@OMSPROD I
   WHERE I.FINICIAL >= TO_DATE(TO_CHAR(TRUNC(SYSDATE-2)+(23.95/24),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
   AND I.FINICIAL < TRUNC (SYSDATE-2+1)
   AND I.FFINAL IS NOT NULL;
   
   
       SELECT I.MINICIAL,
           I.FINICIAL,
           I.FFINAL,
           I.TRAFO
   FROM OMS.INTERUPC@OMSPROD I
   WHERE I.FINICIAL >= TO_DATE(TO_CHAR(TRUNC(SYSDATE-1)+(23.95/24),'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
   AND I.FINICIAL < '14/07/2019'
   AND I.FFINAL IS NOT NULL
   AND ((I.FFINAL-I.FINICIAL)*24)<=0.05;
   
   
   
   