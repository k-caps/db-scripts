create or replace procedure send_signup_mail(P_USERDATA USERS_TBL%rowtype) 
  as
    l_app_name varchar2(100) := p_userdata.app_name;;
    l_to varchar2(100) := p_userdata.email_address;;
    l_url clob;
    l_pwd varchar2(100) := p_userdata.password;
	l_username varchar2(100) := p_userdata.username;
  begin
	
  -- Example link to an apex  modal dialog (Fired by an item and REQUEST value)(app 109 page 2)
  l_url := 'https://server-name/DbApex/f?p=109:2::OPEN_MESSAGES:::P2_ID:'||P_REQUEST.ID; 
  
  -- Send to single target
  MAIL_NOTIFICATION.send_message(l_to,l_app_name,l_usrnm,l_pwd,l_url);
  
  -- Send to all subcriberes
  for i in (select email from new_user_subscribers where SUB_ID = P_USERDATA.ID) loop
    l_to := i.EMAIL;
    MAIL_NOTIFICATION.send_message(l_to,l_app_name,l_usrnm,l_pwd,l_url);
  end loop;
  
  -- Always send to DBAs
  MAIL_NOTIFICATION.send_message('adminsemail@website.com',l_app_name,l_usrnm,l_pwd,l_url);
  end send_message_mail;