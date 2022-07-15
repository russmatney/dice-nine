extends RigidBody2D


export(float) var ttl = 5.0

var side: String

onready var anim = $AnimatedSprite
onready var remove_timer = $RemoveTimer

# Called when the node enters the scene tree for the first time.
func _ready():
  remove_timer.start(ttl)

  if side:
    anim.set_animation(side)

func kill():
  # should be fine?
  queue_free()

func _on_RemoveTimer_timeout():
  kill()


func set_side(s):
  side = s
