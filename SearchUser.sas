*  Begin EG generated code (do not edit this line);
*
*  Stored process registered by
*  Enterprise Guide Stored Process Manager V8.2
*
*  ====================================================================
*  Stored process name: SearchUser
*  ====================================================================
*;


*ProcessBody;
*  End EG generated code (do not edit this line);


%global RequestID User_Id Status ResponseCode ResponseMessage ;

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
run;
/* Specify connection options. Use an unrestricted user ID. */
options metaserver="&MDserver."
metaport=8561       
metauser="&user_name."    
metapass="&user_password"   
metarepository="Foundation"
metaprotocol=BRIDGE;

LIBNAME IAM oracle path="Specify oracle database connection information" schema="Specify Schema name for IAM tables" user='Specify the Oracle Useename' password= "Specify the passwored associated with username";

%macro User_Search;

%macro audit;
proc sql;
insert into IAM.IAM_USER_MANAGEMENT_AUDIT values("&RequestID","Search User","&User_ID","","&dt"dt,"&Status","&ResponseCode","&ResponseMessage","N",.,"");
quit;
%mend audit;
%if %sysevalf(%superq(RequestID)=,boolean) %then %do;
data _null_;
Call symput('Status','Failed');
call symput('ResponseCode','1.1');
call symput('ResponseMessage',"Please enter RequetId");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


%if %sysevalf(%superq(User_Id)=,boolean) %then %do;
data _null_;
Call symput('Status','Failed');
call symput('ResponseCode',"1.2");
call symput('ResponseMessage',"Please enter UserId");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


libname current "/repository/IAM_WEBSERVICES/User_Management/Current/";
libname confdir "/repository/Config/";
%MDUEXTR (LIBREF=current);
data _null_;
 		set confdir.SERVERS_CONFIG;
		call symputx("metaserver",META_SERVER);
run;
%put webservice url = "&metaserver.";

data _NULL_;
UID=upcase("&user_id");
call symput('UID',UID);


run;
data groups_Person;
 set current.groupmempersons_info(keep= memname name where = (strip(upcase(memname)) contains "&UID."));
run;

proc sql noprint;
   select count(*)
   into :COUNT 
   from groups_Person ;
quit;

%put &count;

%if &COUNT eq 0 %then %do;
data _null_;
Call symput('RequestId',"&RequestId");
Call symput('Status','Rejected');
call symput('ResponseCode',"2.4");
call symput('ResponseMessage',"UserId does not exists");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;

proc sort data=groups_Person(Rename=(memName=USER_ID)) ;
by USER_ID;
run;

PROC TRANSPOSE DATA=WORK.groups_Person
	OUT=WORK.groups_Person_trans(drop=_name_ source)
	PREFIX=Group
	LABEL=Label
;
	BY USER_ID;
	VAR Name;
RUN; 


data _null_;
Call symput('RequestId',"&RequestId");
Call symput('Status','Success');
call symput('ResponseCode',"0");
call symput('ResponseMessage',catx('',"&User_Id",'Found'));
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];

%exit: %mend User_Search;
%User_Search;

*  Begin EG generated code (do not edit this line);
;*';*";*/;quit;

*  End EG generated code (do not edit this line);