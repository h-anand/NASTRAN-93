      SUBROUTINE XGPIBS        
C        
C     PURPOSE OF THIS ROUTINE IS TO INITIALIZE MACHINE DEPENDENT        
C     CONSTANTS FOR XGPI AND ASSOCIATED ROUTINES AND TO INITIALIZE      
C     THE MODULE LINK TABLE.        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      DIMENSION       OPBUFF(1),PGHDG(113),HDG1(32),HDG2(32),LNKEDT(15),
     1                ENDDTA(2),OPNCOR(1),UTILTY(1),NWPTYP(6),LL(15),   
     2                NONE(2),LNKSPC(1),INBUFF(20),MODNAM(2),OS(2)      
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /MACHIN/ IJHALF(4),MCHNAM        
      COMMON /SYSTEM/ XSYS(90),LPCH        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI2 / LMPL,MPLPNT,MPL(1)        
      COMMON /XGPI2X/ IXX(1)        
      COMMON /XLINK / LXLINK,MAXLNK,MLINK(1)        
      COMMON /XLKSPC/ LLINK,LINK(1)        
      COMMON /OUTPUT/ PGHDG        
      COMMON /LHPWX / LHPW(2),NWPIC        
      COMMON /XGPIC / A(22),NCPW,NBPC,NWPC,MASKHI,MASKLO,ISGNON,NOSGN,  
     1                IALLON,MASKS(1)        
      COMMON /XGPID / B(7),ITAPE,IAPPND,INTGR,LOSGN,NOFLGS,SETEOR,      
     1                EOTFLG,IEQFLG,CPNTRY(7),JMP(7)        
      COMMON /XGPI6 / D(5),IPLUS        
      EQUIVALENCE     (XSYS( 2) ,OPTAP )  ,(XSYS(9) ,NLPP ) ,        
     1                (XSYS(12) ,NLINES)  ,(XSYS(4) ,INTAP) ,        
     2                (OPNCOR(1),LNKSPC(1),OPBUFF(1),OS(2)  ,UTILTY(1)) 
     3,               (CORE(1)  ,OS(1)    ,LOPNCR)        
      DATA    MODNAM/ 4HCHKP,4HNT  /        
      DATA    DELETE/ 4HDELE       /,  XNONE /4HNONE/        
      DATA    ENDDTA/ 4HENDD,4HATA /,  DOLSGN/4H$   /        
C        
C             NWPTYP = NUMBER OF WORDS PER PARAMETER TYPE CODE        
C                        INT,   REAL,   BCD,   D.P.,   CMPLX,  D.P.CMPLX
      DATA    NWPTYP/      1,      1,     2,      2,       2,     4   / 
      DATA    NBLANK/ 4H    /, NONE/4H(NON,4HE)  /        
      DATA    LNKEDT/ 4H  1 ,4H  2 ,4H  3 ,4H  4 ,4H  5 ,4H  6 ,4H  7 , 
     1        4H  8 , 4H  9 ,4H 10 ,4H 11 ,4H 12 ,4H 13 ,4H 14 ,4H 15 / 
      DATA    HDG1  / 4HMODU,4HLE -,4H DMA,4HP NA,4HME -,4H MOD,4HULE , 
     1        4HENTR, 4HY - ,4HLINK,4HS MO,4HDULE,4H RES,4HIDES,4H IN , 
     2        4HON  , 16*4H        /        
      DATA    HDG2  / 4HINDE,4HX   ,4H OF ,4HMODU,4HLE  ,4H POI,4HNT N, 
     1        4HAME , 24*4H        /        
C        
C     INITIALIZE MACHINE DEPENDENT CONSTANTS FOR XGPI        
C     SEE SUBROUTINE XGPIDD FOR DESCRIPTION OF CONSTANTS.        
C        
C     INITIALIZE  /XGPIC/        
C        
C     NCPW   = NUMBER OF CHARACTERS PER WORD        
C     NBPC   = NUMBER OF BITS PER CHARACTER        
C     NWPC   = NUMBER OF WORDS PER CARD = NWPIC        
C                 7094         360        1108             6600        
C    MASKLO = 017777600000, 7FFF0000, 017777600000, 00000000017777600000
C    ISGNON = 400000000000, 80000000, 400000000000, 40000000000000000000
C    NOSGN  = 377777777777, 7FFFFFFF, 377777777777, 37777777777777777777
C    IALLON = 777777777777, FFFFFFFF, 777777777777, 77777777777777777777
C        
C    MASKHI = MASK FOR LOW ORDER 16 BITS AND SIGN BIT = 32767,        
C             INITIALIZED IN XGPIDD        
C        
      NCPW   = XSYS(41)        
      NBPC   = XSYS(39)        
      NWPC   = NWPIC        
      MASKLO = LSHIFT(MASKHI,16)        
      ISGNON = LSHIFT(1,XSYS(40)-1)        
      NOSGN  = COMPLF(ISGNON)        
      IALLON = COMPLF(0)        
C        
C     GENERATE MASKS ARRAY        
C     MASK IS IN 4 PARTS - MASK DESCRIPTION WILL BE GIVEN IN TERMS OF   
C                          IBM 360        
C     PART 1 - FFOOOOOO,OOFFOOOO,OOOOFFOO,OOOOOOFF        
C     PART 2 - COMPLEMENT OF PART 1        
C     PART 3 - FFFFFFFF,OOFFFFFF,OOOOFFFF,OOOOOOFF        
C     PART 4 - COMPLEMENT OF PART 3        
C        
      MHIBYT = LSHIFT(IALLON,NBPC*(NCPW-1))        
      DO 10 J = 1,NCPW        
      MASKS(J) = RSHIFT(MHIBYT,NBPC*(J-1))        
      J2 = J + NCPW        
      MASKS(J2) = COMPLF(MASKS(J))        
      J3 = 2*NCPW + J        
      MASKS(J3) = RSHIFT(IALLON,NBPC*(J-1))        
      J4 = 3*NCPW + J        
      MASKS(J4) = COMPLF(MASKS(J3))        
   10 CONTINUE        
C        
C     INITIALIZE  /XGPID/        
C        
C                 7094         360        1108             6600        
C    ITAPE  = 000000100000, 00008000, 000000100000, 00000000000000100000
C    IAPPND = 010000000000, 40000000, 010000000000, 00000000010000000000
C    INTGR  = 400000000001, 80000001, 400000000001, 40000000000000000001
C    LOSGN  = 000000100000, 00008000, 000000100000, 00000000000000100000
C    NOFLGS = 000377777777, 03FFFFFF, 000377777777, 00000000000377777777
C    SETEOR = 004000000000, 20000000, 004000000000, 00000000004000000000
C    EOTFLG = 010000000000, 40000000, 010000000000, 00000000010000000000
C    IEQFLG = 400000000000, 80000000, 400000000000, 40000000000000000000
C    CPNTRY(3) = CHKPNT MODULE INDEX/TYPE CODE        
C    NTRY(6)= 400000000001, 80000001, 400000000001, 40000000000000000001
C    JMP(3) = JUMP MODULE INDEX/TYPE CODE        
C        
      ITAPE  = LSHIFT(1,15)        
      IAPPND = LSHIFT(1,30)        
      INTGR  = ORF(ISGNON,1)        
      LOSGN  = LSHIFT(1,15)        
      NOFLGS = RSHIFT(IALLON,XSYS(40)-26)        
      SETEOR = LSHIFT(1,29)        
      EOTFLG = LSHIFT(1,30)        
      IEQFLG = ISGNON        
C        
C     PRINT MPL CONTENTS IF DIAG 31 IS ON        
C        
      ASSIGN 40 TO IRTN        
      CALL SSWTCH (31,L)        
      IF (L .NE. 0) CALL MPLPRT        
C        
C     GET CHKPNT MODULE INDEX        
C        
   20 MODIDX = 1        
      MPLPNT = 1        
   30 IF (MPL(MPLPNT+1).EQ.MODNAM(1) .AND. MPL(MPLPNT+2).EQ.MODNAM(2))  
     1    GO TO IRTN, (40,50)        
      MODIDX = MODIDX + 1        
      MPLPNT = MPLPNT + MPL(MPLPNT)        
      IF (MPLPNT.GT.LMPL .OR. MPL(MPLPNT).LT.1) GO TO 1240        
      GO TO 30        
   40 CPNTRY(3) = LSHIFT(MODIDX,16) + 4        
C        
C     GET JUMP MODULE INDEX        
C        
      ASSIGN 50 TO IRTN        
      MODNAM(1) = JMP(4)        
      MODNAM(2) = JMP(5)        
      GO TO 20        
   50 JMP(3)    = LSHIFT(MODIDX,16) + 3        
      CPNTRY(6) = ORF(ISGNON,1)        
      JMP(6)    = CPNTRY(6)        
C        
C     COMPUTE LENGTH OF OPENCORE (SUBTRACT OFF SOME FOR UTILITY BUFFERS)
C        
      LOPNCR = KORSZ(OPNCOR) - XSYS(1) - 1        
      UTLTOP = LOPNCR + 1        
      UTLBOT = UTLTOP + XSYS(1) - 1        
C        
C     INITIALIZE  /XGPI2/ (I.E. MPL TABLE)        
C        
C     LOAD FLOATING POINT NUMBERS INTO MPL FROM ARRAY IN /XGPI2X/       
C        
      MPLPNT = 1        
   60 IF (MPL(MPLPNT) .LT. 4) GO TO 150        
      IF (MPL(MPLPNT+3).LT.1 .OR. MPL(MPLPNT+3).GT.2) GO TO 150        
C        
C     MPL ENTRY HAS MODULE TYPE CODE 1 OR 2 - PROCESS PARAMETER SECTION.
C        
      I = MPLPNT + 7        
C        
C     CHECK FOR END OF MPL ENTRY        
C        
   70 IF (I .GE. MPLPNT+MPL(MPLPNT)) GO TO 150        
C        
C     CHECK VALIDITY OF PARAMETER TYPE CODE        
C        
      J = IABS(MPL(I))        
      IF (J.LT.1 .OR. J.GT.6) GO TO 1230        
      L = 1        
C        
C     SEE IF PARAMETER VALUE FOLLOWS TYPE CODE.        
C        
      IF (MPL(I) .LT. 0) GO TO 100        
C        
C     GET LENGTH OF PARAMETER VALUE TO BE LOADED.        
C        
      L = NWPTYP(J)        
C        
C     A VALUE FOLLOWS IF TYPE CODE IS INTEGER OR BCD - OTHERWISE AN     
C     INDEX INTO A TABLE CONTAINING THE VALUE FOLLOWS THE TYPE CODE.    
C        
      IF (J.EQ.1 .OR. J.EQ.3) GO TO 90        
C        
C     GET INDEX INTO VALUE TABLE - NOTE INDEX MUST BE CONVERTED FROM    
C     DOUBLE PRECISION INDEX TO ONE DIMENSIONAL INDEX.        
C        
      M  = MPL(I+1)*2 - 1        
      DO 80 K = 1,L        
      N  = K + M - 1        
      K1 = I + K        
   80 MPL(K1) = IXX(N)        
   90 I  = I + 1        
C        
C     INCREMENT TO NEXT PARAMETER TYPE CODE.        
C        
  100 I  = I + L        
      GO TO 70        
C        
C     GET NEXT MPL ENTRY        
C        
  150 IF (MPL(MPLPNT)+MPLPNT .GT. LMPL) GO TO 160        
      MPLPNT = MPLPNT + MPL(MPLPNT)        
      IF (MPL(MPLPNT) .LT. 1) GO TO 1240        
      GO TO 60        
  160 CONTINUE        
C        
C     INITIALIZE /XLINK/        
C        
C     MAXLNK = MAXIMUM NUMBER OF LINKS THAT CAN BE HANDLED. IF MAXLNK IS
C              INCREASED THEN LNKEDT TABLE MUST BE INCREASED.        
C              (MAXLNK WAS SET IN SEMDBD ROUTINE)        
C        
C     MOVE LINK TABLE INTO OPEN CORE        
C        
      LNKTOP = 1        
      LNKBOT = LLINK + LNKTOP - 5        
      DO 200 J = 1,LLINK        
  200 LNKSPC(J) = LINK(J)        
C        
C     UPDATE LNKSPC TABLE IF SENSE SWITCH 29 IS ON        
C        
      CALL SSWTCH (29,L)        
      IF (L .EQ. 0) GO TO 600        
      ASSIGN 280 TO IRTN        
C        
C     PROCESS INPUT CARD (NOTE-DO NOT USE VARIABLES I,J OR M)        
C        
  210 CALL PAGE1        
      NLINES = NLINES + 2        
      WRITE  (OPTAP,220)        
  220 FORMAT (42H0LINK SPECIFICATION TABLE UPDATE DECK ECHO )        
  230 NLINES = NLINES + 1        
      IF (NLINES .GE. NLPP) GO TO 210        
      CALL XREAD (*240,INBUFF)        
      GO TO 260        
  240 CALL PAGE2 (2)        
      WRITE  (OPTAP,250) UFM        
  250 FORMAT (A23,' 220, MISSING ENDDATA CARD.')        
      GO TO 1250        
  260 CONTINUE        
      WRITE  (OPTAP,270) INBUFF        
  270 FORMAT (5X,20A4)        
C        
C     CHECK FOR COMMENT CARD        
C        
      IF (KHRFN1(0,1,INBUFF(1),1) .EQ. KHRFN1(0,1,DOLSGN,1)) GO TO 230  
C        
C     CONVERT CARD IMAGE        
C        
      CALL XRCARD (UTILTY(UTLTOP),UTLBOT-UTLTOP+1,INBUFF)        
      IF (UTILTY(UTLTOP) .EQ. 0) GO TO 230        
C        
C     CHECK FOR ENDDATA CARD        
C        
      IF (UTILTY(UTLTOP+1).EQ.ENDDTA(1) .AND.        
     1    UTILTY(UTLTOP+2).EQ.ENDDTA(2)) GO TO 380        
      GO TO IRTN, (280,330)        
C        
C     CHECK FORMAT OF CARD        
C        
  280 IF (UTILTY(UTLTOP) .LT. 2) GO TO 1220        
C        
C     SEE IF MODULE NAME IS IN LNKSPC TABLE        
C        
      DO 290 I = LNKTOP,LNKBOT,5        
      IF (LNKSPC(I  ).EQ.UTILTY(UTLTOP+1) .AND.        
     1    LNKSPC(I+1).EQ.UTILTY(UTLTOP+2)) GO TO 300        
  290 CONTINUE        
C        
C     MODULE IS NOT IN LNKSPC - MAKE NEW ENTRY        
C        
      LNKBOT = LNKBOT + 5        
      IF (LNKBOT .GT. LOPNCR) GO TO 1200        
      I = LNKBOT        
C        
C     TRANSFER MODULE NAME AND ENTRY POINT TO LNKSPC        
C        
  300 LNKSPC(I  ) = UTILTY(UTLTOP+1)        
      LNKSPC(I+1) = UTILTY(UTLTOP+2)        
      LNKSPC(I+2) = UTILTY(UTLTOP+3)        
      LNKSPC(I+3) = UTILTY(UTLTOP+4)        
C        
C     CHECK FOR DELETE OR NONE        
C        
      IF (UTILTY(UTLTOP  ) .EQ.      2) GO TO 320        
      IF (UTILTY(UTLTOP+5) .EQ. DELETE) GO TO 310        
      IF (UTILTY(UTLTOP+5) .NE.  XNONE) GO TO 1220        
C        
C     MODULE HAS NO ENTRY POINT        
C        
      LNKSPC(I+2) = NONE(1)        
      LNKSPC(I+3) = NONE(2)        
      M = 0        
      J = 7        
      IF (UTILTY(UTLTOP+7) .NE. -1) J = 9        
      GO TO 330        
C        
C     MODULE IS TO BE DELETED        
C        
  310 LNKSPC(I) = 0        
      GO TO 370        
C        
C     GENERATE A LINK FLAG WORD        
C        
  320 M = 0        
      J = 5        
C        
C     CHECK MODE WORD        
C        
  330 K = UTLTOP + J        
      IF (UTILTY(K)) 340,350,360        
C        
C     INTEGER FOUND        
C        
  340 IF (UTILTY(K) .NE. -1) GO TO 1220        
      M = ORF(M,LSHIFT(1,UTILTY(K+1)-1))        
      J = J + 2        
      GO TO 330        
C        
C     CONTINUE MODE FOUND        
C        
  350 J = 1        
      ASSIGN 330 TO IRTN        
      GO TO 230        
C        
C     END OF INSTRUCTION FOUND        
C        
C     TRANSFER GENERATED LINK WORD TO LNKSPC ENTRY        
C        
  360 IF (UTILTY(K) .NE. NOSGN) GO TO 1220        
      J = I + 4        
      LNKSPC(J) = M        
C        
C     PROCESS NEXT INPUT CARD        
C        
  370 ASSIGN 280 TO IRTN        
      GO TO 230        
C        
C     PUNCH OUT LNKSPC TABLE IF SENSE SWITCH 28 IS ON.        
C        
  380 CALL SSWTCH (28,L)        
      IF (L .EQ. 0) GO TO 600        
C        
C     ELIMINATE DELETED LNKSPC ENTRIES        
C        
  390 DO 400 I = LNKTOP,LNKBOT,5        
      IF (LNKSPC(I) .EQ. 0) GO TO 410        
  400 CONTINUE        
      GO TO 430        
  410 K = I + 4        
      N = LNKBOT - 1        
      DO 420 M = I,K        
      N = N + 1        
      LNKSPC(M) = LNKSPC(N)        
  420 CONTINUE        
      LNKBOT = LNKBOT - 5        
      GO TO 390        
  430 CALL PAGE2 (2)        
      WRITE  (OPTAP,440)        
  440 FORMAT (98H0***USER REQUESTS LINK SPECIFICATION TABLE BE PUNCHED O
     1UT FOR USE IN RECOMPILING SUBROUTINE XLNKDD )        
      WRITE  (LPCH,450)        
  450 FORMAT (70(1H*),/38HLINK SPEC. TABLE FOR SUBROUTINE XLNKDD )      
      J  = LNKBOT - LNKTOP + 5        
      N  = J/90        
      WRITE  (LPCH,460) J        
  460 FORMAT (6X,16HDIMENSION LINK (,I4,1H))        
      K  = 90        
      IF (N .EQ. 0) GO TO 490        
      DO 480 I = 1,N        
      I10= I/10        
      I1 = I - 10*I10        
      WRITE  (LPCH,470) I10,I1,K        
  470 FORMAT (5X,2H1,,9X,4HLINK,2I1,1H(,I4,1H))        
  480 CONTINUE        
  490 K  = MOD(J,90)        
      I  = N + 1        
      I10= I/10        
      I1 = I - 10*I10        
      IF (K .GT. 0) WRITE (LPCH,470) I10,I1,K        
      WRITE  (LPCH,500) J        
  500 FORMAT (6X,28HCOMMON/XLKSPC/ LLINK, KLINK(,I4,1H),/,        
     1        6X,34HEQUIVALENCE (LINK(   1),LINK01(1)) )        
      IF (K .GT. 0) N = N + 1        
      IF (N .LT. 2) GO TO 530        
      DO 520 I = 2,N        
      I10= I/10        
      I1 = I - 10*I10        
      K  = 90*(I-1) + 1        
      WRITE  (LPCH,510) K,I10,I1        
  510 FORMAT (5X,2H1,,11X,6H(LINK( ,I4,6H),LINK ,2I1,4H(1)))        
  520 CONTINUE        
  530 CONTINUE        
      J  = LNKTOP - 1        
      M  = 0        
  540 J  = J + 1        
      M  = M + 1        
      M10= M/10        
      M1 = M - 10*M10        
      K  = MIN0(J+89,LNKBOT+4)        
      WRITE  (LPCH,550) M10,M1,(LNKSPC(I),I=J,K)        
  550 FORMAT (6X,9HDATA LINK,2I1,1H/, /,        
     1        5X,4H1 4H,A4,3H,4H,A4,4H, 4H,A4,3H,4H,A4,1H,,I6,/,        
     2       (5X,4H1,4H,A4,3H,4H,A4,4H, 4H,A4,3H,4H,A4,1H,,I6))        
      WRITE  (LPCH,560)        
  560 FORMAT (5X,2H1/)        
      J = K        
      IF (J .LT. LNKBOT+4) GO TO 540        
      J = LNKBOT - LNKTOP + 5        
      WRITE  (LPCH,570) J        
  570 FORMAT (6X,8HLLINK = ,I4)        
C        
C     INITIALIZE PAGE HEADING        
C        
  600 DO 610 I = 1,32        
      PGHDG(I+ 96) = HDG1(I)        
      PGHDG(I+128) = HDG2(I)        
  610 PGHDG(I+160) = NBLANK        
      PGHDG(  113) = MCHNAM        
      NLINES = NLPP        
C        
C     INITIALIZE O/P BUFFER PARAMETERS - O/P BUFFERS ARE IN OPEN CORE   
C        
      OPBTOP = LNKBOT + 5        
      NXTLIN = OPBTOP - 20        
C        
C     GET FIRST/NEXT MPL ENTRY        
C        
      MPLPNT = 1        
      MODIDX = 1        
C        
C     CHECK FOR DECLARATIVE OR NULL ENTRY        
C        
  620 IF (MPL(MPLPNT+3).GT.4 .OR. MPL(MPLPNT+3).LT.1) GO TO 630        
      GO TO 700        
  630 IF (MPL(MPLPNT) .LT. 1) GO TO 800        
      MPLPNT = MPLPNT + MPL(MPLPNT)        
      MODIDX = MODIDX + 1        
      IF (MPLPNT .LT. LMPL) GO TO 620        
      GO TO 800        
C        
C     PREPARE TO GENERATE NEXT LINE OF OUTPUT        
C        
  700 NXTLIN = NXTLIN + 20        
      I  = NXTLIN + 19        
      IF (I .GT. LOPNCR) GO TO 1240        
      DO 710 J = NXTLIN,I        
  710 OPBUFF(J) = NBLANK        
C        
C     MODULE INDEX INTO WORD 1 OF O/P ENTRY        
C        
      OPBUFF(NXTLIN) = MODIDX        
C        
C     DMAP NAME TO WORDS 2,3 OF O/P ENTRY        
C        
      OPBUFF(NXTLIN+1) = MPL(MPLPNT+1)        
      OPBUFF(NXTLIN+2) = MPL(MPLPNT+2)        
C        
C     GET ENTRY POINT NAME AND ENTER IN WORDS 4,5 OF O/P ENTRY        
C        
      OPBUFF(NXTLIN+3) = NONE(1)        
      OPBUFF(NXTLIN+4) = NONE(2)        
      DO 720 I = LNKTOP,LNKBOT,5        
      IF (LNKSPC(I).EQ.MPL(MPLPNT+1) .AND. LNKSPC(I+1).EQ.MPL(MPLPNT+2))
     1    GO TO 730        
  720 CONTINUE        
      GO TO 630        
  730 OPBUFF(NXTLIN+3) = LNKSPC(I+2)        
      OPBUFF(NXTLIN+4) = LNKSPC(I+3)        
C        
C     EXAMINE LINK FLAG        
C        
      L = LNKSPC(I+4)        
      DO 740 J = 1,MAXLNK        
      IF (ANDF(L,LSHIFT(1,J-1)) .EQ. 0) GO TO 740        
C        
C     MODULE IS IN LINK J - SET BIT J IN MAIN LINK TABLE AND O/P BUFFER 
C     MAKE SURE LINK TABLE IS LONG ENOUGH.        
C        
      IF (LXLINK .LT. MODIDX) GO TO 1210        
      MLINK(MODIDX) = ORF(MLINK(MODIDX),LSHIFT(1,J-1))        
      K = NXTLIN + J + 4        
      OPBUFF(K) = LNKEDT(J)        
  740 CONTINUE        
      GO TO 630        
C        
C     SEE IF O/P BUFFER IS TO BE PRINTED (I.E. SENSE SWITCH 31 IS ON)   
C        
  800 CALL SSWTCH (31,L)        
      IF (L .NE. 0) GO TO 810        
C        
C     PRINT O/P BUFFER IF LINK DRIVER PUNCHED O/P  REQUESTED(I.E. SENSE 
C     SWITCH 30 IS ON)        
C        
      CALL SSWTCH (30,L)        
      IF (L .EQ. 0) RETURN        
  810 DO 830 I = OPBTOP,NXTLIN,20        
      NLINES = NLINES + 1        
      IF (NLINES .GE. NLPP) CALL PAGE        
      J = I + 19        
      WRITE  (OPTAP,820) (OPBUFF(K),K=I,J)        
  820 FORMAT (5X,I6,3X,2A4,4X,2A4,7X,15A4)        
  830 CONTINUE        
C        
C     SEE IF ANY DRIVERS SHOULD BE PUNCHED  (I.E. SENSE SWITCH 30 ON)   
C        
      CALL SSWTCH (30,L)        
      IF (L .EQ. 0) RETURN        
      CALL PAGE1        
      NLINES = NLINES + 2        
      WRITE  (OPTAP,910)        
  910 FORMAT ('0USER REQUESTS PUNCHED OUTPUT FOR THE FOLLOWING LINK ',  
     1        'DRIVER SUBROUTINES')        
      WRITE  (LPCH,920)        
  920 FORMAT (70(1H*), /,' INSERT FOLLOWING FORTRAN CODE IN RESPECTIVE',
     1       ' LINK DRIVER ROUTINES')        
      DO 1170 J = 1,MAXLNK        
      CALL SSWTCH (J,L)        
      IF (L .EQ. 0) GO TO 1170        
      J10= J/10        
      J1 = J - 10*J10        
      WRITE  (LPCH,930) J10,J1,J        
  930 FORMAT (70(1H*), /6X,15HSUBROUTINE XSEM,2I1, /6X,12HDATA THISLK,  
     1        /,I2,1H/)        
      WRITE  (LPCH,940) J10,J1        
  940 FORMAT (6X,21HDATA SUBNAM/4HXSEM,4H,2I1,3H  /)        
      NLINES = NLINES + 2        
      IF (NLINES .GE. NLPP) CALL PAGE        
      WRITE  (OPTAP,950) J10,J1        
  950 FORMAT (9H0    XSEM,2I1)        
C        
C     USER REQUESTS PUNCHED O/P FOR LINK J        
C     SEARCH LINK TABLE FOR MODULES RESIDING IN LINK J        
C        
      FRSTIN = 0        
      L      = 0        
      LASTIN = 0        
      NXTGRP = 1000        
      DO  1100 I = 1,LXLINK        
      LL(L+1) = 940        
      IF (ANDF(MLINK(I),LSHIFT(1,J-1)) .NE. 0) LL(L+1) = 2000 + I       
      IF (I - LASTIN) 980,990,960        
  960 IF (FRSTIN.LE.0 .AND. LL(L+1).EQ.940) GO TO 1100        
      FRSTIN = I        
      LASTIN = MIN0(I+180,LXLINK)        
      LSTGRP = NXTGRP        
      NXTGRP = NXTGRP - 5        
  970 FORMAT (I5,8H GO TO (  )        
  980 L = L + 1        
      IF (LL(L) .NE. 940) GO TO 1000        
C        
C     ONLY TWO CONSECUTIVE BRANCHES TO 940 IN COMPUTED  -GO TO -        
C        
      IF (LAST+2 .GE. I) GO TO 1010        
      LASTIN = LAST        
      L      = MAX0(0,L-1+LASTIN-I)        
  990 LL(15) = LL(L+1)        
      IF (L) 1050,1050,1020        
 1000 LAST = I        
 1010 IF (L .LT. 13) GO TO 1100        
 1020 IF (FRSTIN .EQ. LL(1)-2000) WRITE (LPCH,970) NXTGRP        
      LK = MIN0(L,10)        
      WRITE  (LPCH,1030) (LL(K),K=1,LK)        
 1030 FORMAT (5X,1H1,10(I5,1H,))        
      L  = L - LK        
      DO 1040 K = 1,L        
 1040 LL(K) = LL(K+10)        
      IF (I .LT. LASTIN) GO TO 1100        
 1050 LAST = NXTGRP + 15        
      IF (I .EQ. LXLINK) LAST = 970        
      IF (FRSTIN .EQ. LASTIN) GO TO 1070        
      FRSTIN = FRSTIN - 1        
      WRITE  (LPCH,1060) LL(15),LSTGRP,LASTIN,LAST,FRSTIN,NXTGRP        
 1060 FORMAT (5X, 1H1, I5, 4H ),I ,/,        
     1        I5, 14H IF (MODX .GT. ,I3, 8H) GO TO ,I5, /,        
     1        6X, 10HI = MODX - , I3, /,        
     1        6X, 17HIF (I ) 940, 940, ,I5)        
      GO TO 1090        
 1070 WRITE  (LPCH,1080) LSTGRP,FRSTIN,LL(15),LAST        
 1080 FORMAT (I5,12H IF (MODX - ,I3,7H ) 940,,I5,1H,,I5)        
 1090 NXTGRP = LAST        
      FRSTIN = -1        
 1100 CONTINUE        
C        
C     PUNCH OUT GO TO AND IF STATEMENTS FOR LAST GROUP OF MODULES IN    
C     LINK J.        
C        
      IF (FRSTIN .NE. 0) GO TO 1120        
C        
C     CANNOT FIND ANY MODULES IN THIS LINK        
C        
      NLINES = NLINES + 2        
      WRITE  (OPTAP,1110) J        
 1110 FORMAT (1H0,10X,29HTHERE ARE NO MODULES IN LINK  ,I3)        
      GO TO 1170        
 1120 IF (LAST .NE. 970) WRITE (LPCH,1130) NXTGRP        
 1130 FORMAT (I5,34H IF (MODX - LXLINK ) 940, 940, 970 )        
C        
C     SEARCH O/P BUFFER FOR MODULES RESIDING IN LINK J        
C        
      DO 1160 I = OPBTOP,NXTLIN,20        
      K = I + 4 + J        
      IF (OPBUFF(K) .EQ. NBLANK) GO TO 1160        
C        
C     THIS MODULE IS IN LINK J - PUNCH OUT CALL AND GO TO STATEMENT     
C        
      N = 2000 + OPBUFF(I)        
      WRITE  (LPCH,1150) N,OPBUFF(I+3),OPBUFF(I+4)        
 1150 FORMAT (I5,1X,5HCALL ,2A4,/6X,8HGO TO 10)        
 1160 CONTINUE        
 1170 CONTINUE        
      J = LLINK/8        
      IF (J .GT. LXLINK) CALL PAGE2 (-3)        
      IF (J .GT. LXLINK) WRITE (OPTAP,1180) SWM,J,LXLINK        
 1180 FORMAT (A27,' 54, THE NUMBER OF MODULES SPECIFIED IN THE LINK ',  
     1       'SPECIFICATION TABLE,',I5, /20X,'EXCEEDS THE ALLOWABLE ',  
     2       'NUMBER SPECIFIED BY SEMDBD,',I5,1H.)        
      CALL PEXIT        
C        
C     ERROR MESSAGES -        
C        
C     NOT ENOUGH OPEN CORE        
C        
 1200 CALL XGPIDG (51,LNKBOT-LOPNCR,0,0)        
      GO TO 1250        
C        
C     NAMED COMMON /XLINK/ IS TOO SMALL        
C        
 1210 CALL XGPIDG (52,0,0,0)        
      RETURN        
C        
C     INCORRECT FORMAT IN ABOVE CARD.        
C        
 1220 CALL XGPIDG (53,0,0,0)        
      ASSIGN 280 TO IRTN        
      GO TO 230        
C        
C     ERROR IN PARAMETER SECTION OF MPL TABLE        
C        
 1230 CALL XGPIDG (49,MPLPNT,MPL(MPLPNT+1),MPL(MPLPNT+2))        
      GO TO 150        
C        
C     FATAL ERROR IN MPL TABLE        
C        
 1240 CALL XGPIDG (49,MPLPNT,MPL(MPLPNT+1),MPL(MPLPNT+2))        
      GO TO 1250        
C        
C     FATAL ERROR EXIT        
C        
 1250 XSYS(3) = 3        
      RETURN        
      END        
