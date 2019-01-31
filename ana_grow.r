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

coe <- data4sum$coefficient
N <- nrow(database)
aic <- AIC(data4.step)
result <- cbind(coe,aic,N)
print("439")
result[2:nrow(result),5:6] <- ""

write.table(matrix(c("",colnames(result)),nrow=1),out2,append=T,quote=F,sep=","
,row.names=F,col.names=F)
write.table(result,out2,append=T,quote=F,sep=",",row.names=T,col.names=F)