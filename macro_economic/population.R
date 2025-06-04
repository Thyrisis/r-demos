install.packages("googlesheets4")
library(tidyverse)
library(googlesheets4) 

data.raw <- googlesheets4::read_sheet(ss = "https://docs.google.com/spreadsheets/d/11qDjnPu2BlFFegwpPl3CcyZtfiYT4R2seU_IcIcJkHM"
, sheet = "data-for-regions-by-year")

data.raw <- read_csv("ddf--datapoints--population--by--country--year.csv")

data.raw |>
  ggplot(aes(x = time, y = Population, color = name)) +
  geom_line() +
  geom_vline(xintercept = 2025)
