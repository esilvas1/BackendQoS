CREATE DATABASE LINK GTECH
    CONNECT TO LSANTAFE IDENTIFIED BY MDEPROD2021
    USING '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=EPM-PO13)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=GENEPROD)))';
/


