      SUBROUTINE FIND (MODE,BUF1,BUF4,SETID,X)        
C        
      INTEGER         AWRD(2),BUF1,BUF4,BUFSIZ,ERR(3),FOR,FSCALE,FVP,   
     1                GPSET,ORIGIN,ORG,PARM,PRJECT,PRNT,REGION,SET,     
     2                SETD,SETID(1),TRA,WORD,X(1),HSET,ORIG,POIN,REGI,  
     3                SCAL,VANT,MSG1(20),MSG3(21),MSG6(20),NAME(2)      
      REAL            IMSEP,MAX,MAXDEF,MIN,MM17P5        
      DOUBLE PRECISION DWRD        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /SYSTEM/ BUFSIZ, NOUT        
      COMMON /BLANK / NGP,SKP11,NSETS,PRNT,SKP12,NGPSET,SKP13(4),       
     1                PARM,GPSET,SKP2(8),MERR,SETD        
      COMMON /XXPARM/ PLTBUF,PLTTER(5),NOPENS,PAPSIZ(2),PENPAP(27),     
     1                SCALE,OBJMOD,FSCALE,MAXDEF,DEFMAX,AXIS(6),VIEW(9),
     2                FVP,SKPVP1(4),D0,SKPVP2(2),PRJECT,S0S,FOR,ORG,    
     3                NORG,ORIGIN(11),EDGE(11,4),XY(11,3)        
      COMMON /PLTDAT/ SKPPLT(2),REG(4),AXYMAX(14),SKPA(3),CNTCHR(2)     
      COMMON /RSTXXX/ CSTM(3,3),MIN(3),MAX(3),D(3),AVER(3)        
      EQUIVALENCE     (WORD,AWRD(1),IWRD,FWRD,DWRD)        
      DATA    NAME  / 4H  FI, 4HND  /        
      DATA    MM17P5, RDIST,  SQRT3 / .688975, 29., 1.732051/,        
     1        ORIG  / 4HORIG/, REGI / 4HREGI/, SCAL / 4HSCAL/,        
     2        HSET  / 3HSET /, VANT / 4HVANT/, POIN / 4HPOIN/        
      DATA    NMSG1 , MSG1  / 20,        
     1                4H(34X, 4H,45H, 4HAN A, 4HTTEM, 4HPT H, 4HAS B,   
     2                4HEEN , 4HMADE, 4H TO , 4HDEFI, 4HNE M, 4HORE ,   
     3                4HTHAN, 4H ,I2, 4H,17H, 4H DIS, 4HTINC, 4HT OR,   
     4                4HIGIN, 4HS)     /        
      DATA    NMSG3 , MSG3  / 21,        
     1                4H(25X, 4H,27H, 4HAN U, 4HNREC, 4HOGNI, 4HZABL,   
     2                4HE RE, 4HQUES, 4HT (,, 4H2A4,, 4H37H), 4H HAS,   
     3                4H BEE, 4HN SP, 4HECIF, 4HIED , 4HON A, 4H -FI,   
     4                4HND- , 4HCARD, 4H)   /        
      DATA    NMSG6 , MSG6  / 20,        
     1                4H(33X, 4H,71H, 4HMAXI, 4HMUM , 4HDEFO, 4HRMAT,   
     2                4HION , 4HCARD, 4H NEE, 4HDED , 4H- 5 , 4HPER ,   
     3                4HCENT, 4H OF , 4HMAXI, 4HMUM , 4HDIME, 4HNSIO,   
     4                4HN US, 4HED.)  /        
C        
      CALL RDMODX (PARM,MODE,WORD)        
      SET    = SETD        
      REGION = 0        
      REG(1) = 0.        
      REG(2) = 0.        
      REG(3) = 1.        
      REG(4) = 1.        
      RATIO  = 0.        
      NOGO   = 0        
      IF (MODE .LT. 0) GO TO 480        
C        
C     INTERPRET THE REQUESTS ON THE -FIND- CARD.        
C        
   10 IF (MODE .LE. 0) CALL RDMODE (*10,*20,*480,MODE,WORD)        
   20 CALL RDWORD (MODE,WORD)        
C        
C     IS AN ORIGIN TO BE FOUND        
C        
   30 IF (WORD .NE. ORIG) GO TO 90        
      IF (MODE .NE.    0) GO TO 10        
      ASSIGN 40 TO TRA        
      GO TO 400        
   40 IF (ORG .EQ. 0) GO TO 70        
      DO 50 J = 1,ORG        
      IF (ORIGIN(J) .EQ. IWRD) GO TO 80        
   50 CONTINUE        
      IF (ORG  .LT. NORG) GO TO 70        
      IF (PRNT .LT.    0) GO TO 60        
      ERR(1) = 1        
      ERR(2) = NORG        
      CALL WRTPRT (MERR,ERR,MSG1,NMSG1)        
   60 ORG = NORG        
      I   = ORG + 1        
      EDGE(I,1) = 0.0        
      EDGE(I,2) = 0.0        
      EDGE(I,3) = 1.0        
      EDGE(I,4) = 1.0        
   70 ORG = ORG + 1        
      ORIGIN(ORG) = IWRD        
      J   = ORG        
   80 FOR = J        
      GO TO 10        
C        
C     IS A REGION SPECIFIED        
C        
   90 IF (WORD .NE. REGI) GO TO 200        
      IF (MODE .NE.    0) GO TO 10        
      REGION = 1        
      ASSIGN 110 TO TRA        
      J = 0        
  100 J = J + 1        
      GO TO 440        
  110 REG(J) = AMIN1(1.,ABS(FWRD))        
      IF (J-4) 100,10,10        
C        
C     IS THE SCALE TO BE FOUND        
C        
  200 IF (WORD .NE. SCAL) GO TO 220        
      FSCALE = 1        
      IF (MODE .NE. 0) GO TO 10        
      ASSIGN 210 TO TRA        
      GO TO 440        
  210 RATIO = FWRD        
      GO TO 10        
C        
C     IS THERE A SET ON THE FIND CARD        
C        
  220 IF (WORD .NE. HSET) GO TO 300        
      IF (MODE .NE.    0) GO TO 10        
      ASSIGN 230 TO TRA        
      GO TO 400        
  230 DO 240 J = 1,NSETS        
      IF (IWRD .EQ. SETID(J)) GO TO 260        
  240 CONTINUE        
      WRITE  (NOUT,250) UWM,IWRD        
  250 FORMAT (A25,' 700, SET',I9,' REQUESTED ON FIND CARD HAS NOT BEEN',
     1       ' DEFINED. DEFAULT SET',I9,' USED')        
      NOGO = 1        
      GO TO 10        
  260 SET  = J        
      GO TO 10        
C        
C     IS THE VANTAGE POINT TO BE FOUND        
C        
  300 IF (WORD .NE. VANT) GO TO 320        
      IF (MODE .EQ. 0) CALL RDMODE (*10,*310,*480,MODE,WORD)        
  310 CALL RDWORD (MODE,WORD)        
      IF (WORD .NE. POIN) GO TO 30        
      FVP = 1        
      GO TO 10        
C        
C     UNRECOGNIZABLE OPTION ON THE FIND CARD        
C        
  320 IF (PRNT .LT. 0) GO TO 10        
      ERR(1) = 2        
      ERR(2) = AWRD(1)        
      ERR(3) = AWRD(2)        
      CALL WRTPRT (MERR,ERR,MSG3,NMSG3)        
      GO TO 10        
C        
C     READ AN INTEGER FROM THE FIND CARD        
C        
  400 CALL RDMODE (*410,*10,*480,MODE,WORD)        
  410 IF (MODE .EQ. -1) GO TO 430        
      IF (MODE .EQ. -4) GO TO 420        
      IWRD = FWRD        
      GO TO 430        
  420 IWRD = DWRD        
  430 GO TO TRA, (40,230)        
C        
C     READ A REAL NUMBER FROM THE FIND CARD        
C        
  440 CALL RDMODE (*450,*10,*480,MODE,WORD)        
  450 IF (MODE .EQ. -4) GO TO 460        
      IF (MODE .NE. -1) GO TO 470        
      FWRD = IWRD        
      GO TO 470        
  460 FWRD = DWRD        
  470 GO TO TRA, (110,210)        
C        
C     END OF THE FIND CARD        
C        
  480 IF (ORG .GT. 0) GO TO 485        
C        
C     ALLOW NO ORIGIN REQUEST ON FIRST FIND CARD        
C     ORIGIN ID IS ZERO        
C        
      ORG = 1        
      ORIGIN(1) = 0        
      REGION = 1        
  485 IF (FOR    .EQ. 0) GO TO 500        
      IF (REGION .EQ. 0) GO TO 490        
      EDGE(FOR,1) = REG(1)        
      EDGE(FOR,2) = REG(2)        
      EDGE(FOR,3) = REG(3)        
      EDGE(FOR,4) = REG(4)        
      GO TO 500        
  490 REG(1) = EDGE(FOR,1)        
      REG(2) = EDGE(FOR,2)        
      REG(3) = EDGE(FOR,3)        
      REG(4) = EDGE(FOR,4)        
  500 REG(1) = REG(1)*AXYMAX(1)        
      IF (REG(2) .NE. 0.) GO TO 510        
      REG(2) = 4.*CNTCHR(2)        
      GO TO 520        
  510 REG(2) = REG(2)*AXYMAX(2)        
  520 REG(3) = REG(3)*AXYMAX(1) - CNTCHR(1)*8.        
      REG(4) = REG(4)*AXYMAX(2) - CNTCHR(2)        
C        
C     CALCULATE THE ROTATION MATRIX + ROTATE THE CO-ORDINATES OF THE SET
C        
      CALL GOPEN (GPSET,X(BUF4),0)        
      I = 1        
      CALL FWDREC (*810,GPSET)        
      IF (SET .EQ. 1) GO TO 540        
      DO 530 I = 2,SET        
      CALL FWDREC (*810,GPSET)        
  530 CONTINUE        
C        
C     READ NGPSET        
C        
  540 CALL FREAD (GPSET,NGPSET,1,0)        
C        
C     CHECK CORE        
C        
      ICRQ = 3*NGPSET + NGP - BUF4 - BUFSIZ - 1        
      IF (ICRQ .GT. 0) GO TO 800        
      CALL FREAD (GPSET,X,NGP,0)        
      CALL CLOSE (GPSET,1)        
      CALL FNDSET (X,X(NGP+1),BUF1,0)        
      DO 550 I = 1,3        
      MIN(I) = +1.E+20        
  550 MAX(I) = -1.E+20        
      CALL PROCES (X(NGP+1))        
      IF (MAXDEF.NE.0.0 .OR. PRNT.GE.0) GO TO 560        
C        
C     DEFORMED PLOTS AND MAXDEF WAS NOT SPECIFIED        
C        
      ERR(1) = 0        
      CALL WRTPRT (MERR,ERR,MSG6,NMSG6)        
      MAXDEF = AMAX1(D(2),D(3))        
      IF (MAXDEF .LE. 0.0) MAXDEF = 1.0        
      MAXDEF = 0.05*MAXDEF        
  560 CONTINUE        
      GO TO (600,570,700), PRJECT        
C        
C     PERSPECTIVE PROJECTION (FIND VANTAGE POINT IF REQUESTED)        
C        
  570 DO 580 I = 1,3        
      MIN(I) = +1.E+20        
  580 MAX(I) = -1.E+20        
      CALL PERPEC (X(NGP+1),0)        
      FVP = 0        
C        
C     ORTHOGRAPHIC OR PERSPECTIVE PROJECTION        
C        
C     FIND SCALE FACTOR (IF REQUESTED).        
C        
  600 IF (FSCALE .EQ. 0) GO TO 630        
      A = D(2) + 2.*MAXDEF*SQRT3        
      IF (A .EQ. 0.0) GO TO 610        
      A = (REG(3)-REG(1))/A        
  610 B = D(3) + 2.*MAXDEF*SQRT3        
      IF (B .EQ. 0.0) GO TO 620        
      B = (REG(4)-REG(2))/B        
  620 SCALE = AMIN1(A,B)        
      IF (SCALE .LE. 0.) SCALE = AMAX1(A,B)        
      IF (SCALE .LE. 0.) SCALE = 1.        
      IF (RATIO .NE. 0.) SCALE = RATIO*SCALE        
C        
C     FIND ORIGIN -FOR- IF REQUESTED        
C        
  630 IF (FOR .EQ. 0) GO TO 830        
      XY(FOR,1) = AVER(2)*SCALE - (REG(1)+REG(3))/2.        
      XY(FOR,3) = AVER(3)*SCALE - (REG(2)+REG(4))/2.        
      GO TO 830        
C        
C     STEREO PROJECTION        
C        
C     FIND SCALE FACTORS (IF REQUESTED).        
C        
  700 IF (FSCALE .EQ. 0) GO TO 710        
      DIAM = SQRT(D(1)**2 + D(2)**2 + D(3)**2)        
      A = SQRT3*MAXDEF        
      IF (D(2)+A.GE.DIAM .OR. D(3)+A.GE.DIAM) DIAM = DIAM + MAXDEF      
      IF (DIAM .EQ. 0.0) DIAM = 1.E-5        
      OBJMOD = 10./DIAM        
      SCALE  = AMIN1(REG(3)-REG(1),REG(4)-REG(2))/MM17P5        
      IF (RATIO .NE. 0.) SCALE=RATIO*SCALE        
C        
C     FIND VANTAGE POINT (IF REQUESTED)        
C        
  710 CALL PERPEC (X(NGP+1),0)        
      FVP = 0        
C        
C     FIND ORIGIN -FOR- IF REQUESTED        
C        
      IF (FOR .EQ. 0) GO TO 830        
      IMSEP     = S0S*(RDIST-D0)/(2.*RDIST)        
      XY(FOR,1) = SCALE*(AVER(2)*OBJMOD-IMSEP) - (REG(1)+REG(3))/2.     
      XY(FOR,2) = SCALE*(AVER(2)*OBJMOD+IMSEP) - (REG(1)+REG(3))/2.     
      XY(FOR,3) = SCALE*(AVER(3)*OBJMOD)       - (REG(2)+REG(4))/2.     
      GO TO 830        
C        
  800 CALL MESAGE (-8,ICRQ,NAME)        
C        
  810 WRITE  (NOUT,820) UFM,SETID(SET)        
  820 FORMAT (A23,' 703, SET',I9,' REQUESTED ON FIND CARD NOT IN ',     
     1       'GPSETS FILE.')        
      NOGO = 1        
      CALL CLOSE (GPSET,1)        
      GO TO 840        
C        
  830 FSCALE = 0        
      FOR    = 0        
  840 IF (NOGO .NE. 0) CALL MESAGE (-37,0,NAME)        
      RETURN        
      END        
