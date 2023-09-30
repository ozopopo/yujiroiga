extends Node

@onready var ni:TextEdit = %NameInput

var user_name:String = ""

func _ready() -> void:
	go_to(0)
	return

func go_to_title_scene() -> void:
	get_node("../")._change_scene("Title")
	return
	
func go_to(index:int) -> void:

	if index == 0:
		$Ui/AskLogin.show()
		%YesButton.grab_focus()
	else:
		$Ui/AskLogin.hide()

	if index == 1:
		$Ui/NameInput.show()
		ni.grab_focus()
	else:
		%NameInputError.hide()
		$Ui/NameInput.hide()

	if index == 2:
		$Ui/NewPassInput.show()
		%NewPassInput.grab_focus()
	else:
		
		%NewPassInputError.hide()
		$Ui/NewPassInput.hide()
	
	if index == 3:
		$Ui/PassInput.show()
		%PassInput.grab_focus()
	else:
		%PassInputError.hide()
		$Ui/PassInput.hide()

	return


func _on_no_button_pressed() -> void:
	Settings.is_login = false
	go_to_title_scene()
	return

#名前が存在するか判定
func _on_name_accept_button_pressed() -> void:
	var input_name:String = ni.text
	
	
	if input_name == "letmegototestscene":
		get_node("../")._change_scene("Test")
		return
		
	if input_name == "__regeneratedatafile":
		Settings.regenerate_data_file()
		OS.alert("Data file successfully regenerated")
		get_tree().quit()
		return
		
	if input_name == "__recoverydatafile":
		Settings.recovery_data_file()
		OS.alert("Data file successfully recovering(?)")
		get_tree().quit()
		return
		
	if input_name == "":
		%NameInputError.show()
		return
	
	user_name = input_name
	
	Settings.set_current_user(user_name)
	if Settings.is_exists_user(input_name):
		go_to(3)
	else:
		go_to(2)
	
	return

#新規パスワード決定
func _on_new_pass_accept_button_pressed() -> void:
	var input_pass:String = %NewPassInput.text
	if input_pass == "":
		%NewPassInputError.show()
		return
	Settings.user_data_init(input_pass)
	Settings.is_login = true
	go_to_title_scene()
	return

#パスワード判定
func _on_pass_accept_button_pressed() -> void:
	var psi:TextEdit = %PassInput
	var input_pass:String = psi.text
	if input_pass == "":
		%PassInputError.text = "パスワードを入力してください"
		%PassInputError.show()
		return
	if !Settings.is_correct_passwd(input_pass):
		%PassInputError.text = "パスワードが違います"
		%PassInputError.show()
		return
	Settings.login()
	go_to_title_scene()
	return

#nameinput入力制限
func _on_name_input_text_changed() -> void:
	var current_text:String = ni.text
	var current_caret:int = ni.get_caret_column()
	if current_text.length() > 20:
		current_text = current_text.substr(0,20)
	ni.text = current_text.replace("\n", "")
	ni.set_caret_column(current_caret)
	return

#newpassinput入力制限
func _on_new_pass_input_text_changed() -> void:
	var npi:TextEdit = %NewPassInput
	var current_caret:int = npi.get_caret_column()
	npi.text = npi.text.replace("\n", "")
	npi.set_caret_column(current_caret)
	return

#passinput入力制限
func _on_pass_input_text_changed() -> void:
	var pi:TextEdit = %PassInput
	var current_caret:int = pi.get_caret_column()
	pi.text = pi.text.replace("\n", "")
	pi.set_caret_column(current_caret)
	return
