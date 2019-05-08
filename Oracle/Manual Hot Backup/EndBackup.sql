conn sys/Bb123456@DB12C as sysdba

-- Backup control file
alter database backup controlfile to 'c:\temp\dbfilesbackup\controlfiles\CONTROL01.ctl';
alter database end backup;
exit;