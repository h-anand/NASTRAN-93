      SUBROUTINE TRNSP (CORE)        
C        
C     OUT-OF-CORE MATRIX TRANSPOSE USING 1 TO 8 SCRATCH FILES - NASTRAN 
C     ORIGINAL ROUTINE.        
C        
C     (SEE TRANSP FOR IN-CORE MATRIX TRANSPOSE FOR UPPER TRIAG. MATRIX, 
C      AND TRNSPS FOR OUT-OF-CORE MATRIX TRANSPOSE WITH 1 SCRATCH FILE, 
C      A NASTRAN NEW ROUTINE)        
C        
C     REVERT TO NASTRAN ORIGINAL TRNSP IF DIAG 41 IS ON, OR 94TH WORD OF
C     /SYSTEM/ IS 1000. OTHERWISE SEND THE TRANSPOSE JOB TO THE NEW     
C     TRNSPS ROUTINE, EXECPT LOWER AND UPPER TRIANGULAR MATRICES        
C        
      INTEGER         SCRTH,OTPE,SYSBUF,TRB1        
      DIMENSION       CORE(1),TRB1(7,8),A(2),IPARM(2),NAME(2),ZERO(4)   
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /TRNSPX/ NAMEA ,NCOLA ,NROWA ,IFORMA,ITYPA ,IA(2),        
     1                NAMEAT,NCOLAT,NROWAT,IFORAT,ITYPAT,IAT(2),        
     2                LCARE,NSCRH,SCRTH(8)        
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ SYSBUF,OTPE,SKIP(91),KSYS94        
      COMMON /PACKX / IOTYP,IOTYPA,II,JJ,INCR        
      COMMON /UNPAKX/ IOTYP1,IS1,NROW1,INCR1        
      DATA    IPARM / 4HTRAN,4HPOSE/, ZERO / 4*0.0   /        
      DATA    NAME  / 4HTRNS,4HP   /        
C        
      IF (NSCRH .NE. 8) CALL CONMSG (IPARM,2,0)        
      IAT(1) = 0        
      IAT(2) = 0        
      INCR1  = 1        
      II     = 1        
      IF (ITYPAT .EQ. 0) ITYPAT = ITYPA        
      IOTYP  = MIN0(ITYPAT,ITYPA)        
      IOTYPA = IOTYP        
      IOTYP1 = IOTYP        
      IF (IFORMA.EQ.4 .OR. IFORMA.EQ.5) GO TO 50        
C               LOWER            UPPER TRIANG. MATRICES        
C        
      J = MOD(KSYS94,10000)/1000        
      IF (J .EQ. 1) GO TO 50        
      CALL SSWTCH (41,J)        
      IF (J .EQ. 1) GO TO 50        
C        
C     NASTRAN MAINTENANCE WORK IS DONE ON VAX        
C        
      IF (MACH.NE.5 .OR. IFORMA.LT.3 .OR. IFORMA.EQ.6) GO TO 40        
C               VAX      NOT SQUARE, RECTANG., AND SYMM.        
      CALL FNAME (NAMEA,A)        
      WRITE  (4,30) A,IFORMA        
   30 FORMAT (40X,'MATRIX ',2A4,', FORM =',I2,' ===>TRNSPS')        
   40 NCOLAT = 0        
      NSCRTH = 1        
      CALL TRNSPS (CORE,CORE)        
      GO TO 500        
C        
   50 IPARM1 = NAMEA        
      NSCRTH = NSCRH        
      IM1    = 1        
      NCALAT = NCOLAT        
      NCOLAT = 0        
      IJ1    = 0        
      LAST   = 1        
      NTYPE  = IOTYPA        
      IF (NTYPE .EQ. 3) NTYPE = 2        
      LCORE  = LCARE        
      IBUF1  = LCORE - SYSBUF        
      IBUF   = IBUF1 - SYSBUF        
      LCORE  = IBUF  - 1        
      IF (LCORE) 440,440,70        
C        
C     COMMENT FROM G.CHAN/UNISYS    1/91        
C     ABOUT THE SQUARE OR RECTANGULAR MATRIX TRANSPOSE BY THE VAX -     
C     DATA, 1.0**-10 OR SMALLER, ON THE TRANSPOSED MATRIX MAY DIFFER    
C     FROM THE ORIGINAL VALUES. CAN NOT EXPLAIN WHY.        
C     THE NORMAL DATA, 1.0**+5 OR LARGER, ARE ALL OK.        
C     (NO CHECK ON THE OTHER MACHINES)        
C        
   70 NROWO  = MIN0(NROWAT,NCOLA)        
      NBRUT  = LCORE/(NROWO*NTYPE)        
      IF (NBRUT .EQ. 0) GO TO 440        
      NREM   = NBRUT        
      IF (NBRUT .GT. NCALAT) GO TO 380        
      K = AMAX1(FLOAT(NROWAT)*SQRT(FLOAT(NTYPE)/FLOAT(LCORE)),1.0)      
   80 NROW2 = NBRUT*K        
      NROW  = MIN0(NSCRTH*NROW2,NCALAT)        
      KM    = (NCALAT+NROW-1)/NROW        
      ICOL  = NBRUT*NTYPE        
      IF (LCORE .LT. NROW*NTYPE+(NSCRTH-1)*SYSBUF) GO TO 440        
C        
C     THERE ARE NROW2 ROWS IN EACH SUBMATRIX        
C     WE GENERATE NROW ROWS PER PASS OF FULL MATRIX        
C     THERE WILL BE KM SUCH PASSES        
C        
      IOLOOP = 1        
   90 IF (IJ1) 210,100,210        
  100 IF (IOLOOP .EQ. KM) GO TO 390        
      NROW1 = NROW*IOLOOP        
  110 IS1   = NROW1 - NROW + 1        
      IF (IOLOOP .NE. 1) GO TO 120        
      IPARM1= NAMEA        
      CALL OPEN (*410,NAMEA,CORE(IBUF1),0)        
  120 CALL FWDREC (*420,NAMEA)        
      NL = NROW*NTYPE        
C        
C     OPEN SCRATCHES        
C        
      J = IBUF        
      DO 140 I = 1,NSCRTH        
      IPARM1 = SCRTH(I)        
      CALL OPEN (*410,SCRTH(I),CORE(J),1)        
      J = J - SYSBUF        
      DO 130 III = 1,7        
  130 TRB1(III,I) = 0        
  140 CONTINUE        
      DO 200 ILOOP = 1,NROWO        
      CALL UNPACK (*180,NAMEA,CORE)        
  150 IK = 1        
      JJ = NROW2        
      INCR = 1        
      DO 160 I = 1,NSCRTH        
      CALL PACK (CORE(IK),SCRTH(I),TRB1(1,I))        
      IK = IK + NROW2*NTYPE        
  160 CONTINUE        
C        
C     END LOOP ON BUILDING 1 COL OF SUB MATRICES        
C        
      GO TO 200        
C        
  180 DO 190 I = 1,NL        
  190 CORE(I) = 0.0        
      GO TO 150        
  200 CONTINUE        
      CALL REWIND (NAMEA)        
C        
C     END LOOP ON BUILDING NSCRATH SUB MATRICES        
C        
      DO 201 I = 1,NSCRTH        
      CALL CLOSE (SCRTH(I),1)        
  201 CONTINUE        
  210 DO 350 J = 1,NSCRTH        
      IF (IJ1) 230,220,230        
  220 IF (IOLOOP.NE.KM .OR. J.NE.NSCRTH) GO TO 230        
      LAST = 0        
  230 DO 340 M = 1,K        
      IPARM1 = SCRTH(J)        
      CALL OPEN (*410,SCRTH(J),CORE(IBUF),0)        
      IF (LAST.EQ.1 .OR. NCALAT-NCOLAT.GE.NREM) GO TO 240        
      NBRUT = NCALAT - NCOLAT        
      ICOL  = NBRUT*NTYPE        
      IS1   = (M-1)*NREM + 1        
      NROW1 = IS1 + NBRUT        
      GO TO 270        
  240 IF (IJ1) 250,260,250        
  250 CALL FWDREC (*420,SCRTH(J))        
  260 IS1   = (M-1)*NBRUT + 1        
      NROW1 = NBRUT*M        
  270 L = 1        
      DO 310 I = 1,NROWO        
      CALL UNPACK (*280,SCRTH(J),CORE(L))        
      GO TO 300        
  280 DO 290 NL = 1,ICOL        
      M2 = NL + L - 1        
  290 CORE(M2) = 0.0        
  300 L = L + ICOL        
  310 CONTINUE        
      CALL CLOSE (SCRTH(J),1)        
      IPARM1 = NAMEAT        
      CALL OPEN (*410,NAMEAT,CORE(IBUF),IM1)        
      IF (IM1 .EQ. 3) GO TO 320        
      CALL FNAME (NAMEAT,A(1))        
      CALL WRITE (NAMEAT,A(1),2,1)        
      IM1  = 3        
  320 INCR = NBRUT        
      JJ = NROWO        
      DO 330 L = 1,NBRUT        
      M2 = NTYPE*(L-1) + 1        
      CALL PACK (CORE(M2),NAMEAT,NAMEAT)        
  330 CONTINUE        
      CALL CLOSE (NAMEAT,2)        
C        
C     END LOOP ON SUBMATRIX        
C        
      IF (NCOLAT .GE. NCALAT) GO TO 350        
  340 CONTINUE        
C        
C     END LOOP ON EACH SCRATCH        
C        
  350 CONTINUE        
C        
C     END LOOP ON EACH PASS THROUGH LARGE MATRIX        
C        
      IOLOOP = IOLOOP + 1        
      IF (IOLOOP .LE. KM) GO TO 90        
      IPARM1 = NAMEAT        
      CALL OPEN  (*410,NAMEAT,CORE(IBUF),3)        
      CALL CLOSE (NAMEAT,1)        
      CALL CLOSE (NAMEA, 1)        
      GO TO 500        
C        
C     ONE PASS ONLY        
C        
  380 NSCRTH  = 1        
      SCRTH(1)= NAMEA        
      NBRUT   = NCALAT        
      K   = 1        
      IJ1 = 1        
      IOTYP = ITYPA        
      GO TO 80        
  390 IOVER = NCALAT - (KM-1)*NROW        
      NBRUT = MIN0(NBRUT,IOVER)        
      ICOL  = NBRUT*NTYPE        
      NROW  = IOVER        
      NROW2 = MIN0(NBRUT*K,NROW)        
      K     = (NROW2+NBRUT-1)/NBRUT        
      NSCRTH= MIN0((IOVER+K*NBRUT-1)/(K*NBRUT),NSCRTH)        
      IF (NSCRTH .EQ. 0) NSCRTH =  1        
      NROW1 = NCALAT        
      GO TO 110        
C        
C     ERROR MESSAGES        
C        
  410 N1 = -1        
      GO TO 450        
  420 N1 = -2        
      GO TO 450        
  440 N1 = -8        
  450 CALL MESAGE (N1,IPARM1,NAME)        
C        
C     ONE FINAL CHECK BEFORE RETURN        
C        
  500 IF (IFORMA.EQ.3 .OR. IFORMA.EQ.7) GO TO 520        
      IF (NCOLAT.EQ.NROWA .AND. NROWAT.EQ.NCOLA) GO TO 520        
      CALL FNAME (NAMEA,A)        
      WRITE (OTPE,510) SWM,A,IFORMA,NCOLA,NROWA,IFORAT,NCOLAT,NROWAT    
  510 FORMAT (A27,' FORM TRNSP. TRANSPOSED MATRIX APPEARS IN ERROR',    
     1    /5X,'ORIGINAL ',2A4, ' - FORM =',I3,',  (',I6,' X',I6,')',    
     2    /5X,'TRNASPOSED MATRIX - FORM =',I3,',  (',I6,' X',I6,')')    
  520 IF (NSCRH .NE. 8) CALL CONMSG (IPARM,2,0)        
      RETURN        
      END        
