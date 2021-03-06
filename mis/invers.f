      SUBROUTINE INVERS (NDIM,A,N,B,M,DETERM,ISING,INDEX)        
C        
C     INVERSE, OR LINEAR EQUATIONS SOLVER        
C        
C     NDIM IS THE ACTUAL SIZE OF A IN CALLING PROGRAM. E.G. A(NDIM,NDIM)
C     A IS SQUARE MATRIX TO BE INVERTED.        
C     N IS SIZE OF UPPER LEFT PORTION BEING INVERTED.        
C     B IS COLUMN OF CONSTANTS (OPTIONAL INPUT). SUPPLY SPACE B(NDIM,1) 
C     M IS THE NUMBER OF COLUMNS OF CONSTANTS        
C     DETERM RETURNS THE VALUE OF DETERMINANT IF NON-SINGULAR        
C     ISING RETURNS 2, IF MATRIX A(N,N) IS SINGULAR        
C                   1, IF MATRIX A(N,N) IS NON-SINGULAR        
C     (IF ISING IS SET TO .LT. 0 UPON INPUT, DETERM IS NOT CALCULATED)  
C     INVERSE RETURNS  IN A        
C     SOLUTION VECTORS RETURN IN B        
C     INDEX IS WORKING STORAGE (N,3)        
C        
      DIMENSION       A(NDIM,1),   B(NDIM,1), INDEX(N,3)        
      COMMON /MACHIN/ MACH        
      EQUIVALENCE     (IROW,JROW), (ICOLUM,JCOLUM), (AMAX, T, SWAP)     
      DATA    EPSI  / 1.0E-30 /        
C        
C     INITIALIZE        
C        
      IF (MACH  .EQ. 5) EPSI = 1.E-18        
      DETERM = 1.0        
      IF (ISING .LT. 0) DETERM = 0.0        
      DO 10 J = 1,N        
   10 INDEX(J,3) = 0        
      DO 130 I = 1,N        
C        
C     SEARCH FOR PIVOT        
C        
      AMAX = 0.0        
      DO 40 J = 1,N        
      IF (INDEX(J,3) .EQ. 1) GO TO 40        
      DO 30 K = 1,N        
      IF (INDEX(K,3) - 1) 20,30,190        
   20 IF (ABS(A(J,K)) .LE. AMAX) GO TO 30        
      IROW   = J        
      ICOLUM = K        
      AMAX   = ABS(A(J,K))        
   30 CONTINUE        
   40 CONTINUE        
      INDEX(ICOLUM,3) = INDEX(ICOLUM,3) + 1        
      INDEX(I,1) = IROW        
      INDEX(I,2) = ICOLUM        
C        
C     INTERCHANGE ROWS TO PUT PIVOT ELEMENT ON DIAGONAL        
C        
      IF (IROW .EQ. ICOLUM) GO TO 70        
      DETERM = -DETERM        
      DO 50 L = 1,N        
      SWAP = A(IROW,L)        
      A(IROW,L  ) = A(ICOLUM,L)        
   50 A(ICOLUM,L) = SWAP        
      IF (M .LE. 0) GO TO 70        
      DO 60 L = 1,M        
      SWAP = B(IROW,L)        
      B(IROW,L  ) = B(ICOLUM,L)        
   60 B(ICOLUM,L) = SWAP        
C        
C     DIVIDE PIVOT ROW BY PIVOT ELEMENT        
C        
   70 PIVOT  = A(ICOLUM,ICOLUM)        
      DETERM = DETERM*PIVOT        
      IF (ABS(PIVOT) .LT. EPSI) GO TO 190        
      A(ICOLUM,ICOLUM) = 1.0        
      DO 80 L = 1,N        
   80 A(ICOLUM,L) = A(ICOLUM,L)/PIVOT        
      IF (M .LE. 0) GO TO 100        
      DO 90 L=1,M        
   90 B(ICOLUM,L) = B(ICOLUM,L)/PIVOT        
C        
C     REDUCE NON PIVOT ROWS        
C        
  100 DO 130 L1 = 1,N        
      IF (L1 .EQ. ICOLUM) GO TO 130        
      T = A(L1,ICOLUM)        
      A(L1,ICOLUM) = 0.0        
      IF (ABS(T) .LT. EPSI) GO TO 130        
      DO 110 L = 1,N        
  110 A(L1,L) = A(L1,L) - A(ICOLUM,L)*T        
      IF (M .LE. 0) GO TO 130        
      DO 120 L = 1,M        
  120 B(L1,L) = B(L1,L) - B(ICOLUM,L)*T        
  130 CONTINUE        
C        
C     INTERCHANGE COLUMNS        
C        
      DO 150 I = 1,N        
      L = N + 1 - I        
      IF (INDEX(L,1) .EQ. INDEX(L,2)) GO TO 150        
      JROW   = INDEX(L,1)        
      JCOLUM = INDEX(L,2)        
      DO 140 K = 1,N        
      SWAP = A(K,JROW)        
      A(K,JROW  ) = A(K,JCOLUM)        
      A(K,JCOLUM) = SWAP        
  140 CONTINUE        
  150 CONTINUE        
      DO 170 K = 1,N        
      IF (INDEX(K,3) .EQ. 1) GO TO 160        
      ISING = 2        
      GO TO 180        
  160 CONTINUE        
  170 CONTINUE        
      ISING = 1        
  180 RETURN        
  190 ISING = 2        
      RETURN        
      END        
