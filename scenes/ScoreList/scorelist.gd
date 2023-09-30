extends Node

func _ready() -> void:
	
	set_score_list()
	return
	
func set_score_list(showtestuser:bool=false) -> void:
	
	var all_user_data:Dictionary = Settings.get_all_user_data()
	var score_list:VBoxContainer = %ScoreListVBox
	
	var gamemode:int = %GamemodeOptionButton.selected
	var difficulty:int = %DifficultyOptionButton.selected
	
	for child in score_list.get_children():
		score_list.remove_child(child)
		child.queue_free()
		pass
		
	for user_name in all_user_data:
		if !showtestuser && user_name.contains("TestUser"):
			continue
		
		var score:int = 0
		var grass:int = 0
		var tree:int = 0
		var car:int = 0
		var time:float = 0
		
		if gamemode == 0:
			score = all_user_data[user_name]["score%d" % [difficulty]]
			grass = all_user_data[user_name]["grass%d" % [difficulty]]
			tree = all_user_data[user_name]["tree%d" % [difficulty]]
			car = all_user_data[user_name]["car%d" % [difficulty]]
			pass
		if gamemode == 1:
			time = all_user_data[user_name]["time%d" % [difficulty]]
			car = all_user_data[user_name]["tcar%d" % [difficulty]]
			pass
			
		if user_name == "FairyMD":
			user_name += "(製作者)"
			pass
		
		var score_item_container:HBoxContainer = HBoxContainer.new()
		
		var left_spacer:VSeparator = VSeparator.new()
		left_spacer.custom_minimum_size = Vector2(150,0)
		left_spacer.modulate = Color(1,1,1,0)
		score_item_container.add_child(left_spacer)
		
		var username_score_container:VBoxContainer = VBoxContainer.new()
		username_score_container.custom_minimum_size = Vector2(400,70)
		var username_label:Label = Label.new()
		username_label.text = user_name
		username_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		username_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var score_label:Label = Label.new()
		if gamemode == 0:
			score_label.text = "%06d" % [score]
			pass
		if gamemode == 1:
			score_label.text = "%02d:%02d.%03d" % [int(time/60), int(time)%60, (time-int(time))*1000]
			pass
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var label_settings:LabelSettings = LabelSettings.new()
#		font.resource_path = "res://font/mplus-1c-regular.ttf"
		label_settings.font_size = 20
		username_label.label_settings = label_settings
		score_label.label_settings = label_settings
		
		username_score_container.add_child(username_label)
		username_score_container.add_child(score_label)
		score_item_container.add_child(username_score_container)
		
		#center spacer
		var center_spacer:VSeparator = VSeparator.new()
		center_spacer.custom_minimum_size = Vector2(50,0)
		center_spacer.modulate = Color(1,1,1,0)
		score_item_container.add_child(center_spacer)
		
		#detail container
		var detail_container:VBoxContainer = VBoxContainer.new()
		detail_container.custom_minimum_size = Vector2(400, 70)
		var grass_tree_label:Label = Label.new()
		grass_tree_label.text = "草を枯らした回数：%d回,　木を枯らした回数：%d回" % [grass, tree]
		grass_tree_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grass_tree_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		grass_tree_label.label_settings = label_settings
		var car_label:Label = Label.new()
		car_label.text = "車に轢かれた回数：%d回" % [car]
		car_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		car_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		car_label.label_settings = label_settings
		if gamemode == 0:
			detail_container.add_child(grass_tree_label)
			pass
		detail_container.add_child(car_label)
		score_item_container.add_child(detail_container)
		
		score_list.add_child(score_item_container)
		pass
	
	return

func _on_refresh_data_button_pressed() -> void:
	set_score_list(Input.is_key_pressed(KEY_SHIFT))
	%RefreshDataButton.disabled = true
	$RefreshCooldownTimer.start(3)
	
	await $RefreshCooldownTimer.timeout
	
	%RefreshDataButton.disabled = false
	return

func _on_back_to_the_title_button_pressed() -> void:
	get_node("../")._change_scene("Title")
	return
