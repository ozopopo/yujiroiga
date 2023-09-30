extends Node

func _ready() -> void:
	
	$Ui/ConfirmScreen.hide()
	%GamemodeOptionButton.grab_focus()
	
	if Settings.is_default_settings():
		%ResetSettingButton.hide()
		pass
	else:
		%ResetSettingButton.show()
		pass
	
	%GamemodeOptionButton.selected = Settings.gamemode
	%DifficultyOptionButton.selected = Settings.difficlty
	%DisableAmbiSoundOptionButton.selected = int(!Settings.disable_ambient_sound)
	%ShowGairojuHealthOptionButton.selected = int(!Settings.show_gairoju_health)
	%ShowJosouzaiZanryoOptionButton.selected = int(!Settings.show_josouzai_zanryo)
	%EnableInfinityJosouzaiOptionButton.selected = int(!Settings.enable_infinity_josouzai)
	%EnableInvincibleModeOptionButton.selected = int(!Settings.enable_invincible_mode)
	
	return

func _on_data_reset_buttons_pressed(gamemode:int, difficulty:int) -> void:
	Settings.reset_current_user_data(gamemode, difficulty)
	%SavedDataViewer.refresh()
	return

func _on_delete_saved_data_button_pressed() -> void:
	$Ui/ConfirmScreen.modulate = Color(1,1,1,0)
	$Ui/ConfirmScreen.show()
	var tween:Tween = create_tween()
	tween.tween_property($Ui/ConfirmScreen, "modulate", Color(1,1,1,1), 3)
	%CancelDeleteButton.disabled = true
	%DeleteButton.disabled = true
	
	await tween.finished
	
	%CancelDeleteButton.disabled = false
	%DeleteButton.disabled = false
	
	%CancelDeleteButton.grab_focus()
	return

func _on_back_button_pressed() -> void:
	Settings.gamemode = %GamemodeOptionButton.selected
	Settings.difficlty = %DifficultyOptionButton.selected
	Settings.disable_ambient_sound = (%DisableAmbiSoundOptionButton.selected == 0)
	Settings.show_gairoju_health = (%ShowGairojuHealthOptionButton.selected == 0)
	Settings.show_josouzai_zanryo = (%ShowJosouzaiZanryoOptionButton.selected == 0)
	Settings.enable_infinity_josouzai = (%EnableInfinityJosouzaiOptionButton.selected == 0)
	Settings.enable_invincible_mode = (%EnableInvincibleModeOptionButton.selected == 0)
	
	Settings.save_settings()
	
	get_node("../")._change_scene("Title")
	return

func _on_reset_setting_button_pressed() -> void:
	
	Settings.gamemode = 0
	Settings.difficlty = 0
	Settings.disable_ambient_sound = false
	Settings.show_gairoju_health = false
	Settings.show_josouzai_zanryo = false
	Settings.enable_infinity_josouzai = false
	Settings.enable_invincible_mode = false
	
	%GamemodeOptionButton.selected = Settings.gamemode
	%DifficultyOptionButton.selected = Settings.difficlty
	%DisableAmbiSoundOptionButton.selected = int(!Settings.disable_ambient_sound)
	%ShowGairojuHealthOptionButton.selected = int(!Settings.show_gairoju_health)
	%ShowJosouzaiZanryoOptionButton.selected = int(!Settings.show_josouzai_zanryo)
	%EnableInfinityJosouzaiOptionButton.selected = int(!Settings.enable_infinity_josouzai)
	%EnableInvincibleModeOptionButton.selected = int(!Settings.enable_invincible_mode)
	
	%ResetSettingButton.hide()
	return
	
func _on_cancel_delete_button_pressed() -> void:
	$Ui/ConfirmScreen.hide()
	return

func _on_delete_button_pressed() -> void:
	Settings.remove_current_user_data()
	get_tree().quit()
	return
