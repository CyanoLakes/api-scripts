.libPaths("~/R/library")
require("httr")
require("jsonlite")
# Example API query script
# Downloads all chl-a data for all dams in subscription, saves to csv
# Author: CyanoLakes (Pty) Ltd

# API query options
base <- "https://online.cyanolakes.com/api/"
format <- "json"

# matchup settings
depth <- "0"  # default depth setting for all stations
startDate <- "2022-01-01"  # start date to get matchups
endDate <- "2025-06-01"  # end date to get matchups
timeDelta <- "0"  # time difference between satellite and in situ data

# import credentials file with username, password and wdir
source("credentials.R")

# Get utility functions
source("utils.R")

# Specify output file
file.stats <- paste0("Matchups_",depth,"_",timeDelta,".csv")

# Open libraries
library("jsonlite")
library("httr")

# Initialize an empty list to store data
all_matchups <- data.frame()

# 1. Get dams with stations
# Query dams
damscall <- paste0(base, "dams-with-stations/?format=json")
dams <- query(damscall, username, password )

# Convert to dataframe
dams <- as.data.frame(dams)

# Get names
damnames <- dams$name

for(dam.n in dams$id) {
  i <- 1 # Reset i here
  print(paste("Getting matchups for ", dams$name[dams$id == dam.n]))

  # 2. Get stations for this dam
  stationscall <- paste0(base, "user-stations-with-stats/", dam.n, "/?format=json")
  stations <- query(stationscall, username, password)

  # 3. Get matchups for each station
  for(station.n in stations$id) {
     print(paste("Downloading station: ", stations$name[stations$id == station.n]))

    # 3. Get matchups for this station
    matchupscall <- paste0(base, "matchups/", station.n, "/",depth, "/?format=json",
                          "&startdate=", startDate, "&enddate=", endDate, "&days=", timeDelta)
    matchups <- query(matchupscall, username, password)
    matchups <- as.data.frame(matchups)

    # Save to dataframe (all stations)
    all_matchups <- rbind(all_matchups, matchups)
  }
}

# Write dataframe to file
write.table(all_matchups, file=paste0(wdir, file.stats), sep = ",", row.names=FALSE)
print(paste("Downloaded data. Written to csv file at ", wdir, file.stats))
