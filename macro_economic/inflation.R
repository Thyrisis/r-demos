library(tidyverse)
#install.packages("janitor")
library(janitor)
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 3)

url <- "https://www.ons.gov.uk/file?uri=/economy/inflationandpriceindices/datasets/consumerpriceindices/current/mm23.csv"

data.raw <- read_csv(url)

data.clean <- data.raw |>
  filter(str_detect(Title, "^[0-9]{4} [A-Z]{3}")) |>
  janitor::clean_names() |>
  mutate(ons_month = as_date(paste(title, '01')), across(c(starts_with("cpi"), starts_with("rpi")), as.numeric))

# list of available vars
vars <- names(data.clean)

plot_vars <- c("rpi_all_items_index_jan_1987_100"
              , "cpih_12mth_food_alcoholic_beverages_tobacco_g_2015_100"
              , "cpih_12mth_energy_g_2015_100")

data.clean |>
  select(ons_month, all_of(plot_vars)) |>
  pivot_longer(plot_vars) |>
  filter(!is.na(value)) |>
  ggplot(aes(x = ons_month, y = value, colour = name)) +
  geom_line() +
  geom_hline(yintercept = 0) +
  facet_wrap(vars(name), scales = "free_y") +
  theme(legend.position = "none")
