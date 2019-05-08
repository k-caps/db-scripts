create or replace trigger SEND_SIGNUP_EMAIL_TRG
  after insert on USERS_TBL
  for each row 
  declare
  pragma autonomous_transaction;
    l_app_name varchar2(512);
    l_usrnm varchar2(100);
    l_user USERS_TBL%rowtype;
    --l_smtp_host varchar2(100):= apex_050100.wwv_flow_platform.get_preference('SMTP_HOST_ADDRESS');
    --l_smtp_port number := apex_050100.wwv_flow_platform.get_preference('SMTP_HOST_PORT');
  begin
	l_user.email := :new.email
    l_user.app_name := :new.app_name;
    l_user.username:= :new.username;    
    l_user.pwd := :new.password;
	
    send_signup_mail(l_user);    
    apex_mail.push_queue('MAIL-SRV.COM',25);
  
    /*dbms_scheduler.create_job(
    job_name => 'SEND_EMAIL_JOB',
    job_type => 'PLSQL_BLOCK',
    job_action => 'BEGIN 
                      send_signup_mail('||l_paramaters||','||l_im_to_lazy_to_type||');
                  END;',
   auto_drop => true,
   number_of_arguments => 0,
   enabled => true
  );*/
  --apex_mail.push_queue(l_smtp_host,l_smtp_port); 
  end;