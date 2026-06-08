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
@onready var Life1 = $UI/Life1
@onready var Life2 = $UI/Life2
@onready var Life3 = $UI/Life3

var items: Array
var item: Dictionary
var index_item: int = 0
var wrong: int = 0
var correct: int = 0
var updatedCorrectAnswerIndex: int
var lives: int = 3
var highscore: int = SaveManager.loadScore()
var timerRunning: bool
var timerWait: float = 30.0

func _ready():
	items = read_json_file("res://assets/texts/questions.json")
	items.shuffle()
	displayScore()
	Life1.play("default")
	Life2.play("default")
	Life3.play("default")
	$VirusSprite.play("walk")
	$PlayerSprite.play("default")
	Result.hide()
	prepareCutscene()
	cutsceneStartQuestion()

func displayScore():
	WrongNumber.text = "Wrong: " + str(wrong)
	ScoreNumber.text = "Score: " + str(correct) #+"/"+str(items.size())

func show_questions():
	CorrectAnswer.hide()
	OKButton.hide()
	Congratulation.hide()
	AnswersList.show()
	QuestionImage.show()
	ScoreNumber.show()
	RestartButton.hide()
	AnswersList.clear()
	QuestionItems.show()
	$UI/TimerBar.show()
	$UI/Timer.start(timerWait)
	timerRunning = true
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
	print(correctAnswer)
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
	timerWait -= 0.2
	if timerWait < 1:
		timerWait = 1
	print(timerWait)
	$AudioMusic.pitch_scale = (30-timerWait)/80 + 1
	
	index_item +=1
	##if index_item >= items.size():
		##show_result()
	if index_item >= items.size():
		index_item = 0
		items = read_json_file("res://assets/texts/questions.json")
		items.shuffle()
	if lives == 0:
		gameOver()
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
	prepareCutscene()
	lives = lives - 1
	if lives == 2:
		Life3.play("lost")
	else: if lives == 1:
		Life2.play("lost")
	else:
		Life1.play("lost")
	AnimPlay.play("Answer_Wrong")
	$VirusSprite.play("walk")
	await AnimPlay.animation_finished
	displayScore()
	refresh_scene()

func show_congratulations():
	prepareCutscene()
	AnimPlay.play("Answer_Correct")
	$VirusSprite.play("walk")
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
	$UI/TimerBar.hide()
	timerRunning = false


func cutsceneStartQuestion():
	AnimPlay.play("Wait")
	await AnimPlay.animation_finished
	AnimPlay.play("Question_Start")
	await AnimPlay.animation_finished
	show_questions()


func gameOver():
	AnimPlay.play("GameOver")
	await AnimPlay.animation_finished
	prepareCutscene()
	if correct > highscore:
		highscore = correct
		SaveManager.saveScore(highscore)
		QuestionItems.text = "New High Score!\nYour Score: {score}".format({"score": correct})
		$AudioMusic.play()
	else:
		QuestionItems.text = "Game Over.\nYour Score: {score}\nHigh Score: {high}".format({"score": correct, "high": highscore})
	QuestionItems.show()
	RestartButton.show()


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



func _process(_delta):
	if Input.is_action_pressed("debug_kill"):
		lives = 1
		print("kill")
	
	if Input.is_action_pressed("debug_correct"):
		correct += 1
		show_congratulations()
	
	#Timer Code
	if($UI/Timer.time_left >= 0):
		$UI/TimerBar.value = ($UI/Timer.time_left / $UI/Timer.wait_time)*100
	if ($UI/Timer.time_left <= 0 && timerRunning):
		show_failure()
