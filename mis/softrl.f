      SUBROUTINE SOFTRL (NAME,ITEM,MCB)        
C        
C     UTILITY SUBROUTINE TO OBTAIN THE MATRIX TRAILER FOR A MATRIX      
C     STORED ON THE SOF        
C     STATUS OF THE SOF ITEM IS RETURNED IN WORD ONE OF THE MATRIX      
C     CONTROL BLOCK        
C        
C         1 NORMAL RETURN - THE TRAILER IS STORED IN WORDS 2 THRU 7     
C         2 ITEM WAS PESUDO WRITTEN        
C         3 ITEM DOES NOT EXIST        
C         4 SUBSTRUCTURE NAME DOES NOT EXIST        
C         5 ILLEGAL ITEM NAME        
C        
      EXTERNAL        ANDF,RSHIFT        
      INTEGER         ANDF,RSHIFT,BUF,BLKSIZ,NMSBR(2),MCB(7),NAME(2)    
      COMMON /MACHIN/ MACH,IHALF,JHALF        
      COMMON /SOF   / DITDUM(6),IO,IOPBN,IOLBN,IOMODE,IOPTR,IOSIND,     
     1                IOITCD,IOBLK        
      COMMON /SYS   / BLKSIZ        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      DATA    IRD   / 1/        
      DATA    NMSBR / 4HSOFT,4HRL  /        
C        
C        
C     CHECK IF ITEM IS ONE OF THE FOLLOWING ALLOWABLE NAMES.        
C     KMTX,MMTX,PVEC,POVE,UPRT,HORG,UVEC,QVEC,PAPP,POAP,LMTX        
C        
      CALL CHKOPN (NMSBR(1))        
      IOITCD = ITCODE(ITEM)        
      ITM = ITTYPE(ITEM)        
      IF (ITM .NE. 1) GO TO 1000        
C        
C     FIND SUBSTRUCTURE NAME AND MDI BLOCK        
C        
      CALL FDSUB (NAME,IOSIND)        
      IF (IOSIND .LT. 0) GO TO 1010        
      CALL FMDI (IOSIND,IMDI)        
C        
C     GET BLOCK NUMBER OF FIRST BLOCK        
C        
      IOPBN = ANDF(BUF(IMDI+IOITCD),JHALF)        
      IF (IOPBN .EQ.     0) GO TO 1020        
      IF (IOPBN .EQ. JHALF) GO TO 1030        
      IOLBN = 1        
C        
C     GET NEXT BLOCK IN CHAIN        
C        
   20 CALL FNXT (IOPBN,INXT)        
      IF (MOD(IOPBN,2) .EQ. 1) GO TO 30        
      NEXT = ANDF(RSHIFT(BUF(INXT),IHALF),JHALF)        
      GO TO 40        
   30 NEXT = ANDF(BUF(INXT),JHALF)        
   40 CONTINUE        
      IF (NEXT .EQ. 0) GO TO 50        
      IOPBN = NEXT        
      IOLBN = IOLBN + 1        
      GO TO 20        
C        
C     WE HAVE HIT END OF CHAIN - READ THE LAST BLOCK        
C        
   50 CALL SOFIO (IRD,IOPBN,BUF(IO-2))        
      I1 = IO - 2        
      I2 = I1 + BLKSIZ + 4        
C        
C     EXTRACT TRAILER FROM BLOCK        
C        
      DO 60 I = 1,6        
   60 MCB(I+1) = BUF(IO+BLKSIZ-6+I)        
      MCB(1  ) = 1        
      RETURN        
C        
C        
C     ERRORS        
C        
C     ILLEGAL ITEM        
C        
 1000 MCB(1) = 5        
      RETURN        
C        
C     SUBSTRUCTURE DOES NOT EXIST        
C        
 1010 MCB(1) = 4        
      RETURN        
C        
C     ITEM DOES NOT EXIST        
C        
 1020 MCB(1) = 3        
      RETURN        
C        
C     ITEM IS PESUDO WRITTEN        
C        
 1030 MCB(1) = 2        
      RETURN        
      END        
