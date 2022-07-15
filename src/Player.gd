extends KinematicBody2D

var bullet_speed = 2000
var bullet = preload("res://src/Bullet.tscn")

onready var fire_position = $FirePosition
onready var anim = $AnimatedSprite

var fire_delay = 0.3
var next_fire_in = 0

onready var roll_timer = $RollTimer
var rolling := false
var roll_time := 0.3
var roll_delay := 0.3
var next_roll_in := 0.0

var current_side = "one"
var next_side := "one"

### ready #####################################################################

func _ready():
  if current_side:
    set_side(current_side)

### set_side ##############################################################

func set_side(side=null):
  if side:
    current_side = side
  anim.set_animation(current_side)

### control #####################################################################

func control_direction():
  var dir = Vector2()

  if Input.is_action_pressed("move_right"):
    dir.x += 1
  if Input.is_action_pressed("move_left"):
    dir.x -= 1
  if Input.is_action_pressed("move_down"):
    dir.y += 1
  if Input.is_action_pressed("move_up"):
    dir.y -= 1

  return dir.normalized()

func is_fire_pressed():
  return Input.is_action_pressed("fire")

func is_roll_pressed():
  return Input.is_action_pressed("roll")

### physics process ##########################################################

var speed = 500
var velocity = Vector2()

func _physics_process(delta):
  var intended = control_direction()

  # use delta here?
  var v_diff = intended * speed
  velocity = move_and_slide(v_diff)

  look_at(get_global_mouse_position())

  if is_fire_pressed() and next_fire_in <= 0:
    fire()
    next_fire_in = fire_delay
  else:
    next_fire_in -= delta

  if is_roll_pressed() and next_roll_in <= 0:
    roll()
    next_roll_in = roll_delay
  else:
    next_roll_in -= delta


### fire ####################################################################

func fire():
  var new_bullet = bullet.instance()

  # use player current_side to set bullet side
  new_bullet.set_side(current_side)

  new_bullet.position = fire_position.get_global_position()
  new_bullet.rotation_degrees = rotation_degrees
  new_bullet.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
  get_tree().get_root().call_deferred("add_child", new_bullet)

### roll ####################################################################

func roll():
  # TODO do a spin! tween?
  rolling = true
  roll_timer.start(roll_time)
  anim.set_animation("roll")
  next_side = Dice.roll_six_sided([current_side])

func _on_RollTimer_timeout():
  rolling = false
  set_side(next_side)
