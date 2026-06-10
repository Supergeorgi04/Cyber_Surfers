extends Node

var persistentData: Dictionary = {
	"highScore": 0
}

# Called when the node enters the scene tree for the first time.
func saveScore(score: int):
	persistentData = {"highScore": score}
	print(persistentData)

func loadScore():
	return persistentData.get("highScore")
