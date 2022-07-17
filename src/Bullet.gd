extends RigidBody2D

export(float) var ttl = 5.0

var side: String

onready var anim = $AnimatedSprite
onready var remove_timer = $RemoveTimer

var shot_by_player: bool

### ready #####################################################################

func _ready():
  remove_timer.start(ttl)

  if side:
    anim.set_animation(side)

### physics_process #####################################################################

# func _physics_process(_delta):
#   pass

### kill #####################################################################

func kill():
  # TODO body destroyed animation/shrink/something?
  # TODO still valid?
  queue_free()

func _on_RemoveTimer_timeout():
  kill()

### side/color #####################################################################

func set_side(s):
  side = s

### collisions #####################################################################

# matching sides == hit?

func _on_Area2D_body_entered(body:Node):
  if body != self:
    # was bullet fired by player or enemy?
    if shot_by_player and body.is_in_group("enemies"):
      if body.has_method("hit"):
        body.hit(side)
      kill()
    elif not shot_by_player and body.is_in_group("player"):
      if body.has_method("hit"):
        body.hit(side)
      kill()
    elif body is TileMap:
      kill()
    else:
      if shot_by_player:
        print("player bullet: ", self, " hit : ", body)
      else:
        pass
        # print(body)
