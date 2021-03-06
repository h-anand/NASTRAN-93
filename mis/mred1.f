      SUBROUTINE MRED1        
C        
C     THIS SUBROUTINE IS THE MRED1 MODULE WHICH INITIATES THE MODAL     
C     SYNTHESIS CALCULATIONS.        
C        
C     DMAP CALLING SEQUENCE        
C     MRED1    CASECC,GEOM4,DYNAMICS/USETX,EEDX,EQST,DMR/*NAMEA*/       
C              S,N,DRY/STEP/S,N,NOUS/S,N,SKIPM/S,N,GPARM/TYPE $        
C        
C     INPUT DATA        
C     GINO   - CASECC - CASE CONTROL        
C              GEOM4  - BDYC DATA        
C                     - BDYS DATA        
C                     - BDYS1 DATA        
C              DYNAMICS - EIGR DATA        
C     SOF    - EQSS   - SUBSTRUCTURE EQUIVALENCE TABLE        
C              BGSS   - BASIC GRID POINT IDENTIFICATION TABLE        
C              CSTM   - COORDINATE SYSTEM TRANSFORMATION MATRICES DATA  
C        
C     OUTPUT DATA        
C     GINO   - USETX  - S,R,B DEGREES OF FREEDOM        
C              EEDX   - EIGR DATA        
C              EQST   - TEMPORARY EQSS        
C              DMR    - RIGID BODY MATRIX        
C        
C     PARAMETERS        
C     INPUT  - NAMEA  - INPUT SUBSTRUCTURE NAME (BCD)        
C              DRY    - OPERATION MODE (INTEGER)        
C              STEP   - CONTROL DATA CASECC RECORD (INTEGER)        
C              TYPE   - REAL OR COMPLEX (BCD)        
C     OUTPUT - DRY    - MODULE OPERATION FLAG (INTEGER)        
C              NOUS   - FIXED POINTS FLAG (INTEGER)        
C                     = +1 IF FIXED POINTS DEFINED        
C                     = -1 IF NO FIXED POINTS DEFINED        
C              SKIPM  - MODES FLAG (INTEGER)        
C                     =  0 IF MODES NOT PRESENT        
C                     = -1 IF MODES PRESENT        
C     OTHERS - GBUF   - GINO BUFFERS        
C              SBUF   - SOF  BUFFERS        
C              KORLEN - CORE LENGTH        
C              NEWNAM - NEW SUBSTRUCTURE NAME        
C              BNDSET - BOUNDARY SET IDENTIFICATION NUMBER        
C              FIXSET - FIXED SET IDENTIFICATION NUMBER        
C              IEIG   - EIGENVALUE SET IDENTIFICATION NUMBER        
C              IO     - OUTPUT FLAGS        
C              RGRID  - FREEBODY MODES FLAGS        
C              RNAME  - FREEBODY SUBSTRUCTURE NAME        
C              IRSAVE - RSAVE FLAG        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              NCSUBS - NUMBER OF CONTRIBUTING SUBSTRUCTURES        
C              NAMEBS - BEGINNING ADDRESS OF CONTRIBUTING SUBSTRUCTURE  
C                       NAMES        
C              EQSIND - BEGINNING ADDRESS OF EQSS GROUP ADDRESSES       
C              NSLBGN - BEGINNING ADDRESS OF SIL DATA        
C              NSIL   - NUMBER OF SIL GROUPS        
C              BDYCS  - BEGINNING ADDRESS OF BDYC DATA        
C              NBDYCC - NUMBER OF BDYC DATA GROUPS        
C              USETL  - LENGTH OF USET ARRAY        
C              USTLOC - BEGINNING ADDRESS OF USET ARRAY        
C              RGRIDX - FREEBODY MODE RELATIVE X COORDINATE        
C              RGRIDY - FREEBODY MODE RELATIVE Y COORDINATE        
C              RGRIDZ - FREEBODY MODE RELATIVE Z COORDINATE        
C              USRMOD - USERMODE  OPTION FLAG        
C              BOUNDS - OLDBOUNDS OPTION FLAG        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT,ANDF,ORF        
      LOGICAL         USRMOD,BOUNDS,PONLY,ERRORS        
      REAL            RZ(1),RANGE(2),GPRM        
      DIMENSION       MODNAM(2),MTRLRA(7),MTRLRB(7),MTRLRC(7),MTRLRD(7),
     1                NMONIC(16),CCTYPE(2),MTRLRE(7),ITMNAM(2),        
     2                LSTBIT(32),ERRNAM(6),LETRS(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /BLANK / OLDNAM(2),DRY,STEP,NOUS,SKIPM,TYPE(2),GPRM,GBUF1, 
     1                GBUF2,SBUF1,SBUF2,SBUF3,KORLEN,NEWNAM(2),BNDSET,  
     2                FIXSET,IEIG,IO,RGRID(2),RNAME(2),IRSAVE,KORBGN,   
     3                NCSUBS,NAMEBS,EQSIND,NSLBGN,NSIL,BDYCS,NBDYCC,    
     4                USETL,USTLOC,RGRIDX,RGRIDY,RGRIDZ,USRMOD,BOUNDS,  
     5                PONLY        
CZZ   COMMON /ZZMRD1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,IPRNTR        
      EQUIVALENCE     (Z(1),RZ(1))        
      DATA    NMONIC/ 4HNAMB,4HBOUN,4HFIXE,4HMETH,4HCMET,4HOUTP,4HRGRI, 
     1                4HOLDM,4HOLDB,4HRSAV,4HRNAM,4HRANG,4HNMAX,4HUSER, 
     2                4HNAMA,4HGPAR/        
      DATA    CASECC/ 101          /        
      DATA    MODNAM/ 4HMRED,4H1   /        
      DATA    ERRNAM/ 4HLAMS,4HPHIS,4HPHIL,4HGIMS,4HLMTX,4HUPRT/        
      DATA    IBLANK, YES,NO,ALL   /4H    ,4HYES ,4HNO  ,4HALL /        
      DATA    LETRS / 1HM,1HC      /        
      DATA    CCTYPE/ -1,-2        /        
      DATA    CRED  , NHLODS,NHLOAP,NHEQSS /4HCRED,4HLODS,4HLOAP,4HEQSS/
C        
C     COMPUTE OPEN CORE AND DEFINE GINO, SOF BUFFERS        
C        
      NOZWDS = KORSZ(Z(1))        
      GBUF1  = NOZWDS- SYSBUF - 2        
      GBUF2  = GBUF1 - SYSBUF        
      SBUF1  = GBUF2 - SYSBUF        
      SBUF2  = SBUF1 - SYSBUF - 1        
      SBUF3  = SBUF2 - SYSBUF        
      KORLEN = SBUF3 - 1        
      KORBGN = 1        
      IF (KORLEN .LE. KORBGN) GO TO 430        
C        
C     INITIALIZE SOF        
C        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
C        
C     INITIALIZE CASE CONTROL PARAMETERS        
C        
      DO 10 I = 1, 2        
      RGRID(I) = -1        
      NEWNAM(I)= IBLANK        
   10 RNAME(I) = IBLANK        
      BNDSET = 0        
      FIXSET = 0        
      IEIG   = 0        
      NOIEIG = YES        
      IO     = 0        
      SKIPM  = 0        
      MODES  = NO        
      BOUNDS = .FALSE.        
      PONLY  = .FALSE.        
      IBOUND = NO        
      IRSAVE = NO        
      NOUS   = 1        
      IFREE  = NO        
      NMAX   = 2147483647        
      IMAX   = ALL        
      IMODE  = NO        
      USRMOD = .FALSE.        
      IUSERM = 1        
      MODULE = 1        
      GPRM   = 0.0        
      IBF    = 0        
      NRANGE = 0        
      IRANGE = ALL        
      RANGE(1) =-1.0E+35        
      RANGE(2) = 1.0E+35        
C        
C     PROCESS CASE CONTROL        
C        
      IFILE = CASECC        
      CALL OPEN (*400,CASECC,Z(GBUF2),0)        
      IF (STEP) 20,40,20        
   20 DO 30 I = 1,STEP        
   30 CALL FWDREC (*420,CASECC)        
C        
C     READ CASECC AND EXTRACT DATA        
C        
   40 CALL READ (*410,*420,CASECC,Z(KORBGN),2,0,NOREAD)        
      IF (Z(KORBGN) .EQ. CRED) MODULE = 2        
      NOWDSC = Z(KORBGN+1)        
      DO 190 I = 1,NOWDSC,3        
      CALL READ (*410,*420,CASECC,Z(KORBGN),3,0,NOREAD)        
C        
C     TEST CASE CONTROL MNEMONICS        
C        
      DO 50 J = 1,16        
      IF (Z(KORBGN) .EQ. NMONIC(J)) GO TO 60        
   50 CONTINUE        
      GO TO 190        
C        
C     SELECT DATA TO EXTRACT        
C        
   60 GO TO ( 70, 90,100,110,110,120,130,140,150,160,170,        
     1       102,115,125,132,155), J        
C        
C     EXTRACT NEW SUBSTRUCTURE NAME        
C        
   70 DO 80 K = 1,2        
   80 NEWNAM(K) = Z(KORBGN+K)        
      GO TO 190        
C        
C     EXTRACT BOUNDARY SET        
C        
   90 IF (Z(KORBGN+1) .NE. CCTYPE(1)) GO TO 185        
      BNDSET = Z(KORBGN+2)        
      IBF = IBF + 2        
      GO TO 190        
C        
C     EXTRACT FIXED SET        
C        
  100 IF (Z(KORBGN+1) .NE. CCTYPE(1)) GO TO 185        
      FIXSET = Z(KORBGN+2)        
      IBF = IBF + 1        
      GO TO 190        
C        
C     EXTRACT FREQUENCY RANGE        
C        
  102 IF (Z(KORBGN+1) .NE. CCTYPE(2)) GO TO 185        
      IRANGE = IBLANK        
      IF (NRANGE .EQ. 1) GO TO 104        
      NRANGE = 1        
      RANGE(1) = RZ(KORBGN+2)        
      GO TO 190        
  104 RANGE(2) = RZ(KORBGN+2)        
      GO TO 190        
C        
C     EXTRACT EIGENVALUE METHOD        
C        
  110 IF (Z(KORBGN+1) .NE. CCTYPE(1)) GO TO 185        
      IEIG = Z(KORBGN+2)        
      NOIEIG = NO        
      GO TO 190        
C        
C     EXTRACT MAXIMUM NUMBER OF FREQUENCIES        
C        
  115 IF (Z(KORBGN+1) .NE. CCTYPE(1)) GO TO 185        
      IF (Z(KORBGN+2) .EQ. 0) GO TO 190        
      NMAX = Z(KORBGN+2)        
      IMAX = IBLANK        
      GO TO 190        
C        
C     EXTRACT OUTPUT FLAGS        
C        
  120 IF (Z(KORBGN+1) .NE. CCTYPE(1)) GO TO 185        
      IO = ORF(IO,Z(KORBGN+2))        
      GO TO 190        
C        
C     EXTRACT USERMODE FLAG        
C        
  125 IF (Z(KORBGN+1) .NE. CCTYPE(1)) GO TO 185        
      IMODE  = YES        
      SKIPM  = -1        
      USRMOD = .TRUE.        
      IF (Z(KORBGN+2) .EQ. 2) IUSERM = 2        
      GO TO 190        
C        
C     EXTRACT RIGID BODY GRID POINT ID        
C        
 130  RGRID(1) = Z(KORBGN+2)        
      IF (Z(KORBGN+1) .NE. CCTYPE(1)) RGRID(1) = 0        
      IFREE = YES        
      GO TO 190        
C        
C     EXTRACT OLD SUBSTRUCTURE NAME        
C        
  132 DO 134 K = 1,2        
  134 OLDNAM(K) = Z(KORBGN+K)        
      GO TO 190        
C        
C     SET OLDMODES FLAG        
C        
  140 IF ((Z(KORBGN+1).EQ.CCTYPE(1)) .OR. (Z(KORBGN+1).EQ.CCTYPE(2)))   
     1   GO TO 185        
      IF (Z(KORBGN+1) .NE. YES) GO TO 190        
      SKIPM = -1        
      MODES = YES        
      GO TO 190        
C        
C     SET OLDBOUND FLAG        
C        
  150 IF ((Z(KORBGN+1).EQ.CCTYPE(1)) .OR. (Z(KORBGN+1).EQ.CCTYPE(2)))   
     1   GO TO 185        
      IF (Z(KORBGN+1) .NE. YES) GO TO 190        
      BOUNDS = .TRUE.        
      IBOUND = YES        
      GO TO 190        
C        
C     EXTRACT GPARAM PARAMETER        
C        
  155 IF (Z(KORBGN+1) .NE. CCTYPE(2)) GO TO 185        
      GPRM = RZ(KORBGN+2)        
      GO TO 190        
C        
C     SET RSAVE FLAG        
C        
  160 IF (Z(KORBGN+1) .EQ. NO) GO TO 190        
      IRSAVE = YES        
      GO TO 190        
C        
C     EXTRACT RIGID BODY SUBSTRUCTURE NAME        
C        
  170 DO 180 K = 1,2        
  180 RNAME(K) = Z(KORBGN+K)        
      IF (RGRID(1) .LT. 0) RGRID(1) = 0        
      IFREE = YES        
      GO TO 190        
C        
C     CASECC COMMAND ERROR        
C        
  185 WRITE (IPRNTR,916) UWM,LETRS(MODULE),NMONIC(J)        
  190 CONTINUE        
      CALL CLOSE (CASECC,1)        
C        
C     TEST MODULE OPERATION FLAG        
C        
      IF (DRY) 192,194,196        
  192 IF (DRY .EQ. -2) GO TO 198        
      WRITE (IPRNTR,909) UIM        
      DRY = -2        
      GO TO 198        
  194 SKIPM = -1        
      ITEST = 0        
      CALL FDSUB (NEWNAM,ITEST)        
      IF (ITEST .NE. -1) GO TO 510        
      WRITE (IPRNTR,922) UFM,LETRS(MODULE),NEWNAM        
      GO TO 500        
  196 ITEST = 0        
      CALL FDSUB (NEWNAM,ITEST)        
      IF (ITEST .EQ. -1) GO TO 198        
      IF (BOUNDS .OR. (SKIPM .EQ. -1)) GO TO 198        
      CALL SFETCH (NEWNAM,NHLODS,3,ITEST)        
      IF (ITEST .EQ. 3) GO TO 197        
      CALL SFETCH (NEWNAM,NHLOAP,3,ITEST)        
      IF (ITEST .EQ. 3) GO TO 197        
      ITMNAM(1) = NEWNAM(1)        
      ITMNAM(2) = NEWNAM(2)        
      GO TO 450        
C        
C     LOADS ONLY PROCESSING        
C        
  197 PONLY = .TRUE.        
C        
C     TEST OUTPUT OPTION        
C        
  198 IF (ANDF(IO,1) .EQ. 0) GO TO 200        
      CALL PAGE1        
      WRITE (IPRNTR,900) OLDNAM,NEWNAM        
      IF (IBF .EQ. 0) WRITE (IPRNTR,918)        
      IF (IBF .EQ. 1) WRITE (IPRNTR,919) FIXSET        
      IF (IBF .EQ. 2) WRITE (IPRNTR,920) BNDSET        
      IF (IBF .EQ. 3) WRITE (IPRNTR,921) BNDSET,FIXSET        
      IF (RGRID(1) .EQ. -1) WRITE (IPRNTR,906) RNAME        
      IF (RGRID(1) .NE. -1) WRITE (IPRNTR,907) RGRID(1),RNAME        
      IF (NOIEIG .EQ. NO) WRITE (IPRNTR,908) IBOUND,MODES,IFREE,IMODE,  
     1    IRSAVE,IEIG        
      IF (NOIEIG .NE. NO) WRITE (IPRNTR,908) IBOUND,MODES,IFREE,IMODE,  
     1    IRSAVE        
      IF (IMAX   .EQ. ALL) WRITE (IPRNTR,910) IMAX,GPRM        
      IF (IMAX   .NE. ALL) WRITE (IPRNTR,911) NMAX,GPRM        
      IF (IRANGE .EQ. ALL) WRITE (IPRNTR,912) OLDNAM,IRANGE        
      IF (IRANGE .NE. ALL) WRITE (IPRNTR,913) OLDNAM,RANGE(1)        
C        
C     CHECK FOR OLDMODES, OLDBOUND ERRORS        
C        
  200 ERRORS = .FALSE.        
      IF (PONLY) GO TO 290        
      CALL SFETCH (OLDNAM,ERRNAM(1),3,ITEST)        
      CALL SOFTRL (OLDNAM,ERRNAM(2),MTRLRA)        
      CALL SOFTRL (OLDNAM,ERRNAM(4),MTRLRB)        
      CALL SOFTRL (OLDNAM,ERRNAM(5),MTRLRC)        
      CALL SOFTRL (OLDNAM,ERRNAM(3),MTRLRD)        
      CALL SOFTRL (OLDNAM,ERRNAM(6),MTRLRE)        
      IFLAG = 1        
      IF (USRMOD) GO TO 290        
      IF (SKIPM) 210,230,230        
C        
C     OLDMODES SET - PHIS AND LAMS MUST BE ON SOF        
C        
  210 IF (ITEST .GT. 3) GO TO 360        
  220 IFLAG = 2        
      IF (MTRLRA(1) .GT. 2) GO TO 360        
      GO TO 260        
C        
C     OLDMODES NOT SET - PHIS, PHIL AND LAMS MUST BE DELETED        
C        
  230 IF (ITEST .LT. 3) GO TO 370        
  240 IFLAG = 2        
      IF (MTRLRA(1) .LT. 3) GO TO 370        
  250 IFLAG = 3        
      IF (MTRLRD(1) .LT. 3) GO TO 370        
C        
C     OLDBOUND SET - GIMS AND UPRT MUST BE ON SOF        
C        
  260 IFLAG = 4        
      IF (.NOT. BOUNDS) GO TO 270        
      IF (MTRLRB(1) .GT. 2) GO TO 380        
  265 IFLAG = 6        
      IF (MTRLRE(1) .GT. 2) GO TO 380        
      GO TO 290        
C        
C     OLDBOUND NOT SET - GIMS AND LMTX MUST BE DELETED        
C        
  270 IF (MTRLRB(1) .LT. 3) GO TO 390        
  280 IFLAG = 5        
      IF (MTRLRC(1) .LT. 3) GO TO 390        
C        
C     TEST FOR ERRORS        
C        
  290 IF (ERRORS) GO TO 500        
      IF (IUSERM .EQ. 2) WRITE (IPRNTR,917) UIM        
C        
C     READ EQSS GROUP 0 DATA AND TEST OPEN CORE LENGTH        
C        
      ITMNAM(2) = OLDNAM(2)        
      CALL SFETCH (OLDNAM,NHEQSS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 460        
      IF (ITEST .EQ. 4) GO TO 470        
      IF (ITEST .EQ. 5) GO TO 480        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      IF (KORBGN+NWDSRD .GE. SBUF3) GO TO 430        
C        
C     COMPRESS BASIC SUBSTRUCTURE NAMES AND TEST OPEN CORE LENGTH       
C        
      NCSUBS = Z(KORBGN+2)        
      NAMEBS = KORBGN        
      I = 2*((NWDSRD - 4)/2)        
      K = 4        
      DO 300 J = 1,I,2        
      Z(KORBGN+J-1) = Z(KORBGN+K  )        
      Z(KORBGN+J  ) = Z(KORBGN+K+1)        
      IF (RGRID(1) .LT. 0) GO TO 300        
      IF (RNAME(1) .NE. IBLANK) GO TO 298        
      RNAME(1) = Z(KORBGN+J-1)        
      RNAME(2) = Z(KORBGN+J  )        
  298 CONTINUE        
      IF ((Z(KORBGN+J-1).NE.RNAME(1)) .OR. (Z(KORBGN+J).NE.RNAME(2)))   
     1   GO TO 300        
      RGRID(2) = (J+1)/2        
  300 K = K + 2        
      EQSIND = KORBGN + 2*NCSUBS        
      IF (EQSIND .GE. SBUF3) GO TO 430        
C        
C     TEST OUTPUT OPTION        
C        
      IF (ANDF(IO,1) .EQ. 0) GO TO 310        
      IF (IRANGE  .NE.  ALL) GO TO 302        
      I = 2*NCSUBS        
      WRITE (IPRNTR,901) (Z(KORBGN+J-1),Z(KORBGN+J),J=1,I,2)        
      GO TO 310        
  302 IF (NCSUBS .GE. 5) GO TO 306        
      I = 1 + 2*NCSUBS        
      DO 304 J = I,10        
  304 Z(KORBGN+J-1) = IBLANK        
  306 K = 10        
      WRITE (IPRNTR,914) (Z(KORBGN+J-1),Z(KORBGN+J),J=1,K,2),RANGE(2)   
      IF (NCSUBS .LE. 5) GO TO 310        
      K = K + 1        
      I = 2*NCSUBS        
      WRITE (IPRNTR,901) (Z(KORBGN+J-1),Z(KORBGN+J),J=K,I,2)        
C        
C     READ EQSS GROUPS TO END-OF-ITEM        
C        
  310 KORBGN = EQSIND + 2*NCSUBS        
      DO 320 I = 1, NCSUBS        
      IF (KORBGN .GE. SBUF3) GO TO 430        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      J = 2*(I - 1)        
      Z(EQSIND+J  ) = KORBGN        
      Z(EQSIND+J+1) = NWDSRD        
  320 KORBGN = KORBGN + NWDSRD        
      NSLBGN = KORBGN        
      CALL SUREAD (Z(KORBGN),-2,NWDSRD,ITEST)        
      NSIL = NWDSRD/2        
C        
C     TEST OUTPUT OPTION        
C        
      IF (ANDF(RSHIFT(IO,3),1) .EQ. 0) GO TO 350        
      DO 330 I = 1,NCSUBS        
      J = 2*(I-1)        
      CALL CMIWRT (1,OLDNAM,Z(NAMEBS+J),Z(EQSIND+J),Z(EQSIND+J+1),RZ,Z) 
  330 CONTINUE        
      ISIL = 2*NSIL        
      CALL CMIWRT (8,OLDNAM,OLDNAM,NSLBGN,ISIL,RZ,Z)        
C        
C     DETERMINE USET LENGTH        
C        
  350 KORBGN = NSLBGN + NWDSRD        
      USTLOC = KORBGN        
      ICODE  = Z(KORBGN-2)        
      CALL DECODE (ICODE,LSTBIT,NWDSD)        
      USETL = (Z(KORBGN-3) + NWDSD) - 1        
C        
C     PROCESS FIXED SET        
C        
      CALL MRED1A (1)        
      CALL MRED1B (1)        
C        
C     PROCESS BOUNDARY SET        
C        
      CALL MRED1A (2)        
      CALL MRED1B (2)        
C        
C     CONVERT EQSS DATA TO UB DATA        
C        
      IF (PONLY) GO TO 510        
      CALL MRED1C        
C        
C     PROCESS EIGENVALUE DATA        
C        
      IF (SKIPM .EQ. -1) GO TO 355        
      CALL MRED1D        
C        
C     PROCESS FREE BODY MODES        
C        
  355 CALL MRED1E        
      GO TO 510        
C        
C     PHIS, LAMS DO NOT EXIST        
C        
  360 WRITE (IPRNTR,902) UFM,ERRNAM(IFLAG),OLDNAM        
      ERRORS = .TRUE.        
      GO TO (220,260), IFLAG        
C        
C     PHIS, PHIR, LAMS NOT DELETED        
C        
  370 WRITE (IPRNTR,903) UFM,ERRNAM(IFLAG),OLDNAM        
      ERRORS = .TRUE.        
      GO TO (240,250,260), IFLAG        
C        
C     GIMS, UPRT DOES NOT EXIST        
C        
  380 WRITE (IPRNTR,904) UFM,ERRNAM(IFLAG),OLDNAM        
      ERRORS = .TRUE.        
      IF (IFLAG - 5) 265,265,290        
C        
C     GIMS, LMTX NOT DELETED        
C        
  390 WRITE (IPRNTR,905) UFM,ERRNAM(IFLAG),OLDNAM        
      ERRORS = .TRUE.        
      IFLAG = IFLAG - 3        
      GO TO (280,290), IFLAG        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  400 IMSG = -1        
      GO TO 440        
  410 IMSG = -2        
      GO TO 440        
  420 IMSG = -3        
      GO TO 440        
  430 IMSG = -8        
      IFILE = 0        
  440 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  450 IMSG = -4        
      GO TO 490        
  460 IMSG = -1        
      GO TO 490        
  470 IMSG = -2        
      GO TO 490        
  480 IMSG = -3        
  490 CALL SMSG (IMSG,NHEQSS,ITMNAM)        
      RETURN        
C        
  500 CALL SOFCLS        
      DRY = -2        
      RETURN        
C        
C     CLOSE ANY OPEN FILES        
C        
  510 CALL SOFCLS        
      IF (DRY .EQ. -2) WRITE (IPRNTR,915) LETRS(MODULE)        
      IF (PONLY) SKIPM = -1        
      RETURN        
C        
  900 FORMAT (//38X,46HS U M M A R Y    O F    C U R R E N T    P R O,  
     1       8H B L E M,//13X,38HNAME OF PSEUDOSTRUCTURE TO BE REDUCED ,
     2       4(2H. ),2A4,6X,40HNAME GIVEN TO RESULTANT PSEUDOSTRUCTURE ,
     3       2A4)        
  901 FORMAT (16X,2A4,2X,2A4,2X,2A4,2X,2A4,2X,2A4)        
  902 FORMAT (A23,' 6617, OLDMODES SET AND REQUESTED SOF ITEM DOES NOT',
     1       ' EXIST.  ITEM ',A4,', SUBSTRUCTURE ',2A4,1H.)        
  903 FORMAT (A23,' 6618, OLDMODES NOT SET AND REQUESTED SOF ITEM MUST',
     1       ' BE DELETED.  ITEM ',A4,', SUBSTRUCTURE ',2A4,1H.)        
  904 FORMAT (A23,' 6619, OLDBOUND SET AND REQUESTED SOF ITEM DOES NOT',
     1       ' EXIST.  ITEM ',A4,', SUBSTRUCTURE ',2A4,1H.)        
  905 FORMAT (A23,' 6620, OLDBOUND NOT SET AND REQUESTED SOF ITEM MUST',
     1       ' BE DELETED.  ITEM ',A4,', SUBSTRUCTURE ',2A4,1H.)        
  906 FORMAT (13X,'RIGID BODY GRID POINT IDENTIFICATION NUMBER .',14X,  
     1       'RIGID BODY SUBSTRUCTURE NAME ',5(2H. ),2A4)        
  907 FORMAT (13X,46HRIGID BODY GRID POINT IDENTIFICATION NUMBER . ,I8, 
     1       6X,30HRIGID BODY SUBSTRUCTURE NAME  ,5(2H. ),2A4)        
  908 FORMAT (13X,18HOLDBOUND FLAG SET ,14(2H. ),A4,10X,12HOLDMODES FLA,
     1       6HG SET ,11(2H. ),A4,/13X,29HFREE BODY MODES TO BE CALCULA,
     2       5HTED  ,6(2H. ),A4,10X,20HUSER MODES FLAG SET ,10(2H. ),A4,
     3       /13X,24HSAVE REDUCTION PRODUCTS ,11(2H. ),A4,10X,7HEIGENVA,
     4       23HLUE EXTRACTION METHOD  ,5(2H. ),I8)        
  909 FORMAT (A29,' 6630, FOR DRY OPTION IN MODAL REDUCE, INPUT DATA ', 
     1       'WILL BE CHECKED', /36X,'BUT NO SOF TABLE ITEMS WILL BE ', 
     2       'CREATED.')        
  910 FORMAT (13X,42HMAXIMUM NUMBER OF FREQUENCIES TO BE USED  ,2(2H. ),
     1       A4,10X,14HGPARAM VALUE  ,13(2H. ),1P,E12.6)        
  911 FORMAT (13X,42HMAXIMUM NUMBER OF FREQUENCIES TO BE USED  ,2(2H. ),
     1       I8,6X,14HGPARAM VALUE  ,13(2H. ),1P,E12.6)        
  912 FORMAT (13X,46HNAMES OF COMPONENT SUBSTRUCTURES CONTAINED IN ,2A4,
     1       6X,32HRANGE OF FREQUENCIES TO BE USED ,4(2H. ),A4)        
  913 FORMAT (13X,46HNAMES OF COMPONENT SUBSTRUCTURES CONTAINED IN ,2A4,
     1       6X,32HRANGE OF FREQUENCIES TO BE USED ,4(2H. ),1P,E12.6)   
  914 FORMAT (16X,5(2A4,2X),47X,1P,E12.6)        
  915 FORMAT (10H0  MODULE ,A1,36HREDUCE TERMINATING DUE TO ABOVE ERRO, 
     1       3HRS.)        
  916 FORMAT (A25,' 6367, ILLEGAL FORMAT ON THE ',A1,'REDUCE OUTPUT ',  
     1       'COMMAND ',A4,'.  COMMAND IGNORED.')        
  917 FORMAT (A29,' 6636, NMAX AND RANGE SUB COMMANDS ARE IGNORED ',    
     1       'UNDER USERMODES = TYPE 2.')        
  918 FORMAT (13X,36HBOUNDARY SET IDENTIFICATION NUMBER  ,5(2H. ),14X,  
     1       32HFIXED SET IDENTIFICATION NUMBER ,4(2H. ))        
  919 FORMAT (13X,36HBOUNDARY SET IDENTIFICATION NUMBER  ,5(2H. ),14X,  
     1       32HFIXED SET IDENTIFICATION NUMBER ,4(2H. ),I8)        
  920 FORMAT (13X,36HBOUNDARY SET IDENTIFICATION NUMBER  ,5(2H. ),I8,6X,
     1       32HFIXED SET IDENTIFICATION NUMBER ,4(2H. ))        
  921 FORMAT (13X,36HBOUNDARY SET IDENTIFICATION NUMBER  ,5(2H. ),I8,6X,
     1       32HFIXED SET IDENTIFICATION NUMBER ,4(2H. ),I8)        
  922 FORMAT (A23,' 6220, MODULE ',A1,'REDUCE - RUN EQUALS GO AND ',    
     1       'SUBSTRUCTURE ',2A4,' DOES NOT EXIST.')        
C        
      END        
