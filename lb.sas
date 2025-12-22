filename rawlb "C:\Users\swaps\OneDrive\Desktop\Portfolio\Mini Study\raw_lb.csv";
filename rawdm "C:\Users\swaps\OneDrive\Desktop\Portfolio\Mini Study\Sdtm\raw_dm.csv";

data work.raw_lb_raw;
    infile rawlb
        dsd dlm=','
        firstobs=2
        truncover
        lrecl=32767;

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
run;
filename rawlb "C:\Users\swaps\OneDrive\Desktop\Portfolio\Mini Study\raw_lb.csv";

data work.raw_lb_raw;
    infile rawlb
        dsd dlm=','
        firstobs=2
        truncover
        lrecl=32767;

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
    infile rawdm
        dsd dlm=',' firstobs=2 truncover lrecl=32767;

    length
        SubjectID        $3
        Sex              $1
        AgeYears         8
        Treatment_group  $20
        Consent_Date     $20
        First_Dose_Date  $20
        Last_Dose_Date   $20
    ;

    input
        SubjectID
        Sex
        AgeYears
        Treatment_group
        Consent_Date
        First_Dose_Date
        Last_Dose_Date
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
