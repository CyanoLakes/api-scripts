# Example API query script
# Downloads all statistics for all dams in subscription, saves to csv
# Author: CyanoLakes (Pty) Ltd
.libPaths("~/R/library")
require("httr")
library("httr")
require("jsonlite")
library("jsonlite")
source("credentials.R")
source("utils.R")

# Specify name of output file
file.stats <- "all_stats.csv"

# Get dams
damscall <- paste(base, "dams", "?", "format", "=", format, sep = "")
dams <- query(damscall, username, password)

# Get names
damnames <- dams$name
i <- 1

# First call to get data structure
call1 <- paste(base, "dates/", dams$id[1], "/?format=", format, sep = "")
print(call1)
dates1 <- query(call1, username, password)
call2 <- paste(base, "statistics/", dams$id[1], "/", dates1[1], "/?format=", format, sep = "")
print(call2)
df <- query(call2, username, password)
df <- remove_duplicates(df)
df$name <- NA

#Loop through dams, date populating dataframe
j <- 1
for (id in dams$id) {
  dam_name <- damnames[i]
  print(paste("Downloading statistics for", dam_name))
  datescall <- paste(base, "dates/", id, "/?format=", format, sep = "")
  dates <- query(datescall, username, password)
  # using available dates above, find out stats for each date
  for (date in dates) {
    statscall <- paste(base, "statistics/", id, "/", date, "/?format=", format, sep = "")
    stats <- query(statscall, username, password)

    # Remove duplicates
    stats <- remove_duplicates(stats)

    # Add to dataframe
    df[j,] <- stats[1,]
    df[j, "name"] <- dam_name

    print(paste("Downloaded", date))
    j <- j + 1
  }
  i <- i + 1
}

# Unlist coordinates 
df$lat <- NA
df$lon <- NA
for (irow in 1:nrow(df)) { df$lat[irow] <- unlist(df$location.coordinates[irow])[2] }
for (irow in 1:nrow(df)) { df$lon[irow] <- unlist(df$location.coordinates[irow])[1] }
df$location.coordinates <- NULL
df$location.type <- NULL

# Write dataframe to file
write.table(df, file = paste0(wdir, file.stats), sep = ",", row.names = FALSE)
print(paste("Downloaded data. Written to csv file at ", wdir, file.stats))

