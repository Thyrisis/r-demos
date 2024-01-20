install.packages("tidyverse")
install.packages("slider")
library("tidyverse")
library("slider")

hadcet.mean.url <- "https://www.metoffice.gov.uk/hadobs/hadcet/data/meantemp_daily_totals.txt"
hadcet.min.url <- "https://www.metoffice.gov.uk/hadobs/hadcet/data/mintemp_daily_totals.txt"
hadcet.max.url <- "https://www.metoffice.gov.uk/hadobs/hadcet/data/maxtemp_daily_totals.txt"

hadcet.read.fn <- function(url) {
  read.fwf(url
           , widths = c(10, 7)
           , header = TRUE
           , skip = 1
           , row.names = NULL
           , col.names = c('obs_temp'))
}

hadcet.clean.fn <- function(tbl) {
  tbl |>
    as_tibble() |>
    rename(obs_date = row.names) |>
    mutate(obs_date = as.Date(obs_date)
           , obs_temp = as.numeric(obs_temp)
           , obs_year = year(obs_date)
           , obs_doy = yday(obs_date)
           , obs_temp_roll7 = slide_dbl(obs_temp, mean, .before = 6, .complete = TRUE))
}

hadcet.mean.raw <- hadcet.read.fn(hadcet.mean.url)
hadcet.mean.clean <- hadcet.clean.fn(hadcet.mean.raw)

hadcet.min.raw <- hadcet.read.fn(hadcet.min.url)
hadcet.min.clean <- hadcet.clean.fn(hadcet.min.raw)

hadcet.max.raw <- hadcet.read.fn(hadcet.max.url)
hadcet.max.clean <- hadcet.clean.fn(hadcet.max.raw)

hadcet.all.clean <-
  hadcet.mean.clean |>
  rename(mean_temp = obs_temp
         , mean_temp_roll7 = obs_temp_roll7) |>
  full_join(hadcet.min.clean |> 
              select(obs_date, obs_temp, obs_temp_roll7) |> 
              rename(min_temp = obs_temp
                     , min_temp_roll7 = obs_temp_roll7)
            , by = "obs_date") |>
  full_join(hadcet.max.clean |>
              select(obs_date, obs_temp, obs_temp_roll7) |>
              rename(max_temp = obs_temp
                     , min_temp_roll7 = obs_temp_roll7)
            , by = "obs_date")

hadcet.2023.mean <- hadcet.mean.clean |>
  filter(obs_year == 2023) |>
  rename(mean_temp = obs_temp
         , mean_temp_roll7 = obs_temp_roll7)

hadcet.all.clean |>
  filter(obs_year >= 1940
         , obs_year < 2023) |>
  ggplot(aes(x = obs_doy, y = mean_temp_roll7, group = as.factor(obs_year))) +
  geom_line(alpha = 0.1, show.legend = FALSE) +
  geom_line(data = hadcet.2023.mean, colour = "red")
