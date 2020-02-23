# Making graphics in R

<code>R</code> can clean, analyze and visualze vast amounts of data efficiently. Its power comes from the thousands of packages that programmers and scientists have created to extend it. We'll be using some of those packages to explore Louisiana data. 

In R, packages first must be installed and then loaded. The IRE/NICAR staff has already installed the packages we'll be using for this lesson, but here for future reference is how to install a package:

> install.packages("xxx")  [where "xxx" is the name of a package]

To load a package for use, simply enter this at the prompt:

> library(xxx) [where xxx is the name of the package -- and notice, this time the package name is NOT in quotes]

A few more points before we dig in:

* Capitalization matters. If a variable is spelled "Cat", don't write "cat" or "CAT". 
* Punctuation matters. R will help you by creating parentheses in pairs; don't erase closing parentheses by mistake.
* Assign variables with this mark <code><-</code> (left arrow and hyphen). The shortcut on Windows is Alt + minus sign; on Mac it is Option + minus sign.
* Comment out a line with the <code>#</code> (hash) mark
* Finally, you can create a script in R. This Is A Big Deal. It means you can insert comments in your code. It means you can recheck every stage of your work. It means that if you get fresh data you can import that data and run an old analysis against the new data to see if the results change.

In the script I've prepared, and which you can keep, you'll see that I try to be organized. (It's probably because, by nature, I'm the exact opposite.) Anyway, here are the steps:

1. Load packages.
2. Import data.
3. Clean data (if necessary -- it usually is).
4. Analyze and visualize data.
5. Publish data.

So let's load some libraries! Remember, the wonderful IRE/NICAR staff has already installed these packages, so we don't have to. 

* > library(tidyverse)
* > library(sf)
* > library(viridis)
* > library(plotly)
* > library(htmlwidgets)

Next we'll import data. I've selected three selections of Louisiana data from the American Community Survey. We'll use the tidyverse function read_csv() to import them.

* > LA_race <- read_csv("B02001_ACS2017_5YR.csv")
* > LA_education <-read_csv("B06009_ACS2018_5YR.csv")
* > LA_income <-read_csv("B19013_ACS2018_5YR.csv")

Take a look at LA_race with the command View(LA_race).

Now we'll visualize it using a histogram, a type of bar chart that measures frequencies. We'll count parishes based on their percentage of white residents, starting with a simple histogram using the tidyverse package ggplot2.

ggplot(LA_race, aes(White_per)) +
  geom_histogram()
  
![](https://github.com/roncampbell/NICAR-2020/blob/images/BasicHistogram.png?raw=true)

You can see that a few parishes have low percentages of whites; most parishes have white percentages of 60% or more.

Now let's take a look at that command: First we list the function, ggplot, then open parentheses, list the data frame we want to chart, LA_race, a comma followed by a peculiar word "aes", which is short for "aesthetic", then another opening parentheses and the column we want to chart, White_per, followed by closing parentheses and a plus sign. 

Next comes another weird word, "geom_", short for geometry, and histogram. In ggplot, everything is charted on a geom -- a point, a line, a bar or, in this case, a histogram. And just about everything is followed by opening and closing parentheses where you might or might not add further instructions.

So we now a basic histogram. But let's jazz it up. Copy what you just did and paste it below, but don't run it. We're going to add something in the parentheses after "geom_histogram".

ggplot(LA_race, aes(White_per)) +
  geom_histogram(col="black", fill="lightskyblue2")
  

![](https://github.com/roncampbell/NICAR-2020/blob/images/Histogram2.png?raw=true)

Run it, and we get something that leaps off the screen. The code we just added probably make sense now. "Col = 'black'" applies to the outline of objects; "fill='lightskyblue2'" applies to the interior or fill of objects. 

In case you're wondering about "lightskyblue2", R has lots of colors to choose from. How many? Go to the cursor, type this and hit enter.

colors()

Yep. Heinz has 57 flavors. R has 657 colors. 

Now we'll complete the chart. And to make it easier to work with, we'll assign it to a variable that we can call. Here's what we're going to do: We'll add a headline (or top label), labels for the x (horizontal) and y (vertical) axes and a source line. While we're at it, we'll also replace the gray background with a plain white background to make it easier to read.

race_hist <- ggplot(LA_race, aes(White_per)) + 
  geom_histogram(col="black", fill="lightskyblue2") +
  labs(title="Racial makeup of Louisiana parishes",
       caption="Source: U.S. Census Bureau") +
  xlab("White percentage") + ylab("Parishes") +
  theme_classic()

Now let's see what it looks like. Remember -- we have a script, so if we want to change something, we simply copy what we've already written, make tweaks and run it again.

race_hist

![](https://github.com/roncampbell/NICAR-2020/blob/images/Histogram3.png?raw=true)

Now we're going to look at median household income. 

First let's do a histogram.

![](https://github.com/roncampbell/NICAR-2020/blob/images/IncomeHistogram.png?raw=true)

It's highly varied. We'll use R's built-in summary() function to see just how highly varied median household income is among Louisiana's 64 parishes. As you write this command, remember: Capitalization matters in R!

summary(LA_income$MedianHouseholdIncome)

   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  21161   35295   41246   43325   50668   76589 

The variation is huge. Median income in the wealthiest parish is nearly four times that of the poorest parish. 

We're going to compare median income and education of Louisiana parishes to find out whether education and income go together. To make the comparison simpler, we'll classify parishes into broad income ranges.

LA_income <- LA_income %>% 
  mutate(IncRange = case_when(MedianHouseholdIncome < 35295 ~ "LowInc",
                              MedianHouseholdIncome >= 35295 & 
                                MedianHouseholdIncome <= 41246 ~ "MedLowInc",
                              MedianHouseholdIncome > 41246 &
                                MedianHouseholdIncome <= 50668 ~ "MedHighInc",
                              MedianHouseholdIncome > 50668 ~ "HighInc"))

This is the most complicated bit of coding we're doing in this class. We're making a permanent change to the LA_income data frame, so we assign a change in LA_income back to LA_income. Then we use the mutate() command to create a new column, IncRange, and the argument case_when to set up conditions based on values in the field Medhouseholdincome. We're taking the values straight from the summary we did a few minutes ago. We then break up the parishes into four categories: LowInc, MedLowInc, MedHighInc and HighInc.

Next we'll join the LA_income and LA_education data frames. Joining or merging two data frames is similar to joining tables in SQL; you use a field that both data frames have in common.

LA_inc_ed <- inner_join(LA_education, LA_income,
                        by="id")

Now we can examine the relationship between income and education. We'll use the categories we just created in the IncRange field and the percentage of residents with at least a college degree (BAPlus_per). We're trying to measure variation within each income category; so we'll use box plots. The syntax is similar to what we've seen with histograms.

ggplot(LA_inc_ed, aes(IncRange, BAPlus_per)) + 
  geom_boxplot()

![](https://github.com/roncampbell/NICAR-2020/blob/images/BasicBoxplot.png?raw=true)

We can see that something is going on. But we have to look closely to see the pattern. That's because of the way the boxes are arranged -- in alphabetical order, from "H" (HighInc) to "M" (MedLowInc). 

It would be much clearer if the boxes were arranged from LowInc to High Inc. We can do that by converting IncRange to a factor, a special variable in R, and arranging the variables in a set order.

LA_inc_ed$IncRange <- factor(LA_inc_ed$IncRange, levels=c("LowInc","MedLowInc","MedHighInc","HighInc"))

Now we'll re-run the same command, this time with a few tweaks:

ggplot(LA_inc_ed, aes(IncRange, BAPlus_per)) + 
  geom_boxplot() +
  labs(title="Education and income in Louisiana parishes",
       caption="Source: U.S. Census Bureau") +
  xlab("Income ranges") + ylab("Percentage with bachelor's degree or higher")

![](https://github.com/roncampbell/NICAR-2020/blob/images/FinishedBoxplot.png?raw=true) 

Now you can really see the relationship between education level and median income. Generally, poorer low-income parishes have few college-educated residents.

A box plot makes this clear with just a few lines. The thick horizontal line in the box is the median; the lower and upper edges of the box represent the 25th and 75th percentiles of the data. The vertical lines extending above and below the box are called "whiskers" and extend 1-1/2 times the distance between the 25th and 75th perentiles. For example, if the 25th percentile for BA degrees is 10% and the 75th percentile is 30%, the distance (or InterQuartile Range, IQR for short) is 20 percentage points, and 1-1/2 times that is 30 percentage points. Anything beyond a whisker is an outlier and is represented by a dot.






