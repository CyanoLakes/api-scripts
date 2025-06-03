# Function to query database
query <- function(call, username, password) {
  result <- GET(call, authenticate(username, password, type = "basic"), encode = "UTF-8")
  result <- content(result, "text", encoding = "UTF-8")
  result <- fromJSON(result, flatten = TRUE)
  return(result)
}

# Function to remove duplicate rows
remove_duplicates <- function(df) {
  if (nrow(df) > 1) {
    print("Warning! More than one entry for this date. Choosing smallest szenith value")
    if (df["szenith"][1, 1] < df["szenith"][2, 1]) {
      df <- df[1,]
      df$row.names <- NULL
      return(df)
    } else {
      df <- df[2,]
      df$row.names <- NULL
      return(df)
    }
  } else {
    return(df)
  }
}