/* DM domain derivation from dm.sas (SDTM-Mapping-and-Clinical-Data-Standardization).
   The RAW_DM step below stands in for dm.sas's PROC IMPORT of raw_dm.xlsx: the column
   names and types match what PROC IMPORT (VALIDVARNAME=V7) produces from the spreadsheet
   headers "Subject Id", "Treatment group", "Consent Date", "First Dose Date",
   "Last Dose Date" (spaces become underscores; date cells arrive as Excel serials), and
   the values are the study's actual raw rows. Everything below the RAW_DM step -- the
   SDTM DM mapping (STUDYID/DOMAIN/USUBJID/SEX/AGE/RFSTDTC/RFENDTC), PROC SORT, PROC PRINT
   and PROC EXPORT (path relativized) -- is the author's logic, unchanged. Self-contained:
   no external files are read, so it runs as-is against /v1/quick. */

data raw_dm;
    length Subject_Id 8 Sex $6 AgeYears 8 Treatment_group $20
           Consent_Date 8 First_Dose_Date 8 Last_Dose_Date 8;
    input Subject_Id Sex $ AgeYears Treatment_group $ Consent_Date First_Dose_Date Last_Dose_Date;
    datalines;
1 F 54 Drug_ABC 45296 45301 45356
2 M 61 Placebo 45474 45303 .
3 Female 48 Drug_ABC 45299 45306 45342
4 Male 40 Placebo 45292 45298 45371
5 F 45 Drug_ABC 45306 45307 45364
;
run;

data dm;
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
proc sort data=dm;
    by USUBJID;
run;
proc print data = dm;
run;
proc export data=dm
    outfile="dm.csv"
    dbms=csv
    replace;
run;
