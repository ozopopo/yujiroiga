extends Node

var game_started:bool = false
var game_finished:bool = false
var time:int = 0
var time_f:float = 0.0
var score:int = 0
var grass_killed:int = 0
var tree_killed:int = 0
var car_hit:int = 0
var last_josouzai_summoned_area:int = randi_range(0, 1)
var remaining_gairoju:int = 60

const CAMERA_MIN_X:int = -1600
const CAMERA_MAX_X:int = 1600
const CAMERA_MIN_Y:int = -750
const CAMERA_MAX_Y:int = 0

const TIME_ATTACK_SUMMON_COUNT:int = 60

func _ready() -> void:
	
	init_game()
	
	return
	
func summon_gairoju() -> void:
	#誰だkiとtreeで場所で異なる名前付けたやつ
	var type_name:String = ["kusa", "kusa", "ki", "kusa"].pick_random()
	var gairoju = ResourceLoader.load("res://scenes/%s/%s.tscn" % [type_name, type_name]).instantiate()
	var random_gairoju_area:int = randi_range(0,4)
	var gairoju_area_marker_pos0:Vector2 = $Gairojus.get_node("Gairoju%d0" % [random_gairoju_area]).position
	var gairoju_area_marker_pos1:Vector2 = $Gairojus.get_node("Gairoju%d1" % [random_gairoju_area]).position
	
	gairoju.scale = Vector2(1,1) * 1.8
	gairoju.position.x = randf_range(gairoju_area_marker_pos0.x, gairoju_area_marker_pos1.x)
	gairoju.position.y = randf_range(gairoju_area_marker_pos0.y, gairoju_area_marker_pos1.y)
	
	var gairoju_random_type:int = randi_range(0,1)
	if gairoju_random_type == 0:
		gairoju.health = randi_range(50,100)
		pass
	elif gairoju_random_type == 1:
		gairoju.health = randi_range(100,150)
		pass
	
	gairoju.connect("ATTACKED", on_gairoju_attacked)
	gairoju.connect("KILLED", on_gairoju_killed)
	
	$Gairojus.add_child(gairoju)
	return

func init_game() -> void:
	game_started = false
	game_finished = false
	$Hud/Game/BlackScreen.hide()
	
	if !Settings.disable_ambient_sound:
		if Settings.difficlty == 0:
			$AmbientSound.play()
			$AmbientSound.connect("finished", $AmbientSound.play)
			pass
		if Settings.difficlty == 1:
			$HardAmbientSound.play()
			$HardAmbientSound.connect("finished", $HardAmbientSound.play)
			pass
		pass
	
	if Settings.gamemode == 0:
		$Hud/Game/GameInfo/Score.show()
		$Hud/Game/GameInfo/Time/Label.text = "制限時間："

		for i in range(30):
			summon_gairoju()
			pass

		score = 0
		time = 60
		pass
		
	if Settings.gamemode == 1:
		$Hud/Game/GameInfo/Score.hide()
		$Hud/Game/GameInfo/Time/Label.text = "経過時間："
		
		for i in range(TIME_ATTACK_SUMMON_COUNT):
			summon_gairoju()
			pass
		
		time_f = 0.0
		remaining_gairoju = TIME_ATTACK_SUMMON_COUNT
		pass
		
	if Settings.difficlty == 0:
		$Lights.hide()
		pass
	if Settings.difficlty == 1:
		$Lights.show()
		pass
	
	$Player.moveable = false
	$Hud/Game.hide()
	$Hud/Ready.show()
	$Hud/Ready.start()
	$Hud/Ready.connect("FINISHED", start_game)
	return
	
func start_game() -> void:
	$Player.moveable = true

	$Hud/Game.show()
	$Hud/Debug.hide()
	$Hud/Pause.hide()
	$Hud/Result.hide()
	
	$Cars/CarSummonTimer.start(0.1)
	$Josouzais/JosouzaiSummonTimer.start(9.8)
	
	$GameTimer.start(1)
	
	#開幕どこかに除草剤召喚
	#どうでもいいけど除草剤召喚ってなんかかっこよくね
	_on_josouzai_summon_timer_timeout()
	
	game_started = true
	return
	
func finish_game() -> void:
	game_finished = true
	
	$FinishSound.play()
	$Player.moveable = false
	for car in $Cars.get_children():
		car.queue_free()
		pass

	set_result_hud()
	
	await $FinishSound.finished
	
	var tween:Tween = create_tween()
	tween.tween_property($Hud/Result, "modulate", Color(1,1,1,1), 4.5)
	
	await tween.finished
	
	%RetryButton.disabled = false
	%SaveScoreButton.disabled = !Settings.is_ok_to_save() || (score < 0 || 999999 < score || score % 10 != 0)
	%BackToTheTitleButton.disabled = false
	%RetryButton.grab_focus()
	return
	
func set_result_hud() -> void:
	
	#スコアモード
	if Settings.gamemode == 0:
		%ResultScore.text = "%06d" % [score]
		%ResultDetailGrass.text = "%d" % [grass_killed]
		%ResultDetailTree.text = "%d" % [tree_killed]
		%ResultDetailCar.text = "%d" % [car_hit]

		if Settings.is_login:
			$Hud/Result/ResultScreen/Score/YourCurrentScore.show()
			$Hud/Result/ResultScreen/ResultDetail/VSeparator.show()
			$Hud/Result/ResultScreen/ResultDetail/CurrentDetail.show()
			var current_user_data:Dictionary = Settings.get_current_user_data()
			%YourCurrentScore.text = "%06d" % [current_user_data.score]
			%CurrentDetailGrass.text = "%d" % [current_user_data.grass]
			%CurrentDetailTree.text = "%d" % [current_user_data.tree]
			%CurrentDetailCar.text = "%d" % [current_user_data.car]

			if current_user_data.car == 0 && current_user_data.score != 0:
				%CurrentDetailCarLabel.label_settings.font_color = Color.YELLOW
				%CurrentDetailCar.label_settings.font_color = Color.YELLOW
				pass
			else:
				%CurrentDetailCarLabel.label_settings.font_color = Color.WHITE
				%CurrentDetailCar.label_settings.font_color = Color.WHITE
				pass
			pass

		else:
			$Hud/Result/ResultScreen/Score/YourCurrentScore.hide()
			$Hud/Result/ResultScreen/ResultDetail/VSeparator.hide()
			$Hud/Result/ResultScreen/ResultDetail/CurrentDetail.hide()
			pass
		
		if car_hit == 0:
			%ResultDetailCarLabel.label_settings.font_color = Color.YELLOW
			%ResultDetailCar.label_settings.font_color = Color.YELLOW
			pass
		elif car_hit >= 10:
			%ResultDetailCarLabel.label_settings.font_color = Color.RED
			%ResultDetailCar.label_settings.font_color = Color.RED
			pass
		else:
			%ResultDetailCarLabel.label_settings.font_color = Color.WHITE
			%ResultDetailCar.label_settings.font_color = Color.WHITE
			pass
			
		pass
	if Settings.gamemode == 1:
		#ResultTimeじゃないのって思った方、いると思います。
		#どうしてでしょうか。答えはシンプルです。
		# T i m e 用 の U I 別 で 作 ん の め ん ど く さ い か ら
		$Hud/Result/ResultScreen/ResultDetail/Detail/DetailGrass.hide()
		$Hud/Result/ResultScreen/ResultDetail/Detail/DetailTree.hide()
		%SaveScoreButton.text = "タイムを保存する"
		
		%ResultScore.text = "%02d:%02d.%03d" % [int(time_f/60), int(time_f)%60, (time_f - int(time_f))*1000]
		%ResultDetailCar.text = "%d" % [car_hit]

		if Settings.is_login:
			$Hud/Result/ResultScreen/Score/YourCurrentScore.show()
			$Hud/Result/ResultScreen/ResultDetail/VSeparator.show()
			$Hud/Result/ResultScreen/ResultDetail/CurrentDetail.show()
			$Hud/Result/ResultScreen/ResultDetail/CurrentDetail/CurrentDetailGrass.hide()
			$Hud/Result/ResultScreen/ResultDetail/CurrentDetail/CurrentDetailTree.hide()
			$Hud/Result/ResultScreen/Score/YourCurrentScore/Label.text = "あなたの現在のタイム："

			var current_user_data:Dictionary = Settings.get_current_user_data()
			var current_time:float = current_user_data.time
			%YourCurrentScore.text = "%02d:%02d.%03d" % [int(current_time/60), int(current_time)%60, (current_time - int(current_time))*1000]
			%CurrentDetailCar.text = "%d" % [current_user_data.car]

			if current_user_data.car == 0 && current_time > 1:
				%CurrentDetailCarLabel.label_settings.font_color = Color.YELLOW
				%CurrentDetailCar.label_settings.font_color = Color.YELLOW
				pass
			else:
				%CurrentDetailCarLabel.label_settings.font_color = Color.WHITE
				%CurrentDetailCar.label_settings.font_color = Color.WHITE
				pass

			pass
		else:
			$Hud/Result/ResultScreen/Score/YourCurrentScore.hide()
			$Hud/Result/ResultScreen/ResultDetail/VSeparator.hide()
			$Hud/Result/ResultScreen/ResultDetail/CurrentDetail.hide()
			pass
		
		pass
	
	$Hud/Result.modulate = Color(1,1,1,0)
	$Hud/Result.show()
	$Hud/Game.hide()
	
	%RetryButton.disabled = true
	%SaveScoreButton.disabled = true
	%BackToTheTitleButton.disabled = true
	return
	
func save_game_data() -> void:
	if Settings.is_login:
		if Settings.gamemode == 0:
			Settings.save_game_data({
				"score": score,
				"grass": grass_killed,
				"tree": tree_killed,
				"car": car_hit
			})
			pass
		if Settings.gamemode == 1:
			Settings.save_game_data({
				"time": time_f,
				"car": car_hit
			})
			pass
		pass
	return
	
func update_game_hud() -> void:
	if Settings.gamemode == 0:
		
		if time > 10:
			$Hud/Game/GameInfo/Score/ScoreLabel.text = "%06d" % [clamp(score, 0, 999999)]
			pass
		else:
			$Hud/Game/GameInfo/Score/ScoreLabel.text = "??????"
			pass

		$Hud/Game/GameInfo/Time/TimeLabel.text = "%02d:%02d" % [int((time%3600)/60),time%60]
		pass
	if Settings.gamemode == 1:
		
		if !game_finished:
			if remaining_gairoju > 10:
				$Hud/Game/GameInfo/Time/TimeLabel.text = "%02d:%02d.%03d" % [int(time_f/60), int(time_f)%60, (time_f - int(time_f))*1000]
				pass
			else:
				$Hud/Game/GameInfo/Time/TimeLabel.text = "??:??.???"
				pass
			
		pass

	$Hud/Game/JosouzaiInfo/JosouzaiPercentage.value = $Player.attack_health_ratio
	$Hud/Debug/Label.text = "CameraPos: %s\nPlayerPos: %s" % [$Camera2D.position, $Player.position]
	return

func _process(delta:float) -> void:
	if Settings.gamemode == 0:
		pass
	if Settings.gamemode == 1 && game_started && !game_finished:
		time_f += delta
		pass
	
	update_game_hud()
	return

func _physics_process(_delta:float) -> void:
	$Camera2D.position.x = clamp($Player.position.x, CAMERA_MIN_X,CAMERA_MAX_X)
	$Camera2D.position.y = clamp($Player.position.y, CAMERA_MIN_Y,CAMERA_MAX_Y)
	
	$Lights/PointLight2D.position = $Player.position
	
	return

func _unhandled_input(event):
	if event.is_action_pressed("pause") && game_started && !game_finished:
		$Hud/Game.hide()
		$Hud/Pause.show()
		$OpenMenuSound.play()
		$Hud/Pause/PauseScreen/ResumeButton.grab_focus()
		get_tree().paused = true
		pass
	return

#func _input(event:InputEvent) -> void:
#	if event.is_action_pressed("pause") && game_started && !game_finished:
#		$Hud/Game.hide()
#		$Hud/Pause.show()
#		$OpenMenuSound.play()
#		$Hud/Pause/PauseScreen/ResumeButton.grab_focus()
#		get_tree().paused = true
#		pass
#	return

func on_gairoju_attacked(type:int) -> void:
	if game_finished:
		return

	if type == 0:
		score += 10
		pass
	if type == 1:
		score += 20
		pass
	return

func on_gairoju_killed(type:int) -> void:
	if game_finished:
		return
		
	if type == 0:
		score += 1000
		grass_killed += 1
		pass
	if type == 1:
		score += 2000
		tree_killed += 1
		pass
	
	if Settings.gamemode == 0:
		summon_gairoju()
		pass
	if Settings.gamemode == 1:
		remaining_gairoju -= 1
		if remaining_gairoju == 0:
			finish_game()
			pass
		pass

	return

func _on_resume_button_pressed() -> void:
	$Hud/Game.show()
	$Hud/Pause.hide()
	get_tree().paused = false
	return

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_node("../")._change_scene("Play2")
	return

func _on_back_to_the_title_button_pressed() -> void:
	get_tree().paused = false
	get_node("../")._change_scene("Title")
	return

func _on_save_score_button_pressed() -> void:
	save_game_data()
	%SaveScoreButton.disabled = true
	%SaveScoreButton.text = "保存しました"
	
	if Settings.gamemode == 0:
		%YourCurrentScore.text = "%06d" % [score]
		%CurrentDetailGrass.text = "%d" % [grass_killed]
		%CurrentDetailTree.text = "%d" % [tree_killed]
		%CurrentDetailCar.text = "%d" % [car_hit]
		pass
	if Settings.gamemode == 1:
		%YourCurrentScore.text = %ResultScore.text
		%CurrentDetailCar.text = "%d" % [car_hit]
		pass
	
	if car_hit == 0:
		%CurrentDetailCarLabel.label_settings.font_color = Color.YELLOW
		%CurrentDetailCar.label_settings.font_color = Color.YELLOW
		pass
	else:
		%CurrentDetailCarLabel.label_settings.font_color = Color.WHITE
		%CurrentDetailCar.label_settings.font_color = Color.WHITE
		pass
	return

func _on_josouzai_summon_timer_timeout() -> void:
	if !game_finished:
		
		var josouzai = ResourceLoader.load("res://scenes/josouzai/josouzai.tscn").instantiate()
		var josouzai_summon_area:int = int(last_josouzai_summoned_area == 0)
		var josouzai_summon_area_pos0:Vector2 = $Josouzais.get_node("Josouzai%d0" % [josouzai_summon_area]).position
		var josouzai_summon_area_pos1:Vector2 = $Josouzais.get_node("Josouzai%d1" % [josouzai_summon_area]).position
		josouzai.position.x = randf_range(josouzai_summon_area_pos0.x, josouzai_summon_area_pos1.x)
		josouzai.position.y = randf_range(josouzai_summon_area_pos0.y, josouzai_summon_area_pos1.y)
		josouzai.scale = Vector2(1,1) * 1.1
		$Josouzais.add_child(josouzai)
		last_josouzai_summoned_area = josouzai_summon_area
		if Settings.difficlty == 0:
			$Josouzais/JosouzaiSummonTimer.start( randf_range(12,15) )
			pass
		if Settings.difficlty == 1:
			$Josouzais/JosouzaiSummonTimer.start( randf_range(6,7.5) )
			pass
		
	return

func _on_car_summon_timer_timeout() -> void:
	if !game_finished:
		
		var car = ResourceLoader.load("res://scenes/car/car.tscn").instantiate()
		var car_random_pos:int = randi_range(0,5)
		car.speed = randf_range(2.5,5.4) * 3
		if car_random_pos % 2 == 0:
			car.move_dir = Vector2(1,0)
			pass
		else:
			car.move_dir = Vector2(-1,0)
			pass
		car.scale = Vector2(3.75,4) # 3.5 4
		car.position = $Cars.get_node("Car%d" % [car_random_pos]).position
		
		$Cars.add_child(car)
		$Cars/CarSummonTimer.start( randf_range(1, 1.5) )

		pass
	return

func _on_game_timer_timeout() -> void:
	if Settings.gamemode == 0:
		if time > 0:
			time -= 1
			$GameTimer.start(1)
			pass
		elif time == 0:
			$GameTimer.stop()
			finish_game()
			pass
		pass
	
	return

func _on_player_car_hit() -> void:
	car_hit += 1
	
	var bs:ColorRect = $Hud/Game/BlackScreen
	bs.modulate = Color(1,1,1,1)
	bs.show()
	
	var random_respawn_area:int = randi_range(0,5)
	$Player.position = $PlayerRespawns.get_node("PlayerRespawn%d" % [random_respawn_area]).position
	$Player.moveable = false
	
	var tween:Tween = create_tween()
	tween.tween_property(bs, "modulate", Color(1,1,1,0), 4)
	
	await tween.finished
	
	$Player.moveable = !game_finished
	$Hud/Game/BlackScreen.hide()
	return
