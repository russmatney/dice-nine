extends Node2D

export(String) var upgrade_name = "no-op"

signal collected

func _on_Area2D_body_entered(body:Node):
  if body.is_in_group("player"):
    ProgressionState.unlock_next_side()
    emit_signal("collected")
    # TODO announcement via HUD/Notifs/Banner
    kill() # remove from the screen


func kill():
  queue_free()
