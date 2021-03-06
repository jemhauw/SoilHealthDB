
#*****************************************************************************************************************
# Step 1: load data
#*****************************************************************************************************************
library(ggplot2)
# install.packages("ggmap")
library(ggmap)
# install.packages("maps")
library(maps)
# install.packages("mapdata")
library(mapdata)
# library("gridExtra")
# install.packages("readxl")
library("readxl")

data_loc <- paste(here::here(), "data", sep = "/")
outputs_loc <- paste(here::here(), "outputs", sep = "/")

source(paste(here::here(),"RScripts/functions.R", sep = "/"))

soilhealthData <- read.csv(paste(data_loc, "SoilHealthDB_V1.csv", sep="/"), header = T)

# Subset

#*****************************************************************************************************************
# Step 2: data quality check 
# check background information (contries's latitude and longitude and other numeric background informations)
#*****************************************************************************************************************
#2.1 check potential location input error
attach(soilhealthData)
Country <- as.character(Country)
sort(unique(Country)) # data from 43 countries, all data has contry information
# unique(soilhealthData[Country == '',]$StudyID)


varCountry <- c("Argentina","Australia", "Bangladesh","Benin"
  , "Brazil", "Cameroon",  "Canada", "China",  "Costa Rica"   
  , "Denmark",  "England",   "France", "Germany"  
  ,  "Ghana",  "Greece", "Guinea", "India",  "Indonesia"
  , "Italy",  "Kenya",  "Malawi", "Netherland","New Zealand"  
  , "Nigeria",   "Norway", "Peru",   "Philippines", "Poland"  
  , "Republic of Moldova", "Rwanda", "South Korea", "Spain",  "Sweden" 
  , "Switzerland", "Tanzania",  "Togo", "Turkey", "Uganda"   
  , "USA", "Zambia", "Zimbabwe")

sub_country <- as.data.frame(matrix(NA, ncol = 7, nrow = 41))
colnames(sub_country) <- c("ID", "Country", "Lat_min", "Lat_max", "Long_min", "Long_max", "obs(n)")


for (i in 1:length(varCountry)) {
  subdata <- soilhealthData[soilhealthData$Country == varCountry[i],]
  min_lat <- min(subdata$Latitude, na.rm = T)
  max_lat <- max(subdata$Latitude, na.rm = T)
  min_long <- min(subdata$Longitude, na.rm = T)
  max_long <- max(subdata$Longitude, na.rm = T)
  n_obs <- length(subdata$StudyID) # number of observations in this country
  
  sub_country[i,] <- list(i,varCountry[i], min_lat, max_lat, min_long, max_long, n_obs)
}

sub_country # view and check potential latitude and longitude input error

# save results as csv****************************************************************
write.csv(sub_country, paste(outputs_loc,'1. latitude and longitude by country check.csv', sep = "/" ), row.names = F )

colnames(soilhealthData)

# create a function to plot histgram of numeric background information
qc_background <- function (bk, tex_ylab) { 
  ggplot(soilhealthData, aes(x=bk)) + 
    geom_histogram(color="black", fill="gray") + theme_bw() +
    xlab (tex_ylab)
}

# plot and output figures****************************************************************

pdf( paste(outputs_loc,'QC1. Backgroud information histgram.pdf', sep = "/" ), width=6, height=4)

#2.2 check publication year
qc_background (YearPublication, "Paper published year")

# 2.3 check elevation
qc_background (Elevation, "Elevation")

# 2.4
qc_background ( Tannual, "Annual temperature" )

# 2.5
qc_background ( MAT, "Mean annual temperature" )

# 2.6
qc_background ( Pannual, "Annual precipitation" )

# 2.7
qc_background ( MAP, "Mean annual precipitation" )

# 2.8
qc_background ( TimeAfterCoverCrop, "Years after cover-crop or tillage" )

# 2.9
qc_background ( Duration, "Duration of cover-crop or tillage" )

# 2.10
qc_background ( SoilBD, "Soil bulk dsity" )

# 2.11
qc_background ( SandPerc, "Sand percentage (%)" )

# 2.12
qc_background ( SiltPerc, "Silt percentage (%)" )

# 2.13
qc_background ( ClayPerc, "Clay percentage (%)" )

# 2.14
qc_background ( SoilpH, "Soil pH" )

# 2.15
qc_background( SoilTC, "Soil background carbon (%)" )

# 2.16
qc_background( SoilKsat, "Soil saurated conductivity" )

# 2.17
qc_background( No_C, "Number of replication for control (n)" )

# 2.18
qc_background( No_T, "Number of replication for treatment (n)" )

# 2.19
qc_background( NoSubsample, "Number of subsamples (n)" )

dev.off()


#*****************************************************************************************************************
# Step 3: data quality check -- check indicators
#*****************************************************************************************************************


# first response infor column
which(colnames(soilhealthData) == 'BiomassCash_C')
# OC
which(colnames(soilhealthData) == 'OC_C')
# N
which(colnames(soilhealthData) == 'N_C')
# last useful parameter
which(colnames(soilhealthData) == 'MBN_C')

# get all response indicators and store in respcol -- control
respcol <- c(seq(which(colnames(soilhealthData) == 'BiomassCash_C'),which(colnames(soilhealthData) == 'OC_C'),5)
             ,seq(which(colnames(soilhealthData) == 'N_C'),which(colnames(soilhealthData) == 'MBN_C'),5)) # all response columns
res_name <- colnames(soilhealthData)[respcol]

# get all response indicators and store in respcol2 -- trentment
respcol2 <- respcol+1
res_name2 <- colnames(soilhealthData)[respcol2]


# plot and output figures****************************************************************

pdf( paste(outputs_loc,'QC2. Soil health indicator histgram.pdf', sep = "/" ), width=8, height=4)

par( mar=c(2, 0.2, 0.2, 0.2)
     , mai=c(0.4, 0.6, 0.0, 0.1)  # by inches, inner margin
     , omi = c(0.1, 0.3, 0.4, 0.2)  # by inches, outer margin
     , mgp = c(0.5, 0.5, 0) # set distance of axis
     , tcl = 0.4
     , cex.axis = 1.0
     , mfrow=c(1, 2) )

for (i in 1:38) {
  
  # plot control
  xlim_low <- min(soilhealthData[,respcol[i]], na.rm = T)
  xlim_high <- max(soilhealthData[,respcol[i]], na.rm = T)
  bk <- ( xlim_high - xlim_low ) /20
  
  hist(soilhealthData[,respcol[i]], breaks = seq(xlim_low, xlim_high, bk)
       , col = "gray"
       , main = ""
       , xlab = ""
       , ylab = ""
       , xlim = c(xlim_low, xlim_high*1.1)
       , freq=FALSE )
  
  mtext(side = 2, text = expression("Frequency"), line = 2.0, cex=1.0, outer = F)
  
  mtext(side = 3, text = res_name[i], line = 0.5, cex=1.2, outer = F)
  
  box()
  
  # plot treatment
  xlim_low <- min(soilhealthData[,respcol2[i]], na.rm = T)
  xlim_high <- max(soilhealthData[,respcol2[i]], na.rm = T)
  bk <- ( xlim_high - xlim_low ) /20
  
  hist(soilhealthData[,respcol2[i]], breaks = seq(xlim_low, xlim_high, bk)
       , col = "gray"
       , main = ""
       , xlab = ""
       , ylab = ""
       , xlim = c(xlim_low, xlim_high*1.1)
       , freq=FALSE )
  
  mtext(side = 2, text = expression("Frequency"), line = 2.0, cex=1.0, outer = F)
  
  mtext(side = 3, text = res_name2[i], line = 0.5, cex=1.2, outer = F)
  
  box()
}

dev.off()



