*  Begin EG generated code (do not edit this line); 
* 
*  Stored process registered by 
*  Enterprise Guide Stored Process Manager V7.1 
* 
*  ==================================================================== 
*  Stored process name: DeleteGroup
*  ==================================================================== 
* 
*  Stored process prompt dictionary: 
*  ____________________________________ 
*  USER_ID 
*       Type: Text 
*      Label: User_Id 
*       Attr: Visible, Required 
*  ____________________________________ 
*; 
 
*ProcessBody; 
 
options MPRINT MLOGIC SYMBOLGEN;
proc printto log="/repository/IAM_WEBSERVICES/DeleteGroup.Log" new; run;
 
%global RequestID USER_ID Group; 
 
*  End EG generated code (do not edit this line); 
 
 %global RequestID User_Id Group Status ResponseCode ResponseMessage ;


%put RequestID=[&RequestID];
%put User_Id=[&User_Id];
%put Group=[&Group];

data _null_;
dt=put(datetime(),datetime20.);
call symput('dt',dt);
run;

%put &dt;
libname confdir "/repository/Config/";
data _null_;
 	set confdir.SERVERS_CONFIG;
	call symputx("user_name",META_USER);
	call symputx("user_password",META_PASSWORD);
	call symputx("metaserver",META_SERVER);
	call symputx("MDserver",MD_SERVER);
	call symputx("IAM_PATH",IAM_PATH);
    call symputx("IAM_USER",IAM_USER);
    call symputx("IAM_PASSWORD",IAM_PASSWORD);	
run;
/* Specify connection options. Use an unrestricted user ID. */
options metaserver="&MDserver."
metaport=8561       
metauser="&user_name."    
metapass="&user_password"   
metarepository="Foundation"
metaprotocol=BRIDGE;
LIBNAME IAM oracle path="Specify oracle database connection information" schema="Specify Schema name for IAM tables" user='Specify the Oracle Useename' password= "Specify the passwored associated with username";

filename DelGrp "/repository/IAM_WEBSERVICES/User_Management/Update/DelGrp.xml";
							 
/* Give the list of generic mail ID's */
%let recipients ='xxxxxxxx@gamil.com','yyyyyyyy@testad.com'; 

data _null_;
recipients=tranwrd("&recipients.","','",",");
call symputx("recipients1",recipients);
run;									  

%macro sent_to_user;

PROC SQL NOERRORSTOP;

connect to oracle (user=&IAM_USER  PASSWORD="&IAM_PASSWORD"
path=&IAM_PATH);
create table IAM_alerts_Temp1 as
select * from connection to Oracle
(select DISTINCT USERID,REQUEST_DATE,
case when SERVICE_TYPE='CreateUser-AddGroup' then 'Added to'
when SERVICE_TYPE='Delete Group' then 'Deleted from' end as Call_Type from
IAM_USER_MANAGEMENT_AUDIT
where STATUS='Success' and EMAIL_SENT_FLG = 'N'
and REGEXP_COUNT(GROUP_NAME,'Disabled Users')>0
and SERVICE_TYPE in ('Delete Group') );
disconnect from oracle;
quit;


proc sql noprint;
select count(*) into : cnt1_Iam from IAM_alerts_Temp1;
quit;
%let cnt1_Iam=&cnt1_Iam.;
%put &cnt1_Iam.;

%if &cnt1_Iam.>0 %then

%do;


proc sql noprint  ;
select (COUNT(USERID)) into : cnt_users from IAM_alerts_Temp1

 ;
quit;

%let cnt_users=&cnt_users.;
%put &cnt_users.;

proc sql noprint;
select  USERID,Request_Date, Call_Type into : USERID1 -: USERID&cnt_users., : Request_date1 -: Request_date&cnt_users.,
 : call_type1 -: call_type&cnt_users.

from IAM_alerts_Temp1

;
quit;

proc sql noprint;

select max(REQUEST_DATE) format DATETIME20.
into : MAX_start_date2 from IAM_alerts_Temp1;
quit;

%LET MAX_start_date2=&MAX_start_date2;



%let MAX_start_date1= %unquote(%str(%'&MAX_start_date2%'));



%put &MAX_start_date1;
%put &USERID1;
%PUT   &Request_date1;
%PUT   &call_type1;




options emailhost =("172.16.xx.xx");  /*Enter Email host IP*/

FILENAME MYFILE email to =(&recipients.)
SUBJECT="IAM User Disable Notification" 

TYPE= 'text/plain' ;

data _null_;
   file MYFILE;
   put "Dear Team";

put "Please find IAM User Disable Notification Details:";
 put " ";
	  put " ";
   %do i = 1 %to &cnt_users. ;
   put "User=&&userid&i.  &&call_type&i. Disabled Users Group at &&Request_date&i.";

%end;
run;


proc sql noprint;
connect to oracle (user=&IAM_USER  PASSWORD="&IAM_PASSWORD"
path=&IAM_PATH);
execute (

UPDATE IAM_USER_MANAGEMENT_AUDIT SET 
EMAIL_SENT_FLG = 'Y', 
EMAIL_SENT_DATE = sysdate , 

EMAIL_SENT_TO= &recipients1.



where STATUS='Success' and EMAIL_SENT_FLG = 'N'
and REGEXP_COUNT(GROUP_NAME,'Disabled Users')>0
and SERVICE_TYPE in ('Delete Group') AND


REQUEST_DATE <=(TO_DATE(&MAX_start_date1, 'dd/mm/yyyy hh24:mi:ss'))
)
by oracle;
disconnect from oracle;
quit;

%end;
%mend sent_to_user;		
%macro DeleteGroup;

%macro audit;
proc sql;
insert into IAM.IAM_USER_MANAGEMENT_AUDIT values("&RequestID","Delete Group","&User_ID","&Group","&dt"dt,"&Status","&ResponseCode","&ResponseMessage","N",.,"");
quit;
%sent_to_user;				   
%mend audit;

%if %sysevalf(%superq(RequestID)=,boolean) %then %do;
data _null_;
call symput('Status','Fail');
call symput('ResponseCode','1.1');
call symput('ResponseMessage',"Please Enter RequestID");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;

%if %sysevalf(%superq(User_Id)=,boolean) %then %do;
data _null_;
call symput('RequestId',"&RequestID");
call symput('Status','Fail');
call symput('ResponseCode','1.2');
call symput('ResponseMessage',"Please Enter UserID.");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;

%if %sysevalf(%superq(Group)=,boolean) %then %do;
data _null_;
call symput('RequestId',"&RequestID");
call symput('Status','Fail');
call symput('ResponseCode','1.3');
call symput('ResponseMessage',"Please Enter Group.");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


libname savehere "/repository/IAM_WEBSERVICES/User_Management/";
libname current "/repository/IAM_WEBSERVICES/User_Management/Current/";
libname confdir "/repository/Config/";
%MDUEXTR (LIBREF=current);
data user;
	set current.person(where=(strip(name)=strip("&user_id")));
	call symputx("ID",objid);
run;

data Group;
	set current.GROUP_INFO(where=(strip(name)=strip("&Group")));
	call symputx("GRPID",ID);
run;

%put &ID &GRPID;

%if %sysevalf(%superq(ID)=,boolean) %then %do;
data _null_;
call symput('RequestId',"&RequestID");
call symput('Status','Rejected');
call symput('ResponseCode','2.4');
call symput('ResponseMessage',"UserID does not exists.");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


%if %sysevalf(%superq(GRPID)=,boolean) %then %do;
data _null_;
call symput('RequestId',"&RequestID");
call symput('Status','Rejected');
call symput('ResponseCode','2.5');
call symput('ResponseMessage',"Group does not exists.");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;

data GROUPMEMPERSONS_INFO;
set current.GROUPMEMPERSONS_INFO;
where memId="&ID" and id="&GRPID";
call symputx("memId",memId);
run;

%if %sysevalf(%superq(memId)=,boolean) %then %do;
data _null_;
call symput('RequestId',"&RequestID");
call symput('Status','Rejected');
call symput('ResponseCode','2.6');
call symput('ResponseMessage',catx('',"&Group",'not assigned to User.'));
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


data _null_;
 	set confdir.SERVERS_CONFIG;
	call symputx("user_name",META_USER);
	call symputx("user_password",META_PASSWORD);
	call symputx("metaserver",META_SERVER);
	call symputx("MDserver",MD_SERVER);
run;

options metaserver="&MDserver."    /*specify metadataserver */ 
metaport=8561                           /* metadata server port */
metauser="&user_name."                  /* user id : e.g. SAS Administrator --> sasadm */
metapass="&user_password."              /* user password          */
metarepository="Foundation"
metaprotocol=BRIDGE;

	proc metadata IN=
	"<UpdateMetadata>
	<Metadata>
	<IdentityGroup Id=""&GRPID"">
	<MemberIdentities Function=""Remove"">
	<Person ObjRef=""&ID""/>
	</MemberIdentities>
	</IdentityGroup>
   	</Metadata>
   	<Reposid>$METAREPOSITORY</Reposid>
   	<NS>SAS</NS>
   	<Flags>268435456</Flags>
	<Options>
	</Options>
   	</UpdateMetadata>" 
	out=DelGrp;
run;


data _null_;
call symput('RequestID',"&RequestID");
call symput('Status','Success');
call symput('ResponseCode',"0");
call symput('ResponseMessage',catx(" ","&Group",'deleted Successfully'));
run;
%audit;

%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%exit: %mend DeleteGroup;
%DeleteGroup; 
 
*  Begin EG generated code (do not edit this line); 
;*';*";*/;quit; 

 
*  End EG generated code (do not edit this line);