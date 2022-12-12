CREATE OR REPLACE PROCEDURE BRAE.QA_PFDDEJECUTAR_AJ(FECHAOPERACION  DATE)
AS

  TYPE T_QA_TFDDREGISTRO IS TABLE OF QA_TFDDREGISTRO%ROWTYPE;
  V_QA_TFDDREGISTRO T_QA_TFDDREGISTRO;

BEGIN

--ACTUALIZACION DE LA TABLA REGISTRO (AJUSTE)
  MERGE INTO (SELECT *
              FROM   QA_TFDDREGISTRO
              WHERE  FDD_FINICIAL>=TRUNC(FECHAOPERACION)
              AND    FDD_FINICIAL< LAST_DAY(FECHAOPERACION) + 1
              AND    FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO IN (SELECT FDD_CODIGOEVENTO||FDD_CODIGOELEMENTO
                                                              FROM   QA_TFDDPRELIMINAR_AJ)
              ) FDD_DESTINO
  USING      QA_TFDDPRELIMINAR_AJ FDD_ORIGEN
  ON(FDD_DESTINO.FDD_CODIGOEVENTO||FDD_DESTINO.FDD_CODIGOELEMENTO =
      FDD_ORIGEN.FDD_CODIGOEVENTO||FDD_ORIGEN.FDD_CODIGOELEMENTO   )
  WHEN     MATCHED THEN UPDATE SET FDD_DESTINO.FDD_FINICIAL   = FDD_ORIGEN.FDD_FINICIAL,
                                   FDD_DESTINO.FDD_FFINAL     = FDD_ORIGEN.FDD_FFINAL,
                                   FDD_DESTINO.FDD_CAUSA      = FDD_ORIGEN.FDD_CAUSA,
                                   FDD_DESTINO.FDD_AJUSTADO   = FDD_ORIGEN.FDD_AJUSTADO,
                                   FDD_DESTINO.FDD_TIPOAJUSTE = FDD_ORIGEN.FDD_TIPOAJUSTE,
                                   FDD_DESTINO.FDD_RADICADO   = FDD_ORIGEN.FDD_RADICADO,
                                   FDD_DESTINO.FDD_APROBADO   = FDD_ORIGEN.FDD_APROBADO,
                                   FDD_DESTINO.FDD_CAUSA_CREG = FDD_ORIGEN.FDD_CAUSA_CREG,
                                   FDD_DESTINO.FDD_EXCLUSION  = FDD_ORIGEN.FDD_EXCLUSION,
                                   FDD_DESTINO.FDD_CAUSA_SSPD = FDD_ORIGEN.FDD_CAUSA_SSPD
                      DELETE WHERE FDD_ORIGEN.FDD_TIPOAJUSTE=3
  WHEN NOT MATCHED THEN INSERT
                        VALUES    (FDD_ORIGEN.FDD_CODIGOEVENTO,
                                   FDD_ORIGEN.FDD_FINICIAL,
                                   FDD_ORIGEN.FDD_FFINAL,
                                   FDD_ORIGEN.FDD_CODIGOELEMENTO,
                                   FDD_ORIGEN.FDD_TIPOELEMENTO,
                                   FDD_ORIGEN.FDD_CONSUMODIA,
                                   FDD_ORIGEN.FDD_ENS_ELEMENTO,
                                   FDD_ORIGEN.FDD_ENS_EVENTO,
                                   FDD_ORIGEN.FDD_ENEG_EVENTO,
                                   FDD_ORIGEN.FDD_ENEG_ELEMENTO,
                                   FDD_ORIGEN.FDD_CODIGOGENERADOR,
                                   FDD_ORIGEN.FDD_CAUSA,
                                   FDD_ORIGEN.FDD_CAUSA_CREG,
                                   FDD_ORIGEN.FDD_USUARIOAP,
                                   FDD_ORIGEN.FDD_CONTINUIDAD,
                                   FDD_ORIGEN.FDD_ESTADOREPORTE,
                                   FDD_ORIGEN.FDD_PUBLICADO,
                                   FDD_ORIGEN.FDD_RECONFIG,
                                   FDD_ORIGEN.FDD_PERIODO_OP,
                                   FDD_ORIGEN.FDD_FREG_APERTURA,
                                   FDD_ORIGEN.FDD_FREG_CIERRE,
                                   FDD_ORIGEN.FDD_FPUB_APERTURA,
                                   FDD_ORIGEN.FDD_FPUB_CIERRE,
                                   FDD_ORIGEN.FDD_PERIODO_TC1,
                                   FDD_ORIGEN.FDD_TIPOCARGA,
                                   FDD_ORIGEN.FDD_EXCLUSION,
                                   FDD_ORIGEN.FDD_CAUSA_SSPD,
                                   FDD_ORIGEN.FDD_AJUSTADO,
                                   FDD_ORIGEN.FDD_TIPOAJUSTE,
                                   FDD_ORIGEN.FDD_RADICADO,
                                   FDD_ORIGEN.FDD_APROBADO,
                                   FDD_ORIGEN.FDD_IUA
                                  );
  COMMIT;

--INSERTAR REGISTROS FDD_TIPOAJUSTE=3 EN LA TABLA QA_TFDDELIMINADOS

    INSERT INTO QA_TFDDELIMINADOS
    SELECT * FROM QA_TFDDPRELIMINAR_AJ
    WHERE FDD_TIPOAJUSTE=3;
    COMMIT;

END QA_PFDDEJECUTAR_AJ;



