# If no commandline parameters are passed, or if you prefer setting values in a file, hardcode the variable values.
if [ -z "$1" ]; then
ORACLE_HOME=/full/path/to/oracle/dbhome
ORACLE_HOST=YOUR_ORACLE_HOSTNAME
ORACLE_SID=YOUR_ORACLE_DB_NAME
ORACLE_SCHEMA=YOUR_ORACLE_SCHEMA_NAME
ORACLE_PASSWORD=PASSWORDtoORACLEschema123
TABLENAME=COMMA,SEPARATED,LIST,OF,TABLES,TO,LOAD,INTO,POSTGRES
POSTGRES_HOST=YOUR_PG_HOSTNAME
POSTGRES_PORT=5432
POSTGRES_DBNAME=YOUR_POSTGRES_DBNAME
POSTGRES_SCHEMA=THE_PG_SCHEMA_TO_RECEIVE_THE_DATA
POSTGRES_USER=the_postgres_user_you_will_connect_as
POSTGRES_PASSWORD=PASSWORDtoPGschema234
POSTGIS_SCHEMA=WHEREVER_YOUR_POSTGIS_IS,CAN,BE,MULTIPLE,SCHEMAS
ORACLE_PK=ORACLE_TABLE_PK_COL_NAME # Note that this must be the same name for all tables in this export. If there are different pk column names for each table in TABLENAME, you must export each table by itself.

else 
# Eventually will swap this bad system out with getopts
  ORACLE_HOME=$1
  ORACLE_SID=$2
  ORACLE_SCHEMA=$3
  ORACLE_PASSWORD=$4
  POSTGRES_HOST=$5
  POSTGRES_PORT=$6
  POSTGRES_DBNAME=$7
  POSTGRES_SCHEMA=$8
  POSTGRES_PASSWORD=$9
  POSTGRES_SCHEMA=$10
  POSTGIS_SCHEMA=$11
fi
###   END OF EDIT SECTION   ###

CURR_DATE=`date +%d_%m_%Y`
CURR_TIME=`date '+%X'`
echo Starting transfer at $CURR_TIME

# The default ora2pg conf file is /etc/ora2pg/ora2pg.conf
echo "Generating SQL (TYPE = TABLE, No PK set!)"
echo Path: 
echo "/data/export/$CURR_DATE (inside container)" 
docker exec -d ora2pg mkdir -p /data/export/$CURR_DATE
# ora2pg conf file values:
# You can optionally add a where clause, to transfer only some of the data.
cat > ./ora2pg.conf << EOF
ORACLE_HOME             $ORACLE_HOME
ORACLE_DSN              dbi:Oracle:host=$ORACLE_HOST;service_name=$ORACLE_SID
ORACLE_USER             $ORACLE_SCHEMA
ORACLE_PWD              $ORACLE_PASSWORD
SCHEMA                  $ORACLE_SCHEMA
TYPE                    TABLE
ALLOW                   $TABLENAME
BINMODE   	            utf8
PG_DSN                  dbi:Pg:dbname=$POSTGRES_DBNAME;host=$POSTGRES_HOST;port=$POSTGRES_PORT
PG_USER                 $POSTGRES_USER
PG_PWD                  $POSTGRES_PASSWORD
PG_SCHEMA               $POSTGRES_SCHEMA
POSTGIS_SCHEMA          $POSTGIS_SCHEMA
OUTPUT        	        output.sql
OUTPUT_DIR     		    /data/export/$CURR_DATE
STOP_ON_ERROR           0
AUTODETECT_SPATIAL_TYPE 0
CONVERT_SRID            1-------------------------
DATA_LIMIT              10000
PG_NUMERIC_TYPE 	    1
PG_INTEGER_TYPE 	    1
JOBS            	    8
ORACLE_COPIES   		8
PARALLEL_TABLES 		2
DEFINED_PK      		$ORACLE_PK
DEFAULT_NUMERIC 		real
DISABLE_PARTITION       1
USER_GRANTS             1
TRANSACTION             readonly
PKEY_IN_CREATE			1
FILE_PER_CONSTRAINT		1
EXPORT_SCHEMA			1
CREATE_SCHEMA			0
LOG_ON_ERROR			1
TRUNCATE_TABLE			1
#WHERE					ROWNUM <= 10000
EOF

docker exec ora2pg rm -f /etc/ora2pg/ora2pg.conf
docker cp ./ora2pg.conf ora2pg:/etc/ora2pg

docker exec ora2pg rm -f /data/export/$CURR_DATE/output.sql
echo Starting ora2pg..
docker exec ora2pg ora2pg
echo Preparing output sqlfile...
docker cp ora2pg:/data/export/$CURR_DATE/output.sql ./
export PGPASSWORD=$POSTGRES_PASSWORD
echo Running SQL..
cat > ~/.psqlrc << EOF
SET search_path TO :schema,$POSTGIS_SCHEMA;
EOF
psql -h $POSTGRES_HOST -d $POSTGRES_DBNAME -p $POSTGRES_PORT -U $POSTGRES_USER -v schema=$POSTGRES_SCHEMA < ./output.sql
echo Changing to Copy mode
sed -i 's/TYPE                    TABLE/TYPE                    COPY/' ./ora2pg.conf
docker exec ora2pg rm -f /etc/ora2pg/ora2pg.conf
docker cp ./ora2pg.conf ora2pg:/etc/ora2pg
CURR_TIME=`date '+%X'`
echo Starting data export at $CURR_TIME
docker exec ora2pg ora2pg 

# In case the direct transfer doesn't work, this will create an sqlfile for ora2pg to manually load into postgres. You shouldn't need this but it is a nice option to have. To use it just comment out "docker exec ora2pg ora2pg" and uncomment the next 4 lines. 
#echo Done data export. Preparing data sqlfile..
#docker cp ora2pg:/data/export/$CURR_DATE/`echo $TABLENAME | awk '{print toupper($0)}'`_output.sql ./
#echo Starting data loading..
#psql -h $POSTGRES_HOST -d $POSTGRES_DBNAME -p $POSTGRES_PORT -U $POSTGRES_USER -v schema=$POSTGRES_SCHEMA < ./`echo $TABLENAME | awk '{print toupper($0)}'`_output.sql
CURR_TIME=`date '+%X'`
echo Transfer done at: $CURR_TIME 
