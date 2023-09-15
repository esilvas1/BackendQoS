       SELECT FDD_CODIGOEVENTO,
              FDD_CODIGOELEMENTO, 
               FDD_FINICIAL, 
               FDD_FFINAL,
               (CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(:FECHAOPERACION),+1) OR FDD_FFINAL IS NULL )
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
                
               (CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(:FECHAOPERACION),+1) OR FDD_FFINAL IS NULL )
                     THEN
                      (
 ----------------------FDD_FFINAL ES MAYOR AL TIEMPO DE OPERACION O ES NULL
                         ((CASE WHEN (TRUNC(FDD_FINICIAL)<>(ADD_MONTHS(TRUNC(:FECHAOPERACION),+1)-1))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                        THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6)-- CASO 1
                                                  THEN (
                                                       ((TRUNC(FDD_FINICIAL)+(6/24))-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                       + 6 
                                                       + (ADD_MONTHS(TRUNC(:FECHAOPERACION),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2
                                                       )
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18)--CASO2
                                                             THEN (
                                                                   6
                                                                   + (ADD_MONTHS(TRUNC(:FECHAOPERACION),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2  
                                                                   )
                                                             ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18)--CASO 3
                                                                        THEN (
                                                                             ((TRUNC(FDD_FINICIAL)+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                             + (ADD_MONTHS(TRUNC(:FECHAOPERACION),+1)-(TRUNC(FDD_FINICIAL)+1))*24/2
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
                                                                            (ADD_MONTHS(TRUNC(:FECHAOPERACION),+1)-TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS'))*24
                                                                            )
                                                                  END)
                                                       END)
                                             END) 
                                        END))
 ----------------------                          
                      )
                     ELSE
                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(:FECHAOPERACION))
                        THEN
                           (
 ---------------------------FDD_FINICIAL ES MENOR AL TIEMPO DE OPERACION
                             ((CASE WHEN (TRUNC(FDD_FFINAL)<>(TRUNC(:FECHAOPERACION)))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                            THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 7
                                                      THEN (                                                           
                                                           (TRUNC(FDD_FFINAL)-TRUNC(:FECHAOPERACION))*24/2
                                                           + (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TRUNC(FDD_FFINAL))*24
                                                           )
                                                      ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO8
                                                                 THEN (
                                                                      (TRUNC(FDD_FFINAL)-TRUNC(:FECHAOPERACION))*24/2
                                                                      + 6 
                                                                      )
                                                                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 9
                                                                            THEN (
                                                                                 (TRUNC(FDD_FFINAL)-TRUNC(:FECHAOPERACION))*24/2
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
                
               (CASE WHEN (TO_DATE(TO_CHAR(FDD_FFINAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') >= ADD_MONTHS(TRUNC(:FECHAOPERACION),+1) OR FDD_FFINAL IS NULL )
                     THEN
                      (
 ----------------------FDD_FFINAL ES MAYOR AL TIEMPO DE OPERACION O ES NULL
                         ((CASE WHEN (TRUNC(FDD_FINICIAL)<>(ADD_MONTHS(TRUNC(:FECHAOPERACION),+1)-1))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                        THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6)-- CASO 1
                                                  THEN (TO_NUMBER(1))
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18)--CASO2
                                                             THEN (TO_NUMBER(2))
                                                             ELSE (TO_NUMBER(3))
                                                        END)
                                             END))--INICIA BLOQUE 2 (EN EL MISMO DIA)
                                        ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6)--CASO 4
                                                  THEN (TO_NUMBER(4))
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18)--CASO 5
                                                            THEN (TO_NUMBER(5))
                                                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18)
                                                                       THEN (TO_NUMBER(6))
                                                                  END)
                                                       END)
                                             END) 
                                        END))
 ----------------------                          
                      )
                     ELSE
                        CASE WHEN (TO_DATE(TO_CHAR(FDD_FINICIAL,'DD/MM/YYYY hh24:mi:ss'),'DD/MM/YYYY hh24:mi:ss') < TRUNC(:FECHAOPERACION))
                        THEN
                           (
 ---------------------------FDD_FINICIAL ES MENOR AL TIEMPO DE OPERACION
                             ((CASE WHEN (TRUNC(FDD_FFINAL)<>(TRUNC(:FECHAOPERACION)))--BLOQUE 1 (AFECTACIONES EN DIAS DIFERENTES)
                                            THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 1
                                                      THEN (TO_NUMBER(7))
                                                      ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO2
                                                                 THEN (TO_NUMBER(8))
                                                                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 3
                                                                            THEN (TO_NUMBER(9))
                                                                       END)
                                                            END)
                                                 END))--INICIA BLOQUE 2 (EN EL MISMO DIA)
                                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 4
                                                      THEN (TO_NUMBER(10))
                                                      ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 5
                                                                THEN (TO_NUMBER(11))
                                                                ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FFINAL)>=18)
                                                                           THEN (TO_NUMBER(12))
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
                                        THEN ((CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 1
                                                  THEN (TO_NUMBER(13))
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 2
                                                                 THEN (TO_NUMBER(14))
                                                                 ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 3
                                                                           THEN (TO_NUMBER(15))
                                                                           ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 4
                                                                                     THEN (TO_NUMBER(16))
                                                                                     ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)--CASO 5
                                                                                               THEN (TO_NUMBER(17))
                                                                                               ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 6
                                                                                                         THEN (TO_NUMBER(18))
                                                                                                         ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 7
                                                                                                                        THEN (TO_NUMBER(19))
                                                                                                                        ELSE(CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18)--CASO 8
                                                                                                                                  THEN(TO_NUMBER(20))
                                                                                                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=6 AND EXTRACT(HOUR FROM FDD_FFINAL)<18) --CASO 9
                                                                                                                                            THEN (TO_NUMBER(21))
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
                                                  THEN (TO_NUMBER(22))
                                                  ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 9
                                                            THEN (TO_NUMBER(23))
                                                            ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=6 AND EXTRACT(HOUR FROM FDD_FINICIAL)<18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)--CASO 10
                                                                           THEN (TO_NUMBER(24))
                                                                           ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)<6 AND EXTRACT(HOUR FROM FDD_FFINAL)<6)-- CASO 11
                                                                                     THEN (TO_NUMBER(25))
                                                                                     ELSE (CASE WHEN (EXTRACT(HOUR FROM FDD_FINICIAL)>=18 AND EXTRACT(HOUR FROM FDD_FFINAL)>=18)-- CASO 12
                                                                                               THEN (TO_NUMBER(26))
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
                END) AS FDD_CASOS_AP
               
               
         FROM QA_TFDDREGISTRO         
         WHERE (TO_CHAR(FDD_FINICIAL, 'MM/YYYY') = TO_CHAR(TRUNC(:FECHAOPERACION),'MM/YYYY') 
                OR TO_CHAR(FDD_FFINAL, 'MM/YYYY') = TO_CHAR(TRUNC(:FECHAOPERACION),'MM/YYYY'))
