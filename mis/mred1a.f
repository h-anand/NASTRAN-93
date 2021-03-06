      SUBROUTINE MRED1A (MODE)        
C        
C     THIS SUBROUTINE PROCESSES THE BDYC DATA FOR THE FIXED        
C     IDENTIFICATION SET (FIXSET) AND THE BOUNDARY IDENTIFICATION SET   
C     (BNDSET) FOR THE MRED1 MODULE.        
C        
C     INPUT DATA        
C     GINO - GEOM4    - BDYC DATA        
C     MODE            - PROCESSING OPERATION FLAG        
C                     = 1, PROCESS FIXED ID SET        
C                     = 2, PROCESS BOUNDARY ID SET        
C        
C     OUTPUT DATA        
C     GINO - USETX    - S,R,B DEGREES OF FREEDOM        
C        
C     PARAMETERS        
C     INPUT  - GBUF1  - GINO BUFFER        
C              KORLEN - CORE LENGTH        
C              BNDSET - BOUNDARY SET IDENTIFICATION NUMBER        
C              FIXSET - FIXED SET IDENTIFICATION NUMBER        
C              IO     - OUTPUT OPTION FLAG        
C              KORUST - STARTING ADDRESS OF USET ARRAY        
C              NCSUBS - NUMBER OF CONTRIBUTING SUBSTRUCTURES        
C              NAMEBS - BEGINNING ADDRESS OF BASIC SUBSTRUCTURES NAMES  
C              KBDYC  - BEGINNING ADDRESS OF BDYC DATA        
C              NBDYCC - NUMBER OF BDYC CARDS        
C              USETL  - NUMBER OF WORDS IN USET ARRAY        
C     OUTPUT - NOUS   - FIXED POINTS FLAG        
C                       .GE.  0, FIXED POINTS DEFINED        
C                       .EQ. -1, NO FIXED POINTS DEFINED        
C              DRY    - MODULE OPERATION FLAG        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         PONLY        
      DIMENSION       ARRAY(3),BDYC(2),MODNAM(2)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / OLDNAM(2),DRY,IDUM1,NOUS,SKIPM,IDUM2(3),GBUF1,    
     1                IDUM3(4),KORLEN,IDUM4(2),BNDSET,FIXSET,IDUM5,IO,  
     2                IDUM6(6),NCSUBS,NAMEBS,IDUM7(3),KBDYC,NBDYCC,     
     3                USETL,KORUST,IDUM14(5),PONLY        
CZZ   COMMON /ZZMRD1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ IDUM8,IPRNTR,IDUM9(6),NLPP,IDUM10(2),LINE        
      COMMON /TWO   / ITWO(32)        
      COMMON /BITPOS/ IDUM11(5),UL,UA,UF,IDUM12,UN,IDUM13(11),UI        
      DATA    GEOM4 , BDYC  /102,910,9/        
      DATA    MODNAM/ 4HMRED,4H1A     /        
C        
C     TEST PROCESSING MODE FLAG        
C        
      IF (MODE .EQ. 2) GO TO 10        
C        
C     TEST FIXED SET ID FLAG AND SET FIXED INDEX        
C        
      IF (FIXSET.EQ.0 .OR. SKIPM.EQ.-1) GO TO 260        
      SETID  = FIXSET        
      ISHIFT = 10        
      GO TO 20        
C        
C     SET BOUNDARY INDEX        
C        
   10 IF (BNDSET .EQ. 0) GO TO 240        
      SETID  = BNDSET        
      ISHIFT = 1        
C        
C     ALLOCATE USET ARRAY AND TEST OPEN CORE LENGTH        
C        
      IF (NOUS .EQ. 1) GO TO 40        
   20 KBDYC = KORUST + USETL        
      IF (KBDYC .GE. KORLEN) GO TO 200        
C        
C     TURN UL, UA, UF, UN, AND UI BITS ON IN USET ARRAY        
C        
      IBITS = ITWO(UL) + ITWO(UA) + ITWO(UF) + ITWO(UN) + ITWO(UI)      
      DO 30 I = 1,USETL        
   30 Z(KORUST+I-1) = IBITS        
C        
C     READ BOUNDARY SET (BDYC) BULK DATA FOR REQUESTED FIXED SET        
C     ID (FIXSET) OR BOUNDARY SET ID (BNDSET)        
C        
   40 IFILE = GEOM4        
      CALL PRELOC (*170,Z(GBUF1),GEOM4)        
      CALL LOCATE (*230,Z(GBUF1),BDYC,IFLAG)        
   50 CALL READ (*180,*230,GEOM4,ARRAY,1,0,IFLAG)        
      IF (ARRAY(1) .EQ. SETID) GO TO 70        
   60 CALL READ (*180,*190,GEOM4,ARRAY,3,0,IFLAG)        
      IF (ARRAY(3) .EQ. -1) GO TO 50        
      GO TO 60        
C        
C     SET ID FOUND, STORE AT Z(KBDYC+NWDS)        
C        
   70 NWDS = 0        
   80 CALL READ (*180,*190,GEOM4,Z(KBDYC+NWDS),3,0,IFLAG)        
      IF (Z(KBDYC+NWDS+2) .EQ. -1) GO TO 110        
C        
C     CHECK THAT SUBSTRUCTURE IS A COMPONENT OF STRUCTURE BEING        
C     REDUCED        
C        
      DO 90 I = 1,NCSUBS        
      J = 2*(I-1)        
      IF ((Z(NAMEBS+J).EQ.Z(KBDYC+NWDS)) .AND. (Z(NAMEBS+J+1).EQ.       
     1     Z(KBDYC+NWDS+1))) GO TO 100        
   90 CONTINUE        
C        
C     SUBSTRUCTURE IS NOT A COMPONENT        
C        
      IF (MODE .EQ. 1) WRITE (IPRNTR,900) UWM,Z(KBDYC+NWDS),        
     1                                    Z(KBDYC+NWDS+1)        
      IF (MODE .EQ. 2) WRITE (IPRNTR,901) UWM,Z(KBDYC+NWDS),        
     1                                    Z(KBDYC+NWDS+1)        
      DRY = -2        
      GO TO 80        
C        
C     SAVE BASIC SUBSTRUCTURE INDEX        
C        
  100 Z(KBDYC+NWDS+3) = I        
      NWDS = NWDS + 4        
      IF (KBDYC+NWDS .GE. KORLEN) GO TO 200        
      GO TO 80        
C        
C     CHECK FOR DUPLICATE BDYC SUBSTRUCTURE NAMES        
C        
  110 NWDS = NWDS/4        
      IF (NWDS .LE. 1) GO TO 125        
      I = NWDS - 1        
      DO 120 J = 1,I        
      K  = J + 1        
      II = 4*(J-1)        
      DO 120 L = K,NWDS        
      LL = 4*(L-1)        
      IF (Z(KBDYC+II  ) .NE. Z(KBDYC+LL  )) GO TO 120        
      IF (Z(KBDYC+II+1) .NE. Z(KBDYC+LL+1)) GO TO 120        
      WRITE (IPRNTR,902) UFM,OLDNAM,ARRAY(1)        
      DRY = -2        
  120 CONTINUE        
C        
C     TEST OUTPUT OPTION        
C        
  125 CONTINUE        
      IF (ANDF(RSHIFT(IO,ISHIFT),1) .EQ. 0) GO TO 150        
      IF (NWDS .EQ. 0) GO TO 150        
      LINE = NLPP + 1        
      DO 140 I = 1,NWDS        
      IF (LINE .LE. NLPP) GO TO 130        
      CALL PAGE1        
      IF (MODE .EQ. 1) WRITE (IPRNTR,903) FIXSET        
      IF (MODE .EQ. 2) WRITE (IPRNTR,904) BNDSET        
      LINE = LINE + 7        
  130 J = 4*(I-1)        
      IF (MODE .EQ. 1) WRITE (IPRNTR,905) Z(KBDYC+J),Z(KBDYC+J+1),      
     1    Z(KBDYC+J+2)        
      IF (MODE .EQ. 2) WRITE (IPRNTR,906) Z(KBDYC+J),Z(KBDYC+J+1),      
     1    Z(KBDYC+J+2)        
  140 LINE = LINE + 1        
C        
C     SORT BDYC DATA ON SET ID        
C        
  150 NBDYCC = NWDS        
      IF (NBDYCC .LE. 1) GO TO 270        
      NWDS = 4*NBDYCC        
      CALL SORT (0,0,4,3,Z(KBDYC),NWDS)        
      GO TO 270        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  170 IMSG = -1        
      GO TO 220        
  180 IMSG = -2        
      GO TO 210        
  190 IMSG = -3        
      GO TO 210        
  200 IMSG = -8        
      IFILE = 0        
  210 CALL CLOSE (GEOM4,1)        
  220 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  230 IF (MODE .EQ. 1) WRITE (IPRNTR,907) UWM,FIXSET        
      IF (MODE .EQ. 2) WRITE (IPRNTR,908) UWM,BNDSET        
      DRY = -1        
      GO TO 250        
  240 IF (PONLY) GO TO 280        
      WRITE (IPRNTR,909) UFM        
      DRY = -2        
  250 CALL SOFCLS        
      CALL CLOSE (GEOM4,1)        
      RETURN        
C        
C     NO FIXED ID SET DATA        
C        
  260 NOUS = -1        
C        
C     END OF PROCESSING        
C        
  270 CALL CLOSE (GEOM4,1)        
  280 CONTINUE        
C        
  900 FORMAT (A25,' 6622, A FIXED SET HAS BEEN SPECIFIED FOR ',2A4,     
     1       ', BUT IT IS NOT A COMPONENT OF',/32X,'THE PSEUDOSTRUCTURE'
     2,      ' BEING PROCESSED.  THE FIXED SET WILL BE IGNORED.')       
  901 FORMAT (A25,' 6604, A BOUNDARY SET HAS BEEN SPECIFIED FOR ',2A4,  
     1       ', BUT IT IS NOT A COMPONENT OF',/32X,'THE PSEUDOSTRUCTURE'
     2,      ' BEING PROCESSED.  THE BOUNDARY SET WILL BE IGNORED.')    
  902 FORMAT (A23,' 6623, SUBSTRUCTURE ',2A4,        
     1       ' HAS DUPLICATE NAMES IN BDYC DATA SET ',I8,1H.)        
  903 FORMAT (1H0,43X,'SUMMARY OF COMBINED FIXED SET NUMBER ',I8, //57X,
     1       'BASIC      FIXED', /54X,'SUBSTRUCTURE  SET ID', /58X,     
     2       'NAME      NUMBER',/)        
  904 FORMAT (1H0,43X,'SUMMARY OF COMBINED BOUNDARY SET NUMBER ',I8,    
     1       //57X,'BASIC      BOUNDARY', /54X,'SUBSTRUCTURE   SET ID', 
     2       /58X,'NAME       NUMBER',/)        
  905 FORMAT (56X,2A4,3X,I8)        
  906 FORMAT (56X,2A4,4X,I8)        
  907 FORMAT (A25,' 6621, FIXED SET',I9,' SPECIFIED IN CASE CONTROL ',  
     1       'HAS NOT BEEN DEFINED BY BULK DATA.')        
  908 FORMAT (A25,' 6606, BOUNDARY SET',I9,' SPECIFIED IN CASE CONTROL',
     1       ' HAS NOT BEEN DEFINED BY BULK DATA.')        
  909 FORMAT (A23,' 6603, A BOUNDARY SET MUST BE SPECIFIED FOR A REDUCE'
     1,      ' OPERATION.')        
C        
      RETURN        
      END        
