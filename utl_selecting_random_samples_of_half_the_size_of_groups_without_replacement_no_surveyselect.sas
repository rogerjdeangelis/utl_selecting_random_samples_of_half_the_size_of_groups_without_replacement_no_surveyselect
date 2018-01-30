Selecting random samples of half the size of groups without replacement do surveyselect available;

WPS/SAS same results

Original topic: Printing a set of observations

see
https://goo.gl/A187zv
https://communities.sas.com/t5/General-SAS-Programming/Printing-a-set-of-observations/m-p/432250


INPUT
=====

 ALGORITHM

     1. Add a random uniform number.
     2. Sort by reviewer and id
     3. Use a DOW loop to first count the number ids by a reviewer
     4. Divide the group count by two
     5. In the second DOW loop output first half of then observations by group


 WORK.HAVUNQ total obs=24            SORT BY REV SLICER ID
                                  |
   Obs    REV     ID     SLICER   |  REV     ID     SLICER
                                  |
     1    JANE     1    0.55033   |  JANE     5    0.05386   8 observations in 'JANE'
     2    JANE     2    0.13733   |  JANE     8    0.07626   output first 8/2=4 observations
     3    JANE     3    0.23566   |  JANE     2    0.13733
     4    JANE     4    0.71716   |  JANE     7    0.22044
     5    JANE     5    0.05386   |
     6    JANE     6    0.56701   |  JANE     3    0.23566   do not output these
     7    JANE     7    0.22044   |  JANE     1    0.55033
     8    JANE     8    0.07626   |  JANE     6    0.56701
                                  |  JANE     4    0.71716
     9    MARY     1    0.74064   |
    10    MARY     2    0.29755   |
    11    MARY     3    0.29519   |
    12    MARY     4    0.99592   |
    13    MARY     5    0.21051   |
    14    MARY     6    0.29567   |
    15    MARY     7    0.56619   |


PROCESS  (ALL THE CODE)
=======================

    proc sort data=havSrt out=havSrtSrt;
    by rev slicer id ;
    run;quit;

    data want(drop=cnt cntget slicer);
      retain cnt 0 cntget 0;
      do until (last.rev);
         set havSrtSrt;
         by rev;
         cnt=cnt+1;
      end;
      do until (last.rev);
         set havSrtSrt;
         by rev;
         cntGet=cntGet+1;
         if cntGet <= round(cnt/2) then output;
      end;
      cnt=0;
      cntget=0;
    run;quit;

OUTPUT
======

  WORK.WANT total obs=13

    Obs    REV     ID

      1    JANE     5   8/2=4
      2    JANE     8
      3    JANE     2
      4    JANE     7

      5    MARY     5  7/3 = 3.5 rounded up to 4
      6    MARY     3
      7    MARY     6
      8    MARY     2

      9    MIKE     7  9/2 = 4.5 rounded to 5
     10    MIKE     2
     11    MIKE     5
     12    MIKE     1
     13    MIKE     8

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
 call streaminit(1234);
 do rev="MARY","JANE","MIKE","MARY","JANE","MIKE";
     do id=1 to 10*rand("uniform");
        slicer=rand("uniform");
        output;
   end;
 end;
run;quit;

proc sort data=have out=havSrt nodupkey;
by rev id ;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('

libname wrk sas7bdat "%sysfunc(pathname(work))";
proc sort data=wrk.havSrt out=havSrtSrt;
by rev slicer id ;
run;quit;

data wrk.want(keep= rev id);
  retain cnt 0 cntget 0;
  do until (last.rev);
     set havSrtSrt;
     by rev;
     cnt=cnt+1;
  end;
  put cnt;
  do until (last.rev);
     set havSrtSrt;
     by rev;
     cntGet=cntGet+1;
     if cntGet <= round(cnt/2) then output;
  end;
  cnt=0;
  cntGet=0;
run;quit;

');

