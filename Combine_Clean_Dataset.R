########################################################################################
# Script Purpose: Create pipeline for bringing in census data and cleaning for our use #
########################################################################################

# Load necessary packages
library(tidyverse)
library(censusapi) # Install if necessary
library(readr)

# Loads in the census api key
census_api <- Sys.getenv("CENSUS_API_KEY")


#################################################
#### Step 1: Use Census APIs to pull in data ####
#################################################


###########################################################
# DONT NEED TO RUN THIS PART UNLESS CHANGING TABLE CONTENT

# Provides list of avaliable APIs
# meta_info <- listCensusApis()

# Gives the variable information for the ABS survey (for 2018 but variables carry over the years)
#abs_var_2018 <- listCensusMetadata(name="abscs", vintage = 2018)

# DONT NEED TO RUN THIS PART UNLESS CHANGING TABLE CONTENT
###########################################################

# Create empty table to append data in loop
all_abs <- tibble()

# Loops through each year of interest and pulls data, combining into single table (FYI this takes a while to run)
for (yr in 2017:2021){
  # Pulls the current year data
  current_abs <- getCensus(name="abscs", 
                           vars = c("GEOCOMP", "GEO_ID", "YEAR", "STATE", # Location info
                                    "ETH_GROUP", "ETH_GROUP_LABEL", "RACE_GROUP", "RACE_GROUP_LABEL", "NAICS2017", "NAICS2017_LABEL", "EMP", "EMP_S", # Business characteristics
                                    "PAYANN", "PAYANN_S", "RCPPDEMP", "RCPPDEMP_S", "RCPSZFI", "FIRMPDEMP", "FIRMPDEMP_S"), # Profit info
                           region = "state:*",
                           vintage = yr, 
                           key = census_api)
  # Appends to full table
  all_abs <- bind_rows(all_abs, current_abs)
}


####################################################
#### Step 2: Clean data for greater readability ####
####################################################


# Remove unnecessary column
all_abs <- all_abs %>% select(-STATE)

# Gives each column a name that matches meaning [all estimates end with "_Est"; all standard error measures end with "_StdErr"]
colnames(all_abs) <- c("State", # state
                       "Geo_ID_Component", # GEOCOMP
                       "Geo_ID_Code", # GEO_ID
                       "Year", # YEAR
                       "Ethnicity_Code", # ETH_GROUP
                       "Ethnicity_Label", # ETH_GROUP_LABEL
                       "Race_Code", # RACE_GROUP
                       "Race_Label", # RACE_GROUP_LABEL
                       "Industry_NAICS_Code", # NAICS2017
                       "Industry_NAICS_Label", # NAICS2017_LABEL
                       "Num_Employee_Est", # EMP
                       "Num_Employee_StdErr", # EMP_S
                       "Ann_Payroll_$1k_Est", # PAYANN
                       "Ann_Payroll_$1k_StdErr", # PAYANN_S
                       "Revenue_$1k_Est", # RCPPDEMP
                       "Revenue_$1k_StdErr", # RCPPDEMP_S
                       "Revenue_$1k_Code", # RCPSZFI
                       "Num_Firms_Est", # FIRMPDEMP
                       "Num_Firm_StdErr" # FIRMPDEMP_S
                       )

# Recode variables as needed to change number to description
# Mapping for states
state_codes <- c("01" = "Alabama", "02" = "Alaska", "04" = "Arizona", "05" = "Arkansas", "06" = "California", "08" = "Colorado",
                 "09" = "Connecticut", "10" = "Delaware", "11" = "District of Columbia", "12" = "Florida", "13" = "Georgia",
                 "15" = "Hawaii", "16" = "Idaho", "17" = "Illinois", "18" = "Indiana", "19" = "Iowa", "20" = "Kansas",
                 "21" = "Kentucky", "22" = "Louisiana", "23" = "Maine", "24" = "Maryland", "25" = "Massachusetts", "26" = "Michigan",
                 "27" = "Minnesota", "28" = "Mississippi", "29" = "Missouri", "30" = "Montana", "31" = "Nebraska", "32" = "Nevada",
                 "33" = "New Hampshire", "34" = "New Jersey", "35" = "New Mexico", "36" = "New York", "37" = "North Carolina",
                 "38" = "North Dakota", "39" = "Ohio", "40" = "Oklahoma", "41" = "Oregon", "42" = "Pennsylvania", "44" = "Rhode Island",
                 "45" = "South Carolina", "46" = "South Dakota", "47" = "Tennessee", "48" = "Texas", "49" = "Utah", "50" = "Vermont",
                 "51" = "Virginia", "53" = "Washington", "54" = "West Virginia", "55" = "Wisconsin", "56" = "Wyoming", "72" = "Puerto Rico")

# Apply the mapping to our combined table
all_abs$State_Name <- state_codes[as.character(all_abs$State)]

# Reorder the State_Name column so it is next to the codes
all_abs <- all_abs %>% select(State, State_Name, everything())


####################################
#### Step 3: Output as CSV file ####
####################################

# Output our cleaned table as a csv file into R environment
write_csv(all_abs, "abs_2017-2021_data_clean.csv")

