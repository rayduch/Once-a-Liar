################################################################
## Paper: Is Cheating a national pastime? Experimental evidence
## Author code: Denise Laroze
## Year: 2018
################################################################


library(foreign)
library(ggplot2)
library(readstata13)
library(RColorBrewer)
library(rms)
theme_set(theme_bw())
library(plyr)
library(stargazer)
library(gridExtra)
library(clusterSEs)
library(car)



rm(list=ls())

setwd("C:/Users/Denise Laroze P/Documents/GitHub/Once-a-Liar/General")
fig.path <- "Figures"
v<-"Nov2018"

dat<- read.dta13("mastern_final2018_new_new.dta")
#subject<-read.dta13("subjects_2018.dta")
#online.chile<-read.csv("CESS_Panel_DS_Stgo_2017.csv")
#names(rus)<- tolower(names(rus))


##########################
### Figures
############################
###########

###########################
### Die by type Figure 2
###########################

subject<-dat[ dat$include_data_all==1,]


subject$ind_typenew3[subject$ind_typenew2==1] <- "Consistent Maximal"
subject$ind_typenew3[subject$ind_typenew2==2] <- "Consistent Partial"
subject$ind_typenew3[subject$ind_typenew2==3] <- "Consistent Honest"
subject$ind_typenew3[subject$ind_typenew2==4] <- "Other"


pt<-prop.table(table(subject$realdie, subject$ind_typenew3), 2)
pt<-as.data.frame(pt)

names(pt)<-c("die", "type", "prop" )
pt$type <- factor(pt$type, levels = c("Consistent Maximal", "Consistent Partial", "Consistent Honest", "Other"))



d<-ggplot(pt, aes(x = die, y = prop, colour=type, fill=type)) + geom_bar(stat = "identity" ,position="dodge") + 
  ylab("Fraction") + scale_y_continuous( limits = c(0,1)) +
  xlab("") + labs(colour="", fill="") +
  geom_hline(yintercept = 1/6, lty="dashed", col="black", size=1)+
  scale_fill_manual(values= c("grey90", "grey60", "grey40", "grey20"), guide = guide_legend(title = "")) +
  scale_color_manual(values= c("grey90", "grey60", "grey40", "grey20"))+
  theme(legend.position="bottom")
d
ggsave(paste0("Figure2",v, ".eps"), path=fig.path, width = 9, height = 6)



############################
### Figure 3 Reaction times
############################

p.df<-dat[, c("time_declare", "include_data", "declared_cat", "country_code"  )]
p.df$country[p.df$country_code==1] <- "Chile"
p.df$country[p.df$country_code==2] <- "Russia"
p.df$country[p.df$country_code==3] <- "U.K."


p.df$time_declare[p.df$include_data==0]<-NA
p.df<-p.df[complete.cases(p.df$time_declare),]

set.seed(23356)
p.df$time_declare_1<-p.df$time_declare+runif(nrow(p.df))


#### RT cummulative distribution plot

setEPS()
postscript(paste0("Figures/Figure3",v, ".eps"), width = 11, height = 7)


par(pty='m')
plot(ecdf(p.df$time_declare_1[p.df$declared_cat==1]),
     xlim=c(0,30),
     ylim=c(0,1),
     xlab="Seconds",
     ylab="",
     main="",
     col="black",
     lty=1, lwd=3)

lines(ecdf(p.df$time_declare_1[p.df$declared_cat==2]),
        col="grey70",  lty=3, lwd=3)

lines(ecdf(p.df$time_declare_1[p.df$declared_cat==3]),
          col="grey40", lty=2, lwd=3)
legend('bottomright', 
       legend=c("Maximal Cheating","Partial Cheating","Honest"),  # text in the legend
       col=c("black","grey70","grey40"), 
       lty = c(1, 3, 2)#,# point colors
       #pch=15
)

dev.off()



#######################################
###Figure B2 Cheater types by country
########################################

dat$declared_near<- ifelse ( dat$declared_frac>0 & dat$declared_frac<=.2, 1, 0)


p.df<-dat[, c("country_code", "hightype" , "include_data", "include_data_all", "declared_0", "declared_f", "declared_near")]
p.df$country[p.df$country_code==1] <- "Chile"
p.df$country[p.df$country_code==2] <- "Russia"
p.df$country[p.df$country_code==3] <- "U.K."


p.df$include_data[p.df$include_data_all==0]<-NA
p.df<-p.df[complete.cases(p.df$include_data),]


p.df$type[p.df$declared_0==1]<-"Maximal"
p.df$type[p.df$declared_f==1]<-"Limited"
p.df$type[p.df$declared_near==1]<-"Near-Maximal"



pt<-prop.table(table(p.df$type, p.df$hightype, p.df$country), c(3,2))

prop.t<-as.data.frame(pt)

names(prop.t)<-c("type", "perform_high" ,"country", "prop" )
prop.t$perform_high_lab<-ifelse(prop.t$perform_high==1, "High Performance", "Low Performance")

prop.t$type <- factor(prop.t$type, levels = c("Maximal", "Limited", "Near-Maximal"))



d<-ggplot(prop.t, aes(x = type, y = prop, colour=perform_high_lab, fill=perform_high_lab)) + geom_bar(stat = "identity", position = "dodge") + 
  ylab("Percent") + scale_y_continuous(labels = scales::percent , limits = c(0,1)) +
  xlab("") + labs(colour="", fill="") +
  scale_fill_manual("", values = c("red", "blue"))+
  theme(text = element_text(size=20))+
  #geom_hline(yintercept = 1/6, lty="dashed", col="red")+
  facet_wrap(~  country, ncol = 3) +  
  theme(legend.position="bottom", legend.text=element_text(size=15))
d

ggsave(paste0("FigureB2",v, ".eps"), path=fig.path, width = 12, height = 5)






###############################
### Figure C2
################################
p.df<-dat[, c("country_code", "ind_typenew2", "offerdg" ,"offerdg_0", "include_data")]
p.df$country[p.df$country_code==1] <- "Chile"
p.df$country[p.df$country_code==2] <- "Russia"
p.df$country[p.df$country_code==3] <- "U.K."

p.df$type[p.df$ind_typenew2==1] <- "C. Maximal"
p.df$type[p.df$ind_typenew2==2] <- "C. Partial"
p.df$type[p.df$ind_typenew2==3] <- "C. Honest"
p.df$type[p.df$ind_typenew2==4] <- "Other"

p.df$dg_type<-ifelse(p.df$offerdg_0==1, "Give 0", "Give >0")

p.df$ind_typenew2[p.df$include_data==0]<-NA
p.df<-p.df[complete.cases(p.df$ind_typenew2),]


pt<-prop.table(table(p.df$type, p.df$dg_type, p.df$country), c(3,2))

prop.t<-as.data.frame(pt)

names(prop.t)<-c("type", "dg_type" ,"country", "prop" )



prop.t$type <- factor(prop.t$type, levels = c("C. Maximal", "C. Partial", "C. Honest", "Other"))
prop.t$dg_type <- factor(prop.t$dg_type, levels = c("Give 0", "Give >0"))



d<-ggplot(prop.t, aes(x = type, y = prop, colour=dg_type, fill=dg_type)) + geom_bar(stat = "identity", position = "dodge") + 
  ylab("Percent") + scale_y_continuous(labels = scales::percent , limits = c(0,1)) +
  xlab("") + labs(colour="", fill="") +
  theme(text = element_text(size=20))+
  scale_fill_manual("", values = c("black", "grey60"))+
  scale_colour_manual("", values = c("black", "grey60"))+
  #geom_hline(yintercept = 1/6, lty="dashed", col="red")+
  facet_wrap(~  country, ncol = 3) +  theme(legend.position="bottom", legend.text=element_text(size=15))
d
ggsave(paste0("FigureC2",v, ".eps"), path=fig.path, width = 16, height = 5)







###########################################
### Figure C4: Digital die
###########################################
subject<-dat[ dat$include_data_all==1,]
subject<-subject[ subject$digitaldie_actual>=0,]
subject<-subject[ subject$period==2,]


subject$ind_typenew3[subject$ind_typenew2==1] <- "Consistent Maximal"
subject$ind_typenew3[subject$ind_typenew2==2] <- "Consistent Partial"
subject$ind_typenew3[subject$ind_typenew2==3] <- "Consistent Honest"
subject$ind_typenew3[subject$ind_typenew2==4] <- "Other"


pt<-prop.table(table(subject$digitaldie, subject$ind_typenew3), 2)
pt<-as.data.frame(pt)

names(pt)<-c("die", "type", "prop" )
pt$type <- factor(pt$type, levels = c("Consistent Maximal", "Consistent Partial", "Consistent Honest", "Other"))



d<-ggplot(pt, aes(x = die, y = prop, colour=type, fill=type)) + geom_bar(stat = "identity" ,position="dodge") + 
  ylab("Fraction") + scale_y_continuous( limits = c(0,1)) +
  xlab("") + labs(colour="", fill="") +
  geom_hline(yintercept = 1/6, lty="dashed", col="black", size=1)+
  scale_fill_manual(values= c("grey90", "grey60", "grey40", "grey20"), guide = guide_legend(title = "")) +
  scale_color_manual(values= c("grey90", "grey60", "grey40", "grey20"))+
  theme(legend.position="bottom")
d
ggsave(paste0("FigureC4",v, ".eps"), path=fig.path, width = 9, height = 6)




##########################################
#### Figure C5 Reaction time per country
##########################################



p.dfc<-subset(p.df, country=="Chile")
p.dfu<-subset(p.df, country=="U.K.")
p.dfr<-subset(p.df, country=="Russia")

setEPS()
postscript(paste0("Figures/FigureC5",v, ".eps"), width = 11, height = 7)


par(mfrow=c(1,3))

# Chile
plot(ecdf(p.dfc$time_declare_1[p.dfc$declared_cat==1]),
     xlim=c(0,30),
     ylim=c(0,1),
     xlab="Seconds",
     ylab="",
     main="Chile",
     col="black",
     lty=1, lwd=3)

lines(ecdf(p.dfc$time_declare_1[p.dfc$declared_cat==2]),
      col="grey70",  lty=3, lwd=3)

lines(ecdf(p.dfc$time_declare_1[p.dfc$declared_cat==3]),
      col="grey40", lty=2, lwd=3)
      

# UK
plot(ecdf(p.dfu$time_declare_1[p.dfu$declared_cat==1]),
     xlim=c(0,30),
     ylim=c(0,1),
     xlab="Seconds",
     ylab="",
     main="U.K.",
     col="black",
     lty=1, lwd=3)

lines(ecdf(p.dfu$time_declare_1[p.dfu$declared_cat==2]),
      col="grey70",  lty=3, lwd=3)

lines(ecdf(p.dfu$time_declare_1[p.dfu$declared_cat==3]),
      col="grey40", lty=2, lwd=3)



# Russia
plot(ecdf(p.dfr$time_declare_1[p.dfr$declared_cat==1]),
     xlim=c(0,30),
     ylim=c(0,1),
     xlab="Seconds",
     ylab="",
     main="Russia",
     col="black",
     lty=1, lwd=3)

lines(ecdf(p.dfr$time_declare_1[p.dfr$declared_cat==2]),
      col="grey70",  lty=3, lwd=3)

lines(ecdf(p.dfr$time_declare_1[p.dfr$declared_cat==3]),
      col="grey40", lty=2, lwd=3)

legend('bottomright', 
       legend=c("Maximal Cheating","Partial Cheating","Honest"),  # text in the legend
       col=c("black","grey70","grey40"), 
       lty = c(1, 3, 2)#,# point colors
)

dev.off()












###################################
#### Posibly eliminate from code
###################################
############################
### Cheater type
######################.
p.df<-dat[, c("country_code", "ind_typenew2", "hightype", "include_data")]
p.df$country[p.df$country_code==1] <- "Chile"
p.df$country[p.df$country_code==2] <- "Russia"
p.df$country[p.df$country_code==3] <- "U.K."


p.df$ind_typenew2[p.df$include_data==0]<-NA
p.df<-p.df[complete.cases(p.df$ind_typenew2),]


pt<-prop.table(table(p.df$ind_typenew2, p.df$hightype, p.df$country), c(3,2))

prop.t<-as.data.frame(pt)

names(prop.t)<-c("ind_typenew2", "perform_high" ,"country", "prop" )
prop.t$perform_high_lab<-ifelse(prop.t$perform_high==1, "High Performance", "Low Performance")
prop.t$ind_typenew2_lab<-ifelse(prop.t$ind_typenew2==1, "C. Maximal", 
                                ifelse(prop.t$ind_typenew2==2, "C. Partial",
                                       ifelse(prop.t$ind_typenew2==3, "C. Honest", "Other")
                                )
)


prop.t$ind_typenew2_lab <- factor(prop.t$ind_typenew2_lab, levels = c("C. Maximal", "C. Partial", "C. Honest", "Other"))



d<-ggplot(prop.t, aes(x = ind_typenew2_lab, y = prop, colour=perform_high_lab, fill=perform_high_lab)) + geom_bar(stat = "identity", position = "dodge") + 
  ylab("Percent") + scale_y_continuous(labels = scales::percent , limits = c(0,0.7)) +
  xlab("") + labs(colour="", fill="") +
  theme(text = element_text(size=20))+
  scale_fill_manual("", values = c("red", "blue"))+
  #geom_hline(yintercept = 1/6, lty="dashed", col="red")+
  facet_wrap(~  country, ncol = 3) +
  theme(legend.position="bottom", legend.text=element_text(size=20))
d
ggsave(paste0("cheater_type_performance",v, ".pdf"), path=fig.path, width = 16, height = 5)



