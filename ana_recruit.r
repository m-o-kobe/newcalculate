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
out <-args[2]

data<-read.csv(file1, header=T)

data1.glm<-glm(formula = kanyu ~ crd1 + crd2 + crd3,family=binomial, data = data)
data2.step<-step(data1.glm)
data3.glm<-glm(formula = kanyu~  crd,family=binomial, data = data)
data4.step<-step(data3.glm)

tablecsv(data1.glm,data,out)

tablecsv(data2.step,data,out)

tablecsv(data3.glm,data,out)

tablecsv(data4.step,data,out)
