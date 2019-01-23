args <- commandArgs(trailingOnly=T)
file1 <-args[1]
file2 <-args[2]
out <-args[3]
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
