extends Sprite2D

signal ATTACKED
signal KILLED

@export var health:int = 100
@export var dead:bool = false
@export var show_health:bool = false

var touching_attack:bool = false

func _ready() -> void:
	show_health = Settings.show_gairoju_health
	return

func _process(_delta:float) -> void:

	if health < 1 || dead:
		emit_signal("KILLED", 0) 
		queue_free()
		pass

	if touching_attack:
		health -= 1
		emit_signal("ATTACKED", 0)
		pass

	if show_health:
		$Label.show()
		$Label.text = var_to_str(health)
		pass
	else:
		$Label.hide()
		pass

	return


func _on_area_2d_area_entered(area:Area2D) -> void:
	if area.name == "AttackHitBox":
		touching_attack = true
	return


func _on_area_2d_area_exited(area:Area2D) -> void:
	if area.name == "AttackHitBox":
		touching_attack = false
	return
