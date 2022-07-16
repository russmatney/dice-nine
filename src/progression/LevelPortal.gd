extends Node2D



func _on_Area2D_body_entered(body:Node):
  if body.is_in_group("player"):
    ProgressionState.goto_next_level()
