      SUBROUTINE GP3        
C        
C     GP3 IS THE MAIN CONTROL PROGRAM FOR MODULE GP3.        
C     IF PLOAD2 CARDS ARE PRESENT, GP3C IS EXECUTED TO BUILD PLOAD DATA 
C     ON SCRATCH FILE 2 (SCR2). GP3A IS EXECUTED TO BUILD THE STATIC    
C     LOADS TABLE (SLT). GP3B IS EXECUTED TO BUILD THE GRID POINT       
C     TEMPERATURE TABLE (GPTT).        
C     GP3D IS EXECUTED TO BUILD THE ELEMENT TEMPERATURE TABLE (ETT) FROM
C     THE GPTT AND ANY TEMPP1,TEMPP2,TEMPP3, AND TEMPRB DATA PRESENT.   
C        
      INTEGER         BUF1   ,BUF2  ,BUF  ,SYSBUF,PLOAD2,TWO   ,SLT   , 
     1                GPTT  ,GEOM3  ,BUF3 ,STATUS,SPERLK        
      COMMON /BLANK / NOGRAV ,NOLOAD,NOTEMP        
      COMMON /GP3COM/ GEOM3 ,EQEXIN,GEOM2 ,SLT   ,GPTT  ,SCR1  ,SCR2  , 
     1                BUF1  ,BUF2  ,BUF(50)      ,CARDID(60)   ,IDNO(30)
     2,               CARDDT(60)   ,MASK(60)     ,STATUS(60)   ,NTYPES, 
     3                IPLOAD,IGRAV ,PLOAD2(2)    ,LOAD(2)      ,NOPLD2, 
     4                TEMP(2)      ,TEMPD(2)     ,TEMPP1(2)    ,        
     5                TEMPP2(2)    ,TEMPP3(2)    ,TEMPRB(2)    ,BUF3  , 
     6                PLOAD3(2)    ,IPLD3        
      COMMON /SYSTEM/ SYSBUF,SY(93),SPERLK        
CZZ   COMMON /ZZGP3X/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /TWO   / TWO(32)        
C        
C     TURN PARAMETERS ON. INITIALIZE BUFFER POINTERS.        
C     READ TRAILER ON GEOM3. IF PURGED, EXIT.        
C        
      CALL DELSET        
C        
      IF (SPERLK .EQ. 0) GO TO 20        
      DO 10 I = 1,60,2        
      STATUS(I  ) =-1        
   10 STATUS(I+1) = 0        
   20 NOLOAD = -1        
      NOGRAV = -1        
      NOTEMP = -1        
      BUF1   = KORSZ(Z) - SYSBUF - 2        
      BUF2   = BUF1 - SYSBUF        
      BUF3   = BUF2 - SYSBUF - 2        
      BUF(1) = GEOM3        
      CALL RDTRL (BUF)        
      IF (BUF(1) .NE. GEOM3) RETURN        
C        
C     IF THE SLT IS PURGED, BYPASS THE SLT PHASE OF GP3.        
C     OTHERWISE, IF PLOAD2 CARDS PRESENT, EXECUTE GP3C.        
C     EXECUTE GP3A TO COMPLETE SLT PHASE.        
C        
      BUF(7) = SLT        
      CALL RDTRL (BUF(7))        
      IF (BUF(7) .NE. SLT) GO TO 30        
      CALL GP3C        
      CALL GP3A        
C        
C     IF THE GPTT IS NOT PURGED, EXECUTE GP3B TO BUILD IT.        
C        
   30 BUF(7) = GPTT        
      CALL RDTRL (BUF(7))        
      IF (BUF(7) .NE. GPTT) RETURN        
C        
C     GP3B WILL FORM A GPTT ON SCR1 AND THEN GP3D WILL READ SCR1 AND    
C     THE TEMPP1,TEMPP2,TEMPP3, AND TEMPRB DATA FROM GEOM3 TO FORM THE  
C     ETT (ELEMENT TEMPERATURE TABLE) ON THE OUTPUT FILE GPTT.        
C        
      CALL GP3B        
      CALL GP3D        
      RETURN        
      END        