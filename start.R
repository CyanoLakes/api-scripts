# Specify library in user directory
r_lib_path <- "~/R/library"
if (!dir.exists(r_lib_path)) {
  dir.create(r_lib_path, recursive = TRUE)
}
.libPaths("~/R/library")

# Install curl and openssl dependencies
system("sudo apt-get install libcurl4-openssl-dev libssl-dev")

# Install packages
install.packages("httr")
install.packages("jsonlite")
