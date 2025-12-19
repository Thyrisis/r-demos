# Part 1
def read_input(input_file):
  outlist = []
  with open(input_file, "r") as file:
    for line_number, line in enumerate(file, start=1):
      line = line.strip()
      
      if not line:
        continue
      
      outlist.append(line)
      
  return outlist


# function to return default when index outside range (incl. override default negative index behaviour)
def idx_null(lst, idx, default='.'):
  if idx < 0:
    output = default
  else:
    try:
      output = lst[idx]
    except:
      output = default
  
  return output


# main
def process(input_lst):
  
  access_count = 0

  for row_n, row_val in enumerate(input_lst):
    for col_n, cell_val in enumerate(row_val):
      # ignore empty locations
      if cell_val == '.':
        continue

      # use custom function to handle beyond edges as always empty (".")
      # concatenate 8 surrounding values
      if (idx_null(idx_null(input_lst, row_n), col_n-1) +
          idx_null(idx_null(input_lst, row_n-1), col_n-1) +
          idx_null(idx_null(input_lst, row_n-1), col_n) +
          idx_null(idx_null(input_lst, row_n-1), col_n+1) +
          idx_null(idx_null(input_lst, row_n), col_n+1) +
          idx_null(idx_null(input_lst, row_n+1), col_n+1) +
          idx_null(idx_null(input_lst, row_n+1), col_n) +
          idx_null(idx_null(input_lst, row_n+1), col_n-1)
         ).count('@') < 4:
           access_count += 1
  
  return access_count
  

example = ["..@@.@@@@.","@@@.@.@.@@","@@@@@.@.@@","@.@@@@..@.","@@.@@@@.@@",".@@@@@@@.@",".@.@.@.@@@","@.@@@.@@@@",".@@@@@@@@.","@.@.@@@.@."]
input_file = read_input("advent-of-code-2025/day4-input.txt")

process(example)
process(input_file)


# part 2
def process2(input_lst):
  output_lst = input_lst

  for row_n, row_val in enumerate(input_lst):
    row_lst = list(row_val)

    for col_n, cell_val in enumerate(row_lst):
      # ignore empty locations
      if cell_val == '.':
        continue

      # use custom function to handle beyond edges as always empty (".")
      # concatenate 8 surrounding values
      
      if (idx_null(idx_null(input_lst, row_n), col_n-1) +
          idx_null(idx_null(input_lst, row_n-1), col_n-1) +
          idx_null(idx_null(input_lst, row_n-1), col_n) +
          idx_null(idx_null(input_lst, row_n-1), col_n+1) +
          idx_null(idx_null(input_lst, row_n), col_n+1) +
          idx_null(idx_null(input_lst, row_n+1), col_n+1) +
          idx_null(idx_null(input_lst, row_n+1), col_n) +
          idx_null(idx_null(input_lst, row_n+1), col_n-1)
         ).count('@') < 4:
           row_lst[col_n] = 'x'
           
    output_lst[row_n] = "".join(row_lst)
  
  return output_lst


process2(example)
