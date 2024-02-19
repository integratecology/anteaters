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
attr(df$timestamp, "tzone") <- "UTC"
df <- df[!is.na(df$temp_c),]

aid <- df$individual.local.identifier[2]

nf <- raster("/home/alston92/proj/anteaters/data/native_forest.tif")
pf <- raster("/home/alston92/proj/anteaters/data/planted_forest.tif")
stream <- raster("/home/alston92/proj/anteaters/data/dist2streams.tif")

print(paste0("Data loaded at ",Sys.time()))

# Create a telemetry object 
l <- as.telemetry(df, tz = "UTC", keep = "temp_c")
l$temp_cs <- (l$temp_c - mean(l$temp_c))/sd(l$temp_c)

print(paste0("Telemetry object created at ",Sys.time()))

assign(paste0("t_",aid), l)
l_name <- paste0("t_",aid)

fits <- list.files("/home/alston92/proj/anteaters/fits", full.names=TRUE)
wanted_fit <- grep(aid, fits)
wanted_file <- fits[wanted_fit]
load(wanted_file)
fit <- FIT

print(paste0("CTMM fit at ",Sys.time()))
print(summary(fit))

assign(paste0("ctmm_",aid), fit)
ctmm_name <- paste0("ctmm_",aid)

# Calculate the UDs ###
ud <- akde(l, fit, weights=TRUE, dt=300)
print("UD created")
print(summary(ud))

assign(paste0("ud_",aid), fit)
ud_name <- paste0("ud_",aid)

save(fit, l, ud, list = c(ctmm_name,l_name,ud_name), file=paste0("/home/alston92/proj/anteaters/ctmms/",aid,".Rda"))

# Fit the RSFs ###
rsf <- ctmm:::rsf.fit(l, UD=ud, R=list(nf=nf,pf=pf), formula=~nf+pf+temp_cs:nf+temp_cs:pf, debias=TRUE, error=0.01, integrator="MonteCarlo",smooth=FALSE)
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
write.table(x, 'results/anteater_rsf_results_final4.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')

print("Done!")

