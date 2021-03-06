      SUBROUTINE XREAD (*,BUFX)        
C        
C     THIS ROUTINE MAKES FREE-FIELD INPUT PACKAGE (HANDLED BY FFREAD)   
C     COMPLETELY MACHINE INDEPENDENT.        
C        
C     IF THE XSORT FLAG IN /XECHOX/ IS TURNED ON (XSORT=1), THIS ROUTINE
C     WILL ALSO PREPARES THE NECESSARY GROUND WORK SO THAT THE INPUT    
C     CARDS CAN BE SORTED EFFICIENTLY IN XSORT2 ROUTINE. ALL FIELDS IN  
C     THE INPUT CARDS ARE ALSO LEFT-ADJUSTED FOR PRINTING.        
C        
C     WRITTEN BY G.CHAN/UNISYS.   OCT. 1987        
C     LAST REVISED, 1/1990, IMPROVED EFFICIENCY BY REDUCING CHARACTER   
C     OPERATIONS (VERY IMPORTANT FOR CDC MACHINE)        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         RSHIFT,COMPLF        
      LOGICAL          DOUBLE,BCD2,BCD3,ALPHA,NUMRIC        
      INTEGER          BUFX(20),SUB(2)        
      INTEGER          CARD1(80),KHR1(43),BLANK1,DOLLR1,SLASH1,STAR1,   
     1                 PLUS1,MINUS1,ZERO1,POINT1,E1,D1,J1        
      CHARACTER*1      KARD1(80),KHRK(43),BLANKK,EQU1        
      CHARACTER*8      CARD8(10),CARD81,BLANK8,SLASH8,END8(3),NAME8(15) 
      CHARACTER*23     UFM*23,KHR43*43,CARD80*80        
      COMMON /XMSSG /  UFM        
      COMMON /XECHOX/  DUMMY,ECHOU,OSOP(2),XSORT,WASFF,DUM,F3LONG,LARGE 
      COMMON /XSORTX/  IBUF(4),TABLE(255)        
      COMMON /SYSTEM/  BUFSZ,NOUT,NOGO        
      COMMON /MACHIN/  MACH        
      EQUIVALENCE      (KARD1(1),CARD8(1), CARD80 ,CARD81  ) ,        
     1                 (BLANK1,KHR1( 1)) , (KHR43 ,KHRK( 1)) ,        
     2                 (ZERO1 ,KHR1( 2)) , (D1    ,KHR1(15)) ,        
     3                 (E1    ,KHR1(16)) , (SLASH1,KHR1(38)) ,        
     4                 (DOLLR1,KHR1(39)) , (STAR1 ,KHR1(40)) ,        
     5                 (PLUS1 ,KHR1(41)) , (MINUS1,KHR1(42)) ,        
     6                 (POINT1,KHR1(43))        
      DATA    BLANK8 , SLASH8 ,  BLANK4  , EQUAL4 , SUB            /    
     1        '    ' , '/   ' ,  4H      , 4H==== , 4HXREA,4HD     /    
      DATA    NNAME /  15 /   ,  NAME8                             /    
     1        'SPC1 ', 'SPCS ', 'TICS '  , 'MPCS ','MPCAX', 'RELES',    
     2        'GTRAN','FLUTTER','BDYC '  , 'SPCSD','SPCS1','RANDPS',    
     3       'DAREAS','DELAYS', 'DPHASES'                          /    
      DATA    END8  /  'ENDDATA ','ENDATA ','END DATA'/, DERR / -1 /    
C        
      DATA    KHR43 /' 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ/$*+-.' /    
C                      2 4 6 8 1 2 4 6 8 2 2 4 6 8 3 2 4 6 8 4 2        
C                              0         0         0         0        
      DATA    N7, N1, N2,      N3,                       N4, N5,N6 /    
     1        44,  1,  2,      11,                       37, 41,43 /    
      DATA    PLUS1 , BLANKK, EQU1 / 0, ' ', '=' /        
C        
      IF (PLUS1 .EQ. 0) CALL K2B (KHR43,KHR1,43)        
C        
C     CALL FFREAD TO READ INPUT CARD        
C     IF INPUT IS A COMMENT CARD, SET IBUF(1)=-1, AND RETURN        
C     IF INPUT IS IN FREE-FIELD, ALL 10 BULKDATA FIELDS ARE ALREADY     
C     LEFT-ADJUSTED, AND WASFF IS SET TO +1 BY FFREAD        
C     IF INPUT IS IN FIXED-FIELD, ALL 10 BULKDATA FIELDS MAY NOT BE IN  
C     LEFT-ADJUSTED FORMAT, AND WASFF IS SET TO -1 BY FFREAD        
C        
      CALL FFREAD (*850,CARD8)        
      CALL K2B (CARD80,CARD1,80)        
      IF (CARD1(1) .EQ. DOLLR1) GO TO 770        
      IE = 0        
      IF (XSORT.EQ.0 .OR. WASFF.EQ.1) GO TO 40        
C        
C     LEFT-ADJUSTED THE BULKDATA FIELDS, FIRST 9 FIELDS        
C     (FIRST 4 AND A HALF FIELDS IF DOUBLE FIELD CARDS)        
C        
      IB = 1        
      L  = 8        
      IF (CARD1(1).EQ.PLUS1 .OR. CARD1(1).EQ.STAR1) IB = 9        
      IF (CARD1(1) .EQ. STAR1) L = 16        
      DO 30 I = IB,72,L        
      IF (CARD1(I) .NE. BLANK1) GO TO 30        
      K  = I        
      JE = I + L - 1        
      DO 10 J = I,JE        
      IF (CARD1(J) .EQ. BLANK1) GO TO 10        
      CARD1(K) = CARD1(J)        
      KARD1(K) = KARD1(J)        
      K  = K + 1        
   10 CONTINUE        
      IF (K .EQ. I) GO TO 30        
      DO 20 J = K,JE        
      KARD1(J) = BLANKK        
   20 CARD1(J) = BLANK1        
   30 CONTINUE        
C        
C     CHECK COMMENT CARD WITH DOLLAR SIGN NOT IN COLUMN 1. CONVERT      
C     CHARACTER STRING TO BCD STRING, AND RETURN TO CALLER IF IT IS     
C     NOT CALLED BY XSORT.        
C        
   40 IE = IE + 1        
      IF (CARD1(IE) .EQ. BLANK1) GO TO 40        
      IF (CARD1(IE) .EQ. DOLLR1) GO TO 760        
C     READ (CARD80,50) BUFX        
C  50 FORMAT (20A4)        
      CALL KHRBCD (CARD80,BUFX)        
      IF (XSORT .EQ. 0) GO TO 780        
C        
C        
C     IF THIS ROUTINE IS CALLED BY XSORT, PASS THE FIRST 3 FIELDS TO    
C     IBUF ARRAY IN /XSORTX/, IN INTEGER FORMS        
C        
C     FIRST BULKDATA FIELD IS ALPHA-NUMERIC, COMPOSED OF TWO 4-CHARACTER
C     WORDS. CHECK WHETHER OR NOT THIS IS A CONTINUATION OR COMMENT CARD
C     IF IT IS NOT, WE CHANGE ALL 8 CHARACTER BYTES INTO THEIR NUMERIC  
C     CODE VALUES GIVEN BY TABLE /KHR43/ AND STORE THE VALUE IN IBUF(1) 
C     AND IBUF(2)        
C        
C     WE SET IBUF(1) AND (2)    IF INPUT CARD IS        
C     ----------------------    -------------------        
C                -1             A COMMENT CARD        
C                -2             A CONTINUATION CARD        
C                -3             A DELETE CARD (RANGE IN IBUF(3) AND (4))
C                -3, -4         A DIRTY DELETE CARD        
C                -5             A BLANK CARD        
C                -9             A ENDDATA CARD        
C     AND IBUF(2) AND IBUF(3) ARE NOT SET, EXECPT -3 CASE        
C        
C     IF FIELD 2 AND/OR FIELD 3 ARE IN CHARACTERS, WE PUT THE FIRST 6   
C     BYTES (OUT OF POSSIBLE 8 CHARACTER-BYTES) INTO IBUF(3) AND/OR     
C     IBUFF(4) RESPECTIVELY, IN INTERNAL NUMERIC CODE QUITE SIMILAR TO  
C     RADIX-50        
C     IF FIELD 2 HAS MORE THAN 7 CHARACTERS, IBUF(4) IS USED TO RECEIVE 
C     THE LAST 2 CHARACTERS OF FIELD 2        
C        
C     IF FIELD 2 AND/OR FIELD 3 ARE NUMERIC DATA (0-9,+,-,.,E), THEIR   
C     ACTUAL INTEGER VALUES ARE STORED IBUF(3) AND/OR IBUF(4).        
C     IF THEY ARE F.P. NUMBERS, THEIR EXPONENT VALUES (X100000) ARE     
C     CHANGED INTO INTEGERS, AND THEN STORED IN IBUF(3) AND/OR IBUF(4)  
C        
C     NOTE - XREAD WILL HANDLE BOTH SINGLE- AND DOUBLE-FIELD BULKDATA   
C     INPUT IN FIELDS 2 AND 3, AND MOVED THEM ACCORDINGLY INTO IBUF(3)  
C     AND IBUF(4)        
C        
C        
C     PRESET TABLE IF THIS IS VERY FIRST CALL TO XREAD ROUTINE        
C     TABLE SETTING IS MOVED UP BY ONE IF MACHINE IS CDC (TO AVOID      
C     BLANK CHARACTER WHICH IS ZERO FROM ICHAR FUNCTION)        
C        
      FROMY = 0        
      IF (XSORT .NE. 1) GO TO 80        
      XSORT = 2        
      CDC   = 0        
      IF (MACH .EQ. 4) CDC = 1        
      DO 60 I = 1,255        
   60 TABLE(I) = N7        
      DO 70 I = 1,N6        
      J = ICHAR(KHRK(I)) + CDC        
   70 TABLE(J) = I        
      F3LONG = 0        
      LARGE  = RSHIFT(COMPLF(0),1)/20        
C        
C     CHECK BLANK, ENDDATA, AND CONTINUATION CARDS        
C        
   80 ER = 0        
      J1 = CARD1(1)        
      J  = TABLE(ICHAR(KARD1(1))+CDC)        
      IF (J .GE. N7) GO TO 810        
      IF (CARD81.EQ.BLANK8 .AND. CARD8(2).EQ. BLANK8)  GO TO 90        
      IF (CARD81.EQ.END8(1) .OR. CARD81.EQ.END8(2) .OR.        
     1    CARD81.EQ.END8(3)) GO TO 100        
      IF (J1.NE.PLUS1 .AND. J1.NE.STAR1) GO TO 120        
      IBUF(1) = -2        
      GO TO 110        
   90 IBUF(1) = -5        
      GO TO 110        
  100 IBUF(1) = -9        
  110 IBUF(2) = IBUF(1)        
      GO TO 800        
C        
C     CHECK ASTERISK IN FIELD 1 (BUT NOT IN COLUMN1 1) AND SET DOUBLE-  
C     FIELD FLAG. MERGE EVERY TWO SINGLE FIELDS TO ENSURE CONTINUITY OF 
C     DOUBLE FIELD DATA (FIXED FIELD CARDS ONLY)        
C        
  120 DOUBLE = .FALSE.        
      IF (WASFF .EQ. 1) GO TO 180        
      IE = 8        
      DO 130 J = 2,8        
      IF (CARD1(IE) .EQ. STAR1) GO TO 140        
  130 IE = IE - 1        
      GO TO 180        
  140 DOUBLE = .TRUE.        
      IB = 0        
      DO 170 I = 8,71,16        
      K = I        
      DO 150 J = 1,16        
      L = I + J        
      IF (CARD1(L) .EQ. BLANK1) GO TO 150        
      K = K + 1        
      IF (K .EQ. L) GO TO 150        
      IB = 1        
      CARD1(K) = CARD1(L)        
      KARD1(K) = KARD1(L)        
  150 CONTINUE        
      IF (K .EQ. L) GO TO 170        
      K = K + 1        
      DO 160 J = K,L        
      KARD1(J) = BLANKK        
  160 CARD1(J) = BLANK1        
  170 CONTINUE        
      IF (IE .LE. 0) CALL MESAGE (-37,0,SUB)        
C     IF (IB .EQ. 1) READ (CARD80,50) BUFX        
      IF (IB .EQ. 1) CALL KHRBCD (CARD80,BUFX)        
      CARD1(IE) = BLANK1        
      KARD1(IE) = BLANKK        
C        
C     CHECK DELETE CARD        
C     SET IBUF(1)=IBUF(2)=-3 IF IT IS PRESENT, AND SET THE DELETE RANGE 
C     IN IBUF(3) AND IBUF(4)        
C     SET IBUF(1)=-3 AND IBUF(2)=-4 IF TRASH FOUND AFTER SLASH IN       
C     FIELD 1        
C     NOTE - IF FIELD 3 IS BLANK, IBUF(4) IS -3        
C        
  180 IF (J1 .NE. SLASH1) GO TO 200        
      DO 190 L = 1,4        
  190 IBUF(L) = -3        
      IF (CARD81 .NE. SLASH8) IBUF(2) = -4        
      L = 2        
      GO TO 300        
C        
C     TURN BCD2 AND BCD3 FLAGS ON IF THE 2ND AND 3RD INPUT FIELDS ARE   
C     NOT NUMERIC RESPECTIVELY        
C     IF 2ND FIELD HAS MORE THAN 6 CHARACTERS, REPLACE 3RD FIELD BY THE 
C     7TH AND 8TH CHARACTERS OF THE 2ND FIELD        
C     (FOR DMI AND DTI CARDS, MERGE 7TH AND 8TH CHARACTERS INTO 3RD     
C     FIELD AND TREAT THE ORIG. 3RD FIELD AS A NEW BCD WORD)        
C     IF 3RD FIELD HAS MORE THAN 6 CHARACTERS, SET F3LONG FLAG TO 1, AND
C     USER INFORMATION MESSAGE 217A WILL BE PRINTED BY XSORT        
C     FIELDS 2 AND 3 SHOULD NOT START WITH A /, $, *        
C     IF FIELD2 IS A BCD WORD, FIELD3 PROCESSING ACTUALLY BEGINS IN     
C     CARD8(4)        
C        
  200 BCD2 = .FALSE.        
      IF (DERR .EQ. +1) DERR = 0        
      J = TABLE(ICHAR(KARD1(9))+CDC)        
      IF (J .GE. N7) GO TO 810        
      NUMRIC = (J.GE.N2 .AND. J.LE.N3) .OR. J.GE.N5        
      IF (NUMRIC) GO TO 210        
      BCD2 = .TRUE.        
      IF (CARD1(15) .EQ. BLANK1) GO TO 210        
C        
C     SINCE THE NAME IN THE 2ND FIELD OF DMI, DTI, DMIG, DMIAX CARDS    
C     ARE NOT UNIQUELY DEFINED FOR SORTING, SPECIAL CODES HERE TO MOVE  
C     THE LAST PART OF A LONG NAME (7 OR 8 LETTER NAME) INTO THE 3RD    
C     FIELD, AND TREAT THE NEW 3RD FIELD AS BCD WORD. THUS THE ORIGINAL 
C     3RD FIELD (THE COLUMN NUMBER, RIGHT ADJUSTED WITH LEADING ZEROS)  
C     IS LIMITED TO 4 DIGITS OR LESS.  IF THE NAME IN THE 2ND FIELD IS  
C     SHORT (6 LETTERS OR LESS), MERGING OF THE 3RD FIELD IS NOT NEEDED.
C        
      IF (CARD1(1).NE.D1       .OR.  CARD1(3).NE.KHR1(20) .OR.        
     1   (CARD1(2).NE.KHR1(24) .AND. CARD1(2).NE.KHR1(31))) GO TO 208   
      BCD3 = .TRUE.        
      K = 24        
      IF (DOUBLE) K = 32        
      IF (CARD1(K-3) .EQ. BLANK1) GO TO 204        
      IF (ECHOU .EQ. 1) GO TO 202        
      IF (DERR .EQ. -1) CALL PAGE        
      CALL PAGE2 (-2)        
      IF (DOUBLE) CARD1(8) = STAR1        
      WRITE  (NOUT,201) CARD8        
  201 FORMAT (30X,10A8)        
      IF (DOUBLE) CARD1(8) = BLANK1        
  202 CALL PAGE2 (-2)        
      WRITE  (NOUT,203) UFM        
  203 FORMAT (A23,', THE 3RD INPUT FIELD OF THE ABOVE CARD IS LIMITED ',
     1       'TO 4 OR LESS DIGITS, WHEN A NAME OF 7 OR MORE', /5X,      
     2       'LETTERS IS USED IN THE 2ND FIELD',/)        
      DERR = +1        
      NOGO =  1        
  204 DO 205 J = 1,4        
      IF (CARD1(K-4) .NE. BLANK1) GO TO 206        
      KARD1(K-4) = KARD1(K-5)        
      KARD1(K-5) = KARD1(K-6)        
      KARD1(K-6) = KARD1(K-7)        
  205 KARD1(K-7) = BLANKK        
  206 DO 207 J = 1,6        
      KARD1(K) = KARD1(K-2)        
  207 K = K-1        
      KARD1(K  ) = KARD1(16)        
      KARD1(K-1) = KARD1(15)        
      KARD1( 15) = BLANKK        
      GO TO 215        
C        
  208 KARD1(17) = KARD1(15)        
      KARD1(18) = KARD1(16)        
      DO 209 K = 19,24        
  209 KARD1(K) = BLANKK        
C        
  210 BCD3 = .FALSE.        
      K = 17        
      IF (DOUBLE) K = 25        
      J = TABLE(ICHAR(KARD1(K))+CDC)        
      ALPHA = J.EQ.N1 .OR. (J.GT.N3 .AND. J.LT.N5)        
      IF (ALPHA) BCD3 = .TRUE.        
      IF (BCD3 ) GO TO 215        
C        
C     THE FIRST 3 FIELDS OF THE DMIG OR DMIAX CARDS (NOT THE 1ST HEADER 
C     CARD), ARE NOT UNIQUE. MERGE THE 4TH FIELD (1 DIGIT INTEGER) INTO 
C     THE 3RD FIELD (INTEGER, 8 DIGITS OR LESS) TO INCLUDE THE COMPONENT
C     FIELD FOR SORTING        
C        
      IF (CARD1(1).NE.D1 .OR. CARD1(2).NE.KHR1(24) .OR.        
     1    CARD1(3).NE.KHR1(20)  .OR. (CARD1(4).NE.KHR1(18) .AND.        
     2    CARD1(4).NE.KHR1(12))) GO TO 215        
      IF (CARD1(1) .EQ. KHR1(2)) GO TO 215        
      K = 24        
      IF (DOUBLE) K = 32        
      IF (CARD1(K) .NE. BLANK1) GO TO 215        
      DO 211 J = 1,7        
      K = K - 1        
      IF (CARD1(K) .NE. BLANK1) GO TO 212        
  211 CONTINUE        
  212 KARD1(K+1) = KARD1(25)        
      IF (DOUBLE) KARD1(K+1) = KARD1(41)        
C        
C        
C     CHANGE ALL CHARACTERS IN FIRST 3 FIELDS TO INTEGER INTEGER CODES  
C     ACCORDING TO THE TABLE ARRANGEMENT IN /KHR43/        
C     MAKE SURE THE INTERNAL CODE IS NOT IN NASTRAN INTEGER RANGE (1 TO 
C     8 DIGITS), AND WITHIN MACHINE INTEGER WORD LIMIT        
C     IN 2ND AND 3RD FIELDS, INTERCHANGE ALPHABETS AND NUMERIC DIGITS   
C     SEQUENCE TO AVOID SYSTEM INTEGER OVERFLOW        
C        
C     -------------- REMEMBER, FROM HERE DOWN,        
C                    CARD1 (1-BYTE ) HOLD ONE CHARACTER, AND        
C                    IBUFX (4-BYTES) HOLD AN  INTEGER ----------------- 
C     WE ALSO HAVE   CARD8 (8-BYTES) HOLDING 8 CHARACTERS,        
C              AND   BUFX  (4-BYTES) HOLDING 4 BCD-CHARACTERS        
C        
C        
C     MAP OF THE FIRST 3 BULKDATA FIELDS -        
C     (INPUT)        
C        
C           WORD1 WORD2 WORD3 WORD4 WORD5 WORD6 WORD7 WORD8 WORD9 WORD10
C     BYTE: 1         8 9        16 17       24 25       32 33       40 
C          +-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+
C     SF:  !<-FIELD 1->!<-FIELD 2->!<-FIELD 3->!        
C     DF:  !<-FIELD 1->!<------ FIELD 2 ------>!<------ FIELD 3 ------>!
C        
C        
C     MAP OF IBUF -           WORD1 WORD2 WORD3 WORD4        
C     (OUTPUT)         BYTE:  1         8 9  12 13 16        
C                            +-----+-----+-----+-----+        
C     FOR CORE SORT          !<-FIELD 1->!<--->!<--->!        
C     PERFORMED IN                        FIELD FIELD        
C     XSORT2                                 2     3        
C        
  215 NUMRIC = .FALSE.        
      L    = 0        
      IOO  = 100        
      WORD = 0        
  220 WORD = WORD + 1        
      GO TO 260        
  230 IOO  = N4        
      IF (.NOT.BCD2) GO TO 280        
      WORD = 3        
      GO TO 260        
  240 WORD = 5        
      IF (DOUBLE) WORD = 7        
      IF (.NOT.BCD2 .OR. KARD1(15).EQ.BLANKK) GO TO 250        
      WORD = 4        
      IOO  = 100        
      BCD3 = .TRUE.        
  250 IF (.NOT.BCD3) GO TO 280        
      IF (WORD.NE.4 .AND. KARD1(WORD*4+3).NE.BLANKK .AND. DERR.NE.+1)   
     1    F3LONG = 1        
  260 IE  = WORD*4        
      IB  = IE - 3        
      J   = TABLE(ICHAR(KARD1(IB))+CDC)        
      IF (J .GE. N7) GO TO 810        
      IF (MOD(WORD,2).EQ.0 .AND. .NOT.NUMRIC) GO TO 262        
      NUMRIC = (J.GE.N2 .AND. J.LE.N3) .OR. J.GE.N5        
      IF (NUMRIC) GO TO 280        
  262 IF (IOO .EQ. 100) GO TO 265        
      IE = IE + 2        
      K  = J        
      IF (K .GT. N3) J = K - N3        
      IF (K .LE. N3) J = K + 25        
  265 SUM = J        
      IB  = IB + 1        
      DO 270 I = IB,IE        
      J   = TABLE(ICHAR(KARD1(I))+CDC)        
  270 SUM = SUM*IOO + J        
      IF (IOO .EQ. 100) SUM = SUM + 200000000        
      IBUF(L+1) = SUM        
  280 L = L + 1        
      GO TO (220,230,240,290), L        
C        
C     CHECK INTEGERS ON 2ND AND 3RD FIELDS        
C        
  290 IF (BCD2 .AND. BCD3) GO TO 500        
      L  = 2        
      IF (BCD2) L = 3        
  300 L  = L + 1        
      IF (L-4) 310,320,500        
  310 IB = 9        
      GO TO 330        
  320 IB = 17        
      IF (DOUBLE) IB = 25        
  330 IE = IB + 7        
      IF (DOUBLE) IE = IB + 15        
      J1 = CARD1(IB)        
      IF (J1.EQ.PLUS1 .OR. J1.EQ.MINUS1 .OR. J1.EQ.POINT1 .OR.        
     1    J1.EQ.ZERO1) GO  TO 340        
      J  = TABLE(ICHAR(KARD1(IB))+CDC)        
      IF (J.GE.N2 .AND. J.LE.N3) GO TO 350        
C        
C     IT IS CHARACTER FIELDS, NOTHING ELSE NEEDS TO BE DONE        
C        
      GO TO 300        
C        
C     IT IS NUMERIC        
C        
  340 IB  = IB + 1        
  350 SUM = 0        
      FP  = 0        
      SIGX= 1        
      SIGN= 1        
      IF (J1 .EQ. MINUS1) SIGN =-1        
      IF (J1 .EQ. POINT1) FP   = 1        
      DO 380 I = IB,IE        
      IF (KARD1(I) .EQ. BLANKK) GO TO 390        
      J   = TABLE(ICHAR(KARD1(I))+CDC) - N2        
      IF (J.LT.0 .OR. J.GT.9) GO TO 360        
      IF (FP.LE.0 .AND. IABS(SUM).LT.LARGE) SUM = SUM*10 + SIGN*J       
      GO TO 380        
C        
C     A NON-NUMERIC SYMBOL FOUND IN NUMERIC STRING        
C     ONLY 'E', 'D', '+', '-', OR '.' ARE ACCEPTABLE HERE        
C        
  360 J1  = CARD1(I)        
      IF (J1 .EQ. POINT1) GO TO 370        
      IF (FP.EQ.0 .OR. IBUF(3).EQ.-3) GO TO 420        
      IF (J1.NE.E1 .AND. J1.NE.D1 .AND. J1.NE.PLUS1 .AND.        
     1    J1.NE.MINUS1) GO TO 420        
      IF (J1 .EQ. MINUS1) SIGX = -1        
      FP  =-1        
      SUM = 0        
      GO TO 380        
  370 FP  = 1        
C        
  380 CONTINUE        
C        
C     BEEF UP NUMERIC DATA BY 2,000,000,000 SO THAT THEY WILL BE        
C     SORTED BEHIND ALL ALPHABETIC DATA, AND MOVE THE NUMERIC DATA, IN  
C     INTEGER FORM (F.P. MAY NOT BE EXACT) INTO IBUF(3) OR IBUF(4)      
C        
  390 IF (FP) 410,400,400        
  400 IBUF(L) = SUM + SIGN*2000000000        
      GO TO 300        
  410 IBUF(L) = SIGN*2000000000        
      IF (SIGX.GT.0 .AND. SUM.LT.9)        
     1    IBUF(L) = SIGN * (10**(SIGX*SUM) + 2000000000)        
      IF (SIGX.GT.0 .AND. SUM.GE.9) IBUF(L)= 2147000000*SIGN        
      GO TO 300        
C        
C     ERROR IN NUMERIC FIELD        
C        
  420 IF (IB.EQ.10 .OR. IB.EQ.18) IB = IB - 1        
      K = 1        
      IF (ECHOU.EQ.0 .AND. ER.NE.-9) K = 2        
      CALL PAGE2 (-K)        
      IF (ECHOU.EQ.0 .AND. ER.NE.-9) WRITE (NOUT,430) CARD80        
  430 FORMAT (1H ,29X,A80)        
      K = 2        
      IF (.NOT.DOUBLE) GO TO 440        
      K = 4        
      IF (L .NE. 4) WORD = WORD + 1        
  440 IF (L .EQ. 4) WORD = WORD + 2        
      WRITE  (NOUT,450) (BLANK4,I=1,WORD),(EQUAL4,I=1,K)        
  450 FORMAT (7X,'*** ERROR -',24A4)        
      NOGO = 1        
      ER   =-9        
      GO TO 500        
C        
C     BOTH FIELDS 2 AND 3 (OF BULK DATA CARD) DONE.        
C        
C        
C     FOR MOST BULK DATA CARDS, EXCEPT THE ONES IN NAME8, THE FIRST     
C     3 FIELDS, IN INTERNAL CODES AND SAVED IN THE IBUF 4-WORD ARRAY,   
C     ARE SUFFICIENT FOR ALPHA-NUMERIC SORT (BY XSORT2)        
C        
C     THOSE SPECIAL ONES IN NAME8 ADDITIONAL FIELDS FOR SORTING        
C        
  500 DO 510 TYPE = 1,NNAME        
      IF (CARD81 .EQ. NAME8(TYPE)) GO TO        
     1   (520,   520,   520,   520,   600,   520,    520,   520,        
     2    520,   560,   570,   580,   560,   560,    560),  TYPE        
C        
C    1   SPC1   SPCS   TICS   MPCS  MPCAX  RELES   GTRAN  FLUTTER       
C    2   BDYC  SPCSD   SPCS1 RANDPS DELAYS DAREAS  DPHASES        
C        
  510 CONTINUE        
      GO TO 700        
C        
C     SPC1,SPCS,TICS,MPCS,RELES,GTRAN,FLUTTER,BDYC CARDS -        
C     ADD 4TH INTEGER FIELD TO IBUF ARRAY        
C        
  520 IBUF(2) = IBUF(3)        
      IBUF(3) = IBUF(4)        
  530 SUM = 0        
      DO 540 I = 25,32        
      J1  = CARD1(I)        
      IF (J1 .EQ. BLANK1) GO TO 550        
      J   = TABLE(ICHAR(KARD1(I))+CDC) - N2        
      IF (J.GE.0 .AND. J.LE.9) SUM = SUM*10 + J        
  540 CONTINUE        
  550 IBUF(4) = SUM        
      IF (TYPE .EQ. 12) GO TO 590        
      GO TO 700        
C        
C     DAREAS,DELAYS,DPHASES,SPCSD CARDS -        
C     ADD ONE TO IBUF(1), THUS CREATE DARF,DELB,DPHB,OR SPCT IN        
C     IBUF(1), THEN ADD 4TH INTEGER FIELD INTO IBUF ARRAY        
C        
  560 IBUF(1) = IBUF(1) + 1        
      GO TO 520        
C        
C     SPCS1 CARD -        
C     ADD TWO TO IBUF(1), THUS CREATE SPCU IN IBUF(1), THEN ADD        
C     4TH INTEGER FIELD INTO IBUF ARRAY        
C        
  570 IBUF(1) = IBUF(1) + 2        
      GO TO 520        
C        
C     RANDPS -        
C     MERGE FIELDS 3 AND 4 IF SUBCASE NUMBERS ARE NOT TOO BIG        
C        
  580 IF (IBUF(4).GE.10000 .OR. BUFX(8).NE.BLANK4) GO TO 700        
      IOOOO = IBUF(4)*10000        
      GO TO 530        
  590 IBUF(4) = IBUF(4) + IOOOO        
      GO TO 700        
C        
C     MPCAX -        
C     MOVE THE 6TH FIELD INTO IBUF(4)        
C        
  600 J = 41        
      DO 610 I = 25,32        
      CARD1(I) = CARD1(J)        
      KARD1(I) = KARD1(J)        
  610 J = J+1        
      GO TO 530        
C        
C     CHECK NUMERIC ERROR IN 4TH TO 9TH FIELDS IF NO ERROR IN FIRST     
C     3 FIELDS (NEW BULK DATA CARDS ONLY)        
C        
  700 IF (FROMY.EQ.1 .OR. ER.EQ.-9) GO TO 800        
      WORD = 5        
      IF (DOUBLE) WORD = 7        
  710 WORD = WORD + 2        
      IF (DOUBLE) WORD = WORD + 2        
      IF (WORD .GE. 19) GO TO 800        
      IB = WORD*4 - 3        
      J  = TABLE(ICHAR(KARD1(IB))+CDC)        
      IF (J .GE. N7) GO TO 710        
      ALPHA = J.EQ.N1 .OR. (J.GT.N3 .AND. J.LT.N5)        
      IF (ALPHA) GO TO 710        
      IE = IB + 7        
      IF (DOUBLE) IE = IB + 15        
      L  = IB + 1        
      DO 740 I = L,IE        
      J1 = CARD1(I)        
      IF (J1 .EQ. BLANK1) GO TO 710        
      J  = TABLE(ICHAR(KARD1(I))+CDC)        
      NUMRIC = (J.GE.N2 .AND. J.LE.N3) .OR. (J.GE.N5 .AND. J.LE.N6)     
      IF (NUMRIC .OR. J.EQ.15 .OR. J.EQ.16) GO TO 740        
C                           D            E        
      K = 1        
      IF (ECHOU.EQ.0 .AND. ER.NE.-9) K = 2        
      CALL PAGE2 (-K)        
      IF (ECHOU.EQ.0 .AND. ER.NE.-9) WRITE (NOUT,430) CARD80        
      WORD = WORD + 2        
      K = 2        
      IF (.NOT. DOUBLE) GO TO 730        
      K = 4        
  730 WRITE (NOUT,450) (BLANK4,J=1,WORD),(EQUAL4,J=1,K)        
      NOGO = 1        
      GO TO 800        
  740 CONTINUE        
      GO TO 800        
C        
  760 IF (XSORT .EQ. 0) KARD1(IE) = KHRK( 1)        
  770 IF (XSORT .EQ. 0) KARD1( 1) = KHRK(39)        
      IBUF(1) = -1        
C     READ (CARD80,50) BUFX        
      CALL KHRBCD (CARD80,BUFX)        
      GO TO 800        
C        
  780 IBUF(1) = 0        
C        
  800 RETURN        
C        
  810 IF (XSORT .EQ. 2) GO TO 830        
      WRITE  (NOUT,820) XSORT        
  820 FORMAT (//,' *** TABLE IN XREAD HAS NOT BEEN INITIALIZED.',       
     1        /5X,'XSORT=',I4)        
      CALL MESAGE (-37,0,SUB)        
  830 WRITE  (NOUT,840) CARD8        
  840 FORMAT (/,' *** ILLEGAL CHARACTER ENCOUNTERED IN INPUT CARD',     
     1       /4X,1H',10A8,1H' )        
      NOGO = 1        
  850 RETURN 1        
C        
C        
      ENTRY YREAD (*,BUFX)        
C     ====================        
C        
C     YREAD IS CALLED ONLY BY XSORT TO RE-PROCESS CARD IMAGES FROM      
C     THE OPTP FILE        
C        
C     WRITE (CARD80,50) BUFX        
      CALL BCDKH8 (BUFX,CARD80)        
      CALL K2B (CARD80,CARD1,80)        
      FROMY = 1        
      GO TO 80        
C        
C        
      ENTRY RMVEQ (BUFX)        
C     ==================        
C        
C     RMVEQ, CALLED ONLY BY XCSA, REMOVES AN EQUAL SIGN FROM TEXT.      
C     THUS, 1 EQUAL SIGN BEFORE COLUMN 36 IS ALLOWED ON ONE EXECUTIVE   
C     CONTROL LINE        
C        
C     AT THIS POINT, THE DATA IN KARD1 IS STILL GOOD        
C        
      DO 900 I = 1,36        
      IF (KARD1(I) .EQ. EQU1) GO TO 910        
  900 CONTINUE        
      GO TO 920        
  910 KARD1(I) = BLANKK        
      CALL KHRBCD (CARD80,BUFX)        
  920 RETURN        
      END        
