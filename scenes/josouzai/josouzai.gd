extends Node2D

func _on_josouzai_hit_box_area_entered(area:Area2D):
	if area.name == "PlayerHitBox":
		queue_free()
		pass
	return

func _on_josouzai_hit_box_body_entered(body:CharacterBody2D) -> void:
	if body.name == "Player2" || body.name == "Player":
		queue_free()
		pass
	return
