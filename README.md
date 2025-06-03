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
4. On first use run start.R `Rscript start.R` to install required packages and set up the library
5. Specify your username and password in credentials.R
6. Run the scripts from the terminal using the Rscript command
7. Check that the data has been downloaded to your working directory

To view the a description of all data available through the API,
refer to `Data_Description.xlsx`. 

Refer to the `CyanoLakes_API_Guide.pdf` for more information. 
