;; 1. Based on: 649_clean
;; 2. Description: BLOCK(10), KEFB logistic EXP ETA EFB50, clean except ETA, EFB EXP ETA, EFB sets in logistic at half OCC2 correct at time 0
;; x1. Author: Steve Choy
$PROBLEM    Cov Matrix(11),no RIS,not logit BC0,MTT 3
$INPUT      ID TIME BSL DV MDV CMT DIP FLAG
$DATA      Simulated_run649.csv IGNORE=@
            IGNORE=(CMT.EQ.0,DIP.EQ.1,FLAG.GT.0)
$SUBROUTINE ADVAN6 TOL=5 ;
$MODEL      COMP=(WEIGHT) ; CMT1 for BODY WEIGHT
            COMP=(INSULIN) ; CMT2 for INSULIN
            COMP=(FPG) ; CMT3 for FPG
            COMP=(HBA1C) ; CMT4 for HBA1c
            COMP=(HBA2C) ; CMT5 for HBA1c
            COMP=(HBA3C) ; CMT6 for HBA1c

;
$PK  
;;=================Weight parameters================
BLWT  = THETA(1)* EXP(ETA(7)) ; Baseline weight (kg)
Kout  = LOG(2)/THETA(2) ; Half-life of weight cmt (days)
Kin   = Kout * BLWT

;;=================D&E+Placebo and loss of effect=================
OCC1=0
OCC2=0
IF(TIME.GT.1)   OCC1 = 1    ; Effect of treatment 1
IF(TIME.GT.BSL) OCC2 = 1	; Effect placebo, administered at baseline

EFDE = THETA(3)  + ETA(8)  ; Effect parameter of Diet&Exercise: counseling administered at screening
EFPL = THETA(4)  + ETA(9)  ; Effect placebo, administered at baseline

EFDEPL   = EFDE * OCC1 + (EFPL * OCC2)
EFUPS  = THETA(5)  + ETA(10) ; Loss of effect of D&E + placebo per year (%/year) slope

EFUP    = (100 + EFUPS * TIME/365) / 100 ; effect of loss d&e and placebo
EFFW    = EFUP * (100 - EFDEPL) / 100 ; effect of weight based on disease progression, effect of D&E and effect of placebo

;;=================Beta-cell parameters=============
BC0     =  THETA(6)  + ETA(2) ; Baseline Bcell function, logistic function
BCE0    =  1/(1 + EXP(BC0))  ; scale beta-cell function between 0 and 1
RB      =  THETA(7)  + ETA(3) ; Rate of Bcell function decline per year, logits
EFBMAX  =  THETA(8) * EXP(ETA(1)) ; maximal relative increase on beta cell function
SEFBI   =  THETA(9)  ; shape of sigmoidal logistic function

SEFBD   = THETA(21) ; shape of sigmoidal logistic function DECREASE
EFB50   = THETA(10) * EXP(ETA(14)) ; Time for half of EFB logistic decline (days)

BF      =  1/(1 + EXP(BC0 + RB*TIME/365)) ;rate of loss beta cell function per year
EFBI    =  0
IF(TIME.GT.0) EFBI = EFBMAX/(1+(TIME/BSL)**SEFBI) ; increase logistic function of EFB
EFBD    =  0
IF(TIME.GT.0) EFBD = EFBI/(1+(TIME/EFB50)**SEFBD) ; decrease logistic function of EFB
EFFB    =  1 + EFBD

BNET    = EFFB * BF ; Overall shape of Beta cell function

;;=================Insulin parameters===============
IS0     =  THETA(11) + ETA(4) ; Baseline IS, logistic function
ISS0    =  1/(1 + EXP(IS0))    ; scale insulin sensitivity between 0 and 1
KIOI    =  7.8                   ; kinI/koutI set to correspond to typical steady-state fasting FSI 5uU/mL
SCALEIS =  THETA(12) *EXP(ETA(6)) ; scaling factor of weight change effect on IS

;;=================Glucose parameters===============
FPGSS    =  4.5 ; healthy FPG reference value from HOMA
KIOG     =  FPGSS * KIOI ; 35.1    ; kinG/koutG set to correspond to typical ss FPG level in healthy subjects of 4.5 mmol/L given a ss FSI level of 7.8 uU/mL
THRESH   =  FPGSS - 1 ; Minimum threshold glucose, one less than FPGSS

;;=================HbA1c parameters=================
MTT     =  THETA(17)		; mean transit time (days)
NC      =  3			; no. of total compartments for HbA1c
KIHB    =  THETA(18)     ; Kin HbA1c (%/days L/mmol)
KOHB    =  NC/MTT		; Also known as Ktransit (%/days L/mmol)
INTCPT  =  THETA(19) * EXP(ETA(5)) ; Residual amount of HbA1c independent of FPG (PPG & assay error)
PPG     =  INTCPT
IF(TIME.GT.0) PPG = INTCPT * THETA(20) ; Reduction of Post-prandial glucose effect, scales PPG after time 0

;;=================Baseline functions===============
B       =  THRESH * BCE0 * KIOI
C       =  -BCE0 * KIOI * KIOG / (ISS0)
BLI     =  (-B + SQRT(B**2 -4*C)) / (2)   ; baseline insulin
BLG     =  KIOG / (ISS0 * BLI)       ; baseline FPG
BLHB    =  (INTCPT + KIHB*BLG)/KOHB *NC  ; baseline HbA1c

;;=================Residual error parameters========
RESWT   = THETA(13)		; proportional weight residual error
RESFSI	= THETA(14)	* EXP(ETA(11))	; proportional FSI residual error
RESFPG	= THETA(15)	* EXP(ETA(12))	; proportional FPG residual error
RESHBA	= THETA(16)	* EXP(ETA(13))	; proportional HbA1c residual error

;;=================Initialization of compartments===
A_0(1)      =  BLWT
A_0(2)      =  BLI
A_0(3)      =  BLG
A_0(4)      =  BLHB/NC
A_0(5)      =  BLHB/NC
A_0(6)      =  BLHB/NC

;;================= First Weight record switch======
IF(NEWIND.NE.2) IND = 0
IF(CMT.EQ.1)    IND = 1
$DES  
AA1=A(1)
IF(IND.EQ.0) DWT = 0
IF(IND.EQ.1) DWT = BLWT - A(1)
IF(IND.EQ.0) DWTP = 1
IF(IND.EQ.1) DWTP = A(1)/BLWT

EFFS = 1 + SCALEIS * DWT      ;EFFECT ON INSULIN SENSITIVITY IS PROPORTIONAL TO CHANGE IN BODY WEIGHT FROM BASELINE
;
B1 =  THRESH * BF * EFFB * KIOI ; THRESH is the FPG threshold conc
C1 =  -BF * EFFB * KIOI * KIOG / (ISS0 * EFFS)
FSI =  (-B1 + SQRT(B1*B1 -4*C1)) / (2)   ; FSI production stimulated by FPG (linearized)
IF (FSI.LT.0)  FSI = 1
;
FPG =  KIOG / (EFFS * ISS0 * FSI)       ; baseline FPG
;
DADT(1) = Kin * EFFW - Kout * A(1)            ; turn-over model for body weight
DADT(2) = 0                                   ; short-term dynamics assumed to be at steady-state
DADT(3) = 0                                   ; short-term dynamics assumed to be at steady-state
DADT(4) = PPG + KIHB * FPG - KOHB * A(4)      ; HbA1c production driven by FPG
DADT(5) = KOHB*A(4)-KOHB*A(5)      			  ; HbA1c transit
DADT(6) = KOHB*A(5)-KOHB*A(6)                 ; HbA1c transit
;

$ERROR  
;;=================Re-defining Time parameters outisde $DES===
;
AA4=A(4)
AA5=A(5)
AA6=A(6)
EWT  = A(1)
IF(EWT.LE.0) EWT = 0.00001
EHB  = A(4) + A(5) + A(6)
IF(EHB.LE.0) EHB = 0.00001
;
IF(IND.EQ.0) DWTE = 0
IF(IND.EQ.1) DWTE = BLWT - A(1)
IF(IND.EQ.0) DWTPE = 1
IF(IND.EQ.1) DWTPE = A(1)/BLWT

EEFS = 1 + SCALEIS * DWTE
;
B2 =  THRESH * BF * EFFB * KIOI
C2 =  -BF * EFFB * KIOI * KIOG / (ISS0 * EEFS)
EFSI =  (-B2 + SQRT(B2**2 -4*C2)) / (2)   ; FSI production stimulated by FPG (linearized)
IF (EFSI.LT.1)  EFSI = 1
EFPG =  KIOG / (EEFS * ISS0 * EFSI)       ; baseline FPG
IF (EFPG.LE.0) EFPG = 0.00001
EDEN = (EEFS * ISS0 * EFSI)
;
;
;;=================On/off switch for each compartment========
E1 = 0
E2 = 0
E3 = 0
E4 = 0
IF (CMT.EQ.1) E1 = 1
IF (CMT.EQ.2) E2 = 1
IF (CMT.EQ.3) E3 = 1
IF (CMT.EQ.4) E4 = 1

IPRED  =   LOG(0.00001)
IF(F.GT.0) IPRED = E1*LOG(EWT) + E2*LOG(EFSI) + E3*LOG(EFPG) + E4*LOG(EHB)
IF(F.GT.0) W = RESWT*E1 + RESFSI*E2 + RESFPG*E3 + RESHBA*E4
IRES  =   DV - IPRED
IWRES  = IRES
IF(W.NE.0) IWRES =   IRES/W
Y     =   IPRED + W*ERR(1)

IF(ICALL.EQ.4.AND.CMT.EQ.3) THEN
Y = LOG((INT(10*( EXP(IPRED + W*ERR(1) ) )))/10)
ENDIF

IF(ICALL.EQ.4.AND.CMT.EQ.4) THEN
Y = LOG((INT(10*( EXP(IPRED + W*ERR(1) ) )))/10)
ENDIF

;;=================Diagnostic outputs=====================
ISSE = ISS0 * EEFS * 100 ; insulin sensitivity (%)
BSSE = BNET * 100 ; Beta cell function (%)
IGR = EFSI / EFPG ; Insulin-glucose ratio
IF(DWTE.EQ.0) THEN  ; insulin sensitivity per kg change
  ISSEKG = 0
ELSE
  ISSEKG = (ISSE - (ISS0 * 100)) / DWTE
ENDIF

;;=================Change from baseline===================
IF(NEWIND.NE.2) THEN
  WTFLG1=0
  WTFLG2=0
  WTFLG3=0
  WTFLG4=0
ENDIF

IF(WTFLG1.EQ.0.AND.CMT.EQ.1) THEN
   BASE1=EXP( DV )
   WTFLG1=1
ENDIF

IF(WTFLG2.EQ.0.AND.CMT.EQ.2) THEN
   BASE2=EXP( DV )
   WTFLG2=1
ENDIF

IF(WTFLG3.EQ.0.AND.CMT.EQ.3) THEN
   BASE3=EXP( DV )
   WTFLG3=1
ENDIF

IF(WTFLG4.EQ.0.AND.CMT.EQ.4) THEN
   BASE4=EXP( DV )
   WTFLG4=1
ENDIF

IF(CMT.EQ.1) CFB1 = (EXP(DV)-BASE1)/BASE1
IF(CMT.EQ.2) CFB2 = (EXP(DV)-BASE2)/BASE2
IF(CMT.EQ.3) CFB3 = (EXP(DV)-BASE3)/BASE3
IF(CMT.EQ.4) CFB4 = (EXP(DV)-BASE4)/BASE4

CFB = E1*CFB1 + E2*CFB2 + E3*CFB3 + E4*CFB4 
IF(TIME.EQ.0) CFB = 0
;
NID=IREP
SDV = Y
;
$THETA  (0,104.277) ; BLWT
 (0,96.9422) ; Kout
 4.07896 ; EFDE
 2.28404 ; EFPL
 2.98666 ; EFUPS
 (-3,-0.445935,2) ; BC0
 0.208919 ; RB
 (0,0.171069) ; EFBMAX
 (-100,-3.68999,0) ; SEFBI
 (40,189.953) ; EFB50
 (0,1.1019) ; IS0
 0.0514028 ; SCALEIS
 (0,0.00919065) ; RESWT
 (0,0.262162) ; RESFSI
 (0,0.0687593) ; RESFPG
 (0,0.0240872) ; RESHBA
 (0,38.8771) ; MTT
 (0,0.0129028) ; KIHB
 (0,0.0708852) ; INTCPT
 0.962795 ; PPG
 (0,8.0521) ; SEFBD
$OMEGA  BLOCK(10)
 0.248662  ; EFBMAX
 -0.324005 1.39532  ; BC0
 0.0981088 -0.224451 0.210208  ; RB
 0.221065 -0.352266 0.105203 0.305137  ; IS0
 0.00447496 -0.0200577 -0.00490146 -0.0104563 0.0238006  ; INTCPT
 0.167785 -0.292249 0.119387 0.24431 0.020457 0.449234  ; SCALEIS
 0.0393118 -0.0373825 0.0125163 0.0337664 -0.00445451 0.0232753 0.0213004  ; BLWT
 0.0868604 2.14706 -0.98756 -0.939352 0.013064 -1.04875 -0.178463 35.5718  ; EFDE
 0.501473 -1.56801 -0.388824 0.882971 0.0168388 0.47021 0.0867813 -15.6509 40.1704  ; EFPL
 -0.0114547 0.212369 -1.41961 -0.0276497 -0.0352235 -1.34686 -0.120501 12.821 28.5882 74.3962  ; EFUPS
$OMEGA  BLOCK(2)
 0.0990947  ; RESFSI
 0.0403634 0.0655947  ; RESFPG
$OMEGA  0.0259579  ; RESHBA
 0.121909  ; EFB50
$SIGMA  1  FIX
$ESTIMATION MSFO=run650 METHOD=1 INTERACTION MAX=0 PRINT=5 POSTHOC
            NOABORT
;$COVARIANCE MATRIX=S PRINT=E UNCONDITIONAL
$TABLE      ID TIME CMT BF ISS0 EFUP EFFW AA4 AA5 AA6 EHB EWT EFSI
            EFPG CMT CFB DV PRED IPRED RES WRES IRES IWRES CWRES NOAPP
            NOPRINT ONEHEAD FILE=sdtarun650
$TABLE      ID TIME CMT DV CFB EFDEPL EFFW KOHB BLWT BLI BLG EFFB BF
            BNET EFSI EFPG EDEN EWT EHB EEFS BC0 BCE0 PPG ISSE
            ISSEKG IS0 ISS0 RB DWTE BSSE DWTPE AA4 AA5 AA6 EFBI EFBD
            NOAPP NOPRINT ONEHEAD FILE=catarun650
$TABLE      ID ETA1 ETA2 ETA3 ETA4 ETA5 ETA6 ETA7 ETA8 ETA9 ETA10
            ETA11 ETA12 ETA13 ETA14 NOAPP NOPRINT ONEHEAD
            FILE=patabrun650
