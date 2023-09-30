extends VBoxContainer

func _ready() -> void:
	
	if Settings.is_login:
		refresh()
		pass
	else:
		hide()
		pass
		
	return

func refresh() -> void:
	var all_current_data:Dictionary = Settings.get_all_current_user_data()
	
	$SavedData/ScoreNormal/Score/Label2.text = "%06d" % [all_current_data.score0]
	$SavedData/ScoreNormal/KilledGrass/Label2.text = "%d" % [all_current_data.grass0]
	$SavedData/ScoreNormal/KilledTree/Label2.text = "%d" % [all_current_data.tree0]
	$SavedData/ScoreNormal/CarCrashed/Label2.text = "%d" % [all_current_data.car0]

	$SavedData/ScoreHard/Score/Label2.text = "%06d" % [all_current_data.score1]
	$SavedData/ScoreHard/KilledGrass/Label2.text = "%d" % [all_current_data.grass1]
	$SavedData/ScoreHard/KilledTree/Label2.text = "%d" % [all_current_data.tree1]
	$SavedData/ScoreHard/CarCrashed/Label2.text = "%d" % [all_current_data.car1]

	var time0:float = all_current_data.time0
	$SavedData/TimeNormal/Score/Label2.text = "%02d:%02d.%03d" % [int(time0/60), int(time0)%60, (time0-int(time0))*1000]
	$SavedData/TimeNormal/CarCrashed/Label2.text = "%d" % [all_current_data.tcar0]

	var time1:float = all_current_data.time1
	$SavedData/TimeHard/Score/Label2.text = "%02d:%02d.%03d" % [int(time1/60), int(time1)%60, (time1-int(time1))*1000]
	$SavedData/TimeHard/CarCrashed/Label2.text = "%d" % [all_current_data.tcar1]
	
	return
