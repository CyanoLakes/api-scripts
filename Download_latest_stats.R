# Example API query script 
# Downloads most recent statistics, risk levels and recommendations for all dams in subscription
# Author: CyanoLakes (Pty) Ltd

# Login credentials
username <- "username"
password <- "password"

# Specify working directory
wdir <- "/Directory/"

# Specify name of output file
file.stats <- "CyanoLakes_latest_stats.csv"

# Install and require needed packages (first run only)
#install.packages("httr")
#install.packages("jsonlite")
#require("httr")
#require("jsonlite")

# Function to query database
query <- function(call, username, password)
	{
	result <- GET(call, authenticate(username, password, type = "basic"))
	result <- content(result, "text")
	result <- fromJSON(result, flatten = TRUE)
	result <- as.data.frame(result, stringsAsFactors=FALSE)
	return(result)
	}

# Function to remove duplicate rows
remove_duplicates <- function(df)
	{
	if (nrow(df)>1){
	print("Warning! More than one entry for this date. Choosing smallest szenith value")
	if (df["szenith"][1,1]<df["szenith"][2,1]) {
		df <- df[1,]
		df$row.names <- NULL
		return(df)}
	else {
		df <- df[2,]
		df$row.names <- NULL
		return(df)}
	}
	else { 
		return(df)}
	}

# Open libraries
library("jsonlite")
library("httr")

# API query options
base <- "https://online.cyanolakes.com/api/"
format <- "json"

# First call to get risk levels for all dams
print("Downloading latest information")
latestcall <- paste(base,"user-dams-with-stats/latest/","?","format","=", format, sep="")
df1 <- query(latestcall, username, password)
 
# Unlist lat and lon data
df1$lat <- NA
df1$lon <- NA
if (nrow(df1)>1) {
	for(irow in 1:nrow(df1)) {
	df1$lat[irow] <- unlist(df1$geometry.coordinates[irow])[2]
	df1$lon[irow] <- unlist(df1$geometry.coordinates[irow])[1]
	}
} else {
df1$lat <- df1$geometry.coordinates[2]
df1$lon <- df1$geometry.coordinates[1]
}

# Make list null (not needed)
df1$geometry.coordinates <- NULL

# First call to get structure 
statscall <- paste(base,"statistics/",df1$id[1],"/",df1$statistic.last_updated_date[1],"?","format","=", format, sep="")
print(statscall)
df2 <- query(statscall, username, password)

#Loop through dams, adding additional stats to df2
j <- 1
View(df1)
for(irow in 1:nrow(df1)) {
	statscall <- paste(base,"statistics/",df1$id[irow],"/",df1$statistic.last_updated_date[irow],"?","format","=", format, sep="")
	stats <- query(statscall, username, password)
	
	# Remove duplicates if exist
	stats <- remove_duplicates(stats)
	
	# Append to dataframe
	df2[j, ] <- stats[1,]
	
	print(paste("Downloaded statistics for ", df1$name[irow]))
	j <- j+1
	}

# Make list null (not needed)
df2$location.coordinates <- NULL

# Merge dataframes by ID
colnames(df1)[colnames(df1)=="id"] <- "dam"
df <- merge(df1,df2,by="dam")

# Write dataframe to file
write.table(df, file=paste0(wdir, file.stats), sep = ",", row.names=FALSE)
print(paste("Downloaded data. Written to csv file at ", wdir, file.stats))
