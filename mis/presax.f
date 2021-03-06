      SUBROUTINE PRESAX (IHARM)        
C        
C     THIS ROUTINE APPLIES PRESSURE LOADS TO AXISYMMETRIC SHELL        
C        
      LOGICAL         PIEZ        
      INTEGER         FILE,SLT,ICARD(6),IORD(2),NAME(2)        
      REAL            CARD(6),GPCO(4,2)        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRAD,S4PISQ        
CZZ   COMMON /ZZSSA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /LOADX / LC,SLT,BGPDT,OLD        
      COMMON /SYSTEM/ KSYSTM(80)        
      EQUIVALENCE     (ICARD(1),CARD(1))        
      DATA    NAME  / 4HPRES,4HAX  /        
C        
C     DEFINITION OF VARIABLES        
C        
C     N        NUMBER OF CURRENT HARMONIC        
C     FILE     FILE NAME FOR ERROR MESAGES        
C     SLT      STATIC LOADS TABLE        
C     CARD     CARD IMAGE OF PRESAX CARD        
C     DEGRAD   CONVERSION FACTOR FOR DEGREES TO RADIANS        
C     IORD     ARRAY GIVING OPTIMUM ORDER FOR LOOKING UP POINTS IN BGPDT
C     OLD      CURRENT POSITION OF BGPDT        
C     GPCO     ARRAY HOLDING BGPDT DATA FOR EACH RING        
C     XL       DISTANCE  BETWEEN  RINGS        
C     SINSI    SIN  ANGLE BETWEEN RINGS        
C     COSSI    COS  ANGLE BETWEEN RINGS        
C     ISILA    SIL VALUE  OF CURRENT HARMONIC - RING A        
C     ISILB    SIL VALUE  OF CURRENT HARMONIC - RING B        
C     IHARM    SUBCASE  INDICATOR  1 = SINE  2 = COSINE        
C        
C        
C     BRING IN PRESAX CARD        
C        
      FILE = SLT        
      CALL READ (*910,*920,SLT,CARD(1),6,0,IFLAG)        
      N  = ICARD(6) + 1        
      XI = N - 1        
C        
C     CONVERT PHI1,PHI2 TO RADIANS        
C        
      CARD(4) = CARD(4)*DEGRAD        
      CARD(5) = CARD(5)*DEGRAD        
C        
C     PICK UP BGPDT DATA FOR RINGS        
C        
C     IF 1ST. RING IS NEGATIVE, THIS IS A SURFACE CHARGE LOAD IN A      
C     PIEZOELECTRIC PROBLEM        
C        
      PIEZ = .FALSE.        
      IF (KSYSTM(78).NE.1 .OR. ICARD(2).GT.0) GO TO 5        
      PIEZ = .TRUE.        
      ICARD(2) = -ICARD(2)        
    5 CONTINUE        
      CALL PERMUT (ICARD(2),IORD(1),2,OLD)        
      DO 10 I = 1,2        
      J = IORD(I) + 1        
      CALL FNDPNT (GPCO(1,J-1),ICARD(J) )        
   10 CONTINUE        
      XL = SQRT((GPCO(2,2) - GPCO(2,1))**2 + (GPCO(3,2) - GPCO(3,1))**2)
      IF (XL .EQ. 0.0) CALL MESAGE (-30,26,-1)        
      SINSI = (GPCO(2,2) - GPCO(2,1))/XL        
      COSSI = (GPCO(3,2) - GPCO(3,1))/XL        
      CALL FNDSIL (ICARD(2))        
      ISILA = ICARD(2)        
      CALL FNDSIL (ICARD(3))        
      ISILB = ICARD(3)        
C        
C     APPLY LOADS TO ALL HARMONICS        
C        
      IF (N .NE. 1) GO TO 20        
C        
C     APPLY LOADS TO ZERO HARMONIC - COSINE SUBCASE ONLY        
C        
      IF (IHARM .NE. 2) GO TO 90        
      PR = (CARD(5) - CARD(4))        
      GO TO 30        
C        
C     I .GT. 1  APPLY  SINE AND COSINE FACTORS        
C        
   20 IF (IHARM .EQ. 1) GO TO 40        
C        
C     COSINE CASE        
C        
      PR = (SIN(XI*CARD(5)) - SIN(XI*CARD(4)))/XI        
      GO TO 30        
C        
C     SINE CASE        
C        
   40 PR = -(COS(XI*CARD(5)) - COS(XI*CARD(4)))/XI        
C        
C     APPLY LOADS        
C        
   30 PR = PR*CARD(1)*XL        
      PRPIEZ = PR        
      PRC = PR*COSSI        
      PRS =-PR*SINSI        
      PR  = GPCO(2,1)/3.0 + GPCO(2,2)/6.0        
      IF (.NOT.PIEZ) GO TO 35        
C        
C     PIEZOELECTRIC        
C        
      PRC = 0.        
      PRS = 0.        
   35 CONTINUE        
      Z(ISILA  ) = Z(ISILA  ) + PRC*PR        
      Z(ISILA+2) = Z(ISILA+2) + PRS*PR        
      IF (PIEZ)  Z(ISILA+3) = Z(ISILA+3) + PRPIEZ*PR        
      PR = GPCO(2,2)/3.0 + GPCO(2,1)/6.0        
      Z(ISILB  ) = Z(ISILB  ) + PRC*PR        
      Z(ISILB+2) = Z(ISILB+2) + PRS*PR        
      IF (PIEZ)  Z(ISILB+3) = Z(ISILB+3) + PRPIEZ*PR        
   90 RETURN        
C        
C     FILE ERRORS        
C        
  910 IP1 = -2        
  911 CALL MESAGE (IP1,FILE,NAME(1))        
  920 IP1 = -3        
      GO TO 911        
      END        
