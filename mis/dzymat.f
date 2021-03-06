      SUBROUTINE DZYMAT (D,NFB,NLB,NTZYS,IDZDY,NTAPE,XP,BETA,IPRNT,NS,  
     1                   NC,YP,ZP,SG,CG,YB,ZB,NBEA)        
C        
C     CALCULATION OF DZ AND DY MATRICES SLENDER BODY CALCULATIONS       
C        
C     D         WORKING ARRAY USED TO STORE A ROW OF DZ OR DY        
C     NFB       NUMBER OF THE FIRST BODY WITH THE ORIENTATION REQUESTED 
C     NLB       NUMBER OF THE LAST BODY WITH THE ORIENTATION        
C               REQUESTED        
C     NTZYS     NUMBER OF Z OR Y ORIENTED SLENDER BODY ELE.        
C     NTAPE     I/O UNIT NUMBER WHICH THE OUTPUT MATRIX IS TO        
C               BE WRITTEN ON        
C     XP        X-CONTROL POINT COORDINATE OF LIFTING SURFACE        
C               BOXES        
C     BETA      SQRT(1.0 - M**2)        
C        
      INTEGER         BY,BZ,C,C1,P,S,S1,YT,ZT        
      DIMENSION       D(2,NTZYS),XP(1),NS(1),NC(1),YP(1),ZP(1),SG(1),   
     1                CG(1),YB(1),ZB(1),NBEA(1)        
      COMMON /DLBDY / NJ1,NK1,NP,NB,NTP,NBZ,NBY,NTZ,NTY,NT0,NTZS,NTYS,  
     1                INC,INS,INB,INAS,IZIN,IYIN,INBEA1,INBEA2,INSBEA,  
     2                IZB,IYB,IAVR,IARB,INFL,IXLE,IXTE,INT121,INT122,   
     3                IZS,IYS,ICS,IEE,ISG,ICG,IXIJ,IX,IDELX,IXIC,IXLAM, 
     4                IA0,IXIS1,IXIS2,IA0P,IRIA,INASB,IFLA1,IFLA2,ITH1A,
     5                ITH2A,ECORE,NEXT,SCR1,SCR2,SCR3,SCR4,SCR5        
CZZ   COMMON /ZZDAMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,KR        
      COMMON /SYSTEM/ SYSBUF,NPOT        
C        
      C1 = 0        
      S1 = 0        
      NFYB = NB - NBY  + 1        
      IF (NP .EQ. 0) GO TO 410        
C        
C     THIS LOOP IS FOR EACH LIFTING SURF. PANEL        
C        
      ISN = 0        
      DO 400 P = 1,NP        
      NSP = NS(P)        
      NCP = NC(P)        
      NSP = (NSP-ISN)/NCP        
      ISN = NS(P)        
C        
C     LOOP FOR EACH STRIP IN PANEL -P-        
C        
      DO 350 S = 1,NSP        
      S1  = S1 + 1        
C        
C     Y AND Z COORDINATE OF STRIP        
C        
      DY  = YP(S1)        
      DZ  = ZP(S1)        
      SGR = SG(S1)        
      CGR = CG(S1)        
C        
C     LOOP FOR EACH CHORDWISE ELEMENT IN STRIP        
C        
      DO 300 C = 1,NCP        
      C1  = C1 + 1        
      DX  = XP(C1)        
C        
C     - ROWDYC -  CALCULATES ROW -C1- OF DZ OR DY        
C        
      CALL ROWDYZ (NFB,NLB,C1,NTZYS,D,DX,DY,DZ,BETA,IDZDY,NTAPE,SGR,    
     1             CGR,IPRNT,YB,ZB,Z(IARB),Z(INSBEA),Z(IXIS1),Z(IXIS2), 
     2             Z(IA0))        
C        
  300 CONTINUE        
  350 CONTINUE        
  400 CONTINUE        
C        
C     WE HAVE NOW CALCULATED -C1- ROWS WHICH ARE THE LIFTING SURFACES.  
C     NOW, LOOP FOR THE -Z- ORIENTED BODIES        
C        
  410 CONTINUE        
      IF (NBZ.LE.0 .OR. NTZ.LE.0) GO TO 510        
      SGR = 0.0        
      CGR = 1.0        
      DO 500 BZ = 1,NBZ        
      DY  = YB(BZ)        
      DZ  = ZB(BZ)        
      NBEZ = NBEA(BZ)        
C        
C     LOOP FOR EACH ELEMENT OF BODY -BZ-        
C        
      DO 450 ZT = 1,NBEZ        
      C1  = C1 + 1        
      DX  = XP(C1)        
C        
      CALL ROWDYZ (NFB,NLB,C1,NTZYS,D,DX,DY,DZ,BETA,IDZDY,NTAPE,SGR,    
     1             CGR,IPRNT,YB,ZB,Z(IARB),Z(INSBEA),Z(IXIS1),Z(IXIS2), 
     2             Z(IA0))        
  450 CONTINUE        
  500 CONTINUE        
C        
C     NOW, LOOP FOR THE -Y- ORIENTED BODIES        
C        
  510 IF (NB.LT.NFYB .OR. NTY.LE.0) GO TO 650        
      IXP = NTP        
      IF (NFYB .LE. 1) GO TO 530        
      NFYBM1 = NFYB - 1        
      DO 520 I = 1,NFYBM1        
  520 IXP = IXP + NBEA(I)        
  530 CONTINUE        
      SGR =-1.0        
      CGR = 0.0        
      DO 600 BY = NFYB,NB        
      DY  = YB(BY)        
      DZ  = ZB(BY)        
      NBEY = NBEA(BY)        
C        
C     LOOP FOR EACH ELEMENT OF BODY -BY-        
C        
      DO 550 YT = 1,NBEY        
      C1  = C1  + 1        
      IXP = IXP + 1        
      DX  = XP(IXP)        
C        
      CALL ROWDYZ (NFB,NLB,C1,NTZYS,D,DX,DY,DZ,BETA,IDZDY,NTAPE,SGR,    
     1             CGR,IPRNT,YB,ZB,Z(IARB),Z(INSBEA),Z(IXIS1),Z(IXIS2), 
     2             Z(IA0))        
C        
  550 CONTINUE        
  600 CONTINUE        
  650 CONTINUE        
      RETURN        
      END        
