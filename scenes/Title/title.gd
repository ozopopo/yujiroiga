extends Node

func _ready() -> void:
	%StartButton.grab_focus()
	if Settings.is_login:
		var current_user_data:Dictionary = Settings.get_current_user_data()
		$Ui/CurrentScoreUi.show()
		$Ui/CurrentScoreUi/Label.text = "ようこそ、%sさん！\n現在の保存されているデータ：" % [Settings.current_user_name]
		if Settings.gamemode == 0:
			%CurrentScore.text = "%06d" % [current_user_data.score]
			%CurrentGrass.text = "%d" % [current_user_data.grass]
			%CurrentTree.text = "%d" % [current_user_data.tree]
			%CurrentCar.text = "%d" % [current_user_data.car]
			pass
		if Settings.gamemode == 1:
			$Ui/CurrentScoreUi/Score/Label.text = "タイム："
			$Ui/CurrentScoreUi/Grass.hide()
			$Ui/CurrentScoreUi/Tree.hide()

			var time:float = current_user_data.time
			%CurrentScore.text = "%02d:%02d.%03d" % [int(time/60), int(time)%60, (time - int(time))*1000]
			%CurrentCar.text = "%d" % [current_user_data.car]
			pass
		pass
	else:
		$Ui/CurrentScoreUi.hide()
		pass
		
	match Settings.gamemode:
		0:
			%GamemodeLabel.text = "スコア"
			pass
		1:
			%GamemodeLabel.text = "タイム"
			pass
			
	match Settings.difficlty:
		0:
			%DifficultyLabel.text = "ノーマル"
			pass
		1:
			%DifficultyLabel.text = "ハード"
			pass
	
	return
	
func _on_start_button_pressed() -> void:
	get_node("../")._change_scene("Play2")
	return

func _on_rule_button_pressed() -> void:
	get_node("../")._change_scene("Rule")
	return

func _on_score_list_button_pressed() -> void:
	get_node("../")._change_scene("ScoreList")
	return

func _on_setting_button_pressed() -> void:
	get_node("../")._change_scene("Setting")
	return
