

--DISPONIBILIAD DE ESAPCION EN EL ESQUEMA
SELECT ROUND(((SELECT ROUND(SUM(bytes)/1024/1024,0) FROM DBA_FREE_SPACE   WHERE TABLESPACE_NAME = 'TSP_DATOS_BRAE' GROUP BY  TABLESPACE_NAME )/(SELECT ROUND(SUM(BYTES/1024/1024),0) FROM DBA_DATA_FILES B WHERE TABLESPACE_NAME = 'TSP_DATOS_BRAE' GROUP BY B.TABLESPACE_NAME))*100,1) AS PORCNETAJE_DISPONIBLE,
       (SELECT ROUND(SUM(bytes)/1024/1024,0) FROM DBA_FREE_SPACE   WHERE TABLESPACE_NAME = 'TSP_DATOS_BRAE' GROUP BY  TABLESPACE_NAME ) AS "EspacioDisponible(Mb)",
       (SELECT ROUND(SUM(BYTES/1024/1024),0) FROM DBA_DATA_FILES B WHERE TABLESPACE_NAME = 'TSP_DATOS_BRAE' GROUP BY B.TABLESPACE_NAME) AS "EspacioTotal(Mb)" 
FROM DUAL;

 -- TAMAÑO POR TABLAS 
  SELECT SEGMENT_NAME TABLE_NAME,
         SUM(BYTES)/(1024*1024) TABLE_SIZE_GIGAS
  FROM USER_EXTENTS
  WHERE SEGMENT_TYPE='TABLE'
  AND SEGMENT_NAME IN (SELECT TABLE_NAME FROM TABS)
  GROUP BY SEGMENT_NAME
  ORDER BY 2 DESC;


---ELIMINAR DATOS DE LA PAPELARA DE RECICLAJE (Causado por el DROP)
PURGE RECYCLEBIN;
SELECT * FROM RECYCLEBIN;
SELECT * FROM USER_RECYCLEBIN;
SELECT * FROM CAT;

--CREATE TABLE QA_TTT11_REPORTE AS (SELECT * FROM "BIN$Me14mWpoQvKmCROXGxJkxw==$0");


