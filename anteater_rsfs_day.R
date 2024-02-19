# PACKAGES ####
library(data.table)
library(raster)
library(ctmm, lib.loc="/home/alston92/R/x86_64-pc-linux-gnu-library/4.3")
library(profmem)

# DATA ####
# Load data #
# Sys.setenv(TZ='UTC')
setwd("/home/alston92/proj/anteaters")

ind_file <- commandArgs(trailingOnly=TRUE)
print(ind_file)

df <- fread(ind_file)
attr(df$timestamp, "tzone") <- "UTC"

# Standardize temperature
df <- df[!is.na(df$temp_c),]
df$temp_cs <- (df$temp_c - mean(df$temp_c))/sd(df$temp_c)

nf <- raster("/home/alston92/proj/anteaters/data/native_forest.tif")
pf <- raster("/home/alston92/proj/anteaters/data/planted_forest.tif")

print(paste0("Data loaded at ",Sys.time()))

# Create a telemetry object
l <- as.telemetry(df, tz = "UTC", drop=TRUE, keep = "temp_cs")

# Subset to daytime locations
l <- annotate(l, by="sun")
l <- l[l$sunlight > 0,]

aid <- l@info$identity[1]
print(aid)

assign(paste0("t_",aid), l)
l_name <- paste0("t_",aid)

print(paste0("Telemetry object created at ",Sys.time()))

# Fit ctmm
guess <- ctmm.guess(l, interactive=FALSE)
guess$error <- TRUE
fit <- ctmm.select(l, CTMM=guess)

assign(paste0("ctmm_",aid), fit)
ctmm_name <- paste0("ctmm_",aid)

print(paste0("CTMM fit at ",Sys.time()))
print(summary(fit))

# Calculate the UDs ###
ud <- akde(l, fit, weights=TRUE)
print("UD created")

assign(paste0("ud_",aid), fit)
ud_name <- paste0("ud_",aid)

save(fit, l, ud, list = c(ctmm_name,l_name,ud_name), file=paste0("/home/alston92/proj/anteaters/ctmms/day/",aid,".Rda"))

sTime <- Sys.time()

# Fit the RSFs ###
profmem(rsf <- ctmm:::rsf.select(l, UD=ud, R=list(nf=nf,pf=pf), formula=~nf+pf+temp_cs:nf+temp_cs:pf, debias=TRUE, error=0.01, max.mem="32 Gb", integrator="MonteCarlo"))
print("Fitted RSF")
print(summary(rsf))

assign(paste0("rsf_",aid), rsf)
rsf_name <- paste0("rsf_",aid)
print(rsf_name)
save(rsf, list=rsf_name, file=paste0("/home/alston92/proj/anteaters/rsfs_day/",aid,"_rsf_day.Rda"))

eTime <- Sys.time()

print(paste0("RSF for animal ", ind_file," parameterized at ",Sys.time()))

print("Done!")
