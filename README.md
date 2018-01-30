# utl_selecting_random_samples_of_half_the_size_of_groups_without_replacement_no_surveyselect
Selecting random samples of half the size of groups without replacement do surveyselect available. Keywords: sas sql join merge big data analytics macros oracle teradata mysql sas communities stackoverflow statistics artificial inteligence AI Python R Java Javascript WPS Matlab SPSS Scala Perl C C# Excel MS Access JSON graphics maps NLP natural language processing machine learning igraph DOSUBL DOW loop stackoverflow SAS community.
    Selecting random samples of half the size of groups without replacement do surveyselect available;

    https://goo.gl/B25Ki7
    https://github.com/rogerjdeangelis/utl_selecting_random_samples_of_half_the_size_of_groups_without_replacement_no_surveyselect

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
    
        Paul Dorfman <sashole@bellsouth.net>

    Roger,

    Tis' neat. OTOH, it's occurred to me that the first DoW can be coded just for
    counting the number of obs in the BY group, and the second -
    for sampling using the long in the tooth "K/N" method:

    data want (drop = K N) ;
      do N = 1 by 1 until (last.rev) ;
        set havsrtsrt ;
        by rev ;
      end ;
      K = ceil (N * 0.5) ;
      do _n_ = 1 to N ;
        set havsrtsrt ;
        if rand ('uniform') < divide (K,N) then do ;
          output ;
          K +- 1 ;
        end ;
        N +- 1 ;
      end ;
    run ;

    However, it's more interesting to ponder how the same can be done against a
    totally disordered file in the same two passes through it. Here a hash table
    once again looks like a perfect tool for the job. On the first pass,
    it collects the obs counts N for every group by REV and the corresponding
    K-values. On the second, the same "K/N" scheme as above is executed,
    except that the (K,N) hash values are adjusted on the fly as the logic dictates:

    data want (drop = K N) ;
      dcl hash h() ;
      h.defineKey  ("rev") ;
      h.defineData ("K", "N") ;
      h.defineDone () ;
      do until (z1) ;
        set have end = z1 ;
        if h.find() ne 0 then N = 1 ;
        else                  N + 1 ;
        K = ceil (N * 0.5) ;
        h.replace() ;
      end ;
      do until (z2) ;
        set have end = z2 ;
        h.find() ;
        if rand ('uniform') < divide (K,N) then do ;
          output ;
          K +- 1 ;
        end ;
        N +- 1 ;
        h.replace() ;
      end ;
      stop ;
    run ;



   Roger

     I remember that algorithm, keep track of where you are and add output at different probabilities until you have the exact 
    number you want.
