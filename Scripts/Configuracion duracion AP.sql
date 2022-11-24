

        SELECT FDD_CODIGOEVENTO,
               FDD_CODIGOELEMENTO, 
               FDD_FINICIAL, 
               FDD_FFINAL,
               ( CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(:FECHAOPERACION),+1) OR FDD_FFINAL IS NULL )
                     THEN
                      (ADD_MONTHS(TRUNC(:FECHAOPERACION),+1) - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
                     ELSE
                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(:FECHAOPERACION))
                        THEN
                           (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TRUNC(:FECHAOPERACION))*24
                        ELSE
                         (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') - TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss'))*24
                         END
                END) AS FDD_DURACION, 
                
               (CASE WHEN (TRUNC(FDD_FINICIAL)<>TRUNC(FDD_FFINAL))--BLOQUE 1 
                 THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 1
                             THEN (
                                  ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                  + 6 
                                  + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
                                  + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')- TRUNC(FDD_FFINAL))*24
                                  )
                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 2
                                        THEN (
                                             ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                             + 6
                                             + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
                                             + 6
                                             + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
                                             )
                                        ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 3
                                                   THEN (
                                                        ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                        + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
                                                        + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - TRUNC(FDD_FFINAL))*24
                                                        )
                                                   ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 4
                                                              THEN (
                                                                   ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                   + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
                                                                   + 6
                                                                   + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
                                                                   )
                                                              ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 5
                                                                         THEN (
                                                                              6
                                                                              + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END) 
                                                                              + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - TRUNC(FDD_FFINAL))*24
                                                                              )
                                                                         ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 6
                                                                                    THEN (
                                                                                         6
                                                                                         + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
                                                                                         + 6
                                                                                         )
                                                                                    ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 7
                                                                                               THEN (
                                                                                                    6
                                                                                                    + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
                                                                                                    + 6
                                                                                                    + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
                                                                                                    )
                                                                                                ELSE(CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 8
                                                                                                           THEN(
                                                                                                               ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                                                               + 6
                                                                                                               + (CASE WHEN ((TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL))<=1) THEN (TO_NUMBER(0)) ELSE (TRUNC(FDD_FFINAL)-TRUNC(FDD_FINICIAL) -1)*12 END)
                                                                                                               + 6
                                                                                                               )
                                                                                                           ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18) --CASO 9
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
                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 8
                            THEN (
                                 ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24 
                                 )
                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 9
                                       THEN (
                                            ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                            + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
                                            )
                                       ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 10
                                                  THEN (
                                                       (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') - (TRUNC(FDD_FFINAL)+(18/24)))*24
                                                       )
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 11
                                                             THEN (
                                                                  (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                  )
                                                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)-- CASO 12
                                                                        THEN (
                                                                             (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                             )
                                                                        ELSE (TO_NUMBER(0))
                                                                   END)
                                                        END)
                                             END)
                                  END)
                       END) 
               END) AS FDD_DURACION_AP,
               
                (CASE WHEN (TRUNC(FDD_FINICIAL)<>TRUNC(FDD_FFINAL))--BLOQUE 1 
                 THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 1
                             THEN (TO_NUMBER(1))
                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 2
                                        THEN (TO_NUMBER(2))
                                        ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 3
                                                   THEN (TO_NUMBER(3))
                                                   ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 4
                                                              THEN (TO_NUMBER(4))
                                                              ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 5
                                                                         THEN (TO_NUMBER(5))
                                                                         ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 6
                                                                                    THEN (TO_NUMBER(6))
                                                                                    ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 7
                                                                                               THEN (TO_NUMBER(7))
                                                                                               ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 8
                                                                                                          THEN (TO_NUMBER(8))
                                                                                                          ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)
                                                                                                                THEN (TO_NUMBER(9))
                                                                                                                --ELSE (TO_NUMBER(0))
                                                                                                          END)
                                                                                                     END)
                                                                                          END)
                                                                               END)
                                                                    END)
                                                         END)
                                              END)
                                   END)
                        END))--INICIA BLOQUE 2
                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 10
                            THEN (TO_NUMBER(10))
                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 11
                                       THEN (TO_NUMBER(11))
                                       ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 12
                                                  THEN (TO_NUMBER(12))
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 13
                                                             THEN (TO_NUMBER(13))
                                                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)-- CASO 14
                                                                        THEN (TO_NUMBER(14))
                                                                        ELSE (TO_NUMBER(0))
                                                                   END)
                                                        END)
                                             END)
                                  END)
                       END) 
               END) AS FDD_CASOS_AP
               
               
         FROM QA_TFDDREGISTRO         
         WHERE (TO_CHAR(FDD_FINICIAL, 'MM/YYYY') = TO_CHAR(TRUNC(:FECHAOPERACION),'MM/YYYY') 
                OR TO_CHAR(FDD_FFINAL, 'MM/YYYY') = TO_CHAR(TRUNC(:FECHAOPERACION),'MM/YYYY'))
