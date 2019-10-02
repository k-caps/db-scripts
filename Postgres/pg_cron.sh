# This file is psuedocode, meant to document steps rather than be a script.

# Vars:
PG_VERSION=11
USERNAME=secretname
DBNAME=secretdbname

# packages to install:
pgcron_$PG_VERSION

# Changes in postgresql.conf:

#EXTENSIONS
shared_preload_libraries='repmgr'pg_cron' # repmgr is NOT necessary, it is present to demonstrate multiple libraries..
cron.database_name='$DBNAME'

# Add entries to pg_hba.conf:
# pg_cron_connections
local $DBNAME $USERNAME trust
host  $DBNAME $USERNAME localhost trust

# As superuser inside $DBNAME:
create extension pg_cron;
grant usage on schema cron to $USERNAME;

# restart pg:
pg_ctl restart
