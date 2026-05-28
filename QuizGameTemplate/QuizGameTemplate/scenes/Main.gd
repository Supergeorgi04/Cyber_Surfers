extends Control

@onready var QuestionItems = $UI/VBoxContainer/PanelContainer/QuestionTexts
@onready var AnswersList = $UI/AnswersList
@onready var QuestionImage = $UI/ImageRect
@onready var RestartButton = $UI/RestartButton
@onready var RestartButtonAlways = $UI/RestartButtonAlways
@onready var WrongNumber = $UI/WrongNumber
@onready var ScoreNumber = $UI/ScoreNumber
@onready var CorrectAnswer = $UI/CorrectAnswer
@onready var OKButton = $UI/OK
@onready var Congratulation = $UI/Correct
@onready var Result = $UI/Result
@onready var AnimPlay = $AnimationPlayer

var items: Array
var item: Dictionary
var index_item: int = 0
var wrong: int = 0
var correct: float = 0
var updatedCorrectAnswerIndex: int

func _ready():
	items = read_json_file("res://assets/texts/questions.json")
	items.shuffle()
	displayScore()
	Result.hide()
	prepareCutscene()
	cutsceneStartQuestion()

func displayScore():
	WrongNumber.text = "Wrong: " + str(wrong)
	ScoreNumber.text = "Score: " + str(int(correct)) #+"/"+str(items.size())

func show_questions():
	CorrectAnswer.hide()
	OKButton.hide()
	Congratulation.hide()
	AnswersList.show()
	QuestionImage.show()
	ScoreNumber.show()
	RestartButton.hide()
	AnswersList.clear()
	#WrongNumber.show()
	QuestionItems.show()
	item = items[index_item]
	QuestionItems.text = item.question
	QuestionImage.texture = load(item.imagePath)
	var options = item.options
	var correctAnswer = item.options[item.correctOptionIndex]
	options.shuffle()
	for option in options:
		if option == correctAnswer:
			updatedCorrectAnswerIndex = options.find(option,0)
	print(options)
	for option in options:
		AnswersList.add_item(option)

func show_result():
	displayScore()
	AnswersList.hide()
	Congratulation.hide()
	QuestionImage.hide()
	CorrectAnswer.hide()
	OKButton.hide()
	RestartButton.show()
	RestartButtonAlways.hide()
	WrongNumber.show()
	ScoreNumber.show()
	
	var percentage = round(correct/items.size()*100)
	var greet
	if percentage >= 60:
		greet = "Very good!"
	else:
		greet = "Too bad!"
	QuestionItems.text = "{greet} You're correct {percentage} %".format({"greet": greet, "percentage": percentage})

func refresh_scene():
	index_item +=1
	if index_item >= items.size():
		show_result()
	else:
		AnimPlay.play("Resume")
		await AnimPlay.animation_finished
		prepareCutscene()
		cutsceneStartQuestion()

func read_json_file(filename):
	var json_as_text = FileAccess.get_file_as_string(filename)
	var json_as_dict = JSON.parse_string(json_as_text)
	return json_as_dict

func show_failure():
	"""AnswersList.hide()
	ScoreNumber.show()
	RestartButton.hide()
	QuestionImage.show()
	CorrectAnswer.show()
	OKButton.show()
	Congratulation.hide()
	WrongNumber.show()
	item = items[index_item]
	CorrectAnswer.text = "The correct answer is: " + item.options[updatedCorrectAnswerIndex]"""
	prepareCutscene()
	AnimPlay.play("Answer_Wrong")
	await AnimPlay.animation_finished
	displayScore()
	refresh_scene()

func show_congratulations():
	"""AnswersList.hide()
	ScoreNumber.show()
	RestartButton.hide()
	QuestionImage.hide()
	CorrectAnswer.show()
	OKButton.hide()
	Congratulation.show()
	WrongNumber.show()
	item = items[index_item]
	CorrectAnswer.text = "The correct answer is: " + item.options[updatedCorrectAnswerIndex]"""
	prepareCutscene()
	AnimPlay.play("Answer_Correct")
	await AnimPlay.animation_finished
	displayScore()
	refresh_scene()

func prepareCutscene():
	AnswersList.hide()
	Congratulation.hide()
	QuestionImage.hide()
	CorrectAnswer.hide()
	OKButton.hide()
	RestartButton.hide()
	RestartButtonAlways.hide()
	QuestionItems.hide()
	WrongNumber.hide()
	ScoreNumber.show()


func cutsceneStartQuestion():
	AnimPlay.play("Wait")
	await AnimPlay.animation_finished
	AnimPlay.play("Question_Start")
	await AnimPlay.animation_finished
	show_questions()



func _on_ok_pressed():
	index_item +=1
	refresh_scene()

func _on_correct_pressed():
	index_item +=1
	refresh_scene()

func _on_answers_list_item_selected(index):
	if index == updatedCorrectAnswerIndex:
		correct +=1
		show_congratulations()
	else:
		wrong +=1
		show_failure()
		
func _on_restart_button_pressed():
	get_tree().reload_current_scene()
