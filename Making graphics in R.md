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


