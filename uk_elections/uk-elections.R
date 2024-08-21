#install.packages("sf")
library("sf")
library("tidyverse")

# get election data
url <- "https://researchbriefings.files.parliament.uk/documents/CBP-8647/1918-2019election_results.csv"

# url <- 
# "http://www.electoralcommission.org.uk/__data/assets/excel_doc/0011/191648/UKPGE-turnout-postal-rejected-admin-amended-WEB.xlsx"
# url <- "https://researchbriefings.files.parliament.uk/documents/CBP-7979/HoC-GE2017-results-by-candidate.csv"
# url <- "https://researchbriefings.files.parliament.uk/documents/CBP-8749/HoC-GE2019-results-by-candidate.csv"
# url <- "https://researchbriefings.files.parliament.uk/documents/CBP-10009/HoC-GE2024-results-by-candidate.csv"
file <- "./uk_elections/HoC-GE2017-results-by-candidate.csv"
#file <- "./uk_elections/HoC-GE2019-results-by-candidate.csv"

#data.raw <- read_csv(url) # 403 Forbidden - WTF?
data.raw <- read_csv(file)

# define tracked parties and colours
tracked_parties = c('Con', 'Lab', 'LD', 'Green', 'UKIP', 'PC', 'SNP', 'SF', 'DUP', 'SDLP', 'APNI', 'Reform')
tracked_parties_colours = c('#0087DC', '#E4003B', '#FAA61A', '#02A95B', '#6D3177', '#005B54', '#FDF38E', '#326760', '#D46A4C', '#2AA82C', '#F6CB2F', '#12B6CF')
scale_colour_party <- function(...) {ggplot2:::manual_scale('colour', values = setNames(tracked_parties_colours, tracked_parties), ...)}
scale_fill_party <- function(...) {ggplot2:::manual_scale('colour', values = setNames(tracked_parties_colours, tracked_parties), ...)}

data.clean <- data.raw |>
  janitor::clean_names() |>
  mutate(party_group = if_else(party_abbreviation %in% tracked_parties, party_abbreviation, 'Oth'))

winners <- data.clean |>
  select(-c(ons_region_id, constituency_name, constituency_type, electoral_commission_party_id, electoral_commission_adjunct_party_id
            , mnis_party_id, county_name, region_name, country_name, party_abbreviation, member_mnis_id, party_group)) |>
  group_by(ons_id) |>
  arrange(desc(votes)) |>
  slice_head(n = 1) |>
  rename(winner_first_name = candidate_first_name
         , winner_surname = candidate_surname
         , winner_gender = candidate_gender
         , winner_party_name = party_name
         , winner_sitting_mp = sitting_mp
         , winner_former_mp = former_mp
         , winner_votes = votes
         , winner_share = share
         , winner_change = change)

constituencies <- data.clean |>
  group_by(ons_id, ons_region_id, constituency_name, county_name, region_name, country_name, party_group) |>
  summarise(votes = sum(votes)
            , share = sum(share)) |>
  pivot_wider(id_cols = c(ons_id, ons_region_id, constituency_name, county_name, region_name, country_name)
              , names_from = party_group
              , values_from = c(votes, share)) |>
  left_join(winners, by = "ons_id")

# quick chart
data.clean |>
  left_join(winners, by = "ons_id") |>
  ggplot(aes(x = region_name, y = share, colour = party_group)) +
  geom_point(position = "jitter", alpha = 0.5) +
  facet_wrap(~region_name, scales = "free_x") +
  scale_colour_party() +
  #labs(title = "2019 UK General Election")
  labs(title = "2024 UK General Election")

# share of contested
contested <- constituencies |>
  mutate(across(.cols = starts_with("votes_")
                , .fns = ~if_else(. > 0, 1, 0)
                , .names = "cont_{.col}")) |>
  group_by(across(starts_with("cont_"))) |>
  summarise(across(.cols = starts_with("votes_")
                  , .fns = ~sum(.x, na.rm = TRUE))) |>
  ungroup()

contested |>
  filter(cont_votes_SNP == 1) |>
  summarise(across(.cols = starts_with("votes"), .fns = ~sum(.x, na.rm = TRUE))) |>
  rowwise() |>
  mutate(total_votes = sum(across(everything()))
        , pct_votes = votes_SNP / total_votes) |>
  select(votes_SNP, total_votes, pct_votes)


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

# initial exploration
data.clean |> janitor::tabyl(election, winner)

data.clean |>
  filter(is.na(winner)) |> View()

data.clean |> janitor::tabyl(election, boundary_set)

data.raw |>
  filter(election == 2019) |>
  group_by(`country/region`) |>
  summarise(electorate = sum(electorate, na.rm = TRUE)
, con_votes = sum(con_votes, na.rm = TRUE)
, lib_votes = sum(lib_votes, na.rm = TRUE)
, lab_votes = sum(lab_votes, na.rm = TRUE)
, natSW_votes = sum(natSW_votes, na.rm = TRUE)
, oth_votes = sum(oth_votes, na.rm = TRUE))

constituencies |>
  filter(winner_party_name == 'Conservative') |>
  arrange(desc(winner_share)) |>
  #select(ons_id, constituency_name, winner_first_name, winner_surname, winner_share) |>
  head(50) |>
  ungroup() |>
  summarise(min(winner_share))

# get shapes

