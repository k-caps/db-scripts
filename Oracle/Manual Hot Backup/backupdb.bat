rmdir /s /q c:\temp\dbfilesbackup
md C:\temp\dbfilesbackup\controlfiles
md C:\temp\dbfilesbackup\redologs
md C:\temp\dbfilesbackup\arcredologs
md C:\temp\dbfilesbackup\dbfs
sqlplus /nolog @backupdb.sql
start c:\temp\dbfilesbackup\copydb.bat
sqlplus /nolog @endbackup.sql
exit
