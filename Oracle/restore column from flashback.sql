create table TABLE_NAME_FDA_RESCUE as
select * from SCHEMA.TABLE_NAME as of timestamp to_timestamp('18-02-2019 13:00:00', 'DD-MM-YYYY HH24:MI:SS');

update  SCHEMA.TABLE_NAME t1 set COLUMN_NAME = (select COLUMN_NAME from 
                                                        (select TABLE_NAME_PK_COLUMN,COLUMN_NAME from SCHEMA.TABLE_NAME_FDA_RESCUE) t2
                                                where t1.TABLE_NAME_PK_COLUMN=t2.TABLE_NAME_PK_COLUMN);
commit;                                                      