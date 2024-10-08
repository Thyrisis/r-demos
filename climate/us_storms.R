library(tidyverse)
library(xml2)
library(rvest)

# prompted by
# https://qr.ae/p2g5TO

url.storms <- "https://www.aoml.noaa.gov/hrd/hurdat/uststorms.html"
url.hurricanes <- "https://www.aoml.noaa.gov/hrd/hurdat/All_U.S._Hurricanes.html"

data.storms.raw <- read_html(url.storms)
data.storms.nodes <- html_nodes(data.storms.raw, "table")
data.storms.clean <- html_table(data.storms.nodes, header = FALSE, convert = TRUE)[[3]] |>
  mutate(storm_n = as.numeric(X1)
        , date = as_date(str_extract(X2, "\\d{1,2}/\\d{1,2}/\\d{4}"), format = "%m/%d/%Y")
        , year = year(date)
        , doy = yday(date)
        , time = X3
        , latitude_n = X4
        , longitude_w = X5
        , max_wind_kt = as.numeric(X6)
        , landfall_state = X7
        , storm_name = X8) |>
  select(-starts_with("X")) |>
  filter(!is.na(date))

data.storms.clean |>
  group_by(year, storm_n) |>
  sample_n(1) |>
  ggplot(aes(x = date, y = doy, size = max_wind_speed)) +
  geom_point(alpha = 0.3) +
  scale_size(range = c(1, 10), limits = c(30, 60)) +
  scale_y_continuous(limits = c(0, 366)
                    , breaks = c(15.5, 43.5, 74.5, 104.5, 135.5, 165.5, 196.5, 227.5, 257.5, 288.5, 318.5, 349.5)
                    , labels = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')) +
  scale_x_date(date_breaks = "10 years", date_labels = "%Y")


data.hurricanes.raw <- read_html(url.hurricanes)
data.hurricanes.nodes <- html_nodes(data.hurricanes.raw, "table")
data.hurricanes.clean <- html_table(data.hurricanes.nodes, header = FALSE, convert = TRUE)[[3]] |>
  mutate(year = as.numeric(X1)
        , month = X2
        , states = X3
        , max_cat = as.numeric(X4)
        , pressure_central_mb = as.numeric(X5)
        , max_wind_kt = as.numeric(X6)
        , storm_name = str_replace_all(X7, "\"", "")) |>
  select(-starts_with("X")) |>
  filter(!is.na(year))

data.hurricanes.clean |>
  ggplot(aes(x = year, y = pressure_central_mb, size = max_cat, colour = max_cat, alpha = max_cat)) +
  geom_point() +
  scale_size(range = c(1, 10)) +
  scale_colour_gradient(low = "#0066ff", high = "#290115")
