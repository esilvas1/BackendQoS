create table QA_TCOMPENSAR
(
    FECHA                DATE,
    CLIENTE_ID           VARCHAR2(10),
    CONSECUTIVO_CALCULO  NUMBER,
    CONSECUTIVO_APLICA   NUMBER,
    TRANSFORMADOR_ID     NUMBER,
    MEDIDA_TENSION       NUMBER,
    GRUPO_CALIDAD        NUMBER,
    CONSUMO_MES          NUMBER,
    DIUM                 NUMBER,
    FIUM                 NUMBER,
    EXCTM                NUMBER,
    DIU                  NUMBER,
    FIU                  NUMBER,
    DIUG                 NUMBER,
    FIUG                 NUMBER,
    THC                  NUMBER,
    TVC                  NUMBER,
    HC                   NUMBER,
    VCU                  NUMBER,
    MF                   NUMBER,
    MC                   NUMBER,
    ESTADO               VARCHAR2(10),
    CEC                  NUMBER,
    COSTO_DISTRIBUCION   NUMBER,
    PORCENTAJE_DESCUENTO NUMBER,
    TIPO                 VARCHAR2(10),
    CICLO                NUMBER,
    VCD                  NUMBER,
    VCF                  NUMBER,
    VC                   NUMBER
)
/

create index FOR_QA_TCOMPENSAR_1
    on QA_TCOMPENSAR (FECHA, CLIENTE_ID, VC)
/


