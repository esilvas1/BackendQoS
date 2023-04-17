create table QA_TTT2_OBS
(
    TT2_CODIGOELEMENTO         VARCHAR2(20),
    TT2_IUA                    VARCHAR2(20),
    TT2_GRUPOCALIDAD           VARCHAR2(2),
    TT2_IDMERCADO              VARCHAR2(20),
    TT2_CAPACIDAD              NUMBER,
    TT2_PROPIEDAD              VARCHAR2(20),
    TT2_TSUBESTACION           NUMBER,
    TT2_LONGITUD               VARCHAR2(20),
    TT2_LATITUD                VARCHAR2(20),
    TT2_ALTITUD                NUMBER,
    TT2_ESTADO                 VARCHAR2(20),
    TT2_ESTADO_BRA11           VARCHAR2(20),
    TT2_RESMETODOLOGIA         VARCHAR2(20),
    TT2_CLASS_CARGA            VARCHAR2(20),
    TT2_NOMBRE_CIRCUITO        VARCHAR2(20),
    TT2_IUL                    VARCHAR2(5),
    TT2_CODIGOPROYECTO         VARCHAR2(20),
    TT2_UNIDAD_CONSTRUCTIVA    VARCHAR2(20),
    TT2_RPP                    NUMBER,
    TT2_SALINIDAD              VARCHAR2(2),
    TT2_TIPOINVERSION          VARCHAR2(5),
    TT2_REMUNERACION_PENDIENTE NUMBER,
    TT2_ALTERNATIVA_VALORACION VARCHAR2(20),
    TT2_ID_PLAN                NUMBER,
    TT2_CANTIDAD               NUMBER,
    TT2_FESTADO                DATE,
    TT2_FCOLOCACION            DATE,
    TT2_FMODIFICACION          DATE,
    TT2_USR_COLOCACION         VARCHAR2(20),
    TT2_USR_MODFICACION        VARCHAR2(20),
    TT2_PERIODO_OP             DATE,
    TT2_REPORTE                NUMBER,
    TT2_FSISTEMA               DATE,
    TT2_ACTIVOCONEXION         NUMBER,
    TT2_ACTIVOPROVISIONAL      NUMBER,
    TT2_AP_POTENCIA            NUMBER,
    TT2_CODE_CALP              VARCHAR2(20),
    TT2_FASES                  VARCHAR2(4),
    TT2_POBLACION              VARCHAR2(10),
    TT2_VALOR_UC               NUMBER,
    TT2_OBSERVACIONES          VARCHAR2(400),
    TT2_LOCALIZACION           VARCHAR2(20),
    TT2_MUNICIPIO              VARCHAR2(100),
    TT2_DEPARTAMENTO           VARCHAR2(100),
    TT2_NT_PRIMARIA            NUMBER,
    TT2_NT_SECUNDARIA          NUMBER,
    TT2_NOREPORT_CREG          NUMBER
)
/


ALTER TABLE QA_TTT2_OBS
ADD (TT2_G3E_FID VARCHAR2(20),
     TT2_FID_ANTERIOR VARCHAR2(20)
    );