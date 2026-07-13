extends Resource
class_name Patient2Data

var answerSex: bool = true
var answerCount: int = 0
var answerAbnormality: int = 0

const CORRECT_SEX: bool = false      
const CORRECT_COUNT: int = 46       
const CORRECT_ABNORMALITY: int = 21  

func score() -> int:
	var points := 0
	if answerSex == CORRECT_SEX:
		points += 1
	if answerCount == CORRECT_COUNT:
		points += 1
	if answerAbnormality == CORRECT_ABNORMALITY:
		points += 1
	return points
