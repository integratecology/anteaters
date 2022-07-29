# PACKAGES ####
library(ctmm)
library(data.table)
library(raster)

# DATA ####
# Load data #
# Sys.setenv(TZ='UTC')
setwd("/home/alston92/proj/anteaters")

ind_file <- commandArgs(trailingOnly=TRUE)
print(ind_file)

load(ind_file)

nf <- raster("/home/alston92/proj/anteaters/data/native_forest.tif")
pf <- raster("/home/alston92/proj/anteaters/data/planted_forest.tif")
stream <- raster("/home/alston92/proj/anteaters/data/dist2streams.tif")

print(paste0("Data loaded at ",Sys.time()))

# Standardize temperature
l <- l[!is.na(l$temp_c),]
l$temp_cs <- (l$temp_c - mean(l$temp_c))/sd(l$temp_c)

aid <- l@info$identity[1]
print(aid)

print(paste0("Telemetry object created at ",Sys.time()))

# Fit the RSFs ###
rsf <- ctmm:::rsf.fit(l, UD=ud, R=list(nf=nf,pf=pf,stream=stream), formula=~nf+pf+stream+temp_cs:nf+temp_cs:pf+temp_cs:stream, debias=TRUE, error=0.01, integrator="MonteCarlo") 
print("Fitted RSF")
print(summary(rsf))

assign(paste0("rsf_",aid), rsf)
rsf_name <- paste0("rsf_",aid)
print(rsf_name)
save(rsf, list=rsf_name, file=paste0("/home/alston92/proj/anteaters/rsfs/",aid,"_rsf.Rda"))

eTime <- Sys.time()

# Extract variables of interest ###
nf_est <- summary(rsf)$CI[6,2]
nf_lcl <- summary(rsf)$CI[6,1]
nf_ucl <- summary(rsf)$CI[6,3]
pf_est <- summary(rsf)$CI[5,2]
pf_lcl <- summary(rsf)$CI[5,1]
pf_ucl <- summary(rsf)$CI[5,3]
stream_est <- summary(rsf)$CI[4,2]
stream_lcl <- summary(rsf)$CI[4,1]
stream_ucl <- summary(rsf)$CI[4,3]
nf_temp_est <- summary(rsf)$CI[3,2]
nf_temp_lcl <- summary(rsf)$CI[3,1]
nf_temp_ucl <- summary(rsf)$CI[3,3]
pf_temp_est <- summary(rsf)$CI[2,2]
pf_temp_lcl <- summary(rsf)$CI[2,1]
pf_temp_ucl <- summary(rsf)$CI[2,3]
stream_temp_est <- summary(rsf)$CI[1,2]
stream_temp_lcl <- summary(rsf)$CI[1,1]
stream_temp_ucl <- summary(rsf)$CI[1,3]

print(paste0("RSF for animal ", ind_file," parameterized at ",Sys.time()))

# Vector of results to return
x <- data.frame(aid,nf_est,nf_lcl,nf_ucl,pf_est,pf_lcl,pf_ucl,stream_est,stream_lcl,stream_ucl,nf_temp_est,nf_temp_lcl,nf_temp_ucl,pf_temp_est,pf_temp_lcl,pf_temp_ucl,stream_temp_est,stream_temp_lcl,stream_temp_ucl)

# Store results in data.frame
write.table(x, 'results/anteater_rsf_results_final2.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')

print("Done!")
