print("start")
args <- commandArgs(trailingOnly=T)
file1 <-args[1]
file2 <-args[2]
file3 <-args[3]
out <-args[4]

buf1<-read.csv(file1, header=T)
buf2<-read.csv(file2, header=T)
buf3<-read.csv(file3, header=T)
sink(out,append=TRUE)
buf4<-buf1[,c(-4,-5)]
buf5<-buf2[,c(-4,-5)]
data<-rbind(buf4,buf5,buf3)
data1.glm<-glm(formula = recruit ~ss1+ss2+ss3+ss4+ss5+ss6+ss7+ss8+ss9+ds1+ds2+ds3+ds4+ds5+ds6+ds7+ds8+ds9,family=binomial, data = data)
data1sum<-summary(data1.glm)
print(data1sum)
data2.step<-step(data1.glm)

data2sum<-summary(data2.step)
print(data2sum)
# data3.glm<-glm(formula = death ~ dbh01 + crd+ kabudachi,family=binomial, data = data)
# data3sum<-summary(data3.glm)
# print(data3sum)
# data4.step<-step(data3.glm)

# data4sum<-summary(data4.step)
# print(data4sum)
