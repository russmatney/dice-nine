extends KinematicBody2D

var bullet_speed = 500
var bullet = preload("res://src/Bullet.tscn")

onready var anim = $AnimatedSprite

export(String) var current_side: String
var next_side: String

onready var rolling_timer = $RollingTimer # doing-a-roll timer
var rolling_time := 0.2
var rolling = false
onready var roll_timer = $RollTimer # do-another-roll timer
export(float) var roll_time = 5.0

onready var fire_timer = $FireTimer
export(float) var fire_time = 2.0
onready var fire_pos1 = $FirePosition1
onready var fire_pos2 = $FirePosition2
onready var fire_pos3 = $FirePosition3
onready var fire_pos4 = $FirePosition4

func fire_positions():
  return [fire_pos1, fire_pos2, fire_pos3, fire_pos4]

### ready #####################################################################

func _ready():
  if not current_side:
    # current_side = Dice.roll_six_sided()
    current_side = "four"

  fire_timer.wait_time = fire_time
  fire_timer.start(fire_time)

  # TODO maybe to hectic/want control over this behavior
  roll_timer.wait_time = roll_time
  roll_timer.start()

func set_side(side=null):
  if side:
    current_side = side
  anim.set_animation(current_side)

### fire #####################################################################

func fire_new_bullet(pos: Position2D):
  var new_bullet = bullet.instance()

  # use player current_side to set bullet side
  new_bullet.set_side(current_side)
  new_bullet.position = pos.get_global_position()
  new_bullet.rotation_degrees = rotation_degrees

  # get direction from origin to position
  var fire_dir = pos.transform.origin.normalized() * bullet_speed

  new_bullet.apply_impulse(Vector2(), fire_dir.rotated(rotation))
  get_tree().get_root().call_deferred("add_child", new_bullet)

func fire():
  for pos in fire_positions():
    fire_new_bullet(pos)

func _on_FireTimer_timeout():
  fire()

### roll #####################################################################

func roll():
  # TODO do a spin! tween?
  rolling = true
  rolling_timer.start(rolling_time)
  anim.set_animation("roll")
  # excludes the current_side
  next_side = Dice.roll_six_sided([current_side])

func _on_RollingTimer_timeout():
  rolling = false
  set_side(next_side)

func _on_RollTimer_timeout():
  # do a roll!
  roll()
