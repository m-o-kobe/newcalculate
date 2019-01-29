args <- commandArgs(trailingOnly=T)
file1 <-args[1]
file2 <-args[2]

out1 <-args[3]
out2<-args[4]
buf1<-read.csv(file1, header=T)
buf2<-read.csv(file2, header=T)

database<-rbind(buf1,buf2)

#sink(out1,append=TRUE)

data1.lm<-lm(formula = growth ~ dbh01 + crd1 + crd2 + crd3 + crd4 + crd5 + crd6 + crd7 + crd8 + crd9 + kabudachi, data = database)
print("start")

data1sum<-summary(data1.lm)
print(data1sum)
data2.step<-step(data1.lm)

data2sum<-summary(data2.step)
print(data2sum)
data3.lm<-lm(formula = growth ~ dbh01 + crd+ kabudachi, data = database)
data3sum<-summary(data3.lm)
print(data3sum)
data4.step<-step(data3.lm)

data4sum<-summary(data4.step)
print(data4sum)

#column<-c("growth","dbh01","crd","kabudachi")
#data5<-data[,column]
#library(ggplot2)
library(coefplot)
# coef<- data4.step$coefficients
# error<-summary(data4.step)$coefficients[,"Std. Error"]
# lower<-coef-error
# upper<-coef+error
# label<-data4.step$x
# pdf(out2)
# print(label)
# print(coef)
# print(lower)
# print(upper)
# p <- ggplot(data4.step,aes(y=coefficients))
# p<-p+geom_errorbar(aes(ymin =coefficients-coefficients[,"Std. Error"], ymax = coefficients+coefficients[,"Std. Error"]))
# print("start")
#p<-p+ scale_y_log10()
pdf(out2)
#print(p)
coefplot(data4.step)