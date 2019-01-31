args <- commandArgs(trailingOnly=T)
file1 <-args[1]
file2 <-args[2]
out <-args[3]
out2<-args[4]
buf1<-read.csv(file1, header=T)
buf2<-read.csv(file2, header=T)

sink(out,append=TRUE)
data<-rbind(buf1,buf2)
data1.glm<-glm(formula = death ~ dbh01 + crd1 + crd2 + crd3 + crd4 + crd5 + crd6 + crd7 + crd8 + crd9 + kabudachi,family=binomial, data = data)
data1sum<-summary(data1.glm)
print(data1sum)
data2.step<-step(data1.glm)

data2sum<-summary(data2.step)
print(data2sum)
data3.glm<-glm(formula = death ~ dbh01 + crd+ kabudachi,family=binomial, data = data)
data3sum<-summary(data3.glm)
print(data3sum)
data4.step<-step(data3.glm)

data4sum<-summary(data4.step)
print(data4sum)

coe <- data4sum$coefficient
N <- nrow(data)
aic <- AIC(data4.step)
result <- cbind(coe,aic,N)
result[2:nrow(result),5:6] <- ""

write.table(matrix(c("",colnames(result)),nrow=1),out2,append=T,quote=F,sep=","
,row.names=F,col.names=F)
write.table(result,out2,append=T,quote=F,sep=",",row.names=T,col.names=F)