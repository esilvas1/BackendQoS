SELECT * FROM QA_TFDDREPORTE
WHERE FDR_PERIODO_OP >= '01/07/2019' ;

SELECT * FROM QA_TFDDREPORTE
WHERE FDR_PERIODO_OP like '%/07/19' ;



SELECT R1.FDR_CODIGOEVENTO,R1.FDR_FINICIAL,R2.FDR_FFINAL 
FROM QA_TFDDREPORTE R1
LEFT OUTER JOIN (SELECT FDR_FFINAL,FDR_CODIGOEVENTO,FDR_CODIGOELEMENTO FROM QA_TFDDREPORTE WHERE FDR_FFINAL IS NOT NULL) R2 ON R2.FDR_CODIGOEVENTO||R2.FDR_CODIGOELEMENTO=R1.FDR_CODIGOEVENTO||R1.FDR_CODIGOELEMENTO
WHERE R1.FDR_CODIGOEVENTO<>'NA'
AND R1.FDR_CODIGOEVENTO IS NOT NULL
ORDER BY 1
;


SELECT DISTINCT(FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO) FROM QA_TFDDREGISTRO WHERE FDD_TIPOCARGA <> 'NR';

SELECT DISTINCT(FDR_CODIGOEVENTO||FDR_CODIGOELEMENTO) FROM QA_TFDDREPORTE WHERE FDR_CODIGOEVENTO<>'NA';



SELECT DISTINCT(FDD_CODIGOEVENTO) FROM QA_TFDDREGISTRO WHERE FDD_TIPOCARGA <> 'NR';
SELECT DISTINCT(FDR_CODIGOEVENTO) FROM QA_TFDDREPORTE WHERE FDR_CODIGOEVENTO<>'NA';


SELECT DISTINCT(REG.FDD_CODIGOEVENTO),REP.FDR_CODIGOEVENTO
FROM QA_TFDDREGISTRO REG
LEFT OUTER JOIN (SELECT DISTINCT(FDR_CODIGOEVENTO) FROM QA_TFDDREPORTE WHERE FDR_CODIGOEVENTO<>'NA') REP ON REP.FDR_CODIGOEVENTO=REG.FDD_CODIGOEVENTO
WHERE FDD_TIPOCARGA <> 'NR'
AND REP.FDR_CODIGOEVENTO IS NULL;



SELECT DISTINCT(REP.FDR_CODIGOEVENTO),REG.FDD_CODIGOEVENTO
FROM QA_TFDDREPORTE REP
LEFT OUTER JOIN (SELECT DISTINCT(FDD_CODIGOEVENTO) FROM QA_TFDDREGISTRO WHERE  FDD_TIPOCARGA <> 'NR') REG ON REP.FDR_CODIGOEVENTO=REG.FDD_CODIGOEVENTO
WHERE  REP.FDR_CODIGOEVENTO<>'NA'
AND REG.FDD_CODIGOEVENTO IS NULL;

SELECT * FROM QA_TFDDREPORTE
WHERE FDR_CODIGOEVENTO IN (SELECT DISTINCT(REP.FDR_CODIGOEVENTO)
                            FROM QA_TFDDREPORTE REP
                            LEFT OUTER JOIN (SELECT DISTINCT(FDD_CODIGOEVENTO) FROM QA_TFDDREGISTRO WHERE  FDD_TIPOCARGA <> 'NR') REG ON REP.FDR_CODIGOEVENTO=REG.FDD_CODIGOEVENTO
                            WHERE  REP.FDR_CODIGOEVENTO<>'NA'
                            AND REG.FDD_CODIGOEVENTO IS NULL);


SELECT * FROM QA_TFDDREGISTRO
WHERE FDD_CODIGOEVENTO IN (SELECT DISTINCT(REP.FDR_CODIGOEVENTO)
                            FROM QA_TFDDREPORTE REP
                            LEFT OUTER JOIN (SELECT DISTINCT(FDD_CODIGOEVENTO) FROM QA_TFDDREGISTRO WHERE  FDD_TIPOCARGA <> 'NR') REG ON REP.FDR_CODIGOEVENTO=REG.FDD_CODIGOEVENTO
                            WHERE  REP.FDR_CODIGOEVENTO<>'NA'
                            AND REG.FDD_CODIGOEVENTO IS NULL)
AND FDD_CODIGOELEMENTO IN (SELECT FDR_CODIGOELEMENTO FROM QA_TFDDREPORTE
                            WHERE FDR_CODIGOEVENTO IN (SELECT DISTINCT(REP.FDR_CODIGOEVENTO)
                            FROM QA_TFDDREPORTE REP
                            LEFT OUTER JOIN (SELECT DISTINCT(FDD_CODIGOEVENTO) FROM QA_TFDDREGISTRO WHERE  FDD_TIPOCARGA <> 'NR') REG ON REP.FDR_CODIGOEVENTO=REG.FDD_CODIGOEVENTO
                            WHERE  REP.FDR_CODIGOEVENTO<>'NA'
                            AND REG.FDD_CODIGOEVENTO IS NULL))
                            ;                   
                            
