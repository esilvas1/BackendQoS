

SELECT T.FPARENT AS ALIMENTADOR,COUNT(C.CODE) AS CANTIDAD_USR 
FROM SPARD.CUSTMETR C
LEFT OUTER JOIN SPARD.TRANSFOR T ON T.CODE=TPARENT
WHERE C.CUSTTYPE IN ('NoRegulado','Regulados','OtrosComercializ','Alumbrado')
GROUP BY T.FPARENT
ORDER BY T.FPARENT;