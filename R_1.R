# Henok Fasil Telila
# A descriptive analysis using major packages such as purrr, dplyr and tidyverse.

setwd("C:/Users/Desktop")


if (length(new.pkg)) {
  install.packages(new.pkg, repos = "http://cran.rstudio.com")
}

############################################################
library('RMySQL','pool','ggplot2','corrplot')
        library('readxl','hexbin','RColorBrewer')
                library('RODBC','RPostgreSQL')
install.packages("pander")
#devtools::install_github("taiyun/corrplot")
devtools::install("pander")
library(pander)
library(haven)
library(purrr)
update.packages(repos='http://cran.rstudio.com/', ask=FALSE, checkBuilt=TRUE)
install.packages("RMySQL")
install.packages("RODBC")
#install.packages("RMariaDB")
install.packages("pool")
install.packages("rowr")
install.packages("corrplot")
install.packages("readxl")
install.packages("hexbin")
#http://www.sthda.com/english/wiki/correlation-analyses-in-r
require(dplyr)
require(ggplot2)
require(pool)
install.packages("devtools")
devtools::install_github("taiyun/corrplot")
install.packages("installr")
library(installr)
updaterR()
packageStatus()
#####
#pool <- dbPool(drv = RMySQL::MySQL(),dbname = "mwr_poste_app_monitoring",host = "89.97.235.138",username = 'henok',password = 'Meware529!',
 #              port = 10001)
pool <- dbPool(drv = RMySQL::MySQL(),dbname = "mwr_poste_app_monitoring",host = "89.97.235.138",
               username = 'henok',password = 'Meware529!',port = 10001)
ress <- dbGetQuery(pool, "select * from henk_arma;")
    eventime <- as.Date(ress$eventime);  
      ress1 <- cbind(eventime, ress); 
    
ress1 <- ress1[,-2] ; #final dataset
    View(ress1)
#I have added percentage figure for memoryusage and storagusage
    a <- ress1$memoryused ; b <- ress1$memoryfree ; c <- a+b ; d <- ress1$storageused ; e <- ress1$storagefree ; f <- d+e
    f1<- as.data.frame(round((a/c)*100,4)); colnames(f1) = c("memory_used_percent")  
    f2<- as.data.frame(round((d/f)*100,4));colnames(f2) = c("storage_used_percent") 

    ress2<- cbind(ress1,f1,f2) ; 
    #View(ress2)
  write.csv(ress2, file = "post_dataset_final.csv")  
##################################
    
    #1) Number of events by manufacturer
    #BY number of manufacturers and their crash events
    #samsung	4098, HUAWEI	2353, Xiaomi	762, LGE	530, asus	356, WIKO	258
    manucouont <- ress1 %>%       group_by() %>%       count(devicemanufacturer) %>%       arrange(desc(devicemanufacturer)) %>% 
      arrange(desc(n));  #Highest number of java class problems in descending order
    manu <- manucouont[1:10,]
    ggplot(data=manu, mapping=aes(x=reorder(devicemanufacturer,-n), y=n, fill = "No. of crashes", group = 1))+
      geom_bar(stat="identity", colour="black")+xlab('Device Manufactureres')+ylab('No of events/crashes')
    
    
# 2) BY Java class problems
#Java class problems, top five are counted
#JAVA RELATED PROBLEMS COUNT
#ConfirmPushNavFragment.java->203; RealInterceptorChain.java->132, PublicSuffixDatabase.java->104,Cookie.java->78, RealCall.java->52 
cjavaa <- ress1 %>% 
    group_by() %>% 
      count(javaclass) %>% 
        arrange(desc(javaclass)) %>% 
          arrange(desc(n));  #Highest number of java class problems in descending order
cjavaa <- as.data.frame(cjavaa) ; cjavax <- cjavaa[2:8,];    class(cjavax)
    
ggplot(data=cjavax, mapping=aes(x=reorder(javaclass,-n), y=n, fill = "No. of crashes", group = 1))+
      geom_bar(stat="identity", fill = "#CC0000")+
          xlab('Top java class crash problems')+ylab('No of events/crashes')
    View(cjavaa)
    
    
    

  
##3) OVER ALL FATALITY RATE
fat <- ress1 %>%   group_by(devicemanufacturer) %>% 
     count(is_fatal) %>%   arrange(desc(is_fatal)) %>% 
        arrange(desc(n));  fat <- as.data.frame(fat)#Highest number of java class problems in descending order

fatal <- ress1 %>% 
  group_by(is_fatal) %>%   count(devicemanufacturer) %>% 
          arrange(desc(devicemanufacturer)) %>%   arrange(desc(n)); fatal <- as.data.frame(fatal) #Highest number of java class problems in descending order
fatalx <- left_join(fat,fatal, by = "devicemanufacturer")

fatalx <- fatalx[,-c(2,4)] ;fatalend<-cbind(fatalx,fatalx[,2]-fatalx[,3]) ; 

colnames(fatalend) <- c("devicemanufacturer","#ofCrashes","#of_is_fatal","#of_NonFatal")
#View(fatalend)

###############################
#4) DEVICE STATISTICS: percentage of MEMORY and STORAGE USAGE DURING THE CRUSH OUT OF THE TOTAL; TOTAL = USED + FREE
options(scipen=999)
#memory usage and storage usage statistics
memx <- ress1 %>%   group_by(devicemanufacturer) %>% 
       summarise(tot = sum(memoryfree), mas = sum(memoryused),per =  round((mas/sum(tot+mas))*100,2),
            tgh = sum(storagefree), but = sum(storageused),gka = round((but/sum(tgh+but))*100,2)
                                    )   %>% arrange(desc(tot)); 
memx <- as.data.frame(memx)
write.csv(memx, file = "memory_stat.csv")
############h
colnames(memx) <- c("devicemanufacturer","memoryfree","memoryused","percentageOfMeomoryUsed","storagefree","storageused","percentofstorageUsed")
    #View(memx)
          mok <- memx[1:10,]
      #View(mok)
#Plot for memory usage the total space
ggplot(data = mok, aes(x=reorder(devicemanufacturer,-percentageOfMeomoryUsed), y=percentageOfMeomoryUsed))+
  geom_bar(stat="identity", colour="red")+xlab('Device manufacturers')+ylab('%age of used memory during the crash out of Total space')+
  coord_cartesian(ylim=c(50, 80))+geom_text(aes(label=percentageOfMeomoryUsed), vjust=-0.25) #I did a nice plot about it

#plot for storage usage against the total space
ggplot(data = mok, aes(x=reorder(devicemanufacturer,-percentofstorageUsed), y=percentofstorageUsed))+
  geom_bar(stat="identity", colour="green")+xlab('Device manufacturers')+ylab('%age of used storage during the crash out of Total space')+
  coord_cartesian(ylim=c(20, 80))+geom_text(aes(label=percentofstorageUsed), vjust=-0.25) # I did a nice plot about it

#  
###############################
#FOR sAMSUNG: Percentage of memory usage during the crush
###################
#samiman <- ress2 %>%    filter(devicemanufacturer == 'samsung')  #%ofmemory usage for samsung
#soki <- samiman %>%   group_by(eventime) %>% 
 #       summarise(pap = sum(memoryfree), mdk = sum(memoryused),per =  round((mdk/sum(pap+mdk))*100,2),
  #          pip = sum(storagefree), fau = sum(storageused),gka = round((fau/sum(pip+fau))*100,2))   %>% arrange(eventime); 
#colnames(soki) <- c("eventime","memoryfree","memoryused","percentageOfMeomoryUsed","storagefree","storageused","percentofstorageUsed")

############################################################################################
#DEDICATED TO FORM A DATAFRAME FOR THREE CLASSFICATIONS FOR MEMORY USAGE

memless33<- ress2 %>% #memory usage of less than 33 percent
  filter(memory_used_percent < 33)%>%  arrange(eventime)%>% 
             group_by(eventime) %>%   summarize(obs = n())
            
    #View(memless33)
memless66<- ress2 %>%  
         filter(memory_used_percent >= 33 & memory_used_percent <= 66 )%>%
                    arrange(eventime)%>%   group_by(eventime) %>%   summarize(obs = n())
                        #View(memless66)
memgrt66<- ress2 %>%   #memory usage of greater than 66
      filter(memory_used_percent > 66 )%>%
            arrange(eventime)%>%   group_by(eventime) %>%   summarize(obs = n())
class(memgrt66)      
memgrt66 <- as.data.frame(memgrt66)
#View(memgrt66)

##DEDICATED TO FORM A DATAFRAME FOR THREE CLASSFICATIONS FOR STORAGE USAGE
storless33<- ress2 %>% #storage usage of less than 33 percent
           filter(storage_used_percent < 33)%>%  arrange(eventime)%>% 
                group_by(eventime) %>%   summarize(obs = n())
#View(storless33)
storless66<- ress2 %>%  #storage usage of greater than 33% and less than 66%
       filter(storage_used_percent >= 33 &storage_used_percent <= 66 )%>%
      arrange(eventime)%>%   group_by(eventime) %>%   summarize(obs = n())
#View(storless66)
storgrt66<- ress2 %>%   #storage usage of greater than 66
         filter(storage_used_percent > 66 )%>%
        arrange(eventime)%>%   group_by(eventime) %>%   summarize(obs = n())
   # View(storgrt66)
##############################
###
#
#FUNCTION FOR ALL JAVA RELATED PROBLEMS, MEMORY USAGE, AND STORAGE USAGE
dalx <- function(x){
  
  hua1 <- left_join(x, count31, by="eventime" ,copy=TRUE); hua1 <- data.frame(hua1)  #awesomeCode 
        class(hua1); hua1[is.na(hua1)] <- 0   
        hua1 <- as.data.frame(hua1);  colnames(hua1) <- c("eventime","Hua.crush","ConfirmPush");  cor1 <- cor(hua1$ConfirmPush,hua1$Hua.crush) 
        #hua1 <- hua1[,3];hua1 <- as.data.frame(hua1) ;colnames(hua1) <- c("ConfirmPush" #return(cor1);
  
  hua2 <- left_join(x, count41, by="eventime" ,copy=TRUE); hua2 <- data.frame(hua2)  #awesomeCode 
       class(hua2); hua2[is.na(hua2)] <- 0 ;  hua2 <- as.data.frame(hua2)  ;colnames(hua2) <- c("eventime","Hua.crush","RealInter")
       #hua2[,2:3] <- data.frame(apply(hua2[,2:3], 2, function(x) as.numeric(as.character(x))))
       coor2 <-  cor(hua2$Hua.crush,hua2$RealInter) ;hua2 <- hua2[,3];hua2 <- as.data.frame(hua2) ;colnames(hua2) <- c("RealInter")
  
  
  ##manufacturer with the third problem
  hua3 <- left_join(x, count51, by="eventime" ,copy=TRUE); hua3 <- data.frame(hua3)  #awesomeCode      
       class(hua3); hua3[is.na(hua3)] <- 0   ; hua3 <- as.data.frame(hua3) ;colnames(hua3) <- c("eventime","Hua.crush","PublicSuff")
  #hua3[,2:3] <- data.frame(apply(hua3[,2:3], 2, function(x) as.numeric(as.character(x)))) #hua3 <- as.data.frame(hua3
       coor3 <-  cor(hua3$Hua.crush,hua3$PublicSuff) ;hua3 <- hua3[,3];hua3 <- as.data.frame(hua3) ;colnames(hua3) <- c("PublicSuff")
  
  hua4 <- left_join(x, count61, by="eventime" ,copy=TRUE); hua4 <- data.frame(hua4)  #awesomeCode      
        class(hua4); hua4[is.na(hua4)] <- 0   ; hua4 <- as.data.frame(hua4); colnames(hua4) <- c("eventime","Hua.crush","Cookie")
          coor4 <-  cor(hua4$Hua.crush,hua4$Cookie) ; hua4 <- hua4[,3];hua4 <- as.data.frame(hua4) ;colnames(hua4) <- c("Cookie")
  
  hua5 <- left_join(x, count71, by="eventime" ,copy=TRUE); hua5 <- data.frame(hua5)  #awesomeCode      
        class(hua5); hua5[is.na(hua5)] <- 0   ; hua5 <- as.data.frame(hua5) ;colnames(hua5) <- c("eventime","Hua.crush","Realcall")
         coor5 <-  cor(hua5$Hua.crush,hua5$Realcall);  hua5 <- hua5[,3] ; hua5 <- as.data.frame(hua5) ;colnames(hua5) <- c("Realcall")
  
  #return(list(cor1,coor2,coor3,coor4,coor5))  
  #return(list(hua1,hua2,hua3,hua4,hua5))
  
     
  
  memo1 <- left_join(x, memless33, by="eventime" ,copy=TRUE); memo1 <- data.frame(memo1)   #the first join should maintain the three columns since we need to merge it later
             memo1[is.na(memo1)] <- 0; memo1 <- as.data.frame(memo1)  
             colnames(memo1) <- c("eventime","crush","mem_less33");   cormem1 <- cor(memo1$mem_less33,memo1$crush) 
             memo1 <- memo1[,3];memo1 <- as.data.frame(memo1) ;colnames(memo1) <- c("mless33")
    
  memo2 <- left_join(x, memless66, by="eventime" ,copy=TRUE); memo2 <- data.frame(memo2)   
             memo2[is.na(memo2)] <- 0;     memo2 <- as.data.frame(memo2) ;    colnames(memo2) <- c("eventime","crush","mem_less66")
             cormem2 <-  cor(memo2$crush,memo2$mem_less66) 
             memo2 <- memo2[,3];memo2 <- as.data.frame(memo2) ;colnames(memo2) <- c("mem_less66")
    
  memo3 <- left_join(x, memgrt66, by="eventime" ,copy=TRUE); memo3 <- data.frame(memo3)      
             memo3[is.na(memo3)] <- 0; memo3 <- as.data.frame(memo3)  ; colnames(memo3) <- c("eventime","crush","mem_grt66")
             cormem3 <-  cor(memo3$crush,memo3$mem_grt66) ;   
             memo3 <- memo3[,3];
             memo3 <- as.data.frame(memo3) ;colnames(memo3) <- c("mem_grt66")
             
             
             
  store1 <- left_join(x, storless33, by="eventime" ,copy=TRUE); store1 <- data.frame(store1)   
             class(store1); store1[is.na(store1)] <- 0; store1 <- as.data.frame(store1)  
             colnames(store1) <- c("eventime","crush","store_less33");   store_mem1 <- cor(store1$store_less33,store1$crush) 
             store1 <- store1[,3];store1 <- as.data.frame(store1) ;colnames(store1) <- c("store_less33")
             
  store2 <- left_join(x, storless66, by="eventime" ,copy=TRUE); store2 <- data.frame(store2)   
             class(store2); store2[is.na(store2)] <- 0;     store2 <- as.data.frame(store2) ;    colnames(store2) <- c("eventime","crush","store_less66")
             store_mem2 <-  cor(store2$crush,store2$store_less66) 
             store2 <- store2[,3];store2 <- as.data.frame(store2) ;colnames(store2) <- c("store_less66")
             
             
  store3 <- left_join(x, storgrt66, by="eventime" ,copy=TRUE); store3 <- data.frame(store3)      
             class(store3); store3[is.na(store3)] <- 0   ; store3 <- as.data.frame(store3)  ; colnames(store3) <- c("eventime","crush","store_grt66")
             store_mem3 <-  cor(store3$crush,store3$store_grt66) ;   store3 <- store3[,3];store3 <- as.data.frame(store3) ;colnames(store3) <- c("store_grt66")
             
    
     
    return(list(hua1,hua2,hua3,hua4,hua5,memo1,memo2,memo3,store1,store2,store3))
}  




 
#below is the correct code to produce my desire
######
countfn <- function(x){
    Countx <- ress1 %>%        filter(javaclass == x) %>%
             arrange(eventime)%>%     group_by(eventime) %>%     summarize(obs = n())
    #countx <- as.data.frame(countx)
    #colnames(countx) <- c("eventime","x")
    #return(list(countx=data.frame(countx)))
  }


#The first among the java related problem is "ConfirmPushNavFragment"
a1 <- 'ConfirmPushNavFragment.java'
count31 <- countfn(a1) ; count31 <- data.frame(count31);colnames(count31) <- c("eventime","ConfirmPush")  

#The second among the java related problem is "RealInterceptorChain"
a2 <- 'RealInterceptorChain.java'
count41 <- countfn(a2) ; count41 <- data.frame(count41);colnames(count41) <- c("eventime","RealInter")  

#The third among the java related problem is "PublicSuffixDatabase"
a3 <- 'PublicSuffixDatabase.java'
count51 <- countfn(a3) ; count51 <- data.frame(count51);colnames(count51) <- c("eventime","PublicSuff")  

#The forth among the java related problem is "Cookie"
a4 <- 'Cookie.java'
count61 <- countfn(a4) ; count61 <- data.frame(count61);colnames(count61) <- c("eventime","Cookie")  

#The fifth among the java related problem is "Realcall"
a5 <- 'RealCall.java'
count71 <- countfn(a5) ; count71 <- data.frame(count71);colnames(count71) <- c("eventime","RealCall")  

#Count by Java related problems


###################
#

######################
#NUMBER OF COUNTS BY TELEFONE MANUFACTURERS
manct <- function(x){
                           countman <- ress1 %>%
                                select(devicemanufacturer,eventime) %>%
                        filter(devicemanufacturer == x) %>%
                        arrange(eventime)%>% 
                       group_by(eventime) %>% 
                                      summarize(obs = n())
}



#5) ANALYSIS for SAMSUNG
###################################
sam <- 'samsung' ; 
countsam <-data.frame(manct(sam)) ; colnames(countsam) <- c("eventime","Sam.crash")
View(countsam)
##

library(ggplot2)
ggplot(data = countsam, mapping = aes(x=eventime, y = Sam.crash , color = "No. of events for Samsung for \n the month of May 2020"))+
                    geom_line()+geom_point(alpha = 0.1, color = "blue")+    labs(title = "", x = "Event time", y = "Samsung crash report")+
                                              theme_bw()+ theme(legend.position = "bottom")
#SAMSUNG READY DATASET FOR ANALYSIS
#TO PRODUCE DATAFRAME FOR SAMSUNG WITH JAVA RELATED PROBLEMS, MEMORY USGAGE AND STORAGE USAGE FIGURES    
samAll <- as.data.frame(dalx(countsam));
colnames(samAll) <- c("eventime","crush","ConfirmPush","RealInter","Publicstuff","Cookie",
                             "RealCall","mem_less33","mem_between","mem_grt66","stor_less33","stor_between","stor_grt66") 
#View(samAll) #best of Best

sam_ja <-as.data.frame(cor(samAll[,2:7])) 
ggcorrplot(sam_ja, method = "square",hc.order = TRUE,  type = "lower", outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between samsung and Java class problems")


sam_mem_cor <- as.data.frame(cor(samAll[,c(2,8:10)]))  ;  #correlation of samsung with "memory used" variable
ggcorrplot(sam_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between samsung and memory usage over time")  

sam_stor_cor <- as.data.frame(cor(samAll[,c(2,11:13)]))  ;  #correlation of samsung with "storage used" variable
ggcorrplot(sam_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between samsung and storage usage over time")  
#GRAPHICAL REPRESENTATION
#class(samAll)
ggplot()+
  #geom_line(data= samAll, mapping = aes(x=eventime, y=crush, color = "Crush"))+
  #geom_line(data= samAll, mapping = aes(x=eventime, y=ConfirmPush, color = "ConfirmPush"))+
  #geom_line(data= samAll, mapping = aes(x=eventime, y=RealInter, color = "RealInter"))+
  #geom_line(data= samAll, mapping = aes(x=eventime, y=Publicstuff, color = "Publicstuff"))+
  #geom_line(data= samAll, mapping = aes(x=eventime, y=Cookie, color = "Cookie"))+
  #geom_line(data= samAll, mapping = aes(x=eventime, y=memless33, color = "Memory_usage_<33%"))+
  geom_line(data= samAll, mapping = aes(x=eventime, y=memless66, color = "Memory_usage"))+scale_y_continuous(expand = c(0,10)) +
  
  xlab('May 2020') + ylab('No. of events by Java crash types & Sam crush')+
  geom_point(alpha = 0.1, color = "blue")+
  theme(legend.position = "right")


#Correlation plot of GGally: an extension of ggplot2 for corelation matrix plots
#ggpairs(data=samAll, columns = 2:7)


##############
#6) ANALYSIS for HUAWEI
###################
#Huwaei Count                  View(count1)
hua <- 'HUAWEI'
counthua <-data.frame(manct(hua)) ; colnames(counthua) <- c("eventime","Hua.crash")
ggplot(data = counthua, mapping = aes(x=eventime, y = Hua.crash , 
                                      color = "No. of events for Huawei for \n the month of May 2020"))+
  geom_line()+geom_point(alpha = 0.1, color = "blue")+
  labs(title = "", x = "Event time", y = "Huwaei Crash report")+
  theme_bw()+
  theme(legend.position = "bottom")

#HUAWEI READYMADE DATASET with Java class problems
huaAll <- as.data.frame(dalx(counthua));
colnames(huaAll) <- c("eventime","hua.crush","hua.ConfirmPush","hua.RealInter","hua.Publicstuff","hua.Cookie","hua.RealCall"
                      ,"mem_less33","mem_between","mem_grt66","stor_less33","stor_between","stor_grt66") 
View(huaAll)         
###correlaiton plot
library(RColorBrewer)
library(ggcorrplot)
#########GG
hua_ja <-as.data.frame(cor(huaAll[,2:7])) 
ggcorrplot(hua_ja, method = "square",hc.order = TRUE,  type = "lower", outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between Huawei and Java class problems")   #PuOr #RdYlBu

hua_mem_cor <- as.data.frame(cor(huaAll[,c(2,8:10)]))  ;  #correlation of huasung with "memory used" variable
ggcorrplot(hua_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between huawei and memory usage over time")  

hua_stor_cor <- as.data.frame(cor(huaAll[,c(2,11:13)]))  ;  #correlation of huasung with "storage used" variable
ggcorrplot(hua_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between huawei and storage usage over time")  

ggplot()+
  geom_line(data= huaAll, mapping = aes(x=eventime, y=hua.crush, color = "HUAWEI_Crush"))+
  geom_line(data= huaAll, mapping = aes(x=eventime, y=hua.ConfirmPush, color = "ConfirmPush"))+
  geom_line(data= huaAll, mapping = aes(x=eventime, y=hua.RealInter, color = "RealInter"))+
  geom_line(data= huaAll, mapping = aes(x=eventime, y=hua.Publicstuff, color = "Publicstuff"))+
  geom_line(data= huaAll, mapping = aes(x=eventime, y=hua.Cookie, color = "Cookie"))+
  xlab('May 2020') + ylab('No. of events by Java crash types & HUAWEI crush')+
  geom_point(alpha = 0.1, color = "blue")+
  theme(legend.position = "right")

#END

###################
#6) ANALYSIS for XIAOMI
#XIAOMI ANALYSIS 
#xiaomi Count
xia <- 'Xiaomi' ; 
countxia <-data.frame(manct(xia)) ; 
colnames(countxia) <- c("eventime","xia.crash")

ggplot(data = countxia, mapping = aes(x=eventime, y = xia.crash , 
                                      color = "No. of events for xiaomi for \n the month of May 2020"))+
  geom_line()+geom_point(alpha = 0.1, color = "blue")+
                labs(title = "", x = "Event time", y = "xiaomi crash report")+
                theme_bw()+
                theme(legend.position = "bottom")

###
xiaAll <- as.data.frame(dalx(countxia));colnames(xiaAll) <- c("eventime","xia.crush","xia.ConfirmPush","xia.RealInter","xia.Publicstuff","xia.Cookie","xia.RealCall",
                                                              "mem_less33","mem_between","mem_grt66","stor_less33","stor_between","stor_grt66") 

###correlaiton plot

#########GG
xia_ja <-as.data.frame(cor(xiaAll[,2:7])) ; 
ggcorrplot(xia_ja, method = "square",hc.order = TRUE,  type = "lower", outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between Xiaomi and Java class problems")   #PuOr #RdYlBu


xia_mem_cor <- as.data.frame(cor(xiaAll[,c(2,8:10)]))  ;  #correlation of xiasung with "memory used" variable
ggcorrplot(xia_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between Xiaomi and memory usage over time")  

xia_stor_cor <- as.data.frame(cor(xiaAll[,c(2,11:13)]))  ;  #correlation of samsung with "storage used" variable
ggcorrplot(xia_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between Xiaomi and storage usage over time")  



ggplot()+
              geom_line(data= xiaAll, mapping = aes(x=eventime, y=xia.crush, color = "Xiaomi_Crush"))+
                geom_line(data= xiaAll, mapping = aes(x=eventime, y=xia.ConfirmPush, color = "ConfirmPush"))+
              geom_line(data= xiaAll, mapping = aes(x=eventime, y=xia.RealInter, color = "RealInter"))+
                geom_line(data= xiaAll, mapping = aes(x=eventime, y=xia.Publicstuff, color = "Publicstuff"))+
              geom_line(data= xiaAll, mapping = aes(x=eventime, y=xia.Cookie, color = "Cookie"))+
                              xlab('May 2020') + ylab('No. of events by Java crash types & Xiaomi crush')+
                geom_point(alpha = 0.1, color = "blue")+
  theme(legend.position = "right")
 
#Correlation plot of GGally: an extension of ggplot2 for corelation matrix plots
#ggpairs(data=xiaAll, columns = 2:7)

#geom_line(data= xiaAll, mapping = aes(x=eventime, y=xia.Realcall, color = "Realcall"))+

#END
#############
#8) ANALYSIS for LGE
##LGE Count
lge <- 'LGE' ; 
countlge <-data.frame(manct(lge)) ; colnames(countlge) <- c("eventime","lge.crash")

ggplot(data = countlge, mapping = aes(x=eventime, y = lge.crash , 
                                      color = "No. of events for LGE for \n the month of May 2020"))+
  geom_line()+  geom_point(alpha = 0.1, color = "blue")+
  labs(title = "", x = "Event time", y = "LGE crash report")+
  theme_bw()+
  theme(legend.position = "bottom")

###
 
###Dataset for lge
lgeAll <- as.data.frame(dalx(countlge));colnames(lgeAll) <- c("eventime","lge.crush","lge.ConfirmPush","lge.RealInter","lge.Publicstuff","lge.Cookie","lge.RealCall"
                                                              ,"mem_less33","mem_between","mem_grt66","stor_less33","stor_between","stor_grt66") 


#########GG
lge_ja <-cor(lgeAll[,2:7],use="complete.obs") 
ggcorrplot(lge_ja, method = "square",hc.order = TRUE,  type = "lower", outline.col = "white",
                    colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
                    title = "Correlation coefficient between LGE and Java class problems")   #PuOr #RdYlBu

lge_mem_cor <- as.data.frame(cor(lgeAll[,c(2,8:10)]))  ;  #correlation of LGE with "memory used" variable
ggcorrplot(lge_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between LGE and memory usage over time")  

lge_stor_cor <- as.data.frame(cor(lgeAll[,c(2,11:13)]))  ;  #correlation of samsung with "storage used" variable
ggcorrplot(lge_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between LGE and storage usage over time")  


ggplot()+
  geom_line(data= lgeAll, mapping = aes(x=eventime, y=lge.crush, color = "LGE_Crush"))+
  geom_line(data= lgeAll, mapping = aes(x=eventime, y=lge.ConfirmPush, color = "ConfirmPush"))+
  geom_line(data= lgeAll, mapping = aes(x=eventime, y=lge.RealInter, color = "RealInter"))+
  geom_line(data= lgeAll, mapping = aes(x=eventime, y=lge.Publicstuff, color = "Publicstuff"))+
  geom_line(data= lgeAll, mapping = aes(x=eventime, y=lge.Cookie, color = "Cookie"))+
  xlab('May 2020') + ylab('No. of events by Java crash types & LGE crush')+
  geom_point(alpha = 0.1, color = "blue")+
  theme(legend.position = "right")



#END


#9) ANALYSIS for ASUS
#ASUS Count                  
asus <- 'asus' ; 
countasus <-data.frame(manct(asus)) ; colnames(countasus) <- c("eventime","asus.crash")

ggplot(data = countasus, mapping = aes(x=eventime, y = asus.crash , 
                                      color = "No. of events for ASUS for \n the month of May 2020"))+
  geom_line()+  geom_point(alpha = 0.1, color = "blue")+
  labs(title = "", x = "Event time", y = "ASUS crash report")+
  theme_bw()+  theme(legend.position = "bottom")

###correlaiton plot
asusAll <- as.data.frame(dalx(countasus));colnames(asusAll) <- c("eventime","asus.crush","asus.ConfirmPush","asus.RealInter","asus.Publicstuff","asus.Cookie","asus.RealCall"
                                                                 ,"mem_less33","mem_between","mem_grt66","stor_less33","stor_between","stor_grt66") 

#########GG
asus_ja <-cor(asusAll[,2:7],use="complete.obs") 
ggcorrplot(asus_ja, method = "square",hc.order = TRUE,  type = "lower", outline.col = "white",
                     colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
                     title = "Correlation coefficient between ASUS and Java class problems")   #PuOr #RdYlBu


asus_mem_cor <- as.data.frame(cor(asusAll[,c(2,8:10)]))  ;  #correlation of ASUS with "memory used" variable
ggcorrplot(asus_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between ASUS and memory usage over time")  

asus_stor_cor <- as.data.frame(cor(asusAll[,c(2,11:13)]))  ;  #correlation of asussung with "storage used" variable
ggcorrplot(asus_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between ASUS and storage usage over time")  


ggplot()+
  geom_line(data= asusAll, mapping = aes(x=eventime, y=asus.crush, color = "ASUS_Crush"))+
  geom_line(data= asusAll, mapping = aes(x=eventime, y=asus.ConfirmPush, color = "ConfirmPush"))+
  geom_line(data= asusAll, mapping = aes(x=eventime, y=asus.RealInter, color = "RealInter"))+
  geom_line(data= asusAll, mapping = aes(x=eventime, y=asus.Publicstuff, color = "Publicstuff"))+
  geom_line(data= asusAll, mapping = aes(x=eventime, y=asus.Cookie, color = "Cookie"))+
  xlab('May 2020') + ylab('No. of events by Java crash types & ASUS crush')+
  geom_point(alpha = 0.1, color = "blue")+
  theme(legend.position = "right")

#10) ANALYSIS for WIKO
###################
#WIKO count
wiko <- 'WIKO' ; 
countwiko <-data.frame(manct(wiko)) ; colnames(countwiko) <- c("eventime","wiko.crash")

#plotting
ggplot(data = countwiko, mapping = aes(x=eventime, y = wiko.crash , 
                                       color = "No. of events for WIKO for \n the month of May 2020"))+
  geom_line()+  geom_point(alpha = 0.1, color = "blue")+
  labs(title = "", x = "Event time", y = "WIKO crash report")+
  theme_bw()+
  theme(legend.position = "bottom")

###
##=
#Wiko with the first java class problem 
wikoAll <- as.data.frame(dalx(countwiko));
colnames(wikoAll) <- c("eventime","wiko.crush","wiko.ConfirmPush","wiko.RealInter","wiko.Publicstuff","wiko.Cookie",
                      "wiko.RealCall","mem_less33","mem_between","mem_grt66","stor_less33","stor_between","stor_grt66") 

wiko_ja <-as.data.frame(cor(wikoAll[,2:7])) 
ggcorrplot(wiko_ja, method = "square",hc.order = TRUE,  type = "lower", outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between WIKO and Java class problems")

wiko_mem_cor <- as.data.frame(cor(wikoAll[,c(2,8:10)]))  ;  #correlation of samsung with "memory used" variable
ggcorrplot(wiko_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between WIKO and memory usage over time")  

wiko_stor_cor <- as.data.frame(cor(wikoAll[,c(2,11:13)]))  ;  #correlation of samsung with "storage used" variable
ggcorrplot(wiko_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between WIKO and storage usage over time")  




ggplot()+
  geom_line(data= wikoAll, mapping = aes(x=eventime, y=wiko.crush, color = "WIKO_Crush"))+
  geom_line(data= wikoAll, mapping = aes(x=eventime, y=wiko.ConfirmPush, color = "ConfirmPush"))+
  geom_line(data= wikoAll, mapping = aes(x=eventime, y=wiko.RealInter, color = "RealInter"))+
  geom_line(data= wikoAll, mapping = aes(x=eventime, y=wiko.Publicstuff, color = "Publicstuff"))+
  geom_line(data= wikoAll, mapping = aes(x=eventime, y=wiko.Cookie, color = "Cookie"))+
  xlab('May 2020') + ylab('No. of events by Java crash types & WIKO crush')+
  geom_point(alpha = 0.1, color = "blue")+
  theme(legend.position = "right")

#geom_line(data= wikoAll, mapping = aes(x=eventime, y=wiko.Realcall, color = "Realcall"))+

#END

#Event by manufacturers: ALL IN ONE
ggplot()+
  geom_line(data= wikoAll, mapping = aes(x=eventime, y=wiko.crush, color = "WIKO_Crush"))+
  geom_line(data= lgeAll, mapping = aes(x=eventime, y=lge.crush, color = "LGE_Crush"))+
  geom_line(data = samAll, mapping = aes(x=eventime, y=crush, color = "SAM_crush"))+
  geom_line(data = asusAll, mapping = aes(x=eventime, y = asus.crush, color = "ASUS_Crush"))+
  geom_line(data = huaAll, mapping = aes(x=eventime, y = hua.crush, color = "HUAWEI_Crush"))+
  geom_line(data = xiaAll, mapping = aes(x=eventime, y = xia.crush, color = "XIAOMI_Crush"))+
  labs(title = "Event by manufacturers", x = "Days of the month", y = "Events")+
  theme_bw()+geom_point(alpha = 0.9, color = "blue")
  
###END
install.packages("fpp2")
library(fpp2)
library(pander)
install.packages("forecast")
library(forecast)
install.packages("TSstudio")
install.packages("PerformanceAnalytics")
install.packages("tsbox")
remotes::install_github("christophsax/tsbox")
x.ts <- ts_c(fdeaths, mdeaths) #time series object
x.xts <- ts_xts(x.ts)  #xts
x.df <- ts_df(x.xts) #df
x.dt <- ts_dt(x.df)
x.tbl <- ts_tbl(x.dt)
x.zoo <- ts_zoo(x.tbl)
x.tsibble <- ts_tsibble(x.zoo)
x.tibbletime <- ts_tibbletime(x.tsibble)
x.timeSeries <- ts_timeSeries(x.tibbletime)
all.equal(ts_ts(x.timeSeries), x.ts) 



































library(tidyr)
# 1) Analysis for Samsung
bada <- function(x) {
 
manct <- function(x){
  countman <- ress1 %>%
    select(devicemanufacturer,eventime) %>%
    filter(devicemanufacturer == x) %>%
    arrange(eventime)%>% 
    group_by(eventime) %>% 
    summarize(obs = n(), .groups = 'drop')
}
sam <- 'x'
countsam <-data.frame(manct(sam)) 
colnames(countsam) <- c("eventime","Sam.crash")
ct <- ggplot(data = countsam, mapping = aes(x=eventime, y = Sam.crash , color = "No. of events for Samsung for \n the month of May 2020"))+
  geom_line()+geom_point(alpha = 0.1, color = "blue")+    labs(title = "", x = "Event time", y = "Samsung crash report")+
  theme_bw()+ theme(legend.position = "bottom")
return(data.frame(countsam))
#print(ct)
}
#for (variable in vector) {
 # bada(samsung)
#}
bada(samsung)
x <- list('samsung','HUAWEI')
x %>% map_chr(x, bada)


{
samAll <- as.data.frame(dalx(countsam));
colnames(samAll) <- c("eventime","Sam.crush","ConfirmPush","RealInter","Publicstuff","Cookie",
                      "RealCall","mem_less33","mem_between","mem_grt66","stor_less33","stor_between","stor_grt66",
                      "framef1","framef2","framef3","framef4") 
sam_ja <-as.data.frame(cor(samAll[,2:7])) 
ggcorrplot(sam_ja, method = "square",hc.order = TRUE,  type = "lower", outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between samsung and Java class problems")
sam_mem_cor <- as.data.frame(cor(samAll[,c(2,8:10)]))  ;  #correlation of samsung with "memory used" variable
ggcorrplot(sam_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           colors = c("#6D9EC1", "white", "#E46726"),lab = TRUE,
           title = "Correlation coefficient between samsung and memory usage over time")  
sam_stor_cor <- as.data.frame(cor(samAll[,c(2,11:13)]))  ;  #correlation of samsung with "storage used" variable
ggcorrplot(sam_mem_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between samsung and storage usage over time")  
sam_frame_cor <- as.data.frame(cor(samAll[,c(2,14:17)]))  ;  #correlation of samsung with "frame_file" variable
ggcorrplot(sam_frame_cor, method = "square",hc.order = TRUE,  outline.col = "white",
           lab = TRUE, colors = c("#F8696B", "#FFEB84", "#63BE7B"),insig = "blank", 
           title = "Correlation coefficient between samsung and frame_file over time")  
}







x <- 1
h <- function() {
  y <- 2
  i <- function() {
    z <- 3
    c(x, y, z)
  }
  i()
}
h()
rm(x, h)

df0 <- c("Total cholestrol","HDL","LDL","TRIG")
df1 <- c(164,40,104,78)
df2 <- c(190,38,113,150)
df3 <- c(200,55,100,150)
df <- cbind(df0,df1,df2,df3)
View(df)

#colnames(df) <- c("May 2020","Aug 2020","Threshold")
dk <- t(df)
View(dk)
dk <- as.data.frame(dk) ; dk <- dk[-1,]
colnames(dk) <- c("Total cholestrol","HDL","LDL","TRIG")
#dk <- as.data.frame(dk, row.names = FALSE)
month <- c("May 2020","Aug 2020","Threshold")
View(month)
pa <- as.data.frame(cbind(month, dk))
View(pa)
plot(pa)
ggplot(data = pa, aes(x=month, y=HDL, color = 'rating'))+
  geom_line()





