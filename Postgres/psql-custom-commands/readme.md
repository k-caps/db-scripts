The point of this is to make managing databases easier for DBAs and / or sysadmins, who may not know how to use databases very well.   
Whether it's checking size on disk, blocking connections, or killing all existing connections on a database, there is a sparkly new command for you to use instead of googling the sql or plpgsql syntax.   
Once a Postgres cluster has the contents of the provided psqlrc file (saved in ~/.psqlrc) and the provided plpgsql function has been run on all databases in the cluster, the following shortcuts will be available in new psql sessions:   
```
:show_tables_by_size
:load_schema <schema_name>
:show_schema_size
:kill_all_current_db_connections
:load_db <db_name>
:kill_single_db_connections
:disable_connections
:enable_connections
```   
All commands/shortcuts set here follow the format `:lower_case`. All variables used internally by psql follow the format `:UPPER_CASE`. Variables which this code sets but are not commands follow the format `:_UPPER_CASE`.   
One-liners, including using psql's native meta-commands (the backslash commands such as `\dx` and `\dt`), are possible using psql's meta-command terminator, `\\`.   
For examples, see the examples section at the bottom of this file.   
`\\` is NOT a pipeline, rather it resembles the function of a semicolon (;) in bash or sql.   
Because `\` is also the escape character in psql, when "pipelining" using `\\` with meta-commands, `\` must be escaped with another `\`, leading to a `\\` which is at the start of a command or meta-command. (More on this in the Variables section).   
   
Any of these shortcuts/commands which begin with a meta-command must be "pipelined" WITHOUT the `\\` terminator, as they themselves start a new command. See the examples. If it doesn't work the way you expect, try with and without the `\\`.   

Variables
----
All the commands set here are actually just psql-internal variables, which contain a mix of sql statements, plpgsql functions, and other variables which are not useful to the user, only being used internally by the actual :commands.   
The normal syntax of a psql variable assignment is `\set varname '<value>'`.   
To view the value of any psql variable, including the logic behind the new commands this code adds, use `\echo :varname`.   
You can even edit the logic of any of the commands for the current session as you wish by changing the output of `\echo` and saving it with a new  `\set` meta-command. These changes will last until you close psql and will overwrite the previous value.   


- **Command** `load_schema`
  - Description: This loads a schema. All commands that interact with a schema will use the loaded schema.
  - Comments: This is an alias, and is equivalent to `\set _SCHEMANAME '<schema_name>'`
  - Usage: `:load_schema <schema_name>`   

- **Command** `load_db`
  - Description: This loads a db. All commands that interact with a database will use the loaded db.
  - Comments: This is an alias, and is equivalent to `\set _DBANAME '<db_name>'`
  - Usage: `:load_db <db_name>` 

- **Command** `show_schema_size`
  - Description: Outputs the size of the loaded schema in a pretty, human readable format.
  - Usage: `:show_schema_size`   

- **Command** `disable_connections`
  - Description: Disables all new connections to the loaded database. Does not kill existing sessions.
  - Comments: Must be run as a superuser.
  - Usage: `:disable_connections`   

- **Command** `enable_connections`
  - Description: Allows new connections to the loaded database.
  - Comments: Must be run as a superuser.
  - Usage: `:disable_connections`   

- **Command** `kill_all_current_db_connections`
  - Description: Kills all connections to the current database. Must be run as superuser.
  - Comments: Does not call "kill_single_db_connections" with current db as a parameter. They work similarly but do different things. 
  - Usage: `:kill_all_current_db_connections`   

- **Command** `kill_single_db_connections`
  - Description: Kills all connections to the loaded database
  - Comments: Must be run as a superuser.
  - Usage: `:kill_single_db_connections`   

- **Command** `kill_all_cluster_connections`
  - Description: Kills all connections to all databases in the cluster.
  - Comments: Must be run as a superuser.
  - Usage: `:kill_all_cluster_connections`   

- **Command** `show_tables_by_size`
  - Description: Displays all tables in all schemas, along with their size. Does not show tables in the following schemas:
    - information_schema
    - pg_catalog
    - cron
    - pgagent
  - Usage: `:show_tables_by_size`   

Examples
----
Kill all connections to the database "testdb":
```
:load_db testdb \\ :kill_single_db_connections
You are now connected to database "postgres" as user "postgres".
 pg_terminate_backend
---------------------
(86 rows)
```

Check the size of the "cron" schema:
```
:load_schema
:show_schema_size
 cron
------
 16 kB
(1 row)
```

Disable new connections to testdb and kill all existing ones:
```
:load_db testdb \\ :disable_connections :kill_single_db_connections
You are now connected to database "postgres" as user "postgres".
Disabling connections for DB testdb
ALTER DATABASE
 pg_terminate_backend
---------------------
(3 rows)
```
