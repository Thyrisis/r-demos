def process_instructions(file_path):
  running_total = 50
  totals = []
  inline_zeros = 0

  with open(file_path, "r") as file:
    for line_number, line in enumerate(file, start=1):
      line = line.strip()

      if not line:
        continue

      direction = line[0]
      amount = int(line[1:]) if len(line) > 1 else 0

      # assign reversal factor
      if direction == "R":
        reversal_factor = 0
      elif direction == "L":
        reversal_factor = 100
      else:
        raise ValueError(f"Invalid instruction '{line}' on line {line_number}")

      # apply reversal factor
      current_total = abs(reversal_factor - running_total) % 100
      #print(f"before inline zeros calc - running_total:{running_total} inline_zeros:{inline_zeros} current_total:{current_total} direction: {direction} amount:{amount}")

      # detect passing 0 but exclude landing on 0
      inline_zeros += int((current_total + amount) / 100) - ((current_total + amount) % 100 == 0)
      #print(f"after inline zeros calc - inline_zeros:{inline_zeros} current_total:{current_total}")
      
      # move the dial
      current_total += amount
      #print(f"after move the dial - inline_zeros:{inline_zeros} current_total:{current_total}")
      
      # Wrap running total to range 0–99
      current_total = current_total % 100

      # de-apply reversal factor
      running_total = abs(reversal_factor - current_total) % 100

      #print(f"direction:{direction}, amount:{amount}, running_total:{running_total}, inline_zeros:{inline_zeros}")
  
      totals.append(running_total)

    return (totals, inline_zeros)


running_totals = process_instructions("advent-of-code-2025/day1-input.txt")

zero_count = running_totals[0].count(0)
zero_count_incl_inline = zero_count + running_totals[1]

print(f"Running totals: {running_totals}[0]")
print(f"Number of times running total is 0: {zero_count}")
print(f"Number of times 0 or passed 0: {zero_count_incl_inline}")

#5736 too low
#9216 too high
