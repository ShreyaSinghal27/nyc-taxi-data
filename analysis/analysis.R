taxi_data <- read.csv("yellow_tripdata_2015-08.csv")
library(lubridate)
library(dplyr)
library(ggmap)
library(leaflet)

#Select half of taxi_data as new data
n.total <- nrow(taxi_data)
n.train <- floor(0.5 * nrow(taxi_data))
sample <- sample.int(n.total, n.train, replace=FALSE)
data <- taxi_data [sample, ]

#Separate pick up date and time from the taxi data pick up date time column
data$Pick_up_Date <- as.Date(data$tpep_pickup_datetime)
data$Pick_up_Time <- format(as.POSIXct(data$tpep_pickup_datetime),format = "%H:%M:%S")

#Separate drop off date and time from the taxi data drop up date time column
data$Drop_off_Date <- as.Date(data$tpep_dropoff_datetime)
data$Drop_off_Time <- format(as.POSIXct(data$tpep_dropoff_datetime),format = "%H:%M:%S")

#Remove data where the difference between pick up dates and drop off dates is greater than 1
data$Diff_date <- data$Drop_off_Date - data$Pick_up_Date
data <- data %>% filter(Diff_date <= 1)

#Remove trips where trip distance is less than or equal to 0 and greater than 50 miles
data <- data %>% filter(trip_distance > 0)
data <- data %>% filter(trip_distance < 50)

#Adding weekdays to the data
data$Day <- weekdays(as.Date(data$Pick_up_Date))

#Calculate trip duration (in seconds)
data$Trip_duration <- ymd_hms(data$tpep_dropoff_datetime) - ymd_hms(data$tpep_pickup_datetime)
data <- data %>% filter(!Trip_duration <= 0)

#Delete the rows where latitude/ longitude = 0
data <- data %>% filter (!pickup_longitude == 0) %>% filter(!pickup_latitude == 0) %>% filter(!dropoff_latitude == 0) %>% filter(!dropoff_longitude == 0)

# Delete rows where number of passengers is 0 or greater than 4
data <- data %>% filter(passenger_count > 0) %>% filter(passenger_count < 5)

#Select longitudes which are between -72 and -75 and latitudes which are between 40 and 42
data <- data %>% filter(pickup_longitude < -72) %>% filter(pickup_longitude > -75)
data <- data %>% filter(pickup_latitude > 40) %>% filter(pickup_latitude < 42)
data <- data %>% filter(dropoff_longitude < -72) %>% filter(dropoff_longitude > -75)
data <- data %>% filter(dropoff_latitude > 40) %>% filter(dropoff_latitude < 42)


#Select payment type - only credit and cash
data <- data %>% filter(payment_type %in% c(1,2))


#Remove rate code type == 99 from data
data <- data %>% filter(!RatecodeID == 99)

#Restrict mta tax only to 0 and 0.5
data <- data %>% filter(mta_tax %in% c(0, 0.5))

#Restrict improvement surcharge to 0 and 0.3
data <- data %>% filter(improvement_surcharge %in% c(0, 0.3))

#Since the initial charge for a yellow taxi is 2.5, restrict the total amount to greater than or equal to 2.5
data <- data %>% filter(total_amount >= 2.50)

#Separate hour from the pick up time
data$Pick_up_Hour <- format(as.POSIXct(data$tpep_pickup_datetime),format = "%H")

#Average speed for every trip
data <- data %>% mutate(Average_speed = trip_distance/as.integer(Trip_duration))

#Add a column with binary values for credit = 1, cash = 0
data <- data %>% mutate(Credit_Cash = ifelse(payment_type == 2, 1, 0))

# Map of all the pick ups and drop offs
set.seed(1234)
foo <- sample_n(data, 8e3)
leaflet(data = foo) %>% addProviderTiles("Esri.NatGeoWorldMap") %>%
  addCircleMarkers(~ pickup_longitude, ~pickup_latitude, radius = 1,
                   color = "blue", fillOpacity = 0.3) %>% addCircleMarkers(~ dropoff_longitude, ~dropoff_latitude, radius = 1, color = "orange", fillOpacity = 0.3)

#Plot rides per hour per day
p2 <- data %>%
  group_by(Pick_up_Hour, Day) %>%
  count() %>% 
  ggplot(aes(as.numeric(Pick_up_Hour), n, color = Day)) +
  geom_line(size = 1.5) +
  labs(x = "Hour of the day", y = "count")
p2


#Select training and testing datasets from new data
set.seed(123)
new.total <- nrow(data)
new.train <- floor(0.8 * nrow(data))
new.sample <- sample.int(new.total, new.train, replace=FALSE)
train.data <- data[new.sample, ]
test.data <- data[-new.sample, ]


#Fit the linear regression model with fare as the response variable
lm.fit <- lm(fare_amount ~ trip_distance + pickup_latitude + pickup_longitude+ dropoff_latitude + dropoff_longitude + RatecodeID + mta_tax + improvement_surcharge + passenger_count + Pick_up_Hour + Trip_duration + Average_speed ,data = train.data)

#Predict on test data
test.data$Predictions <- predict(lm.fit, newdata = test.data, type = "response")

summary(lm.fit)


#Select new and smaller training and testing datasets from train data
set.seed(123)
n.total <- nrow(train.data)
n.train <- floor(0.0008 * nrow(train.data))
n.sample <- sample.int(n.total, n.train, replace=FALSE)
new_train <- train.data[n.sample, ]
new_test <- test.data[n.sample, ]

x <- model.matrix(Credit_Cash ~., train.data)[,-1] # Removes class
y <- train.data$Credit_Cash  # Only class
x_test <- model.matrix(Credit_Cash ~., test.data)[,-1]
y_test <- test.data$Credit_Cash

set.seed(999)
fit.ridge <- glmnet(x, y, alpha=0, lambda= 0.01, family='binomial')
prob <- predict(fit.ridge, s = 0.01, newx = x_test)

#Fit a logistic regression to predict whether payment will be made by credit or cash
fit.logit <- glm(Credit_Cash ~ trip_distance + pickup_latitude + pickup_longitude+ dropoff_latitude + dropoff_longitude + RatecodeID + passenger_count + Pick_up_Hour + Day, data = train.data, family = "binomial", maxit = 100)

#Predict on test data
test.data$log_Predictions <- predict(fit.logit, newdata = test.data, type='response') 
test.prediction <- prediction(test.data$log_Predictions, test.data$Credit_Cash)
test.performance <- performance(test.prediction, "auc")
cat('The auc score is', 100*test.performance@y.values[[1]], "\n")



###################################New Code###########################################################

##
library(lubridate)
library(dplyr)
library(ggmap)
library(leaflet)
library(ggplot2)

#COMMON FILES
taxi_zone <- read.csv("taxi_zone_lookup.csv")

#DATA - TAXI
taxi_jan <- read.csv("yellow_tripdata_2018-01.csv")
taxi_feb <- read.csv("yellow_tripdata_2018-02.csv")
taxi_march <- read.csv("yellow_tripdata_2018-03.csv")
taxi_april <- read.csv ("yellow_tripdata_2018-04.csv")
taxi_may <- read.csv("yellow_tripdata_2018-05.csv")
taxi_june <- read.csv("yellow_tripdata_2018-06.csv")


##date
taxi_jan$Pick_up_Date <- as.Date(taxi_jan$tpep_pickup_datetime)
taxi_feb$Pick_up_Date <- as.Date(taxi_feb$tpep_pickup_datetime)
taxi_march$Pick_up_Date <- as.Date(taxi_march$tpep_pickup_datetime)
taxi_april$Pick_up_Date <- as.Date(taxi_april$tpep_pickup_datetime)
taxi_may$Pick_up_Date <- as.Date(taxi_may$tpep_pickup_datetime)
taxi_june$Pick_up_Date <- as.Date(taxi_june$tpep_pickup_datetime)



##select only one month
taxi_jan <- taxi_jan %>% filter(Pick_up_Date <= "2018-01-31")%>% filter(Pick_up_Date >= "2018-01-01")
taxi_feb <- taxi_feb %>% filter(Pick_up_Date <= "2018-02-28")%>% filter(Pick_up_Date >= "2018-02-01")
taxi_march <- taxi_march %>% filter(Pick_up_Date <= "2018-03-31")%>% filter(Pick_up_Date >= "2018-03-01")
taxi_april <- taxi_april %>% filter(Pick_up_Date <= "2018-04-30")%>% filter(Pick_up_Date >= "2018-04-01")
taxi_may <- taxi_may %>% filter(Pick_up_Date <= "2018-05-31")%>% filter(Pick_up_Date >= "2018-05-01")
taxi_june <- taxi_june %>% filter(Pick_up_Date <= "2018-06-30")%>% filter(Pick_up_Date >= "2018-06-01")


#Separate hours
taxi_jan$Pick_up_Hour <- format(as.POSIXct(taxi_jan$tpep_pickup_datetime),format = "%H")
taxi_feb$Pick_up_Hour <- format(as.POSIXct(taxi_feb$tpep_pickup_datetime),format = "%H")
taxi_march$Pick_up_Hour <- format(as.POSIXct(taxi_march$tpep_pickup_datetime),format = "%H")
taxi_april$Pick_up_Hour <- format(as.POSIXct(taxi_april$tpep_pickup_datetime),format = "%H")
taxi_may$Pick_up_Hour <- format(as.POSIXct(taxi_may$tpep_pickup_datetime),format = "%H")
taxi_june$Pick_up_Hour <- format(as.POSIXct(taxi_june$tpep_pickup_datetime),format = "%H")


taxi_jan <- taxi_jan %>% rename(DATE = Pick_up_Date)
taxi_feb <- taxi_feb %>% rename(DATE = Pick_up_Date)
taxi_march <- taxi_march %>% rename(DATE = Pick_up_Date)
taxi_april <- taxi_april %>% rename(DATE = Pick_up_Date)
taxi_may <- taxi_may %>% rename(DATE = Pick_up_Date)
taxi_june <- taxi_june %>% rename(DATE = Pick_up_Date)

taxi_jan <- taxi_jan %>% rename(LocationID = PULocationID)
taxi_feb <- taxi_feb %>% rename(LocationID = PULocationID)
taxi_march <- taxi_march %>% rename(LocationID = PULocationID)
taxi_april <- taxi_april %>% rename(LocationID = PULocationID)
taxi_may <- taxi_may %>% rename(LocationID = PULocationID)
taxi_june <- taxi_june %>% rename(LocationID = PULocationID)


#Adding weekdays to the data
taxi_jan$Day <- weekdays(as.Date(taxi_jan$DATE))
taxi_feb$Day <- weekdays(as.Date(taxi_feb$DATE))
taxi_march$Day <- weekdays(as.Date(taxi_march$DATE))
taxi_april$Day <- weekdays(as.Date(taxi_april$DATE))
taxi_may$Day <- weekdays(as.Date(taxi_may$DATE))
taxi_june$Day <- weekdays(as.Date(taxi_june$DATE))


taxi_Jan <- taxi_jan %>% group_by(DATE, Day, Pick_up_Hour) %>% count()
taxi_Feb <- taxi_feb %>% group_by(DATE, Day, Pick_up_Hour) %>% count()
taxi_March <- taxi_march %>% group_by(DATE, Day, Pick_up_Hour) %>% count()
taxi_April <- taxi_april %>% group_by(DATE, Day, Pick_up_Hour) %>% count()
taxi_May <- taxi_may %>% group_by(DATE, Day, Pick_up_Hour) %>% count()
taxi_June <- taxi_june %>% group_by(DATE, Day, Pick_up_Hour) %>% count()

train.data <- rbind(taxi_Jan, taxi_Feb, taxi_March, taxi_April, taxi_May, taxi_June)

train.data <- train.data %>% rename(N_Taxis = n)

weather <- read.csv("Weather.csv")
weather$DATE <- as.character(weather$DATE)
weather$DATE <- as.Date(weather$DATE)

train.data <- merge(train.data, weather, by = "DATE")


#Fit the linear regression model with n as the response variable
lm.fit <- glm(N_Taxis ~ TMAX+TMIN+AWND+PRCP+SNOW+SNWD, data = train.data)


hourly_data <- train.data %>% group_by(Pick_up_Hour) %>% summarise(sum(N_Taxis)) 

daily_data <- train.data %>% group_by(Day) %>% summarise(sum(N_Taxis))

plot(hourly_data$Pick_up_Hour, hourly_data$`sum(N_Taxis)`)
ggplot(daily_data, aes(Day,`sum(N_Taxis)`))+geom_point()

##Test data
taxi_test <- read.csv("yellow_tripdata_2017-01.csv")

taxi_test$Pick_up_Date <- as.Date(taxi_test$tpep_pickup_datetime)
taxi_test <- taxi_test %>% filter(Pick_up_Date <= "2017-01-31")%>% filter(Pick_up_Date >= "2017-01-01")
taxi_test <- taxi_test %>% rename(DATE = Pick_up_Date)
taxi_test <- taxi_test %>% rename(LocationID = PULocationID)
taxi_test_merge <- inner_join(taxi_test, taxi_zone, by = "LocationID")
#Adding weekdays to the data
taxi_test_merge$Day <- weekdays(as.Date(taxi_test_merge$DATE))

weather_test <- read.csv("1574240.csv")
weather_test$DATE <- as.character(weather_test$DATE)
weather_test$DATE <- as.Date(weather_test$DATE)

merge_weather_taxiTest <- merge(taxi_test_merge, weather_test, by ="DATE")

taxiTest_day <- merge_weather_taxiTest %>% group_by(DATE,Day, TMAX, TMIN, AWND, PRCP, SNOW, SNWD, WDF2, WDF5, WSF2, WSF5) %>% count()

#Predict on test data
merge_weather_taxiTest$Predictions <- predict(lm.fit, newdata = merge_weather_taxiTest, type = "response")

