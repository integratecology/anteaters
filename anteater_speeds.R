# PACKAGES ####
library(ctmm)
library(data.table)

# DATA ####
# Load data set #
# Sys.setenv(TZ='UTC')
setwd("/home/alston92/proj/anteaters")

ind_file <- commandArgs(trailingOnly=TRUE)
print(ind_file)

df <- fread(ind_file)
attr(df$timestamp, "tzone") <- "UTC"

aid <- df$individual.local.identifier[2]

print(paste0("Data loaded at ",Sys.time()))

# Create a telemetry object (for speeds() command)
l <- as.telemetry(df, tz = "UTC", drop=FALSE)
assign(paste0("t_",aid), l)
l_name <- paste0("t_",aid)

print(paste0("Telemetry object created at ",Sys.time()))

guess <- ctmm.guess(l[[1]], interactive=FALSE)
guess$error <- TRUE
fit <- ctmm.select(l[[1]], CTMM=guess)
assign(paste0("ctmm_",aid), fit)
ctmm_name <- paste0("ctmm_",aid)
save(fit, l, list = c(ctmm_name,l_name), file=paste0("/home/alston92/proj/anteaters/ctmms/",aid,".Rda"))

print(paste0("CTMM fit at ",Sys.time()))
print(summary(fit))

speeds <- speeds(l[[1]], CTMM=fit, fast=FALSE, error=0.01)

df$speed_est <- speeds$est
df$speed_lcl <- speeds$low
df$speed_ucl <- speeds$high
aid <- df$individual.local.identifier[2]

print(paste0("Speed of animal ", ind_file," estimated at ",Sys.time()))

write.csv(df, paste0("/home/alston92/proj/anteaters/results/",aid,"_speeds.csv"))

