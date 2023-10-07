extends Node

const TOTAL_PAGE_COUNT:int = 3

var default_show_gairoju_health:bool = false
var rule_index:int = 0

var forward_button_pressed_count:int = 0

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
	return
	
func glitch_text() -> void:
	var now_text:String = $Ui/Rule2/InsanityLabel.text
	var splitted_string_array:PackedStringArray = now_text.split("")
	var splitted_array:Array = Array(splitted_string_array)
	var res:String = ""
	splitted_array.shuffle()
	for i in range(splitted_array.size()):
		res += splitted_array[i]
		pass
	$Ui/Rule2/InsanityLabel.text = res
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
		
	$Ui/Rule2/InsanityLabel.hide()
	$Ui/Rule2/SanityLabel.show()
	forward_button_pressed_count = 0
	return

func _on_forward_button_pressed() -> void:
	if rule_index < TOTAL_PAGE_COUNT-1:
		rule_index += 1
		set_page()
		pass
	else:
		forward_button_pressed_count += 1
		if forward_button_pressed_count % 20 == 0:
			$Ui/Rule2/SanityLabel.hide()
			$Ui/Rule2/InsanityLabel.show()
			glitch_text()
			pass
		if forward_button_pressed_count > 100:
			get_node("../")._change_scene("kyoiku")
			pass
	return
