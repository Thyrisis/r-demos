library(tidyverse)
library(ff.utils)
library(gt)
library(tidyquant)
library(readxl)

today <- str_replace_all(now(), "\\s|-|:", "_")

url <- "https://www.ons.gov.uk/file?uri=/businessindustryandtrade/retailindustry/datasets/poundsdatatotalretailsales/current/poundsdata.xlsx"
file <- "ons_retailsales_poundsdata.xlsx"
download.file(url, file)



url <- "https://www.ons.gov.uk/file?uri=/businessindustryandtrade/retailindustry/datasets/poundsdatatotalretailsales/current/poundsdata.xlsx"
file <- glue::glue("ons_retailsales_poundsdata_", today, ".xlsx")
download.file(url, file)

xl <- read_excel(file, sheet = "ValNSATD", skip = 4, col_names = TRUE)
