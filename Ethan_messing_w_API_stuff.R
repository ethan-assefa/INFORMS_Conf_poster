<<<<<<< HEAD
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





#################################################################################
# For Chat gpt prompt can feed dataset

# Function to print first n rows of a dataframe as CSV text
print_first_n_rows_csv <- function(df, n = 3) {
  # Subset the first n rows
  df_subset <- head(df, n)
  
  # Write the dataframe to a temporary CSV file
  temp_file <- tempfile(fileext = ".csv")
  write.csv(df_subset, file = temp_file, row.names = FALSE)
  
  # Read the CSV file as text
  csv_text <- readLines(temp_file)
  
  # Print the CSV text
  writeLines(csv_text)
  
  # Delete the temporary file
  unlink(temp_file)
}




# Call the function to print the first 3 rows of my_data as CSV text
print_first_n_rows_csv(abs_ts, n = 3)






# Avg revenue all together
ggplot(data = abs_natl, aes(x = Year, y = Avg_Rev_1k_Est)) +
  geom_line(aes(color = RaceEthn)) +
  geom_point() +
  scale_y_continuous(labels = label_custom) +
  labs(x = 'Year', y = "Avg. Annual Revenue") +
  scale_color_manual(values = c("White, NH" = "#788FF5", 
                                "Hispanic, any race"="#107C97",
                                "AIAN, NH"="#F2BF27",
                                "Black/AA, NH"="#E63000",
                                "Asian, NH"="#77C956",
                                "NHOPI, NH"="#BC22C0")) +
  theme_bw()


# Prepare dataset to be used as a times series
abs_ts <- abs_compare_natl %>% 
  select(Year, RaceEthn.O, Avg_Rev_1k_Diff)

# Get unique race/ethnicity groups
#race_groups <- unique(abs_ts$RaceEthn.O)

# Subset data for the current race/ethnicity group
blk_data <- subset(abs_ts, RaceEthn.O == "Black/AA, NH")

# Convert subsetted data to time series
ts_race_data <- ts(blk_data$Avg_Rev_1k_Diff, start = c(2017), frequency = 1)

# Forecast the next 5 years using ARIMA
forecast_result <- forecast(auto.arima(ts_race_data, approximation=FALSE, stepwise=FALSE), h = 5)

# Extract forecasted values
forecast_values <- forecast_result$mean

# Create an empty dataframe to store forecasts
forecast_df <- data.frame()

# Loop through each race/ethnicity group
for (race in race_groups) {
  # Subset data for the current race/ethnicity group
  race_data <- subset(abs_ts, RaceEthn.O == race)
  
  # Convert subsetted data to time series
  ts_race_data <- ts(race_data$Avg_Rev_1k_Diff, start = c(2017), frequency = 1)
  
  # Forecast the next 5 years using ARIMA
  forecast_result <- forecast(auto.arima(ts_race_data), h = 5)
  
  # Extract forecasted values
  forecast_values <- forecast_result$mean
  
  # Create a dataframe with Year and Forecast columns
  forecast_df_race <- data.frame(
    Year = (2018:2022),
    RaceEthn.O = race,
    Avg_Rev_1k_Diff_Forecast = forecast_values
  )
  
  # Bind the current race's forecast to the main forecast dataframe
  forecast_df <- rbind(forecast_df, forecast_df_race)
}

# Print the final forecast dataframe
print(forecast_df)


# Loop through each race/ethnicity group
for (race in race_groups) {
  # Subset data for the current race/ethnicity group
  race_data <- subset(abs_ts, RaceEthn.O == race)
  
  # Convert subsetted data to time series
  ts_race_data <- ts(race_data$Avg_Rev_1k_Diff, start = c(2017), frequency = 1)
  
  # Forecast the next 5 years using ARIMA
  forecast_result <- forecast(auto.arima(ts_race_data), h = 5)
  
  # Extract forecasted values
  forecast_values <- forecast_result$mean
  
  # Create a time series object for the forecast
  ts_forecast <- ts(forecast_values, start = c(2018), frequency = 1)
  
  # Bind the current race's forecast to the main forecast dataframe
  forecast_df_race <- data.frame(
    Year = (2018:2022),
    RaceEthn.O = rep(race, 5),
    Avg_Rev_1k_Diff_Forecast = as.numeric(ts_forecast)
  )
  
  # Bind the current race's forecast to the main forecast dataframe
  forecast_df <- rbind(forecast_df, forecast_df_race)
}
=======
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

>>>>>>> 6ce220ca4aa3a8b30cdb5086e6cf862664fca436
