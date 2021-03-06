      SUBROUTINE RANDOM
C
C     RANDOM ANALYSIS MODULE
C
C     INPUTS   CASECC,XYCB,DIT,DISP,SPCF,LOAD,STRESS,FORCE,PSDL  (9)
C
C     OUTPUTS  PSDF,AUTO  (2)
C
C     SCRATCHES (0)
C
C     PARAMETERS 1 INTEGER
      INTEGER CASECC,XYCB,DIT,IFILE(5),PSDL,PSDF,AUTO
      COMMON /BLANK/ ICOUP
      DATA XYCB,DIT,PSDL,IFILE,CASECC/101,102,103,104,105,106,107,108,  
     1   109/                                                           
      DATA PSDF,AUTO /201,202/                                          
      DATA NFILE              /5/                                       
C                                                                       
C     INITIALIZE + SET UP
C
      CALL RAND7(IFILE,NFILE,PSDL,DIT,ICOUP,NFREQ,NPSDL,NTAU,LTAB,
     1   CASECC,XYCB)
      IF( ICOUP) 10,20,30
   10 RETURN
C
C     UNCOUPLED
C
   20 CALL RAND5(NFREQ,NPSDL,NTAU,XYCB,LTAB,IFILE,PSDF,AUTO,NFILE)
      GO TO 10
C
C     COUPLED
C
   30 CALL RAND8(NFREQ,NPSDL,NTAU,XYCB,LTAB,IFILE,PSDF,AUTO,NFILE)
      GO TO 10
      END
