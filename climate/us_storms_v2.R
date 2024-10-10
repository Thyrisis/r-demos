library(tidyverse)
 
url.hurdat2 <- "https://www.nhc.noaa.gov/data/hurdat/hurdat2-1851-2023-051124.txt"
data.raw <- read_csv(url.hurdat2, col_names = FALSE)
data.raw.storms <- data.raw |>
  filter(is.na(X4)) |>
  mutate(atcf_code = X1
        , name = X2
        , n_obs = as.numeric(X3)) |>
  select(-starts_with("X"))

data.raw.obs <- data.raw |>
  filter(!is.na(X4)) |>
  mutate(
    date = as_date(X1),
    time_utc = X2,
    datetime_utc = as_datetime(paste(X1, X2), format = "%Y%m%d %H%M"),
    codes = X3) |>
  separate(X4, c("status", "lat", "long", "wind_kts", "pressure_mbs", "rad_34kt_ne", "rad_34kt_se", "rad_34kt_sw", "rad_34kt_nw"
              , "rad_50kt_ne", "rad_50kt_se", "rad_50kt_sw", "rad_50kt_nw", "rad_64kt_ne", "rad_64kt_se", "rad_64kt_sw", "rad_64kt_nw")
          , sep = ","
          , convert = TRUE) |>
  mutate(across(starts_with("rad_"), ~ if_else(.x == -999, NA, .x))
        , pressure_mbs = if_else(pressure_mbs == -999, NA, pressure_mbs)
        , saffir_simpson = as.integer(case_when(wind_kts >= 64 & wind_kts <= 82 ~ 1
                                    , wind_kts >= 83 & wind_kts <= 95 ~ 2
                                    , wind_kts >= 96 & wind_kts <= 112 ~ 3
                                    , wind_kts >= 113 & wind_kts <= 136 ~ 4
                                    , wind_kts >= 137 ~ 5))) |>
  select(-starts_with("X"))

data.clean <- data.raw.storms |>
  slice(rep(1:n(), n_obs)) |>
  bind_cols(data.raw.obs)

data.raw.landfall <- data.clean |>
  filter(str_detect(codes, "L")) |>
  group_by(atcf_code) |>
  arrange(datetime_utc) |>
  select(atcf_code, wind_kts, pressure_mbs, saffir_simpson) |>
  rename(landfall_wind_kts = wind_kts
        , landfall_pressure_mbs = pressure_mbs
        , landfall_saffir_simpson = saffir_simpson
      ) |>
  sample_n(1)

data.clean.storms <- data.clean |>
  group_by(atcf_code, name) |>
  summarise(n_rows = n()
          , first_obs = min(datetime_utc)
          , first_obs_year = as.integer(year(min(datetime_utc)))
          , last_obs = max(datetime_utc)
          , max_wind_kts = as.integer(max(wind_kts, na.rm = TRUE))
          , min_pressure_mbs = as.integer(min(pressure_mbs, na.rm = TRUE))
          , max_saffir_simpson = as.integer(max(saffir_simpson, na.rm = TRUE))
        ) |>
  left_join(data.raw.landfall, by = "atcf_code") |>
  arrange(first_obs)


# BBC chart
data.clean.storms |>
  filter(first_obs >= as_date('1920-01-01')
        , max_saffir_simpson >= 3) |>
  ggplot(aes(x = first_obs, y = max_saffir_simpson, colour = as.factor(max_saffir_simpson))) +
  geom_point(position = position_jitter(), alpha = 0.5, size = 5) +
  scale_y_discrete() +
  bbplot::bbc_style()
