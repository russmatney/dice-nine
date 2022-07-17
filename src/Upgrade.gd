extends Node2D

export(String) var upgrade_name = "no-op"

signal collected

func _on_Area2D_body_entered(body:Node):
  if body.is_in_group("player"):
    # we depend on the levelbase listening to this signal
    emit_signal("collected")
    kill() # remove from the screen


func kill():
  queue_free()
