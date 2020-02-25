###########################################
# Painting pictures by the numbers with R #
###########################################

# Working code for class at NICAR 2020 in New Orleans

# Set working directory ---------------------------------------------------

# load files into a dorectory on your computer with 
# subfolders labeled Data for CSV and Maps for shapefiles
# I use Mac directory conventions on import statements below

# remove hash mark when setting working directory and place 
# working directory within parentheses

# setwd()

# Load packages -----------------------------------------------------------
library(tidyverse)
library(viridis)
library(sf)
library(plotly)
library(htmlwidgets)


# Import data -------------------------------------------------------------
LA_race <- read_csv("Data/B02001_ACS2017_5YR.csv")
LA_education <- read_csv("Data/B06009_ACS2018_5YR.csv")
LA_income <- read_csv("Data/B19013_ACS2018_5YR.csv")

# Clean data --------------------------------------------------------------

# calculate percentage of whites and non-whites in LA parishes
LA_race <- LA_race %>% 
  mutate(White_per = (White_alone / Total) * 100,
         NonWhite_per = 100 - White_per)

# calculate percentage of people with less than high school diplomas 
# and with bachelor degrees or higher in LA parishes
LA_education <- LA_education %>% 
  mutate(LessThanHS_per = (LessThanHSGrad / Total) * 100,
         BAPlus_per = ((BachelorsDegree + GradOrProfessionalDegree) / 
                         Total) * 100)


# Visualize data ----------------------------------------------------------

# make a histogram of white population of parishes
ggplot(LA_race, aes(White_per)) + 
  geom_histogram()

# change the colors of the bars
ggplot(LA_race, aes(White_per)) + 
  geom_histogram(col="black", fill="lightskyblue2")

# add labels and source
race_hist <- ggplot(LA_race, aes(White_per)) + 
  geom_histogram(col="black", fill="lightskyblue2") +
  labs(title="Racial makeup of Louisiana parishes",
       caption="Source: U.S. Census Bureau") +
  xlab("White percentage") + ylab("Parishes") +
  theme_classic()

# run histogram by calling variable
race_hist

# histogram of median household income by parish
ggplot(LA_income, aes(MedianHouseholdIncome)) + 
  geom_histogram(col="black", fill="lightgreen") +
  labs(title="Median household income of Louisiana parishes",
       caption="Source: U.S. Census Bureau") +
  xlab("Median income") + ylab("Parishes") +
  theme_classic()

# summarize income by parish
summary(LA_income$MedianHouseholdIncome)

# create income categories
LA_income <- LA_income %>% 
  mutate(IncRange = case_when(MedianHouseholdIncome < 35295 ~ "LowInc",
                              MedianHouseholdIncome >= 35295 & 
                                MedianHouseholdIncome <= 41246 ~ "MedLowInc",
                              MedianHouseholdIncome > 41246 &
                                MedianHouseholdIncome <= 50668 ~ "MedHighInc",
                              MedianHouseholdIncome > 50668 ~ "HighInc"))

# compare parishes for income and education
LA_inc_ed <- inner_join(LA_education, LA_income,
                        by="id")

# visualize the relationship between education and income
ggplot(LA_inc_ed, aes(IncRange, BAPlus_per)) + geom_boxplot()

# arrange the order of boxes from low to high by ordering IncRange column
LA_inc_ed$IncRange <- factor(LA_inc_ed$IncRange, levels=c("LowInc","MedLowInc","MedHighInc","HighInc"))

# now re-run the boxplot and dress it up
ggplot(LA_inc_ed, aes(IncRange, BAPlus_per)) + 
  geom_boxplot() +
  labs(title="Education and income in Louisiana parishes",
       caption="Source: U.S. Census Bureau") +
  xlab("Income range") + ylab("Percentage with bachelor's degree or higher") 

# interactive boxplot of income and education
p <- plot_ly(LA_inc_ed, y= ~BAPlus_per,
             boxpoints="suspected outliers")
p1 <- p %>% add_boxplot(x= "Overall")
p2 <- p %>% add_boxplot(x= ~IncRange)
subplot(
  p1,p2,shareY=TRUE, 
  widths=c(0.2,0.8), margin=0) %>% 
  hide_legend()

# Import maps -------------------------------------------------------------

LA_parishes <- st_read("Maps/LA_parishes.shp")

# merge parish-level income data with map
LA_parish_inc <- inner_join(LA_parishes, LA_income,
                            by=c("AFFGEOID"="id"))

# map income by parish
ggplot(LA_parish_inc) +
  geom_sf(aes(fill = MedianHouseholdIncome)) +
  ggtitle("Median Household Income, 2017") +
  scale_fill_viridis() +
  theme_bw()

# modify the color scale
LA_incmap <- ggplot(LA_parish_inc) +
  geom_sf(aes(fill = MedianHouseholdIncome)) +
  ggtitle("Median Household Income, 2017") +
  scale_fill_viridis_c(alpha=0.6) +
  theme_bw()

LA_incmap

# simple interactive
ggplotly(LA_incmap)