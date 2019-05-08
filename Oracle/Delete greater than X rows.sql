-- 100 is how many rows will remain

delete from TABLE where ID in (select ID from
									(select rownum rid,ID from TABLE) 
								where rid >100);

-- post 12c
delete from TABLE where ID in 
	(select ID from TABLE
	offset 100 rows) ;

commit;