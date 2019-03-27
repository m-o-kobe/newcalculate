#実データ、ランダムデータ、アウトプットファイルネームの順でコマンドライン引数に入力
args <- commandArgs(trailingOnly=T)
file1<-args[1]
file2<-args[2]
fileout<-args[3]
data1<-read.csv(file1,header=T)
data2<-read.csv(file2,header=T)
tResult <- function(x,y,z){
    ft <- var.test(x, y,na.rm=TRUE) # F検定
    fp <- sprintf("%f", ft$p.value)
    if(ft$p.value >= 0.05){ # 等分散の場合
        tt <- t.test(x, y, var.equal=T,na.rm=TRUE)
        tp <- sprintf("%f", tt$p.value)
        tv <- sprintf("%f", tt$statistic)
        if(tt$p.value < 0.01) { # p<.01の場合
            tc <- "**"
        } else if(tt$p.value < 0.05) { # p<.05の場合
            tc <- "*"
        } else if(tt$p.value < 0.10) {
            tc <- "+"
        } else {
            tc <- "n.s"
        }
        res <- data.frame(real=mean(x,na.rm=TRUE), random=mean(y,na.rm=TRUE), f="TRUE", t=tv, p_value=tp, t_check=tc)
    }
    if(ft$p.value < 0.05){ # 不等分散の場合
        tt <- t.test(x, y, var.equal=F,na.rm=TRUE)
        tp <- sprintf("%f", tt$p.value)
        tv <- sprintf("%f", tt$statistic)
        if(tt$p.value < 0.01) { # p<.01の場合
            tc <- "**"
        } else if(tt$p.value < 0.05) { # p<.05の場合
            tc <- "*"
        } else if(tt$p.value < 0.10) {
            tc <- "+"
        } else {
            tc <- "n.s"
        }
        res <- data.frame(real=mean(x,na.rm=TRUE), random=mean(y,na.rm=TRUE), f="FALSE", t=tv, p_value=tp, t_check=tc)
    }
    return(res)
}
#dors<-c("ds1","ds2","ds3","ds4","ds5","ds6","ds7","ds8","ds9","ss1","ss2","ss3","ss4","ss5","ss6","ss7","ss8","ss9")
dors<-c("ds1","ds2","ds3","ss1","ss2","ss3")
t_res<-data.frame()
for(i in 1:6){
    t_res<-rbind(t_res,tResult(data1[,dors[i]],data2[,dors[i]],dors[i]))
}
rownames(t_res)<-dors
write.csv(t_res,fileout,quote=F,sep=",")