library(RCurl)

#August 2015:
taxi_data_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2015-08.csv", ssl.verifypeer = FALSE)
taxi_data <- read.csv(textConnection(taxi_data_URL))

#Taxi-Zone Data:
taxi_zone_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv", ssl.verifypeer = FALSE)
taxi_zone <- read.csv(textConnection(taxi_zone_URL))

##TRAINING:

#Jan 2018:
jan_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-01.csv", ssl.verifypeer = FALSE)
taxi_jan <- read.csv(textConnection(jan_URL))

#Feb 2018:
feb_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-02.csv", ssl.verifypeer = FALSE)
taxi_feb <- read.csv(textConnection(feb_URL))

#March 2018:
march_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-03.csv", ssl.verifypeer = FALSE)
taxi_march <- read.csv(textConnection(march_URL))

#April 2018:
april_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-04.csv", ssl.verifypeer = FALSE)
taxi_april <- read.csv(textConnection(april_URL))

#May 2018:
may_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-05.csv", ssl.verifypeer = FALSE)
taxi_may <- read.csv(textConnection(may_URL))

#June 2018:
june_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-06.csv", ssl.verifypeer = FALSE)
taxi_june <- read.csv(textConnection(june_URL))

##TESTING:

#January 2017:
taxi_test_URL <- getURL("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2017-01.csv", ssl.verifypeer = FALSE)
taxi_test <- read.csv(textConnection(taxi_test_URL))

