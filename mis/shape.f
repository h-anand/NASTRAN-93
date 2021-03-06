      SUBROUTINE SHAPE (*,GPLST,X,U,PEN,DEFORM,IOPT,IPTL,LIPLT,OPCOR)   
C        
C     IOPT CONTROLS THIS ROUTINE        
C     IOPT .LT. 0        
C       THE LINEL ARRAY WAS NOT CREATED.  UNIQUE LINES ARE NOT DRAWN.   
C     IOPT .GE. 0        
C       THE LIPLT ARRAY HAS CONNECTION DATA TO MAKE UNIQUE LINES. SUPLT 
C       WILL CREATE THE LINES.  IPTR IS ONE OF THE PARAMETERS.        
C        
C     REVISED 10/1990 BY G.CHAN/UNISYS, TO INCLUDE BAR, TRIA3 AND QUAE4 
C     OFFSET (PEDGE = 3)        
C        
      INTEGER         GPLST(1),PEN,DEFORM,LIPLT(1),ETYP,ECT,NAME(2),GP, 
     1                ELID,OPCOR,TE,BR,T3,Q4,OFFSET,PEDGE        
      REAL            X(3,1),U(2,1),OFF(6)        
      COMMON /BLANK / NGP,SKP1(9),SKP2(2),ECT,SKP21(7),MERR        
      COMMON /DRWDAT/ SKP15(15),PEDGE        
      DATA    TE,BR , T3,Q4  / 2HTE, 2HBR, 2HT3, 2HQ4 /        
      DATA    NAME  / 4HSHAP,1HE/        
C        
      CALL LINE (0,0,0,0,0,-1)        
      IF (IOPT .GE. 0) GO TO 120        
   10 CALL READ (*140,*130,ECT,ETYP,1,0,I)        
      OFFSET = 0        
      IF (ETYP .EQ. BR) OFFSET = 6        
      IF (ETYP.EQ.T3 .OR. ETYP.EQ.Q4) OFFSET = 1        
      CALL FREAD (ECT,I,1,0)        
      NGPEL = IABS(I)        
      IF (ETYP.NE.TE .AND. NGPEL.LT.5) GO TO 30        
C        
C     NOT A SIMPLE ELEMENT        
C        
   20 LGPEL = NGPEL        
      LTYP  = ETYP        
      CALL LINEL (LIPLT,LTYP,OPCOR,LGPEL,X,PEN,DEFORM,GPLST)        
      L = IABS(LTYP)        
      IF (L-1) 10,115,70        
C        
   30 L = NGPEL + 1        
      IF (NGPEL.LE.2 .OR. I.LT.0) L = NGPEL        
      LTYP = 10000        
      M = 1        
   40 CALL FREAD (ECT,ELID,1,0)        
      IF (ELID .LE. 0) GO TO 10        
      CALL FREAD (ECT,LID,1,0)        
      CALL FREAD (ECT,LIPLT,NGPEL,0)        
      IF (L .NE. NGPEL) LIPLT(L) = LIPLT(1)        
C        
      IF (OFFSET .NE. 0) CALL FREAD (ECT,OFF,OFFSET,0)        
      IF (OFFSET.EQ.0 .OR. DEFORM.NE.0) GO TO 70        
C        
C     IF THIS IS A BAR, TRIA3 OR QUAD4 ELEMENTS READ IN THE OFFSET      
C     NO SCALE FACTOR APPLIES TO OFFSET HERE        
C        
      IF (OFFSET .NE. 6) GO TO 50        
C        
C     BAR OFFSET        
C        
      OFF(1) = 0.707*SQRT(OFF(1)**2 + OFF(2)**2 + OFF(3)**2)        
      OFF(2) = 0.707*SQRT(OFF(4)**2 + OFF(5)**2 + OFF(6)**2)        
      OFF(3) = OFF(1)        
      GO TO 70        
C        
C     TRIA3 AND QUAD4 OFFSET        
C        
   50 OFF(1) = 0.707*OFF(1)        
      DO 60 I = 2,5        
   60 OFF(I) = OFF(1)        
C        
C     WRITE THE LINES.  0 FOR SIL MEANS NO LINES DRAWN        
C        
   70 J = 0        
      DO 110 I = 1,L        
      IF (J .EQ. 0) GO TO 80        
      X1 = X2        
      Y1 = Y2        
   80 GP = LIPLT(I)        
      IF (GP .EQ. 0) GO TO 110        
      GP = IABS(GPLST(GP))        
      IF (DEFORM .NE. 0) GO TO 90        
      X2 = X(2,GP)        
      Y2 = X(3,GP)        
      IF (OFFSET .EQ. 0) GO TO 100        
C        
C     IF OFFSET IS PRESENT, ADD ARBITRARY AN OFFSET LENGTH TO X2 AND Y2.
C     SINCE THE OFFSET LENGTH IS SO TINY, ITS TRUE DIRECTION IS NOT OF  
C     VITAL CONCERNS. THE IDEA HERE IS THAT BIG OFFSET WILL SHOW IN THE 
C     PLOT IF ORIGINAL DATA CONTAINS ERRONEOUS AND BIG OFFSET VALUE(S). 
C        
C     IF OFFSET IS ADDED IN SAME DIRECTION AS THE PLOTTED LINE, ROTATE  
C     THE OFFSET LENGTH BY 90 DEGREE        
C        
      X2 = X2 + OFF(I)        
      XY = XY + OFF(I)        
      IF (ABS((X2-X1)-(Y2-Y1)) .LT. 0.01) X2 = X2 - 2.*OFF(I)        
      GO TO 100        
   90 X2 = U(1,GP)        
      Y2 = U(2,GP)        
  100 IF (J.EQ.0 .OR. J.EQ.GP) GO TO 110        
      CALL LINE (X1,Y1,X2,Y2,PEN,0)        
  110 J = GP        
C        
  115 IF (L-LTYP) 40,10,20        
C        
C        
  120 IF (PEDGE .EQ. 3) GO TO 130        
      CALL SUPLT (LIPLT(1),LIPLT(IPTL+1),X,U,GPLST,PEN,DEFORM)        
  130 CALL LINE (0,0,0,0,0,1)        
      IF (IOPT .LT. 0) CALL BCKREC (ECT)        
      GO TO 150        
C        
C     ILLEGAL EOF        
C        
  140 CALL MESAGE (-2,ECT,NAME)        
  150 IF (PEDGE .EQ. 3) RETURN 1        
      RETURN        
      END        
