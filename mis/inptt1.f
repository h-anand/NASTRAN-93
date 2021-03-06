      SUBROUTINE INPTT1        
C        
C     READ DATA BLOCK(S) FROM A NASTRAN USER TAPE WHICH MUST BE SET UP. 
C        
C     CALL TO THIS MODULE IS        
C        
C     INPUTT1  /O1,O2,O3,O4,O5/V,N,P1/V,N,P2/V,N,P3/V,N,P4  $        
C        
C     PARAMETERS P1 AND P2 ARE INTEGER INPUT, P3 AND P4 ARE BCD        
C        
C               P1= 0, NO ACTION TAKEN BEFORE READ (DEFAULT)        
C                 =+N, SKIP FORWARD N DATA BLOCKS BEFORE READ        
C                 =-1, USER TAPE IS REWOUND BEFORE READ        
C                 =-2, A NEW REEL IS MOUNTED BEFORE READ        
C                 =-3, THE NAMES OF ALL DATA BLOCKS ON USER TAPE ARE    
C                      PRINTED AND READ OCCURS AT BEGINNING OF TAPE     
C                 =-4, AN OUTPUT TAPE IS TO BE DISMOUNTED        
C                      AFTER AN END-OF-FILE MARK IS WRITTEN.        
C                      A NEW INPUT REEL WILL THEN BE MOUNTED.        
C                 =-5, SEARCH USER TAPE FOR FIRST VERSION OF DATA       
C                      BLOCKS REQUESTED.        
C                      IF ANY ARE NOT FOUND, A FATAL TERMINATION        
C                      OCCURS.        
C                 =-6, SEARCH USER TAPE FOR FINAL VERSION OF DATA       
C                      BLOCKS REQUESTED.        
C                      IF ANY ARE NOT FOUND, A FATAL TERMINATION        
C                      OCCURS.        
C                 =-7, SEARCH USER TAPE FOR FIRST VERSION OF DATA       
C                      BLOCKS REQUESTED.        
C                      IF ANY ARE NOT FOUND, A WARNING OCCURS.        
C                 =-8, SEARCH USER TAPE FOR FINAL VERSION OF DATA       
C                      BLOCKS REQUESTED.        
C                      IF ANY ARE NOT FOUND, A WARNING OCCURS.        
C                 =-9, REWIND AND UNLOAD USER TAPE        
C        
C               P2= 0, FILE NAME IS INPT        
C                 = 1, FILE NAME IS INP1        
C                 = 2, FILE NAME IS INP2        
C                 = 3, FILE NAME IS INP3        
C                 = 4, FILE NAME IS INP4        
C                 = 5, FILE NAME IS INP5        
C                 = 6, FILE NAME IS INP6        
C                 = 7, FILE NAME IS INP7        
C                 = 8, FILE NAME IS INP8        
C                 = 9, FILE NAME IS INP9        
C                 THE MPL DEFAULT VALUE FOR P2 IS 0        
C        
C               P3=    TAPE ID CODE FOR USER TAPE, AN ALPHANUMERIC      
C                      VARIABLE WHOSE VALUE MUST MATCH A CORRESPONDING  
C                      VALUE ON THE USER TAPE.        
C                      THIS CHECK IS DEPENDENT ON THE VALUE OF        
C                      P1 AS FOLLOWS..        
C                       *P1*             *TAPE ID CHECKED*        
C                        +N                     NO        
C                         0                     NO        
C                        -1                    YES        
C                        -2                    YES (ON NEW REEL)        
C                        -3                    YES (WARNING CHECK)      
C                        -4                    YES (ON NEW REEL)        
C                        -5                    YES        
C                        -6                    YES        
C                        -7                    YES        
C                        -8                    YES        
C                        -9                     NO        
C                      THE MPL DEFAULT VALUE FOR P3 IS XXXXXXXX        
C        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         TAPEUP,TAPBIT        
      INTEGER         OUBUF,OUTPUT,P1,P2,P3,P4,ZERO,RSHIFT,ANDF,NONE(2),
     1                TRL(7),NAME(2),SUBNAM(2),INN(10),OUT(5),NAMEX(2), 
     2                IDHDR(7),IDHDRX(7),P3X(2),NT(5,3),DX(3),TAPCOD(2),
     3                BCDBIN(4)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /MACHIN/ MACH        
      COMMON /BLANK / P1,P2,P3(2),P4(2)        
     1       /SYSTEM/ KSYSTM(65)        
CZZ  2       /ZZINP1/ X(1)        
     2       /ZZZZZZ/ X(1)        
      EQUIVALENCE     (KSYSTM(1),NB  ), (KSYSTM( 2),NOUT),        
     1                (KSYSTM(9),NLPP), (KSYSTM(12),LINE)        
      DATA    SUBNAM/ 4HINPT, 4HT1  / , MSC      / 4HMSC /        
      DATA    OUT   / 201,202,203,204,205/, MASK / 65535 /        
      DATA    ZERO  , MONE,MTWO,MTRE,MFOR/ 0,-1,-2,-3,-4 /,        
     1        MFIV  , MSIX,METE,MNIN     /-5,-6,-8,-9    /        
      DATA    INN   / 4HINPT,4HINP1,4HINP2,4HINP3,4HINP4 ,        
     1                4HINP5,4HINP6,4HINP7,4HINP8,4HINP9 /        
      DATA    IDHDR / 4HNAST,4HRAN ,4HUSER,4H TAP,4HE ID,4H COD,4HE - / 
      DATA    BCDBIN/ 4HBCD ,4H    ,4HBINA,4HRY          /        
      DATA    NONE  / 4H (NO,4HNE) /, IPT1,IPT4/ 1H1,1H4 /        
C        
C        
      IPTX = IPT1        
      IF (P4(1) .EQ. MSC) GO TO 20        
      GO TO 100        
C        
C        
      ENTRY INPUT1        
C     ============        
C        
C     INPUT1 HANDELS MSC/OUTPUT1 DATA.        
C     INPUT1 IS CALLED FROM INPTT1, WITH P4 = 'MSC', OR IT IS CALLED    
C     FROM INPTT4        
C        
   20 IPTX = IPT4        
      IF (P3(1).EQ.BCDBIN(1) .AND. P3(2).EQ.BCDBIN(2)) GO TO 9918       
      IF (P3(1).EQ.BCDBIN(3) .AND. P3(2).EQ.BCDBIN(4)) GO TO 9918       
      WRITE  (NOUT,30) UIM        
   30 FORMAT (A29,'. INPUTT1 IS REQUESTED TO READ INPUT TAPE GENERATED',
     1       ' IN MSC/OUTPUT1 COMPATIBLE RECORDS')        
C        
  100 LCOR = KORSZ(X) - 2*NB        
      IF (LCOR .LE. 0) CALL MESAGE (-8,LCOR,SUBNAM)        
      INBUF = LCOR  + 1        
      OUBUF = INBUF + NB        
      TAPCOD(1) = P3(1)        
      TAPCOD(2) = P3(2)        
      IF (P2.LT.0 .OR. P2.GT.9) GO TO 9907        
      IN = INN(P2+1)        
      IF (IPTX .EQ. IPT4) WRITE (NOUT,110) UIM,NB,IN        
  110 FORMAT (A29,', CURRENT NASTRAN BUFFER SIZE IS',I9,' WORDS', /5X,  
     1       'SYNCHRONIZED BUFFSIZE IS REQUIRED IN CURRENT NASTRAN AND',
     2       ' THE VERSION THAT WROTE ',A4,' TAPE (OR FILE)', /5X,      
     3       3(4H====),/)        
      IFILE  = IN        
      IF (MACH .GE. 5) GO TO 120        
      TAPEUP = TAPBIT(IN)        
      IF (.NOT.TAPEUP ) GO TO 9909        
  120 IF (P1 .LT. MNIN) GO TO 9908        
C        
      IF (P1 .EQ. MNIN) GO TO 5000        
      IF (P1 .LT. MFOR) GO TO 3000        
      IF (P1 .EQ. MTRE) GO TO 2000        
      IF (P1 .LE. ZERO) GO TO 150        
C        
      CALL OPEN (*9901,IN,X(INBUF),2)        
      DO 130 I = 1,P1        
      CALL READ (*9906,*9906,IN,NAMEX,2,0,NF)        
  130 CALL SKPFIL (IN,1)        
      GO TO 250        
C        
  150 IF (P1.NE.MTWO .AND. P1.NE.MFOR) GO TO 190        
C        
C     P1 = -2 OR P1 = -4 IS ACCEPTABLE ONLY ON IBM OR UNIVAC        
C        
      IF (MACH.NE.2 .AND. MACH.NE.3) GO TO 9908        
C        
      IOLD = -P1/2        
      CALL OPEN (*9901,IN,X(INBUF),2)        
      CALL TPSWIT (IN,IOLD,1,TAPCOD)        
C        
  190 IF (P1.NE.MONE .AND. P1.NE.MTWO .AND. P1.NE.MFOR) GO TO 230       
C        
C     OPEN USER TAPE TO READ WITH REWIND AHD TAPE ID CHECK        
C        
      IF (P1.NE.MONE .AND. P1.NE.MTWO .AND. P1.NE.MFOR .AND.        
     1    IPTX.EQ.IPT4) GO TO 230        
      CALL OPEN (*9901,IN,X(INBUF),0)        
      CALL READ (*9911,*9912,IN,DX,3,0,NF)        
      CALL READ (*9911,*9912,IN,IDHDRX,7,0,NF)        
      DO 210 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 9913        
  210 CONTINUE        
      CALL READ (*9911,*9912,IN,P3X,2,1,NF)        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 9910        
      CALL SKPFIL (IN,1)        
      GO TO 250        
C        
C     OPEN USER TAPE TO READ WITHOUT REWIND AND NO TAPE ID CHECK        
C        
  230 CALL OPEN (*9901,IN,X(INBUF),2)        
      IF (IPTX .EQ. IPT4) CALL FWDREC (*9912,IX)        
C        
  250 DO 1000 I = 1,5        
      OUTPUT = OUT(I)        
      TRL(1) = OUTPUT        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LE. 0) GO TO 1000        
      CALL FNAME (OUTPUT,NAME)        
      IF (NAME(1).EQ.NONE(1) .AND. NAME(2).EQ.NONE(2)) GO TO 1000       
C        
C     PASS FILE NAME HEADER RECORD        
C        
      CALL READ (*9904,*9905,IN,NAMEX,2,0,NF)        
C        
C     READ TRAILER RECORD, SIX WORDS (OR 3 WORDS, IPTX=4 ONLY)        
C        
      CALL READ (*9904,*300,IN,TRL(2),6,1,NF)        
      GO TO 340        
C        
C     JUST A NOTE, FROM G.CHAN/UNISYS -        
C     LEVEL 17.5 USED 2 RECORDS HERE FOR THE MATRIX NAME (2 BCD WORDS,  
C     1ST RECORD) AND 7 TRAILER WORDS (2ND RECORD)        
C        
  300 IF (IPTX.NE.IPT4 .OR. NF.LT.3) GO TO 9905        
      TRL(5) = TRL(2)        
      TRL(6) = TRL(3)        
      TRL(7) = TRL(4)        
      DO 320 J = 2,7        
      J1 = J/2 + 4        
      J2 = MOD(J-1,2)*16        
      TRL(J) = ANDF(RSHIFT(TRL(J1),J2),MASK)        
  320 CONTINUE        
C        
C     OPEN OUTPUT DATA BLOCK TO WRITE WITH REWIND        
C        
  340 CALL OPEN (*9902,OUTPUT,X(OUBUF),1)        
C        
C     COPY CONTENTS OF USER TAPE ONTO OUTPUT DATA BLOCK, INCLUDING      
C     FILE NAME IN RECORD 0        
C        
      CALL CPYFIL (IN,OUTPUT,X,LCOR,NF)        
C        
C     CLOSE OUTPUT DATA BLOCK WITH REWIND AND EOF        
C        
      CALL CLOSE (OUTPUT,1)        
C        
C     WRITE TRAILER        
C        
      TRL(1) = OUTPUT        
      CALL WRTTRL (TRL)        
      CALL PAGE2 (-3)        
      WRITE  (NOUT,400) UIM,NAME,IN,NAMEX        
  400 FORMAT (A29,' 4105,     DATA BLOCK ',2A4,' RETRIEVED FROM USER ', 
     1       'TAPE',A4, /5X,'NAME OF DATA BLOCK WHEN PLACED ON USER ',  
     2       'TAPE WAS ',2A4 )        
C        
 1000 CONTINUE        
C        
C     CLOSE NASTRAN USER TAPE WITHOUT REWIND        
C        
      CALL CLOSE (IN,2)        
      RETURN        
C        
C     OBTAIN LIST OF DATA BLOCKS ON USER TAPE.        
C        
 2000 CALL OPEN (*9901,IN,X(INBUF),0)        
      CALL READ (*9911,*9912,IN,DX,3,0,NF)        
      CALL READ (*9911,*9912,IN,IDHDRX,7,0,NF)        
      DO 2005 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 9913        
 2005 CONTINUE        
      CALL READ (*9911,*9912,IN,P3X,2,1,NF)        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 9914        
 2006 CALL SKPFIL (IN,1)        
      KF = 0        
 2007 CALL PAGE1        
      LINE = LINE + 5        
      WRITE  (NOUT,2010) IN        
 2010 FORMAT (1H0,50X,A4,14H FILE CONTENTS ,/46X,4HFILE,18X,4HNAME/1H0) 
 2020 CALL READ (*2050,*9915,IN,NAMEX,2,1,NF)        
      CALL SKPFIL (IN,1)        
      KF = KF + 1        
      LINE = LINE + 1        
      WRITE (NOUT,2030) KF,NAMEX        
 2030 FORMAT (45X,I5,18X,2A4)        
      IF (LINE - NLPP) 2020,2007,2007        
 2050 CALL REWIND (IN)        
      CALL SKPFIL (IN,1)        
      GO TO 250        
C        
C        
C     SEARCH MODE        
C        
 3000 CONTINUE        
C        
C     EXAMINE OUTPUT REQUESTS AND FILL NAME TABLE        
C        
      NNT = 0        
      DO 3050 I = 1,5        
      OUTPUT = OUT(I)        
      TRL(1) = OUTPUT        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LE. 0) GO TO 3020        
      CALL FNAME (OUTPUT,NAME)        
      IF (IPTX.EQ.IPT4 .AND. NAME(1).EQ.NONE(1) .AND. NAME(2).EQ.NONE(2)
     1   ) GO TO 3010        
      NT(I,1) = 0        
      NT(I,2) = NAME(1)        
      NT(I,3) = NAME(2)        
      NNT = NNT + 1        
      GO TO 3050        
 3010 NT(I,2) = NAME(1)        
      NT(I,3) = NAME(2)        
 3020 NT(I,1) = -1        
 3050 CONTINUE        
C        
      IF (NNT .GT. 0) GO TO 3070        
      CALL PAGE2 (-2)        
      WRITE  (NOUT,3060) UWM,IPTX        
 3060 FORMAT (A25,' 4137,  ALL OUTPUT DATA BLOCKS FOR INPUTT',A1,       
     1       ' ARE PURGED.')        
      RETURN        
C        
C     CHECK TAPE ID LABEL.        
C        
 3070 CALL OPEN (*9901,IN,X(INBUF),0)        
      CALL READ (*9911,*9912,IN,DX,3,0,NF)        
      CALL READ (*9911,*9912,IN,IDHDRX,7,0,NF)        
      DO 3080 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 9913        
 3080 CONTINUE        
      CALL READ (*9911,*9912,IN,P3X,2,1,NF)        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 9910        
      CALL SKPFIL (IN,1)        
C        
C        
C     BEGIN SEARCH OF TAPE.        
C        
      KF = 0        
 3110 CALL READ (*3500,*9915,IN,NAMEX,2,0,NF)        
      KF = KF + 1        
C        
      DO 3200 I = 1,5        
      NAME(1) = NT(I,2)        
      NAME(2) = NT(I,3)        
      IF (NT(I,1) .LT. 0) GO TO 3200        
      IF (NAME(1).NE.NAMEX(1) .OR. NAME(2).NE.NAMEX(2)) GO TO 3200      
      NT(I,1) = NT(I,1) + 1        
      IF (NT(I,1).EQ.1 .OR. P1.EQ.MSIX .OR. P1.EQ.METE) GO TO 3150      
      CALL PAGE2 (-3)        
      WRITE  (NOUT,3140) UWM,NAME,KF,IN        
 3140 FORMAT (A25,' 4138,  DATA BLOCK ',2A4,' (DATA BLOCK COUNT =',I5,  
     2        ') HAS PREVIOUSLY BEEN RETRIEVED FROM', /36X ,        
     3        'USER TAPE ',A4,' AND WILL BE IGNORED.')        
      GO TO 3205        
 3150 CALL READ (*9904,*3160,IN,TRL(2),6,1,NF)        
      GO TO 3180        
 3160 IF (IPTX.NE.IPT4 .OR. NF.LT.3) GO TO 9905        
      TRL(5) = TRL(2)        
      TRL(6) = TRL(3)        
      TRL(7) = TRL(4)        
      DO 3170 J = 2,7        
      J1 = J/2 + 4        
      J2 = MOD(J-1,2)*16        
      TRL(J) = ANDF(RSHIFT(TRL(J1),J2),MASK)        
 3170 CONTINUE        
 3180 OUTPUT = OUT(I)        
      CALL OPEN (*9902,OUTPUT,X(OUBUF),1)        
      CALL CPYFIL (IN,OUTPUT,X,LCOR,NF)        
      CALL CLOSE (OUTPUT,1)        
      TRL(1) = OUTPUT        
      CALL WRTTRL (TRL)        
      CALL PAGE2 (-2)        
      WRITE  (NOUT,3185) UIM,NAME,IN,KF        
 3185 FORMAT (A29,' 4139, DATA BLOCK ',2A4,' RETRIEVED FROM USER TAPE ',
     1       A4,' (DATA BLOCK COUNT =',I5,1H))        
      IF (NT(I,1) .GT. 1) GO TO 3190        
      NNT = NNT - 1        
      GO TO 3210        
 3190 WRITE  (NOUT,3195) UWM        
 3195 FORMAT (A25,' 4140, SECONDARY VERSION OF DATA BLOCK HAS REPLACED',
     1        ' EARLIER ONE.')        
      CALL PAGE2 (-2)        
      GO TO 3210        
 3200 CONTINUE        
C        
 3205 CALL SKPFIL (IN,1)        
 3210 IF (NNT.GT.0 .OR. P1.EQ.MSIX .OR. P1.EQ.METE) GO TO 3110        
      GO TO 3900        
C        
 3500 IF (NNT .LE. 0) GO TO 3900        
      CALL PAGE2 (-7)        
      IF (P1.EQ.MFIV .OR. P1.EQ.MSIX) GO TO 9916        
      WRITE  (NOUT,3510) UWM        
 3510 FORMAT (A25,' 4141, ONE OR MORE DATA BLOCKS NOT FOUND ON USER ',  
     1        'TAPE.')        
      DO 3530 I = 1,5        
      IF (NT(I,1) .NE. 0) GO TO 3530        
      WRITE  (NOUT,3520) NT(I,2),NT(I,3)        
 3520 FORMAT (20X,21HNAME OF DATA BLOCK = ,2A4)        
 3530 CONTINUE        
      IF (P1.EQ.MFIV .OR. P1.EQ.MSIX) GO TO 9995        
C        
 3900 CONTINUE        
      CALL SKPFIL (IN,-1)        
      CALL CLOSE (IN,2)        
      RETURN        
C        
 5000 CONTINUE        
      CALL UNLOAD (IN)        
      RETURN        
C        
C     ERRORS        
C        
 9901 WRITE  (NOUT,9951) SFM,IPTX,IN        
 9951 FORMAT (A25,' 4107, MODULE INPTT',A1,' UNABLE TO OPEN NASTRAN ',  
     1       'FILE ',A4,1H.)        
      GO TO 9995        
C        
 9902 WRITE  (NOUT,9952) SFM,IPTX,OUTPUT        
 9952 FORMAT (A25,' 4108, SUBROUTINE INPTT',A1,' UNABLE TO OPEN OUTPUT',
     1       ' DATA BLOCK',I5)        
      GO TO 9995        
C        
 9904 CALL MESAGE (-2,IFILE,SUBNAM)        
C        
 9905 CALL MESAGE (-3,IFILE,SUBNAM)        
C        
 9906 WRITE  (NOUT,9956) UFM,IPTX,P1,IN,I        
 9956 FORMAT (A22,' 4111, MODULE INPUTT',A1,' IS UNABLE TO SKIP FORWARD'
     1,       I10,' DATA BLOCKS ON PERMANENT NASTRAN FILE ',A4,1H., /5X,
     2        'NUMBER OF DATA BLOCKS SKIPPED =',I5)        
      LINE = LINE + 1        
      GO TO 9995        
C        
 9907 WRITE  (NOUT,9957) UFM,IPTX,P2        
 9957 FORMAT (A23,' 4112, MODULE INPUTT',A1,' - ILLEGAL VALUE FOR ',    
     1        'SECOND PARAMETER =',I20)        
      GO TO 9995        
C        
 9908 WRITE  (NOUT,9958) UFM,IPTX,P1        
 9958 FORMAT (A23,' 4113, MODULE INPUTT',A1,' - ILLEGAL VALUE FOR ',    
     1       'FIRST PARAMETER =',I20)        
      GO TO 9995        
C        
 9909 WRITE  (NOUT,9959) UFM,IN        
 9959 FORMAT (A23,' 4127, USER TAPE ',A4,' NOT SET UP.')        
      GO TO 9995        
C        
 9910 WRITE  (NOUT,9960) UFM,P3X,IPTX,P3        
 9960 FORMAT (A23,' 4136, USER TAPE ID CODE -',2A4,'- DOES NOT MATCH ', 
     1       'THIRD INPUTT',A1,' DMAP PARAMETER -',2A4,2H-.)        
      GO TO 9995        
C        
 9911 WRITE  (NOUT,9961) UFM,IPTX,IN        
 9961 FORMAT (A23,' 4132, MODULE INPUTT',A1,' - END-OF-FILE ENCOUNTERED'
     1,   ' WHILE ATTEMPTING TO READ TAPE ID CODE ON USER TAPE ',A4,1H.)
      GO TO 9995        
C        
 9912 WRITE  (NOUT,9962) UFM,IPTX,IN        
 9962 FORMAT (A23,' 4133, MODULE INPUTT',A1,' - END-OF-RECORD ',        
     1       'ENCOUNTERED WHILE ATTEMPTING TO READ TAPE ID CODE ON ',   
     2       'USER TAPE ',A4,1H.)        
      GO TO 9995        
C        
 9913 WRITE  (NOUT,9963) UFM,IPTX,IDHDRX        
 9963 FORMAT (A23,' 4134, MODULE INPUTT',A1,        
     1        ' - ILLEGAL TAPE CODE HEADER = ',7A4)        
      GO TO 9995        
C        
 9914 WRITE  (NOUT,9964) UWM,P3X,P3        
 9964 FORMAT (A25,' 4135, USER TAPE ID CODE -',2A4,'- DOES NOT MATCH ', 
     1        'THIRD INPUTT1 DMAP PARAMETER -',2A4,2H-.)        
      LINE = LINE + 2        
      GO TO 2006        
C        
 9915 WRITE  (NOUT,9965) SFM,IPTX        
 9965 FORMAT (A25,' 4106, MODULE INPUTT',A1,' - SHORT RECORD.')        
      GO TO 9995        
C        
 9916 WRITE  (NOUT,9966) UFM        
 9966 FORMAT (A23,' 4142, ONE OR MORE DATA BLOCKS NOT FOUND ON USER ',  
     1       'TAPE',/)        
      DO 9917 I = 1,5        
      IF (NT(I,1) .NE. 0) GO TO 9917        
      WRITE (NOUT,9967) NT(I,2),NT(I,3)        
      LINE = LINE + 1        
 9917 CONTINUE        
 9967 FORMAT (20X,'NAME OF DATA BLOCK = ',2A4)        
      GO TO 9995        
C        
 9918 WRITE  (NOUT,9968) UFM,P3        
 9968 FORMAT (A23,', ILLEGAL TAPE LABEL NAME -',2A4,'-  POSSIBLY ',     
     1       'THE 4TH PARAMETER OF INPTT4 IS IN ERROR')        
C        
C        
 9995 LINE = LINE + 2        
      CALL MESAGE (-61,0,0)        
      RETURN        
C        
      END        
