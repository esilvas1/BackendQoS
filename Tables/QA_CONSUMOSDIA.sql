create table QA_TCONSUMOSDIA
(
    CONS_ELEMENTO VARCHAR2(32) not null,
    CONS_PERIODO  DATE         not null,
    CONS_DIARIO   NUMBER,
    constraint QA_ICONSUMOSDIA_PK
        primary key (CONS_PERIODO, CONS_ELEMENTO)
)
/


