-- Originall query to split:
update SCHEMA.TABLE
  set FIELD=VALUE
-- Optional  where FIELD != FIELD2


-- Version 1:
select 'update SCHEMA.TABLE
        set FIELD=VALUE
-- Optional        where FIELD != FIELD2
        and NUMERIC_FIELD between '''||min(rid)||''' and '''||max(rid)||''';
        commit;'
from
-- Split into how many
    (select NUMERIC_FIELD rid, ntile(1000) over (order by NUMERIC_FIELD) num
    from SCHEMA.TABLE
-- Same optional where clause    where FIELD != FIELD2)
group by num
order by num;

-- Version 2:
update SCHEMA.TABLE
  set FIELD=VALUE
-- Optional  where FIELD != FIELD2
-- Split into how many (mod(field to split by,how many to split to))
  and mod(NUMERIC_FIELD,3)=0;
-- Now paste the same update, so that you have as many queries as the number you mod by, (in this example 3)
-- with only the "=0" changing to "=1","=2".. up till the number you put in the mod.
update SCHEMA.TABLE
  set FIELD=VALUE
-- Optional  where FIELD != FIELD2
  and mod(NUMERIC_FIELD,3)=1;
update SCHEMA.TABLE
  set FIELD=VALUE
-- Optional  where FIELD != FIELD2
  and mod(NUMERIC_FIELD,3)=2;