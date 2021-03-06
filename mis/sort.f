      SUBROUTINE SORT (IDUM,JDUM,NR,KEYWD,Z,NWDS)        
C        
C     THE ORIGINAL NASTRAN SORT ROUTINE FOR IN-CORE SORTING AND FILE    
C     SORT IS NOW RENAMED SORTI        
C     (ONLY 5 PERCENT OF NASTRAN ROUTINES ACTUALLY CALL SORTI, WITH NON-
C     ZERO IDUM AND JDUM)        
C        
C     THIS NEW SORT ROUTINE WITH IDUM=JDUM=0, PERFORMS ONLY IN-CORE SORT
C     FOR INTEGERS, FLOATING POINT NUMBERS, AND BCD WORDS, BY THE       
C     MODIFIED SHELL METHOD        
C     IT USES MUCH LESS CORE SPACE        
C        
C     ARRAY Z IS NR-ROWS BY (NWDS/NR)-COLUMNS IN SIZE        
C     DATA STORED ROW-WISE IN Z, AND TO BE SORTED BY KEYWD-TH ROW       
C        
C     USE A NEGATIVE KEYWD  IF THE ORIGINAL ORDER OF THE TABLE ENTRIES  
C     ARE TO BE PRESERVED AND THE COLUMN OF KEYWORDS CONTAINS DUPLICATES
C     (INTEGER SORT ONLY)    E.G.        
C        
C     ORIGINAL TABLE     SORTED(KEYWD=+1)       SORTED(KEYWD=-1)        
C     ---------------    ----------------       ----------------        
C       1      4             1      4               1      4        
C       2      2             1     10               1      3        
C       1      3             1      3               1     10        
C       1     10             2      2               2      2        
C        
C        
C     THIS ROUTINE WOULD SWITCH BACK TO THE OLD SHUTTLE EXCHANGE METHOD 
C     NUMBERS OVERFLOW DUE TO THE REQUIREMENT THAT ORIGINAL ORDER MUST B
C     MAINTAINED        
C        
C     ENTRY POINTS        
C        
C     SORT   - TABLE SORT BY INTEGER        
C     SORTF  - TABLE SORT BY F.P. NUMBER        
C     SORTA  - TABLE SORT BY ALPHABETS, 4-BCD CHARACTERS        
C     SORTA8 - TABLE SORT BY ALPHABETS, 8-BCD CHAR. (KEYWD AND KEYWD+1) 
C     SORTA7 - SAME AS SORTA8, EXCEPT LEADING CHAR. IS IGNORED        
C     SORT2K - 2-KEYWORD SORT, SORT BY KEYWD AND KEYWD+1, INTEGER OR    
C              REAL NUMBER KEYS. NEGATIVE KEYWD IS IGNORED        
C        
C     THE TWO SORT CALLS OF THE FOLLOWING FORM CAN BE REPLACED BY ONE CA
C     TO SORT2K, WHICH IS FASTER, NO DANGER OF NUMBER OVERFLOW, AND THE 
C     ORIGINAL SEQUENCE WILL NOT CHANGE WHEN THERE ARE DUPLICATES.      
C        
C         CALL SORT (0,0,N1,-(N2+1),TABLE,N3)        
C         CALL SORT (0,0,N1,-N2,    TABLE,N3)        
C              CAN BE REPLACED BY        
C         CALL SORT2K (0,0,N1,N2,TABLE,N3)        
C        
C        
C     WRITTEN BY G.CHAN/SPERRY, 3/1987        
C        
      LOGICAL         RVSBCD        
      INTEGER         ZI,      ZN,      TEMP,    Z(NR,1), TWO31,   TWO, 
     1                SUBR(6)        
      REAL            RI,      RN        
      COMMON /SYSTEM/ IBUF,    NOUT,    DM37(37),NBPW        
      COMMON /MACHIN/ MACH,    IJHLF(2),LQRO        
      COMMON /TWO   / TWO(16)        
      EQUIVALENCE     (ZI,RI), (ZN,RN)        
      DATA    SUBR  / 2H  ,    2HF ,    2HA ,    2HA8,    2HA7,    2H2K/
C        
C     CHECK ERROR, CHECK DATA TYPE, AND PREPARE FOR SORT        
C        
      ISORT = 1        
      GO TO 10        
C        
      ENTRY SORTF (IDUM,JDUM,NR,KEYWD,Z,NWDS)        
C     =======================================        
      ISORT = 2        
      GO TO 10        
C        
      ENTRY SORTA (IDUM,JDUM,NR,KEYWD,Z,NWDS)        
C     =======================================        
      ISORT = 3        
      GO TO 10        
C        
      ENTRY SORTA8 (IDUM,JDUM,NR,KEYWD,Z,NWDS)        
C     ========================================        
      ISORT = 4        
      GO TO 10        
C        
      ENTRY SORTA7 (IDUM,JDUM,NR,KEYWD,Z,NWDS)        
C     ========================================        
      ISORT = 5        
      GO TO 10        
C        
      ENTRY SORT2K (IDUM,JDUM,NR,KEYWD,Z,NWDS)        
C     ========================================        
      ISORT = 6        
C        
   10 IF (NWDS .EQ. 0) GO TO 330        
      IF (IDUM.NE.0 .OR. JDUM.NE.0) GO TO 300        
      RVSBCD = MOD(LQRO,10) .EQ. 1        
      KEY  = IABS(KEYWD)        
      IF (KEY .GT. NR) GO TO 280        
      NC = NWDS/NR        
      IF (NC*NR .NE. NWDS) GO TO 280        
      M  = NC        
      IF (ISORT.NE.1 .OR. KEYWD.GE.0) GO TO 30        
C        
C                     - INTEGER SORT ONLY -        
C     IF ORIGINAL ORDER IS TO BE MAINTAINED WHERE DUPLICATE KEYWORDS MAY
C     OCCUR, ADD INDICES TO THE KEYWORDS (GOOD FOR BOTH POSITIVE AND    
C     NEGATIVE RANGES, AND BE SURE THAT KEYWORDS ARE NOT OVERFLOWED),   
C     SORT THE DATA, AND REMOVE THE INDICES LATER        
C        
C     IF KEYWORD OVERFLOWS, SWITCH TO SHUTTLE EXCHANGE METHOD        
C        
      IF (NC.GE.TWO(16) .AND. NBPW.LE.32) GO TO 200        
      J = 30        
      IF (NBPW .GE. 60) J = 47        
      TWO31 = 2**J        
      LIMIT = (TWO31-NC)/NC        
      DO 20 I = 1,NC        
      J = Z(KEY,I)        
      IF (IABS(J) .GT. LIMIT) GO TO 200        
      J = J*NC + I        
      K =-1        
      IF (J .LT. 0) K =-NC        
   20 Z(KEY,I) = J + K        
C        
C     SORT BY        
C     MODIFIED SHELL METHOD, A SUPER FAST SORTER        
C        
   30 M = M/2        
      IF (M .EQ. 0) GO TO 180        
      J = 1        
      K = NC - M        
   40 I = J        
   50 N = I + M        
      ZI= Z(KEY,I)        
      ZN= Z(KEY,N)        
      GO TO (60,80,90,90,90,60), ISORT        
C           INT FP A4 A8 A7 2K        
C        
   60 IF (ZI-ZN) 170,70,150        
   70 IF (ISORT .EQ. 1) GO TO 170        
      IF (Z(KEY+1,I)-Z(KEY+1,N)) 170,170,150        
   80 IF (RI-RN) 170,170,150        
   90 KK = 1        
      IF (ISORT .EQ. 5) GO TO 110        
C        
C     COMPARE 1ST BYTE, THEN COMPARE 2ND, 3RD, AND 4TH BYTES TOGETHER   
C     IF MACHINE DOES NOT USE REVERSED BCD ORDER. THOSE MACHINES WITH   
C     REVERSED BCD ORDER (VAX, ULTRIX, S/G) MUST COMPARE EACH BYTE      
C     SEPERATELY BECAUSE OF THE SIGN BIT        
C        
  100 IF (KHRFN1(ZERO,4,ZI,1) - KHRFN1(ZERO,4,ZN,1)) 170,110,150        
  110 IF (.NOT.RVSBCD) IF (KHRFN1(ZI,1,ZERO,4)-KHRFN1(ZN,1,ZERO,4))     
     1                                               170,140,150        
      IF (KHRFN1(ZERO,4,ZI,2) - KHRFN1(ZERO,4,ZN,2)) 170,120,150        
  120 IF (KHRFN1(ZERO,4,ZI,3) - KHRFN1(ZERO,4,ZN,3)) 170,130,150        
  130 IF (KHRFN1(ZERO,4,ZI,4) - KHRFN1(ZERO,4,ZN,4)) 170,140,150        
  140 IF (ISORT.LE.3 .OR. KK.EQ.2) GO TO 170        
      ZI = Z(KEY+1,I)        
      ZN = Z(KEY+1,N)        
      KK = 2        
      GO TO 100        
  150 DO 160 L = 1,NR        
      TEMP = Z(L,I)        
      Z(L,I) = Z(L,N)        
  160 Z(L,N) = TEMP        
      I = I - M        
      IF (I .GE. 1) GO TO 50        
  170 J = J + 1        
      IF (J-K) 40,40,30        
  180 IF (ISORT.NE.1 .OR. KEYWD.GE.0) GO TO 330        
      DO 190 I = 1,NC        
  190 Z(KEY,I) = Z(KEY,I)/NC        
      GO TO 330        
C        
C     SORT BY        
C     SHUTTLE EXCHANGE THETHOD, A SLOW SORTER        
C     (THIS WAS NASTRAN ORIGINAL SORTER, MODIFIED FOR 2-D ARRAY OPERATIO
C     WITH 20-COLUMN LIMITATION REMOVED)        
C        
  200 IF (I .LE. 1) GO TO 220        
      J = I - 1        
      DO 210 I = 1,J        
  210 Z(KEY,I) = Z(KEY,I)/NC        
C        
  220 DO 270 II = 2,NC        
      ZI = Z(KEY,II)        
      JJ = II - 1        
      IF (ZI .GE. Z(KEY,JJ)) GO TO 270        
  230 JJ = JJ - 1        
      IF (JJ .GT. 0) IF (ZI-Z(KEY,JJ)) 230,240,240        
  240 JJ = JJ + 2        
      DO 260 I = 1,NR        
      TEMP = Z(I,II)        
      M = II        
      DO 250 J = JJ,II        
      Z(I,M) = Z(I,M-1)        
  250 M = M - 1        
  260 Z(I,JJ-1) = TEMP        
  270 CONTINUE        
      GO TO 330        
C        
C     ERROR. FORCING A WALK BACK        
C        
  280 WRITE  (NOUT,290) SUBR(ISORT),NR,KEY,NWDS,NC        
  290 FORMAT ('0*** ERROR IN SORT',A2,4I8)        
      GO TO 320        
  300 WRITE  (NOUT,310)        
  310 FORMAT ('0*** CALLING ROUTINE SHOULD CALL SORTI')        
  320 CALL ERRTRC ('SORT    ',320)        
  330 RETURN        
      END        
