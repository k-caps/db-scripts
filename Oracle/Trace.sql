-- Find the session to trace
select * from v$session
where USERNAME = 'ORA_USERNAME';

-- Start tracing
exec dbms_system.set_sql_trace_in_session(5885,46273,true);

-- Find the tracefile name
select instance||'_ora_'||ltrim(to_char(a.spid,'fm99999'))||'.trc',
'exec dbms_system.set_sql_trace_in_session('||b.sid||','||b.SERIAL#||',true);'
from v$process a , v$session b , v$thread c
where a.addr = b.paddr
and b.username = 'USER_NAME'
and b.machine='PC_NAME';

-- create human readable sql file from the trace (run from the directory containing the trc file)
-- The number
tkprof INSTANCE_NAME_ora_46056.trc INSTANCE_NAME_ora_46056.sql