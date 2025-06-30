.libPaths("~/R/library")
require("httr")
require("jsonlite")
# Example API query script
# Downloads all chl-a data for all dams in subscription, saves to csv 
# Author: CyanoLakes (Pty) Ltd

# Optionally specify one or more dams in this list
selectedDams <- c()

# API query options
base <- "https://online.cyanolakes.com/api/"
format <- "json"

# import credentials file with username, password and wdir
source("credentials.R")

# Get utility functions
source("utils.R")

# Specify output file
file.stats <- "CyanoLakes_chl_stats.csv"

# Open libraries
library("jsonlite")
library("httr")

# Pre-assign data frame
Data <- data.frame(
	ID=numeric(0),
	name=character(0),
	date=character(0),
	time=character(0),
	chla_med=numeric(0),
	chla_mean=numeric(0),
	chla_max=numeric(0),
	chla_min=numeric(0),
	chla_std=numeric(0),
	turbidity_med=numeric(0),
	turbidity_min=numeric(0),
	turbidity_max=numeric(0),
	acdom_med=numeric(0),
	acdom_min=numeric(0),
	acdom_max=numeric(0),
	stringsAsFactors=F
)

# Query dams
damscall <- paste(base,"dams","?","format","=", format, sep="")
dams <- query(damscall, username, password )

# Convert to dataframe
dams <- as.data.frame(dams)

# Filter by selected Dam
if (length(selectedDams) > 0 ) {
	 dams <- dams[dams$name %in% selectedDams, ]
}

# Get names
damnames <- dams$name
i <- 1

#Loop through dams getting statistics for each
for(dam.n in dams$id) {
	print(paste("Downloading statistics for ", dam.n))

	# Get dates
	datescall <- paste(base,"dates/",dam.n,"?","format","=", format, sep="")
	dates <- query(datescall, username, password)

	# For debugging
	# j <- 1

	# using available dates above, find out stats for each date
	for(date.n in dates) {
		# Get stats for date
		statscall <- paste(base,"statistics/",dam.n,"/",date.n,"?","format","=", format, sep="")
		# print(statscall)
		stats <- query(statscall, username, password)
		stats <- as.data.frame(stats)
		
		# If more than one row, choose row with smallest szenith value
		if (nrow(stats)>1) {
			print("Warning! More than one entry for this date. Choosing smallest szenith value")
			if (stats["szenith"][1,1]<stats["szenith"][2,1]) {
				stats <- stats[1,] 
				}
				else {
					stats <- stats[2,]
				}
		}

		## Populate data frame (note order must be preserved)
		Data[nrow(Data)+1, ] <- data.frame(
			 t(c(
				 dam.n,
				damnames[i],
				stats$date,
				stats$time,
				stats$chla_merged.median,
				stats$chla_merged.mean,
				stats$chla_merged.q3,  # max
				stats$chla_merged.q1,  # min
				stats$chla_merged.std,
				stats$attenuation,
				stats$attenuation_low,
				stats$attenuation_high,
				stats$acdom,
				stats$acdom_low,
				stats$acdom_high
			 )),
			 stringsAsFactors = FALSE
		)

		print(paste("Downloaded statistics for ", date.n))
		# For debugging
		# if (j == 5 || j == 10) {
		#   break
		# }
		# j <- j+1
	}
	i <- i+1
	}

# Write dataframe to file
write.table(Data, file=paste0(wdir, file.stats), sep = ",", row.names=FALSE)
print(paste("Downloaded data. Written to csv file at ", wdir, file.stats))
