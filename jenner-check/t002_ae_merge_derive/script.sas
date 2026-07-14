/* AE domain derivation from ae.sas (SDTM-Mapping-and-Clinical-Data-Standardization).
   ae.sas reads two raw CSVs (raw_dm.csv, raw_ae.csv) from local disk; here those two
   reads are replaced by inline DATA steps that build the same RAW_DM and RAW_AE_RAW
   tables from the study's raw values (mixed date formats preserved, incl. the DD/MM/YYYY
   row and the row with a missing end date). The DM reference build, AE term/date/severity/
   relationship/serious mapping, the two BY-merges, the AESTDY study-day derivation, the
   PROC SQL count, PROC PRINT and PROC CONTENTS are the author's logic, unchanged. PROC
   EXPORT path relativized. Self-contained: no external files are read. */

data work.raw_dm;
    length
        SubjectID        $3
        Sex              $1
        AgeYears         8
        Treatment_group  $20
        Consent_Date     $20
        First_Dose_Date  $20
        Last_Dose_Date   $20
    ;
    infile datalines dsd dlm=',' truncover;
    input
        SubjectID
        Sex
        AgeYears
        Treatment_group
        Consent_Date
        First_Dose_Date
        Last_Dose_Date
    ;
    datalines;
1,F,54,Drug ABC,2024-01-10,2024-01-15,2024-03-11
2,M,61,Placebo,2024-07-06,2024-01-17,
3,Female,48,Drug ABC,2024-01-13,2024-01-20,2024-02-26
4,Male,40,Placebo,2024-01-06,2024-01-12,2024-03-26
5,F,45,Drug ABC,2024-01-20,2024-01-21,2024-03-19
;
run;

data work.dm_ref;
    set work.raw_dm;

    length
        STUDYID  $20
        SUBJID   $3
        USUBJID  $40
        RFSTDTC  $10
    ;

    STUDYID = "ABC123";

    SUBJID  = strip(put(input(SubjectID, best.), z3.));
    USUBJID = catx("-", STUDYID, SUBJID);

    RFSTDTC = put(input(First_Dose_Date, anydtdte.), yymmdd10.);

    keep SUBJID USUBJID RFSTDTC;
run;

proc sort data=work.dm_ref;
    by SUBJID;
run;
data work.raw_ae_raw;
    length
        SubjectID              8
        EventDescription       $200
        StartDate_char         $20
        EndDate_char           $20
        Severity               $20
        RelationshipToDrug     $20
        ActionTaken            $30
        Serious                $10
    ;
    infile datalines dsd dlm=',' truncover;
    input
        SubjectID
        EventDescription
        StartDate_char
        EndDate_char
        Severity
        RelationshipToDrug
        ActionTaken
        Serious
    ;
    datalines;
1,Headache,2024-01-13,,Moderate,Possible,None,No
2,Nausea,18/01/2024,20/01/2024,Mild,Unrelated,None,No
3,Vomiting,2024-01-26,2024-01-26,Severe,Probable,Drug stopped,Yes
4,Dizziness,2024-01-15,2024-01-15,Mild,Related,None,No
5,Headache,2025-01-15,2024-01-28,Mild,Unrelated,Drug stopped,No
;
run;
data work.raw_ae;
    set work.raw_ae_raw;

    length SUBJID $3;
    format StartDate EndDate yymmdd10.;

    /* Subject ID */
    SUBJID = put(SubjectID, z3.);

    /* Start Date */
    if not missing(StartDate_char) then
        StartDate = input(StartDate_char, anydtdte.);

    /* End Date */
    if not missing(EndDate_char) then
        EndDate = input(EndDate_char, anydtdte.);
run;

proc sort data=work.raw_ae;
    by SUBJID;
run;

data work.ae_pre;
    merge work.raw_ae(in=a)
          work.dm_ref(in=b);
    by SUBJID;

    if a and b;

    length
        STUDYID  $20
        DOMAIN   $2
        AETERM   $200
        AESTDTC  $10
        AEENDTC  $10
        AESEV    $8
        AEREL    $12
        AESER    $1
    ;

    STUDYID = "ABC123";
    DOMAIN  = "AE";

    AETERM = strip(EventDescription);

    if not missing(StartDate) then AESTDTC = put(StartDate, yymmdd10.);
    else AESTDTC = "";

    if not missing(EndDate) then AEENDTC = put(EndDate, yymmdd10.);
    else AEENDTC = "";

    select (upcase(strip(Severity)));
        when ("MILD")     AESEV = "MILD";
        when ("MODERATE") AESEV = "MODERATE";
        when ("SEVERE")   AESEV = "SEVERE";
        otherwise         AESEV = "";
    end;

    select (upcase(strip(RelationshipToDrug)));
        when ("RELATED")    AEREL = "RELATED";
        when ("POSSIBLE")   AEREL = "POSSIBLE";
        when ("PROBABLE")   AEREL = "PROBABLE";
        when ("UNRELATED")  AEREL = "UNRELATED";
        otherwise           AEREL = "";
    end;

    select (upcase(strip(Serious)));
        when ("YES", "Y") AESER = "Y";
        when ("NO", "N", "NON") AESER = "N";
        otherwise AESER = "";
    end;
run;

proc print data=work.ae_pre;
run;
proc sort data=work.raw_ae;  by SUBJID; run;
proc sort data=work.dm_ref;  by SUBJID; run;

data work.ae_v1;
    merge work.raw_ae(in=a)
          work.dm_ref(in=b);
    by SUBJID;

    if a and b;

    length
        STUDYID  $20
        DOMAIN   $2
        AETERM   $200
        AESTDTC  $10
        AEENDTC  $10
        AESEV    $8
        AEREL    $12
        AESER    $1
    ;

    STUDYID = "ABC123";
    DOMAIN  = "AE";

    /* ---- Term ---- */
    AETERM = strip(EventDescription);

    /* ---- ISO Dates ---- */
    if not missing(StartDate) then
        AESTDTC = put(StartDate, yymmdd10.);
    else
        AESTDTC = "";

    if not missing(EndDate) then
        AEENDTC = put(EndDate, yymmdd10.);
    else
        AEENDTC = "";

    /* ---- Severity ---- */
    select (upcase(strip(Severity)));
        when ("MILD")     AESEV = "MILD";
        when ("MODERATE") AESEV = "MODERATE";
        when ("SEVERE")   AESEV = "SEVERE";
        otherwise         AESEV = "";
    end;

    /* ---- Relationship ---- */
    select (upcase(strip(RelationshipToDrug)));
        when ("RELATED")    AEREL = "RELATED";
        when ("POSSIBLE")   AEREL = "POSSIBLE";
        when ("PROBABLE")   AEREL = "PROBABLE";
        when ("UNRELATED")  AEREL = "UNRELATED";
        otherwise           AEREL = "";
    end;

    /* ---- Serious ---- */
    select (upcase(strip(Serious)));
        when ("YES","Y") AESER = "Y";
        when ("NO","N")  AESER = "N";
        otherwise        AESER = "";
    end;
run;
data work.ae_v1;
    set work.ae_v1;

    length AESTDY 8;

    if not missing(AESTDTC) and not missing(RFSTDTC) then
        AESTDY = input(AESTDTC, yymmdd10.)
               - input(RFSTDTC, yymmdd10.)
               + 1;
    else
        AESTDY = .;
run;

proc sql;
    select count(*) as AE_N from work.ae_v1;
quit;

proc print data=work.ae_v1;
    var SUBJID RFSTDTC AESTDTC AESTDY AEENDTC;
run;
data ae;
    set work.ae_v1;

    keep
        STUDYID
        DOMAIN
        USUBJID
        AETERM
        AESTDTC
        AEENDTC
        AESTDY
        AESEV
        AEREL
        AESER
    ;
run;
proc export
    data=ae
    outfile="ae.csv"
    dbms=csv
    replace;
run;
proc contents data=ae position;
run;
