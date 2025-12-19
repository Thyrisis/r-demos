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
  
def process(ranges_str):
  # initialise invalid_count
  invalid_count = 0

  # separate by commas
  range_list = ranges_str.split(",")
  
  for list_n, list_val in enumerate(range_list):

    # identify range    
    range_start = int(list_val.split("-")[0])
    range_end = int(list_val.split("-")[1])
    #print(f"list_n:{list_n}, list_val:{list_val}, range_start:{range_start}, range_end:{range_end}")
    
    for i in range(range_start, range_end+1):
      str_i = str(i)
      str_i_len = len(str_i)
      
      # can only be invalid ID if len is even
      if str_i_len % 2 != 0:
        continue
    
      # is first half of str_i == str_i?
      str_i_h1 = str_i[:int(str_i_len/2)]
      str_i_h2 = str_i[int(str_i_len/2):]
      
      if str_i_h1 == str_i_h2:
        invalid_count += i
        #print(f"invalid ID:{str_i}")
  
  return invalid_count
  
example = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
input_file = read_input("advent-of-code-2025/day2-input.txt")

process(example)
process(input_file[0])

# Part 2
def process2(ranges_str):
  # initialise invalid_count
  invalid_sum = 0

  # separate by commas
  range_list = ranges_str.split(",")
  
  for list_n, list_val in enumerate(range_list):

    # identify range    
    range_start = int(list_val.split("-")[0])
    range_end = int(list_val.split("-")[1])
    #print(f"list_n:{list_n}, list_val:{list_val}, range_start:{range_start}, range_end:{range_end}")
    
    for i in range(range_start, range_end+1):
      str_i = str(i)
      str_i_len = len(str_i)
      
      # check 1:str_i_len for repeats and only repeats, on hit increment invalid_sum and break
      for j in range(1, int(str_i_len / 2)+1):
        str_list = [str_i[k:k+j] for k in range(0, str_i_len, j)]
        if all(l == str_list[0] for l in str_list):
          invalid_sum += i
          #print(f"list_val:{list_val} str_i:{str_i}")
          break # exit the loop when we know it's an invalid ID

  return invalid_sum
  
process2(example)
process2(input_file[0])

# 34826702005 too low
