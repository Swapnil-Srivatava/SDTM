libname sdtm "C:\Users\swaps\OneDrive\Desktop\Portfolio\Mini Study\Sdtm";
run;
libname raw "C:\Users\swaps\OneDrive\Desktop\Portfolio\Mini Study";
run;

proc import datafile= "C:\Users\swaps\OneDrive\Desktop\Portfolio\Mini Study\raw_dm.xlsx"
    out=raw_dm
    dbms=xlsx
    replace;
    getnames=yes;
run;

data sdtm.dm;
set raw_dm;
length
        STUDYID  $20
        DOMAIN   $2
        USUBJID  $40
        SUBJID   $10
        SEX      $1
        RFSTDTC  $10
        RFENDTC  $10;

   
    
    STUDYID = "ABC123";
    DOMAIN  = "DM";

if vtype(Subject_Id) = "N" then do;
SUBJID = strip(put(Subject_Id, z3.));
end;
else do;
SUBJID = strip(Subject_Id);
end;

USUBJID = catx("-", STUDYID, SUBJID);
   
    
    select (upcase(strip(Sex)));
        when ("F", "FEMALE") SEX = "F";
        when ("M", "MALE")   SEX = "M";
        otherwise            SEX = "";
    end;

    
    AGE = AgeYears;



if vtype(First_Dose_Date) = "N" then do;
    if not missing(First_Dose_Date) then RFSTDTC = put(First_Dose_Date, yymmdd10.);
    else RFSTDTC = "";
end;
else do;
    
    if not missing(First_Dose_Date) and strip(First_Dose_Date) ne "." then
        RFSTDTC = put(input(strip(First_Dose_Date), anydtdte.), yymmdd10.);
    else RFSTDTC = "";
end;

/* Last_Dose_Date -> RFENDTC */
if vtype(Last_Dose_Date) = "N" then do;
    if not missing(Last_Dose_Date) then RFENDTC = put(Last_Dose_Date, yymmdd10.);
    else RFENDTC = "";
end;
else do;
    if not missing(Last_Dose_Date) and strip(Last_Dose_Date) ne "." then
        RFENDTC = put(input(strip(Last_Dose_Date), anydtdte.), yymmdd10.);
    else RFENDTC = "";
end;

keep
        STUDYID
        DOMAIN
        USUBJID
        SUBJID
        RFSTDTC
        RFENDTC
        SEX
        AGE
    ;
run;
proc sort data=sdtm.dm;
    by USUBJID;
run;
proc print data = sdtm.dm;
run;
proc export data=sdtm.dm
    outfile="C:\Users\swaps\OneDrive\Desktop\Portfolio\Mini Study\Sdtm\dm.csv"
    dbms=csv
    replace;
run;
