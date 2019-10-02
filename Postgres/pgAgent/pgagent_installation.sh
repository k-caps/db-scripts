# This file is psuedocode, it might run but it's meant to document the steps rather than be a script

# Vars:
DBNAME=secretdb
USERNAME=secretname

# pgAGent:
sudo yum install pgagent_11
sudo su - postgres

cat > $PGDATA/pg_hba.conf << EOF
# pgAgent connections
local $DBNAME $USERNAME trust
host  $DBNAME $USERNAME 127.0.0.1/32 trust
EOF

# ^ The hba also needs the client's ip to be able to connect as $USERNAME
pg_ctl reload 
psql -d $DBANME -U $USERNAME -c "create extension pgagent"

/usr/bin/pgagent_11 hostaddr=127.0.0.1 dbname=$DBANME user=$USERNAME
pg_ctl reload
