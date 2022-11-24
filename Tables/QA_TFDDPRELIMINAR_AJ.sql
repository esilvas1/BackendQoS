create table QA_TFDDPRELIMINAR_AJ
(
    FDD_CODIGOEVENTO    VARCHAR2(10) not null,
    FDD_FINICIAL        TIMESTAMP(3),
    FDD_FFINAL          TIMESTAMP(3),
    FDD_CODIGOELEMENTO  VARCHAR2(16),
    FDD_TIPOELEMENTO    VARCHAR2(16),
    FDD_CONSUMODIA      NUMBER(15, 5),
    FDD_ENS_ELEMENTO    NUMBER(15, 5),
    FDD_ENS_EVENTO      NUMBER(15, 5),
    FDD_ENEG_EVENTO     NUMBER(15, 5),
    FDD_ENEG_ELEMENTO   NUMBER(15, 5),
    FDD_CODIGOGENERADOR VARCHAR2(16),
    FDD_CAUSA           VARCHAR2(50),
    FDD_CAUSA_CREG      VARCHAR2(50),
    FDD_USUARIOAP       VARCHAR2(2),
    FDD_CONTINUIDAD     VARCHAR2(2),
    FDD_ESTADOREPORTE   VARCHAR2(2),
    FDD_PUBLICADO       VARCHAR2(2),
    FDD_RECONFIG        VARCHAR2(2),
    FDD_PERIODO_OP      DATE,
    FDD_FREG_APERTURA   DATE,
    FDD_FREG_CIERRE     DATE,
    FDD_FPUB_APERTURA   DATE,
    FDD_FPUB_CIERRE     DATE,
    FDD_PERIODO_TC1     NUMBER,
    FDD_TIPOCARGA       VARCHAR2(20),
    FDD_EXCLUSION       VARCHAR2(20),
    FDD_CAUSA_SSPD      NUMBER,
    FDD_AJUSTADO        VARCHAR2(2),
    FDD_TIPOAJUSTE      NUMBER,
    FDD_RADICADO        VARCHAR2(30),
    FDD_APROBADO        VARCHAR2(2),
    FDD_IUA             VARCHAR2(20)
)
/

create index QA_IFDDPRELIMINAR_AJ_1
    on QA_TFDDPRELIMINAR_AJ (FDD_CODIGOEVENTO, FDD_CODIGOELEMENTO)
/

create index QA_IFDDPRELIMINAR_AJ_2
    on QA_TFDDPRELIMINAR_AJ ("FDD_CODIGOEVENTO" || "FDD_CODIGOELEMENTO")
/


