* Encoding: UTF-8.

PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE="C:\Users\klaud\Desktop\Raport 3\bank_reg_training.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=";"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  Approval AUTO
  CreditScore AUTO
  DebttoIncomeRatio AUTO
  Interest AUTO
  RequestAmount AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME ZbiórDanych1 WINDOW=FRONT.

DATASET ACTIVATE ZbiórDanych1.
FREQUENCIES VARIABLES=CreditScore DebttoIncomeRatio Interest RequestAmount
  /FORMAT=NOTABLE
  /NTILES=4
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /ORDER=ANALYSIS.

COMPUTE Approval_num=Approval = "T".
EXECUTE.

CORRELATIONS
  /VARIABLES=CreditScore DebttoIncomeRatio Interest RequestAmount Approval_num
  /PRINT=TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.

SET RNG=MT MTINDEX=308285.

USE ALL.
COMPUTE filter_$=(uniform(1)<=.70).
VARIABLE LABELS filter_$ 'Około 70% obserwacji (SAMPLE)'.
FORMATS filter_$ (f1.0).
FILTER  BY filter_$.
EXECUTE.

FILTER OFF.
USE ALL.
EXECUTE.

* Drzewo klasyfikacyjne.
TREE CreditScore [s] BY Approval [n] DebttoIncomeRatio [s] Interest [s] 
  /TREE DISPLAY=TOPDOWN NODES=STATISTICS BRANCHSTATISTICS=YES NODEDEFS=YES SCALE=AUTO
  /PRINT MODELSUMMARY RISK
  /GAIN SUMMARYTABLE=YES TYPE=[NODE] SORT=DESCENDING CUMULATIVE=NO
  /PLOT IMPORTANCE
  /SAVE PREDVAL
  /METHOD TYPE=CRT MAXSURROGATES=AUTO PRUNE=NONE
  /GROWTHLIMIT MAXDEPTH=AUTO MINPARENTSIZE=100 MINCHILDSIZE=50
  /VALIDATION TYPE=SPLITSAMPLE(podzial) OUTPUT=BOTHSAMPLES
  /CRT MINIMPROVEMENT=0.0001
  /MISSING NOMINALMISSING=MISSING.

COMPUTE MAE_CART1=ABS(CreditScore - PredictedValue_CART1).
EXECUTE.

COMPUTE MAPE_CART1=ABS(CreditScore - PredictedValue_CART1) / CreditScore.
EXECUTE.

COMPUTE MSE_CART1=(CreditScore - PredictedValue_CART1) ** 2.
EXECUTE.

* Drzewo klasyfikacyjne.
TREE CreditScore [s] BY Approval [n] DebttoIncomeRatio [s] Interest [s] 
  /TREE DISPLAY=TOPDOWN NODES=STATISTICS BRANCHSTATISTICS=YES NODEDEFS=YES SCALE=AUTO
  /PRINT MODELSUMMARY RISK
  /GAIN SUMMARYTABLE=YES TYPE=[NODE] SORT=DESCENDING CUMULATIVE=NO
  /PLOT IMPORTANCE
  /SAVE PREDVAL
  /METHOD TYPE=CRT MAXSURROGATES=AUTO PRUNE=SE(1)
  /GROWTHLIMIT MAXDEPTH=AUTO MINPARENTSIZE=100 MINCHILDSIZE=50
  /VALIDATION TYPE=SPLITSAMPLE(podzial) OUTPUT=BOTHSAMPLES
  /CRT MINIMPROVEMENT=0.0001
  /MISSING NOMINALMISSING=MISSING.

COMPUTE MAE_CART2=ABS(CreditScore - PredictedValue_CART2).
EXECUTE.

COMPUTE MAPE_CART2=ABS(CreditScore - PredictedValue_CART2) / CreditScore.
EXECUTE.

COMPUTE MSE_CART2=(CreditScore - PredictedValue_CART2) ** 2.
EXECUTE.

*Multilayer Perceptron Network.
MLP CreditScore (MLEVEL=S) WITH DebttoIncomeRatio Interest Approval_num
 /RESCALE COVARIATE=STANDARDIZED DEPENDENT=STANDARDIZED 
  /PARTITION  VARIABLE=podzial
  /ARCHITECTURE   AUTOMATIC=NO HIDDENLAYERS=2 (NUMUNITS=4,16) HIDDENFUNCTION=TANH 
    OUTPUTFUNCTION=IDENTITY 
  /CRITERIA TRAINING=BATCH OPTIMIZATION=SCALEDCONJUGATE LAMBDAINITIAL=0.0000005 
    SIGMAINITIAL=0.00005 INTERVALCENTER=0 INTERVALOFFSET=0.5 MEMSIZE=1000 
  /PRINT CPS NETWORKINFO SUMMARY 
  /PLOT NETWORK PREDICTED RESIDUAL 
  /SAVE PREDVAL   
  /STOPPINGRULES ERRORSTEPS= 1 (DATA=AUTO) TRAININGTIMER=ON (MAXTIME=15) MAXEPOCHS=AUTO 
    ERRORCHANGE=1.0E-4 ERRORRATIO=0.001 
 /MISSING USERMISSING=EXCLUDE .

COMPUTE MAE_MLP=ABS(CreditScore - MLP_PredictedValue).
EXECUTE.

COMPUTE MAPE_MLP=ABS(CreditScore - MLP_PredictedValue) /  CreditScore.
EXECUTE.

COMPUTE MSE_MLP=(CreditScore - MLP_PredictedValue) **2.
EXECUTE.

SORT CASES  BY podzial.
SPLIT FILE SEPARATE BY podzial.

DESCRIPTIVES VARIABLES=MAE_CART1 MAPE_CART1 MSE_CART1 MAE_CART2 MAPE_CART2 MSE_CART2 MAE_MLP 
    MAPE_MLP MSE_MLP
  /STATISTICS=MEAN.

* Kreator wykresów.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=CreditScore PredictedValue_CART1 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: CreditScore=col(source(s), name("CreditScore"))
  DATA: PredictedValue_CART1=col(source(s), name("PredictedValue_CART1"))
  GUIDE: axis(dim(1), label("CreditScore"))
  GUIDE: axis(dim(2), label("Predicted Value"))
  GUIDE: text.title(label("Wykres rozrzutu z Predicted Value wg CreditScore"))
  ELEMENT: point(position(CreditScore*PredictedValue_CART1))
END GPL.

* Kreator wykresów.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=CreditScore PredictedValue_CART2 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: CreditScore=col(source(s), name("CreditScore"))
  DATA: PredictedValue_CART2=col(source(s), name("PredictedValue_CART2"))
  GUIDE: axis(dim(1), label("CreditScore"))
  GUIDE: axis(dim(2), label("Predicted Value"))
  GUIDE: text.title(label("Wykres rozrzutu z Predicted Value wg CreditScore"))
  ELEMENT: point(position(CreditScore*PredictedValue_CART2))
END GPL.

* Kreator wykresów.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=CreditScore MLP_PredictedValue MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: CreditScore=col(source(s), name("CreditScore"))
  DATA: MLP_PredictedValue=col(source(s), name("MLP_PredictedValue"))
  GUIDE: axis(dim(1), label("CreditScore"))
  GUIDE: axis(dim(2), label("Wartość przewidywana dla CreditScore"))
  GUIDE: text.title(label("Wykres rozrzutu z Wartość przewidywana dla CreditScore wg CreditScore"))
  ELEMENT: point(position(CreditScore*MLP_PredictedValue))
END GPL.

USE ALL.
COMPUTE filter_$=(podzial = 0).
VARIABLE LABELS filter_$ 'podzial = 0 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
