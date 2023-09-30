extends Sprite2D

signal ATTACKED
signal KILLED

@export var health:int = 100
@export var dead:bool = false
@export var show_health:bool = false

var touching_attack:bool = false
var killed:bool = false

func _ready() -> void:
	show_health = Settings.show_gairoju_health
	return

func _process(_delta:float) -> void:
	if health < 1 || dead:
		region_rect = Rect2(200,237,82,251)
		$KiArea/CollisionShape2D.disabled = true
		if !killed:
			killed = true
			emit_signal("KILLED", 1)
			pass
		pass

	if touching_attack:
		health -= 1
		emit_signal("ATTACKED", 1)
		pass
		
	if show_health:
		$Label.show()
		$Label.text = var_to_str(health)
		pass
	else:
		$Label.hide()
		pass
	
	return


func _on_ki_area_area_entered(area:Area2D) -> void:
	if area.name == "AttackHitBox":
		touching_attack = true
		pass
	return


func _on_ki_area_area_exited(area:Area2D) -> void:
	if area.name == "AttackHitBox":
		touching_attack = false
		pass
	return
