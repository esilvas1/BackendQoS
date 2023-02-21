create table QA_TTC1
(
    TC1_TC1         VARCHAR2(20),
    TC1_CODCONEX    VARCHAR2(20),
    TC1_TIPCONEX    VARCHAR2(2),
    TC1_NT          NUMBER(2),
    TC1_NTP         NUMBER(2),
    TC1_PROPACTIV   VARCHAR2(5),
    TC1_CONEXRED    VARCHAR2(2),
    TC1_IDCOMER     VARCHAR2(10),
    TC1_IDMERC      VARCHAR2(5),
    TC1_GC          VARCHAR2(3),
    TC1_CODFRONCOM  VARCHAR2(20),
    TC1_CODCIRC     VARCHAR2(50),
    TC1_CODTRANSF   VARCHAR2(20),
    TC1_CODDANE     VARCHAR2(10),
    TC1_UBIC        VARCHAR2(2),
    TC1_DIREC       VARCHAR2(100),
    TC1_CONESP      VARCHAR2(3),
    TC1_CODARESP    VARCHAR2(5),
    TC1_TIPARESP    VARCHAR2(4),
    TC1_ESTSECT     VARCHAR2(2),
    TC1_ALTITUD     NUMBER(15, 5),
    TC1_LONGITUD    VARCHAR2(15),
    TC1_LATITUD     VARCHAR2(15),
    TC1_AUTOGEN     VARCHAR2(2),
    TC1_EXPENER     VARCHAR2(2),
    TC1_CAPAUTOGENR VARCHAR2(6),
    TC1_TIPGENR     VARCHAR2(2),
    TC1_CODFRONEXP  VARCHAR2(20),
    TC1_FENTGEN     DATE,
    TC1_CONTRESP    VARCHAR2(6),
    TC1_CAPCONTRESP VARCHAR2(6),
    TC1_PERIODO     NUMBER(6),
    TC1_IUA         VARCHAR2(20)
)
/

comment on column QA_TTC1.TC1_TC1 is 'Codigo de identificaion del usuario.'
/

comment on column QA_TTC1.TC1_CODCONEX is 'Codico de conexión, codigo de Transformador.'
/

comment on column QA_TTC1.TC1_TIPCONEX is 'Tipo de conexión.'
/

comment on column QA_TTC1.TC1_NT is 'Nivel de Tension.'
/

comment on column QA_TTC1.TC1_NTP is 'Nivel de Tension Primaria.'
/

comment on column QA_TTC1.TC1_PROPACTIV is 'Propiedad del Activo.'
/

comment on column QA_TTC1.TC1_CONEXRED is 'Conexión de Red.'
/

comment on column QA_TTC1.TC1_IDCOMER is 'ID del comercializador'
/

comment on column QA_TTC1.TC1_IDMERC is 'ID de Mercado'
/

comment on column QA_TTC1.TC1_GC is 'Grupo de Calidad'
/

comment on column QA_TTC1.TC1_CODFRONCOM is 'Codigo de Frontera comercial'
/

comment on column QA_TTC1.TC1_CODCIRC is 'Código circuito o línea'
/

comment on column QA_TTC1.TC1_CODTRANSF is 'Código transformador'
/

comment on column QA_TTC1.TC1_CODDANE is 'Código dane (NIU)'
/

comment on column QA_TTC1.TC1_UBIC is 'Ubicacion'
/

comment on column QA_TTC1.TC1_DIREC is 'Direccion'
/

comment on column QA_TTC1.TC1_CONESP is 'Condiciones Especiales'
/

comment on column QA_TTC1.TC1_CODARESP is 'Código área especial'
/

comment on column QA_TTC1.TC1_TIPARESP is 'Tipo área especial'
/

comment on column QA_TTC1.TC1_ESTSECT is 'Estrato / sector'
/

comment on column QA_TTC1.TC1_EXPENER is 'Exporta Energia'
/

comment on column QA_TTC1.TC1_CAPAUTOGENR is 'Capacidad autogenerador (kw)'
/

comment on column QA_TTC1.TC1_TIPGENR is 'Tipo de generación'
/

comment on column QA_TTC1.TC1_CODFRONEXP is 'Código frontera exportación'
/

comment on column QA_TTC1.TC1_FENTGEN is 'Fecha entrada a generar'
/

comment on column QA_TTC1.TC1_CONTRESP is 'Contrato de respaldo'
/

comment on column QA_TTC1.TC1_CAPCONTRESP is 'Capacidad contrato de respaldo'
/

comment on column QA_TTC1.TC1_PERIODO is 'Periodo del registro'
/

create index QA_ITC1_2
    on QA_TTC1 (TC1_PERIODO, TC1_CODCONEX, TC1_IUA, TC1_TC1)
/

create index FOR_QA_TFDDREFERENCIA_1
    on QA_TTC1 (TC1_PERIODO, TC1_AUTOGEN)
/

create index FOR_QA_TC1_TC1
    on QA_TTC1 (TC1_TC1)
/


