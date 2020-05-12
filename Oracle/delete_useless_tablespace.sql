-- sqlplus / as sysdba
--select tablespace_name from dba_tablespaces;

alter session set container = xepdb1;
create undo tablespace undotbs02 datafile '/opt/oracle/oradata/XE/XEPDB1/undotbs02.dbf' size 24M autoextend off;
alter system set undo_tablespace = undotbs02 scope=both;
drop tablespace undotbs01; --INCLUDING CONTENTS AND DATAFILES;
--rm -f /opt/oracle/oradata/XE/XEPDB1/undotbs01.dbf
