install.packages("sf")
library("sf")
library("tidyverse")

# get election data
url <- "https://researchbriefings.files.parliament.uk/documents/CBP-8647/1918-2019election_results.csv"

data.raw <- read_csv(url)

# clean data
winner <- data.raw |>
  filter(total_votes > 0) |>
  select(election, constituency_name, c(con_votes, lib_votes, lab_votes, natSW_votes, oth_votes)) |>
  pivot_longer(cols = c(con_votes, lib_votes, lab_votes, natSW_votes, oth_votes)) |>
  group_by(election, constituency_name) |>
  slice(which.max(value)) |>
  mutate(winner = str_sub(name, 1, str_locate(name, "_")[1] - 1)) |>
  select(-name)

data.clean <- data.raw |>
  left_join(winner, by = c("election", "constituency_name"))

data.clean |> janitor::tabyl(election, winner)
# initial exploration
data.raw |> janitor::tabyl(election, boundary_set)

data.raw |>
  filter(election == 2019) |>
  group_by(`country/region`) |>
  summarise(electorate = sum(electorate, na.rm = TRUE)
, con_votes = sum(con_votes, na.rm = TRUE)
, lib_votes = sum(lib_votes, na.rm = TRUE)
, lab_votes = sum(lab_votes, na.rm = TRUE)
, natSW_votes = sum(natSW_votes, na.rm = TRUE)
, oth_votes = sum(oth_votes, na.rm = TRUE))

# get shapes

