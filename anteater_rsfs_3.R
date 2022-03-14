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

df <- fread(ind_file)
df$temp_d <- abs(df$temp_c - 22)
attr(df$timestamp, "tzone") <- "UTC"

pasture <- raster("/home/alston92/proj/anteaters/data/pasture.tif")
nf <- raster("/home/alston92/proj/anteaters/data/native_forest.tif")
pf <- raster("/home/alston92/proj/anteaters/data/planted_forest.tif")
stream <- raster("/home/alston92/proj/anteaters/data/dist2streams.tif")

print(paste0("Data loaded at ",Sys.time()))

# Create a telemetry object (for speeds()o command)
l <- as.telemetry(df, tz = "UTC", drop=FALSE, keep = "temp_d")

print(paste0("Telemetry object created at ",Sys.time()))

guess <- ctmm.guess(l[[1]], interactive=FALSE)
guess$error <- TRUE
fit <- ctmm.select(l[[1]], CTMM=guess)

print(paste0("CTMM fit at ",Sys.time()))
print(summary(fit))

# Calculate the UDs ###
ud <- akde(l[[1]], fit, weights=TRUE)
print("UD created")

sTime <- Sys.time()

# Fit the RSFs ###
rsf <- ctmm:::rsf.fit(l[[1]], UD=ud, R=list(pasture=pasture,nf=nf,pf=pf,stream=stream), formula=~pasture+nf+pf+stream+pasture:temp_d+nf:temp_d+pf:temp_d+stream:temp_d, debias=TRUE, error=0.08)
print("Fitted RSF")

eTime <- Sys.time()

# Extract variables of interest ###
aid <- df$individual.local.identifier[2]
pasture_est <- summary(rsf)$CI[1,2]
pasture_lcl <- summary(rsf)$CI[1,1]
pasture_ucl <- summary(rsf)$CI[1,3]
nf_est <- summary(rsf)$CI[2,2]
nf_lcl <- summary(rsf)$CI[2,1]
nf_ucl <- summary(rsf)$CI[2,3]
pf_est <- summary(rsf)$CI[3,2]
pf_lcl <- summary(rsf)$CI[3,1]
pf_ucl <- summary(rsf)$CI[3,3]
stream_est <- summary(rsf)$CI[4,2]
stream_lcl <- summary(rsf)$CI[4,1]
stream_ucl <- summary(rsf)$CI[4,3]
pasture_temp_est <- summary(rsf)$CI[5,2]
pasture_temp_lcl <- summary(rsf)$CI[5,1]
pasture_temp_ucl <- summary(rsf)$CI[5,3]
nf_temp_est <- summary(rsf)$CI[6,2]
nf_temp_lcl <- summary(rsf)$CI[6,1]
nf_temp_ucl <- summary(rsf)$CI[6,3]
pf_temp_est <- summary(rsf)$CI[7,2]
pf_temp_lcl <- summary(rsf)$CI[7,1]
pf_temp_ucl <- summary(rsf)$CI[7,3]
stream_temp_est <- summary(rsf)$CI[8,2]
stream_temp_lcl <- summary(rsf)$CI[8,1]
stream_temp_ucl <- summary(rsf)$CI[8,3]
area <- summary(rsf)$CI[9,2]
area_lcl <- summary(rsf)$CI[9,1]
area_ucl <- summary(rsf)$CI[9,3]
runtime <- difftime(eTime, sTime, units="mins")

print(paste0("RSF for animal ", ind_file," parameterized at ",Sys.time()))

# Vector of results to return
x <- data.frame(aid,pasture_est,pasture_lcl,pasture_ucl,nf_est,nf_lcl,nf_ucl,pf_est,pf_lcl,pf_ucl,stream_est,stream_lcl,stream_ucl,pasture_temp_est,pasture_temp_lcl,pasture_temp_ucl,nf_temp_est,nf_temp_lcl,nf_temp_ucl,pf_temp_est,pf_temp_lcl,pf_temp_ucl,stream_temp_est,stream_temp_lcl,stream_temp_ucl,area,area_lcl,area_ucl,runtime)

# Store results in data.frame
write.table(x, 'results/anteater_rsf_results_3.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')

