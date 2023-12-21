-- BRAE.QA_TFDDCAUSAS_SP7 definition

CREATE TABLE "BRAE"."QA_TFDDCAUSAS_SP7" 
   (	"FDD_CATEGORIA" VARCHAR2(20), 
	"FDD_CAUSA_SP7" NUMBER, 
	"FDD_NOMBRE" VARCHAR2(200), 
	"FDD_DESCRIPCION" VARCHAR2(400), 
	"FDD_CAUSA_CREG" NUMBER, 
	"FDD_DESCRIPCION_CREG" VARCHAR2(200), 
	"FDD_CAUSA_SSPD" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS NOLOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TSP_DATOS_BRAE" ;