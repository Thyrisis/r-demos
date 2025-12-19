# Common
def read_input(input_file):
  outlist = []
  with open(input_file, "r") as file:
    for line_number, line in enumerate(file, start=1):
      line = line.strip()
      
      if not line:
        continue
      
      outlist.append(line)
      
  return outlist

example = ["3-5","10-14","16-20","12-18","","1","5","8","11","17","32"]
input_file = read_input("advent-of-code-2025/day5-input.txt")

# Part 1
def process(input_lst):
  # there's always one and exactly one blank line breaking fresh ranges from IDs so find it
  break_point = input_lst.index("")
  
  # read fresh ranges first
  fresh_rng = input_lst[:break_point]
  
  # now read inventory IDs
  inv_id = input_lst[break_point+1:]
  
  # loop through the fresh ranges
  for fresh_id, fresh_val in enumerate(fresh_rng):
    for range_val in range(fresh_val.split('-')[0], fresh_val.split('-')[1]):
      range_val
  
  return fresh_rng, inv_id

  
process(example)
  
