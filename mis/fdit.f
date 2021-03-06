      SUBROUTINE FDIT (I,K)        
C        
C     FETCHES FROM THE RANDOM ACCESS STORAGE DEVICE THE BLOCK OF THE    
C     DIT CONTAINING THE ITH SUBSTRUCTURE NAME, AND STORES IT IN THE    
C     ARRAY BUF STARTING AT LOCATION (DIT+1) AND EXTENDING TO LOCATION  
C     (DIT+BLKSIZ).  THE OUTPUT K INDICATES THAT THE SUBSTRUCTURE HAS   
C     THE KTH ENTRY IN BUF.        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         DITUP,NXTUP,NEWBLK        
      INTEGER         BUF,DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                BLKSIZ,DIRSIZ,ANDF,RSHIFT,NMSBR(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                IODUM(8),MDIDUM(4),        
     2                NXT,NXTPBN,NXTLBN,NXTTSZ,NXTFSZ(10),NXTCUR,       
     3                DITUP,MDIUP,NXTUP,NXTRST        
      COMMON /SYS   / BLKSIZ,DIRSIZ        
      COMMON /SYSTEM/ NBUFF,NOUT        
      COMMON /MACHIN/ MACH,IHALF,JHALF        
      DATA    IRD   , IWRT  / 1,2   /        
      DATA    IEMPTY/ 4H    /        
      DATA    INDSBR/ 5     /, NMSBR /4HFDIT,4H    /        
C        
      CALL CHKOPN (NMSBR(1))        
C        
C     NDIR IS THE NUMBER OF SUBSTRUCTURE NAMES IN ONE BLOCK OF THE DIT  
C        
      NDIR = BLKSIZ/2        
C        
C     COMPUTE THE LOGICAL BLOCK NUMBER, AND THE WORD NUMBER WITHIN      
C     BUF IN WHICH THE ITH SUBSTRUCTURE NAME IS STORED.  STORE THE BLOCK
C     NUMBER IN IBLOCK, AND THE WORD NUMBER IN K.        
C        
      IBLOCK = I/NDIR        
      IF (I .EQ. IBLOCK*NDIR) GO TO 10        
      IBLOCK = IBLOCK + 1        
   10 K = 2*(I-(IBLOCK-1)*NDIR) - 1 + DIT        
      IF (DITLBN .EQ. IBLOCK) RETURN        
C        
C     THE DESIRED DIT BLOCK IS NOT PRESENTLY IN CORE, MUST THEREFORE    
C     FETCH IT.        
C        
      NEWBLK = .FALSE.        
C        
C     FIND THE PHYSICAL BLOCK NUMBER OF THE BLOCK ON WHICH THE LOGICAL  
C     BLOCK IBLOCK IS STORED.        
C        
      J = DITBL        
      ICOUNT = 1        
   30 IF (ICOUNT .EQ. IBLOCK) GO TO 40        
      ICOUNT = ICOUNT + 1        
      CALL FNXT (J,INXT)        
      IF (MOD(J,2) .EQ. 1) GO TO 33        
      IBL = RSHIFT(BUF(INXT),IHALF)        
      GO TO 36        
   33 IBL = ANDF(BUF(INXT),JHALF)        
   36 IF (IBL .EQ. 0) GO TO 70        
      J = IBL        
      GO TO 30        
   40 IF (DITPBN .EQ. 0) GO TO 43        
C        
C     THE IN CORE BLOCK SHARED BY THE DIT AND THE ARRAY NXT IS NOW      
C     OCCUPIED BY THE DIT.  WRITE IT OUT IF IT HAS BEEN UPDATED.        
C        
      IF (.NOT.DITUP) GO TO 50        
      CALL SOFIO (IWRT,DITPBN,BUF(DIT-2))        
      GO TO 50        
   43 IF (NXTPBN .EQ. 0) GO TO 50        
C        
C     THE IN CORE BLOCK SHARED BY THE DIT AND THE ARRAY NXT IS NOW      
C     OCCUPIED BY NXT.  WRITE OUT NXT IF IT HAS BEEN UPDATED.        
C        
      IF (.NOT.NXTUP) GO TO 46        
      CALL SOFIO (IWRT,NXTPBN,BUF(NXT-2))        
      NXTUP  = .FALSE.        
   46 NXTPBN = 0        
      NXTLBN = 0        
C        
C     READ THE DESIRED DIT BLOCK INTO CORE.        
C        
   50 DITPBN = J        
      DITLBN = IBLOCK        
      IF (NEWBLK) GO TO 60        
      CALL SOFIO (IRD,J,BUF(DIT-2))        
      RETURN        
C        
   60 ISTART = DIT + 1        
      IEND   = DIT + BLKSIZ        
      DO 65 LL = ISTART,IEND        
      BUF(LL) = IEMPTY        
   65 CONTINUE        
      RETURN        
C        
C     WE NEED A FREE BLOCK FOR THE DIT.        
C        
   70 CALL GETBLK (J,IBL)        
      IF (IBL .EQ. -1) GO TO 80        
      NEWBLK = .TRUE.        
      J = IBL        
      IF (ICOUNT .EQ. IBLOCK) GO TO 40        
C        
C     ERROR MESSAGES.        
C        
      CALL ERRMKN (INDSBR,7)        
   80 WRITE  (NOUT,85) UFM        
   85 FORMAT (A23,' 6223, SUBROUTINE FDIT - THERE ARE NO MORE FREE ',   
     1       'BLOCKS AVAILABLE ON THE SOF')        
      CALL SOFCLS        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
