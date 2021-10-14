library(vroom)

# Download
download.file("https://www.ssa.gov/oact/babynames/state/namesbystate.zip", "namesbystate.zip")
unzip("namesbystate.zip", exdir = "namesbystate")

# Read
files <- dir("namesbystate", pattern = "*.TXT", full.names = TRUE)
dat <- vroom(files, col_names=c("state", "sex", "year", "name", "n"))

# Write
vroom_write(dat, "app/namesbystate.csv", delim = ",")
