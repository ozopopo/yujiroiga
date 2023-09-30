extends Node

const TOTAL_PAGE_COUNT:int = 3

var default_show_gairoju_health:bool = false
var rule_index:int = 0


func _init() -> void:
	default_show_gairoju_health = Settings.show_gairoju_health
	Settings.show_gairoju_health = true
	return

func _ready() -> void:
	%TotalPage.text = "%02d" % [TOTAL_PAGE_COUNT]
	
	rule_index = 0
	set_page()
	
	%BackButton.connect("focus_entered", %BackButton.release_focus)
	%ForwardButton.connect("focus_entered", %ForwardButton.release_focus)
	return


func _process(delta:float) -> void:
	%CurrentPage.text = "%02d" % [rule_index+1]
	%JosouzaiPercentage.value = $Ui/Rule0/GameObjects/Player.attack_health_ratio
	return

func set_page() -> void:
	for i in range(TOTAL_PAGE_COUNT):
		var rule:VBoxContainer = $Ui.get_node("Rule%d" % [i])
		if i == rule_index:
			rule.show()
			rule.process_mode = Node.PROCESS_MODE_INHERIT
			pass
		else:
			rule.hide()
			rule.process_mode = Node.PROCESS_MODE_DISABLED
			pass
		pass

	%ForwardButton.disabled = (rule_index == TOTAL_PAGE_COUNT-1)
	return

func _on_back_button_pressed() -> void:
	if rule_index < 1:
		Settings.show_gairoju_health = default_show_gairoju_health
		get_node("../")._change_scene("Title")
		pass
	else:
		rule_index -= 1
		set_page()
		pass
	return

func _on_forward_button_pressed() -> void:
	if rule_index < TOTAL_PAGE_COUNT-1:
		rule_index += 1
		pass
	set_page()
	return
