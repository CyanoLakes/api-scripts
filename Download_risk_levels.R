# Example API query script 
# Download all risk levels and recommendations for all dams in subscription, saves to csv
# Author: CyanoLakes (Pty) Ltd

# Login credentials
username <- "username"
password <- "password"

# Specify working directory
wdir <- "/Directory/"

# Specify output file
file.stats <- "CyanoLakes_risk_levels.csv"

# Install and require needed packages (first run only)
#install.packages("httr")
#install.packages("jsonlite")
#require("httr")
#require("jsonlite")

# Function to query database
query <- function(call, username, password)
{
result <- GET(call, authenticate(username,password, type = "basic"))
result <- content(result, "text")
result <- fromJSON(result, flatten = TRUE)
return(result)
}

# Open libraries
library("jsonlite")
library("httr")

# Pre-assign data frame
Data <- data.frame(
ID=numeric(0), 
name=character(0), 
date=character(0), 
full_contact=character(0),
partial_contact=character(0),
cyanobacteria_risk_level=character(0),
cyanobacteria_cell_count=numeric(0),
tropic_status=character(0),
stringsAsFactors=F)

# API query options
base <- "https://online.cyanolakes.com/api/"
format <- "json"

# Query dams
damscall <- paste(base,"dams","?","format","=", format, sep="")
dams <- query(damscall, username, password )

# Convert to dataframe
dams <- as.data.frame(dams)

# Get names
damnames <- dams$name
i <- 1

# Loop through dams getting statistics for each
for(dam.n in dams$id) {
	print(paste("Downloading statistics for ", dam.n))

	# Get dates
	datescall <- paste(base,"dates/",dam.n,"?","format","=", format, sep="")
	dates <- query(datescall, username, password)
	
	# Get stats for each date
	for(date.n in dates) {
		# Get stats for date
		statscall <- paste(base,"summary-statistics/",dam.n,"/",date.n,"?","format","=", format, sep="")
		stats <- query(statscall, username, password)
		stats <- as.data.frame(stats, stringsAsFactors=FALSE)
		
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
		
		# Combine values
		values <- c(dam.n,damnames[i],date.n,stats$full_contact,
		stats$partial_contact,stats$cyanobacteria_risk_level,
		stats$cyanobacteria_cell_count,stats$tropic_status)
		#print(values)
		
		# Populate data frame (note order must be preserved)
		Data[nrow(Data)+1, ] <- values
		
		print(paste("Downloaded statistics for ", date.n))
	} 
	i <- i+1
	}

# Write dataframe to file
write.table(Data, file=paste0(wdir, file.stats), sep = ",", row.names=FALSE)
print(paste("Downloaded data. Written to csv file at ", wdir, file.stats))

