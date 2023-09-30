extends Node


func _physics_process(_delta) -> void:
	var j:Vector2 = Vector2.ZERO
	j.x = int(Input.is_key_pressed(KEY_L)) - int(Input.is_key_pressed(KEY_J))
	j.y = int(Input.is_key_pressed(KEY_K)) - int(Input.is_key_pressed(KEY_I))
	$CharacterBody2D.move_and_collide(j*3)
	return


func _on_get_pressed() -> void:
#	print( Settings.get_userdata("ﾌｪｱﾘｨ誠です男（製作者）") )
	return

func set_score_list() -> void:
	
	var all_user_data:Dictionary = Settings.get_all_user_data()
	var score_list:VBoxContainer = $Ui/ScrollContainer/VBoxContainer
	
	for child in score_list.get_children():
		score_list.remove_child(child)
		child.queue_free()
		pass
		
	for user_name in all_user_data:
			
		var score:int = all_user_data[user_name].score
		var grass:int = all_user_data[user_name].grass
		var tree:int = all_user_data[user_name].tree
		var car:int = all_user_data[user_name].car
		
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
		score_label.text = "%06d" % [score]
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
		
		detail_container.add_child(grass_tree_label)
		detail_container.add_child(car_label)
		score_item_container.add_child(detail_container)
		
		score_list.add_child(score_item_container)
		pass
	
	return

func _on_set_pressed() -> void:
	set_score_list()
#	Settings.reset_data_file()
#	Settings.append_test("ユジロイガ.pak")
	return

func _on_get_2_pressed() -> void:
	Settings.recovery_data()
	get_tree().quit()
	
	return
