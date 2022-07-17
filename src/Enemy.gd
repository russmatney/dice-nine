extends KinematicBody2D

var bullet_speed = 500
var bullet = preload("res://src/Bullet.tscn")

onready var anim = $AnimatedSprite

export(bool) var disabled = false

export(int) var health = 1

export(String) var current_side: String
var next_side: String

onready var rolling_timer = $RollingTimer # doing-a-roll timer
var rolling_time := 0.2
var rolling = false
onready var roll_timer = $RollTimer # do-another-roll timer
export(float) var roll_every_t = 3.0

onready var fire_timer = $FireTimer
export(float) var fire_time = 2.0
onready var fire_pos1 = $FirePosition1
onready var fire_pos2 = $FirePosition2
onready var fire_pos3 = $FirePosition3
onready var fire_pos4 = $FirePosition4

func fire_positions():
  return [fire_pos1, fire_pos2, fire_pos3, fire_pos4]

export(Array, String) var available_sides = []

### ready #####################################################################

func _ready():
  if not current_side:
    if available_sides.size() > 0:
      current_side = available_sides[0]
    else:
      current_side = "one"
  set_side()

  if not disabled:
    fire_timer.wait_time = fire_time
    fire_timer.start(fire_time)

    # TODO maybe too hectic/want control over this behavior
    roll_timer.wait_time = roll_every_t
    roll_timer.start()

func set_side(side=null):
  if side:
    current_side = side
  anim.set_animation(current_side)

  health = Dice.num_for_side(current_side)

### physics_process #####################################################################

var roll_spin_force := 3000

func _physics_process(delta):
  if rolling:
    rotate(roll_spin_force * delta * (randi() - 0.5))

### fire #####################################################################

func fire_new_bullet(pos: Position2D):
  var new_bullet = bullet.instance()

  # use player current_side to set bullet side
  new_bullet.set_side(current_side)
  new_bullet.position = pos.get_global_position()
  new_bullet.rotation_degrees = rotation_degrees
  new_bullet.shot_by_player = false

  # get direction from origin to position
  var fire_dir = get_global_position().direction_to(new_bullet.position).normalized() * bullet_speed

  new_bullet.apply_impulse(Vector2(), fire_dir)

  if Nav.current_scene:
    # prefer to add to the current scene, which gets cleaned up
    Nav.current_scene.call_deferred("add_child", new_bullet)
  else:
    get_tree().get_root().call_deferred("add_child", new_bullet)

func fire():
  for pos in fire_positions():
    fire_new_bullet(pos)

func _on_FireTimer_timeout():
  fire()

### roll #####################################################################

func roll():
  rolling = true
  rolling_timer.start(rolling_time)
  anim.set_animation("roll")

  # excludes the current_side
  # next_side = Dice.roll_six_sided([current_side], available_sides, current_side)
  next_side = current_side # disable changing sides on roll

func _on_RollingTimer_timeout():
  rolling = false

  # no need to set new roll
  # set_side(next_side)

  # stop the roll animation
  set_side()

func _on_RollTimer_timeout():
  # if available_sides.size() > 1:
  #   # do a roll!
  #   roll()

  # allow always roll, for fun
  roll()

### collisions #####################################################################

signal hit

func hit(side):
  emit_signal("hit")
  var damage = Dice.num_for_side(side)
  health -= damage
  health = max(0, health)

  # get new side using new health
  current_side = Dice.side_for_num(health)
  set_side()

  if health <= 0:
    kill()

### death #####################################################################

signal death

func kill():
  emit_signal("death")
  # TODO animation
  queue_free()
