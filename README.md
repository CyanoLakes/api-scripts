# R scripts for the CyanoLakes API

The API provides access to the data so that it can be downloaded 
for analysis, or integrated into your database or app. 

The API 
reference documentation can be found here: 

https://online.cyanolakes.com/docs/

The API provides data in two formats: HTML and JSON. 

Navigating 
to the API web address will yield the HTML format. The JSON 
format is obtained by appending `?format=json` to a query.

Examples:

Return dates for a dam ID in json format:
https://online.cyanolakes.com/api/dates/dam_id/?format=json

Return statistics using a dam_id and date in html format:
https://online.cyanolakes.com/api/statistics/dam_id/date/

How to download data:
1. Download the R scripts from Github
2. Copy the R scripts to a folder on your computer
3. Download and install R on your computer from https://www.r-project.org
4. Edit the R scripts by specifying your username, password, the directory and the file
name where you would like to save the data
5. Once installed, run the scripts in R
6. Check that the data has been downloaded to the file specified in your script

To view the a description of all data available through the API,
refer to `Data_Description.xlsx`. 

Refer to the `CyanoLakes_API_Guide.pdf` for more information. 
