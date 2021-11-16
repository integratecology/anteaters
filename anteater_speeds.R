# PACKAGES ####
library(ctmm)
library(data.table)

# DATA ####
# Load data set #
# Sys.setenv(TZ='UTC')
setwd("/bigdata/casus/movement/anteaters")

ind_file <- commandArgs(trailingOnly=TRUE)
print(ind_file)

df <- fread(ind_file)
attr(df$timestamp, "tzone") <- "UTC"

print(paste0("Data loaded at ",Sys.time()))

# Create a telemetry object (for speeds() command)
l <- as.telemetry(df, tz = "UTC", drop=FALSE)

print(paste0("Telemetry object created at ",Sys.time()))

guess <- ctmm.guess(l[[1]], interactive=FALSE)
guess$error <- TRUE
fit <- ctmm.select(l[[1]], CTMM=guess)

print(paste0("CTMM fit at ",Sys.time()))
print(summary(fit))

speeds <- speeds(l[[1]], fit)

df$speed <- speeds$ML
df$speed_lcl <- speeds$low
df$speed_ucl <- speeds$high

print(paste0("Speed of animal ", spp_file," estimated at ",Sys.time()))

write.table(df, './results/anteater_speeds.csv', append = TRUE, 
                row.names = FALSE, col.names = FALSE, sep = ',')
