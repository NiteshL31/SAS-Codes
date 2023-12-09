*  Begin EG generated code (do not edit this line); 
* 
*  Stored process registered by 
*  Enterprise Guide Stored Process Manager V7.1 
* 
*  ==================================================================== 
*  Stored process name: CreateUsers 
*  ==================================================================== 
* 
*  Stored process prompt dictionary: 
*  ____________________________________ 
*  AUTHDOAMIN 
*       Type: Text 
*      Label: AuthDoamin 
*       Attr: Visible, Required 
*  ____________________________________ 
*  DISPNAME 
*       Type: Text 
*      Label: Dispaly Name 
*       Attr: Visible 
*  ____________________________________ 
*  EMAIL 
*       Type: Text 
*      Label: Email 
*       Attr: Visible 
*  ____________________________________ 
*  EMAILTYPE 
*       Type: Text 
*      Label: Email Type 
*       Attr: Visible 
*  ____________________________________ 
*  GROUP1 
*       Type: Text 
*      Label: Group1 
*       Attr: Visible, Required 
*  ____________________________________ 
*  GROUP2 
*       Type: Text 
*      Label: Group2 
*       Attr: Visible 
*  ____________________________________ 
*  GROUP3 
*       Type: Text 
*      Label: Group3 
*       Attr: Visible 
*  ____________________________________ 
*  GROUP4 
*       Type: Text 
*      Label: Group4 
*       Attr: Visible 
*  ____________________________________ 
*  GROUP5 
*       Type: Text 
*      Label: Group5 
*       Attr: Visible 
*  ____________________________________ 
*  JOB 
*       Type: Text 
*      Label: Job Details 
*       Attr: Visible 
*  ____________________________________ 
*  REQUESTID 
*       Type: Text 
*      Label: RequestID 
*       Attr: Visible, Required 
*  ____________________________________ 
*  USER_ID 
*       Type: Text 
*      Label: User_Id 
*       Attr: Visible, Required 
*  ____________________________________ 
*; 
 
 
*ProcessBody; 
options mprint mlogic symbolgen;
options noserror;
/*options mprint mlogic symbolgen;*/
 
%global AUTHDOAMIN 
        DISPNAME 
        EMAIL 
        EMAILTYPE 
        GROUP1 
        GROUP2 
        GROUP3 
        GROUP4 
        GROUP5 
        JOB 
        REQUESTID 
        USER_ID; 
 
 
 
*  End EG generated code (do not edit this line); 
 
 
options mprint mlogic symbolgen;
proc printto log="/repository/IAM_WEBSERVICES/CreateUser.Log" new; run;
%global RequestID User_Id DispName Job AuthDoamin Email Emailtype Group1 Group2 Group3 Group4 Group5 ResponseCode ResponseMessage Status;

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

%put RequestID=[&RequestID];
%put User_Id=[&User_Id];
%put DispName=[&DispName];
%put Job=[&Job];
%put email=[&email];
%put EmailType=[&EmailType];
%put AuthDoamin=[&AuthDoamin];
%put Group1=[&Group1];
%put Group2=[&Group2];
%put Group3=[&Group3];
%put Group4=[&Group4];
%put Group5=[&Group5];
data _null_;
dt=put(datetime(),datetime20.);
call symput('dt',dt);
run;

%put &dt;


libname savehere "/repository/IAM_WEBSERVICES/User_Management/";
libname current "/repository/IAM_WEBSERVICES/User_Management/Current/";
libname confdir "/repository/Config/";
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
and SERVICE_TYPE in ('CreateUser-AddGroup') );
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




/*options emailhost =("172.16.2.23");*/

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
and SERVICE_TYPE in ('CreateUser-AddGroup') AND


REQUEST_DATE <=(TO_DATE(&MAX_start_date1, 'dd/mm/yyyy hh24:mi:ss'))
)
by oracle;
disconnect from oracle;
quit;

%end;
%mend sent_to_user;		

%Macro Field_Check;

%macro audit;
proc sql;
insert into IAM.IAM_USER_MANAGEMENT_AUDIT values("&RequestID","CreateUser-AddGroup","&User_ID","&grp_list","&dt"dt,"&Status","&ResponseCode","&ResponseMessage","N",.,"");
quit;
%sent_to_user;				   
%mend audit;

%if %sysevalf(%superq(RequestID)=,boolean) %then %do; 
data _null_;
Call symput('Status','Failed');
call symput('ResponseCode','1.1');
call symput('ResponseMessage',"Please Enter RequestID");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


%if %sysevalf(%superq(User_Id)=,boolean)  %then %do;
data _null_;
Call symput('Status','Failed');
call symput('ResponseCode','1.2');
call symput('ResponseMessage',"Please Enter User_Id");
run;
%audit;
%put  Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;

%if %sysevalf(%superq(GROUP1)=,boolean)  %then %do;
data _null_;
Call symput('Status','Failed');
call symput('ResponseCode','1.3');
call symput('ResponseMessage',"Please Enter atleast One Group");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;

data Groups_Exists ;
attrib Groups length= $256;
stop;
run;
%do i=1   %to 5;
data Groups_R_Exists;
attrib Groups length=$256;
Groups="&&Group&i";
run;
proc append base=Groups_Exists data=Groups_R_Exists force;
run;
%end; 
data Groups_Exists;
set Groups_Exists;
where Groups<> '';
run;

proc sql noprint;
select Groups into:grp_list separated by ',' from Groups_Exists;
quit;
 
  data savehere.IAM_users_create_list;*/
      attrib keyid length=$200 format=$200. informat=$200. label="Unique Key";
		attrib name length=$60 format=$60. informat=$60. label="Person Name";
		attrib description length=$200 format=$200. informat=$200. label="Description";
		attrib title length=$200 format=$200. informat=$200. label="Persons Title";
		attrib displayname length=$256 format=$256. informat=$256. label="Person DisplayName";
		attrib Groups length=$256 format=$256. informat=$256. label="Group Name";
		attrib Seq_no format=8.0 informat=8.0 label="Display Order";

      attrib keyid length=$200 format=$200. informat=$200. label="Identity Unique Key";
		attrib emailAddr length=$256 format=$256. informat=$256. label="Email Address";
		attrib emailType length=$32 format=$32. informat=$32. label="Type of Email Address";
		STOP;
	 run;


%macro addUser(User_Id,Job,Display_Name,email,emailType,Groups,seqno);
data _null_;
 		set confdir.SERVERS_CONFIG;
		call symputx("metaserver",META_SERVER);
run;
%put webservice url = "&metaserver.";
data savehere.IAM_adduser;
attrib keyid length=$200 format=$200. informat=$200. label="Unique Key";
attrib name length=$60 format=$60. informat=$60. label="Person Name";
attrib description length=$200 format=$200. informat=$200. label="Description";
attrib title length=$200 format=$200. informat=$200. label="Persons Title";
attrib displayname length=$256 format=$256. informat=$256. label="Person DisplayName";

attrib keyid length=$200 format=$200. informat=$200. label="Identity Unique Key";
attrib emailAddr length=$256 format=$256. informat=$256. label="Email Address";
attrib emailType length=$32 format=$32. informat=$32. label="Type of Email Address";
            
 keyid = "";
 name = "&User_Id.";
 description  = "&Job.";
 Title = "&Job.";
 displayname = "&Display_Name.";
 emailAddr = "&email.";
 emailType = "&emailType.";
/* User_ID = "&User_Id.";
 Display_Name = "&Display_Name.";
 Job_Description = "&Job.";*/
 Groups = "&Groups.";
 Seq_no = &seqno;
run;

/*%MDUEXTR (LIBREF=current);*/
data userExist;
 set current.person(keep=name);
 if strip(name) = strip("&User_Id.") then 
  do;
   call symput("UserExistFlag","Yes");
   stop;
  end; 
 else;
  do; 
   call symput("UserExistFlag","No");
  end;
run;
%put &UserExistFlag;
/****If the user exist then don't add to the approval list******/
%macro checkifuserexist;
%if &UserExistFlag = No %then
   %do;
   	proc append data=savehere.IAM_adduser base=savehere.IAM_users_create_list force; run;
      data _null_;
       call symput("putmeinhtml","User Added");
      run;
   %end;
%else
   %do;
      proc append data=savehere.IAM_adduser base=savehere.IAM_users_create_list force; run; 
     data _null_;
      call symput("putmeinhtml","User Already Exist and the new selected group will be added"); /****Put a message that user already exist in the html webout file**/
     run;
	
   %end;
%mend checkifuserexist;
%checkifuserexist;
%put &putmeinhtml;
%mend addUser;

%macro AddUpdateUser;

libname SAMPDAT '/repository/IAM_WEBSERVICES/User_Management/';
libname AUDIT '/repository/IAM_WEBSERVICES/User_Management/Change';
Proc sql;
select count(*) into :entries_count from SAMPDAT.IAM_users_create_list;
quit;

%do j=1 %to &entries_count;


proc sql noprint;
create table SAMPDAT.IAM_users_created_approved as
select *, upcase(name) as name_upcase from SAMPDAT.IAM_users_create_list
where seq_no = &j;
quit;

/*************************************************************************************************/
/***************************** Push the users and update the groups ******************************/ 
/*************************************************************************************************/

%LET soapXMLFile = /repository/IAM_WEBSERVICES/User_Management/Update/GRPMEM_REQ1.xml; 
%let outxml_for_blk = /repository/IAM_WEBSERVICES/User_Management/Update/GRPMEM_REQ1.xml;
%LET OwnerFile = /repository/IAM_WEBSERVICES/User_Management/Update/OWNER_REQ1.xml; 
%let outxml_for_Owner = /repository/IAM_WEBSERVICES/User_Management/Update/OWNER_REQ1.xml;

libname current "/repository/IAM_WEBSERVICES/User_Management/Current/";
libname temps "/repository/IAM_WEBSERVICES/User_Management/";

%MDUEXTR (LIBREF=current);
/*Check the names in the current metadata to the 'approved add to metadata' list*/
proc sort data=temps.IAM_users_created_approved out=IAM_users_created_approved; by name_upcase; run;
proc sql noprint;
create table current.person as
/*create table person1 as*/
select *, upcase(name) as name_upcase from current.person
;
quit;
proc sort data=current.person out=person_all; by name_upcase; run;
/*proc sort data=person1 out=person_all; by name_upcase; run;*/
data person
     current.person_upd;
 merge IAM_users_created_approved(in=a where=(name ne ""))    person_all(in=b);
 by name_upcase;
 if a and not b then output Person;
 if a and b then output current.person_upd;
run;

 	/*Create the authdomain table*/
data authdomain;
	attrib keyid length=$200 format=$200. informat=$200. label="Unique Key";
	attrib authDomName length=$60 format=$60. informat=$60. label="Authentication Domain Name";
/*	infile datalines delimiter=',' missover;*/
/*	input keyid authDomName;*/
/*cards;            */
/*DefaultAuth DefaultAuth*/
	STOP;
; 
run;

proc sql;
insert into authdomain values("&AuthDoamin","&AuthDoamin"); 
quit;
proc sql noprint;
   	select count(*)
   	into :COUNT_PERS 
   	from current.person_upd; 
quit; 
%macro CreatANDUpdateNewEntry;
%if &COUNT_PERS eq 0 %then  
%do;
	/****Create the email table****/
	data email(keep=keyid emailAddr emailType);
 		set person(keep=name emailAddr emailType);
 		keyid=name; 
	run;
	/****Create the person table*****/
	data person;
 		set person;
 		keyid=name;
 		*keyid = input(_n_,$200.);
	run;

	/***Create the Login table***/
	data logins(keep=keyid userid password authdomkeyid);
	attrib keyid length=$200 format=$200. informat=$200. label="Identity Unique Key";
	attrib userid length=$128 format=$128. informat=$128. label="User Id";
	attrib password length=$64 format=$64. informat=$64. label="Password";
	attrib authdomkeyid length=$200 format=$200. informat=$200. label="Authentication Domain Unique Key";
	set person;
	userid = strip(name)||"@BMOMAN";      
	authdomkeyid = "&AuthDoamin";
	keyid=name;
	*keyid =input(_n_,$200.);
	run;

	/* Initialize the macro variables that create canonical tables. */
	%mduimpc();
	/* Load the information from the person table to the metadata server. */
	%let _mduimplb_outrequest_=/repository/Config/;
	%let _mduimplb_outresponse_=/repository/Config/;
	%mduimplb();
	/* Now pull the person table again to get the keyids of the newly created users so as to use it for the grpmems **/
 	/*************Running only the group update part **************/
%MDUEXTR (LIBREF=current);
proc sql noprint;
create table current.person as
select *, upcase(name) as name_upcase from current.person
;
quit;
proc sort data=current.person out=person_all; by name_upcase; run;
/****Merge to the approved list **/
data personwith_keyid;
  merge person_all(in=a)
        IAM_users_created_approved(in=b where=(name ne ""));
  by name_upcase;
  if b;
  drop keyid;
  rename objid = memkeyid;
run;
/***Merge this with groups_info table to get the Goupids ***/
proc sort data=personwith_keyid; by groups; run;
proc sort data=current.group_info out=group_info(rename=(name = groups)); by name; run;
data with_keyid_groupid(keep=grpkeyid memkeyid);
 merge personwith_keyid(in=a)
       group_info(in=b);
 by groups;
 if a;
 rename id = grpkeyid;
run;

/***Now Create the request file for the group update***/
%macro createXML();
/*******Loop through the dataset *******/
/******** Header of the XML file ******/
data _null_;
   	file "&soapXMLFile";
   	put '<?xml version="1.0" encoding="UTF-8"?>';
	put '<UpdateMetadata>';
	put '<Metadata>';
run;

data _null_;
   	file "&OwnerFile";
   	put '<?xml version="1.0" encoding="UTF-8"?>';
	put '<AddMetadata>';
	put '<Metadata>';
run;
/* Count the no of observations in the dataset to create the loop ****/
proc sql noprint;
   select count(*)
   into :COUNT 
   from with_keyid_groupid; 
quit;
%let rowcount = &count;

/******************Loop through the datasets to create entry for each row in the dataset **********/
/***********Macro to create the xml entries *****/
%macro loopintable;

%do %while (&rowcount ne 0);
data _null_;    
	set with_keyid_groupid; 
	format cstring $10.; 
	if _n_ = &rowcount;
	call symputx("grpkeyid",grpkeyid);
	call symputx("memkeyid",memkeyid); 
	rowcount = sum(_n_,-1);
	call symput("rowcount",rowcount);
run;
data _null_;
    file "&soapXMLFile" mod;
	put "<IdentityGroup Id=""&grpkeyid"">";
    put "<MemberIdentities Function=""Append"">";
	put "<Person ObjRef=""&memkeyid""/>";
	put "</MemberIdentities>"; 
    put "</IdentityGroup>"; 
run;


data _null_;
    file "&OwnerFile" mod;
	put "<ResponsibleParty Name=""IAM"" Desc=""""  Role=""Created By"">";
   Put "<Objects>";
    put "<Person ObjRef=""&memkeyid""/>";
	put "</Objects>"; 
    put "</ResponsibleParty>"; 
    put "<ResponsibleParty Name=""IAM"" Desc=""""  Role=""Modified By"">";
	Put "<Objects>";
    put "<Person ObjRef=""&memkeyid""/>";
	put "</Objects>"; 
   put "</ResponsibleParty>"; 
run;


%end;
%MEND loopintable;
/***********Macro to create the xml entries ***ENDS**/
%loopintable;
/****** Footer of the XML file ******/
data _null_;
   file "&soapXMLFile" mod;
   put '</Metadata>';  
   put '<Reposid>>$METAREPOSITORY</Reposid>';  
   put '<NS>SAS</NS>';  
   put '<Flags>268435456</Flags>';  
   put '<Options/>';  
   put '</UpdateMetadata>'; 
run;

data _null_;
   file "&OwnerFile" mod;
   put '</Metadata>';  
   put '<Reposid>$METAREPOSITORY</Reposid>';  
   put '<NS>SAS</NS>';  
   put '<Flags>268435456</Flags>';  
   put '<Options/>';  
   put '</AddMetadata>'; 
run;

%MEND CreateXML;
%CreateXML();
/*************Running only the group update part ***************/
filename _respons "&soapXMLFile" lrecl=1024 ;
filename _outxml "&outxml_for_blk" lrecl=1024 ;


filename resp "&OwnerFile" lrecl=1024 ;
filename req "&outxml_for_Owner" lrecl=1024 ;

proc metadata in=_outxml out=_respons header=FULL; run;
proc metadata in=req out=resp header=FULL; run;

data users_to_be_created_for_audit(drop=keyid);
 format change_dttm datetime27.
				ACTION_TYPE $12.;
 set SAMPDAT.IAM_users_created_approved;
	  change_dttm = datetime();
	  ACTION_TYPE = "User Added";
	  ACTIONED_USER="&_metaperson";
run;	
 	/*************Running only the group update part ********ENDS*******/
	/*************************************************************************************************/
	/***************************** Push the users and update the groups ***********ENDS***************/ 
	/*************************************************************************************************/
%end;

%else /*************Running only the group update part for existing user***************/
%do;
	/* Now pull the person table again to get the keyids of the newly created users so as to use it for the grpmems **/
	*%MDUEXTR (LIBREF=current);
	proc sort data=current.person_upd; by name_upcase; run;
	/****Merge to the approved list **/
	data current.personwith_keyid;
  		merge current.person_upd(in=a)
        	  IAM_users_created_approved(in=b where=(name ne ""));
  	by name_upcase;
  	if b;
  	drop keyid;
  	rename objid = memkeyid;
	run;
	/***Merge this with groups_info table to get the Goupids ***/
	proc sort data=current.personwith_keyid; by groups; run;
	proc sort data=current.group_info out=group_info(rename=(name = groups)); by name; run;
	data current.with_keyid_groupid(keep=grpkeyid memkeyid);
 		merge current.personwith_keyid(in=a)
       			group_info(in=b);
 		by groups;
 		if a;
 		rename id = grpkeyid;
	run;
	/***Now Create the request file for the group update***/
	%macro createXML();
	/*******Loop through the dataset *******/
	/******** Header of the XML file ******/
	data _null_;
   	file "&soapXMLFile";
   	put '<?xml version="1.0" encoding="UTF-8"?>';
	put '<UpdateMetadata>';
	put '<Metadata>';
	run;

	/* Count the no of observations in the dataset to create the loop ****/
	proc sql noprint;
   	select count(*)
   	into :COUNT 
   	from current.with_keyid_groupid; 
	quit;
	%let rowcount = &count;

	/******************Loop through the datasets to create entry for each row in the dataset **********/
	/***********Macro to create the xml entries *****/
	%macro loopintable;

	%do %while (&rowcount ne 0);
	data _null_;    
	set current.with_keyid_groupid; 
	format cstring $10.; 
	if _n_ = &rowcount;
	call symputx("grpkeyid",grpkeyid);
	call symputx("memkeyid",memkeyid); 
	rowcount = sum(_n_,-1);
	call symput("rowcount",rowcount);
	run;
	data _null_;
    file "&soapXMLFile" mod;
	put "<IdentityGroup Id=""&grpkeyid"">";
    put "<MemberIdentities Function=""Append"">";
	put "<Person ObjRef=""&memkeyid""/>";
	put "</MemberIdentities>"; 
    put "</IdentityGroup>"; 
	run;



	%end;
	%MEND loopintable;
	/***********Macro to create the xml entries ***ENDS**/
	%loopintable;
	/****** Footer of the XML file ******/
	data _null_;
   	file "&soapXMLFile" mod;
   	put '</Metadata>';  
   	put '<Reposid>$METAREPOSITORY</Reposid>';  
   	put '<NS>SAS</NS>';  
   	put '<Flags>268435456</Flags>';  
   	put '<Options/>';  
   	put '</UpdateMetadata>'; 
	run;

	%MEND CreateXML;
	%CreateXML();
	/*************Running only the group update part ***************/
	filename _respons "&soapXMLFile" lrecl=1024 ;
	filename _outxml "&outxml_for_blk" lrecl=1024 ;



	proc metadata in=_outxml out=_respons header=FULL; run;

%end;
%mend CreatANDUpdateNewEntry;
%CreatANDUpdateNewEntry;
%end;
proc sql;
 	delete * from SAMPDAT.IAM_users_create_list ;
 	quit;
 run;

proc sql;
 delete * from SAMPDAT.IAM_users_created_approved;
quit;
run;


%mend AddUpdateUser;

%MDUEXTR (LIBREF=current);

%put "Into Existing Macro ";
data userExist;
 set current.person(keep=name);
 if strip(name) = strip("&User_Id.") then 
  do;
   call symput("UserExistFlag","Yes");
   stop;
  end; 
 else;
  do; 
   call symput("UserExistFlag","No");
  end;
run;
%if (&UserExistFlag= Yes)  %then %do;
data UserGroupExist;
set current.GROUPMEMPERSONS_INFO(Keep=Name memName);
where strip(memName) = strip("&User_Id.");
run;

%let nav_grp=Available;
proc sql noprint;
select  "'"||strip(Trim(Groups))||"'"  into: nav_grp separated by ' ' from Groups_Exists
where upcase(groups) not in(select distinct upcase(name)  from current.IDGRPS);
quit;
%put &nav_grp;
/*%let nav_grp=Available;*/
%if (&nav_grp ^= Available)  %then %do;
data _null_;
Call symput('Status','Rejected');
call symput('ResponseCode','2.1');
call symput('ResponseMessage',catx(" ",'Entered group',"&nav_grp",'does not exists'));
run;
%put %length(%cmpres(&nav_grp));
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;
%else %do ;

proc sql;
create table Existing_Grp as 
select Groups,ifc(Strip(a.Groups)=strip(b.name),'Y','N') as FLG 
from Groups_Exists a left join UserGroupExist b
on Strip(a.Groups)=strip(b.name)
;
quit;

data Grp_yes;
set Existing_Grp;
Sr_No=_n_;
where FLG='Y';
run;

data Grp_No;
set Existing_Grp;
Sr_No=_n_;
where FLG='N';
run;

Proc sql noprint;
select count(*) into: exist_grp_cnt from Grp_yes;
select count(*) into: nexist_grp_cnt from Grp_No;
quit;

%if (&exist_grp_cnt > 0 and &nexist_grp_cnt=0) %then %do;
data _null_;
Call symput('Status','Rejected');
call symput('ResponseCode','2.2');
call symput('ResponseMessage','User and Group already exists');
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end ;
%else %do;

%do K=1 %to &nexist_grp_cnt;
data _null_;
set Grp_No(where=(sr_no=&K));
call symput('GrpsAdd',Groups);
run;

%put &User_Id &GrpsAdd &K;
 %addUser(&User_Id,"","","","",&GrpsAdd,&K);
%end;
%AddUpdateUser;
proc sql noprint;
select  "'"||strip(Trim(Groups))||"'"  into: added_grp separated by ' ' from Grp_No;
quit;
data _null_;
Call symput('RequestID',"&RequestID");
Call symput('Status','Success');
call symput('ResponseCode',"0");
call symput('ResponseMessage',catx(" ","&added_grp",'Added Successfully.'));
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];

%goto exit;
%end;
%end;
%end;


%if %sysevalf(%superq(AuthDoamin)=,boolean)  %then %do;
data _null_;
Call symput('Status','Failed');
call symput('ResponseCode','1.4');
call symput('ResponseMessage',"Please Enter AuthDoamin");
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;

%end;


%put &UserExistFlag is here;
data AuthDomainExists;
   set  current.authdomain(keep=authDomName);
   if Upcase(strip(authDomName)) = Upcase(strip("&AuthDoamin.")) then 
  do;
   call symput("AuthDomFlag","Yes");
   stop;
  end; 
 else;
  do; 
   call symput("AuthDomFlag","No");
  end;
run;

%let nav_grp=Available;

proc sql noprint;
select  "'"||strip(Trim(Groups))||"'"  into: nav_grp separated by ' ' from Groups_Exists
where upcase(groups) not in(select distinct upcase(name)  from current.IDGRPS);
quit;

%put &nav_grp;


%if (&AuthDomFlag= No)  %then %do;
data _null_;
Call symput('Status','Rejected');
call symput('ResponseCode','2.3');
call symput('ResponseMessage',catx(" ",'Entered AuthDomain',"&AuthDoamin",'does not exists'));
run;
%audit;
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


%put &nav_grp Is here;
%if (&nav_grp ^= Available)  %then %do;
data _null_;
Call symput('Status','Rejected');
call symput('ResponseCode','2.1');
call symput('ResponseMessage',catx(" ",'Entered group',"&nav_grp",'does not exists'));
run;
%audit;
%put %length(%cmpres(&nav_grp));
%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];
%goto exit;
%end;


%else %do;

data User_Details;
Length Request_Id User_ID Display_Name JOB AuthDoamin EMAIL EMAIL_TYPE 
Group1  Group2 Group3 Group4 Group5 $250.;
Request_Id="&RequestId";
User_ID="&User_ID";
Display_Name="&DispName";
JOB="&Job";
AuthDoamin="&AuthDoamin";
EMAIL="&Email";
EMAIL_TYPE="&EmailType";
Group1="&Group1";
Group2="&Group2";
Group3="&Group3";
Group4="&Group4";
Group5="&Group5";
Missing_GRP=cmiss(of GROUP:);
run;
data _null_;
set User_Details;
call symput('missing_grp',Missing_GRP);
run;


proc contents data=User_Details out=grp(where=(NAME contains 'Group') Keep=Name);
run;

proc sql;
select Sum(count(*),-(&missing_grp*1)) into:Tot_Grp from grp;
quit;
%put &Tot_Grp; 

%do i=1 %to &Tot_Grp;
Proc sql;
select User_Id,Job,Display_Name,email,EMAIL_TYPE,Group&i into:
User_Id,:Job,:Display_Name,:email,:emailType,:Groups from User_Details;
quit;

%addUser(&User_Id,&Job,&Display_Name,&email,&emailType,&Groups,&i);
%end;


%AddUpdateUser;



data _null_;
%let syscc=0;
Call symput('RequestID',"&RequestID");
Call symput('Status','Success');
call symput('ResponseCode',"0");
call symput('ResponseMessage',catx(" ","&User_ID",'Added Successfully.'));
run;
%audit;
%let syscc=0;
%end;

%put RequestID=[&RequestID] Status=[&Status] ResponseCode=[&ResponseCode] and ResponseMessage=[&ResponseMessage];

%exit: %mend Field_Check;
%Field_Check; 
 
*  Begin EG generated code (do not edit this line); 
;*';*";*/;quit; 

 
*  End EG generated code (do not edit this line);