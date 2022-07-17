extends KinematicBody2D

var bullet_speed = 2000
var bullet = preload("res://src/Bullet.tscn")

onready var fire_position = $FirePosition
onready var anim = $AnimatedSprite
onready var camera = $Camera2D

var fire_delay = 0.3
var next_fire_in = 0

onready var roll_timer = $RollTimer
var rolling := false
var roll_time := 0.3
var roll_delay := 0.3
var next_roll_in := 0.0

var current_side := "none"
var next_side := ""
var respawn_side
var is_clone = false

### ready #####################################################################

func _ready():
  if respawn_side:
    set_side(respawn_side)
  elif current_side:
    set_side(current_side)

### set_side ##############################################################

func set_side(side=null):
  if side:
    current_side = side

  if anim:
    anim.set_animation(current_side)

  health = Dice.num_for_side(current_side)

  # bad pattern?
  ProgressionState.update_hud()

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
var roll_spin_force := 3000

func _physics_process(delta):
  var intended = control_direction()

  # use delta here?
  var v_diff = intended * speed

  velocity = move_and_slide(v_diff)

  if rolling:
    rotate(roll_spin_force * delta * (randi() - 0.5))
  else:
    look_at(get_global_mouse_position())

  if (is_fire_pressed() and next_fire_in <= 0
    and not rolling and current_side != "none"):
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

signal fired
onready var sounds = $Sounds

# TODO nicer helper for things like this
func play_fire_sound():
  var sound = [sounds.player_fire_sound, sounds.player_fire_sound2][randi() % 2]
  sound.play()


func fire():
  var new_bullet = bullet.instance()

  # use player current_side to set bullet side
  new_bullet.set_side(current_side)

  new_bullet.shot_by_player = true
  new_bullet.position = fire_position.get_global_position()
  new_bullet.rotation_degrees = rotation_degrees
  new_bullet.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))

  if Nav.current_scene:
    # prefer to add bullets to the current scene, so they get cleaned up
    Nav.current_scene.call_deferred("add_child", new_bullet)
  else:
    get_tree().get_root().call_deferred("add_child", new_bullet)

  play_fire_sound()
  emit_signal("fired")

### roll ####################################################################

signal roll_start
# NOTE only emitted when the side changes
signal rolled

func roll():
  rolling = true
  roll_timer.start(roll_time)
  anim.set_animation("roll")
  emit_signal("roll_start")

func _on_RollTimer_timeout():
  rolling = false
  set_side() # stop roll animation
  emit_signal("rolled")


### collisions #####################################################################

var health: int
signal hit

func play_hit_sound():
  sounds.player_hit.play()

func hit(side):
  emit_signal("hit")

  var damage = Dice.num_for_side(side)
  health -= damage
  health = max(0, health)

  # get new side using new health
  current_side = Dice.side_for_num(health)
  set_side()

  print("setting side: ", current_side)

  if health <= 0:
    kill()
  else:
    play_hit_sound()


### death #####################################################################

signal death

func kill():
  emit_signal("death")
  # TODO animation
  queue_free()

func kill_for_respawn():
  queue_free()
