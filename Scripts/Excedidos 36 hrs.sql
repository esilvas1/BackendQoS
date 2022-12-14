SELECT I.MINICIAL, I.MFINAL, 
	 TO_CHAR(I.FINICIAL,'DD/MM/YYYY HH24:mi:ss ') AS FDD_FINICIAL,
	 TO_CHAR(I.FFINAL,'DD/MM/YYYY HH24:mi:ss ') AS FDD_FFINAL, 
	 TO_CHAR(MI.FSISTEMA,'DD/MM/YYYY HH24:mi:ss ') AS F_INICIAL__SISTEMA,
	 TO_CHAR(MF.FSISTEMA,'DD/MM/YYYY HH24:mi:ss ') AS F_FINAL_SISTEMA,
	 MI.OPERADOR, I.TRAFO, I.FPARENT AS CTO_OMS,--T.FPARENT AS CTO_SPARD,
	 MI.BREAKER AS BREAKER_I, MF.BREAKER AS BREAKER_F,MI.CAUSA, 
	 MI.OBJETIVO AS OBJETIVO_INICIAL, MF.OBJETIVO AS OBJETIVO_FINAL
	 FROM OMS.INTERUPC@OMSPROD I 
	 LEFT OUTER JOIN OMS.MANIOBRAS@OMSPROD MI ON MI.CODE=I.MINICIAL
	 LEFT OUTER JOIN OMS.MANIOBRAS@OMSPROD MF ON MF.CODE=I.MFINAL
	 --LEFT OUTER JOIN SPARD.TRANSFOR T ON T.CODE=I.TRAFO
	 WHERE (MI.CAUSA <> 'PRUEBA' OR MI.TIPO <> 'PRUEBA')
	 AND I.TYPEEQUIP IN ('Transformer','Feeder')
	 AND I.FINICIAL >=TO_DATE('01/06/2019','DD/MM/YYYY HH24:MI:SS')
	 AND I.FINICIAL < TRUNC(SYSDATE)-1 --(MANIOBRAS ABIERTAS ANTES DEL DIA DE OPERACION) SE REPORTO CON CONTINUA 'S'
	 AND MI.FSISTEMA < TRUNC(I.FINICIAL)+2.25 --(MINICIAL INGRESADA EN OMS MAXIMO A LAS 06:00  2 DIAS DESPUES DE OPERACION) GARANTIZA SU REGISTRO EN QOS
	 AND I.FFINAL < TRUNC(SYSDATE)-1 --(MANIOBRA DE CIERRE MAXIMO EL DIA DE OPERACION )
	 AND MF.FSISTEMA > TRUNC(I.FFINAL)+2.25 --(MANIOBRA INGRESADA EN OMS DESPUES DE 30 HORAS DE RESTAURADO EL SERVICIO)
	 ORDER BY I.FINICIAL,I.MINICIAL,I.TRAFO;