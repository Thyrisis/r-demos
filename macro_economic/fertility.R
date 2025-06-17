#install.packages("tidyverse")
library(tidyverse)

births.raw <- read_fwf("macro_economic/births/birthsRR.txt"
                        , skip = 3
                        , col_positions = fwf_positions(start = c(1, 9, 17, 22)
                                                        , end = c(7, 12, 19, 32)
                                                        , col_names = c("country_code"
                                                                        , "year"
                                                                        , "age"
                                                                        , "total")))

top_10 <- births.raw |>
    group_by(country_code) |>
    summarise(total = sum(total)) |>
    arrange(desc(total)) |>
    head(10) |>
    pull(country_code)

births.raw |>
    filter(country_code %in% top_10) |>
    group_by(country_code, year) |>
    summarise(total = sum(total)) |>
    ggplot(aes(x = year, y = total, colour = country_code)) +
    geom_line()
