extends Node

@export var is_login:bool = false
@export var current_user_name:String = ""

#General Settings
@export var gamemode:int = 0
@export var difficlty:int = 0
@export var disable_ambient_sound:bool = false
#Advanced Settings
@export var show_gairoju_health:bool = false
@export var show_josouzai_zanryo:bool = false
@export var enable_infinity_josouzai:bool = false
@export var enable_invincible_mode:bool = false

var data_file_name = ProjectSettings.get("application/config/name")+".yjr"

var all_users_data:ConfigFile = null
var executable_dir:String = OS.get_executable_path().get_base_dir()
var data_file_path:String = executable_dir + "/" + data_file_name


func _ready() -> void:

	if !FileAccess.file_exists(executable_dir+"/ignorecfgcheck"):
		load_cfg_file()
		pass
	else:
		OS.alert("Config file check ignored")
		pass

	return

func _get_key() -> String:
	#deleted	
	return ""

func load_cfg_file() -> ConfigFile:
	var cfg:ConfigFile = ConfigFile.new()
	if cfg.load_encrypted_pass(data_file_path, _get_key()) != OK:
		OS.alert("データファイルの読み込みに失敗しました。\nもし何度もこの警告がでるのであれば、\nREADMEに書いてある方法をお試しください。", "データファイルの読み込みに失敗しました")
		get_tree().quit(-1)
		pass
	return cfg
	
func regenerate_data_file() -> void:
	var cfg:ConfigFile = ConfigFile.new()
	
	cfg.set_value("FairyMD", "score0", 0)
	cfg.set_value("FairyMD", "grass0", 0)
	cfg.set_value("FairyMD", "tree0", 0)
	cfg.set_value("FairyMD", "car0", 0)
	
	cfg.set_value("FairyMD", "score1", 0)
	cfg.set_value("FairyMD", "grass1", 0)
	cfg.set_value("FairyMD", "tree1", 0)
	cfg.set_value("FairyMD", "car1", 0)
	
	cfg.set_value("FairyMD", "time0", 0.0)
	cfg.set_value("FairyMD", "tcar0", 0)
	
	cfg.set_value("FairyMD", "time1", 0.0)
	cfg.set_value("FairyMD", "tcar1", 0)
	
	cfg.set_value("FairyMD", "gamemode", 0)
	cfg.set_value("FairyMD", "difficulty", 0)
	cfg.set_value("FairyMD", "disableambi", false)
	cfg.set_value("FairyMD", "showgairojuhp", false)
	cfg.set_value("FairyMD", "showjosouzaizanryo", false)
	cfg.set_value("FairyMD", "enableinfinityjosouzai", false)
	cfg.set_value("FairyMD", "enableinvinciblemode", false)
	
	cfg.save_encrypted_pass(executable_dir+"/regenerated.yjr", _get_key())
	return

func recovery_data_file() -> void:
	
	var cfg:ConfigFile = load_cfg_file()
	var cfg_n:ConfigFile = ConfigFile.new()
	
	for section in cfg.get_sections():
		for s_key in cfg.get_section_keys(section):
			var v = cfg.get_value(section, s_key)
			match s_key:
				"pass":
					if section == "FairyMD":
						continue
						pass
					pass
				"score":
					cfg_n.set_value(section, "score0", v)
					continue
					pass
				"grass":
					cfg_n.set_value(section, "grass0", v)
					continue
					pass
				"tree":
					cfg_n.set_value(section, "tree0", v)
					continue
					pass
				"car":
					cfg_n.set_value(section, "car0", v)
					continue
					pass

			cfg_n.set_value(section, s_key, v)
			pass
		pass
		
		cfg_n.save_encrypted_pass(executable_dir+"/recover.yjr", _get_key())
	return

func remove_current_user_data() -> void:
	if !is_exists_user(current_user_name) || !is_login:
		return
	var cfg:ConfigFile = ConfigFile.new()
	var _cfg:ConfigFile = load_cfg_file()
	for section in _cfg.get_sections():
		if section == current_user_name:
			continue
		for section_key in _cfg.get_section_keys(section):
			if section_key == "name":
				continue
			cfg.set_value(section, section_key, _cfg.get_value(section, section_key))
			pass
		pass
		
	cfg.save_encrypted_pass(data_file_path, _get_key())
	return

func reset_current_user_data(_gamemode:int=gamemode, _difficulty:int=difficlty) -> void:
	if !is_login:
		return

	var cfg:ConfigFile = load_cfg_file()
	
	if _gamemode == 0:
		cfg.set_value(current_user_name, "score%d" % [_difficulty], 0)
		cfg.set_value(current_user_name, "grass%d" % [_difficulty], 0)
		cfg.set_value(current_user_name, "tree%d" % [_difficulty], 0)
		cfg.set_value(current_user_name, "car%d" % [_difficulty], 0)
		pass
	if _gamemode == 1:
		cfg.set_value(current_user_name, "time%d" % [_difficulty], 0.0)
		cfg.set_value(current_user_name, "tcar%d" % [_difficulty], 0)
		pass

	cfg.save_encrypted_pass(data_file_path, _get_key())
	return
	
func user_data_init(passwd:String) -> void:
	var cfg:ConfigFile = load_cfg_file()
	
	cfg.set_value(current_user_name, "pass", passwd.uri_encode().sha256_text())
	cfg.set_value(current_user_name, "score0", 0)
	cfg.set_value(current_user_name, "grass0", 0)
	cfg.set_value(current_user_name, "tree0", 0)
	cfg.set_value(current_user_name, "car0", 0)
	
	cfg.set_value(current_user_name, "score1", 0)
	cfg.set_value(current_user_name, "grass1", 0)
	cfg.set_value(current_user_name, "tree1", 0)
	cfg.set_value(current_user_name, "car1", 0)
	
	cfg.set_value(current_user_name, "time0", 0.0)
	cfg.set_value(current_user_name, "tcar0", 0)
	
	cfg.set_value(current_user_name, "time1", 0.0)
	cfg.set_value(current_user_name, "tcar1", 0)
	
	cfg.set_value(current_user_name, "gamemode", 0)
	cfg.set_value(current_user_name, "difficulty", 0)
	cfg.set_value(current_user_name, "disableambi", false)
	cfg.set_value(current_user_name, "showgairojuhp", false)
	cfg.set_value(current_user_name, "showjosouzaizanryo", false)
	cfg.set_value(current_user_name, "enableinfinityjosouzai", false)
	cfg.set_value(current_user_name, "enableinvinciblemode", false)
	
	cfg.save_encrypted_pass(data_file_path, _get_key())
	return
	
func login() -> void:
	is_login = true
	
	#設定の同期
	var cfg:ConfigFile = load_cfg_file()
	
	gamemode = cfg.get_value(current_user_name, "gamemode")
	difficlty = cfg.get_value(current_user_name, "difficulty")
	disable_ambient_sound = cfg.get_value(current_user_name, "disableambi")
	show_gairoju_health = cfg.get_value(current_user_name, "showgairojuhp")
	show_josouzai_zanryo = cfg.get_value(current_user_name, "showjosouzaizanryo")
	enable_infinity_josouzai = cfg.get_value(current_user_name, "enableinfinityjosouzai")
	enable_invincible_mode = cfg.get_value(current_user_name, "enableinvinciblemode")
	
	return

func save_settings() -> void:
	if is_login:
		var cfg:ConfigFile = load_cfg_file()
		
		cfg.set_value(current_user_name, "gamemode", gamemode)
		cfg.set_value(current_user_name, "difficulty", difficlty)
		cfg.set_value(current_user_name, "disableambi", disable_ambient_sound)
		cfg.set_value(current_user_name, "showgairojuhp", show_gairoju_health)
		cfg.set_value(current_user_name, "showjosouzaizanryo", show_josouzai_zanryo)
		cfg.set_value(current_user_name, "enableinfinityjosouzai", enable_infinity_josouzai)
		cfg.set_value(current_user_name, "enableinvinciblemode", enable_invincible_mode)
		
		cfg.save_encrypted_pass(data_file_path, _get_key())
		pass
	
	return

func save_game_data(data:Dictionary) -> void:
	if is_ok_to_save():
		var cfg:ConfigFile = load_cfg_file()
		
		if gamemode == 0:
			cfg.set_value(current_user_name, "score%d" % [difficlty], data.score)
			cfg.set_value(current_user_name, "grass%d" % [difficlty], data.grass)
			cfg.set_value(current_user_name, "tree%d" % [difficlty], data.tree)
			cfg.set_value(current_user_name, "car%d" % [difficlty], data.car)
			pass
		if gamemode == 1:
			cfg.set_value(current_user_name, "time%d" % [difficlty], data.time)
			cfg.set_value(current_user_name, "tcar%d" % [difficlty], data.car)
			pass
		
		cfg.save_encrypted_pass(data_file_path, _get_key())
		pass
	else:
		OS.alert("セーブ条件を満たしていません", "FAILED TO SAVE")
		pass
	return

func is_exists_user(user_name:String) -> bool:
	var cfg:ConfigFile = load_cfg_file()
	return cfg.has_section(user_name)

func is_correct_passwd(passwd:String):
	var cfg:ConfigFile = load_cfg_file()
	return cfg.get_value(current_user_name, "pass") == passwd.uri_encode().sha256_text()
	
func is_default_settings() -> bool:
	return gamemode == 0 && difficlty == 0 && !disable_ambient_sound && \
			!show_gairoju_health && !show_josouzai_zanryo && !enable_infinity_josouzai && !enable_invincible_mode

func is_ok_to_save() -> bool:
	return is_login && !show_gairoju_health && !show_josouzai_zanryo && !enable_infinity_josouzai && !enable_invincible_mode

func get_all_user_data() -> Dictionary:
	var cfg:ConfigFile = load_cfg_file()
	var dict:Dictionary = {}

	for section in cfg.get_sections():
		dict[section] = {}
#		dict[section]["name"] = section
		for section_key in cfg.get_section_keys(section):
			if section_key == "pass":
				continue
			dict[section][section_key] = cfg.get_value(section, section_key)
			pass
		pass

	return dict

func get_current_user_data() -> Dictionary:
	var cfg:ConfigFile = load_cfg_file()

	var ret:Dictionary = {}

	if gamemode == 0:
		ret.score = cfg.get_value(current_user_name,"score%d" % [difficlty])
		ret.grass = cfg.get_value(current_user_name,"grass%d" % [difficlty])
		ret.tree = cfg.get_value(current_user_name,"tree%d" % [difficlty])
		ret.car = cfg.get_value(current_user_name,"car%d" % [difficlty])
		pass
	elif gamemode == 1:
		ret.time = cfg.get_value(current_user_name,"time%d" % [difficlty])
		ret.car = cfg.get_value(current_user_name,"tcar%d" % [difficlty])
		pass

	return ret

func get_all_current_user_data() -> Dictionary:
	var cfg:ConfigFile = load_cfg_file()
	var ret:Dictionary = {}

	for section_key in cfg.get_section_keys(current_user_name):
		if section_key == "pass":
			continue
		ret[section_key] = cfg.get_value(current_user_name, section_key)
		pass

	return ret

func set_current_user(user_name:String) -> void:
	current_user_name = user_name
	return
