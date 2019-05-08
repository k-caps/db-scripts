
	conn sys/Bb123456@DB12C as sysdba
	set serveroutput on 
	set feedback off;
	set heading off;
	spool c:\temp\dbfilesbackup\copydb.bat;
	
	declare
		v_IS_ARCHIVEMODE varchar2(12);
		v_CONTROL_FILE_PATH varchar2(80);
	begin 
		-- Determines whether or not db is in archivelog mode (necessary in order to put DB into backup mode.)
		select LOG_MODE  
		into V_IS_ARCHIVEMODE
		from V$DATABASE;
		
		if  V_IS_ARCHIVEMODE = 'NOARCHIVELOG' then
			dbms_output.put_line('Procedure corrupted. Cancel batch job (press ctrl + c),');
			dbms_output.put_line('Set the database to archivelog mode and run this script again.');
		end if;
	end;
	/
	
	-- Put DB in backup mode
	alter database begin backup;
	
	-- generate .bat script in (as of now) predetermined location which will be run by "Backupdb.bat" and which copies the dbf files and then the redo logs to the (as of now) predetermined location.
	select 'xcopy /s'||' ' ||  FILE_NAME  ||' '|| 'c:\temp\dbfilesbackup\dbfs'
	from DBA_DATA_FILES;
	
	select 'xcopy /s'||' ' ||   MEMBER  ||' '|| 'c:\temp\dbfilesbackup\redologs'
	from V$LOGFILE;
	
	select 'xcopy /s'||' ' ||  DESTINATION ||' '|| 'c:\temp\dbfilesbackup\arcredologs'
	from V$ARCHIVE_DEST
	where ROWNUM = 1;
	
	select 'exit;' from dual;
	spool off;
	exit;

