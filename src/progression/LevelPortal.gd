extends Node2D

export(bool) var disabled = false setget set_disabled


onready var shape = $Area2D/CollisionShape2D


func set_disabled(val: bool):
  print("portal set_disabled called", val)
  shape.set_deferred("disabled", val)
  disabled = val


func _on_Area2D_body_entered(body:Node):
  if body.is_in_group("player"):
    ProgressionState.goto_next_level()
