
SELECT FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO AS CONCAT,
FDD_FINICIAL,FDD_FFINAL,
(TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss')-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24 AS "DURACION HH.hh",
(CASE WHEN ((TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss')
                                        -TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24) <= 0.05 THEN 1
                                        ELSE 0 END) AS MENOR3MIN,
                                        FDD_CAUSA_SSPD
FROM QA_TFDDREGISTRO
WHERE (CASE WHEN ((TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss')
                                        -TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24) <= 0.05 THEN 1
                                        ELSE 0 END)=1
AND (CASE WHEN ((TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss')
                                        -TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24) <= 0.05 THEN 1
                                         ELSE 0 END)<>FDD_CAUSA_SSPD                                        
  
;

