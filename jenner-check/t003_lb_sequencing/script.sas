/* LB domain derivation from lb.sas (SDTM-Mapping-and-Clinical-Data-Standardization).
   lb.sas reads raw_lb.csv and raw_dm.csv from local disk (and re-reads raw_lb into
   raw_lb_raw a second time -- kept here as the author wrote it); those reads are replaced
   by inline DATA steps building the same tables in the layouts lb.sas declares, with
   ALT/AST values consistent with the study lab data and both an Excel-serial and a
   character date so both date branches are exercised. The Excel-serial-vs-character date
   handling, LBSTRESC/LBSTRESN standardisation, the DM merge, LBDY derivation, and LBSEQ
   sequencing via BY/FIRST. + RETAIN are the author's logic, unchanged. Self-contained:
   no external files are read. */

data work.raw_lb_raw;
    length
        SubjectID_char $10
        LBTESTCD       $8
        LBTEST         $40
        LBORRES        $40
        LBORRESU       $20
        LBDATE_char    $30
        VISIT          $40
        VISITNUM       8
    ;
    infile datalines dsd dlm=',' truncover;
    input
        SubjectID_char
        LBTESTCD
        LBTEST
        LBORRES
        LBORRESU
        LBDATE_char
        VISIT
        VISITNUM
    ;
    datalines;
1,ALT,Alanine Aminotransferase,35,U/L,45301,Baseline,1
1,ALT,Alanine Aminotransferase,78,U/L,45315,Week 2,2
2,AST,Aspartate Aminotransferase,22,U/L,45303,Baseline,1
3,ALT,Alanine Aminotransferase,High,,45320,Week 4,4
5,AST,Aspartate Aminotransferase,Low,U/L,45312,Week 3,3
;
run;

data work.raw_lb_raw;
    length
        SubjectID_char $10
        LBTESTCD       $8
        LBTEST         $40
        LBORRES        $40
        LBORRESU       $20
        LBDATE_char    $30
        VISIT          $40
        VISITNUM       8
    ;
    infile datalines dsd dlm=',' truncover;
    input
        SubjectID_char
        LBTESTCD
        LBTEST
        LBORRES
        LBORRESU
        LBDATE_char
        VISIT
        VISITNUM
    ;
    datalines;
1,ALT,Alanine Aminotransferase,35,U/L,45301,Baseline,1
1,ALT,Alanine Aminotransferase,78,U/L,45315,Week 2,2
2,AST,Aspartate Aminotransferase,22,U/L,45303,Baseline,1
3,ALT,Alanine Aminotransferase,High,,45320,Week 4,4
5,AST,Aspartate Aminotransferase,Low,U/L,45312,Week 3,3
;
run;
data work.raw_lb;
    set work.raw_lb_raw;

    length
        SUBJID     $3
        LBDTN      8
        LBDTC      $10
        LBSTRESC  $40
        LBSTRESN   8
    ;

    format LBDTN yymmdd10.;

    /* Subject key */
    SUBJID = strip(put(input(SubjectID_char, best.), z3.));

    /* Date handling: Excel serial vs character */
    if not missing(LBDATE_char) then do;
        if notdigit(strip(LBDATE_char)) = 0 then
            LBDTN = '30DEC1899'd + input(strip(LBDATE_char), best.);
        else
            LBDTN = input(strip(LBDATE_char), anydtdte.);
    end;

    if not missing(LBDTN) then LBDTC = put(LBDTN, yymmdd10.);
    else LBDTC = "";

    /* Standard results */
    LBSTRESC = strip(LBORRES);

    if not missing(LBORRES) then do;
        if notdigit(compress(strip(LBORRES),'.-')) = 0 then
            LBSTRESN = input(strip(LBORRES), best.);
        else
            LBSTRESN = .;
    end;
    else LBSTRESN = .;

    drop SubjectID_char LBDATE_char;
run;

proc sort data=work.raw_lb;
    by SUBJID;
run;
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

data work.lb_pre;
    merge work.raw_lb(in=a)
          work.dm_ref(in=b);
    by SUBJID;

    if a and b;

    length
        STUDYID  $20
        DOMAIN   $2
    ;

    STUDYID = "ABC123";
    DOMAIN  = "LB";
run;
data work.lb_pre;
    set work.lb_pre;

    length LBDY 8;

    if not missing(LBDTC) and not missing(RFSTDTC) then
        LBDY = input(LBDTC, yymmdd10.)
             - input(RFSTDTC, yymmdd10.)
             + 1;
    else
        LBDY = .;
run;
proc sort data=work.lb_pre;
    by USUBJID LBDTN LBTESTCD;
run;

data work.lb_pre;
    set work.lb_pre;
    by USUBJID;

    if first.USUBJID then LBSEQ = 1;
    else LBSEQ + 1;
run;
data work.lb_v1;
    retain
        STUDYID DOMAIN USUBJID LBSEQ
        LBTESTCD LBTEST
        LBORRES LBORRESU
        LBSTRESC LBSTRESN
        LBDTC LBDY
        VISIT VISITNUM
    ;

    set work.lb_pre;

    keep
        STUDYID DOMAIN USUBJID LBSEQ
        LBTESTCD LBTEST
        LBORRES LBORRESU
        LBSTRESC LBSTRESN
        LBDTC LBDY
        VISIT VISITNUM
    ;
run;
proc contents data=work.lb_v1 varnum;
run;

proc print data=work.lb_v1;
run;
