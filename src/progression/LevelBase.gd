extends Node2D
class_name LevelBase

var enemy_scene = preload("res://src/Enemy.tscn")
var hud_scene = preload("res://src/ui/HUD.tscn")
var hud: CanvasLayer

onready var sounds = $Sounds

onready var player_start = $PlayerStart
var player
var portals = []
var upgrades = []

var enemies = []
var enemy_starts = []

signal enemies_cleared

# ready #######################################################################

func _ready():
  assert(player_start)
  assert(sounds)

  portals = get_tree().get_nodes_in_group("portals")
  upgrades = get_tree().get_nodes_in_group("upgrades")
  enemies = get_tree().get_nodes_in_group("enemies")
  enemy_starts = get_tree().get_nodes_in_group("enemy_starts")

  if not hud or not is_instance_valid(hud):
      print("progression state creating hud!")
      hud = hud_scene.instance()
      call_deferred("add_child", hud)

      hud.connect("ready", self, "setup_level")

  print("level ready")

func setup_level():
  print("setup level")
  ProgressionState.ensure_hud()
  ProgressionState.ensure_pause()
  ProgressionState.set_current_level(self)

  for up in upgrades:
    up.connect("collected", self, "_on_upgrade_collected", [up])

  player = ProgressionState.spawn_player(player_start)
  player.connect("roll_start", self, "_on_player_roll_start")
  player.connect("rolled", self, "_on_player_rolled")
  player.connect("death", self, "_on_player_death", [player])

  for en in enemies:
    en.connect("death", self, "_on_enemy_death", [en])

  for e_st in enemy_starts:
    spawn_enemy(e_st)

  connect("enemies_cleared", self, "_on_enemies_cleared")

### enemy spawn, death ###########################################################

func spawn_enemy(pos:Position2D):
  var enemy = enemy_scene.instance()
  enemies.append(enemy)
  enemy.connect("death", self, "_on_enemy_death", [enemy])
  enemy.position = pos.position
  var sides = [pos.initial_side]
  sides.append_array(pos.other_sides)
  enemy.available_sides = sides
  get_tree().get_root().call_deferred("add_child", enemy)

func _on_enemy_death(en):
  enemies.erase(en)
  sounds.enemy_die_sound.play()

  if enemies.size() <= 0:
    emit_signal("enemies_cleared")
    sounds.enemies_cleared_sound.play()
  else:
    print(enemies.size(), " enemies remaining")

# _on_enemies_cleared #######################################################################

func _on_enemies_cleared():
  print("enemies cleared!")

# _on_upgrade_collected #######################################################################

func _on_upgrade_collected(_upgrade):
  print("upgrade collected!")

# _on_player_death #######################################################################

func _on_player_death(_p):
  print("player death")
  sounds.player_death_sound.play()

# _on_player_roll_start #######################################################################

func _on_player_roll_start():
  print("player roll start")
  sounds.player_roll_sound.play()

# _on_player_rolled #######################################################################

func _on_player_rolled():
  print("player rolled")

# hide/show portals #######################################################################

func hide_portals():
  for p in portals:
    p.visible = false
    p.disabled = true

func show_portals():
  for p in portals:
    p.visible = true
    p.disabled = false
