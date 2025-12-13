def process_instructions(file_path):
    running_total = 50
    totals = []

    with open(file_path, "r") as file:
        for line_number, line in enumerate(file, start=1):
            line = line.strip()

            if not line:
                continue

            direction = line[0]
            amount = int(line[1:]) if len(line) > 1 else 0

            if direction == "R":
                running_total += amount
            elif direction == "L":
                running_total -= amount
            else:
                raise ValueError(
                    f"Invalid instruction '{line}' on line {line_number}"
                )

            # Wrap running total to range 0–99
            running_total = running_total % 100

            totals.append(running_total)

    return totals


if __name__ == "__main__":
    running_totals = process_instructions("instructions.txt")

    zero_count = running_totals.count(0)

    print(f"Running totals: {running_totals}")
    print(f"Number of times running total is 0: {zero_count}")