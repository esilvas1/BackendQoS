select * from QA_TTT2_OBS;

begin
    QA_PTT2_REGISTRO(date'2023-03-01');
end;


select * from QA_TTT2_OBS
where TT2_CODIGOELEMENTO = '5T01503';

begin
    QA_PBRA11_REGISTRO(date'2023-03-01');
end;

begin
    QA_PBRA11_REPORTE(date'2023-03-01');
end;

SELECT * FROM QA_TBRA11_REPORTE
where BRA11_PERIODO_OP = date'2023-03-01';


select * from QA_TBRA11_REGISTRO
where BRA11_PERIODO_OP = date'2023-03-01';



select * from QA_TTT2_REGISTRO
    where TT2_CODIGOELEMENTO in (
        SELECT TT2_CODIGOELEMENTO
        FROM QA_TTT2_REGISTRO
        having COUNT(TT2_CODIGOELEMENTO)>2
        GROUP BY TT2_CODIGOELEMENTO
        )
order by TT2_CODIGOELEMENTO, TT2_ESTADO;

commit;

select count(1) from QA_TBRA11_REGISTRO
where BRA11_PERIODO_OP = date'2023-03-01'
;

select count(1) from QA_TTT2_REGISTRO
where TT2_PERIODO_OP = date'2023-03-01'
having COUNT(TT2_CODIGOELEMENTO) > 1;



select count(distinct TT2_CODIGOELEMENTO) from QA_TTT2_REGISTRO
where TT2_PERIODO_OP = date'2023-03-01'
and TT2_TIPOINVERSION in (1,3);

select count(TT2_CODIGOELEMENTO)
from (
    select TT2_CODIGOELEMENTO, count(TT2_CODIGOELEMENTO)
    from QA_TTT2_TEMP
    where to_char(TT2_FMODIFICACION,'yyyy-mm') = '2023-03'
    having COUNT(TT2_CODIGOELEMENTO) > 1
    group by TT2_CODIGOELEMENTO
    order by 1
     )
;



SELECT * FROM QA_TTT2_REGISTRO;

SELECT MAX(TT2_PERIODO_OP) FROM QA_TTT2_BACKUP;;


 SELECT 	T1.	TT2_CODIGOELEMENTO
        ,	T1.	TT2_IUA
        ,  (CASE WHEN T1.TT2_ESTADO='RETIRADO'
                 THEN T2.TT2_GRUPOCALIDAD
                 ELSE T1.TT2_GRUPOCALIDAD
            END) AS TT2_GRUPOCALIDAD
        ,	T1.	TT2_IDMERCADO
        ,  (CASE WHEN T1.TT2_ESTADO='RETIRADO'
                 THEN T2.TT2_CAPACIDAD
                 ELSE T1.TT2_CAPACIDAD
            END) AS TT2_CAPACIDAD
        ,  (CASE WHEN T1.TT2_ESTADO='RETIRADO'
                 THEN T2.TT2_PROPIEDAD
                 ELSE T1.TT2_PROPIEDAD
            END) AS TT2_PROPIEDAD
        ,  (CASE WHEN T1.TT2_ESTADO='RETIRADO'
                 THEN T2.TT2_TSUBESTACION
                 ELSE T1.TT2_TSUBESTACION
            END) AS TT2_TSUBESTACION
        ,  (CASE WHEN T1.TT2_ESTADO='RETIRADO'
                 THEN T2.TT2_LONGITUD
                 ELSE T1.TT2_LONGITUD
            END) AS TT2_LONGITUD
        ,  (CASE WHEN T1.TT2_ESTADO='RETIRADO'
                 THEN T2.TT2_LATITUD
                 ELSE T1.TT2_LATITUD
            END) AS TT2_LATITUD
        ,  (CASE WHEN T1.TT2_ESTADO='RETIRADO'
                 THEN T2.TT2_ALTITUD
                 ELSE T1.TT2_ALTITUD
            END) AS TT2_ALTITUD
        ,	T1.	TT2_ESTADO
        ,	T1.	TT2_ESTADO_BRA11
        ,	T1.	TT2_RESMETODOLOGIA
        ,	T1.	TT2_CLASS_CARGA
        ,	T1.	TT2_NOMBRE_CIRCUITO
        ,	T1.	TT2_IUL
        ,	T1.	TT2_CODIGOPROYECTO
        ,	T1.	TT2_UNIDAD_CONSTRUCTIVA
        ,	T1.	TT2_RPP
        ,	T1.	TT2_SALINIDAD
        ,	T1.	TT2_TIPOINVERSION
        ,	T1.	TT2_REMUNERACION_PENDIENTE
        ,	T1.	TT2_ALTERNATIVA_VALORACION
        ,	T1.	TT2_ID_PLAN
        ,	T1.	TT2_CANTIDAD
        ,	T1.	TT2_FESTADO
        ,	T1.	TT2_FCOLOCACION
        ,	T1.	TT2_FMODIFICACION
        ,	T1.	TT2_USR_COLOCACION
        ,	T1.	TT2_USR_MODFICACION
        ,	T1.	TT2_PERIODO_OP
        ,   T1. TT2_REPORTE
        ,   T1. TT2_FSISTEMA
        ,   T1. TT2_ACTIVOCONEXION
        ,   T1. TT2_ACTIVOPROVISIONAL
        ,   T1. TT2_AP_POTENCIA
        ,   T2. TT2_CODE_CALP
        ,   T1. TT2_FASES
        ,   T1. TT2_POBLACION
        ,   T1. TT2_VALOR_UC
        ,   T1. TT2_OBSERVACIONES
        ,   T1. TT2_LOCALIZACION
        ,   T1. TT2_MUNICIPIO
        ,   T1. TT2_DEPARTAMENTO
        ,   T1. TT2_NT_PRIMARIA
        ,   T1. TT2_NT_SECUNDARIA
        ,   T1. TT2_ACTIVONR
        ,   T1. TT2_G3E_FID
        ,   T1. TT2_FID_ANTERIOR
        FROM QA_TTT2_TEMP T1
        LEFT OUTER JOIN (SELECT TT2_CODIGOELEMENTO
                            ,   TT2_GRUPOCALIDAD
                            ,	TT2_IDMERCADO
                            ,	TT2_CAPACIDAD
                            ,	TT2_PROPIEDAD
                            ,	TT2_TSUBESTACION
                            ,	TT2_LONGITUD
                            ,	TT2_LATITUD
                            ,	TT2_ALTITUD
                            ,   TT2_CODE_CALP
                         FROM BRAE.QA_TTT2_REGISTRO
                         WHERE TRUNC(TT2_PERIODO_OP)<>TRUNC(date'2023-03-01')
                         ) T2 ON T2.TT2_CODIGOELEMENTO=T1.TT2_CODIGOELEMENTO
        WHERE T1.TT2_CODIGOELEMENTO IN (
                                        SELECT DISTINCT T1.TT2_CODIGOELEMENTO
                                        FROM QA_TTT2_TEMP T1
                                        INNER  JOIN (SELECT DISTINCT TT2_CODIGOELEMENTO
                                                     FROM QA_TTT2_TEMP
                                                     WHERE TT2_ESTADO = 'OPERACION'
                                                     AND   TRUNC(TT2_FCOLOCACION,'MM') = TO_DATE('01/03/2023','DD/MM/YYYY')
                                                     ) T2 ON T2.TT2_CODIGOELEMENTO = T1.TT2_CODIGOELEMENTO
                                        WHERE TT2_ESTADO = 'RETIRADO'
                                        AND TRUNC(TT2_FCOLOCACION,'MM'  ) <= date'2023-03-01'
                                        AND TRUNC(TT2_FMODIFICACION,'MM')  = DATE'2023-03-01'
                                        )
        AND T1.TT2_CODIGOELEMENTO NOT IN(
                                          SELECT DISTINCT TT2_CODIGOELEMENTO
                                          FROM QA_TTT2_REGISTRO
                                          WHERE    TT2_ACTIVOCONEXION    = 1
                                          OR       TT2_ACTIVOPROVISIONAL = 1
                                          OR       TT2_ESTADO_BRA11      = 'PLANEACION'--NO REALIZAR REPOSICIONES SOBRE LOS TRANSFORMADORES EN PLANEACION
                                          )-->NO GENERAR REPORTE DE REPOSICIONES A LOS ACTIVOS DE CONEXION, Y PROVISIONAL - POST
        ;

SELECT * FROM QA_TTT2_REGISTRO
WHERE TT2_CODIGOELEMENTO = '1T13035';
COMMIT;

SELECT *
FROM QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'OPERACION'
--AND   TRUNC(TT2_FCOLOCACION,'MM') = TO_DATE('01/03/2023','DD/MM/YYYY')
AND TT2_CODIGOELEMENTO = '3T03875';


select max(TT2_PERIODO_OP) from QA_TTT2_BACKUP;

delete from QA_TTT2_REGISTRO;

insert into QA_TTT2_REGISTRO
select * from QA_TTT2_BACKUP;


select count(1) from QA_TTT2_REGISTRO;

commit;

select * from QA_TTT2_REGISTRO
where TT2_CODIGOELEMENTO = '3T03875';

commit;

begin
    QA_PTT2_REGISTRO(date'2023-03-01');
end;

SELECT * FROM QA_TTT2_REGISTRO
WHERE TT2_PERIODO_OP = DATE'2023-03-01'
AND TT2_TIPOINVERSION IN (1,3);

select * from QA_TBRA11_REGISTRO;




SELECT   SYSDATE AS BRA11_PERIODO_OP
                ,TT2_CODIGOELEMENTO AS BRA11_CODIGOELEMENTO
                ,TT2_CODIGOPROYECTO AS BRA11_CODIGOPROYECTO
                ,TT2_IUL AS BRA11_IUL
                ,(CASE WHEN(TT2_ESTADO_BRA11<>'PLANEACION') THEN(TT2_CODE_IUA) ELSE(NULL)  END) AS BRA11_CODE_IUA
                ,(CASE WHEN(TT2_ESTADO_BRA11 ='PLANEACION') THEN(TT2_CODE_IUA) ELSE(NULL)  END) AS BRA11_CODE_IUA_PRO
                ,TT2_UNIDAD_CONSTRUCTIVA AS BRA11_UNIDAD_CONSTRUCTIVA
                ,TT2_RPP AS BRA11_RPP
                ,TT2_SALINIDAD AS BRA11_SALINIDAD
                ,TT2_TIPOINVERSION AS BRA11_TIPOINVERSION
                ,'NA' AS BRA11_OBSERVACIONES
                ,TRUNC(TT2_PERIODO_OP,'YYYY') AS BRA11_FESTADO
                ,TT2_REMUNERACION_PENDIENTE AS BRA11_REMUNERACION_PENDIENTE
                ,(CASE WHEN(TT2_ESTADO_BRA11 = 'OPERACION'   ) THEN(2)
                       WHEN(TT2_ESTADO_BRA11 = 'RETIRADO'    ) THEN(3)
                       WHEN(TT2_ESTADO_BRA11 = 'PLANEACION'  ) THEN(1)
                  END)   AS BRA11_ESTADO
                ,TT2_RESMETODOLOGIA AS BRA11_RESMETODOLOGIA
                ,(CASE WHEN(TT2_ALTERNATIVA_VALORACION = 'BRAEN') THEN(6)
                       WHEN(TT2_ALTERNATIVA_VALORACION = 'BRAFO') THEN(3)
                       WHEN(TT2_ALTERNATIVA_VALORACION = 'INVA' ) THEN(5)
                  END) AS BRA11_ALTERNATIVA_VALORACION
                ,TT2_ID_PLAN AS BRA11_ID_PLAN
                ,(CASE WHEN(TT2_TIPOINVERSION IN (1,3)) THEN(1) ELSE(0) END) AS BRA11_CANTIDAD_REPOSICIONES
                ,TT2_IDMERCADO AS BRA11_IDMERCADO
        FROM QA_TTT2_REGISTRO
        --WHERE TT2_PERIODO_OP = TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')
        WHERE   TT2_ACTIVONR = 0;

CREATE TABLE BRAE.QA_TBRA11_BACKUP
AS SELECT * FROM QA_TBRA11_REGISTRO;

DELETE FROM QA_TBRA11_REGISTRO;

COMMIT;

SELECT * FROM QA_TBRA11_BACKUP;

INSERT INTO QA_TBRA11_REGISTRO
SELECT   TRUNC(SYSDATE,'MM') AS BRA11_PERIODO_OP
                ,TT2_CODIGOELEMENTO AS BRA11_CODIGOELEMENTO
                ,TT2_CODIGOPROYECTO AS BRA11_CODIGOPROYECTO
                ,TT2_IUL AS BRA11_IUL
                ,(CASE WHEN(TT2_ESTADO_BRA11<>'PLANEACION') THEN(TT2_CODE_IUA) ELSE(NULL)  END) AS BRA11_CODE_IUA
                ,(CASE WHEN(TT2_ESTADO_BRA11 ='PLANEACION') THEN(TT2_CODE_IUA) ELSE(NULL)  END) AS BRA11_CODE_IUA_PRO
                ,TT2_UNIDAD_CONSTRUCTIVA AS BRA11_UNIDAD_CONSTRUCTIVA
                ,TT2_RPP AS BRA11_RPP
                ,TT2_SALINIDAD AS BRA11_SALINIDAD
                ,TT2_TIPOINVERSION AS BRA11_TIPOINVERSION
                ,'NA' AS BRA11_OBSERVACIONES
                ,TRUNC(TT2_PERIODO_OP,'YYYY') AS BRA11_FESTADO
                ,TT2_REMUNERACION_PENDIENTE AS BRA11_REMUNERACION_PENDIENTE
                ,(CASE WHEN(TT2_ESTADO_BRA11 = 'OPERACION'   ) THEN(2)
                       WHEN(TT2_ESTADO_BRA11 = 'RETIRADO'    ) THEN(3)
                       WHEN(TT2_ESTADO_BRA11 = 'PLANEACION'  ) THEN(1)
                  END)   AS BRA11_ESTADO
                ,TT2_RESMETODOLOGIA AS BRA11_RESMETODOLOGIA
                ,(CASE WHEN(TT2_ALTERNATIVA_VALORACION = 'BRAEN') THEN(6)
                       WHEN(TT2_ALTERNATIVA_VALORACION = 'BRAFO') THEN(3)
                       WHEN(TT2_ALTERNATIVA_VALORACION = 'INVA' ) THEN(5)
                  END) AS BRA11_ALTERNATIVA_VALORACION
                ,TT2_ID_PLAN AS BRA11_ID_PLAN
                ,(CASE WHEN(TT2_TIPOINVERSION IN (1,3)) THEN(1) ELSE(0) END) AS BRA11_CANTIDAD_REPOSICIONES
                ,TT2_IDMERCADO AS BRA11_IDMERCADO
        FROM QA_TTT2_REGISTRO
        --WHERE TT2_PERIODO_OP = TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')
        WHERE   TT2_ACTIVONR = 0;


SELECT COUNT(1)
FROM QA_TTT2_REGISTRO
        --WHERE TT2_PERIODO_OP = TRUNC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')
        WHERE   TT2_ACTIVONR = 0;

SELECT COUNT(1) FROM QA_TBRA11_BACKUP;

COMMIT;

begin
    QA_PBRA11_REPORTE(date '2023-03-01');
end;

select count(1) from QA_TBRA11_REGISTRO;

select * from QA_TBRA11_REPORTE
where BRA11_PERIODO_OP = date'2023-03-01';



        INSERT INTO BRAE.QA_TBRA11_REPORTE
        SELECT   BRA11_PERIODO_OP
                ,BRA11_CODIGOELEMENTO
                ,BRA11_CODIGOPROYECTO
                ,BRA11_IUL
                ,BRA11_CODE_IUA
                ,BRA11_CODE_IUA_PRO
                ,BRA11_UNIDAD_CONSTRUCTIVA
                ,BRA11_RPP
                ,BRA11_SALINIDAD
                ,BRA11_TIPOINVERSION
                ,BRA11_OBSERVACIONES
                ,TO_NUMBER(TO_CHAR(BRA11_FESTADO,'YYYY')) AS BRA11_FESTADO
                ,BRA11_REMUNERACION_PENDIENTE
                ,BRA11_ESTADO
                ,BRA11_RESMETODOLOGIA
                ,BRA11_ALTERNATIVA_VALORACION
                ,BRA11_ID_PLAN
                ,BRA11_CANTIDAD_REPOSICIONES
                ,BRA11_IDMERCADO
        FROM QA_TBRA11_REGISTRO
        WHERE BRA11_PERIODO_OP=date'2023-03-01'
        AND BRA11_CODIGOELEMENTO IN (select distinct TT2_CODIGOELEMENTO from QA_TTT2_REGISTRO
                                     where TT2_PERIODO_OP = date'2023-03-01')
;
        COMMIT;

select distinct TT2_CODIGOELEMENTO from QA_TTT2_REGISTRO
where TT2_PERIODO_OP = date'2023-03-01';


SELECT * FROM QA_TBRA11_REPORTE
WHERE BRA11_PERIODO_OP = DATE'2023-03-01';

COMMIT;


SELECT  TC1_TC1
      , TC1_CODCONEX
      , TT2_AP_POTENCIA AS TC1_POTENCIA
      , TC1_IDCOMER
      , TC1_CODDANE
      , MUND_DESCRIPCION
FROM QA_TTC1
LEFT OUTER JOIN (SELECT TT2_CODIGOELEMENTO
                       ,TT2_AP_POTENCIA
                 FROM QA_TTT2_BACKUP
                 WHERE TT2_ESTADO='OPERACION') ON TT2_CODIGOELEMENTO =  TC1_CODCONEX
LEFT OUTER JOIN QA_TMUNDANE ON MUND_MUNDANE = SUBSTR(TC1_CODDANE,1,5)
WHERE TC1_PERIODO=:PERIODO
AND TC1_TC1 LIKE 'CALP%';


DELETE FROM QA_TTT1_REGISTRO;

COMMIT;

SELECT * FROM QA_TTT1_REGISTRO;
COMMIT;

SELECT * FROM QA_TTT1_REPORTE;

INSERT INTO QA_TTT1_REPORTE
SELECT DATE'2023-02-01' AS TT1_PERIODO
,TT1_NOMBRECIRCUITO
,TT1_CODIGOCIRCUITO
,TT1_VOLTAJE
,TT1_GRUPOCALIDAD
,TT1_IDMERCADO
,TT1_RELE_TELECONTROL
,TT1_CANT_RELES
,TT1_ALIMENT_RADIAL
,TT1_NORM_ABIERTO
,TT1_LONGITUD
,TT1_LATITUD
,TT1_ALTITUD
,TT1_PORC_PROPIEDAD
FROM QA_TTT1_REGISTRO
WHERE TT1_NOMBRECIRCUITO NOT IN ('CANO1');


COMMIT;

select * from QA_TTT2_REPORTE
where TT2_CODE_TRAFO = '1T13535'; --



select * from QA_TTT2_REGISTRO
where TT2_CODIGOELEMENTO in ('1T04228'	,'1T04702'	,'1T04711'	,'1T04741'	,'1T09027'	,'1T13203'	,'5T00691'	,'1T00471'	,'1T01754'	,'1T02112'	,'1T02354'	,'1T07197'	,'1T09522'	,'3T00648'	,'3T01465'	,'3T01589'	,'3T02234'	,'5T00761'	,'3T02631'	,'5T01434')

select * from QA_TTT2_REGISTRO
where TT2_CODE_IUA in ('100JNI0101',
'100JUP009Z',
'100JKL009Z',
'100JV3009Z',
'100JT4009Z',
'100J1V009B',
'100JF60107',
'10005I0001',
'1000O10001',
'1006DU0001',
'1000UQ0001',
'10024Z0001',
'1009UH0001',
'1003US0001',
'100IQF009Z',
'1008O40001',
'100IWK0101',
'10097K0001',
'100G9J009Z',
'100IQW009Z');


SELECT MAX(TO_NUMBER(QA_FBASE_CONV(SUBSTR(TT2_CODE_IUA,2,5),36,10))) AS MAX_CONSEC
        --INTO MAX_CONSECUTIVO_IUA
FROM BRAE.QA_TTT2_REGISTRO
WHERE TT2_CODE_IUA IS NOT NULL;

--26660 maximos asignado

select * from QA_TTT2_CODIGO_UC;

/
declare
begin
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKL0098' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T12' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T00471';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKM0098' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T12' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T01754';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKN0101' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T40' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T02112';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKO0098' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T12' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T02354';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKP0101' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T40' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T04228';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKQ009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T04702';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKR009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T04711';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKS009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T04741';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKT0101' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T40' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T07197';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKU009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T09027';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKV009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T09522';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKW009B' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T14' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '1T13203';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKY0102' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T41' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '3T00648';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KKZ009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '3T01465';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KL0009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '3T01589';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KL1009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '3T02234';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KL2009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '3T02631';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KL3009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '5T00691';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KL4009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '5T00761';
UPDATE QA_TTT2_REGISTRO SET TT2_CODE_IUA ='100KL5009Z' , TT2_UNIDAD_CONSTRUCTIVA = 'N1T38' , TT2_OBSERVACIONES = 'Recodificacion para PIR 2022' WHERE TT2_CODIGOELEMENTO = '5T01434';
end;

commit;

select count(1) from QA_TCOMPENSAR
where fecha = date'2022-07-01'
;
commit;


UPDATE QA_TTC1_TEMP
SET TC1_DIREC = SUBSTR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TC1_DIREC,'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'Ñ','N'),'(',' '),')',' '),'\',' '),'/',' '),',',' '),'.',' '),'°',' '),'À',' '),'1º',' '),'2°',' '),'3°',' '),'º',' '),'·',' '),'ñ','n'),'´',' '),' ',' '),'#',' '),'ª',' '),'Ò',' '),'¿',''),'Â¿',''),'Â',''),1,50)
WHERE ROWNUM >= 0
;



COMMIT;



   SELECT COUNT(DISTINCT FDD_AJUSTADO) AS AJUSTADO
    FROM QA_TFDDREGISTRO
    WHERE TRUNC(FDD_FINICIAL,'MM') = date'2023-03-01'
    AND   FDD_AJUSTADO = 'S'
    ;



BEGIN
    QA_PBRA11_REGISTRO(DATE'2023-04-01');
end;

SELECT MAX(BRA11_PERIODO_OP) FROM QA_TBRA11_REGISTRO;


select * from QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'OPERACION'
AND TT2_G3E_FID IS NOT  NULL;


SELECT * FROM QA_TTT2_TEMP;


SELECT *
FROM QA_TTT2_TEMP
WHERE TT2_ESTADO = 'OPERACION'
AND   TRUNC(TT2_FCOLOCACION,'MM') = date'2023-04-01'
AND   TT2_G3E_FID  <> TT2_FID_ANTERIOR
;


                                        SELECT *
                                        FROM QA_TTT2_TEMP T1
                                        INNER  JOIN (SELECT DISTINCT TT2_CODIGOELEMENTO
                                                     FROM QA_TTT2_TEMP
                                                     WHERE TT2_ESTADO = 'OPERACION'
                                                     AND   TRUNC(TT2_FCOLOCACION,'MM') = DATE'2023-04-01'
                                                     AND   TT2_G3E_FID <> TT2_FID_ANTERIOR
                                                     ) T2 ON T2.TT2_CODIGOELEMENTO = T1.TT2_CODIGOELEMENTO
                                        WHERE TT2_ESTADO = 'RETIRADO'
                                        AND TRUNC(TT2_FCOLOCACION,  'MM') <= DATE'2023-04-01'--
                                        AND TRUNC(TT2_FMODIFICACION,'MM')  = DATE'2023-04-01'--Identifica que se hayan realizado el mes de operacion
;



SELECT *
 FROM QA_TTT2_TEMP
 WHERE TT2_ESTADO = 'OPERACION'
 AND   TRUNC(TT2_FCOLOCACION,'MM') = DATE'2023-04-01'
 AND   TT2_G3E_FID <> TT2_FID_ANTERIOR;


begin
    QA_PTT2_REGISTRO(date'2023-04-01');
end;

select *
from QA_TTT2_REGISTRO
    where TT2_CODIGOELEMENTO in (
                                select TT2_CODIGOELEMENTO
                                from QA_TTT2_REGISTRO
                                having count(TT2_CODIGOELEMENTO) > 2
                                group by TT2_CODIGOELEMENTO
        )
order by TT2_CODIGOELEMENTO,TT2_ESTADO;



    select TT2_CODIGOELEMENTO
    from QA_TTT2_REGISTRO
    having count(TT2_CODIGOELEMENTO) > 2
    group by TT2_CODIGOELEMENTO;



CREATE TABLE QA_TTT2_REP_PENDIENTES AS
select *
from QA_TTT2_REGISTRO
    where TT2_CODIGOELEMENTO in (
                                select TT2_CODIGOELEMENTO
                                from QA_TTT2_REGISTRO
                                having count(TT2_CODIGOELEMENTO) > 2
                                group by TT2_CODIGOELEMENTO
        )
order by TT2_CODIGOELEMENTO,TT2_ESTADO;


SELECT * FROM QA_TTT2_REP_PENDIENTES;
DELETE FROM QA_TTT2_REP_PENDIENTES;
COMMIT;


SELECT * FROM QA_TTT2_BACKUP;

UPDATE QA_TTT2_BACKUP
SET TT2_CLASS_CARGA = '1'
;

UPDATE QA_TTT2_REGISTRO
SET TT2_CLASS_CARGA = '1'
;

COMMIT;

DELETE FROM QA_TTT2_REGISTRO;

SELECT * FROM QA_TTT2_REGISTRO;

INSERT INTO QA_TTT2_REGISTRO
SELECT * FROM QA_TTT2_BACKUP;


COMMIT;


begin
    QA_PTT2_REGISTRO(date'2023-04-01');
end;


DELETE FROM QA_TTT2_REP_PENDIENTES
WHERE TT2_PERIODO_OP = TRUC(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'));
COMMIT;

INSERT INTO QA_TTT2_REP_PENDIENTES
SELECT * FROM QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'RETIRADO'
AND   TT2_CLASS_CARGA = '0';
COMMIT;

DELETE FROM QA_TTT2_REGISTRO
WHERE TT2_ESTADO = 'RETIRADO'
AND   TT2_CLASS_CARGA = '0';
COMMIT;



SELECT * FROM QA_TTT2_REP_PENDIENTES;

select * from QA_TTT2_REGISTRO
where TT2_ESTADO = 'RETIRADO'
AND TT2_CODIGOELEMENTO IN ('5T01261',	'5T01487',	'5T00311',	'1T04724',	'3T00325',	'5T01389',	'5T01640',	'1T08372',	'3T02401');


begin
    QA_PTC1_REGISTRO_FASE2(date'2023-04-01');
end;


delete from QA_TTC1_TEMP;

select * from QA_TTC1_TEMP;

commit;

insert into QA_TTC1_USRS_COMER
select * from QA_TTC1
where TC1_PERIODO = '202303'
and TC1_IDCOMER <> '604'
and tc1_tc1 not like 'CALP%'
AND TC1_TIPCONEX = 'T';

select * FROM QA_TTC1_USRS_COMER;


update QA_TTC1_USRS_COMER
set TC1_PERIODO = null;

commit;

select * from QA_TTC1_TEMP;


begin
    QA_PTC1_REGISTRO_FASE1(date'2023-04-01');
end;

begin
    QA_PTC1_REGISTRO_FASE2(date'2023-04-01');
end;

select distinct TC1_CODDANE from QA_TTC1_TEMP;

insert into QA_TTC1
select * from QA_TTC1_TEMP;

commit;

SELECT sys_context('USERENV','OS_USER') from dual;

DELETE from QA_TTT12_REPORTE
where TT12_PERIODO_OP=date'2023-04-01';

COMMIT;

SELECT TO_CHAR(TRUNC(SYSDATE),'') FROM DUAL;

SELECT TC1_CODCIRC AS CODIGO_IUL,COUNT(TC1_CODCIRC) AS CANTIDAD_USRS, TT1_NOMBRECIRCUITO AS NOMBRE_CIRCUITO
FROM QA_TTC1
LEFT OUTER JOIN QA_TTT1_REGISTRO ON TT1_CODIGOCIRCUITO = TC1_CODCIRC
WHERE TC1_PERIODO=202212
AND TC1_TC1 NOT LIKE 'CALP%'
AND TC1_CODCONEX NOT LIKE 'ALPM%'
GROUP BY TC1_CODCIRC, TT1_NOMBRECIRCUITO;

SELECT * FROM QA_TTT1_REGISTRO;


--CLIENTES ACTIVOS DE CONEX
SELECT TC1_CODCONEX AS CODIGO_TRANSFORMADOR
     , TC1_CODFRONCOM AS FRONTERA_COMERCIAL
     , TT2_CAPACIDAD AS CAPACIDAD_TRAFO
FROM QA_TTC1
LEFT OUTER JOIN (SELECT TT2_CODIGOELEMENTO
                      , TT2_CAPACIDAD
                      , TT2_ACTIVOCONEXION
                      , TT2_ACTIVOPROVISIONAL
                 FROM QA_TTT2_REGISTRO
                 WHERE TT2_ESTADO = 'OPERACION') ON TT2_CODIGOELEMENTO = TC1_CODCONEX
WHERE TC1_PERIODO = 202212
AND TC1_TC1 NOT LIKE 'CALP%'
AND TC1_CODCONEX NOT LIKE 'ALPM%'
AND TT2_ACTIVOPROVISIONAL = 0
HAVING COUNT(TC1_CODCONEX) = 1
GROUP BY TC1_CODCONEX, TC1_CODFRONCOM, TT2_CAPACIDAD, TT2_ACTIVOPROVISIONAL;

SELECT TC1_CODCONEX AS CODIGO_TRANSFORMADOR
     , TC1_CODFRONCOM AS FRONTERA_COMERCIAL
FROM QA_TTC1
WHERE TC1_PERIODO = 202212
AND TC1_TC1 NOT LIKE 'CALP%'
AND TC1_CODCONEX NOT LIKE 'ALPM%'
HAVING COUNT(TC1_CODCONEX) = 1
GROUP BY TC1_CODCONEX, TC1_CODFRONCOM;

--trafo-usuario
select TC1_CODCONEX, tc1_tc1, TC1_NT, TC1_NTP from QA_TTC1
where TC1_PERIODO = 202212;


SELECT * FROM QA_TCONSOLIDADO_SUI
WHERE FDD_NIU LIKE 'CALP%'
AND FDD_ES_ALUMBRADO = 0


SELECT * FROM QA_TCONSOLIDADO_LAC
WHERE FDD_YEAR = '2022';

SELECT * FROM QA_TCONSOLIDADO_OR;

COMMIT;

DELETE FROM QA_TCONSOLIDADO_OR;

COMMIT;

INSERT INTO QA_TCONSOLIDADO_OR
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



SELECT * FROM QA_TCONSOLIDADO_OR
LEFT OUTER JOIN (SELECT DISTINCT FDC_CAUSA_015, FDC_EXCLUSION FROM QA_TFDDCAUSAS) ON FDC_CAUSA_015 = FDD_CAUSA_CREG
WHERE FDC_EXCLUSION = 'EXCLUIDA';


SELECT * FROM QA_TCONSOLIDADO_OR
WHERE FDD_CAUSA_CREG IN ('45','28','17','41','4');

COMMIT;


RENAME QA_TCONSOLIDADO_LAC to QA_TCONSOLIDADO_LAC_EVENTOS;
RENAME QA_TCONSOLIDADO_OR to QA_TCONSOLIDADO_OR_EVENTOS;
RENAME QA_TCONSOLIDADO_SUI to QA_TCONSOLIDADO_SUI_USUARIOS;

SELECT * FROM QA_TCONSOLIDADO_SUI_USUARIOS;


SELECT * FROM QA_TCONSOLIDADO_SUI_USUARIOS
;
--INSERT INTO QA_TCONSOLIDADO_OR_USUARIOS
SELECT TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'YYYY') AS FDD_YEAR
      ,TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'), 'MM') AS FDD_MONTH
      ,'CNSD' AS FDD_COD_ASIC
      ,TC1_TC1 AS FDD_NIU
      ,TC1_IUA AS FDD_CODIGOELEMENTO
      ,(case when TC1_TIPCONEX = 'T' then 1 else 2 end ) AS FDD_TIPOELEMENTO
      ,TC1_GC AS FDD_GRUPOCALIDAD
      ,TC1_NT AS FDD_NIVEL
      ,ROUND((CASE WHEN TC1_TC1 LIKE 'CALP%' THEN NVL(CSX_DIUM_AP,0) ELSE NVL(CSX_DIUM,0) END),13) AS FDD_TIEMPONETO
      ,ROUND(NVL(CSX_DIUM,0),13) AS FDD_TIEMPO_SIN_EXCL_AP
      ,(CASE WHEN TC1_TC1 LIKE 'CALP%' THEN 1 ELSE 0 END) AS FDD_ES_ALUMBRADO
FROM QA_TTC1
LEFT OUTER JOIN (
    SELECT CSX_TRANSFOR, CSX_DIUM,CSX_DIUM_AP FROM QA_TCSX
    WHERE CSX_PERIODO_OP = TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS')
) ON CSX_TRANSFOR = TC1_CODCONEX
WHERE TC1_PERIODO = TO_CHAR(TO_DATE(:FECHAOPERACION,'DD/MM/YYYY HH24:MI:SS'),'YYYYMM')
AND TC1_TIPCONEX = 'T'
AND TC1_CODCONEX NOT LIKE 'ALPM%'
;

CREATE TABLE QA_TCONSOLIDADO_OR_USUARIOS AS
SELECT * FROM QA_TCONSOLIDADO_SUI_USUARIOS
WHERE FDD_NIU = '1020994';


DELETE FROM QA_TCONSOLIDADO_OR_USUARIOS;
COMMIT;

SELECT * FROM QA_TCONSOLIDADO_OR_USUARIOS;


select tc1_tc1, tc1_nt from qa_ttc1_temp;



select * from QA_TTT2_REGISTRO
where TT2_ACTIVOPROVISIONAL = 1;
