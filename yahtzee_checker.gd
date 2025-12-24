extends Node3D
class_name YahtzeeChecker

var ones: int = 0
var twos: int = 0
var threes: int = 0
var fours: int = 0
var fives: int = 0
var sixes: int = 0
var dice_results: Array[int] = []

func check_what_have(dice: Array[DieObject]) -> Array[int]:
	var output: Array[int] = []
	calculate_dice(dice)
	
	output.append(ones) # How many ones
	output.append(twos * 2) # How many twos
	output.append(threes * 3) # How many threes
	output.append(fours * 4) # How many fours
	output.append(fives * 5) # How many fives
	output.append(sixes * 6) # How many sixes
	
	output.append(calc_three_of_a_kind())
	output.append(calc_four_of_a_kind())
	output.append(calc_full_house())
	output.append(calc_sm_straight())
	output.append(calc_lg_straight())
	output.append(calc_yahtzee())
	
	output.append(sum_of_dice()) # chance
	
	return output

func calculate_dice(dice: Array[DieObject]):
	dice_results.clear()
	ones = 0
	twos = 0
	threes = 0
	fours = 0
	fives = 0
	sixes = 0
	for die in dice:
		match die.get_top_face():
			1: ones += 1
			2: twos += 1
			3: threes += 1
			4: fours += 1
			5: fives += 1
			6: sixes += 1
	
	dice_results.append(ones)
	dice_results.append(twos)
	dice_results.append(threes)
	dice_results.append(fours)
	dice_results.append(fives)
	dice_results.append(sixes)

func sum_of_dice() -> int:
	return (ones) + (twos * 2) + (threes * 3) + (fours * 4) + (fives * 5) + (sixes * 6)

func calc_three_of_a_kind() -> int:
	for index in dice_results.size():
		print(index)
		if dice_results[index] >= 3:
			return sum_of_dice()
	return 0

func calc_four_of_a_kind() -> int:
	for index in dice_results.size():
		if dice_results[index] >= 4:
			return sum_of_dice()
	return 0

func calc_full_house() -> int:
	var three: bool = false
	var two: bool = false
	for index in dice_results.size():
		if dice_results[index] == 3:
			three = true
		if dice_results[index] == 2:
			two = true
	
	if three and two:
		return 25
	else:
		return 0

func calc_sm_straight() -> int:
	if ones >= 1 and twos >= 1 and threes >= 1 and fours >= 1:
		return 30
	if twos >= 1 and threes >= 1 and fours >= 1 and fives >= 1:
		return 30
	if threes >= 1 and fours >= 1 and fives >= 1 and sixes >= 1:
		return 30
	
	return 0

func calc_lg_straight() -> int:
	if ones >= 1 and twos >= 1 and threes >= 1 and fours >= 1 and fives >= 1:
		return 40
	if twos >= 1 and threes >= 1 and fours >= 1 and fives >= 1 and sixes >= 1:
		return 40
	
	return 0

func calc_yahtzee() -> int:
	for num in dice_results:
		if num == 5:
			return 50
	return 0
