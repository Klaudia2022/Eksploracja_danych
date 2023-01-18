plik<-file.choose()
adult<-read.csv(plik, header=TRUE, sep=';')
adult

install.packages("ggplot2")
library(ggplot2)

#Wykonaj zwykły i znormalizowany zestawiony wykres słupkowy dla zmiennej
#maritalstatus, oznaczając kolorem wartości zmiennej income.

ggplot(adult, aes(maritalstatus))+geom_bar(aes(fill=income))+scale_fill_manual(breaks=c('>50K','<=50K'), values=c('green', 'red'))
ggplot(adult, aes(maritalstatus))+geom_bar(aes(fill=income), position="fill")+scale_fill_manual(breaks=c('>50K', '<=50K'), values=c('green', 'red'))

#Zbuduj tabelę krzyżową dla zmiennych maritalstatus (w kolumnach) i income (w wierszach).
#Dane umieszczone w tabeli powinny być procentowe (procent liczony w kolumnie).

tabela1<- table(adult$income, adult$maritalstatus)
tabela1
tabela<-round(prop.table(tabela1, margin=2)*100,2)
tabela

#Zidentyfikuj obserwacje odstające ze względu na wartości zmiennej education.
#Ile ich jetst?

boxplot(adult$education)
adult$educationstan<-scale(x=adult$education)
adult_outliers<-adult[which(adult$educationstan < -3 | adult$educationstan > 3),]
dim(adult_outliers)
adult_outliers

#Wykonaj zwykły i znormalizowany zestawiony histogram dla zmiennej education,
#oznaczając kolorem wartości zmiennej income

ggplot(adult, aes(education))+geom_histogram(aes(fill=income))+scale_fill_manual(breaks=c('>50K','<=50K'), values=c('green', 'red'))
ggplot(adult, aes(education))+geom_histogram(aes(fill=income), position="fill")+scale_fill_manual(breaks=c('>50K', '<=50K'), values=c('green', 'red'))

#Na podstawie zmiennej education utwórz nową zmienną education_binned zgodnie ze schematem:
#basic education education<=8
#medium education 8<education<13
#high education education>=13

adult$education_binned <- cut(x=adult$education, breaks=c(0, 8.01,12.9,100), right=FALSE, labels=c("basic education", "medium education", "high education"))
adult$education_binned

#Wykonaj zwykły i znormalizowany zestawiony wykres słupkowy dla zmiennej
#education_binned, oznaczając kolorem wartości zmiennej income.

ggplot(adult, aes(education_binned))+geom_bar(aes(fill=income))+scale_fill_manual(breaks=c('>50K', '<=50K'), values=c('green', 'red'))
ggplot(adult, aes(education_binned))+geom_bar(aes(fill=income), position="fill") + scale_fill_manual(breaks=c('>50K','<=50K'), values=c('green', 'red'))















