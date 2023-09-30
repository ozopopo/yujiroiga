extends Node2D

signal CAR_HIT

@export var moveable:bool = true
@export var speed:float = 3
@export var attackHealth:float = 300
@export var attackHealthRatio:int = 100

@onready var playerAttack:Node2D = $Attack

const ATTACK_HEALTH_MAX:float = 300
const ATTACK_HEALTH_GAIN_TIME:int = 5

var areaEntering:bool = false
var touchingWall:bool = false
var attackHealthGainTimer:int = 0

var dir:Vector2 = Vector2(0,1)
var animDir:Vector2 = Vector2(0,1)
var enteredDir:Vector2 

func _physics_process(delta:float) -> void:
	
	if moveable:
		dir.x = int(Input.is_key_pressed(KEY_RIGHT)||Input.is_key_pressed(KEY_D))-int(Input.is_key_pressed(KEY_LEFT)||Input.is_key_pressed(KEY_A))
		dir.y = int(Input.is_key_pressed(KEY_DOWN)||Input.is_key_pressed(KEY_S))-int(Input.is_key_pressed(KEY_UP)||Input.is_key_pressed(KEY_W))

		if dir.length() == 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.seek(0)
		else:
			if dir.y != 0:
				animDir.x = 0
				animDir.y = dir.y
			else:
				animDir.x = dir.x
				animDir.y = 0
			$AnimationPlayer.play("walk%d%d" % [int(animDir.x)+1, int(animDir.y)+1])
#			$AnimationPlayer.play("walk"+var_to_str(int(dir.x + 1))+var_to_str(int(dir.y + 1)))

		if touchingWall:
			position -= enteredDir.normalized() * speed
		else:
			position += dir * speed
			
		#attack
		_set_atatck_health()
		if (Input.is_key_pressed(KEY_SPACE) || Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) && attackHealth > 1:
			attackHealth -= 1
			
			var modu:Color = $Attack.modulate
			var opacity:float = (attackHealth+30)/ATTACK_HEALTH_MAX
#			print("attackhealth: %d" % [attackHealth])
#			print(opacity)
			$Attack.modulate = Color(modu.r,modu.g,modu.b,clamp(opacity,0,1))
			
			$Attack.position = animDir * 24
			$Attack.rotation = atan2(animDir.y,animDir.x) + PI/2
			
			$Attack.show()
			$Attack/AttackHitBox/CollisionShape2D.disabled = false
		else:
			$Attack.hide()
			$Attack/AttackHitBox/CollisionShape2D.disabled = true
	else:
		$Attack.hide()
		
	return

func _set_atatck_health() -> void:
	attackHealthGainTimer += 1
	if attackHealthGainTimer == ATTACK_HEALTH_GAIN_TIME:
		attackHealth += 1
		attackHealthGainTimer = 0
	if 0 < attackHealth && attackHealth < 10:
		attackHealth = -100
	if -10 < attackHealth && attackHealth < 0:
		attackHealth = 10
	$Label.text = var_to_str(attackHealth) + "\n" + var_to_str($Attack.modulate)
	attackHealth = clamp(attackHealth, -100, ATTACK_HEALTH_MAX)
	
	attackHealthRatio = 100 * (clamp(attackHealth, 0, ATTACK_HEALTH_MAX)/ATTACK_HEALTH_MAX)
	return

func _on_area_2d_area_entered(area:Area2D) -> void:
	print("entererd areaname: %s" % [area.name])
	if area.name.contains("Wall"):
		touchingWall = true
		enteredDir = dir
	if area.name == "JosouzaiHitBox":
		$JosouzaiGet.play()
		attackHealth = ATTACK_HEALTH_MAX
		area.queue_free()
	if area.name.contains("Car"):
		emit_signal("CAR_HIT")
	areaEntering = true
	return


func _on_area_2d_area_exited(area:Area2D) -> void:
	print("exited areaname: %s" % [area.name])	
	if area.name.contains("Wall"):
		touchingWall = false
		enteredDir = Vector2.ZERO
	areaEntering = false
	return
