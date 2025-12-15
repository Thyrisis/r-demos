library(tidyverse)

input <- read_fwf("advent-of-code-2025/day1-input.txt")

start_idx = 50

output <- input |>
  mutate(movement = as.integer(str_sub(X1,2,3)),
         movement = if_else(str_sub(X1,1,1) == 'L', movement * -1, movement),
         position = accumulate(movement, ~ .x + movement, .init = start_idx)[-1])




# Example tibble
df <- tibble(
  id = 1:6,
  x  = c(10, 12, 8, 15, 14, 20)
)

# Compute y using previous x (non-recursive)
df %>%
  mutate(
    y = 0.7 * lag(x, default = first(x)) + 5
  )