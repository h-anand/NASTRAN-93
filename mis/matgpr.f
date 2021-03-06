      SUBROUTINE MATGPR        
C        
C     DMAP FOR MATGPR MODULE        
C        
C     MATGPR    GPL,USET,SIL,KFS//C,N,F/C,N,S/C,N,PRTOPT/        
C                                 C,N,FILTER/C,N,FLTRFLAG $        
C        
C     THIS MODULE ENHANCED BY P.R.PAMIDI/RPK CORPORATION, 3/1988        
C        
      EXTERNAL        ANDF        
      INTEGER         GPL,USET,SIL,IM(7),TWO1,ANDF,SYSBUF,CORE,BLANK,   
     1                OTPE,TYCOMP,SCALAR,COMPS(6),EXID,PRBUF(15),       
     2                HEAD2(32),IPRBF(4),ICHAR(17),PRBUFC(5)        
      INTEGER         NAME(2),EXTRA,HSET        
      REAL            A(4),PRBUFX(5),XXBUF(15)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /CONDAS/ IDUM(2),RADDEG        
      COMMON /SYSTEM/ SYSBUF,OTPE,INX(6),NLPP,INX1(2),LINE        
CZZ   COMMON /ZZMGPR/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /BITPOS/ IBITS(32),ICHAR        
      COMMON /OUTPUT/ HEAD(96),LABEL(96)        
      COMMON /ZNTPKX/ IA(4),II,IEOL,IEOR        
      COMMON /BLANK / IISET(2),KKSET(2),IPOPT(2),FILTER,IFLFLG        
      COMMON /TWO   / TWO1(32)        
      EQUIVALENCE     (XXBUF(1),PRBUF(1))        
      EQUIVALENCE     (PRBUFC(1),PRBUFX(1))        
      EQUIVALENCE     (IA(1), A(1))        
      DATA    GPL,USET,SIL,MATRX    / 101   ,102   ,103   ,104     /    
      DATA    SCALAR,COMPS,NLINE    / 4H S  ,4HT1  ,4HT2  ,4HT3    ,    
     1                                4HR1  ,4HR2  ,4HR3  ,15      /    
      DATA    NAME  / 4HMATG, 4HPR  /        
      DATA    NULL  / 4HNULL        /        
      DATA    BLANK,  EXTRA,  HSET  / 4H    ,4H E  ,4H H           /    
      DATA    IHSET / 4HH           /        
      DATA    IALLP / 4HALLP        /        
      DATA    HEAD2 /        
     1        4H    , 4HPOIN, 4HT   , 4H    , 4H   V, 4HALUE, 4H    ,   
     2        4H POI, 4HNT  , 4H    , 4H    , 4HVALU, 4HE   , 4H  P0,   
     3        4HINT , 4H    , 4H    , 4H VAL, 4HUE  , 4H   P, 4HOINT,   
     4        4H    , 4H    , 4H  VA, 4HLUE , 4H    , 4H POI, 4HNT  ,   
     5        4H    , 4H    , 4HVALU, 4HE   /        
C        
C        
      ISET = IISET(1)        
      KSET = KKSET(1)        
      INLOPT = 0        
      IF (IPOPT(1) .EQ. NULL) INLOPT = 1        
      IF (FILTER   .EQ.  0.0) GO TO 5        
      IFLAG = 1        
      IF (FILTER .LT. 0.0) IFLAG = 2        
      IF (IFLFLG .NE.   0) IFLAG = IFLAG + 2        
    5 IM(1) = MATRX        
      CALL RDTRL (IM(1))        
      IF (IM(1) .LT. 0) GO TO 380        
C        
C     CONVERT BCD TO BIT POSITION IN USET        
C        
      DO 10 I = 1,32        
      IF (ICHAR(I) .EQ. ISET) GO TO 20        
   10 CONTINUE        
      IF (ISET .NE. IHSET) GO TO 15        
      ISET = -1        
      GO TO 21        
   15 WRITE  (OTPE,16) UWM,IISET        
   16 FORMAT (A25,', UNKNOWN SET ',2A4,' SPECIFIED FOR THE FIRST PARA', 
     1        'METER OF THE MATGPR MODULE.  MODULE NOT EXECUTED.')      
      RETURN        
C        
   20 ISET = IBITS(I)        
   21 CONTINUE        
      DO 30 I = 1,32        
      IF (ICHAR(I) .EQ. KSET) GO TO 40        
   30 CONTINUE        
      KSET = ISET        
      GO TO 50        
   40 KSET = IBITS(I)        
   50 CONTINUE        
      LCORE = KORSZ(CORE) - SYSBUF        
      IBUF  = LCORE + 1        
      IF (ISET+KSET .EQ. -2)  GO TO 51        
      CALL GOPEN (GPL,CORE(IBUF),0)        
      CALL READ  (*460,*60,GPL,CORE(1),LCORE,0,LGPL)        
      CALL CLOSE (GPL,1)        
      GO TO 500        
C        
C     NSET ONLY  NO GPL,USET,  ETC.        
C        
   51 LGPL  = 0        
      LUSET = 0        
      LSIL  = 0        
      IUSET = 1        
      ISIL  = 1        
      GO TO 81        
   60 CALL CLOSE (GPL,1)        
      LCORE = LCORE - LGPL        
      CALL GOPEN (USET,CORE(IBUF),0)        
      IUSET = LGPL + 1        
      CALL READ  (*480,*70,USET,CORE(LGPL+1),LCORE,0,LUSET)        
      CALL CLOSE (USET,1)        
      GO TO 500        
   70 CALL CLOSE (USET,1)        
      LCORE = LCORE - LUSET        
      CALL GOPEN (SIL,CORE(IBUF),0)        
      ISIL  = LGPL + LUSET + 1        
      CALL READ  (*490,*80,SIL,CORE(ISIL),LCORE,0,LSIL)        
      CALL CLOSE (SIL,1)        
      GO TO 500        
   80 CALL CLOSE (SIL,1)        
      K = ISIL + LSIL        
      LCORE   = LCORE - LSIL - 1        
      CORE(K) = LUSET + 1        
C        
C     LOAD HEADER FOR PAGES        
C        
      LSIL = LSIL + 1        
   81 CONTINUE        
      DO 90 I = 1,96        
   90 LABEL(I) = BLANK        
      DO 100 I = 1,32        
      K = 32 + I        
  100 LABEL(K) = HEAD2(I)        
      NCOL  = IM(2)        
      CALL FNAME (MATRX,LABEL(4))        
      CALL GOPEN (MATRX,CORE(IBUF),0)        
      IE    = IBITS(12)        
      INULL = 0        
      LOOP  = 0        
      ICMPX = 1        
      IF (IM(5) .GT. 2) ICMPX = 3        
      IF (ISET .NE. -1) MASK  = TWO1(ISET)        
      IF (KSET .NE. -1) MASK1 = TWO1(KSET)        
      MUSET = 0        
      JC    = 0        
      IKSIL = 1        
      L     = 1        
      ASSIGN 210 TO IOUT        
      CALL PAGE        
C        
C     START LOOP ON EACH COLUMN        
C        
  110 LOOP = LOOP + 1        
      CALL INTPK (*390,MATRX,0,ICMPX,0)        
      IF (INULL .NE. 0) GO TO 400        
  120 CONTINUE        
      IF (INLOPT .EQ. 1) GO TO 359        
C        
C     CHECK FOR HSET        
C        
  121 IF (ISET  .EQ.   -1) GO TO 150        
      IF (MUSET .EQ. LOOP) GO TO 160        
  130 JC = JC + 1        
      IF (JC .GT. LUSET) GO TO 150        
      KK = LGPL + JC        
      IF (ANDF(CORE(KK),MASK)) 140,130,140        
C        
C     FOUND COLUMN IN USET        
C        
  140 MUSET = MUSET + 1        
      GO TO 121        
C        
C     COLUMN NOT IN USET        
C        
  150 IPRBF(L  ) = LOOP        
      IPRBF(L+1) = HSET        
      GO TO 200        
C        
C     JC IS INDEX OF NON-ZERO IN G SET-- SOOK UP SIL        
C        
  160 IF (IKSIL .EQ. LSIL+1) GO TO 150        
      KK = ISIL + IKSIL        
      IF (JC .LT. CORE(KK)) GO TO 170        
      IKSIL = IKSIL + 1        
      GO TO 160        
  170 ICOMP = JC - CORE(KK-1) + 1        
      IF (ICOMP .NE. 1) GO TO 180        
C        
C     CHECK FOR SCALAR POINT        
C        
      IF (CORE(KK)-CORE(KK-1) .GT. 1) GO TO 180        
      TYCOMP = SCALAR        
C        
C     CHECK FOR EXTRA        
C        
      KK = LGPL + JC        
      IF (ANDF(CORE(KK),TWO1(IE))) 171,190,171        
  171 TYCOMP = EXTRA        
      GO TO 190        
  180 TYCOMP = COMPS(ICOMP)        
  190 EXID   = CORE(IKSIL)        
      IPRBF(L+1) = TYCOMP        
      IPRBF(L  ) = EXID        
  200 GO TO IOUT, (210,420,430)        
  210 WRITE  (OTPE,220)LOOP,IPRBF(1),IPRBF(2)        
  220 FORMAT ('0COLUMN',I8,2H (,I8,1H-,A2,2H).)        
      LINE  = LINE + 2        
      IF (LINE .GE.NLPP) CALL PAGE        
      JJ    = 0        
      KUSET = 0        
      KSIL  = 1        
      IPB   = 1        
      IPBC  = 1        
      IEND  = 0        
  230 IF (IEOL) 350,240,350        
  240 CALL ZNTPKI        
C        
C     CHECK FILTER        
C        
      IF (FILTER .EQ. 0.0) GO TO 246        
C        
C     FILTER IS NON-ZERO        
C        
      VALUE = A(1)        
      IF (ICMPX .EQ. 3) VALUE = SQRT(A(1)*A(1) + A(2)*A(2))        
      GO TO (241,242,243,244), IFLAG        
C        
  241 IF (ABS(VALUE) .LT. FILTER) GO TO 230        
      GO TO 246        
  242 IF (ABS(VALUE) .GT. ABS(FILTER)) GO TO 230        
      GO TO 246        
  243 IF (VALUE.LT.FILTER .AND. VALUE.GT.0.0) GO TO 230        
      GO TO 246        
  244 IF (VALUE.GT.FILTER .AND. VALUE.LT.0.0) GO TO 230        
C        
C     CHECK FOR HSET        
C        
  246 IF (KSET .EQ. -1) GO TO 306        
C        
C     LOOK UP ROW IN USET        
C        
  250 IF (KUSET .GT. LUSET+1) GO TO 500        
      IF (KUSET .EQ.      II) GO TO 280        
  260 JJ = JJ + 1        
C        
C     PROTECT AGINST NO BITPOS OR NO USET        
C        
      IF (JJ .GT. LUSET) GO TO 306        
      KK = LGPL + JJ        
      IF (ANDF(CORE(KK),MASK1)) 270,260,270        
C        
C     FOUND ELEMENT IN USET        
C        
  270 KUSET = KUSET + 1        
      GO TO 250        
C        
C     JJ IS INDEX OF NON-ZERO IN G SET - NOW SEARCH SIL FOR JJ        
C        
  280 IF (KSIL .EQ. LSIL+1) GO TO 510        
      KK = ISIL + KSIL        
      IF (JJ .LT. CORE(KK)) GO TO 290        
      KSIL = KSIL + 1        
      GO TO 280        
  290 ICOMP = JJ - CORE(KK-1) + 1        
      IF (ICOMP .NE. 1) GO TO 300        
C        
C     CHECK FOR SCALAR POINT        
C        
      IF (CORE(KK)-CORE(KK-1) .GT. 1) GO TO 300        
      TYCOMP = SCALAR        
C        
C     CHECK FOR EXTRA POINT        
C        
      KK = LGPL + JJ        
      IF (ANDF(CORE(KK),TWO1(IE))) 305,310,305        
C        
C     EXTRA POINT        
C        
  305 TYCOMP = EXTRA        
      GO TO 310        
C        
C     H POINT        
C        
  306 TYCOMP = HSET        
      EXID   = II        
      GO TO 311        
  300 TYCOMP = COMPS(ICOMP)        
  310 EXID   = CORE(KSIL)        
  311 IF (IPB .GE. NLINE) GO TO 330        
  320 PRBUF(IPB  ) = EXID        
      PRBUF(IPB+1) = TYCOMP        
      IF (ICMPX .EQ. 1) GO TO 325        
      IF (IPOPT(1) .NE. IALLP) GO TO 325        
      AMAG = SQRT(A(1)*A(1) + A(2)*A(2))        
      IF (AMAG .EQ. 0.0) GO TO 325        
      A(2) = ATAN2(A(2),A(1))*RADDEG        
      IF (A(2) .LT. -0.00005) A(2) = A(2) + 360.0        
      A(1) = AMAG        
  325 PRBUF(IPB+2) = IA(1)        
      PRBUFC(IPBC) = IA(2)        
      IPBC = IPBC + 1        
      IPB  = IPB  + 3        
      GO TO 230        
  330 IPB1 = IPB  - 1        
      IPBC = IPBC - 1        
      WRITE  (OTPE,340) (PRBUF(I),PRBUF(I+1),XXBUF(I+2),I=1,IPB1,3)     
  340 FORMAT (5X,5(1X,I8,1X,1A2,1X,1P,E12.5))        
      LINE = LINE + 1        
      IF (ICMPX .EQ. 1) GO TO 343        
      WRITE  (OTPE,341) (PRBUFX(I),I=1,IPBC)        
  341 FORMAT (5X,5(13X,1P,E12.5))        
      WRITE  (OTPE,342)        
  342 FORMAT (1H )        
      LINE = LINE + 2        
  343 CONTINUE        
      IPBC = 1        
      IPB  = 1        
      IF (LINE .GE. NLPP) CALL PAGE        
      IF (IEND .EQ. 1) GO TO 360        
      GO TO 320        
C        
C     END OF COLUMN        
C        
  350 IEND = 1        
      IF (IPB .EQ. 1) GO TO 360        
      GO TO 330        
  359 CALL FWDREC (*510,MATRX)        
  360 IF (LOOP  .NE. NCOL) GO TO 110        
      IF (INULL .NE.    0) GO TO 450        
  370 CALL CLOSE (MATRX,1)        
  380 RETURN        
C        
  390 IF (INULL .NE. 0) GO TO 360        
      INULL = 1        
      IBEGN = LOOP        
      GO TO 360        
  400 IFIN  = LOOP - 1        
      INULL = 0        
  410 LOOPS = LOOP        
      LOOP  = IBEGN        
      ASSIGN 420 TO IOUT        
      GO TO 121        
  420 L = 3        
      LOOP = IFIN        
      ASSIGN 430 TO IOUT        
      GO TO 121        
  430 ASSIGN 210 TO IOUT        
      L = 1        
      LOOP = LOOPS        
      WRITE  (OTPE,440) IBEGN,IPRBF(1),IPRBF(2),IFIN,IPRBF(3),IPRBF(4)  
  440 FORMAT ('0COLUMNS',I8,2H (,I8,1H-,A2,6H) THRU,I8,2H (,I8,1H-,A2,  
     1        11H) ARE NULL.)        
      LINE = LINE + 2        
      IF (LINE .GE. NLPP) CALL PAGE        
      IF (IFIN .NE. NCOL) GO TO 120        
      GO TO 370        
  450 IFIN = LOOP        
      GO TO 410        
  460 IN = GPL        
  470 CALL MESAGE (-2,IN,NAME)        
  480 IN = USET        
      GO TO 470        
  490 IN = SIL        
      GO TO 470        
  500 CALL MESAGE (8,0,NAME)        
      GO TO 370        
  510 CALL MESAGE (7,0,NAME)        
      GO TO 370        
      END        
