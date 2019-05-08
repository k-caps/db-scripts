-- Find all duplicate objectids
SELECT objectid
FROM schema.table
GROUP BY objectid
HAVING count(objectid) > 1)

-- Count them
SELECT count(*)
FROM (SELECT objectid
      FROM schema.table
      GROUP BY objectid
      HAVING count(objectid) > 1) a;
                  

-- Find one of every recurring objectid in only groups with duplicates
SELECT count(ctid)
FROM schema.table
WHERE ctid NOT IN (SELECT min(ctid)
                   FROM schema.table
                   GROUP BY objectid
                   HAVING count(objectid) > 1) a;
                                                                   
-- Delete all but one row of every dup                                                        
DELETE FROM schema.table
WHERE ctid NOT IN (SELECT min(ctid)
                   FROM schema.table
                   GROUP BY objectid) a;

                                                                   
-- Oracle uses rowid, Postgres uses ctid
-- One needs the "a" alias, don't remember which, so if it doesn't work just try without