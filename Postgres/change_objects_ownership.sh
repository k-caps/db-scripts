#!/bin/bash

# Usage:
# All objects in <dbname> will be transferred to <user_name>
# chmod +x ch_ownership.s && sh ch_ownership.sh -d dbname -user_name

# Vars:
WD=~/pg_change_ownership
mkdir -p $WD
SQLFILE=$WD/query_generator.sql
DMLFILE=$WD/dmlcommands.sql
DB_NAME=''
USER_NAME=''
while getopts "d:u:" arg; do
        case $arg in 
                d) DB_NAME="${OPTARG}";;
                u) USER_NAME="${OPTARGE}";;
        esac
done

# If you'd rather hardcode/ set the variables infile, do it here:
#DB_NAME=<value>
#USER_NAME=<value>

printf "Building sqlfile..\n"
# The "\o" causes  psql to save the genrated queries in the specified file.
cat > $SQLFILE << EOF
\o $DMLFILE
EOF

# Tables
cat >> $SQLFILE << EOF
select 'ALTER TABLE '||schemaname||'."'||tablename||'" OWNER TO $USER_NAME;' as "--Commands to run--"
FROM pg_tables WHERE NOT schemaname IN ('pg_catalog','information_schema')
UNION ALL
EOF

# FDW tables
cat >> $SQLFILE << EOF
select 'ALTER TABLE '||schemaname||'."'||tablename||'" OWNER TO $USER_NAME;'
FROM information_schema.foreign_tables WHERE NOT foreign_table_schema IN ('pg_catalog','information_schema')
EOF

# Views
cat >> $SQLFILE << EOF
select 'ALTER VIEW '||schemaname||'."'||tablename||'" OWNER TO $USER_NAME;'
FROM information_schema.tables WHERE table_type ='VIEW' AND NOT table_schema IN ('pg_catalog','information_schema')
EOF

# Schemas
cat >> $SQLFILE << EOF
select 'ALTER SCHEMA "'||schema_name||'" OWNER TO $USER_NAME;'
FROM information_schema.schemata WHERE NOT schema_name IN ('pg_catalog','information_schema')
UNION ALL
EOF

# Sequences
cat >> $SQLFILE << EOF
select 'ALTER SEQUENCE '||sequence_schema||'."'||sequence_name||'" OWNER TO $USER_NAME;'
FROM information_schema.sequences WHERE NOT sequence_schema IN ('pg_catalog','information_schema')
UNION ALL
EOF

# Indexes
cat >> $SQLFILE << EOF
select 'ALTER INDEX "'||schemaname||'"."'||indexname||'" OWNER TO $USER_NAME;'
FROM pg_indexes WHERE NOT schemaname in ('pg_catalog','information_schema')
UNION ALL
EOF

# Extensions
cat >> $SQLFILE << EOF
select 'UPDATE pg_extension SET extowner=(SELECT oid FROM pg_authid WHERE rolname= ''$USER_NAME'') WHERE extname <> ''plpgsql'';'
UNION ALL
EOF
### This is possibly necessary. If you need it, add it after the extensions query, and replace the ";" with the "union all" ###
#select 'UPDATE pg_shdepend SET refobjid =(SELECT oid FROM pg_authid WHERE rolname = ''$USER_NAME'')
#WHERE deptype=''o'' AND refobjid = (SELECT extowner FROM pg_extension WHERE extname <> ''plpgsql'');'
#UNION ALL

# SQL reassign owned to catch anything that doesn't belong to postgres and that the script missed
cat >> $SQLFILE << EOF
select 'REASSIGN OWNED BY "'||rolname||'" TO $USER_NAME;'
FROM pg_roles WHERE rolname NOT IN ('repmgr','barman','postgres','streaming_barman','splunk-agent')
AND rolname !~ 'pg_'
AND rolname <> '$USER_NAME';
EOF

printf "Ownership changes:\n"
# Execute change of ownership:
# Generates the ALTER commands into the dmlfile using the above queries
psql -d $DB_NAME -U postgres -f $SQLFILE
sed -i -e 's/^([0-9]\+.*//g' $DMLFILE
cat $DMLFILE
printf "Executing commands:\n"
# Execute the generated queries
psql -d $DB_NAME -U postgres -f $DMLFILE

printf "\n\nDone.\n"
