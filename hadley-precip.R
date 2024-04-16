library("tidyverse")
library("slider")
library("glue")
library("bbplot")

hadp.ew.url <- "https://www.metoffice.gov.uk/hadobs/hadukp/data/daily/HadEWP_daily_totals.txt"
hadp.s.url <- "https://www.metoffice.gov.uk/hadobs/hadukp/data/daily/HadSP_daily_totals.txt"
hadp.ni.url <- "https://www.metoffice.gov.uk/hadobs/hadukp/data/daily/HadNIP_daily_totals.txt"

hadp.read.fn <- function(url) {
  read.fwf(url
           , widths = c(10, 7)
           , header = TRUE
           , skip = 4
           , row.names = NULL
           , col.names = c('obs_precip_mm'))
}

hadp.clean.fn <- function(tbl, roll = 28) {
  tbl |>
    as_tibble() |>
    rename(obs_date = row.names) |>
    mutate(obs_date = as.Date(obs_date)
           , obs_precip_mm = as.numeric(obs_precip_mm)
           , obs_year = year(obs_date)
           , obs_doy = yday(obs_date)
           , obs_precip_mm_roll = slide_dbl(obs_precip_mm, mean, .before = roll, .complete = TRUE)
           , obs_caldoy = as.Date(obs_doy - 1, origin = "1940-01-01"))
}

hadp.ew.raw <- hadp.read.fn(hadp.ew.url)
hadp.ew.clean <- hadp.clean.fn(hadp.ew.raw)

hadp.s.raw <- hadp.read.fn(hadp.s.url)
hadp.s.clean <- hadp.clean.fn(hadp.s.raw)

hadp.ni.raw <- hadp.read.fn(hadp.ni.url)
hadp.ni.clean <- hadp.clean.fn(hadp.ni.raw)

current_year <- 2024

hadp.ew.current_year <- hadp.ew.clean |>
  filter(obs_year == current_year)

hadp.ew.clean |>
  filter(obs_year < current_year) |>
  ggplot(aes(x = obs_caldoy, y = obs_precip_mm_roll)) +
  geom_point(alpha = 0.1, size = 0.4) +
  geom_point(data = hadp.ew.current_year, colour = "red", size = 0.4) +
  scale_x_date(labels = function(x){str_sub(strftime(x, format = "%b"), start = 1, end = 1)}, date_breaks = "1 month", expand = c(0, 0)) +
  scale_y_continuous(label = function(x){paste0(x, "mm")}, expand = c(0, 0)) +
  labs(title = "UK Daily Precipitation, 1931 on"
       , subtitle = glue("28 day rolling average, {current_year} in red")
       , y = "Precipitation (mm)"
       , x = ""
       , caption = "source: Hadley Centre England & Wales Precipitation Series: https://www.metoffice.gov.uk/hadobs/hadukp/data/daily/HadEWP_daily_totals.txt") +
  bbc_style() +
  theme(axis.text.x = element_text(hjust = -1)
        , axis.ticks.x = element_line())

  