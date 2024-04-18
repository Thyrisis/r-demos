#install.packages("tidyverse")
#install.packages("slider")
#remotes::install_github('bbc/bbplot')
library("tidyverse")
library("slider")
library("glue")
library("bbplot")

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

hadcet.clean.fn <- function(tbl, roll = 29) {
  tbl |>
    as_tibble() |>
    rename(obs_date = row.names) |>
    mutate(obs_date = as.Date(obs_date)
           , obs_temp = as.numeric(obs_temp)
           , obs_year = year(obs_date)
           , obs_doy = yday(obs_date)
           , obs_temp_roll = slide_dbl(obs_temp, mean, .before = roll, .complete = TRUE)
           , obs_caldoy = as.Date(obs_doy - 1, origin = "1940-01-01"))
}

hadcet.mean.raw <- hadcet.read.fn(hadcet.mean.url)
hadcet.mean.clean <- hadcet.clean.fn(hadcet.mean.raw)

hadcet.min.raw <- hadcet.read.fn(hadcet.min.url)
hadcet.min.clean <- hadcet.clean.fn(hadcet.min.raw)

hadcet.max.raw <- hadcet.read.fn(hadcet.max.url)
hadcet.max.clean <- hadcet.clean.fn(hadcet.max.raw)

hadcet.all.clean <- hadcet.mean.clean |>
  rename(mean_temp = obs_temp
         , mean_temp_roll7 = obs_temp_roll) |>
  full_join(hadcet.min.clean |> 
              select(obs_date, obs_temp, obs_temp_roll) |> 
              rename(min_temp = obs_temp
                     , min_temp_roll7 = obs_temp_roll)
            , by = "obs_date") |>
  full_join(hadcet.max.clean |>
              select(obs_date, obs_temp, obs_temp_roll) |>
              rename(max_temp = obs_temp
                     , min_temp_roll7 = obs_temp_roll)
            , by = "obs_date")

hadcet.2013.mean <- hadcet.mean.clean |>
  filter(obs_year >= 2013
         , obs_year <= 2022) |>
  rename(mean_temp = obs_temp
         , mean_temp_roll7 = obs_temp_roll)

hadcet.2023.mean <- hadcet.mean.clean |>
  filter(obs_year == 2023) |>
  rename(mean_temp = obs_temp
         , mean_temp_roll7 = obs_temp_roll)

hadcet.all.clean |>
  filter(obs_year >= 1940
         , obs_year < 2013) |>
  ggplot(aes(x = obs_caldoy, y = mean_temp_roll7, group = as.factor(obs_year))) +
  geom_line(alpha = 0.1, show.legend = FALSE) +
  geom_line(data = hadcet.2023.mean, colour = "red") +
  geom_line(data = hadcet.2013.mean, colour = "blue", alpha = 0.3) +
  scale_x_date(date_labels = "%d %b", date_breaks = "1 month") +
  labs(title = "Mean Daily Temperature, 1940-2023"
       , subtitle = "30 day rolling average - blue 2013-22, red 2023"
       , x = "Day of Year"
       , y = "Temperature (°C)"
       , caption = "source: Hadley Centre Central England Temperature Series: www.metoffice.gov.uk/hadobs/hadcet/data/download.html")

### v2 - up to date tracker
current_year <- 2024

hadcet.current_year.mean <- hadcet.mean.clean |>
  filter(obs_year == current_year) |>
  rename(mean_temp = obs_temp
         , mean_temp_roll7 = obs_temp_roll)

bbc_plot <- hadcet.all.clean |>
  filter(obs_year >= 1900
         , obs_year < current_year) |>
  ggplot(aes(x = obs_caldoy, y = mean_temp_roll7, group = as.factor(obs_year))) +
  geom_line(alpha = 0.05, show.legend = FALSE) +
  geom_line(data = hadcet.current_year.mean, colour = "red") +
  geom_hline(yintercept = 0, colour = "black") +
  scale_x_date(labels = function(x){str_sub(strftime(x, format = "%b"), start = 1, end = 1)}, date_breaks = "1 month", expand = c(0, 0)) +
  scale_y_continuous(limits = c(-5, 22), breaks = seq(-5, 22, 5), label = function(x){paste0(x, "C")}, expand = c(0, 0)) +
#  scale_x_date(limits = c(as.Date('1940-01-01'), as.Date('1940-12-31')), date_labels = "%b", date_breaks = "1 month") +
  labs(title = "Mean UK Daily Temperature, 1900 on"
       , subtitle = glue("30 day rolling average, {current_year} in red")
       , y = "Temperature (°C)"
       , x = ""
       , caption = "source: Hadley Centre Central England Temperature Series: www.metoffice.gov.uk/hadobs/hadcet/data/download.html") +
  bbc_style() +
  theme(axis.text.x = element_text(hjust = -1)
        , axis.ticks.x = element_line())

finalise_plot(bbc_plot
              , source = "Source: Hadley Centre Central England Temperature Series"
              , save_filepath = "hadley_daily_temp.png")
  
### v3 - hockey stick
hadcet.baseline <-
  hadcet.mean.clean |>
  filter(obs_year >= 1961
         , obs_year <= 1990) |>
  summarise(n_days = n()
            , mean_temp = mean(obs_temp))

hadcet.annual <-
  hadcet.mean.clean |>
  filter(obs_year < year(now())) |>
  group_by(obs_year) |>
  summarise(n_days = n()
            , mean_temp = mean(obs_temp)) |>
  mutate(baseline_var_temp = mean_temp - hadcet.baseline$mean_temp) |>
  ggplot(aes(x = obs_year, y = baseline_var_temp)) +
  geom_col() +
  geom_hline(yintercept = 0) +
  bbc_style()
  
