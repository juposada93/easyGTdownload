library(gtrendsR)
library(lubridate)
library(zoo)

#######Inputs

#Directory
directory <- "C:/Users/22567864/Dropbox/Useful code/output/GT"

#name of the end file
filename<-"civil" 

#Search term you want to use
#Topics are not usual search terms. For example, "%2Fm%2F020v2" is civil war.
searchterm<-"%2Fm%2F020v2"

#Courty
country<-"CO"

#first year of analysis (GT goes back to 2004)
syear<-2004

#last year of analysis
eyear<-2016



#Daily
#####
for(t in 1:5) {
  hits    <-vector()
  date    <-vector()
  meses<-as.vector(c(31,28,31,30,31,30,31,31,30,31,30,31))
for (y in syear:eyear) {
  mes<-1
for (i in meses) {
  
  time<-paste(y,"-",mes,"-01"," ",y,"-",mes,"-", i, sep = "")
  
  topic_tool  <-gtrends(keyword = searchterm , geo = "CO", time = time)
  
  hits<-            as.vector(append(hits, topic_tool$interest_over_time$hits))
  date<-as_datetime(as.vector(append(date, topic_tool$interest_over_time$date)))
  
mes<-mes+1
}}

data<-data.frame(date, hits)
write.csv(data, file = paste(directory, "/D", filename, t, ".csv", sep=""), col.names =FALSE)
}

#Weekly
#####
for(t in 1:2) {
  Whits    <-vector()
  Wdate    <-vector()
  for (y in syear:eyear) {
    time<-paste(y,"-01-01"," ",y,"-12-31", sep = "")
    time
    topic_tool  <-gtrends(keyword = searchterm , geo = country, time = time)
    
    Whits<-            as.vector(append(Whits, topic_tool$interest_over_time$hits))
    Wdate<-as_datetime(as.vector(append(Wdate, topic_tool$interest_over_time$date)))
  }
  data<-data.frame(Wdate, Whits)
  write.csv(data, file = paste(directory, "/W", filename, t, ".csv", sep=""), col.names =FALSE)
}


#Monthly
#####
Mhits    <-vector()
Mdate    <-vector()

time<-paste(syear,"-01-01"," ",eyear,"-12-31", sep = "")
topic_tool  <-gtrends(keyword = searchterm , geo = "CO", time = time)

Mhits<-            as.vector(append(Mhits, topic_tool$interest_over_time$hits))
Mdate<-as_datetime(as.vector(append(Mdate, topic_tool$interest_over_time$date)))

data<-data.frame(Mdate, Mhits)
write.csv(data, file = paste(directory, "/M", filename , ".csv", sep=""), col.names =FALSE)


#Splicing
##### 

datafiles <- lapply(Sys.glob(paste(directory, "/D", filename, "*.csv", sep = "")), read.csv)
file <- merge(datafiles[1], datafiles[2], by="date", all.x = TRUE)
file <- merge(file, datafiles[3], by="date", all.x = TRUE)
file <- merge(file, datafiles[4], by="date", all.x = TRUE)
file <- merge(file, datafiles[5], by="date", all.x = TRUE)
file<-file[, (names(file) %in% c("date", "hits.x", "hits.y", "hits"))]
file$mean <- rowMeans(file[ , c(2:6)], na.rm=TRUE)


datafiles <- lapply(Sys.glob(paste(directory, "/W", filename, "*.csv", sep = "")), read.csv)
Wfile<-merge(datafiles[1], datafiles[2], by="Wdate", all.x = TRUE)
Wfile<-Wfile[, (names(Wfile) %in% c("Wdate", "Whits.x", "Whits.y"))]
Wfile$Wmean <- rowMeans(Wfile[ , c(2:3)], na.rm=TRUE)
names(Wfile)[1] <- "date"


datafiles <- lapply(Sys.glob(paste(directory, "/M", filename, "*.csv", sep = "")), read.csv)
Mfile<-data.frame(datafiles[1])
Mfile<-Mfile[, (names(Mfile) %in% c("Mdate", "Mhits"))]
names(Mfile)[1] <- "date"

total <- merge(file, Wfile, by="date", all.x = TRUE)
total <- merge(total, Mfile, by="date", all.x = TRUE)
remove(datafiles, file, Wfile, Mfile)

total<-total[, (names(total) %in% c("date", "mean", "Wmean", "Mhits"))]
names(total)[2] <- "daily"
names(total)[3] <- "weekly"
names(total)[4] <- "monthly"


total$monthly<-na.locf(total$monthly)
total$weekly[1]<-0
total$weekly<-na.locf(total$weekly)


total$Wsplice<-total$monthly/total$weekly*100
total$Wsplice[!is.finite(total$Wsplice)] <- 0

total$Dsplice<-total$Wsplice/total$daily
total$Dsplice[!is.finite(total$Dsplice)] <- 0

total<-total[, (names(total) %in% c("date", "Dsplice"))]

write.csv(total, file = paste(directory, "/", filename, ".csv", sep=""), col.names =FALSE)






