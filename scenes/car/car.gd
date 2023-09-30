extends CharacterBody2D

@export var move_dir:Vector2 = Vector2(1,0)
@export var speed:float = 10
@export var car_type:int = 0
@export var enable_top_collision:bool = true

var car_move_sound:AudioStreamPlayer2D = null
var car_crash_sound:AudioStreamPlayer = null

func _ready() -> void:
	car_type = randi_range(0, 4)
	car_move_sound = $CarMoveSound
	car_crash_sound = $CarCrachSound
	
	if Settings.difficlty == 0:
		$Lights.hide()
	else:
		$Lights.show()
	
	car_move_sound.play()
	car_move_sound.connect("finished", car_move_sound.play)
	return

func _process(_delta:float) -> void:
	$Sprite2D.flip_h = move_dir.x < 0
	car_type = clamp(car_type, 0, 4)
	$AnimationPlayer.play("car%d" % [car_type])
	
	$CarHitBox/CollisionShape2D5.disabled = !enable_top_collision
	return

func _physics_process(delta:float) -> void:
#	position += speed * move_dir
	velocity = speed * move_dir / delta
	move_and_slide()
	if position.x < -3000 || 3000 < position.x || position.y < -1000 || 1000 < position.y:
		queue_free()
		pass
	return

func _on_car_hit_box_area_exited(area:Area2D) -> void:
	if area.name == "Wall%s" % ["Left" if move_dir.x < 0 else "Right"]:
		if car_crash_sound.playing:
			car_crash_sound.connect("finished", queue_free)
			pass
		else:
			queue_free()
			pass
	return

func _on_car_hit_box_area_entered(area:Area2D) -> void:
#	if area.name.contains("PlayerHitBox"):
#		car_crash_sound.play()
#		if Settings.enable_invincible_mode:
#			move_dir *= -1
#			move_dir += Vector2(randf_range(7,13),randf_range(-30,30)) * 5
#			pass
#		pass
	return

func _on_car_hit_box_body_entered(body) -> void:
	if body.name == "Player":
		car_crash_sound.play()
		if Settings.enable_invincible_mode:
			collision_layer = 0
			collision_mask = 0
			move_dir *= -1
			move_dir += Vector2(randf_range(7,13),randf_range(-20,20))
			pass
		pass
	return
