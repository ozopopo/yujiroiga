extends Node

@onready var game_timer:Timer = $GameTimer

var score:int = 0
var time:int = 0

var car_hit:int = 0
var kusa_killed:int = 0
var tree_killed:int = 0
var last_josouzai_summond_area:int = randi_range(0,1)

const CAMERA_LIMIT_MIN_X:int = -532 
const CAMERA_LIMIT_MIN_Y:int = -250
const CAMERA_LIMIT_MAX_X:int = 532
const CAMERA_LIMIT_MAX_Y:int = 3


func set_gairoju(type:int) -> void:
	var type_names:Array = ["kusa", "ki", "kusa", "kusa"]
	
	var gairoju = ResourceLoader.load("res://"+type_names[type]+".tscn").instantiate()
	
	var random_gairoju_area:int = randi_range(0,4)
	var gairoju_area_marker_pos0:Vector2 = $Gairojus.get_node("Gairoju%d0" % [random_gairoju_area]).position
	var gairoju_area_marker_pos1:Vector2 = $Gairojus.get_node("Gairoju%d1" % [random_gairoju_area]).position
	
	gairoju.position.x = randf_range(gairoju_area_marker_pos0.x,gairoju_area_marker_pos1.x)
	gairoju.position.y = randf_range(gairoju_area_marker_pos0.y,gairoju_area_marker_pos1.y)	
	
	if type == 0:
		gairoju.health = randi_range(50,100)
	elif type == 1:
		gairoju.health = randi_range(100,150)
	
	gairoju.connect("ATTACKED", _on_gairoju_attacked)
	gairoju.connect("KILLED", _on_gairoju_killed)
	
	$Gairojus.add_child(gairoju)
	return

func _ready() -> void:
	for i in range(30):
		set_gairoju( randi_range(0,3) )
	
	var ambient_sound:AudioStreamPlayer = $AmbientSound
	$Ui.hide()
	ambient_sound.play()
	ambient_sound.connect("finished", ambient_sound.play)
	$Ready.show()
	$Ready.start()
	$Player.moveable = false
	return

func _process(delta:float) -> void:
	update_ui()
	if Input.is_action_just_pressed("pause") && time > 1:
		$Ui/ColorRect.hide()
		show_pause_ui()
		get_tree().paused = true
	return

func show_pause_ui() -> void:
	$Ui/PauseUi.show()
	$OpenMenuSound.play()
	return

func update_ui() -> void:
	if time <= 5:
		$Ui/ColorRect/GameInfo/Score/Score.text = "??????"
	else:
		$Ui/ColorRect/GameInfo/Score/Score.text = "%06d" % [clamp(score, 0, 999999)]
		
	$Ui/ColorRect/GameInfo/Time/Timer.text = "%02d:%02d" % [int((time%3600)/60), int(time%60)]
	$Ui/ColorRect/JosouzaiInfo/JosouzaiUsage/Josouzai.text = "%d%%" % [$Player.attackHealthRatio]
	return
	
func game_finish() -> void:
	$Player.moveable = false
	for car in $Cars.get_children():
		car.queue_free()
	$FinishSound.play()
	set_result_ui()
	return
	
func _on_finish_sound_finished() -> void:
	print("finish sound finished")
	var tween:Tween = create_tween()
	tween.tween_property($Ui/ColorRect2, "modulate", Color(1,1,1,1), 5)
	tween.connect("finished", enable_title_buttons)
	return

func enable_title_buttons() -> void:
	%RetryButton.disabled = false
	%SaveScoreButton.disabled = !Settings.is_login || (score < 0 || 999999 < score || score % 10 != 0)
	%BackToTheTitleButton.disabled = false
	%RetryButton.grab_focus()
	return
	
func set_result_ui() -> void:
	
	%ResultScore.text = "%06d" % [score]
	%ResultDetailKusa.text = "%d" % [kusa_killed]
	%ResultDetailTree.text = "%d" % [tree_killed]
	%ResultDetailCar.text = "%d" % [car_hit]
	
	if Settings.is_login:
		$Ui/ColorRect2/ResultUi/VBoxContainer/HBoxContainer.show()
		$Ui/ColorRect2/ResultUi/HBoxContainer/VSeparator.show()
		$Ui/ColorRect2/ResultUi/HBoxContainer/VBoxContainer3.show()
		var current_user_data:Dictionary = Settings.get_current_user_data()
		%YourCurrentScore.text = "%06d" % [current_user_data.score]
		%CurrentKusa.text = "%d" % [current_user_data.grass]
		%CurrentTree.text = "%d" % [current_user_data.tree]
		%CurrentCar.text = "%d" % [current_user_data.car]
		
		if current_user_data.car == 0 && current_user_data.score != 0:
			%CurrentCarLabel.label_settings.font_color = Color.YELLOW
			%CurrentCar.label_settings.font_color = Color.YELLOW
		else:
			%CurrentCarLabel.label_settings.font_color = Color.WHITE
			%CurrentCar.label_settings.font_color = Color.WHITE
	else:
		$Ui/ColorRect2/ResultUi/VBoxContainer/HBoxContainer.hide()
		$Ui/ColorRect2/ResultUi/HBoxContainer/VSeparator.hide()
		$Ui/ColorRect2/ResultUi/HBoxContainer/VBoxContainer3.hide()

	if car_hit == 0:
		%ResultDetailCarLabel.label_settings.font_color = Color.YELLOW
		%ResultDetailCar.label_settings.font_color = Color.YELLOW
	elif car_hit > 10:
		%ResultDetailCarLabel.label_settings.font_color = Color.RED
		%ResultDetailCar.label_settings.font_color = Color.RED
	else:
		%ResultDetailCarLabel.label_settings.font_color = Color.WHITE
		%ResultDetailCar.label_settings.font_color = Color.WHITE

	$Ui/ColorRect2.modulate = Color(1,1,1,0)
	$Ui/ColorRect.hide()
	$Ui/ColorRect2.show()
	return
	
func try_to_save_data() -> void:
	if !Settings.is_login:
		return
	Settings.save({
		"score": score,
		"grass": kusa_killed,
		"tree": tree_killed,
		"car": car_hit
	})
	return

func _physics_process(delta:float) -> void:
	$Camera2D.position.x = clamp($Player.position.x, CAMERA_LIMIT_MIN_X, CAMERA_LIMIT_MAX_X)
	$Camera2D.position.y = clamp($Player.position.y, CAMERA_LIMIT_MIN_Y, CAMERA_LIMIT_MAX_Y)	
	$Ui.transform = $Camera2D.transform
	return


func _on_gairoju_attacked(type:int) -> void:
	if time > 0:
		match type:
			0:
				score += 10
			1:
				score += 20
	return

func _on_gairoju_killed(type:int) -> void:
	if time > 0:
		match type:
			0:
				kusa_killed += 1
				score += 1000
			1:
				tree_killed += 1
				score += 2000
		set_gairoju(randi_range(0,3))
	return

func _on_back_to_the_title_button_pressed() -> void:
	set_physics_process(false)
	set_process(false)
	get_tree().paused = false
	get_node("../")._change_scene("Title")
	return
	
func _on_save_score_button_pressed() -> void:
	try_to_save_data()
	%SaveScoreButton.disabled = true
	%SaveScoreButton.text = "保存しました"
	%YourCurrentScore.text = "%06d" % [score]
	%CurrentKusa.text = "%d" % [kusa_killed]
	%CurrentTree.text = "%d" % [tree_killed]
	%CurrentCar.text = "%d" % [car_hit]
	
	if car_hit == 0:
		%CurrentCarLabel.label_settings.font_color = Color.YELLOW
		%CurrentCar.label_settings.font_color = Color.YELLOW
	else:
		%CurrentCarLabel.label_settings.font_color = Color.WHITE
		%CurrentCar.label_settings.font_color = Color.WHITE
	return

func _on_retry_button_pressed() -> void:
	set_physics_process(false)
	set_process(false)
	get_node("../")._change_scene("Play")
	return


func _on_ready_finished() -> void:
	$Player.moveable = true
	$Cars/CarsSummonTimer.start(0.1)
	$Ui.show()
	$Ui/ColorRect.show()
	$Ui/ColorRect2.hide()
	$Ui/PauseUi.hide()
	$Josouzais/JosouzaiSummonTimer.start(10)
	score = 0
	time = 60
	game_timer.start(1)
	return

func _on_game_timer_timeout():

	if time > 0:
		time -= 1
		game_timer.start(1)
	elif time == 0:
		print("fini!H!!!!")
		game_timer.stop()
		game_finish()
	return


func _on_cars_summon_timer_timeout() -> void:
	if time > 0:
		var car = ResourceLoader.load("res://car.tscn").instantiate()
		var car_random_pos:int = randi_range(0,5)
		car.speed = randf_range(2,6)
		if car_random_pos % 2 == 0:
			car.move_dir = Vector2(1,0)
		else:
			car.move_dir = Vector2(-1,0)
		car.position = $Cars.get_node("CarSummonPos%d" % [car_random_pos]).position
		
		$Cars.add_child(car)
		$Cars/CarsSummonTimer.start( randf_range(0.5, 1) )
	return


func _on_josouzai_summon_timer_timeout() -> void:
	if time > 0:
		var josouzai = ResourceLoader.load("res://josouzai.tscn").instantiate()
		var josouzai_summon_area:int = int(last_josouzai_summond_area == 0)
		var josouzai_summon_area_pos0:Vector2 = $Josouzais.get_node("JosouzaiSummonPos%d0" % [josouzai_summon_area]).position
		var josouzai_summon_area_pos1:Vector2 = $Josouzais.get_node("JosouzaiSummonPos%d1" % [josouzai_summon_area]).position
		josouzai.position.x = randf_range(josouzai_summon_area_pos0.x, josouzai_summon_area_pos1.x)
		josouzai.position.y = randf_range(josouzai_summon_area_pos0.y, josouzai_summon_area_pos1.y)
		josouzai.scale = Vector2(1,1) * 0.3
		$Josouzais.add_child(josouzai)
		last_josouzai_summond_area = josouzai_summon_area
		$Josouzais/JosouzaiSummonTimer.start( randf_range(12,15) )
	return

func _on_player_car_hit() -> void:
	car_hit += 1
	
	var bs:ColorRect = $BlackScreen
	bs.modulate = Color(1,1,1,1)
	bs.show()
	
	var random_respawn_area:int = randi_range(0,5)
	$Player.position = $PlayerRespawns.get_node("PlayerRespawnPos%d" % [random_respawn_area]).position
	$Player.moveable = false
	
	var tween:Tween = create_tween()
	tween.tween_property(bs, "modulate", Color(1,1,1,0), 4)
	tween.connect("finished", _on_blackscreen_tween_finished)
	return
	
func _on_blackscreen_tween_finished() -> void:
	$Player.moveable = bool(time > 0)
	$BlackScreen.hide()
	return


func _on_continue_button_pressed() -> void:
	$Ui/ColorRect.show()
	$Ui/PauseUi.hide()
	get_tree().paused = false
	return
