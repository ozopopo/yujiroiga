extends Control

signal FINISHED

var doing:bool = false

func start() -> void:
	if !doing:
		doing = true
		$ReadySound.play()
		$Label.text = "READY?"
		$Timer.start(3)
		
		await $Timer.timeout
		
		$StartSound.play()
		$Label.text = "START!"
		$Timer.start(1)
		
		await $Timer.timeout
		
		emit_signal("FINISHED")
		queue_free()
		
	return
