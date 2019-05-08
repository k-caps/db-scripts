# Oracle-DB--Manual-hot-backup
Script for performing a manual hot backup on an oracle database. 

Copy the three files locally to your windows computer, and run the backupdb.bat . You dont have to touch the sql files.
Whats happening is the .bat will create the path c:\temp\dbfilesbackup , with subdirectories for redo logs, control files, and tablespace files.
BE CAREFUL, because if you already have something in those paths it will be OVERWRITTEN. (Or if you change the path.)
Then it runs the backupdb.sql , which puts the db into data backup mode, and generates another .bat file which will copy the files to the newly created backup folders.
Then backupdb.bat runs the generated .bat, and then, runs the endbackup.sql which puts the database out of backup mode.
NOTE- Make sure you change the password and database name in both the sql files; connection string to match your database!!

https://medium.com/@kobirosenstein/backing-up-an-oracle-database-manually-eaf1bc9f3ea7#.o3ihbn81h
