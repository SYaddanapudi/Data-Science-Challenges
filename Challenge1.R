## Load Required Packages
library("jsonlite")        # Parsing jSon Files
library("splitstackshape") # String Parsing
library("dplyr")           # Group by Functions 
library("lubridate")       # Time Series
library("reshape2")        # For converting DataFrames to Matrices
library("qlcMatrix")       # For Similarities
library("anytime")         # For cinverting Unix Tine Stamp
library("data.table")      # For Reading Falt Files
library("ggplot2")         # For visualizations
library("stringr")         # For NLP
library("randomForest")
library("FSelector")

## Reading the data
Users_Table = fread("challenge_1/user_table.csv", stringsAsFactors = FALSE, sep = ",")
Test_Results = fread("challenge_1/test_results.csv", stringsAsFactors = FALSE, sep = ",")

## Converting to TimeStamp
Test_Results$timestamp = anytime(Test_Results$timestamp)



## Converting to TimeStamp
Test_Results$timestamp = anytime(Test_Results$timestamp)



### Business Question 1: 
Test_Results_Q1 = Test_Results

## Get the Mean Conversion Rate and number of users based on Price
Grouped_Challeng1 <- Test_Results %>% group_by(test)
GroupRevenues = Grouped_Challeng1 %>% summarise(
  ConversionRate = mean(converted),
  NUmberOfUSers = n_distinct(user_id)
)

###
# A tibble: 2 x 3
#     test      ConversionRate  NUmberOfUSers
#     0         0.0199          202727
#     1         0.0155          114073


### Conduct Student's distribution Test to see if the revenue generated
### by Test Group is Greater than the revenue generated by Other Group
TestGroup = Test_Results[Test_Results$test == 1,c("user_id","converted")]
OtherGroup = Test_Results[Test_Results$test == 0,c("user_id","converted")]
TestGroup$Revenue = TestGroup$converted * 59
OtherGroup$Revenue = OtherGroup$converted * 39

## ttest
### H0: Null Hypotheis: Revenues generated by two groups are equal
### H1: Alternate Hypotheis: Revenues generated by Test Group is Higher
t.test(TestGroup$Revenue,OtherGroup$Revenue,var.equal = FALSE,alternative = "greater")

## Results,
# Welch Two Sample t-test
# 
# data:  TestGroup$Revenue and OtherGroup$Revenue
# t = 5.6846, df = 186480, p-value = 6.565e-09
# alternative hypothesis: true difference in means is greater than 0
# 95 percent confidence interval:
#   0.1000428       Inf
# sample estimates:
#   mean of x mean of y 
# 0.917018  0.776241 

## From the pValue, it is clearly eveident that we fail to accept Null Hypotheis and
## say that revenues generated by Test Group is higher. The only assumption here would be
## there is no bias involved in dividing the groups


### Business Question 2: 
Test_Results_Q2 = Test_Results
### Converting characters to Factors
Test_Results_Q2$source = as.factor(Test_Results_Q2$source)
Test_Results_Q2$device = as.factor(Test_Results_Q2$device)
Test_Results_Q2$operative_system = as.factor(Test_Results_Q2$operative_system)
Test_Results_Q2$test = as.factor(Test_Results_Q2$test)
Test_Results_Q2$converted = as.factor(Test_Results_Q2$converted)

## Random Forests seems to not detect any feature imporant variables
#Test_Results_Q2.rf <- randomForest(converted ~ source + device + operative_system + price, data=Test_Results_Q2, importance=TRUE)
### Runing ChiSquared Feature Selection Algorithm to find the attribute importance
chi.squared(converted ~ source + device + operative_system + price, data=Test_Results_Q2)
#                      attr_importance
# source               0.048861613
# device               0.001977899
# operative_system     0.027376454
# price                0.015455837

## Based on the feature imporatnce, we can say that device doesn't play any role in coversion where as other feature
## like source, operating_system and price do play a role

### Here, the question we want to ask is, Does price play any role in conversion?
## We can adress this question by seeing how many of the users bought the item based on price
Grouped_Ch1_Price<- Test_Results %>% group_by(price)
ConversionByPrice = Grouped_Ch1_Price %>% summarise(
  ConversionRate = mean(converted),
  NonConversionRate = 1-ConversionRate
)

print(ConversionByPrice)
#     price ConversionRate NonConversionRate
# 1    39         0.0199             0.980
# 2    59         0.0156             0.984


## Similarly we want to ask if, Does Operating_System play any role in conversion?
Grouped_Ch1_OS<- Test_Results %>% group_by(operative_system)
ConversionByOS = Grouped_Ch1_OS %>% summarise(
  ConversionRate = mean(converted),
  NonConversionRate = 1-ConversionRate
)
print(ConversionByOS)
#   operative_system  ConversionRate NonConversionRate
# 1 android                 0.0149              0.985
# 2 iOS                     0.0223              0.978
# 3 linux                   0.00822             0.992
# 4 mac                     0.0240              0.976
# 5 other                   0.0130              0.987
# 6 windows                 0.0170              0.983

## Similarly we want to ask if, Does source play any role in conversion?
Grouped_Ch1_source <- Test_Results %>% group_by(source)
ConversionBySource = Grouped_Ch1_source %>% summarise(
  ConversionRate = mean(converted),
  NonConversionRate = 1-ConversionRate
)

print(ConversionBySource)
#       source          ConversionRate NonConversionRate
# 1 ads_facebook            0.0212             0.979
# 2 ads_other               0.0144             0.986
# 3 ads-bing                0.0120             0.988
# 4 ads-google              0.0215             0.979
# 5 ads-yahoo               0.0148             0.985
# 6 direct_traffic          0.0123             0.988
# 7 friend_referral         0.0387             0.961
# 8 seo_facebook            0.0160             0.984
# 9 seo-bing                0.0237             0.976
# 10 seo-google             0.0170             0.983
# 11 seo-other              0.0157             0.984
# 12 seo-yahoo              0.0162             0.984


## Similarly we want to ask if, Does device play any role in conversion?
Grouped_Ch1_device<- Test_Results %>% group_by(device)
ConversionBydevice = Grouped_Ch1_device %>% summarise(
  ConversionRate = mean(converted),
  NonConversionRate = 1-ConversionRate
)

print(ConversionBydevice)
#   device ConversionRate NonConversionRate
# 1 mobile         0.0186             0.981
# 2 web            0.0180             0.982



