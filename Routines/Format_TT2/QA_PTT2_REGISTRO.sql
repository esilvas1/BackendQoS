CREATE OR REPLACE PROCEDURE BRAE.QA_PTT2_REGISTRO(FECHAOPERACION DATE)
AS
  TYPE T_QA_TTT2_REGISTRO IS TABLE OF QA_TTT2_REGISTRO%ROWTYPE;
  V_QA_TTT2_REGISTRO T_QA_TTT2_REGISTRO;

  MAX_CONSECUTIVO_IUA  NUMBER;
  MAX_CONSECUTIVO_CALP NUMBER;
  NOREPORT             NUMBER;
  NOREPORT_ANT         NUMBER;
  CANT_REGIST_OP       NUMBER;
  CANT_REGIST_ANT      NUMBER;
  HORA_INICIO          DATE;
  HORA_FIN             DATE;
  AJUSTADO             NUMBER;
  BRA11                NUMBER;
  
   --V_ACTIVOS
  TYPE RECORD_ACTIVOS IS RECORD
  (TT2_CODIGOELEMENTO BRAE.QA_TTT2_REGISTRO.TT2_CODIGOELEMENTO%TYPE);
  TYPE TABLE_ACTIVOS IS TABLE OF RECORD_ACTIVOS;
  V_ACTIVOS TABLE_ACTIVOS;

   --V_ACT_TIPOPROYECTO
  TYPE RECORD_ACT_TIPOPROYECTO IS RECORD
  (
   TT2_CODIGOELEMENTO      BRAE.QA_TTT2_REGISTRO.TT2_CODIGOELEMENTO%TYPE
  ,TT2_UNIDAD_CONSTRUCTIVA BRAE.QA_TTT2_REGISTRO.TT2_UNIDAD_CONSTRUCTIVA%TYPE
  ,TT2_FMODIFICACION       BRAE.QA_TTT2_REGISTRO.TT2_FMODIFICACION%TYPE
  );
  TYPE TABLE_ACT_TIPOPROYECTO IS TABLE OF RECORD_ACT_TIPOPROYECTO;
  V_ACT_TIPOPROYECTO TABLE_ACT_TIPOPROYECTO;

   --V_ACT_FORIUA
  TYPE RECORD_FORIUA IS RECORD
  (
   TT2_CODIGOELEMENTO      BRAE.QA_TTT2_REGISTRO.TT2_CODIGOELEMENTO%TYPE
  ,TT2_FMODIFICACION       BRAE.QA_TTT2_REGISTRO.TT2_FMODIFICACION%TYPE
  ,TT2_CODIGO_UC           BRAE.QA_TTT2_CODIGO_UC.TT2_CODIGO_UC%TYPE
  );
  TYPE TABLE_FORIUA IS TABLE OF RECORD_FORIUA;
  V_FORIUA TABLE_FORIUA;
  
  --V_ACT_FORIUA
  TYPE RECORD_FORCALP IS RECORD
  (TT2_CODIGOELEMENTO      BRAE.QA_TTT2_REGISTRO.TT2_CODIGOELEMENTO%TYPE);
  TYPE TABLE_FORCALP IS TABLE OF RECORD_FORCALP;
  V_FORCALP TABLE_FORCALP;
  
BEGIN

--ASIGNACION DE VARIABLE NOREPORT -- CANTIDAD DE REGISTROS NO REPORTADOS
  SELECT COUNT(TT2_CODIGOELEMENTO)
  INTO NOREPORT_ANT
  FROM QA_TTT2_REGISTRO
  WHERE TT2_PERIODO_OP = ADD_MONTHS(FECHAOPERACION,-1)
  AND   TT2_ESTADOREPORTE = 0;


--ASIGNACION DE VARIABLE CANT_REGIST_ANT -- CANTIDAD DE REGISTROS DEL PERIODO DE OPERACION t-1
  SELECT COUNT(TT2_CODIGOELEMENTO)
  INTO CANT_REGIST_ANT
  FROM QA_TTT2_REGISTRO
  WHERE TT2_PERIODO_OP = ADD_MONTHS(FECHAOPERACION,-1);   

--ASIGNACION DE VARIABLE NOREPORT -- CANTIDAD DE REGISTROS NO REPORTADOS
  SELECT COUNT(TT2_CODIGOELEMENTO)
  INTO NOREPORT
  FROM QA_TTT2_REGISTRO
  WHERE TT2_PERIODO_OP = TRUNC(FECHAOPERACION)
  AND   TT2_ESTADOREPORTE = 0;
  
--ASIGNACION DE VARIABLE CANT_REGIST_OP -- CANTIDAD DE REGISTROS DEL PERIODO DE OPERACION
  SELECT COUNT(TT2_CODIGOELEMENTO)
  INTO CANT_REGIST_OP
  FROM QA_TTT2_REGISTRO
  WHERE TT2_PERIODO_OP = TRUNC(FECHAOPERACION); 
 
 --VERIFICACION DE ACCION DE AJUSTES REALIZADOS EN LA BASE DE DATOS PARA EL PERIODO 
  SELECT COUNT(DISTINCT FDD_AJUSTADO) AS AJUSTADO
  INTO AJUSTADO
  FROM QA_TFDDREGISTRO
  WHERE TRUNC(FDD_FINICIAL,'MM') = TRUNC(FECHAOPERACION)
  AND   FDD_AJUSTADO = 'S'
  ;

  --VERIFICACION DE GENERACION DE FORMATO BRA11 (m-1)
  SELECT COUNT(*) 
  INTO BRA11
  FROM  BRAE.QA_TBRA11_REGISTRO
  WHERE BRA11_PERIODO_OP =  ADD_MONTHS(TRUNC(FECHAOPERACION),-1);  

  
  IF      ((CANT_REGIST_OP = 0 ) OR (NOREPORT     > 0)) 
      AND ((CANT_REGIST_ANT > 0) OR (NOREPORT_ANT = 0)) 
      AND   AJUSTADO = 0
      AND   BRA11    > 0
  THEN
       
        HORA_INICIO:=SYSDATE;
        DBMS_OUTPUT.PUT_LINE('Writing = ON  ..'||HORA_INICIO);
  
     --BORRADO DE LA TABLA QA_TTT2_TEMP;
       DELETE FROM QA_TTT2_TEMP
       WHERE ROWNUM >= 0;
       COMMIT;
       


  --REVERSADO DE INOFORMACION PARA EJECUTAR EL PROCEDIMEIENTO VARIAS VECES SI SE DESA
        IF NOREPORT > 0 THEN
           --REVERSAR
            --SE ACTUALIZA LOS MODIFICADOS DE REPOSICION
            UPDATE BRAE.QA_TTT2_REGISTRO
            SET    TT2_PERIODO_OP             =  ADD_MONTHS(TRUNC(TT2_FSISTEMA,'MM'),-1),
                   TT2_ALTERNATIVA_VALORACION = 'BRAEN',
                   TT2_ESTADO                 = 'OPERACION',
                   TT2_ESTADO_BRA11           = 'OPERACION',
                   TT2_FESTADO                =  ADD_MONTHS(LAST_DAY(TT2_FSISTEMA),-1),
                   TT2_TIPOINVERSION           = '2'
            WHERE  TT2_ESTADOREPORTE          =  1
            AND    TT2_TIPOINVERSION IN ('1','3')
            AND    TT2_PERIODO_OP = FECHAOPERACION;
            COMMIT;
            
            --SE ACTUALIZAN(REVERSAN) LOS MODIFICADOS DE TRANSICION PLANEACION-OPERACION
            UPDATE BRAE.QA_TTT2_REGISTRO
            SET    TT2_PERIODO_OP             =  ADD_MONTHS(TRUNC(TT2_FSISTEMA,'MM'),-1)
                  ,TT2_ALTERNATIVA_VALORACION = 'INVA'
                  ,TT2_ESTADO_BRA11           = 'PLANEACION'
                  ,TT2_OBSERVACIONES          =  NULL
                  ,TT2_ESTADOREPORTE          =  1                  
            WHERE  TT2_ESTADOREPORTE          =  0
            AND    TT2_OBSERVACIONES          = 'Transicion PLANEACION a OPERACION en BRA11'
            AND    TT2_PERIODO_OP             = FECHAOPERACION;
            
            COMMIT;     
            
            --ELIMINO LOS NUEVOS DE EXPANSION Y LOS NUEVOS DE REPOSICION
            DELETE 
            FROM  QA_TTT2_REGISTRO
            WHERE TT2_ESTADOREPORTE = 0
            AND   TT2_PERIODO_OP    = FECHAOPERACION;           
            COMMIT;
           
        ELSE

            --CREACION DE BACKUP DE LA TABLA QA_TTT2_REGISTRO
            DELETE FROM BRAE.QA_TTT2_BACKUP
            WHERE ROWNUM >= 0;
            COMMIT;

            INSERT INTO BRAE.QA_TTT2_BACKUP SELECT * FROM BRAE.QA_TTT2_REGISTRO;
            COMMIT;

            --INSERTAR LOS BRAFOS EN LA TABLA QA_TTT2_ELIMINADOS
            INSERT INTO BRAE.QA_TTT2_BRAFO
            SELECT * FROM BRAE.QA_TTT2_REGISTRO
            WHERE  TT2_ESTADO='RETIRADO';
            COMMIT;

            --BORRADO DE LOS TRANSFORMADORES RETIRADOS PERIODO ANTERIOR;
            DELETE FROM QA_TTT2_REGISTRO
            WHERE  TT2_ESTADO = 'RETIRADO';
            COMMIT;

            --MARCACION DEL CAMPO TT2_CLASS_CARGA
            UPDATE QA_TTT2_REGISTRO
                SET TT2_CLASS_CARGA = '1'
            WHERE ROWNUM >= 0;
            COMMIT;

        END IF;
        
        --BORRADO DE LA TABLA QA_TT2_OBS;
        DELETE FROM QA_TTT2_OBS
        WHERE ROWNUM >= 0;
        COMMIT;

        
       --CARGAR DATOS DE TRANSFERENCIA DE GTECH A BRAE 
       --V_QA_TTT2_REGISTRO.DELETE;
         WITH INFO_AP AS
        (SELECT  SUBSTR(CON.NODO_TRANSFORM_V,1,20) AS NODO_TRANSFORM_V,SUM(TO_NUMBER(TRIM(REPLACE(LUM.POTENCIA,'.',',')))) AS POTENCIA_INSTALADA
         FROM CCONECTIVIDAD_E@GTECH CON
         JOIN CCOMUN@GTECH COM ON CON.G3E_FID=COM.G3E_FID
         JOIN ELUMINAR_AT@GTECH LUM ON  LUM.G3E_FID = CON.G3E_FID
         WHERE CON.G3E_FNO = 21400
         AND  COM.ESTADO <> 'RETIRADO'
         AND  CON.NODO_TRANSFORM_V IS NOT NULL
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
            ,TRUNC(FECHAOPERACION)                        AS TT2_PERIODO_OP
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
        BULK COLLECT INTO   V_QA_TTT2_REGISTRO
        FROM                CCONECTIVIDAD_E@GTECH  CON
            LEFT OUTER JOIN CCOMUN@GTECH           COM  ON  COM.G3E_FID            = CON.G3E_FID
            LEFT OUTER JOIN ETRANSFO_AT@GTECH      ET   ON  ET.G3E_FID             = COM.G3E_FID
            LEFT OUTER JOIN CPROPIETARIO@GTECH     CPRO ON  CPRO.G3E_FID           = CON.G3E_FID
            LEFT OUTER JOIN QA_TTT1_REGISTRO       TT1  ON  TT1.TT1_NOMBRECIRCUITO = CON.CIRCUITO
            LEFT OUTER JOIN INFO_AP                AP   ON AP.NODO_TRANSFORM_V     = SUBSTR(CON.NODO_TRANSFORM_V,1,20)
        WHERE               COM.G3E_FNO = 20400
        AND                 COM.ESTADO <> 'CONSTRUCCION'
        ;

        IF V_QA_TTT2_REGISTRO IS NOT EMPTY THEN
             FOR i IN V_QA_TTT2_REGISTRO.FIRST..V_QA_TTT2_REGISTRO.LAST LOOP
                     INSERT INTO BRAE.QA_TTT2_TEMP
                   VALUES V_QA_TTT2_REGISTRO(i);
                 END LOOP;
             COMMIT;
        END IF;


  --EXPANSION

        --LOCALIZANDO E INSERTANDO LOS NUEVOS REGISTRO DE EXPANSION DE TRANSFORMADORES
        --CRUCE DE LAS TABLAS QA_TTT2_REGISTRO CON QA_TTT2_TEMP, PARA EXTAER LOS TRANSFORMADORES DE EXPANSION
        V_QA_TTT2_REGISTRO.DELETE;
        SELECT *
        BULK COLLECT INTO V_QA_TTT2_REGISTRO
        FROM QA_TTT2_TEMP
        WHERE TT2_CODIGOELEMENTO IN (
                                    SELECT TT2_CODIGOELEMENTO
                                    FROM QA_TTT2_TEMP
                                    WHERE TT2_ESTADO IN ('OPERACION','PLANEACION')
                                    MINUS
                                    SELECT TT2_CODIGOELEMENTO
                                    FROM QA_TTT2_REGISTRO
                                    )
        AND NVL(TRUNC(TT2_FMODIFICACION),FECHAOPERACION) <
            TRUNC(ADD_MONTHS(FECHAOPERACION,1))
        ;

        IF V_QA_TTT2_REGISTRO IS NOT EMPTY THEN
             FOR i IN V_QA_TTT2_REGISTRO.FIRST..V_QA_TTT2_REGISTRO.LAST LOOP
                   INSERT INTO BRAE.QA_TTT2_REGISTRO
                   VALUES V_QA_TTT2_REGISTRO(i);

                   DELETE FROM QA_TTT2_TEMP
                   WHERE TT2_CODIGOELEMENTO = V_QA_TTT2_REGISTRO(i).TT2_CODIGOELEMENTO
                   AND   TT2_ESTADO = 'RETIRADO';--//ELIMINACION DE LOS REGISTROS NUEVOS CON REPOSICION, PARA EVITAR REPOSICIONES DE EXPANSIONES

             END LOOP;
             COMMIT;
        END IF;
  --ELIMINAR DE LOS REGISTROS INGRESDOS LOS TRANSFORMADORES NUEVOS DE EXPANSION Y CON REPOSICIONES ANTES DE REPORTE (NO SE PUEDE REPONER DE LO QUE NO SE HA REPORTADO)
        DELETE FROM QA_TTT2_REGISTRO
        WHERE  TT2_ESTADO = 'RETIRADO';--CHECK IF THIS SENTENCE IS FUNCTIONAL
        COMMIT;

  --REVISAR Y EXCLUIR LOS TRANSOFORMADORES CON FECHA ESTADO DIFERENTE AL AÑO DE OPERACION, COLOCARLO EN LA TABLA QA_TTT2_OBS
        V_QA_TTT2_REGISTRO.DELETE;
        SELECT *
        BULK COLLECT INTO V_QA_TTT2_REGISTRO
        FROM QA_TTT2_REGISTRO
        WHERE TO_NUMBER(TO_CHAR(TT2_FESTADO,'YYYY')) NOT IN  (TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY')), TO_NUMBER(TO_CHAR(FECHAOPERACION,'YYYY')) - 1)
        AND TT2_PERIODO_OP=TRUNC(FECHAOPERACION);


        IF V_QA_TTT2_REGISTRO IS NOT EMPTY THEN
             FOR i IN V_QA_TTT2_REGISTRO.FIRST..V_QA_TTT2_REGISTRO.LAST LOOP
                   --INCLUSION EN QA_TTT2_OBS
                   INSERT INTO BRAE.QA_TTT2_OBS
                   VALUES V_QA_TTT2_REGISTRO(i);
                   --EXCLUSION DE LA TABLA QA_TTT2_REGISTRO
                   DELETE
                   FROM QA_TTT2_REGISTRO
                   WHERE TT2_CODIGOELEMENTO=V_QA_TTT2_REGISTRO(i).TT2_CODIGOELEMENTO;
             END LOOP;
             COMMIT;
        END IF;
        
        UPDATE QA_TTT2_OBS 
        SET   TT2_OBSERVACIONES = 'Exclusion por Fecha Estado en activos de Expansion'
        WHERE TT2_PERIODO_OP    = FECHAOPERACION
        AND   TT2_OBSERVACIONES IS NULL;
       	COMMIT;

  --VALIDACION DE CAMPOS NULLS Y COLOCACION EN TABLA QA_TTT2_OBS PARA LOS REGISTROS INSERTADOS POR EXAPANSION
        V_QA_TTT2_REGISTRO.DELETE;

        SELECT *
        BULK  COLLECT INTO V_QA_TTT2_REGISTRO
        FROM  QA_TTT2_REGISTRO
        WHERE TT2_PERIODO_OP = FECHAOPERACION
        AND(	TT2_GRUPOCALIDAD	    IS NULL
            OR	TT2_IDMERCADO	        IS NULL
            OR	TT2_CAPACIDAD    	    IS NULL
            OR	TT2_PROPIEDAD	        IS NULL
            OR	TT2_TSUBESTACION	    IS NULL
            OR	TT2_LONGITUD	        IS NULL
            OR	TT2_LATITUD	            IS NULL
            OR	TT2_ALTITUD	            IS NULL
            OR	TT2_ESTADO	            IS NULL
            OR	TT2_ESTADO_BRA11	    IS NULL
            OR	TT2_NOMBRE_CIRCUITO	    IS NULL
            OR	TT2_IUL	                IS NULL
            )
        AND TT2_CODE_IUA                IS NULL;

        --INCLUSION EN QA_TTT2_OBS
        IF V_QA_TTT2_REGISTRO IS NOT EMPTY THEN
              FOR i IN V_QA_TTT2_REGISTRO.FIRST..V_QA_TTT2_REGISTRO.LAST LOOP
                    --Inserta en tabla de observaciones
                    INSERT INTO BRAE.QA_TTT2_OBS
                    VALUES V_QA_TTT2_REGISTRO(i);
                    --Elimina de la tabla de registros
                    DELETE FROM BRAE.QA_TTT2_REGISTRO
                    WHERE  TT2_CODIGOELEMENTO = V_QA_TTT2_REGISTRO(i).TT2_CODIGOELEMENTO
                    AND    TT2_CODE_IUA IS NULL;
              END LOOP;
              COMMIT;
         END IF;
        
        UPDATE QA_TTT2_OBS 
        SET   TT2_OBSERVACIONES = 'Campos Nulos por Expansion, GC, ID, CAP, PROP, LONG, LAT, ALT, ESTADO, CIRCUITO, IUL'
        WHERE TT2_PERIODO_OP    = FECHAOPERACION
        AND   TT2_OBSERVACIONES IS NULL;
       	COMMIT;

        --CONFIGURAR DE LOS NUEVOS REGISTROS DE EXPANSION EL CAMPO TIPO DE PROYECTO POR DEFECTO "2"

        UPDATE QA_TTT2_REGISTRO
        SET TT2_TIPOINVERSION='2'
        WHERE TT2_PERIODO_OP=TRUNC(FECHAOPERACION)
        AND (TT2_TIPOINVERSION IS NULL);
        COMMIT;

        UPDATE QA_TTT2_REGISTRO
        SET TT2_TIPOINVERSION = '4'
        WHERE TT2_PERIODO_OP = TRUNC(FECHAOPERACION)
        AND (TT2_TIPOINVERSION = 'T4');
        COMMIT;

  --REPOSICIÓN
        --COLOCACION DE LOS REGISTROS DE REPOSICION EN LA TABLA QA_TTT2_REGISTRO
        V_QA_TTT2_REGISTRO.DELETE;

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
        BULK COLLECT INTO V_QA_TTT2_REGISTRO
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
                         WHERE TRUNC(TT2_PERIODO_OP)<>TRUNC(FECHAOPERACION)
                         ) T2 ON T2.TT2_CODIGOELEMENTO=T1.TT2_CODIGOELEMENTO
        WHERE T1.TT2_CODIGOELEMENTO IN (
                                        SELECT DISTINCT T1.TT2_CODIGOELEMENTO
                                        FROM QA_TTT2_TEMP T1
                                        INNER  JOIN (SELECT DISTINCT TT2_CODIGOELEMENTO
                                                     FROM QA_TTT2_TEMP
                                                     WHERE TT2_ESTADO = 'OPERACION'
                                                     AND   TRUNC(TT2_FCOLOCACION,'MM') = TRUNC(FECHAOPERACION)
                                                     AND   TT2_G3E_FID <> TT2_FID_ANTERIOR
                                                     ) T2 ON T2.TT2_CODIGOELEMENTO = T1.TT2_CODIGOELEMENTO
                                        WHERE TT2_ESTADO = 'RETIRADO'
                                        AND TRUNC(TT2_FCOLOCACION,  'MM') <= TRUNC(FECHAOPERACION)--
                                        AND TRUNC(TT2_FMODIFICACION,'MM')  = TRUNC(FECHAOPERACION)--Identifica que se hayan realizado el mes de operacion
                                        )
        AND T1.TT2_CODIGOELEMENTO NOT IN(
                                          SELECT DISTINCT TT2_CODIGOELEMENTO
                                          FROM QA_TTT2_REGISTRO
                                          WHERE    TT2_ACTIVOCONEXION    = 1
                                          OR       TT2_ACTIVOPROVISIONAL = 1
                                          OR       TT2_ESTADO_BRA11      = 'PLANEACION'--NO REALIZAR REPOSICIONES SOBRE LOS TRANSFORMADORES EN PLANEACION
                                          )
        ;

        --INSERSION DE LOS REGISTROS DE REPOSICION
        IF V_QA_TTT2_REGISTRO IS NOT EMPTY THEN
             FOR i IN V_QA_TTT2_REGISTRO.FIRST..V_QA_TTT2_REGISTRO.LAST LOOP
                   INSERT INTO BRAE.QA_TTT2_REGISTRO
                   VALUES V_QA_TTT2_REGISTRO(i);
             END LOOP;
             COMMIT;
        END IF;

  --VALIDACION DE CAMPOS NULLS Y COLOCACION EN TABLA QA_TTT2_OBS PARA LOS REGISTROS INSERTADOS POR REPOSICION
        V_QA_TTT2_REGISTRO.DELETE;

        SELECT *
        BULK  COLLECT INTO V_QA_TTT2_REGISTRO
        FROM  QA_TTT2_REGISTRO
        WHERE TT2_PERIODO_OP = FECHAOPERACION
        AND(	TT2_GRUPOCALIDAD	    IS NULL
            OR	TT2_IDMERCADO	        IS NULL
            OR	TT2_CAPACIDAD    	    IS NULL
            OR	TT2_PROPIEDAD	        IS NULL
            OR	TT2_TSUBESTACION	    IS NULL
            OR	TT2_LONGITUD	        IS NULL
            OR	TT2_LATITUD	            IS NULL
            OR	TT2_ALTITUD	            IS NULL
            OR	TT2_ESTADO	            IS NULL
            OR	TT2_ESTADO_BRA11	    IS NULL
            OR	TT2_NOMBRE_CIRCUITO	    IS NULL
            OR	TT2_IUL	                IS NULL
            )
        AND TT2_CODE_IUA                IS NULL;

        --INCLUSION EN QA_TTT2_OBS
        IF V_QA_TTT2_REGISTRO IS NOT EMPTY THEN
              FOR i IN V_QA_TTT2_REGISTRO.FIRST..V_QA_TTT2_REGISTRO.LAST LOOP
                    --Inserta en tabla de observaciones
                    INSERT INTO BRAE.QA_TTT2_OBS
                    VALUES V_QA_TTT2_REGISTRO(i);
                    --Elimina de la tabla de registros
                    DELETE FROM BRAE.QA_TTT2_REGISTRO
                    WHERE  TT2_CODIGOELEMENTO = V_QA_TTT2_REGISTRO(i).TT2_CODIGOELEMENTO
                    AND    TT2_CODE_IUA IS NULL;
              END LOOP;
              COMMIT;
         END IF;
        
        UPDATE QA_TTT2_OBS 
        SET   TT2_OBSERVACIONES = 'Campos Nulos por Reposicion, GC, ID, CAP, PROP, LONG, LAT, ALT, ESTADO, CIRCUITO, IUL'
        WHERE TT2_PERIODO_OP    = FECHAOPERACION
        AND   TT2_OBSERVACIONES IS NULL;
       	COMMIT;


        --ASIGNAR UC A LOS REGISTROS INGRESADOS POR EXPANSION Y REPOSICION
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
				,NVL(UC.TT2_UNIDAD_CONSTRUCTIVA,'N/A#') AS TT2_UNIDAD_CONSTRUCTIVA 
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
		WHERE TR.TT2_UNIDAD_CONSTRUCTIVA IS NULL
		AND   TR.TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
		COMMIT;
	
		DELETE FROM QA_TTT2_REGISTRO
		WHERE TT2_UNIDAD_CONSTRUCTIVA IS NULL
		AND   TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
		COMMIT;
		


        --PASAR A OBSERVACIONES LOS REGISTROS QUE NO CONTIENEN UNA UC VALIDA Y ELIMINAR DE LA TABLA REGISTRO
        INSERT INTO QA_TTT2_OBS
        SELECT * FROM BRAE.QA_TTT2_REGISTRO
        WHERE TT2_UNIDAD_CONSTRUCTIVA = 'N/A#'
        AND   TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
        COMMIT;
        
        UPDATE QA_TTT2_OBS 
        SET   TT2_OBSERVACIONES = 'Exclusion por Unidad Constructiva'
        WHERE TT2_PERIODO_OP    = FECHAOPERACION
        AND   TT2_OBSERVACIONES IS NULL;
       	COMMIT;

        --ELIMINAR DE REGISTRO
        DELETE FROM BRAE.QA_TTT2_REGISTRO
        WHERE TT2_UNIDAD_CONSTRUCTIVA = 'N/A#'
        AND   TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
        COMMIT;

       --MARCAR LOS CAMPOS TIPO_PROYECTO O INVERSION PARA LOS REGISTROS DE REPOSICION
       --1. identificar el brafo mas antiguo y eliminar
        SELECT TT2_CODIGOELEMENTO
        BULK COLLECT INTO V_ACTIVOS
        FROM BRAE.QA_TTT2_REGISTRO
        GROUP BY TT2_CODIGOELEMENTO
        HAVING COUNT(TT2_CODIGOELEMENTO)>1
        ;
        IF V_ACTIVOS IS NOT EMPTY THEN
             FOR i IN V_ACTIVOS.FIRST..V_ACTIVOS.LAST LOOP

                DELETE
                FROM BRAE.QA_TTT2_REGISTRO
                WHERE TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                AND   TT2_PERIODO_OP = FECHAOPERACION
                AND   TT2_ALTERNATIVA_VALORACION = 'BRAFO'
                AND   TT2_FMODIFICACION = (
                                            SELECT MIN(TT2_FMODIFICACION)
                                            FROM QA_TTT2_REGISTRO
                                            WHERE TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                                            AND   TT2_ALTERNATIVA_VALORACION = 'BRAFO'
                                            AND   TT2_PERIODO_OP = FECHAOPERACION
                                           );
               COMMIT;

             END LOOP;
        END IF;


        --2. actualizar el registro anterior reportado
          ---con estado braen a brafo y periodo operacion actual
        V_ACTIVOS.DELETE;
        SELECT TT2_CODIGOELEMENTO
        BULK COLLECT INTO V_ACTIVOS
        FROM BRAE.QA_TTT2_REGISTRO
        GROUP BY TT2_CODIGOELEMENTO
        HAVING COUNT(TT2_CODIGOELEMENTO)>1
        ;
        IF V_ACTIVOS IS NOT EMPTY THEN
             FOR i IN V_ACTIVOS.FIRST..V_ACTIVOS.LAST LOOP

                UPDATE BRAE.QA_TTT2_REGISTRO
                SET   TT2_PERIODO_OP             = FECHAOPERACION,
                      TT2_ALTERNATIVA_VALORACION = 'BRAFO',
                      TT2_ESTADO                 = 'RETIRADO',
                      TT2_ESTADO_BRA11           = 'RETIRADO',
                      TT2_FESTADO                =  LAST_DAY(FECHAOPERACION)
                WHERE TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                AND   TT2_PERIODO_OP <> FECHAOPERACION
                AND   TT2_ALTERNATIVA_VALORACION = 'BRAEN';
               COMMIT;

             END LOOP;
        END IF;


        --3. Identifico de los trafos brafos el siguiente mas antiguo
          --y comparamos las unidades constructivas con el mas atiguo
          --si son diferentes colocar 1 sino 3 en el campo tipo de proyecto; hasta n-1
        V_ACTIVOS.DELETE;

        SELECT   TT2_CODIGOELEMENTO
        BULK     COLLECT INTO V_ACTIVOS
        FROM     BRAE.QA_TTT2_REGISTRO
        GROUP BY TT2_CODIGOELEMENTO
        HAVING COUNT(TT2_CODIGOELEMENTO)>1
        ;
        IF V_ACTIVOS IS NOT EMPTY THEN
             FOR i IN V_ACTIVOS.FIRST .. V_ACTIVOS.LAST LOOP

                SELECT   TT2_CODIGOELEMENTO
                        ,TT2_UNIDAD_CONSTRUCTIVA
                        ,TT2_FMODIFICACION
                BULK     COLLECT INTO V_ACT_TIPOPROYECTO
                FROM     BRAE.QA_TTT2_REGISTRO
                WHERE    TT2_CODIGOELEMENTO =  V_ACTIVOS(i).TT2_CODIGOELEMENTO
                AND      TT2_PERIODO_OP     =  FECHAOPERACION
                ORDER BY TT2_FMODIFICACION;

                IF V_ACT_TIPOPROYECTO IS NOT NULL THEN
                        --Modificacion del tipo de proyecto o inversion al elemento existente reportado y en reposicion
                        IF V_ACT_TIPOPROYECTO(1).TT2_UNIDAD_CONSTRUCTIVA = V_ACT_TIPOPROYECTO(2).TT2_UNIDAD_CONSTRUCTIVA THEN
                          --UPDATE EL REGISTRO QUE TIENE FMODFICACION(1)
                          UPDATE BRAE.QA_TTT2_REGISTRO
                          SET    TT2_TIPOINVERSION = '3'
                          WHERE  TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                          AND    TT2_FMODIFICACION  = V_ACT_TIPOPROYECTO(1).TT2_FMODIFICACION;
                          COMMIT;
                          ELSE
                            IF V_ACT_TIPOPROYECTO(1).TT2_UNIDAD_CONSTRUCTIVA <> V_ACT_TIPOPROYECTO(2).TT2_UNIDAD_CONSTRUCTIVA THEN
                               UPDATE BRAE.QA_TTT2_REGISTRO
                               SET    TT2_TIPOINVERSION = '1'
                               WHERE  TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                               AND    TT2_FMODIFICACION  = V_ACT_TIPOPROYECTO(1).TT2_FMODIFICACION;
                               COMMIT;
                            END IF;
                        END IF;

                      FOR j IN V_ACT_TIPOPROYECTO.FIRST .. V_ACT_TIPOPROYECTO.LAST-1 LOOP
                        IF V_ACT_TIPOPROYECTO(j).TT2_UNIDAD_CONSTRUCTIVA = V_ACT_TIPOPROYECTO(j+1).TT2_UNIDAD_CONSTRUCTIVA THEN
                          --UPDATE EL REGISTRO QUE TIENE FMODFICACION(j+1)
                          UPDATE BRAE.QA_TTT2_REGISTRO
                          SET    TT2_TIPOINVERSION = '3'
                          WHERE  TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                          AND    TT2_FMODIFICACION  = V_ACT_TIPOPROYECTO(j+1).TT2_FMODIFICACION;
                          COMMIT;
                          ELSE
                            IF V_ACT_TIPOPROYECTO(j).TT2_UNIDAD_CONSTRUCTIVA <> V_ACT_TIPOPROYECTO(j+1).TT2_UNIDAD_CONSTRUCTIVA THEN
                               UPDATE BRAE.QA_TTT2_REGISTRO
                               SET    TT2_TIPOINVERSION = '1'
                               WHERE  TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                               AND    TT2_FMODIFICACION  = V_ACT_TIPOPROYECTO(j+1).TT2_FMODIFICACION;
                               COMMIT;
                            END IF;
                        END IF;
                      END LOOP;
                END IF;

             END LOOP;
        END IF;


      --EXTRAER E IDENTIFICAR LOS ELIMINADOS (DESMANTELADOS) TRANSICION '13'
       V_ACTIVOS.DELETE;

       SELECT TT2_CODIGOELEMENTO
       BULK COLLECT INTO V_ACTIVOS
       FROM(
            (SELECT DISTINCT TT2_CODIGOELEMENTO
             FROM QA_TTT2_REGISTRO
             WHERE TT2_ESTADO = 'OPERACION'
             )
           MINUS
            (SELECT DISTINCT TT2_CODIGOELEMENTO
             FROM QA_TTT2_TEMP
             WHERE TT2_ESTADO IN ('OPERACION')
             )
           )
       WHERE TT2_CODIGOELEMENTO NOT IN ((SELECT DISTINCT CODIGO_OPERATIVO
                                        FROM B$CCOMUN@GTECH
                                        WHERE LTT_ID IN (SELECT LTT_ID FROM LTT_IDENTIFIERS@GTECH)
                                        AND G3E_FNO=20400
                                        AND EMPRESA_ORIGEN='CENS')
                                        UNION ALL
                                        SELECT 'XT00001' FROM DUAL--activo comodin TC2 para usuarios temporales
                                        );

        IF V_ACTIVOS IS NOT EMPTY THEN
             FOR i IN V_ACTIVOS.FIRST..V_ACTIVOS.LAST LOOP

                UPDATE BRAE.QA_TTT2_REGISTRO
                SET   TT2_PERIODO_OP             = FECHAOPERACION,
                      TT2_ALTERNATIVA_VALORACION = 'BRAFO',
                      TT2_ESTADO                 = 'RETIRADO',
                      TT2_ESTADO_BRA11           = 'RETIRADO',
                      TT2_FESTADO                =  LAST_DAY(FECHAOPERACION),
                      TT2_TIPOINVERSION          = '3'
                WHERE TT2_CODIGOELEMENTO = V_ACTIVOS(i).TT2_CODIGOELEMENTO
                AND   TT2_PERIODO_OP <> FECHAOPERACION;
                COMMIT;

             END LOOP;
        END IF;


       --CAMBIAR LA FECHA DE PUESTA EN OPERACION A LOS BRAEN Y BRAFO (ULTIMO DIA FECHAOPERACION)
       UPDATE QA_TTT2_REGISTRO
       SET TT2_FESTADO =  LAST_DAY(FECHAOPERACION)
       WHERE TT2_PERIODO_OP = FECHAOPERACION;
       COMMIT;


       --CODIFICACION IUA DE LOS ACTIVOS
        --Contener en V_FORIUA los elementos que no tienen un IUA asignado
        SELECT T2.TT2_CODIGOELEMENTO
             , T2.TT2_FMODIFICACION
             , UC.TT2_CODIGO_UC
        BULK COLLECT INTO V_FORIUA
        FROM QA_TTT2_REGISTRO T2
        LEFT OUTER JOIN QA_TTT2_CODIGO_UC UC
          ON UC.TT2_UNIDAD_CONSTRUCTIVA = T2.TT2_UNIDAD_CONSTRUCTIVA
        WHERE T2.TT2_CODE_IUA IS NULL
        AND   T2.TT2_PERIODO_OP = FECHAOPERACION;

        --Identificar el maximo valor numerico base 10 en la base de TT2 actual
        SELECT MAX(TO_NUMBER(QA_FBASE_CONV(SUBSTR(TT2_CODE_IUA,2,5),36,10))) AS MAX_CONSEC
        INTO MAX_CONSECUTIVO_IUA
        FROM BRAE.QA_TTT2_REGISTRO
        WHERE TT2_CODE_IUA IS NOT NULL;

        --Asignacion de codigos IUA a todos los elementos del periodo con la funcion QA_FBASE_CONV
        IF V_FORIUA IS NOT EMPTY THEN
             FOR i IN V_FORIUA.FIRST..V_FORIUA.LAST
             LOOP
                UPDATE BRAE.QA_TTT2_REGISTRO
                SET   TT2_CODE_IUA        =  '1'|| LPAD(QA_FBASE_CONV((MAX_CONSECUTIVO_IUA + i),10,36),5,0)||V_FORIUA(i).TT2_CODIGO_UC
                WHERE TT2_CODIGOELEMENTO  =  V_FORIUA(i).TT2_CODIGOELEMENTO
                AND   TT2_FMODIFICACION   =  V_FORIUA(i).TT2_FMODIFICACION
                AND   TT2_PERIODO_OP      =  FECHAOPERACION
                AND   TT2_CODE_IUA        IS NULL;
                COMMIT;
             END LOOP;
        END IF;

        --ACTUALIZACION DE LA INFORMACION CALP
        --Se identifican los cambios en las asignaciones de potencia instalada y se actualiza el valor anterior
        UPDATE QA_TTT2_REGISTRO R
        SET   TT2_AP_POTENCIA = NVL((SELECT DISTINCT TT2_AP_POTENCIA
                                     FROM QA_TTT2_TEMP
                                     WHERE TT2_CODIGOELEMENTO = R.TT2_CODIGOELEMENTO
                                     AND   TT2_ESTADO = 'OPERACION')
                                    ,0);
        COMMIT;

        --identificamos el maximo valor conscutivo CALP asignado
        SELECT MAX(TO_NUMBER(SUBSTR(TT2_CODE_CALP,5,20))) MAX_CONSECUTIVO_CALP
        INTO MAX_CONSECUTIVO_CALP
        FROM BRAE.QA_TTT2_REGISTRO
        WHERE TT2_CODE_CALP LIKE 'CALP%';

        --Borrar codigo CALP a los que tengan potencia CERO y CALP asignada
        UPDATE BRAE.QA_TTT2_REGISTRO
        SET    TT2_CODE_CALP   = '0'
        WHERE  TT2_AP_POTENCIA =  0
        AND    TT2_CODE_CALP  <> '0';
        COMMIT;

        --Asignar CALP a los que tengan potencia mayor a CERO y CALP igual a CERO
        --identificar los transformadores que cumplen la condicion codigo CALP=0 , potencia > 0 y  INVERSION (2,4)
        SELECT DISTINCT TT2_CODIGOELEMENTO
        BULK COLLECT INTO V_FORCALP
        FROM   QA_TTT2_REGISTRO
        WHERE  TT2_AP_POTENCIA >  0
        AND    TT2_CODE_CALP   = '0'
        AND    TT2_TIPOINVERSION IN ('2','4');

        --asignar CALP a los transformdores de la coleccion anterior, que
        --cumplen la condicion codigo CALP=0, potencia > 0 y  INVERSION (2,4)
        IF V_FORCALP IS NOT EMPTY THEN
             FOR i IN V_FORCALP.FIRST..V_FORCALP.LAST
             LOOP
                UPDATE BRAE.QA_TTT2_REGISTRO
                SET   TT2_CODE_CALP       =  'CALP'|| LPAD((MAX_CONSECUTIVO_CALP + i),9,0)
                WHERE TT2_CODIGOELEMENTO  =  V_FORCALP(i).TT2_CODIGOELEMENTO;
                COMMIT;
             END LOOP;
        END IF;

        --actualizar CALP a los transformdores de reposicion, que
        --cumplen la condicion codigo CALP=0, potencia > 0 y  INVERSION (1,3)
        --V_FORCALP.DELETE;
        UPDATE BRAE.QA_TTT2_REGISTRO R
        SET    R.TT2_CODE_CALP = (SELECT DISTINCT TT2_CODE_CALP
                                  FROM   BRAE.QA_TTT2_REGISTRO
                                  WHERE  TT2_CODIGOELEMENTO = R.TT2_CODIGOELEMENTO
                                  AND    TT2_CODE_CALP LIKE 'CALP%'
                                  )
        WHERE  R.TT2_AP_POTENCIA >  0
        AND    R.TT2_CODE_CALP   = '0'
        AND    R.TT2_TIPOINVERSION IN ('1','3')
        AND    R.TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
        COMMIT;

        --ASIGNACION DEL VALOR DE LAS UNIDADES CONSTRUCTIVAS
        UPDATE BRAE.QA_TTT2_REGISTRO R
        SET    TT2_VALOR_UC   =(SELECT TT2_VALOR_UC
                                FROM   QA_TTT2_CODIGO_UC
                                WHERE  TT2_UNIDAD_CONSTRUCTIVA = R.TT2_UNIDAD_CONSTRUCTIVA
                                )
        WHERE  TT2_PERIODO_OP = TRUNC(FECHAOPERACION)
        AND    TT2_VALOR_UC   IS NULL;
        COMMIT;
       
     --ACTUALIZACION DE LOS VALORES NO REGULATORIOS

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
										FROM QA_TTT2_REGISTRO
										WHERE TT2_ESTADO = 'OPERACION'
										
										MINUS
										
										SELECT TT2_CODIGOELEMENTO  
										      ,TT2_PROPIEDAD
											  ,TT2_LONGITUD
											  ,TT2_LATITUD
											  ,TT2_ALTITUD
											  ,TT2_NOMBRE_CIRCUITO
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
									  OR    TT2_NOMBRE_CIRCUITO LIKE '%SAUX%'
									  OR    TT2_NOMBRE_CIRCUITO IN ('SIN CIRCUITO','ECO')
									  )						   
		;
		COMMIT;


    --TRANSICION DE ACTIVOS DE PROVISIONALES A OPERACION_BRA11

        UPDATE QA_TTT2_REGISTRO T
        SET T.TT2_ESTADO_BRA11           = 'OPERACION'
           ,T.TT2_ALTERNATIVA_VALORACION = 'BRAEN'
           ,T.TT2_PERIODO_OP             = TRUNC(FECHAOPERACION)
           ,T.TT2_ESTADOREPORTE          = 0
           ,T.TT2_OBSERVACIONES          = 'Transicion PLANEACION a OPERACION en BRA11'
           ,T.TT2_ACTIVOPROVISIONAL      = 0
           ,T.TT2_CAPACIDAD              = (SELECT DISTINCT TT2_CAPACIDAD
                                            FROM  QA_TTT2_TEMP
                                            WHERE TT2_CODIGOELEMENTO = T.TT2_CODIGOELEMENTO
                                            AND   TT2_ESTADO = 'OPERACION')
        WHERE T.TT2_CODIGOELEMENTO IN (
                                     SELECT DISTINCT TT2_CODIGOELEMENTO
                                     FROM QA_TTT2_TEMP
                                     WHERE TT2_ESTADO='OPERACION'
                                     AND   TT2_ACTIVOPROVISIONAL = 0
                                     INTERSECT
                                     SELECT DISTINCT TT2_CODIGOELEMENTO
                                     FROM QA_TTT2_REGISTRO
                                     WHERE TT2_ESTADO='OPERACION'
                                     AND   TT2_ACTIVOPROVISIONAL = 1
                                     );
        COMMIT;


        --MARCACION DE REGISTROS DE REPOSICION NR, PARA LOS ACTIVOS NO REPORTADOS EN BRA11
        UPDATE QA_TTT2_REGISTRO
        SET  TT2_ACTIVONR = 1
        WHERE TT2_CODIGOELEMENTO IN (
                SELECT DISTINCT TT2_CODIGOELEMENTO
                FROM QA_TTT2_REGISTRO
                WHERE TT2_TIPOINVERSION IN (1,3)
                AND TT2_PERIODO_OP = TRUNC(FECHAOPERACION)
            MINUS
                SELECT DISTINCT BRA11_CODIGOELEMENTO
                FROM QA_TBRA11_REGISTRO
                WHERE BRA11_ESTADO = 2
            )
        ;
        COMMIT;

        --PASAR TERCERAS REPOSICIONES A LA TABLA QA_TTT2_REP_PEPNDIENTES
        DELETE FROM QA_TTT2_REP_PENDIENTES
        WHERE TT2_PERIODO_OP = TRUNC(FECHAOPERACION);
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

      --REALIZAR EL CONTEO DE REPOSICIONES Y ASIGNAR A LA COLUMNA TT2_CANTIDAD_REPOSICIONES
        /*
        UPDATE BRAE.QA_TTT2_REGISTRO T
        SET   TT2_CANTIDAD        = (
                                           SELECT COUNT(TT2_CODIGOELEMENTO) AS CANTIDAD
                                           FROM QA_TTT2_REGISTRO
                                           WHERE TT2_CODIGOELEMENTO = T.TT2_CODIGOELEMENTO
                                           GROUP BY TT2_CODIGOELEMENTO
                                           HAVING COUNT(TT2_CODIGOELEMENTO)>1
                                          )
        WHERE TT2_CODIGOELEMENTO IN (
                                    SELECT TT2_CODIGOELEMENTO
                                    FROM QA_TTT2_REGISTRO
                                    GROUP BY TT2_CODIGOELEMENTO
                                    HAVING COUNT(TT2_CODIGOELEMENTO)>1
                                    )
        ;
        COMMIT;

        --REVISAR CONTEOS DE REPOSCIONES MAYORES A 2 Y ELIMINAR LAS REPOSICIONES INTERMEDIAS
        UPDATE QA_TTT2_REGISTRO T
        SET   T.TT2_CANTIDAD = 0
        WHERE T.TT2_FMODIFICACION  <  (
                                        SELECT MAX(TT2_FMODIFICACION) AS TT2_MAX_FECHA
                                        FROM  QA_TTT2_REGISTRO
                                        WHERE TT2_CANTIDAD>2
                                        AND   TT2_CODIGOELEMENTO = T.TT2_CODIGOELEMENTO
                                        AND   TT2_ESTADO = 'RETIRADO'
                                        GROUP BY TT2_CODIGOELEMENTO
                                      )
        AND   T.TT2_CODIGOELEMENTO IN (
                                        SELECT TT2_CODIGOELEMENTO
                                        FROM QA_TTT2_REGISTRO
                                        WHERE TT2_CANTIDAD>2
                                        AND   TT2_ESTADO = 'RETIRADO'
                                        GROUP BY TT2_CODIGOELEMENTO
                                      )
        AND   T.TT2_ESTADO = 'RETIRADO'
        ;
        COMMIT;

        INSERT INTO QA_TTT2_OBS
        SELECT * FROM QA_TTT2_REGISTRO
        WHERE TT2_CANTIDAD = 0;
        COMMIT;

        DELETE FROM QA_TTT2_REGISTRO
        WHERE TT2_CANTIDAD = 0;
        COMMIT;
        */


  --Contabilizacion del tiempo o duracion del proceso QA_PTT2_REGISTRO()
       HORA_FIN := SYSDATE;
       DBMS_OUTPUT.PUT_LINE('Writing = OFF ..'||HORA_FIN);
       DBMS_OUTPUT.PUT_LINE('Duration of the Process: '||ROUND((HORA_FIN-HORA_INICIO)*24*60,3)||' Minutes');
  ELSE
      DBMS_OUTPUT.PUT_LINE('It´s not possible execution of procediment');
  END IF; --IF DE INHABILITACION EN REGISTRAR INFORMACION REPORTADA
---FINALIZACION DEL PROECIEMIENTRO QA_PTT2()
END QA_PTT2_REGISTRO;