      SUBROUTINE EXIO        
C        
C     THE MAIN PURPOSE OF THIS MODULE IS TO COPY DATA BETWEEN THE       
C     RESIDENT SOF AND AN EXTERNAL TAPE OR DISK FILE.  AS AN EXTRA      
C     ADDED ATTRACTION, IT WILL ALSO APPEND AN EXTERNAL SOF (CREATED BY 
C     SOME OTHER NASTRAN RUNS) TO THE RESIDENT SOF AND COMPRESS THE     
C     RESIDENT SOF.        
C        
C     OPTIONS ARE -        
C        
C     (1) DUMP (RESTORE) THE ENTIRE SOF TO (FROM) AN EXTERNAL FILE.     
C         INTERNAL FORM ONLY.  THIS IS THE MOST EFFICIENT MEANS TO SAVE 
C         OR RECOVER A BACKUP COPY OF THE SOF, EXCEPT FOR SYSTEM UTILITY
C         PROGRAMS.        
C        
C     (2) COPY SELECTED ITEMS BETWEEN THE SOF AND AN EXTERNAL FILE.     
C        
C     (3) CHECK THE EXTERNAL FILE AND PRINT OUT A LIST OF ALL SUBSTRUC- 
C         TURES AND ITEMS ON IT ALONG WITH THE DATE AND TIME EACH WAS   
C         CREATED.        
C        
C     (4) APPEND AN EXTERNAL SOF TO THE RESIDENT SOF.        
C        
C     (5) COMPRESS THE RESIDENT SOF. (PLACE ALL ITEMS IN CONTIGUOUS     
C         BLOCKS ON THE SOF AND ELIMINATE ALL EMBEDDED FREE BLOCKS)     
C        
C     FEBRUARY 1974        
C        
      INTEGER         FORMAT,EXTE,BLANK,HEAD1,HEAD2,DRY,DEVICE,UNAME,   
     1                POS,BCDS(2,10),INBCDS(2,5)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / DRY,XMACH,DEVICE(2),UNAME(2),FORMAT(2),MODE(2),   
     1                POS(2),DATYPE(2),NAMES(10),PDATE,PTIME        
      COMMON /SYSTEM/ SYSBUF,NOUT        
      COMMON /OUTPUT/ HEAD1(96),HEAD2(96)        
      EQUIVALENCE     (INTE,BCDS(1,7)),(EXTE,BCDS(1,8)),        
     1                (DEVICE(1),INBCDS(1,1))        
      DATA    BLANK / 4H       /        
      DATA    BCDS  / 4HSOFI   ,4HN     ,        
     1                4HSOFO   ,4HUT    ,        
     2                4HREST   ,4HORE   ,        
     3                4HCHEC   ,4HK     ,        
     4                4HCOMP   ,4HRESS  ,        
     5                4HAPPE   ,4HND    ,        
     6                4HINTE   ,4HRNAL  ,        
     7                4HEXTE   ,4HRNAL  ,        
     8                4HREWI   ,4HND    ,        
     9                4HNORE   ,4HWIND  /        
C        
      DO 10 I = 1,96        
   10 HEAD2(I) = BLANK        
      DO 30 I = 1,5        
      DO 20 J = 1,10        
      IF (INBCDS(1,I) .NE. BCDS(1,J)) GO TO 20        
      INBCDS(2,I) = BCDS(2,J)        
      GO TO 30        
   20 CONTINUE        
   30 CONTINUE        
C        
      DO 40 I = 1,2        
      HEAD2(I   ) = MODE(I)        
      HEAD2(I+ 3) = FORMAT(I)        
      HEAD2(I+ 6) = DEVICE(I)        
      HEAD2(I+ 9) = UNAME(I)        
      HEAD2(I+12) = POS(I)        
   40 CONTINUE        
C        
C     INTERNAL FORMAT - GINO I/O IS USED FOR DATA WHICH WILL BE READ OR 
C                       WAS WRITTEN ON THE SAME HARDWARE.        
C        
      IF (FORMAT(1) .EQ. INTE) CALL EXIO1        
C        
C     EXTERNAL FORMAT - FORTRAN I/O IS USED FOR DATA WHICH WILL BE READ 
C                       OR WAS WRITTEN ON A DIFFERENT MACHINE.        
C        
      IF (FORMAT(1) .EQ. EXTE) CALL EXIO2        
C        
C     CHECK VALIDITY OF FORMAT TO ASCERTAIN WHETHER EITHER EXIO1 OR     
C     EXIO2 WAS CALLED.        
C        
      IF (FORMAT(1).EQ.INTE .OR. FORMAT(1).EQ.EXTE) RETURN        
      WRITE  (NOUT,50) UWM,FORMAT        
   50 FORMAT (A25,' 6333, ',2A4,' IS AN INVALID FORMAT PARAMETER FOR ', 
     1        'MODULE EXIO.')        
      DRY = -2        
      RETURN        
      END        