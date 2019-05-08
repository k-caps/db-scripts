-- on prod
expdp directory=DPDUMP dumpfile=file_name.dmp logfile=file_name.log tables=schema.table,schema.table 

scp /path/to/dpdump/file_name.dmp oracle@hostname:/path/to/dpdump/

-- on dev
impdp directory=DPDUMP dumpfile=file_name.dmp logfile=file_name.log tables=chema.table,schema.table remap_schema=prodschema:devschema 

--------------------------------------------------------------------------------------
Options:
--------------------------------------------------------------------------------------
schemas=SCHEMANAME
remap_tablespace=SOURCETBS:DESTTBS
remap_schema=SOURCE_SCHEMA_NAME:DEST_SCHEMA_NAME
sqlfile=dmpname.sql
encryption_password=thepassword
exclude=grants
exclude=constraints
exclude=function
exclude=package
exclude=procedure 


--------------------------------------------------------------------------------------
Things to create  if needed:
--------------------------------------------------------------------------------------
$ mkdir /path/to/dpdump/
SQL> create directory DPDUMP as '/path/to/dpdump';
SQL> create tablespace impdptbs datafile '/path/to/tablespaces/impdptbs.dbf' size 24M autoextend on;
SQL> create temporary tablespace impdptmp tempfile '/path/to/tablespaces/impdptmp.dbf' size 24M autoextend on;
SQL> create undo tablespace impdpundo datafile '/path/to/tablespaces/impdpundo.dbf' size 24M autoextend on;

grant read, write on directory DPDUMP to username;
--------------------------------------------------------------------------------------
Imp: (old version of impdp)
--------------------------------------------------------------------------------------
imp full=y show=y file='/path/to/dump/name.dmp' log='/path/to/dump/name.dmp'

-------------------------------------------------------------------------------------
Options:
-------------------------------------------------------------------------------------
fromuser=user1 touser=user2
INCLUDE=TABLE"LIKE '%'"
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

