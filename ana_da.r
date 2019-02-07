tablecsv<-function(datalm,data,ou){
    sum<-summary(datalm)
    coe <- sum$coefficient
    N <- nrow(data)
    aic <- AIC(datalm)
    result <- cbind(coe,aic,N)
    result[2:nrow(result),5:6] <- ""
    
    write.table(matrix(c("\n",colnames(result)),nrow=1),ou,append=T,quote=F,sep=","
    ,row.names=F,col.names=F)
    write.table(result,ou,append=T,quote=F,sep=",",row.names=T,col.names=F)
}

args <- commandArgs(trailingOnly=T)
file1 <-args[1]
file2 <-args[2]
out <-args[3]
buf1<-read.csv(file1, header=T)
buf2<-read.csv(file2, header=T)

data<-rbind(buf1,buf2)
data1.glm<-glm(formula = death ~ dbh01 + crd1 + crd2 + crd3 + crd4 + crd5 + crd6 + crd7 + crd8 + crd9 + kabudachi,family=binomial, data = data)
data2.step<-step(data1.glm)
data3.glm<-glm(formula = death ~ dbh01 + crd+ kabudachi,family=binomial, data = data)
data4.step<-step(data3.glm)

tablecsv(data1.glm,data,out)

tablecsv(data2.step,data,out)

tablecsv(data3.glm,data,out)

tablecsv(data4.step,data,out)
