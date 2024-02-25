# Purpose: Using census API to pull data easily

library(tidyverse)
# install.packages("censusapi") # Install the census api package
library(censusapi)

# Loads in the census api key
census_api <- Sys.getenv("CENSUS_API_KEY")

# Provides list of avaliable APIs
meta_info <- listCensusApis()

# Gives the variable information for the ABS survey (for 2018 but variables carry over the years)
abs_var_2018 <- listCensusMetadata(name="abscs", vintage = 2018)


# Create empty table to append data in loop
all_abs <- tibble()
# Create loop that goes through each year of interest and pulls data, combining into single table

for (yr in 2017:2021){
  # Pulls the current year data
  current_abs <- getCensus(name="abscs", 
                           vars = c("GEOCOMP", "GEO_ID", "YEAR", "STATE", # Location info
                                    "ETH_GROUP", "RACE_GROUP", "NAICS2017", "SECTOR", "EMP", "EMP_S", # Business characteristics
                                    "PAYANN", "PAYANN_S", "RCPPDEMP", "RCPPDEMP_S", "FIRMPDEMP", "FIRMPDEMP_S"), # Profit info
                           region = "state:*",
                           vintage = yr, 
                           key = census_api)
  # Appends to full table
  all_abs <- bind_rows(all_abs, current_abs)
  
  
}
abs_2017 <- getCensus(name="abscs", 
                      vars = c("GEOCOMP", "GEO_ID", "YEAR", "STATE", # Location info
                               "ETH_GROUP", "ETH_GROUP_LABEL", "RACE_GROUP", "RACE_GROUP_LABEL", "NAICS2017", "NAICS2017_LABEL", "EMP", "EMP_S", # Business characteristics
                               "PAYANN", "PAYANN_S", "RCPPDEMP", "RCPPDEMP_S", "FIRMPDEMP", "FIRMPDEMP_S"), # Profit info
                      region = "state:*",
                      vintage = 2017, 
                      key = census_api)


getCensus(vars = c("ETH_GROUP", "ETH_GROUP_TTL"), key=census_api)

