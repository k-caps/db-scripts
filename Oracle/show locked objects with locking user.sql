-- Run as sys
select b.owner, b.object_name, a.oracle_username,a.os_user_name
from v$locked_object a,all_objects b
where a.object_id=b.object_id;
