CREATE OR REPLACE PROCEDURE BRAE.QA_PCSX(FECHAOPERACION DATE)
AS

 TYPE T_DATACSX IS TABLE OF QA_TDATACSX%ROWTYPE;
 V_DATACSX T_DATACSX;

 CURSOR C_DATACSX IS
        SELECT FDD_CODIGOEVENTO, 
               FDD_FINICIAL, 
               FDD_FFINAL,
               (CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(FECHAOPERACION),+1) OR FDD_FFINAL IS NULL )
                     THEN
                      (ADD_MONTHS(TRUNC(FECHAOPERACION),+1) - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
                     ELSE
                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(FECHAOPERACION))
                        THEN
                           (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TRUNC(FECHAOPERACION))*24
                        ELSE
                         (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
                         END
                END) AS FDD_DURACION,
               (CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(FECHAOPERACION),+1) OR FDD_FFINAL IS NULL )
                     THEN
                      (
 ----------------------FDD_FFINAL ES MAYOR AL TIEMPO DE OPERACION O ES NULL
                         ((CASE WHEN (TRUNC(FDD_FINICIAL)<>(ADD_MONTHS(TRUNC(FECHAOPERACION),+1)-1))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                        THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6)-- CASO 1
                                                  THEN (
                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                       + 6 
                                                       + (ADD_MONTHS(TRUNC(FECHAOPERACION),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2
                                                       )
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18)--CASO2
                                                             THEN (
                                                                   6
                                                                   + (ADD_MONTHS(TRUNC(FECHAOPERACION),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2  
                                                                   )
                                                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18)--CASO 3
                                                                        THEN (
                                                                             ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                             + (ADD_MONTHS(TRUNC(FECHAOPERACION),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2
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
                                                                            (ADD_MONTHS(TRUNC(FECHAOPERACION),+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                            )
                                                                  END)
                                                       END)
                                             END) 
                                        END))
 ----------------------                          
                      )
                     ELSE
                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(FECHAOPERACION))
                        THEN
                           (
 ---------------------------FDD_FINICIAL ES MENOR AL TIEMPO DE OPERACION
                             ((CASE WHEN (TRUNC(FDD_FFINAL)<>(TRUNC(FECHAOPERACION)))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                            THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 7
                                                      THEN (                                                           
                                                           (TRUNC(FDD_FFINAL)-TRUNC(FECHAOPERACION))*24/2
                                                           + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TRUNC(FDD_FFINAL))*24
                                                           )
                                                      ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO8
                                                                 THEN (
                                                                      (TRUNC(FDD_FFINAL)-TRUNC(FECHAOPERACION))*24/2
                                                                      + 6 
                                                                      )
                                                                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 9
                                                                            THEN (
                                                                                 (TRUNC(FDD_FFINAL)-TRUNC(FECHAOPERACION))*24/2
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
       END) AS FDD_DURACION_AP,
               FDD_CODIGOELEMENTO, 
               FDD_CONTINUIDAD, 
               FDD_USUARIOAP, 
               FDD_EXCLUSION,
               FDD_CAUSA,
               FDD_CAUSA_CREG, 
               FDD_CAUSA_SSPD 
         FROM QA_TFDDREGISTRO
         WHERE (TO_CHAR(FDD_FINICIAL, 'MM/YYYY') = TO_CHAR(TRUNC(FECHAOPERACION),'MM/YYYY') 
                OR TO_CHAR(FDD_FFINAL, 'MM/YYYY') = TO_CHAR(TRUNC(FECHAOPERACION),'MM/YYYY'))
         
        UNION ALL

        SELECT FDD_CODIGOEVENTO, 
               FDD_FINICIAL, 
               FDD_FFINAL,
               (ADD_MONTHS(TRUNC(FECHAOPERACION),+1) - TRUNC(FECHAOPERACION))*24 AS FDD_DURACION,
               (ADD_MONTHS(TRUNC(FECHAOPERACION),+1) - TRUNC(FECHAOPERACION))*24/2 AS FDD_DURACION_AP, 
               FDD_CODIGOELEMENTO, 
               FDD_CONTINUIDAD, 
               FDD_USUARIOAP, 
               FDD_EXCLUSION,
               FDD_CAUSA,
               FDD_CAUSA_CREG, 
               FDD_CAUSA_SSPD 
         FROM QA_TFDDREGISTRO
         WHERE (  FDD_FINICIAL < TRUNC(FECHAOPERACION)
             AND (FDD_FFINAL >= ADD_MONTHS(TRUNC(FECHAOPERACION),+1) OR FDD_FFINAL IS NULL));  


 TYPE T_TCSX IS TABLE OF QA_TCSX%ROWTYPE;
 V_TCSX T_TCSX;

 CURSOR C_TCSX IS
    SELECT DISTINCT(T.FDD_CODIGOELEMENTO), 
    TO_NUMBER('0') AS CSX_DIU, NVL(SUM(T0.FDD_DURACION),0)  AS CSX_DIUM, 
    TO_NUMBER('0') AS CSX_FIU, COUNT( F0.FDD_FINICIAL) AS CSX_FIUM, '161' AS CSX_IDMERCADO,
    COUNT( F1.FDD_FINICIAL) AS CSX_FRECUENCIA_C1, NVL(SUM(T1.FDD_DURACION),0)  AS CSX_DURACION_C1, 
    COUNT( F2.FDD_FINICIAL) AS CSX_FRECUENCIA_C2, NVL(SUM(T2.FDD_DURACION),0)  AS CSX_DURACION_C2, 
    COUNT( F3.FDD_FINICIAL) AS CSX_FRECUENCIA_C3, NVL(SUM(T3.FDD_DURACION),0)  AS CSX_DURACION_C3, 
    COUNT( F4.FDD_FINICIAL) AS CSX_FRECUENCIA_C4, NVL(SUM(T4.FDD_DURACION),0)  AS CSX_DURACION_C4, 
    COUNT( F5.FDD_FINICIAL) AS CSX_FRECUENCIA_C5, NVL(SUM(T5.FDD_DURACION),0)  AS CSX_DURACION_C5, 
    COUNT( F6.FDD_FINICIAL) AS CSX_FRECUENCIA_C6, NVL(SUM(T6.FDD_DURACION),0)  AS CSX_DURACION_C6, 
    COUNT( F7.FDD_FINICIAL) AS CSX_FRECUENCIA_C7, NVL(SUM(T7.FDD_DURACION),0)  AS CSX_DURACION_C7, 
    COUNT( F8.FDD_FINICIAL) AS CSX_FRECUENCIA_C8, NVL(SUM(T8.FDD_DURACION),0)  AS CSX_DURACION_C8, 
    COUNT( F9.FDD_FINICIAL) AS CSX_FRECUENCIA_C9, NVL(SUM(T9.FDD_DURACION),0)  AS CSX_DURACION_C9, 
    COUNT(F10.FDD_FINICIAL) AS CSX_FRECUENCIA_C10,NVL(SUM(T10.FDD_DURACION),0) AS CSX_DURACION_C10,
    COUNT(F11.FDD_FINICIAL) AS CSX_FRECUENCIA_C11,NVL(SUM(T11.FDD_DURACION),0) AS CSX_DURACION_C11,
    COUNT(F12.FDD_FINICIAL) AS CSX_FRECUENCIA_C12,NVL(SUM(T12.FDD_DURACION),0) AS CSX_DURACION_C12,
    COUNT(F13.FDD_FINICIAL) AS CSX_FRECUENCIA_C13,NVL(SUM(T13.FDD_DURACION),0) AS CSX_DURACION_C13,
    COUNT(F14.FDD_FINICIAL) AS CSX_FRECUENCIA_C14,NVL(SUM(T14.FDD_DURACION),0) AS CSX_DURACION_C14,
    COUNT(F15.FDD_FINICIAL) AS CSX_FRECUENCIA_C15,NVL(SUM(T15.FDD_DURACION),0) AS CSX_DURACION_C15,    
    TO_NUMBER('0') AS CSX_DIU_AP, NVL(SUM(T0.FDD_DURACION_AP),0)  AS CSX_DIUM_AP,
    TO_NUMBER('0') AS CSX_FIU_AP, COUNT( F_AP0.FDD_FINICIAL) AS CSX_FIUM_AP,
    COUNT( F_AP1.FDD_FINICIAL) AS CSX_FRECUENCIA_C1_AP, NVL(SUM(T1.FDD_DURACION_AP),0)  AS CSX_DURACION_C1_AP, 
    COUNT( F_AP2.FDD_FINICIAL) AS CSX_FRECUENCIA_C2_AP, NVL(SUM(T2.FDD_DURACION_AP),0)  AS CSX_DURACION_C2_AP, 
    COUNT( F_AP3.FDD_FINICIAL) AS CSX_FRECUENCIA_C3_AP, NVL(SUM(T3.FDD_DURACION_AP),0)  AS CSX_DURACION_C3_AP, 
    COUNT( F_AP4.FDD_FINICIAL) AS CSX_FRECUENCIA_C4_AP, NVL(SUM(T4.FDD_DURACION_AP),0)  AS CSX_DURACION_C4_AP, 
    COUNT( F_AP5.FDD_FINICIAL) AS CSX_FRECUENCIA_C5_AP, NVL(SUM(T5.FDD_DURACION_AP),0)  AS CSX_DURACION_C5_AP, 
    COUNT( F_AP6.FDD_FINICIAL) AS CSX_FRECUENCIA_C6_AP, NVL(SUM(T6.FDD_DURACION_AP),0)  AS CSX_DURACION_C6_AP, 
    COUNT( F_AP7.FDD_FINICIAL) AS CSX_FRECUENCIA_C7_AP, NVL(SUM(T7.FDD_DURACION_AP),0)  AS CSX_DURACION_C7_AP, 
    COUNT( F_AP8.FDD_FINICIAL) AS CSX_FRECUENCIA_C8_AP, NVL(SUM(T8.FDD_DURACION_AP),0)  AS CSX_DURACION_C8_AP, 
    COUNT( F_AP9.FDD_FINICIAL) AS CSX_FRECUENCIA_C9_AP, NVL(SUM(T9.FDD_DURACION_AP),0)  AS CSX_DURACION_C9_AP, 
    COUNT(F_AP10.FDD_FINICIAL) AS CSX_FRECUENCIA_C10_AP,NVL(SUM(T10.FDD_DURACION_AP),0) AS CSX_DURACION_C10_AP,
    COUNT(F_AP11.FDD_FINICIAL) AS CSX_FRECUENCIA_C11_AP,NVL(SUM(T11.FDD_DURACION_AP),0) AS CSX_DURACION_C11_AP,
    COUNT(F_AP12.FDD_FINICIAL) AS CSX_FRECUENCIA_C12_AP,NVL(SUM(T12.FDD_DURACION_AP),0) AS CSX_DURACION_C12_AP,
    COUNT(F_AP13.FDD_FINICIAL) AS CSX_FRECUENCIA_C13_AP,NVL(SUM(T13.FDD_DURACION_AP),0) AS CSX_DURACION_C13_AP,
    COUNT(F_AP14.FDD_FINICIAL) AS CSX_FRECUENCIA_C14_AP,NVL(SUM(T14.FDD_DURACION_AP),0) AS CSX_DURACION_C14_AP,
    COUNT(F_AP15.FDD_FINICIAL) AS CSX_FRECUENCIA_C15_AP,NVL(SUM(T15.FDD_DURACION_AP),0) AS CSX_DURACION_C15_AP,
    TRUNC(FECHAOPERACION) AS CSX_PERIODO_OP
    FROM QA_TDATACSX T
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =0)  T0 ON  T0.FDD_CODIGOEVENTO||T0.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =1)  T1 ON  T1.FDD_CODIGOEVENTO||T1.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =2)  T2 ON  T2.FDD_CODIGOEVENTO||T2.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =3)  T3 ON  T3.FDD_CODIGOEVENTO||T3.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =4)  T4 ON  T4.FDD_CODIGOEVENTO||T4.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =5)  T5 ON  T5.FDD_CODIGOEVENTO||T5.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =6)  T6 ON  T6.FDD_CODIGOEVENTO||T6.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =7)  T7 ON  T7.FDD_CODIGOEVENTO||T7.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =8)  T8 ON  T8.FDD_CODIGOEVENTO||T8.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =9)  T9 ON  T9.FDD_CODIGOEVENTO||T9.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=10) T10 ON T10.FDD_CODIGOEVENTO||T10.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=11) T11 ON T11.FDD_CODIGOEVENTO||T11.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=12) T12 ON T12.FDD_CODIGOEVENTO||T12.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=13) T13 ON T13.FDD_CODIGOEVENTO||T13.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=14) T14 ON T14.FDD_CODIGOEVENTO||T14.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=15) T15 ON T15.FDD_CODIGOEVENTO||T15.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =0 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F0 ON  F0.FDD_CODIGOEVENTO||F0.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =1 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F1 ON  F1.FDD_CODIGOEVENTO||F1.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =2 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F2 ON  F2.FDD_CODIGOEVENTO||F2.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =3 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F3 ON  F3.FDD_CODIGOEVENTO||F3.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =4 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F4 ON  F4.FDD_CODIGOEVENTO||F4.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =5 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F5 ON  F5.FDD_CODIGOEVENTO||F5.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =6 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F6 ON  F6.FDD_CODIGOEVENTO||F6.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =7 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F7 ON  F7.FDD_CODIGOEVENTO||F7.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =8 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F8 ON  F8.FDD_CODIGOEVENTO||F8.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =9 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION))  F9 ON  F9.FDD_CODIGOEVENTO||F9.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=10 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION)) F10 ON F10.FDD_CODIGOEVENTO||F10.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=11 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION)) F11 ON F11.FDD_CODIGOEVENTO||F11.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=12 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION)) F12 ON F12.FDD_CODIGOEVENTO||F12.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=13 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION)) F13 ON F13.FDD_CODIGOEVENTO||F13.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=14 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION)) F14 ON F14.FDD_CODIGOEVENTO||F14.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=15 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION)) F15 ON F15.FDD_CODIGOEVENTO||F15.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =0 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP0 ON  F_AP0.FDD_CODIGOEVENTO||F_AP0.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =1 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP1 ON  F_AP1.FDD_CODIGOEVENTO||F_AP1.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =2 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP2 ON  F_AP2.FDD_CODIGOEVENTO||F_AP2.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =3 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP3 ON  F_AP3.FDD_CODIGOEVENTO||F_AP3.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =4 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP4 ON  F_AP4.FDD_CODIGOEVENTO||F_AP4.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =5 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP5 ON  F_AP5.FDD_CODIGOEVENTO||F_AP5.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =6 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP6 ON  F_AP6.FDD_CODIGOEVENTO||F_AP6.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =7 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP7 ON  F_AP7.FDD_CODIGOEVENTO||F_AP7.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =8 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP8 ON  F_AP8.FDD_CODIGOEVENTO||F_AP8.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD =9 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0)  F_AP9 ON  F_AP9.FDD_CODIGOEVENTO||F_AP9.FDD_CODIGOELEMENTO  = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=10 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0) F_AP10 ON F_AP10.FDD_CODIGOEVENTO||F_AP10.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=11 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0) F_AP11 ON F_AP11.FDD_CODIGOEVENTO||F_AP11.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=12 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0) F_AP12 ON F_AP12.FDD_CODIGOEVENTO||F_AP12.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=13 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0) F_AP13 ON F_AP13.FDD_CODIGOEVENTO||F_AP13.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=14 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0) F_AP14 ON F_AP14.FDD_CODIGOEVENTO||F_AP14.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    LEFT OUTER JOIN (SELECT * FROM QA_TDATACSX WHERE FDD_CAUSA_SSPD=15 AND FDD_FINICIAL >= TRUNC(FECHAOPERACION) AND FDD_DURACION_AP>0) F_AP15 ON F_AP15.FDD_CODIGOEVENTO||F_AP15.FDD_CODIGOELEMENTO = T.FDD_CODIGOEVENTO||T.FDD_CODIGOELEMENTO
    GROUP BY T.FDD_CODIGOELEMENTO;
 
    TYPE T_TCSX_V2 IS TABLE OF QA_TCSX%ROWTYPE;
    V_TCSX_V2 T_TCSX_V2;

    CURSOR C_TCSX_V2 IS
             SELECT CSX.CSX_TRANSFOR,         DIU.CSX_DIU,               CSX.CSX_DIUM,
                    FIU.CSX_FIU,              CSX.CSX_FIUM,              CSX.CSX_IDMERCADO,
                    CSX.CSX_FRECUENCIA_C1,    CSX.CSX_DURACION_C1,       CSX.CSX_FRECUENCIA_C2,
                    CSX.CSX_DURACION_C2,      CSX.CSX_FRECUENCIA_C3,     CSX.CSX_DURACION_C3,
                    CSX.CSX_FRECUENCIA_C4,    CSX.CSX_DURACION_C4,       CSX.CSX_FRECUENCIA_C5,
                    CSX.CSX_DURACION_C5,      CSX.CSX_FRECUENCIA_C6,     CSX.CSX_DURACION_C6,
                    CSX.CSX_FRECUENCIA_C7,    CSX.CSX_DURACION_C7,       CSX.CSX_FRECUENCIA_C8,
                    CSX.CSX_DURACION_C8,      CSX.CSX_FRECUENCIA_C9,     CSX.CSX_DURACION_C9,
                    CSX.CSX_FRECUENCIA_C10,   CSX.CSX_DURACION_C10,      CSX.CSX_FRECUENCIA_C11,
                    CSX.CSX_DURACION_C11,     CSX.CSX_FRECUENCIA_C12,    CSX.CSX_DURACION_C12,
                    CSX.CSX_FRECUENCIA_C13,   CSX.CSX_DURACION_C13,      CSX.CSX_FRECUENCIA_C14,
                    CSX.CSX_DURACION_C14,     CSX.CSX_FRECUENCIA_C15,    CSX.CSX_DURACION_C15,
                    DIU_AP.CSX_DIU_AP,        CSX.CSX_DIUM_AP,           FIU_AP.CSX_FIU_AP,
                    CSX.CSX_FIUM_AP,          CSX.CSX_FRECUENCIA_C1_AP,  CSX.CSX_DURACION_C1_AP,
                    CSX.CSX_FRECUENCIA_C2_AP, CSX.CSX_DURACION_C2_AP,    CSX.CSX_FRECUENCIA_C3_AP,
                    CSX.CSX_DURACION_C3_AP,   CSX.CSX_FRECUENCIA_C4_AP,  CSX.CSX_DURACION_C4_AP,
                    CSX.CSX_FRECUENCIA_C5_AP, CSX.CSX_DURACION_C5_AP,    CSX.CSX_FRECUENCIA_C6_AP,
                    CSX.CSX_DURACION_C6_AP,   CSX.CSX_FRECUENCIA_C7_AP,  CSX.CSX_DURACION_C7_AP,
                    CSX.CSX_FRECUENCIA_C8_AP, CSX.CSX_DURACION_C8_AP,    CSX.CSX_FRECUENCIA_C9_AP,
                    CSX.CSX_DURACION_C9_AP,   CSX.CSX_FRECUENCIA_C10_AP, CSX.CSX_DURACION_C10_AP,
                    CSX.CSX_FRECUENCIA_C11_AP,CSX.CSX_DURACION_C11_AP,   CSX.CSX_FRECUENCIA_C12_AP,
                    CSX.CSX_DURACION_C12_AP,  CSX.CSX_FRECUENCIA_C13_AP, CSX.CSX_DURACION_C13_AP,
                    CSX.CSX_FRECUENCIA_C14_AP,CSX.CSX_DURACION_C14_AP,   CSX.CSX_FRECUENCIA_C15_AP,
                    CSX.CSX_DURACION_C15_AP,  CSX.CSX_PERIODO_OP 
          FROM QA_TCSX CSX
          LEFT OUTER JOIN (SELECT CSX_TRANSFOR, SUM(NVL(CSX_DIUM,0)) AS CSX_DIU
          FROM QA_TCSX
          WHERE CSX_PERIODO_OP IN (TRUNC(FECHAOPERACION),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-11))
          GROUP BY CSX_TRANSFOR) DIU ON DIU.CSX_TRANSFOR=CSX.CSX_TRANSFOR
          LEFT OUTER JOIN (SELECT CSX_TRANSFOR, SUM(NVL(CSX_FIUM,0)) AS CSX_FIU
          FROM QA_TCSX
          WHERE CSX_PERIODO_OP IN (TRUNC(FECHAOPERACION),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-11))
          GROUP BY CSX_TRANSFOR) FIU ON FIU.CSX_TRANSFOR=CSX.CSX_TRANSFOR
          LEFT OUTER JOIN (SELECT CSX_TRANSFOR, SUM(NVL(CSX_DIUM_AP,0)) AS CSX_DIU_AP
          FROM QA_TCSX
          WHERE CSX_PERIODO_OP IN (TRUNC(FECHAOPERACION),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-11))
          GROUP BY CSX_TRANSFOR) DIU_AP ON DIU_AP.CSX_TRANSFOR=CSX.CSX_TRANSFOR
          LEFT OUTER JOIN (SELECT CSX_TRANSFOR, SUM(NVL(CSX_FIUM_AP,0)) AS CSX_FIU_AP
          FROM QA_TCSX
          WHERE CSX_PERIODO_OP IN (TRUNC(FECHAOPERACION),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
                         ADD_MONTHS(TRUNC(FECHAOPERACION),-11))
          GROUP BY CSX_TRANSFOR) FIU_AP ON FIU_AP.CSX_TRANSFOR=CSX.CSX_TRANSFOR
          WHERE CSX.CSX_PERIODO_OP=TRUNC(FECHAOPERACION);      



  TYPE R_DISTRAFOS IS RECORD (FDD_CODIGOELEMENTO BRAE.QA_TFDDREGISTRO.FDD_CODIGOELEMENTO%TYPE);  
  TYPE T_DISTRAFOS IS TABLE OF R_DISTRAFOS;

  --TYPE T_DISTRAFOS IS TABLE OF BRAE.QA_TFDDREGISTRO.FDD_CODIGOELEMENTO%TYPE;
  V_DISTRAFOS T_DISTRAFOS;

  CURSOR C_DISTRAFOS IS
    SELECT DISTINCT(V.CSX_TRANSFOR)
    FROM QA_TCSX V
    WHERE V.CSX_PERIODO_OP IN (ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
                                 ADD_MONTHS(TRUNC(FECHAOPERACION),-11))
    AND V.CSX_TRANSFOR NOT IN (SELECT DISTINCT(A.CSX_TRANSFOR)
                                FROM QA_TCSX A
                                WHERE A.CSX_PERIODO_OP IN (TRUNC(FECHAOPERACION)));


 TYPE T_CSU IS TABLE OF QA_TCSU%ROWTYPE;
 V_TCSU T_CSU;
 CURSOR C_TCSU IS
  SELECT DISTINCT TC1_TC1 AS CSU_NIU
      ,'' AS CSU_DIU
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DIUM_AP,0)) ELSE(NVL(TX.CSX_DIUM,0)) END) AS CSU_DIUM
      ,'' AS CSU_FIU
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FIUM_AP,0)) ELSE(NVL(TX.CSX_FIUM,0)) END) AS FIUM
      ,NVL(TX.CSX_IDMERCADO,161) AS CSU_IDMERCADO
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C1_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C1 ,0)) END) AS CSU_FRENCUENCIA_C1 
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C1_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C1   ,0)) END) AS CSU_DURACION_C1
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C2_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C2 ,0)) END) AS CSU_FRENCUENCIA_C2
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C2_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C2   ,0)) END) AS CSU_DURACION_C2
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C3_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C3 ,0)) END) AS CSU_FRECUENCIA_C3
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C3_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C3   ,0)) END) AS CSU_DURACION_C3
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C4_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C4 ,0)) END) AS CSU_FRECUENCIA_C4
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C4_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C4   ,0)) END) AS CSU_DURACION_C4
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C5_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C5 ,0)) END) AS CSU_FRECUENCIA_C5
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C5_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C5   ,0)) END) AS CSU_DURACION_C5
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C6_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C6 ,0)) END) AS CSU_FRECUENCIA_C6
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C6_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C6   ,0)) END) AS CSU_DURACION_C6
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C7_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C7 ,0)) END) AS CSU_FRECUENCIA_C7
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C7_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C7   ,0)) END) AS CSU_DURACION_C7
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C8_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C8 ,0)) END) AS CSU_FRECUENCIA_C8
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C8_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C8   ,0)) END) AS CSU_DURACION_C8
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C9_AP ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C9 ,0)) END) AS CSU_FRECUENCIA_C9
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C9_AP   ,0))  ELSE(NVL(TX.CSX_DURACION_C9   ,0)) END) AS CSU_DURACION_C9
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C10_AP,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C10,0)) END) AS CSU_FRECUENCIA_C10
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C10_AP  ,0))  ELSE(NVL(TX.CSX_DURACION_C10  ,0)) END) AS CSU_DURACION_C10
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C11_AP,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C11,0)) END) AS CSU_FRECUENCIA_C11
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C11_AP  ,0))  ELSE(NVL(TX.CSX_DURACION_C11  ,0)) END) AS CSU_DURACION_C11
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C12_AP,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C12,0)) END) AS CSU_FRECUENCIA_C12
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C12_AP  ,0))  ELSE(NVL(TX.CSX_DURACION_C12  ,0)) END) AS CSU_DURACION_C12
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C13_AP,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C13,0)) END) AS CSU_FRECUENCIA_C13
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C13_AP  ,0))  ELSE(NVL(TX.CSX_DURACION_C13  ,0)) END) AS CSU_DURACION_C13
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C14_AP,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C14,0)) END) AS CSU_FRECUENCIA_C14
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C14_AP  ,0))  ELSE(NVL(TX.CSX_DURACION_C14  ,0)) END) AS CSU_DURACION_C14
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_FRECUENCIA_C15   ,0))  ELSE(NVL(TX.CSX_FRECUENCIA_C15,0)) END) AS CSU_FRECUENCIA_C15
      ,(CASE WHEN (TC1_TC1 LIKE 'CALP%') THEN (NVL(TX.CSX_DURACION_C15     ,0))  ELSE(NVL(TX.CSX_DURACION_C15  ,0)) END) AS CSU_DURACION_C15
      ,TRUNC(FECHAOPERACION) AS CSU_PERIODO_OP
  FROM QA_TTC1
  LEFT OUTER JOIN (SELECT * FROM QA_TCSX WHERE CSX_PERIODO_OP=TRUNC(FECHAOPERACION)) TX ON TX.CSX_TRANSFOR=TC1_CODCONEX
  WHERE TC1_TIPCONEX <> 'P' AND TC1_PERIODO = TO_NUMBER(TO_CHAR(TRUNC(FECHAOPERACION),'YYYYMM'))
  ORDER BY TC1_TC1 ASC;


    TYPE T_TCSU_V2 IS TABLE OF QA_TCSU%ROWTYPE;
    V_TCSU_V2 T_TCSU_V2;

    CURSOR C_TCSU_V2 IS
             SELECT CSU.CSU_NIU,              DIU.CSU_DIU,               CSU.CSU_DIUM,
                    FIU.CSU_FIU,              CSU.CSU_FIUM,              CSU.CSU_IDMERCADO,
                    CSU.CSU_FRECUENCIA_C1,    CSU.CSU_DURACION_C1,       CSU.CSU_FRECUENCIA_C2,
                    CSU.CSU_DURACION_C2,      CSU.CSU_FRECUENCIA_C3,     CSU.CSU_DURACION_C3,
                    CSU.CSU_FRECUENCIA_C4,    CSU.CSU_DURACION_C4,       CSU.CSU_FRECUENCIA_C5,
                    CSU.CSU_DURACION_C5,      CSU.CSU_FRECUENCIA_C6,     CSU.CSU_DURACION_C6,
                    CSU.CSU_FRECUENCIA_C7,    CSU.CSU_DURACION_C7,       CSU.CSU_FRECUENCIA_C8,
                    CSU.CSU_DURACION_C8,      CSU.CSU_FRECUENCIA_C9,     CSU.CSU_DURACION_C9,
                    CSU.CSU_FRECUENCIA_C10,   CSU.CSU_DURACION_C10,      CSU.CSU_FRECUENCIA_C11,
                    CSU.CSU_DURACION_C11,     CSU.CSU_FRECUENCIA_C12,    CSU.CSU_DURACION_C12,
                    CSU.CSU_FRECUENCIA_C13,   CSU.CSU_DURACION_C13,      CSU.CSU_FRECUENCIA_C14,
                    CSU.CSU_DURACION_C14,     CSU.CSU_FRECUENCIA_C15,    CSU.CSU_DURACION_C15,
                    CSU.CSU_PERIODO_OP 
          	FROM QA_TCSU CSU
          LEFT OUTER JOIN (SELECT CSU_NIU, SUM(NVL(CSU_DIUM,0)) AS CSU_DIU
          				   FROM QA_TCSU
  				           WHERE CSU_PERIODO_OP IN (TRUNC(FECHAOPERACION),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-11)
				                         )
          					  GROUP BY CSU_NIU) DIU ON DIU.CSU_NIU=CSU.CSU_NIU
          LEFT OUTER JOIN (SELECT CSU_NIU, SUM(NVL(CSU_FIUM,0)) AS CSU_FIU
 				           FROM QA_TCSU
				           WHERE CSU_PERIODO_OP IN (TRUNC(FECHAOPERACION),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-1),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-2),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-3),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-4),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-5),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-6),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-7),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-8),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-9),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-10),
				                         ADD_MONTHS(TRUNC(FECHAOPERACION),-11))
				           GROUP BY CSU_NIU) FIU ON FIU.CSU_NIU=CSU.CSU_NIU  
		  WHERE CSU.CSU_PERIODO_OP=TRUNC(FECHAOPERACION)
         ;  


BEGIN
 
     BEGIN
      DELETE FROM QA_TDATACSX;
      COMMIT;
     END;
 --ALMACENAR DATOS EN LA TABLA QA_TDATACSX 
 BEGIN
  OPEN C_DATACSX;
  FETCH C_DATACSX BULK COLLECT INTO V_DATACSX;
  FORALL i IN V_DATACSX.FIRST .. V_DATACSX.LAST
     INSERT INTO BRAE.QA_TDATACSX 
            VALUES (V_DATACSX(i).FDD_CODIGOEVENTO,
                    V_DATACSX(i).FDD_FINICIAL,
                    V_DATACSX(i).FDD_FFINAL,
                    V_DATACSX(i).FDD_DURACION,
                    V_DATACSX(i).FDD_DURACION_AP,
                    V_DATACSX(i).FDD_CODIGOELEMENTO,
                    V_DATACSX(i).FDD_CONTINUIDAD,
                    V_DATACSX(i).FDD_USUARIOAP,
                    V_DATACSX(i).FDD_EXCLUSION,
                    V_DATACSX(i).FDD_CAUSA,
                    V_DATACSX(i).FDD_CAUSA_CREG,
                    V_DATACSX(i).FDD_CAUSA_SSPD);   
  CLOSE C_DATACSX;
  COMMIT;
  END;
  
  
 --- ASIGNA TRANSFORMADORES AFECTADOS ANTERIORMENTE (11 MESES) CON VALORES 0 
     BEGIN
      OPEN C_DISTRAFOS;
          FETCH C_DISTRAFOS BULK COLLECT INTO V_DISTRAFOS;         
          FORALL i IN V_DISTRAFOS.FIRST .. V_DISTRAFOS.LAST
          -- INSERTA LOS VALORES EN LA TABLA QA_TSCXREGISTRO
                         INSERT INTO BRAE.QA_TDATACSX
                                          (FDD_CODIGOEVENTO, 
                                           FDD_FINICIAL, 
                                           FDD_FFINAL, 
                                           FDD_DURACION,
                                           FDD_CODIGOELEMENTO, 
                                           FDD_CONTINUIDAD, 
                                           FDD_USUARIOAP, 
                                           FDD_EXCLUSION,
                                           FDD_CAUSA,
                                           FDD_CAUSA_CREG, 
                                           FDD_CAUSA_SSPD) 
                                   VALUES (0, 
                                           NULL, 
                                           NULL, 
                                           '0',
                                           V_DISTRAFOS(i).FDD_CODIGOELEMENTO, 
                                           NULL, 
                                           NULL, 
                                           NULL,
                                           NULL,
                                           NULL, 
                                           '0');
          
      CLOSE C_DISTRAFOS; 
      COMMIT;
      END;
  
  
  --ALMACENAR INFORMACION EN LA TABLA QA_TCSU
  BEGIN
     OPEN C_TCSX;
          FETCH C_TCSX BULK COLLECT INTO V_TCSX;
          FORALL i IN V_TCSX.FIRST .. V_TCSX.LAST
               INSERT INTO BRAE.QA_TCSX
                    VALUES (V_TCSX(i).CSX_TRANSFOR,
                            V_TCSX(i).CSX_DIU,V_TCSX(i).CSX_DIUM,
                            V_TCSX(i).CSX_FIU,V_TCSX(i).CSX_FIUM,
                            V_TCSX(i).CSX_IDMERCADO,
                            V_TCSX(i).CSX_FRECUENCIA_C1, V_TCSX(i).CSX_DURACION_C1,
                            V_TCSX(i).CSX_FRECUENCIA_C2, V_TCSX(i).CSX_DURACION_C2,
                            V_TCSX(i).CSX_FRECUENCIA_C3, V_TCSX(i).CSX_DURACION_C3,
                            V_TCSX(i).CSX_FRECUENCIA_C4, V_TCSX(i).CSX_DURACION_C4,
                            V_TCSX(i).CSX_FRECUENCIA_C5, V_TCSX(i).CSX_DURACION_C5,
                            V_TCSX(i).CSX_FRECUENCIA_C6, V_TCSX(i).CSX_DURACION_C6,
                            V_TCSX(i).CSX_FRECUENCIA_C7, V_TCSX(i).CSX_DURACION_C7,
                            V_TCSX(i).CSX_FRECUENCIA_C8, V_TCSX(i).CSX_DURACION_C8,
                            V_TCSX(i).CSX_FRECUENCIA_C9, V_TCSX(i).CSX_DURACION_C9,
                            V_TCSX(i).CSX_FRECUENCIA_C10,V_TCSX(i).CSX_DURACION_C10,
                            V_TCSX(i).CSX_FRECUENCIA_C11,V_TCSX(i).CSX_DURACION_C11,
                            V_TCSX(i).CSX_FRECUENCIA_C12,V_TCSX(i).CSX_DURACION_C12,
                            V_TCSX(i).CSX_FRECUENCIA_C13,V_TCSX(i).CSX_DURACION_C13,
                            V_TCSX(i).CSX_FRECUENCIA_C14,V_TCSX(i).CSX_DURACION_C14,
                            V_TCSX(i).CSX_FRECUENCIA_C15,V_TCSX(i).CSX_DURACION_C15,
                            V_TCSX(i).CSX_DIU_AP,V_TCSX(i).CSX_DIUM_AP,
                            V_TCSX(i).CSX_FIU_AP,V_TCSX(i).CSX_FIUM_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C1_AP, V_TCSX(i).CSX_DURACION_C1_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C2_AP, V_TCSX(i).CSX_DURACION_C2_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C3_AP, V_TCSX(i).CSX_DURACION_C3_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C4_AP, V_TCSX(i).CSX_DURACION_C4_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C5_AP, V_TCSX(i).CSX_DURACION_C5_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C6_AP, V_TCSX(i).CSX_DURACION_C6_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C7_AP, V_TCSX(i).CSX_DURACION_C7_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C8_AP, V_TCSX(i).CSX_DURACION_C8_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C9_AP, V_TCSX(i).CSX_DURACION_C9_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C10_AP,V_TCSX(i).CSX_DURACION_C10_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C11_AP,V_TCSX(i).CSX_DURACION_C11_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C12_AP,V_TCSX(i).CSX_DURACION_C12_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C13_AP,V_TCSX(i).CSX_DURACION_C13_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C14_AP,V_TCSX(i).CSX_DURACION_C14_AP,
                            V_TCSX(i).CSX_FRECUENCIA_C15_AP,V_TCSX(i).CSX_DURACION_C15_AP,
                            V_TCSX(i).CSX_PERIODO_OP);      
    CLOSE C_TCSX;
    COMMIT;
  END;
    
  --ACTUALIZAR LOS DATOS DIU, FIU, DIU_AP, FIU_AP
 
  -- ABRIR CURSOR C_TCSX_V2
   BEGIN
     OPEN C_TCSX_V2;
          FETCH C_TCSX_V2 BULK COLLECT INTO V_TCSX_V2;

               --ELIMINAR DATOS INGRESADOS ANTERIORMENTE EN QA_TCSX
               BEGIN
               DELETE FROM QA_TCSX 
               WHERE CSX_PERIODO_OP IN (TRUNC(FECHAOPERACION));
               COMMIT;
               END;
             --ALMACENAR INFORMACION EN LA TABLA QA_TCSX NUEVAMENTE
            FORALL i IN V_TCSX_V2.FIRST .. V_TCSX_V2.LAST
               INSERT INTO BRAE.QA_TCSX
                    VALUES (V_TCSX_V2(i).CSX_TRANSFOR,
                            V_TCSX_V2(i).CSX_DIU,V_TCSX_V2(i).CSX_DIUM,
                            V_TCSX_V2(i).CSX_FIU,V_TCSX_V2(i).CSX_FIUM,
                            V_TCSX_V2(i).CSX_IDMERCADO,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C1, V_TCSX_V2(i).CSX_DURACION_C1,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C2, V_TCSX_V2(i).CSX_DURACION_C2,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C3, V_TCSX_V2(i).CSX_DURACION_C3,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C4, V_TCSX_V2(i).CSX_DURACION_C4,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C5, V_TCSX_V2(i).CSX_DURACION_C5,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C6, V_TCSX_V2(i).CSX_DURACION_C6,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C7, V_TCSX_V2(i).CSX_DURACION_C7,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C8, V_TCSX_V2(i).CSX_DURACION_C8,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C9, V_TCSX_V2(i).CSX_DURACION_C9,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C10,V_TCSX_V2(i).CSX_DURACION_C10,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C11,V_TCSX_V2(i).CSX_DURACION_C11,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C12,V_TCSX_V2(i).CSX_DURACION_C12,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C13,V_TCSX_V2(i).CSX_DURACION_C13,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C14,V_TCSX_V2(i).CSX_DURACION_C14,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C15,V_TCSX_V2(i).CSX_DURACION_C15,
                            V_TCSX_V2(i).CSX_DIU_AP,V_TCSX_V2(i).CSX_DIUM_AP,
                            V_TCSX_V2(i).CSX_FIU_AP,V_TCSX_V2(i).CSX_FIUM_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C1_AP, V_TCSX_V2(i).CSX_DURACION_C1_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C2_AP, V_TCSX_V2(i).CSX_DURACION_C2_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C3_AP, V_TCSX_V2(i).CSX_DURACION_C3_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C4_AP, V_TCSX_V2(i).CSX_DURACION_C4_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C5_AP, V_TCSX_V2(i).CSX_DURACION_C5_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C6_AP, V_TCSX_V2(i).CSX_DURACION_C6_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C7_AP, V_TCSX_V2(i).CSX_DURACION_C7_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C8_AP, V_TCSX_V2(i).CSX_DURACION_C8_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C9_AP, V_TCSX_V2(i).CSX_DURACION_C9_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C10_AP,V_TCSX_V2(i).CSX_DURACION_C10_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C11_AP,V_TCSX_V2(i).CSX_DURACION_C11_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C12_AP,V_TCSX_V2(i).CSX_DURACION_C12_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C13_AP,V_TCSX_V2(i).CSX_DURACION_C13_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C14_AP,V_TCSX_V2(i).CSX_DURACION_C14_AP,
                            V_TCSX_V2(i).CSX_FRECUENCIA_C15_AP,V_TCSX_V2(i).CSX_DURACION_C15_AP,
                            V_TCSX_V2(i).CSX_PERIODO_OP);    
    CLOSE C_TCSX_V2;
    COMMIT;
  END;
 
 --BORRAR LOS TRAFOS QUE NO TIENEN ACUMULADO 
     BEGIN
          DELETE FROM QA_TCSX
          WHERE CSX_DIU=0
          AND CSX_DIUM=0 
          AND CSX_DURACION_C1=0 
          AND CSX_DURACION_C2=0 
          AND CSX_DURACION_C3=0 
          AND CSX_DURACION_C4=0 
          AND CSX_DURACION_C5=0 
          AND CSX_DURACION_C6=0 
          AND CSX_DURACION_C7=0 
          AND CSX_DURACION_C8=0 
          AND CSX_DURACION_C9=0 
          AND CSX_DURACION_C10=0 
          AND CSX_DURACION_C11=0 
          AND CSX_DURACION_C12=0 
          AND CSX_DURACION_C13=0 
          AND CSX_DURACION_C14=0 
          AND CSX_DURACION_C15=0
          AND CSX_PERIODO_OP=TRUNC(FECHAOPERACION);
          COMMIT;
     END;

  --ALMACENAR INFORMACION EN LA TABLA QA_TCSU
  BEGIN
     OPEN C_TCSU;
          FETCH C_TCSU BULK COLLECT INTO V_TCSU;
          FORALL i IN V_TCSU.FIRST .. V_TCSU.LAST
               INSERT INTO BRAE.QA_TCSU
                    VALUES (V_TCSU(i).CSU_NIU,
                            V_TCSU(i).CSU_DIU,V_TCSU(i).CSU_DIUM,
                            V_TCSU(i).CSU_FIU,V_TCSU(i).CSU_FIUM,
                            V_TCSU(i).CSU_IDMERCADO,
                            V_TCSU(i).CSU_FRECUENCIA_C1, V_TCSU(i).CSU_DURACION_C1,
                            V_TCSU(i).CSU_FRECUENCIA_C2, V_TCSU(i).CSU_DURACION_C2,
                            V_TCSU(i).CSU_FRECUENCIA_C3, V_TCSU(i).CSU_DURACION_C3,
                            V_TCSU(i).CSU_FRECUENCIA_C4, V_TCSU(i).CSU_DURACION_C4,
                            V_TCSU(i).CSU_FRECUENCIA_C5, V_TCSU(i).CSU_DURACION_C5,
                            V_TCSU(i).CSU_FRECUENCIA_C6, V_TCSU(i).CSU_DURACION_C6,
                            V_TCSU(i).CSU_FRECUENCIA_C7, V_TCSU(i).CSU_DURACION_C7,
                            V_TCSU(i).CSU_FRECUENCIA_C8, V_TCSU(i).CSU_DURACION_C8,
                            V_TCSU(i).CSU_FRECUENCIA_C9, V_TCSU(i).CSU_DURACION_C9,
                            V_TCSU(i).CSU_FRECUENCIA_C10,V_TCSU(i).CSU_DURACION_C10,
                            V_TCSU(i).CSU_FRECUENCIA_C11,V_TCSU(i).CSU_DURACION_C11,
                            V_TCSU(i).CSU_FRECUENCIA_C12,V_TCSU(i).CSU_DURACION_C12,
                            V_TCSU(i).CSU_FRECUENCIA_C13,V_TCSU(i).CSU_DURACION_C13,
                            V_TCSU(i).CSU_FRECUENCIA_C14,V_TCSU(i).CSU_DURACION_C14,
                            V_TCSU(i).CSU_FRECUENCIA_C15,V_TCSU(i).CSU_DURACION_C15,
                            V_TCSU(i).CSU_PERIODO_OP);      
    CLOSE C_TCSU;
    COMMIT;
  END;


  --ACTUALIZAR LOS DATOS DIU, FIU, DIU_AP, FIU_AP DE LA TABLA TCSU
 
  -- ABRIR CURSOR C_TCSU_V2
   BEGIN
     OPEN C_TCSU_V2;
          FETCH C_TCSU_V2 BULK COLLECT INTO V_TCSU_V2;

               --ELIMINAR DATOS INGRESADOS ANTERIORMENTE EN QA_TCSU
               BEGIN
               DELETE FROM QA_TCSU 
               WHERE CSU_PERIODO_OP IN (TRUNC(FECHAOPERACION));
               COMMIT;
               END;
             --ALMACENAR INFORMACION EN LA TABLA QA_TCSU NUEVAMENTE
            FORALL i IN V_TCSU_V2.FIRST .. V_TCSU_V2.LAST
               INSERT INTO BRAE.QA_TCSU
                    VALUES (V_TCSU_V2(i).CSU_NIU,
                            V_TCSU_V2(i).CSU_DIU,V_TCSU_V2(i).CSU_DIUM,
                            V_TCSU_V2(i).CSU_FIU,V_TCSU_V2(i).CSU_FIUM,
                            V_TCSU_V2(i).CSU_IDMERCADO,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C1, V_TCSU_V2(i).CSU_DURACION_C1,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C2, V_TCSU_V2(i).CSU_DURACION_C2,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C3, V_TCSU_V2(i).CSU_DURACION_C3,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C4, V_TCSU_V2(i).CSU_DURACION_C4,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C5, V_TCSU_V2(i).CSU_DURACION_C5,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C6, V_TCSU_V2(i).CSU_DURACION_C6,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C7, V_TCSU_V2(i).CSU_DURACION_C7,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C8, V_TCSU_V2(i).CSU_DURACION_C8,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C9, V_TCSU_V2(i).CSU_DURACION_C9,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C10,V_TCSU_V2(i).CSU_DURACION_C10,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C11,V_TCSU_V2(i).CSU_DURACION_C11,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C12,V_TCSU_V2(i).CSU_DURACION_C12,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C13,V_TCSU_V2(i).CSU_DURACION_C13,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C14,V_TCSU_V2(i).CSU_DURACION_C14,
                            V_TCSU_V2(i).CSU_FRECUENCIA_C15,V_TCSU_V2(i).CSU_DURACION_C15,
                            V_TCSU_V2(i).CSU_PERIODO_OP);    
    CLOSE C_TCSU_V2;
    COMMIT;
  END;


   
END QA_PCSX;