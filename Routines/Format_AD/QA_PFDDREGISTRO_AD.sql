CREATE OR REPLACE PROCEDURE BRAE.QA_PFDDREGISTRO_AD(FECHAOPERACION IN DATE)
AS
BEGIN
	
	DELETE FROM QA_TFDDREGISTRO_AD 
	WHERE TO_CHAR(FDD_FINICIAL,'YYYYMM') = TO_CHAR(FECHAOPERACION,'YYYYMM'); 
	COMMIT;
	
	INSERT INTO QA_TFDDREGISTRO_AD
	select DISTINCT
	b.eve_id AS FDD_CODIGO_EVENTO,                                                  --EVENTO TCS
	b.eve_fecha_inicial as FDD_FINICIAL,           -- fecha_inicial_evento
	b.eve_fecha_final as FDD_FFINAL,               -- fecha_final_evento,     
	X.CLIENTE AS FDD_ELEMENTO,                                                      --USUARIO_TC1
	NULL AS FDD_TIPOELEMENTO,                                                       
	NULL AS FDD_CONSUMODIA,                                                                              
	NULL AS FDD_ENS_ELEMENTO,
	NULL AS FDD_ENS_EVENTO,
	NULL AS FDD_ENEG_ELEMENTO,
	NULL AS FDD_ENEG_EVENTO,
	NULL AS FDD_CODIGO_GENERADOR,
	c.code as FDD_CAUSA,
	c.causa015 AS FDD_CAUSA_CREG,
	NULL AS FDD_USUARIOAP,
	NULL AS FDD_CONTINUIDAD,
	NULL AS FDD_ESTADO_REPORTE,
	NULL AS FDD_PUBLICADO,
	NULL AS FDD_RECONFIG,
	to_char(b.eve_fecha_inicial,'DD/MM/YYYY') as FDD_PERIODO_OP,
	to_char(SYSDATE,'DD/MM/YYYY') as FDD_FREG_APERTURA,
	to_char(SYSDATE,'DD/MM/YYYY') as FDD_FREG_CIERRE,
	to_char(SYSDATE,'DD/MM/YYYY') as FDD_FPUB_APERTURA,
	to_char(SYSDATE,'DD/MM/YYYY') as FDD_FPUB_APERTURA,
	X.PERIODO_TC1 AS FDD_PERIODO_TC1,
	NULL AS FDD_TIPOCARGA,
	cbt.fdc_exclusion AS FDD_EXCLUSION,
	NULL AS FDD_CAUSA_SSPD,
	NULL AS FDD_AJUSTADO,
	NULL AS FDD_TIPOAJUSTE,
	NULL AS FDD_RADICADO,
	NULL AS FDD_APROBADO,
	NULL AS FDD_IUA
	from oms.gev_eve_evento b
	left join  oms.gev_lmd_llamada a
	on  a.eve_id = b.eve_id
	left join  oms.causas C on c.cev_id = b.cev_id
	left join BRAE.QA_TFDDCAUSAS_BT CBT ON cbt.fdc_causa_oms = c.code
	left join (
	            SELECT A.TC1_TC1 ||'-'|| TC1_PERIODO as clienteperiodo, A.TC1_TC1 as CLIENTE, TC1_PERIODO AS PERIODO_TC1
	            FROM BRAE.QA_TTC1 A
	            WHERE TC1_PERIODO >= TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYYMM'))
	            ) x on A.CLI_ID||'-'||to_char(b.eve_fecha_inicial,'YYYYMM') = x.clienteperiodo
	where TO_CHAR(b.eve_fecha_inicial,'YYYYMM') >= TO_CHAR(FECHAOPERACION,'YYYYMM')
	and c.code like ('8%')
	and X.CLIENTE is not null
	order by 1;
	
	COMMIT;

	INSERT INTO QA_TLOG_EJECUCION
    SELECT SYSDATE,'QA_PFDDREGISTRO_AD','PROCEDIMIENTO',UPPER(sys_context('USERENV','OS_USER')),'EXITOSO','Se ha ejecutado el procedimiento '||FECHAOPERACION FROM DUAL;
   	COMMIT;

END QA_PFDDREGISTRO_AD;