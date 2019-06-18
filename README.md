# nyc-taxi-weather-data

Our goal was to determine the effects of weather and time on taxi ridership, as well as the ways in which taxi drivers can use specific trip-related information available to them to maximize their monetary profits. 

The final dataset used to construct our model merges data from two online sources: NYC Taxi & Limousine Commission and National Climatic Data Center.   

As of now, data originating from the NYC Taxi & Limousine Commission (TLC) provides historical data on taxi services from January 2009 to June 2018. This data encompasses both yellow taxi and green taxi trip records; however, owing to the huge size of the dataset, for our purposes, trip records only involving yellow taxis were utilized. Under 'data', one can navigate to Taxi Data.R. Running this script will extract the appropriate datasets that were used from the following URL: https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page. 

As of now, data originating from the National Climatic Data Center (NCDC) provides historical data on weather and climate in the United States for the last 30 years. This data provides a comprehensive selection of variables pertinent to weather -- including, but not limited to, daily maximum/minimum temperature, snowfall, and precipitation level. Under 'data', one can navigate to two CSV files: weather.csv and weather_test.csv. Training data was randomly sampled from weather.csv, and testing data was randomly sampled from weather_test.csv. 

For the main analyses of the study, the data for yellow taxi rides and weather for the Central Park station was merged, by date, to create a dataset with each row representing one unique taxi ride. There are a substantial amount of variables contained in the original dataset, several of which were utilized either directly or indirectly. Indirect use comprised of extracting specific features from existing variables and using those features to create additional variables. For example, from the original TLC variables ‘pickup time/date’ and ‘drop-off time/date’, features such as ‘ride duration’, ‘hour of the day’, and ‘day of the week’ were created to provide more valuable, relevant information.

As our overall goal was to determine how to maximize taxi drivers’ profits based on the data available to them, we decided to focus on which aspects of weather increased the demand of yellow taxis in New York City. However, as an added criterion, we decided to predict which trips were most likely to yield a tip of twenty percent or more, as the additional revenue from tips can prove to be very lucrative.

First of all, we decided to examine the relationship between the number of taxis hired daily and the accompanying weather conditions. We utilized a linear model, where the number of daily taxis was our response variable and daily ‘minimum temperature’, ‘maximum temperature’, ‘amount of snowfall’, and ‘snow depth’ were our predictors. The code for this analysis can be found in 'analysis'. 

Thereafter, for predicting which trips would result in a tip for the driver, we used a Naive Bayes model with a binary variable for whether a tip of twenty percent or more was given as the response variable and ‘trip distance’, ‘rate code’, ‘pick-up location’, ‘pick-up hour’, ‘day’, and ‘month’ as our predictors. All of our predictors represented information that would be readily available to the taxi driver before the start of the trip. The code for this analysis can be found in 'analysis'. 

For a complete explanation of the method, analysis, and results, one can navigate to 'report.pdf'. 

