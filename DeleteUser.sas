*  Begin EG generated code (do not edit this line); 
* 
*  Stored process registered by 
*  Enterprise Guide Stored Process Manager V7.1 
* 
*  ==================================================================== 
*  Stored process name: DeleteUser 
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
proc printto log="/repository/IAM_WEBSERVICES/DeleteUser.Log" new; run;*/
 
%global RequestID USER_ID; 
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

 

 
*  End EG generated code (do not edit this line); 
 
 %global RequestID User_Id Status ResponseCode ResponseMessage ;

/*%let RequestID=ABCDEF;*/
/*%let User_Id=IAM_USER34;*/

%put RequestID=[&RequestID];
%put User_Id=[&User_Id];

%LET soapXMLFile = /repository/IAM_WEBSERVICES/User_Management/Update/USER_DEL_RES.xml;
%LET outxml_for_blk =/repository/IAM_WEBSERVICES/User_Management/Update/USER_DEL_RES.xml; 
%macro DeleteUser;

%macro audit;
proc sql;
insert into IAM.IAM_USER_MANAGEMENT_AUDIT values("&RequestID","Delete User","&User_ID","","&dt"dt,"&Status","&ResponseCode","&ResponseMessage","N",.,"");
quit;
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


libname savehere "/repository/IAM_WEBSERVICES/User_Management/";
libname current "/repository/IAM_WEBSERVICES/User_Management/Current/";

%MDUEXTR (LIBREF=current);
data deleteuser;
	set current.person(where=(strip(name)=strip("&user_id")));
	call symputx("ID",objid);
run;

%put &ID;

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


data _null_;
   	file "&soapXMLFile";
   	put '<?xml version="1.0" encoding="UTF-8"?>';
	put '<DeleteMetadata>';
 	put '<Metadata>';
    put "<Person  Id=""&ID"" TemplateName=""myassns""/>";
   	put '</Metadata>';  
   	put '<Reposid>$METAREPOSITORY</Reposid>';  
   	put '<NS>SAS</NS>';  
   	put '<Flags>268435456</Flags>';  
   	put '<Options>';  
    put '</Options>';
   	put '</DeleteMetadata>'; 
run;

filename _respons "&soapXMLFile" lrecl=1024 ;
filename _outxml "&outxml_for_blk" lrecl=1024 ;

proc metadata in=_outxml out=_respons header=FULL; run;
	

data _null_;
call symput('RequestID',"&RequestID");
call symput('Status','Success');
call symput('ResponseCode',"0");
call symput('ResponseMessage',catx(" ","&User_ID",'deleted Successfully'));
run;
%audit;

%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%exit: %mend DeleteUser;
%DeleteUser; 
 
*  Begin EG generated code (do not edit this line); 
;*';*";*/;quit; 

 
*  End EG generated code (do not edit this line);