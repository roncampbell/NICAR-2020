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

<code>ggplot(LA_race, aes(White_per)) +
  geom_histogram()</code>code>

![](https://github.com/roncampbell/NICAR-2020/blob/images/BasicHistogram.png?raw=true)  

You can see that a few parishes have low percentages of whites; most parishes have white percentages of 60% or more.

Now let's take a look at that command: First we list the function, ggplot, then open parentheses, list the data frame we want to chart, LA_race, a comma followed by a peculiar word "aes", which is short for "aesthetic", then another opening parentheses and the column we want to chart, White_per, followed by closing parentheses and a plus sign. 

Next comes another weird word, "geom_", short for geometry, and histogram. In ggplot, everything is charted on a geom -- a point, a line, a bar or, in this case, a histogram. And just about everything is followed by opening and closing parentheses where you might or might not add further instructions.

So we now a basic histogram. But let's jazz it up. Copy what you just did and paste it below, but don't run it. We're going to add something in the parentheses after "geom_histogram".

<code>ggplot(LA_race, aes(White_per)) +
  geom_histogram(col="black", fill="lightskyblue2")</code>

![](https://github.com/roncampbell/NICAR-2020/blob/images/Histogram2.png?raw=true)  

Run it, and we get something that leaps off the screen. The code we just added probably make sense now. "Col = 'black'" applies to the outline of objects; "fill='lightskyblue2'" applies to the interior or fill of objects. 

In case you're wondering about "lightskyblue2", R has lots of colors to choose from. How many? Go to the cursor, type this and hit enter.

<code>colors()</code>

Yep. Heinz has 57 flavors. R has 657 colors. 

Now we'll complete the chart. And to make it easier to work with, we'll assign it to a variable that we can call. Here's what we're going to do: We'll add a headline (or top label), labels for the x (horizontal) and y (vertical) axes and a source line. While we're at it, we'll also replace the gray background with a plain white background to make it easier to read.

<code>race_hist <- ggplot(LA_race, aes(White_per)) +                  
  geom_histogram(col="black", fill="lightskyblue2") +
  labs(title="Racial makeup of Louisiana parishes",
       caption="Source: U.S. Census Bureau") +
  xlab("White percentage") + ylab("Parishes") +
  theme_classic()</code>

Now let's see what it looks like. Remember -- we have a script, so if we want to change something, we simply copy what we've already written, make tweaks and run it again.

<code>race_hist</code>

![](https://github.com/roncampbell/NICAR-2020/blob/images/Histogram3.png?raw=true)

Now we're going to take a look at median household income. First let's do a histogram.

<code>ggplot(LA_income, aes(MedianHouseholdIncome)) + 
  geom_histogram(col="black", fill="lightgreen") +
  labs(title="Median household income of Louisiana parishes",
       caption="Source: U.S. Census Bureau") +
  xlab("Median income") + ylab("Parishes") +
  theme_classic()</code>

![](https://github.com/roncampbell/NICAR-2020/blob/images/IncomeHistogram.png?raw=true)

It's highly varied. We'll use R's built-in summary() function to see just how highly varied median household income is among Louisiana's 64 parishes. As you write this command, remember: Capitalization matters in R!

<code>summary(LA_income$MedianHouseholdIncome)</code>

   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 

  21161   35295   41246   43325   50668   76589 

The variation is huge. Median household income in the wealthiest parish is nearly four times that of the poorest parish.

We're going to compare median income with the education level in Louisiana parishes to find out whether education and income are linked. To make the comparison simpler, we'll classify parishes into broad income categories.

<code>LA_income <- LA_income %>% 
  mutate(IncRange = case_when(MedianHouseholdIncome < 35295 ~ "LowInc",
                              MedianHouseholdIncome >= 35295 & 
                                MedianHouseholdIncome <= 41246 ~ "MedLowInc",
                              MedianHouseholdIncome > 41246 &
                                MedianHouseholdIncome <= 50668 ~ "MedHighInc",
                              MedianHouseholdIncome > 50668 ~ "HighInc"))</code>

This is the most complicated bit of coding we're doing in this class, so let' break it down. We're making a permanent change to the LA_income data frame, so we assign the change back to the data frame. That's what "LA_income <- LA_income" means. Next we use the mutate() command to create a new column IncRange. Then we use the case_when argument to assign values to IncRange based on the MedianHouseholdIncome column. We create four broad categories based on the values we found in the summary of MedianHouseholdIncome -- LowInc, MedLowInc, MedHighInc and HighInc.

With that done, we'll join LA_income with LA_education. If you've worked with SQL databases, this command will be familiar.

<code>LA_inc_ed <- inner_join(LA_education, LA_income, by="id")</code>

Now we can examine the relationship between income and education. We'll use the categories we just created in the IncRange field and the percentage of residents with at least a college degree (BAPlus_per). We're trying to measure variation within each income category; so we'll use box plots. The syntax is similar to what we've seen with histograms.

<code>ggplot(LA_inc_ed, aes(IncRange)) + geom_boxplot()</code>

![](https://github.com/roncampbell/NICAR-2020/blob/images/BasicBoxplot.png?raw=true)

We can see that something is going on. But we have to look closely to see the pattern. It doesn't help that the boxes are arranged in alphabetical order by IncRange, from "H" for HighInc to "M" for MedLowInc. It would be much clearer if they were arranged in ascending order of income, from LowInc to HighInc. To do that, we'll convert IncRange to a factor, a special data type in R, and assign an order to the variables.

<code>LA_inc_ed$IncRange <- factor(LA_inc_ed$IncRange, levels=c("LowInc","MedLowInc","MedHighInc","HighInc"))</code>

Now we'll do box plots again, this time with a few tweaks to make it look neater.

<code>ggplot(LA_inc_ed, aes(IncRange, BAPlus_per)) + 
  geom_boxplot() +
  labs(title="Education and income in Louisiana parishes",
       caption="Source: U.S. Census Bureau") +

![](https://github.com/roncampbell/NICAR-2020/blob/images/FinishedBoxplot.png?raw=true)

Now you can really see the relationship between education level and median income. Generally, poorer parishes have few college-educated residents.

A box plot makes this clear with just a few lines. The thick horizontal line in the box is the median; the lower and upper edges of the box represent the 25th and 75th percentiles of the data. The vertical lines extending above and below the box are called "whiskers" and extend 1-1/2 times the distance between the 25th and 75th perentiles. For example, if the 25th percentile for BA degrees is 10% and the 75th percentile is 30%, the distance (or InterQuartile Range, IQR for short) is 20 percentage points, and 1-1/2 times that is 30 percentage points. Anything beyond a whisker is an outlier and is represented by a dot.

Let's make this boxplot interactive so we can really see the data. We'll use the plotly package to do that.

p <- plot_ly(LA_inc_ed, y= ~BAPlus_per,
             boxpoints="suspected outliers")
p1 <- p %>% add_boxplot(x= "Overall")
p2 <- p %>% add_boxplot(x= ~IncRange)
subplot(
  p1,p2,shareY=TRUE, 
  widths=c(0.2,0.8), margin=0) %>% 
  hide_legend()

Here's what we're doing: We're creating three layers -- p, p1 and p2 -- which represent the y (vertical axis), education; the overall trend; and the four income ranges that we defined earlier. Notice the argument "add_boxplot" for p1 and p2. It means just what it says, that we're adding them to the chart where we've already placed the education data.

Next we do a subplot. We tell plotly that p1 and p2 will share the y axis. We also set the widths between the boxes. This is arbitrary and can be changed. Finally we decide that we don't need a legend.

Highlight all the code, click the Run button, and this is what you'll get.

![](https://github.com/roncampbell/NICAR-2020/blob/images/InteractiveBox.png?raw=true)

This tells us a lot more than we could see with the static chart. We can instantly see a lot of details that we might have missed before. It vividly underscores the poor educational status of the low-income counties.

One of the best ways to visualize data is with a map. We'll start by importing a digital map of Louisiana's parishes.

<code>LA_parishes <- st_read("Maps/LA_parishes.shp")</code>

This map is a shapefile. If you've worked with ArcMap or QGIS, you're familiar with shapefiles. 

R treats a shapefile as just another bit of data. That means you can join it with the other data we've already imported. Let's add the income data to the parish map. It's slightly more complicated than the last join because the columns we'll use have different names.

<code>LA_parish_inc <- inner_join(LA_parishes, LA_income,
                            by=c("AFFGEOID"="id"))</code>

See how that works? AFFGEOID in LA_parish, the map, is identical to id in LA_income. We used those two columns in the by() statement with an equal sign. Important caution: Make sure that you list the join columns in the same order as the data frames. We listed AFFGEOID first because we listed LA_parishes first. If we had listed LA_parishes first and "id" first, R would have thrown an error.

Now we'll map the data. We're going to throw in a few new wrinkles here, most notably geom_sf(), which is used a lot in mapping in R. And instead of setting the fill equal to a color, we'll set it equal to a field, MedianHouseholdIncome.

<code>ggplot(LA_parish_inc) +
  geom_sf(aes(fill = MedianHouseholdIncome)) +
  ggtitle("Median Household Income, 2017") +
  scale_fill_viridis() +
  theme_bw()</code>

![](https://github.com/roncampbell/NICAR-2020/blob/images/IncMap1.png?raw=true)

Now we'll make an interactive map of median income for Louisiana parishes. This is simpler than making a boxplot. We'll assign a name to the map we just made, run it, then wrap the name in the command ggplotly and run that.

<code>LA_incmap <- ggplot(LA_parish_inc) +
  geom_sf(aes(fill = MedianHouseholdIncome)) +
  ggtitle("Median Household Income, 2017") +
  scale_fill_viridis() +
  theme_bw()</code>

<code>LA_incmap</code>

<code>ggplotly(LA_incmap)

![](https://github.com/roncampbell/NICAR-2020/blob/images/InteractiveMap.png?raw=true)





