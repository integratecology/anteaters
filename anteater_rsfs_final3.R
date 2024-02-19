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

print(paste0("Data loaded at ",Sys.time()))

# Standardize temperature
l <- l[!is.na(l$temp_c),]
l$temp_cs <- (l$temp_c - mean(l$temp_c))/sd(l$temp_c)

aid <- l@info$identity[1]
print(aid)

print(paste0("Telemetry object created at ",Sys.time()))

# Fit the RSFs ###
rsf <- ctmm:::rsf.fit(l, UD=ud, R=list(nf=nf,pf=pf), formula=~nf+pf+temp_cs:nf+temp_cs:pf, debias=TRUE, error=0.01, integrator="MonteCarlo") 
print("Fitted RSF")
print(summary(rsf))

assign(paste0("rsf_",aid), rsf)
rsf_name <- paste0("rsf_",aid)
print(rsf_name)
save(rsf, list=rsf_name, file=paste0("/home/alston92/proj/anteaters/rsfs_final/",aid,"_rsf.Rda"))

eTime <- Sys.time()

# Extract variables of interest ###
nf_est <- summary(rsf)$CI[4,2]
nf_lcl <- summary(rsf)$CI[4,1]
nf_ucl <- summary(rsf)$CI[4,3]
pf_est <- summary(rsf)$CI[3,2]
pf_lcl <- summary(rsf)$CI[3,1]
pf_ucl <- summary(rsf)$CI[3,3]
nf_temp_est <- summary(rsf)$CI[2,2]
nf_temp_lcl <- summary(rsf)$CI[2,1]
nf_temp_ucl <- summary(rsf)$CI[2,3]
pf_temp_est <- summary(rsf)$CI[1,2]
pf_temp_lcl <- summary(rsf)$CI[1,1]
pf_temp_ucl <- summary(rsf)$CI[1,3]

print(paste0("RSF for animal ", ind_file," parameterized at ",Sys.time()))

# Vector of results to return
x <- data.frame(aid,nf_est,nf_lcl,nf_ucl,pf_est,pf_lcl,pf_ucl,nf_temp_est,nf_temp_lcl,nf_temp_ucl,pf_temp_est,pf_temp_lcl,pf_temp_ucl)

# Store results in data.frame
write.table(x, 'results/anteater_rsf_results_final3.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')

print("Done!")
