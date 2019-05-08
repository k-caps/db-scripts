Logic is as follows

ACTION > TRIGGER > PROCEDURE > PACKAGE

ACTION is a database action, such as INSERT
TRIGGER gets called by ACTION, and executes a PROCEDURE which calls the send_email procedure inside the PACKAGE

Example:

User signs up to a website, and receives an email notification.
What happens behind the scenes is:
USERS_TBL has all of a user's information. Columns are ID,username,password,email_address,app_name.
New row is added to USERS_TBL. 
A trigger called NOTIFY_NEW_USER_TRG fires AFTER INSERT.
The trigger sends the :new. values to the procedure called SEND_SIGNUP_MAIL.
SEND_SIGNUP_MAIL builds the url to send in the email body and sends everything to the package.
The package builds the html body of the email and sends it.

The reason there is a procedure just to build the url, is because this is an example. If we want to select 
from other tables as part of what we send in the email, we might get a mutating table ORA. The procedure
serves to avoid that.