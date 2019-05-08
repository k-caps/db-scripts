
create or replace PACKAGE MAIL_NOTIFICATION AS 

-- Have one HTML body (in the table MAIL_PARAMETERS) for each type of email
-- This example one has one type, that sends the application name, and user info. (For example for a newly registered user)
-- This type of email is called by a trigger after insert to some table (for example USERS) so when a new user is added to USERS, the trigger calls this package and sends that info.
-- These parameters get passed in, and the pl/sql logic inserts them into the html which is then sent as the email body.
  PROCEDURE send_info(to_user varchar2, application_name varchar2, user_name varchar2,
                           password varchar2, url varchar2);
                           
END MAIL_NOTIFICATION;
create or replace PACKAGE BODY MAIL_NOTIFICATION AS

  --Actually send the mail
  PROCEDURE send_mail(l_to_user varchar2, l_html_body clob, l_subject varchar2) AS
  BEGIN
    
    wwv_flow_api.SET_SECURITY_GROUP_ID(1690423370136630); -- apex workspace_id
    APEX_MAIL.SEND(
		P_TO => l_to_user,
		P_FROM=> 'admin@website.com',
		P_BODY=> l_html_body,
		P_BODY_HTML=> l_html_body,
		P_SUBJ=> l_subject
    );
    
  END;
  

  PROCEDURE send_info(to_user varchar2, application_name varchar2, user_name varchar2,
                           password varchar2, url varchar2) AS
    l_html_body clob;
    l_subject varchar2(1000) := 'Website Signup Notification';
  BEGIN
    
    select value 
    into l_html_body 
    from mail_parameters
    where name = 'SIGNUP_HTML_BODY';
    
    l_html_body := replace(
                    replace(
                      replace(
                        replace(l_html_body,'L_APPLICATION_PARAMETER',application_name),
                          'L_USERNAME_PARAMETER',user_name),
                        'L_PASSWORD_PARAMETER',password),
                      'L_URL_PARAMETER',url);
    
    send_mail(to_user, l_html_body, l_subject);
      
  END send_info;
END MAIL_NOTIFICATION;