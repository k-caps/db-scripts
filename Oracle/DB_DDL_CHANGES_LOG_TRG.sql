-- In Superuser schema
create table SCHEMA_NAME.DB_DDL_CHANGES_LOG(ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
                      CLIENT_MACHINE VARCHAR2(4000),
                      OS_USER VARCHAR2(4000),
                      CURRENT_SCHEMA VARCHAR2(4000),
                      ACTION_TYPE VARCHAR2(4000),
                      CHANGED_OBJECT_TYPE VARCHAR2(4000),
                      CHANGED_OBJECT_NAME VARCHAR2(4000),
					  CHANGED_OBJECT_OWNER VARCHAR2(50),
                      ACTION_DATE DATE DEFAULT SYSDATE);
                      
create or replace TRIGGER DB_DDL_CHANGES_LOG_TRG
AFTER ALTER OR CREATE OR DROP OR RENAME ON DATABASE
declare 
  pragma autonomous_transaction;
  v_CLIENTMACHINE VARCHAR2(4000);
  v_OSUSER VARCHAR2(4000);
  v_CURRENTSCHEMA VARCHAR2(4000);
BEGIN 
  -- Get parameters into variables to insert into the DB_DDL_CHANGES_LOG table
  select sys_context ('USERENV', 'HOST') into v_CLIENTMACHINE from DUAL;
  select sys_context ('USERENV', 'OS_USER') into v_OSUSER from DUAL;
  
  insert into DB_DDL_CHANGES_LOG
    (CLIENT_MACHINE, OS_USER, ACTION_TYPE, CHANGED_OBJECT_TYPE, CHANGED_OBJECT_OWNER, CHANGED_OBJECT_NAME)
  values
    (v_CLIENTMACHINE, v_OSUSER, ora_sysevent, ora_dict_obj_type, ora_dict_obj_owner, ora_dict_obj_name);
  commit;
  exception
    when others then 
      null;
END;      
/

