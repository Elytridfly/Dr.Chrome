extends Resource
class_name Patient3Data

var answer: Array = [0,0,0,0,0,0]
var CORRECT: Array = [0,1,1,0,1,0]


func score() -> int:
	var points := 0
	if answer[0] and answer[1]== CORRECT[0] and CORRECT[1]:
		points += 1
	if answer[2] and answer[3]== CORRECT[2] and CORRECT[3]:
		points += 1
	if answer[4] and answer[5]== CORRECT[4] and CORRECT[5]:
		points += 1
	return points
