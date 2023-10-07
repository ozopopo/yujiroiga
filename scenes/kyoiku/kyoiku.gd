extends Node

var word_education:String = "教育教育"
var word_execution:String = "死刑死刑"
var word_count:int = 0

func _ready() -> void:
	$AudioStreamPlayer.connect("finished", $AudioStreamPlayer.play)
	$AudioStreamPlayer.play()
	return

func _process(_delta:float) -> void:
	if word_count <= 100 || 250 < word_count:
		$Characters.text += word_education
		pass
	if 100 < word_count && word_count <= 250:
		$Characters.text += word_execution
		pass
	if 360 < word_count:
		get_tree().quit()
		pass
	word_count += 1
	return
