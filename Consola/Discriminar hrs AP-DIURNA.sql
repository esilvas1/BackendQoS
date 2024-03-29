﻿    SELECT SUM(TX.CSX_DIUM*UTR.USER_TRAFO) AS UIXTI_M, SUM(TX.CSX_FIUM*UTR.USER_TRAFO) AS UI_M, SUM(TX.CSX_FRECUENCIA_C1*UTR.USER_TRAFO) AS UI_C1
    --INTO V_UIXTI_M, V_UI_M, V_UI_C1
    FROM QA_TCSX TX
    LEFT OUTER JOIN (SELECT TC1_CODCONEX, COUNT(TC1_TC1) AS USER_TRAFO
                    FROM QA_TTC1
                    WHERE TC1_TIPCONEX='T'
                    AND TC1_PERIODO= 202101
                    GROUP BY TC1_CODCONEX) UTR
    ON UTR.TC1_CODCONEX=TX.CSX_TRANSFOR
    WHERE TX.CSX_PERIODO_OP=TO_DATE('01/01/2021','DD/MM/YYYY')
    GROUP BY TX.CSX_PERIODO_OP
    UNION ALL
    SELECT SUM(TU.CSU_DIUM) AS UIXTI_M, SUM(TU.CSU_FIUM) AS UI_M, SUM(TU.CSU_FRECUENCIA_C1) AS UI_C1
    --INTO V_UIXTI_M, V_UI_M, V_UI_C1
    FROM QA_TCSU TU
    WHERE TU.CSU_PERIODO_OP=TO_DATE('01/01/2021','DD/MM/YYYY')
    GROUP BY TU.CSU_PERIODO_OP;



