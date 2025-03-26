library(tidyverse)

# get list of country files
root <- "../ddf--gapminder--population"
fldr <- paste0(root, "/ddf--datapoints--population--by--country--age--gender--year")
files <- list.files(path = fldr, full.names = TRUE, pattern = "*.csv")

# read all country files
data.raw <- files |>
    map_dfr(read_csv)

# read country code lookups
cntry <- read_csv(paste0(root, "/ddf--entities--geo--country.csv"))

# identify top 5 in each region
top5s <- data.clean |>
    group_by(world_4region, name) |>
    summarise(pop = sum(population)) |>
    arrange(desc(pop)) |>
    group_by(world_4region) |>
    slice_head(n = 5) |>
    pull(name)

# clean data
data.clean <- data.raw |>
    left_join(cntry, by = "country") |>
    mutate(top5g = if_else(name %in% top5s, name, "Other"))

# initial investigations
data.raw |> janitor::tabyl(country)
data.clean |> janitor::tabyl(world_6region)
data.clean |> janitor::tabyl(unhcr_region)
data.clean |> janitor::tabyl(name)

# summaries
data.sum <- data.clean |>
    group_by(world_4region, top5g, year) |>
    summarise(pop = sum(population))

data.sum |>
    ggplot(aes(x = year, y = pop, colour = top5g, label = top5g)) +
    geom_line() +
    geom_text(data = data.sum |> filter(year == max(year)), size = 3) +
    geom_vline(xintercept = 2025) +
    facet_wrap(vars(world_4region), scales = "free_y") +
    theme(legend.position = "none")
