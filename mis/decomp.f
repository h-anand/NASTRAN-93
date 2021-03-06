      SUBROUTINE DECOMP (*,IX,X,DX)        
C        
C     DECOMP WILL DECOMPOSE A REAL UNSYMETRIC MATRIX INTO A UNIT LOWER  
C     TRIANGULAR MATRIX AND AN UPPER TRIANGULAR MATRIX,USING PARTIAL    
C     PIVOTING WITHIN THE LOWER BAND        
C        
C     DEFINITION OF INPUT PARAMETERS        
C        
C     FILEA    =  MATRIX CONTROL BLOCK FOR THE INPUT  MATRIX A        
C     FILEL    =  MATRIX CONTROL BLOCK FOR THE OUTPUT MATRIX L        
C     FILEU    =  MATRIX CONTROL BLOCK FOR THE OUTPUT MATRIX U        
C     SR1FIL   =  SCRATCH FILE        
C     SR2FIL   =  SCRATCH FILE        
C     SR3FIL   =  SCRATCH FILE        
C     NX       =  NUMBER OF CELLS OF CORE AVAILABLE AT IX        
C     DET      =  CELL WHERE THE DETERMINATE OF A WILL BE STORED        
C     POWER    =  SCALE FACTOR TO BE APPLIED TO THE DETERMINATE        
C                 (DETERMINATE = DET*10**POWER)        
C     MINDIA   =  CELL WHERE THE VALUE OF THE MINIMUM DIAGONAL WILL BE  
C                 SAVED        
C     IX       =  BLOCK OF CORE AVAILABLE AS WORKING STORAGE TO DECOMP  
C     X        =  SAME BLOCK AS IX, BUT TYPED REAL        
C     DX       =  SAME BLOCK AS IX, BUT TYPED DOUBLE PRECISION        
C        
      INTEGER            FILEA     ,FILEL    ,FILEU    ,POWER    ,      
     1                   SYSBUF    ,FORMA    ,TYPEA    ,RDP      ,      
     2                   TYPEL     ,EOL      ,PARM(5)  ,BUFA     ,      
     3                   OUTBUF    ,SR1BUF   ,SR2BUF   ,SR3BUF   ,      
     4                   B         ,BBAR     ,C        ,CBAR     ,      
     5                   BBAR1     ,R        ,CCOUNT   ,CBCNT    ,      
     6                   SCRFLG    ,END      ,BBBAR    ,BBBAR1   ,      
     7                   COUNT     ,SR2FL    ,SR3FL    ,SR1FIL   ,      
     8                   SR2FIL    ,SR3FIL   ,SQR      ,SYM      ,      
     9                   FLAG      ,ITRAN(4)        
      DOUBLE PRECISION   DZ        ,DA       ,DET      ,MAX      ,      
     1                   MINDIA    ,DX(1)    ,DTRN        
      DIMENSION          IX(1)     ,X(1)        
      CHARACTER          UFM*23    ,UWM*25   ,UIM*29        
      COMMON   /XMSSG /  UFM       ,UWM      ,UIM        
      COMMON   /DCOMPX/  FILEA(7)  ,FILEL(7) ,FILEU(7) ,SR1FIL   ,      
     1                   SR2FIL    ,SR3FIL   ,DET      ,POWER    ,      
     2                   NX        ,MINDIA   ,B        ,BBAR     ,      
     3                   C         ,CBAR     ,R        
      COMMON   /SYSTEM/  SYSBUF    ,NOUT        
      COMMON   /NAMES /  RD        ,RDREW    ,WRT      ,WRTREW   ,      
     1                   REW       ,NOREW    ,EOFNRW   ,RSP      ,      
     2                   RDP       ,CSP      ,CDP      ,SQR      ,      
     3                   RECT      ,DIAG     ,LOWTRI   ,UPRTRI   ,      
     4                   SYM       ,ROW      ,IDENT        
      COMMON   /ZNTPKX/  A(4)      ,II       ,EOL        
      COMMON   /ZBLPKX/  Z(4)      ,JJ        
      COMMON   /UNPAKX/  ITYPEX    ,IXY      ,JXY      ,INCRX        
      COMMON   /PACKX /  ITYPE1    ,ITYPE2   ,IY       ,JY       ,      
     1                   INCRY        
      EQUIVALENCE        (DA,A(1))           ,(DZ,Z(1))          ,      
     1                   (FORMA,FILEA(4))    ,(TYPEA,FILEA(5))   ,      
     2                   (NCOL,FILEA(3))     ,(TYPEL,FILEL(5))        
      EQUIVALENCE        (ITRAN(1),ITRN)     ,(ITRAN(2),JTRN)    ,      
     1                   (ITRAN(3),DTRN)        
      DATA      PARM(3), PARM(4)/ 4HDECO,4HMP   /        
      DATA      IBEGN  / 4HBEGN /, IEND /4HEND  /        
C        
C     AT LAST, THE START OF THE PROGRAM        
C        
      IF ((FORMA.NE.SQR .AND. FORMA.NE.SYM) .OR. TYPEA.GT.RDP) GOTO 1660
C        
C     BUFFER ALLOCATION        
C        
      BUFA   = NX     - SYSBUF        
      IBUFL  = BUFA   - SYSBUF        
      OUTBUF = IBUFL  - SYSBUF        
      SR1BUF = OUTBUF - SYSBUF        
      SR2BUF = SR1BUF - SYSBUF        
      SR3BUF = SR2BUF - SYSBUF        
      ICRQ   =-SR3BUF        
      IF (ICRQ .GT. 0) GO TO 1668        
      DET    = 1.D0        
      POWER  = 0        
      MINDIA = 1.D+25        
      ITERM  = 0        
      IF (FILEA(1) .LT. 0) ITERM = 1        
      FILEA(1) = IABS(FILEA(1))        
C        
C     WRITE THE HEADER RECORD ON THE OUTPUT TAPES AND INITIALIZE THE    
C     TRAILER RECORDS.        
C        
      CALL GOPEN (FILEL,IX(IBUFL),WRTREW)        
      PARM(2) = SR2FIL        
      CALL OPEN  (*1670,SR2FIL,IX(OUTBUF),WRTREW)        
      CALL FNAME (FILEU(1),X(1))        
      CALL WRITE (SR2FIL,X(1),2,1)        
      FILEL(3) = NCOL        
      FILEL(4) = 4        
      FILEL(2) = 0        
      FILEL(6) = 0        
      FILEL(7) = 0        
      FILEU(2) = 0        
      FILEU(3) = NCOL        
      FILEU(4) = 5        
      FILEU(6) = 0        
      FILEU(7) = 0        
      FILEA(5) = 2        
      IF (NCOL .GT. 2 ) GO TO 10        
      IMHERE = 9        
      CALL ONETWO (*1710,IX(1),X(1),DX(1),ITERM)        
C        
C     CALL GENVEC TO PICK B,BBAR,C,CBAR, AND R        
C        
      RETURN        
   10 IF (B.GT.0 .AND. BBAR.GT.0) GO TO 15        
      IMHERE = 10        
      CALL GENVEC (*1710,IX(BUFA),FILEA(1),NX,IX(1),NCOL,B,BBAR,C,CBAR, 
     1             R,1)        
   15 CONTINUE        
      BBAR1  = BBAR + 1        
      BBBAR  = MIN0(B+BBAR,NCOL)        
      BBBAR1 = BBBAR - 1        
      SCRFLG = 0        
      IF (R .LT. BBBAR1) SCRFLG = 1        
      IF (SCRFLG .EQ. 0) GO TO 20        
      ICRQ = (BBBAR1-R)*2*BBAR        
      CALL PAGE2 (3)        
      WRITE  (NOUT,2000) UIM,ICRQ        
 2000 FORMAT (A29,' 2177, SPILL WILL OCCUR IN UNSYMMETRIC DECOMPOSITION'
     1,      /,I10,' ADDITIONAL MEMORY WORDS NEEDED TO STAY IN CORE.')  
C        
C     INITIALIZE POINTERS TO SPECIFIC AREAS OF CORE        
C        
   20 I1   = 1        
      I1SP = (I1+BBAR*R)*2 - 1        
      IPAK = I1 + BBAR*R + BBBAR/2 + 1        
      I2   = IPAK        
      I3SP = (I2 + MIN0(NCOL,BBBAR+BBAR))*2 - 1        
      I3   = I2  + MIN0(NCOL,BBBAR+BBAR) + C        
      I4SP = I3SP + (BBAR+2)*C*2        
      I4   = I3 + BBAR1*C + CBAR        
      I5   = I4 + BBBAR*CBAR        
      I6SP = (I5+C*CBAR)*2 - 1        
      I7SP = I6SP + CBAR        
      END  = I7SP + C        
      PARM(5) = IBEGN        
      CALL CONMSG (PARM(3),3,0)        
C        
C     DEFINITION OF KEY PROGRAM PARAMETERS        
C        
C     I1     =  POINTER TO AREA WHERE COMPLETED COLUMNS OF L ARE STORED 
C     I1SP   =  POINTER TO AREA WHERE THE PERMUTATION INDEXES ARE STORED
C     IPAK   =  POINTER TO AREA WHERE COLUMNS WILL BE PACKED FROM       
C     I2     =  POINTER TO AREA WHERE THE NEXT COLUMN OF A IS STORED    
C     I3     =  POINTER TO AREA WHERE ACTIVE COLUMNS ARE STORED        
C     I4     =  POINTER TO AREA WHERE ACTIVE ROWS ARE STORED        
C     I5     =  POINTER TO AREA WHERE INTERACTION ELEMENTS ARE STORED   
C     I6SP   =  POINTER TO AREA WHERE SEQUENCED ACTIVE ROW INDICES      
C               ARE STORED        
C     I7SP   =  POINTER TO AREA WHERE SEQUENCED ACTIVE COLUMN INDICES   
C               ARE STORED        
C     B      =  UPPER HALF-BAND        
C     BBAR   =  LOWER HALF-BAND        
C     C      =  NUMBER OF ACTIVE COLUMNS        
C     CBAR   =  NUMBER OF ACTIVE ROWS        
C     R      =  NUMBER OF COLUMNS OF L THAT CAN BE STORED IN CORE       
C     JPOS   =  CURRENT PIVOTAL COLUMN INDEX        
C     JPOSL  =  NEXT COLUMN OF L TO BE WRITTEN OUT        
C     LCOL   =  NUMBER OF COLUMNS OF L CURRENTLY STORED IN CORE OR ON   
C               SCRATCH FILES        
C     CCOUNT =  CURRENT NUMBER OF ACTIVE COLUMNS        
C     CBCNT  =  CURRENT NUMBER OF ACTIVE ROWS        
C     ITRN   =  ROW INDEX OF NEXT ACTIVE COLUMN ELEMENT        
C     JTRN   =  COLUMN INDEX  OF NEXT ACTIVE COLUMN ELEMENT        
C     IOFF   =  ROW POSITION OF THE FIRST ELEMENT IN AREA II        
C     ITERM  =  IF NONZERO, TERMINATE BEFORE THE RE-WRITE        
C     NCOL   =  SIZE OF THE INPUT MATRIX        
C     BBBAR  =  B + BBAR        
C     BBAR1  =  BBAR + 1        
C     BBBAR1 =  B+BBAR - 1        
C     SCRFLG =  NONZERO MEANS SPILL        
C        
C     ****************************************************************  
C     RE-WRITE THE UPPER TRIANGLE OF ACTIVE ELEMENTS IN THE TRANSPOSED  
C     ORDER        
C     ****************************************************************  
C        
      PARM(2) = FILEA(1)        
      CALL OPEN (*1670,FILEA(1),IX(BUFA),RDREW)        
      CCOUNT = 0        
      IF (C .EQ. 0) GO TO 40        
      CALL TRANSP (IX(1),X(1),NX,FILEA(1),B,SR1FIL)        
C        
C     ZERO CORE        
C        
   40 DO 50 I = 1,END        
   50 X(I) = 0.        
      IF (C .EQ. 0) GO TO 260        
C        
C     ****************************************************************  
C     OPEN THE FILE CONTAINING THE TRANSPOSED ACTIVE ELEMENTS AND READ I
C     THE FIRST BBAR + 1 ROWS        
C     ****************************************************************  
C        
      PARM(2) = SR1FIL        
      CALL OPEN (*1670,SR1FIL,IX(SR1BUF),RD)        
      K = 0        
   60 CALL READ (*1680,*1690,SR1FIL,ITRAN(1),4,0,FLAG)        
      IF (ITRN .GT. 0) GO TO 70        
      CALL CLOSE (SR1FIL,REW)        
      GO TO 140        
   70 IF (ITRN .GT. K+1) GO TO 130        
C        
C     DETERMINE IF COLUMN IS ALREADY ACTIVE        
C        
      IF (JTRN .LE. BBBAR) GO TO 60        
      KK  = 0        
   80 IN1 = I3SP + KK        
      IF (IX(IN1) .EQ. JTRN) GO TO 90        
      KK  = KK + 1        
      IF (KK-C) 80,100,1700        
C        
C     ADD IN ACTIVE ELEMENT TO EXISTING COLUMN        
C        
   90 IN1 = I3 + KK*BBAR1 + K        
      DX(IN1) = DTRN        
      GO TO 60        
C        
C     CREATE NEW ACTIVE COLUMN        
C        
  100 CCOUNT = CCOUNT + 1        
      KK  = 0        
  110 IN1 = I3SP + KK        
      IF (IX(IN1) .EQ. 0) GO TO 120        
      KK  = KK + 1        
      IF (KK-C) 110,1700,1700        
  120 IX(IN1) = JTRN        
      IN1     = IN1 + C        
      IX(IN1) = K+1        
      IN1     = I3 + KK*BBAR1 + K        
      DX(IN1) = DTRN        
      GO TO 60        
  130 K = K + 1        
      IF (K-BBAR1) 70,140,1700        
C        
C     SET INDEXES IN AREA VII TO POINT TO THE ACTIVE COLUMNS IN SEQUENCE
C        
  140 ASSIGN 260 TO KK        
  150 IN1 = I7SP        
      K   = 0        
  160 IN2 = I3SP + K        
      IF (IX(IN2)) 1700,180,190        
  170 IN1 = IN1 + 1        
  180 K   = K + 1        
      IF (K-C) 160,250,1700        
  190 IF (IN1 .NE. I7SP) GO TO 200        
      IX(IN1) = K        
      GO TO 170        
  200 KKK = 0        
  210 IN3 = IN1 -KKK        
      IF (IN3 .GT. I7SP) GO TO 220        
      IX(IN3) = K        
      GO TO 170        
  220 IN4 = I3SP + IX(IN3-1)        
      IF (IX(IN2)-IX(IN4)) 240,1700,230        
  230 IX(IN3) = K        
      GO TO 170        
  240 IX(IN3) = IX(IN3-1)        
      KKK = KKK + 1        
      GO TO 210        
  250 GO TO KK, (260,1560)        
  260 CONTINUE        
C        
C     INITIALIZE        
C        
      SR2FL = FILEU(1)        
      SR3FL = SR3FIL        
      JPOS  = 1        
      PARM(2) = FILEA(1)        
      CALL FWDREC (*1680,FILEA(1))        
      LCOL  = 0        
      CBCNT = 0        
      JPOSL = 0        
  270 IF (JPOS .GT. NCOL) GO TO 1650        
C****************************************************************       
C     READ NEXT COLUMN OF A INTO AREA II        
C****************************************************************       
      IOFF   = MAX0(1,JPOS-BBBAR1)        
      COUNT  = CBCNT        
      IMHERE = 275        
      CALL INTPK (*1710,FILEA(1),0,RDP,0)        
      K = 1        
      IF (JPOS .GT. BBBAR) K = JPOS - B + 1        
  280 IF (EOL) 400,290,400        
  290 CALL ZNTPKI        
      IF (II .LT. K) GO TO 280        
      K = JPOS + BBAR        
  300 IF (II .GT. K) GO TO 330        
C        
C     READ ELEMENTS WITHIN THE BAND INTO AREA II        
C        
      IN1 = I2 - IOFF + II        
      DX(IN1) = DA        
  310 IF (EOL) 400,320,400        
  320 CALL ZNTPKI        
      GO TO 300        
C        
C     TAKE CARE OF ACTIVE ELEMENTS BELOW THE BAND        
C        
  330 KK  = 0        
  340 IN1 = I4SP + KK        
      IF (IX(IN1)-II) 350,360,350        
  350 KK  = KK + 1        
      IF (KK-CBAR) 340,370,1700        
C        
C     ADD IN ACTIVE ELEMENT TO EXISTING ROW        
C        
  360 IN1 = I4 + (KK+1)*BBBAR - 1        
      DX(IN1) = DA        
      GO TO 310        
C        
C     CREATE NEW ACTIVE ROW        
C        
  370 KK  = 0        
  380 IN1 = I4SP + KK        
      IF (IX(IN1) .EQ. 0) GO TO 390        
      KK  = KK + 1        
      IF (KK-CBAR) 380,1700,1700        
  390 IX(IN1) = II        
      IN1     = IN1 + CBAR        
      IX(IN1) = JPOS        
      IN1     = I4 + (KK+1)*BBBAR - 1        
      DX(IN1) = DA        
      CBCNT   = CBCNT + 1        
      GO TO 310        
C        
C     ARRANGE ACTIVE ROW INDEXES IN SEQUENCE AND STORE THEM IN AREA VI  
C        
  400 IF (COUNT .EQ. CBCNT) GO TO 500        
      IN1 = I6SP        
      K   = 0        
  410 IN2 = I4SP + K        
      IF (IX(IN2)) 1700,430,440        
  420 IN1 = IN1 + 1        
  430 K   = K + 1        
      IF (K-CBAR) 410,500,1700        
  440 IF (IN1 .NE. I6SP) GO TO 450        
      IX(IN1) = K        
      GO TO 420        
  450 KK  = 0        
  460 IN3 = IN1 - KK        
      IF (IN3 .GT. I6SP) GO TO 470        
      IX(IN3) = K        
      GO TO 420        
  470 IN4 = I4SP + IX(IN3-1)        
      IF (IX(IN2)-IX(IN4)) 490,1700,480        
  480 IX(IN3) = K        
      GO TO 420        
  490 IX(IN3) = IX(IN3-1)        
      KK = KK + 1        
      GO TO 460        
  500 CONTINUE        
C        
C     TEST FOR POSSIBLE MERGING BETWEEN AN INACTIVE-ACTIVE COLUMN AND   
C     THE CURRENT PIVOTAL COLUMN        
C        
      IF (CCOUNT .EQ. 0) GO TO 600        
      IN1 = IX(I7SP) + I3SP        
      IF (IX(IN1)-JPOS) 1700,510,600        
C        
C     MERGE ACTIVE COLUMN AND CURRENT PIVOTAL COLUMN AND ZERO THAT      
C     ACTIVE COLUMN IN AREA III        
C        
  510 IX(IN1) = 0        
      IN1     = IN1 + C        
      IX(IN1) = 0        
      IN1     = I3 + IX(I7SP)*BBAR1        
      CCOUNT  = CCOUNT - 1        
      KK  = 0        
  520 IN2 = IN1 + KK        
      IN3 = I2 + KK        
      DX(IN3) = DX(IN3) + DX(IN2)        
      DX(IN2) = 0.D0        
      KK = KK + 1        
      IF (KK-BBAR1) 520,530,1700        
C        
C     MERGE INTERACTION ELEMENTS        
C        
  530 CONTINUE        
      IF (CBCNT .EQ. 0) GO TO 580        
      IN1 = I5 + IX(I7SP)*CBAR        
      K   = 0        
  540 IN2 = I4SP + K        
      IF (IX(IN2) .EQ. 0) GO TO 560        
      IN3 = IN1 + K        
      IF (DX(IN3) .EQ. 0.D0) GO TO 560        
      IF (IX(IN2) .GT. JPOS+BBAR) GO TO 570        
C        
C     STORE ELEMENT WITHIN THE LOWER BAND        
C        
      IN2 = I2 + IX(IN2) - IOFF        
      DX(IN2) = DX(IN2) - DX(IN3)        
  550 DX(IN3) = 0.D0        
  560 K = K + 1        
      IF (K-CBAR) 540,580,1700        
C        
C     STORE ELEMENT IN THE ACTIVE ROW        
C        
  570 IN2 = I4 + (K+1)*BBBAR - 1        
      DX(IN2) = DX(IN2) - DX(IN3)        
      DX(IN3) = 0.D0        
      GO TO 550        
C        
C     MOVE THE POINTERS IN AREA VII UP ONE        
C        
  580 IN1 = I7SP + CCOUNT - 1        
      DO 590 I = I7SP,IN1        
  590 IX(I    ) = IX(I+1)        
      IX(IN1+1) = 0        
  600 IF(LCOL.EQ.0)GO TO 820        
C        
C     ****************************************************************  
C     OPERATE ON THE CURRENT COLUMN OF A BY ALL PREVIOUS COLUMNS OF L,  
C     MAKING NOTED INTERCHANGES AS YOU GO        
C     ****************************************************************  
C        
      IF (SCRFLG .EQ. 0) GO TO 630        
      IF (LCOL-(R-1)) 630,620,610        
  610 PARM(2) = SR2FL        
      CALL OPEN (*1670,SR2FL,IX(SR2BUF),RD)        
  620 PARM(2) = SR3FL        
      CALL OPEN (*1670,SR3FL,IX(SR3BUF),WRTREW)        
  630 LL   = 0        
      LLL  = 0        
      LLLL = 0        
C        
C     PICK UP INTERCHANGE INDEX FOR COLUMN JPOSL + LL + 1        
C        
  640 IN1    = I1SP + LL        
      INTCHN = IX(IN1)        
      IN2    = I2 + LL        
      IF (INTCHN .EQ. 0) GO TO 650        
C        
C     PERFORM ROW INTERCHANGE        
C        
      IN1 = IN2 + INTCHN        
      DA  = DX(IN1)        
      DX(IN1) = DX(IN2)        
      DX(IN2) = DA        
  650 CONTINUE        
C        
C     COMPUTE THE CONTRIBUTION FROM THAT COLUMN        
C        
      END = MIN0(BBAR1,NCOL-(JPOSL+LL))        
      END = END - 1        
      IF (DX(IN2)) 660,710,660        
  660 IN1 = I1 + LLL*BBAR        
      CALL DLOOP (DX(IN2+1),DX(IN1),-DX(IN2),END)        
      IF (CBCNT .EQ. 0) GO TO 710        
C        
C     TEST TO SEE IF AN INACTIVE-ACTIVE ROW CONTRIBUTION SHOULD BE      
C     ADDED IN        
C        
      KKK = 0        
  680 IN3 = I6SP + KKK        
      IN1 = IX(IN3) + I4SP        
      IF (IX(IN1) .GT. JPOS+BBAR) GO TO 710        
      KK = IN1 + CBAR        
      IF (IX(KK) .GT. JPOSL+LL+1) GO TO 700        
      IF (IX(IN1)-JPOSL-BBAR1 .LE. LL) GO TO 700        
C        
C     ADD IN EFFECT OF THE INACTIVE-ACTIVE ROW        
C        
      IN4 = I2 + IX(IN1) - IOFF        
      K   = JPOSL + BBBAR - JPOS  + LL + I4 + IX(IN3)*BBBAR        
      DX(IN4) = DX(IN4) - DX(K)*DX(IN2)        
  700 KKK = KKK + 1        
      IF (KKK .LT. CBCNT) GO TO 680        
  710 LL  = LL  + 1        
      LLL = LLL + 1        
      IF (LL .EQ. LCOL) GO TO 770        
      IF (LL-R+1) 640,720,750        
  720 IF (R .EQ. BBBAR1) GO TO 640        
      IN1  = I1  + LL*BBAR        
  740 ICRQ = IN1 + BBAR*2 - 1 - SR3BUF        
      IF (ICRQ .GT. 0) GO TO 1668        
      IBBAR2 = BBAR*2        
      CALL READ (*1680,*1690,SR2FL,DX(IN1),IBBAR2,0,FLAG)        
      GO TO 640        
  750 IN1 = I1 + (LLL-1)*BBAR        
      IF (LL.EQ.R .AND. LCOL.EQ.BBBAR1) GO TO 760        
      CALL WRITE (SR3FL,DX(IN1),2*BBAR,0)        
  760 LLL = LLL - 1        
      GO TO 740        
  770 CONTINUE        
C        
C     COMPUTE ELEMENTS FOR THE ACTIVE ROWS        
C        
      IF (CBCNT .EQ. 0) GO TO 820        
      K   = 0        
  780 IN1 = I4SP + K        
      IF (IX(IN1) .GT. JPOS+BBAR) GO TO 800        
  790 K   = K + 1        
      IF (K-CBAR) 780,820,1700        
  800 IN1 = IN1 + CBAR        
      IF (IX(IN1) .EQ. JPOS) GO TO 790        
      KKK = MAX0(0,BBBAR-JPOS+IX(IN1)-1)        
      IN2 = I4  + K*BBBAR - 1        
      IN3 = I2  + KKK - 1 - MAX0(0,BBBAR-JPOS)        
      IN1 = IN2 + BBBAR        
      IN2 = IN2 + KKK        
  810 IN2 = IN2 + 1        
      KKK = KKK + 1        
      IN3 = IN3 + 1        
      DX(IN1) = DX(IN1)-DX(IN2)*DX(IN3)        
      IF (KKK-BBBAR1) 810,790,1700        
C        
C     SEARCH THE LOWER BAND FOR THE MAXIMUM ELEMENT AND INTERCHANGE     
C     ROWS TO BRING IT TO THE DIAGONAL        
C        
  820 K   = 1        
      IN1 = I2 + JPOS - IOFF        
      MAX = DABS(DX(IN1))        
      END = MIN0(BBAR1,NCOL-JPOS+1)        
      INTCHN = 0        
      IF (END .EQ. 1) GO TO 860        
  830 IN2 = IN1 + K        
      IF (DABS(DX(IN2)) .GT. MAX) GO TO 850        
  840 K = K + 1        
      IF (K-END) 830,860,1700        
  850 MAX = DABS(DX(IN2))        
      INTCHN = K        
      GO TO 840        
C        
  860 IF (INTCHN .EQ. 0) GO TO 870        
C        
C     INTERCHANGE ROWS IN AREA II        
C        
      DET = -DET        
C        
      MAX = DX(IN1)        
      IN2 = IN1 + INTCHN        
      DX(IN1) = DX(IN2)        
      DX(IN2) = MAX        
C        
C     STORE THE PERMUTATION INDEX        
C        
      IN2 = I1SP + LCOL        
      IX(IN2) = INTCHN        
C        
C     DIVIDE THE LOWER BAND BY THE DIAGONAL ELEMENT        
C        
  870 IMHERE = 870        
      IF (DX(IN1) .EQ. 0.D0) GO TO 1710        
      MAX = 1.D0/DX(IN1)        
      MINDIA = DMIN1(DABS(DX(IN1)),MINDIA)        
  880 IF (DABS(DET) .LE. 10.D0) GO TO 890        
      DET   = DET/10.D0        
      POWER = POWER + 1        
      GO TO 880        
  890 IF (DABS(DET) .GE. .1D0) GO TO 900        
      DET   = DET*10.D0        
      POWER = POWER - 1        
      GO TO 890        
  900 DET = DET*DX(IN1)        
      K   = 1        
      END = MIN0(BBAR1,NCOL-JPOS+1)        
      IF (END .EQ. 1) GO TO 920        
  910 IN2 = IN1 + K        
      DX(IN2) = DX(IN2)*MAX        
      K = K + 1        
      IF (K-END) 910,920,1700        
  920 IF (CBCNT .EQ. 0) GO TO 940        
C        
C     DIVIDE THE ACTIVE ROWS BY THE DIAGONAL        
C        
      K   = 0        
      IN1 = I4 + BBBAR1        
  930 DX(IN1) = DX(IN1)*MAX        
      IN1 = IN1 + BBBAR        
      K   = K + 1        
      IF (K-CBAR) 930,940,1700        
  940 CONTINUE        
C        
C     INTERCHANGE ACTIVE COLUMNS AND ADD IN EFFECT OF THE COLUMN OF L   
C     ABOUT TO BE WRITTEN OUT        
C        
      IF (CCOUNT .EQ. 0) GO TO 990        
      IF (JPOS .LT. BBBAR) GO TO 990        
      INTCH = IX(I1SP)        
      K   = 0        
  950 IN1 = I3SP + K        
      IF (INTCH .EQ. 0) GO TO 960        
      IN1 = I3  + K*BBAR1        
      IN2 = IN1 + INTCH        
      DA  = DX(IN1)        
      DX(IN1) = DX(IN2)        
      DX(IN2) = DA        
  960 KK  = 1        
      IN2 = I1 - 1        
      IN1 = I3 + K*BBAR1        
      IF (DX(IN1) .EQ. 0.D0) GO TO 980        
  970 IN3 = IN1 + KK        
      IN4 = IN2 + KK        
      DX(IN3) = DX(IN3) - DX(IN1)*DX(IN4)        
      KK = KK + 1        
      IF (KK-BBAR1) 970,980,1700        
  980 K = K + 1        
      IF (K-C) 950,990,1700        
C        
C     WRITE OUT THE NEXT COLUMN OF U AND THE ROW OF ACTIVE ELEMENTS     
C        
  990 PARM(2) = SR2FIL        
      CALL BLDPK (RDP,TYPEL,SR2FIL,0,0)        
      IN1 = I2        
      JJ  = IOFF        
      IMHERE = 1030        
 1000 DZ = DX(IN1)        
      IF (DZ) 1010,1020,1010        
 1010 CALL ZBLPKI        
 1020 IN1 = IN1 + 1        
      JJ  = JJ  + 1        
      IF (JJ-JPOS)   1000,1000,1030        
 1030 IF (DX(IN1-1)) 1040,1710,1040        
 1040 CONTINUE        
C        
C     PACK ACTIVE COLUMN ELEMENTS ALSO        
C        
      IF (CCOUNT .EQ.   0) GO TO 1080        
      IF (JPOS .LT. BBBAR) GO TO 1080        
      K   = 0        
 1050 IN1 = I7SP + K        
      IN2 = IX(IN1) + I3SP        
      GO TO 1070        
 1060 K = K + 1        
      IF (K-CCOUNT) 1050,1080,1700        
 1070 IN3 = I3 + IX(IN1)*BBAR1        
      DZ  = DX(IN3)        
      IF (DZ .EQ. 0.D0) GO TO 1060        
      JJ = IX(IN2)        
      CALL ZBLPKI        
      GO TO 1060        
 1080 CALL BLDPKN (SR2FIL,0,FILEU)        
C        
C     COMPUTE ACTIVE ROW-COLUMN INTERACTION        
C        
      IF (CCOUNT.EQ.0 .OR. CBCNT.EQ.0) GO TO 1130        
      IF (JPOS .LT. BBBAR) GO TO 1130        
      K = 0        
 1090 CONTINUE        
      IN1 = I3 + K*BBAR1        
      IF (DX(IN1) .EQ. 0.D0) GO TO 1120        
      KK  = 0        
 1100 IN2 = I4SP + KK        
      IN2 = I4 + KK*BBBAR        
      IF (DX(IN2) .EQ. 0.D0) GO TO 1110        
      IN3 = I5 + K*CBAR + KK        
      DX(IN3) = DX(IN3)+DX(IN2)*DX(IN1)        
 1110 KK = KK + 1        
      IF (KK-CBAR) 1100,1120,1700        
 1120 K  = K  + 1        
      IF (K-C) 1090,1130,1700        
C        
C     MOVE ELEMENTS IN AREA III UP ONE CELL        
C        
 1130 IF (CCOUNT . EQ.  0) GO TO 1180        
      IF (JPOS .LT. BBBAR) GO TO 1180        
      K   = 0        
 1140 IN1 = I3SP + K        
      IF (IX(IN1) .EQ. 0) GO TO 1170        
      KK  = 0        
      IN1 = I3  + K*(BBAR1)        
 1150 IN2 = IN1 + KK        
      DX(IN2) = DX(IN2+1)        
      KK = KK + 1        
      IF (KK-BBAR) 1150,1160,1700        
 1160 DX(IN2+1) = 0.D0        
 1170 K  = K + 1        
      IF (K-C) 1140,1180,1700        
C        
C     DETERMINE IF A COLUMN OF L CAN BE WRITTEN OUT        
C        
 1180 IF (LCOL-BBBAR1) 1360,1190,1190        
C        
C     OUTPUT A COLUMN OF L        
C        
 1190 PARM(2) = FILEL(1)        
      JPOSL   = JPOSL + 1        
      CALL BLDPK (RDP,TYPEL,FILEL(1),0,0)        
C        
C     STORE THE PERMUTATION INDEX AS THE DIAGONAL ELEMENT        
C        
      JJ = JPOSL        
      DZ = IX(I1SP)        
      CALL ZBLPKI        
      K  = 0        
 1200 JJ = JPOSL + K + 1        
      IN2= I1  + K        
      DZ = DX(IN2)        
      IF (DZ) 1210,1220,1210        
 1210 CALL ZBLPKI        
 1220 K = K + 1        
      IF (K-BBAR) 1200,1230,1700        
C        
C     PACK ACTIVE ROW ELEMENTS ALSO        
C        
 1230 IF (CBCNT .EQ. 0) GO TO 1270        
      K   = 0        
 1240 IN1 = I6SP + K        
      IN2 = I4 + IX(IN1)*BBBAR        
      IN1 = IX(IN1) + I4SP        
      JJ  = IX(IN1)        
      DZ  = DX(IN2)        
      IF (DZ .EQ. 0.D0) GO TO 1260        
      CALL ZBLPKI        
 1260 K = K + 1        
      IF (K-CBCNT) 1240,1270,1700        
 1270 CALL BLDPKN (FILEL,0,FILEL)        
C        
C     MOVE PERMUTATION INDICES OVER ONE ELEMENT        
C        
      END = I1SP + LCOL        
      DO 1280 I = I1SP,END        
 1280 IX(I) = IX(I+1)        
C        
C     MOVE ELEMENTS IN AREA I OVER ONE COLUMN        
C        
      K = 0        
      IF (SCRFLG .EQ. 0) GO TO 1300        
      CALL CLOSE (SR2FL,REW)        
      IF (R .GT. 2) GO TO 1300        
      ICRQ = I1 + BBAR*2 - 1 - SR3BUF        
      IF (ICRQ .GT. 0) GO TO 1668        
      CALL OPEN (*1670,SR2FL,IX(SR2BUF),RD)        
      IBBAR2 = 2*BBAR        
      CALL READ (*1680,*1690,SR2FL,DX(I1),IBBAR2,0,FLAG)        
      GO TO 1350        
 1300 IN1 = I1  + K*BBAR        
      IN2 = IN1 + BBAR        
      CALL XLOOP (DX(IN1),DX(IN2),BBAR)        
      K = K + 1        
      IF (K-R+2) 1300,1330,1350        
 1330 IF (R-BBBAR1) 1340,1300,1700        
 1340 ICRQ = IN2 + BBAR*2 - 1 - SR3BUF        
      IF (ICRQ .GT. 0) GO TO 1668        
      CALL OPEN (*1670,SR2FL,IX(SR2BUF),RD)        
      IBBAR2 = BBAR*2        
      CALL READ (*1680,*1690,SR2FL,DX(IN2),IBBAR2,0,FLAG)        
 1350 LCOL = LCOL - 1        
C        
C     STORE CURRENT COLUMN OF L        
C        
 1360 IF (CBCNT .EQ. 0) GO TO 1410        
C        
C     MOVE ELEMENTS IN AREA IV UP ONE CELL        
C        
      K   = 0        
 1370 IN1 = I4SP + K        
      IF (IX(IN1) .EQ. 0) GO TO 1400        
      KK  = 0        
      IN1 = I4 + K*BBBAR        
 1380 IN2 = IN1 + KK        
      DX(IN2) = DX(IN2+1)        
      KK = KK + 1        
      IF (KK-BBBAR1) 1380,1390,1700        
 1390 DX(IN2+1) = 0.D0        
 1400 K = K + 1        
      IF (K-CBAR) 1370,1410,1700        
 1410 IF (SCRFLG .NE. 0) GO TO 1440        
C        
C     STORE COLUMN IN CORE        
C        
 1420 IN1 = I1 + LCOL*BBAR        
      END = MIN0(BBAR,NCOL-JPOS)        
      IF (END .EQ. 0) GO TO 1470        
      K   = 0        
      IN3 = I2 + JPOS - IOFF + 1        
 1430 IN2 = IN1 + K        
      IN4 = IN3 + K        
      DX(IN2) = DX(IN4)        
      K = K + 1        
      IF (K-END) 1430,1470,1700        
C        
C     STORE COLUMN ON THE SCRATCH FILE        
C        
 1440 IF (LCOL-R+1) 1420,1460,1450        
 1450 IN1 = I1 + (LLL-1)*BBAR        
      CALL WRITE (SR3FL,DX(IN1),BBAR*2,0)        
 1460 IN1 = I2 + JPOS - IOFF + 1        
      CALL WRITE (SR3FL,DX(IN1),BBAR*2,0)        
C        
C     CLOSE SCRATCH FILES AND SWITCH THE POINTERS TO THEM        
C        
      CALL CLOSE (SR3FL,REW)        
      CALL CLOSE (SR2FL,REW)        
      IN1   = SR2FL        
      SR2FL = SR3FL        
      SR3FL = IN1        
 1470 LCOL  = LCOL + 1        
      IF (C .EQ. 0) GO TO 1560        
      IF (JPOS .LT. BBBAR) GO TO 1560        
C        
C     READ IN THE NEXT ROW OF ACTIVE COLUMN ELEMENTS        
C        
      COUNT = CCOUNT        
      IF (ITRN .LT. 0) GO TO 1560        
 1480 IF (ITRN .GT. JPOS-B+2) GO TO 1550        
C        
C     TEST TO SEE IF COLUMN IS ALREADY ACTIVE        
C        
      K   = 0        
 1490 IN1 = I3SP + K        
      IF (IX(IN1) .EQ. JTRN) GO TO 1530        
      K   = K + 1        
      IF (K-C) 1490,1500,1700        
C        
C     CREATE A NEW ACTIVE COLUMN        
C        
 1500 K   = 0        
 1510 IN1 = I3SP + K        
      IF (IX(IN1) .EQ. 0) GO TO 1520        
      K   = K + 1        
      IF (K-C) 1510,1700,1700        
 1520 IX(IN1) = JTRN        
      IN1     = IN1 + C        
      IX(IN1) = ITRN        
      IN1     = I3 + (K+1)*BBAR1 - 1        
      DX(IN1) = DTRN        
      CCOUNT  = CCOUNT + 1        
      GO TO 1540        
C        
C     STORE ELEMENT IN EXISTING COLUMN        
C        
 1530 IN1 = I3 + (K+1)*BBAR1 - 1        
      DX(IN1) = DX(IN1) + DTRN        
 1540 CALL READ (*1680,*1690,SR1FIL,ITRAN,4,0,FLAG)        
      IF (ITRN .GT. 0) GO TO 1480        
      CALL CLOSE (SR1FIL,REW)        
 1550 IF (CCOUNT .EQ. COUNT) GO TO 1560        
C        
C     RE-ARRANGE INDEXES IN SEQUENTIAL ORDER        
C        
      ASSIGN 1560 TO KK        
      GO TO 150        
 1560 CONTINUE        
      JPOS = JPOS + 1        
C        
C     ZERO AREA II        
C        
      END = I2 + MIN0(JPOS-IOFF+BBAR-1,NCOL-1)        
      DO 1580 I = I2,END        
 1580 DX(I) = 0.D0        
C        
C      TEST TO SEE IF ROW INTERACTION ELEMENTS WILL MERGE INTO AREA III 
C        
      IF (CBCNT  .EQ. 0) GO TO 270        
      IF (CCOUNT .EQ. 0) GO TO 1620        
      IF (JPOS-1 .LT. BBBAR) GO TO 270        
      IN1 = I4SP        
      K   = 0        
 1590 IN2 = IN1 + K        
      IF (IX(IN2) .EQ. JPOS-B+1) GO TO 1600        
      K   = K + 1        
      IF (K .LT. CBAR) GO TO 1590        
      GO TO 270        
 1600 IN1 = I5 + K        
      IN2 = I3 + BBAR        
      K   = 0        
 1610 DX(IN2) = DX(IN2)-DX(IN1)        
      DX(IN1) = 0.D0        
      IN2 = IN2 + BBAR1        
      IN1 = IN1 + CBAR        
      K   = K + 1        
      IF (K .LT. C) GO TO 1610        
C        
C      TEST TO SEE IF ACTIVE ROW HAS BEEN ELIMINATED        
C        
 1620 IN1 = IX(I6SP) + I4SP        
      IF (IX(IN1)-JPOSL-BBAR1) 270,1630,270        
C        
C     ELIMINATE THE ACTIVE ROW        
C        
 1630 IX(IN1) = 0        
      IN1     = IN1 + CBAR        
      IX(IN1) = 0        
      CBCNT   = CBCNT - 1        
C        
C     MOVE INDEXES IN AREA VI UP ONE        
C        
      IN1 = I6SP + CBCNT - 1        
      DO 1640 I = I6SP,IN1        
 1640 IX(I    ) = IX(I+1)        
      IX(IN1+1) = 0        
      GO TO 270        
C        
C     FINISH WRITING OUT THE COMPLETED COLUMNS OF L        
C        
 1650 CONTINUE        
      CALL CLOSE (SR1FIL,REW)        
      CALL CLOSE (FILEL,NOREW)        
      CALL CLOSE (SR2FIL,NOREW)        
      PARM(5) = IEND        
      CALL CONMSG (PARM(3),3,0)        
      CALL FINWRT (ITERM,SCRFLG,SR2FL,JPOSL,I1SP,BBAR,I1,CBCNT,IPAK,R,  
     1             BBBAR1,BBBAR,I6SP,I4,I4SP,IX,DX,X,LCOL)        
      FILEU(7) = BBBAR        
      RETURN        
C        
C     ERROR EXITS        
C        
 1660 PARM(1) = -7        
      GO TO 1720        
 1668 PARM(1) = -8        
      PARM(2) = ICRQ        
      GO TO 1720        
 1670 PARM(1) = -1        
      GO TO 1720        
 1680 PARM(1) = -2        
      GO TO 1720        
 1690 PARM(1) = -3        
      GO TO 1720        
 1700 PARM(1) = -25        
      GO TO 1720        
C        
C     SINGULAR MATRIX - CLOSE ALL FILES AND RETURN TO USER        
C        
 1710 CALL CLOSE (FILEA(1),REW)        
      CALL CLOSE (FILEL(1),REW)        
      CALL CLOSE (FILEU(1),REW)        
      CALL CLOSE (SR1FIL,REW)        
      CALL CLOSE (SR2FIL,REW)        
      CALL CLOSE (SR3FIL,REW)        
      WRITE  (NOUT,1715) IMHERE        
 1715 FORMAT (/60X,'DECOMP/IMHERE@',I5)        
      RETURN 1        
 1720 CALL MESAGE (PARM(1),PARM(2),PARM(3))        
      RETURN        
      END        
