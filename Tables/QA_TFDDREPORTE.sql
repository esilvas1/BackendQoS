create table QA_TFDDREPORTE
(
    FDR_PERIODO_OP     DATE,
    FDR_CODIGOEVENTO   VARCHAR2(10) not null,
    FDR_FINICIAL       DATE,
    FDR_FFINAL         DATE,
    FDR_CODIGOELEMENTO VARCHAR2(16),
    FDR_TIPOELEMENTO   NUMBER,
    FDR_CAUSA          VARCHAR2(16),
    FDR_CONTINUIDAD    VARCHAR2(2),
    FDR_EXCLUIDOZNI    NUMBER,
    FDR_AFECTACONGEN   NUMBER,
    FDR_USUARIOAP      NUMBER,
    FDR_TIPOCARGA      VARCHAR2(20),
    FDR_IUA            VARCHAR2(20)
)
/

create index QA_IFDDREPORTE_2
    on QA_TFDDREPORTE (FDR_PERIODO_OP, FDR_CODIGOEVENTO)
/

create index QA_IFDDREPORTE_3
    on QA_TFDDREPORTE (FDR_PERIODO_OP, FDR_CODIGOELEMENTO)
/


