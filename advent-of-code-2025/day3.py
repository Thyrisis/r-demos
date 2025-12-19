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

def process(input_list):
  
  # initialise max_jolts_total
  max_jolts_total = 0
  
  # process each row in turn
  for list_pos, list_val in enumerate(input_list):

    # start with first two items
    max_jolts_row = list_val[0:2]

    # convert row to int array
    #int_list = [int(list_val[i:i+1]) for i in range(0, len(list_val))]
    
    # work down array to construct 2 digit possibilities
    for n, i in enumerate(list_val):
      for j in list_val[n+1:]:
        if i+j > max_jolts_row:
          max_jolts_row = i+j

    max_jolts_total += int(max_jolts_row)
    
    #print(f"list_val:{list_val}, max_jolts_row:{max_jolts_row}")
    
  return max_jolts_total

example = ["987654321111111","811111111111119","234234234234278","818181911112111"]
input_file = read_input("advent-of-code-2025/day3-input.txt")

process(example)
process(input_file)

# Part 2
def get_n_sequential_peaks(input_string, n_peaks):

    results = []
    current_start = 0
    total_len = len(input_string)
    
    for i in range(n_peaks):
        # Calculate how many more peaks we need after this one
        remaining_needed = n_peaks - (i + 1)
        
        # The search must end early enough to leave 'remaining_needed' characters
        search_end = total_len - remaining_needed
        
        if current_start >= search_end:
            break
            
        # Slice the string for the valid search range
        search_range = input_string[current_start:search_end]
        
        if not search_range:
            break

        # Find the max in the range but keep idx relative to the original string
        pos, val = max(enumerate(search_range, start=current_start), key=lambda x: x[1])
        
        results.append(val)
        
        # Next search starts immediately after the current peak's position
        current_start = pos + 1
            
    return results


def process2(input_lst, out_str_lgth=12):

  # initialise max_jolts_total
  max_jolts_total = 0

  # process each row in turn
  for lst_pos, lst_val in enumerate(input_lst):
    
    high_lst = get_n_sequential_peaks(lst_val, out_str_lgth)
    high_val = int(''.join(high_lst))
    
    max_jolts_total += high_val
    
  return max_jolts_total

    
process2(example, 2)
process2(input_file, 2)
process2(example, 12)
process2(input_file, 12)
