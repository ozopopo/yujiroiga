extends CharacterBody2D

signal CAR_HIT

@export var moveable:bool = true
@export var speed:float = 4.0
@export var attack_health:int = 300
@export var attack_health_ratio:int = 100

var attack_health_gain_timer:int = 0
var anim_dir:Vector2 = Vector2.ZERO

const ATTACK_HEALTH_MAX:int = 300
const ATTACK_HEALTH_DRAIN_AMOUNT:int = 1
const ATTACK_HEALTH_GAIN_TIME:int = 5

func _ready() -> void:
	if Settings.show_josouzai_zanryo:
		$Label.show()
		pass
	else:
		$Label.hide()
		pass
	return

func set_attack_health() -> void:
	attack_health_gain_timer += 1
	if attack_health_gain_timer == ATTACK_HEALTH_GAIN_TIME:
		attack_health += 1
		attack_health_gain_timer = 0
		pass
	if attack_health == 0:
		attack_health = -90
		pass
	if attack_health == -1:
		attack_health = 1
		pass
	$Label.text = "%d" % [attack_health]
	attack_health = clamp(attack_health, -90, ATTACK_HEALTH_MAX)
	attack_health_ratio = 100 * (clamp(attack_health, 0, ATTACK_HEALTH_MAX)/(ATTACK_HEALTH_MAX as float))
	$Attack.modulate = Color(1,1,1,(attack_health+30)/float(ATTACK_HEALTH_MAX))
	return

func _physics_process(delta:float) -> void:
	
	if moveable:
		var motion:Vector2 = Vector2.ZERO
		motion.x = int(Input.is_key_pressed(KEY_RIGHT)||Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_LEFT)||Input.is_key_pressed(KEY_A))
		motion.y = int(Input.is_key_pressed(KEY_DOWN)||Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_UP)||Input.is_key_pressed(KEY_W))
		
		velocity = motion.normalized() * speed / delta
		move_and_slide()
		
		if motion.length() == 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.seek(0)
			pass
		else:
			if motion.y != 0:
				anim_dir = Vector2(0, motion.y)
				pass
			else:
				anim_dir = Vector2(motion.x, 0)
				pass
			$AnimationPlayer.play("walk%d%d" % [anim_dir.x+1, anim_dir.y+1])
			pass
		
		if attack_health > 0 && (Input.is_key_pressed(KEY_SPACE) || Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			attack_health -= (ATTACK_HEALTH_DRAIN_AMOUNT*(1 if Settings.difficlty==0 else 2)) * int(!Settings.enable_infinity_josouzai)
			$Attack.show()
			$Attack/AttackHitBox/CollisionShape2D.disabled = false
			$Attack.position = anim_dir * 22
			$Attack.rotation = atan2(anim_dir.y, anim_dir.x) + PI/2
			pass
		else:
			$Attack.hide()
			$Attack/AttackHitBox/CollisionShape2D.disabled = true
			pass
			
		pass
	
	return

func _process(_delta:float) -> void:
	if moveable:
		set_attack_health()
		pass
	return

func _on_player_hit_box_area_entered(area:Area2D) -> void:
	
	if area.name == "JosouzaiHitBox":
		$JosouzaiGetSound.play()
		attack_health = ATTACK_HEALTH_MAX
		pass
	if area.name == "CarHitBox" && !Settings.enable_invincible_mode:
		emit_signal("CAR_HIT")
		pass
	
	return
