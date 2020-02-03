\set show_schema_size 'select pg_size_pretty(pg_schema_size(:''_SCHEMANAME'')) as :_SCHEMANAME;'
\set load_schema '\\set _SCHEMANAME'
\set load_db '\\set _DBNAME'
\set show_tables_by_size 'select table_schema, table_name, pg_size_pretty(pg_relation_size(''"''||table_schema||''"."''||table_name||''"'')) as "table_size" from information_schema.tables where table_schema not in (''pg_catalog'',''information_schema'',''pgagent'',''cron'') order by 3 desc;'
\set kill_all_current_db_connections '\\set _DB_TO_KILL :DBNAME \\c postgres \\\\ select pg_terminate_backend(pid) from pg_stat_activity where datname=:''_DB_TO_KILL''; \\ unset :_DB_TO_KILL'
\set kill_single_db_connections '\\c postgres \\\\ select pg_terminate_backend(pid) from pg_stat_activity  where datname=:''_DBNAME'';'
\set kill_all_cluster_connections '\\c postgres \\\\ select pg_terminate_backend(pid) from pg_stat_activity;'
\set enable_connections '\\c postgres \\echo Enabling connections for DB :_DBNAME \\\\ alter database :_DBNAME with allow_connections = ''true'';'
\set disable_connections '\\c postgres \\echo Disabling connections for DB :_DBNAME \\\\ alter database :_DBNAME with allow_connections = ''false'';'
\set show_current_db_size 'select sizedb() as "current_database_size";'
\set show_number_of_current_connections 'select count(*) as "Currently connected sessions:" from pg_stat_activity;'
\set QUIET 1
do $funcs$
begin
  begin
   CREATE OR REPLACE FUNCTION pg_schema_size(text) RETURNS BIGINT AS $$ SELECT SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::BIGINT FROM pg_tables WHERE schemaname = $1 $$ LANGUAGE SQL;
   CREATE OR REPLACE FUNCTION sizedb() RETURNS text AS $$ SELECT pg_size_pretty(pg_database_size(current_database())); $$ LANGUAGE SQL;
  exception when duplicate_function then
    null;
  end;
end $funcs$;
\unset QUIET
