# Install and configure barman
# Create barman user:
	adduser barman
	passwd barman
# If you have yum or apt-get, simply install from there. Otherwise, you will have to build from sources. 
# To build from sources:
# Copy the files dependencies into the following path on the host. (/home/barman/.local/lib/python2.7/site-packages)
# cd into the folder containing the files and run
	chmod +x setup.py
	./setup.py build
	/usr/bin/python2.7 setup.py install --user 
# Setup passwordless ssh between the barman server and the database server
# Set the pg_hba and postgresql.conf on the database server. The hba must contain the following lines:
	local   replication     postgres                                trust
	host    replication     postgres        127.0.0.1/32            trust
	host    replication     postgres        ::1/128                 trust
	host    replication     barman          <barman server ip>/32   trust
# The following settings must be set in the postgresql.conf :
	wal_level = hot_standby 
	archive_mode = on
	archive_command = 'rsync -a %p barman@<barmanhostname>:/path/to/barman_home/<database_hostname>/incoming/%f'
# If you're not sure what path to put, you can find it by typing:
	
# Where <servername> is whatever you set it to be in the square brackets in each server configuration file. (found by default in /etc/barman.d) Unless specifically set otherwise, the incoming_wals_directory will be in barman_home/<server_name>/incoming. Barman_home can be found in either the main barman.conf that you are using, (default is /etc/barman.conf), or by running:
	barman show-server <servername> | grep barman_home
# Configure barman
# Global level parameters that you  should edit/know (found in /etc/barman.conf)
	barman_home = <directory in which all backups of all servers resides> # Make sure it has enough free space!!!
	log_file = <fullpath to barman's log file>
	configuration_files_directory = <path to directory which will contain server config files> (default is /etc/barman.d )
	minimum_redundancy = <number of backups to always have>
	retention_policy = <specify how many backups/how long a time window of backups barman keeps before autodeletion>
# Server configuration
# Each server should have its' own configuration file, in the configuration_files_directory you set in the server configuration. File name should be <servername>.conf
# Example of a server configuration:

	; Postgres Dev DB
	[SERVERNAME]
	; Human readable description
	description =  "Example of a postgres database configuration"

	; SSH options
	ssh_command = ssh postgres@server -p 24

	; PostgreSQL connection string
	conninfo = host=servername user=postgres port=5432 dbname=postgres password=xxxxxxx

	; Minimum number of required backups (redundancy)
	minimum_redundancy = RECOVERY WINDOW OF 1 MONTHS

	; Archiving strategy
	archiver = on

# Any parameter set in the global configuration file can be overridden here. 
# All Barman commands will use a server name. (barman backup <servername>) The server name that will be used is the value inside the square brackets.

# Using barman
# Run the following commands to start 
	barman cron
	barman switch-xlog --force --archive <servername>

# To backup a server:
	barman backup <servername>

# To see all backups a server has:
	barman list-backup <servername>

# To see details of a particular backup:
		barman show-backup <backup id/name> #(taken from list-backup)
		
# To restore from a backup
# Notice that for a database on docker container, you DO NOT put the file inside the container, rather you put them on the host and use docker volumes.
# You must use a full timestamp, or PITR will fail
	barman recover --target-time "2017-07-30 11:32:00" --remote-ssh-command "ssh <user>@<database_host>" <servername> <backup id/name> <pgdata fullpath> 

# Scheduling of backups should be done with crontab
# barman cron should be set in the crontab to run every minute

