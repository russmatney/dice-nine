extends KinematicBody2D

var bullet_speed = 2000
var bullet = preload("res://src/Bullet.tscn")

### ready #####################################################################

func _ready():
  pass # Replace with function body.


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

### physics process ##########################################################

var speed = 500
var velocity = Vector2()

func _physics_process(_delta):
  var intended = control_direction()

  var v_diff = intended * speed
  velocity = move_and_slide(v_diff)

  look_at(get_global_mouse_position())

  if is_fire_pressed():
    fire()

### fire ####################################################################

func fire():
  var new_bullet = bullet.instance()
  new_bullet.position = get_global_position()
  new_bullet.rotation_degrees = rotation_degrees
  new_bullet.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
  get_tree().get_root().call_deferred("add_child", new_bullet)
