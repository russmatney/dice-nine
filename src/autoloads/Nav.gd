# Navigation.gd
extends Node

var current_scene = null

###########################################################################
# ready
###########################################################################

func _ready():
  randomize()
  var root = get_tree().get_root()
  current_scene = root.get_child(root.get_child_count() - 1)

###########################################################################
# goto_scene
###########################################################################

func goto_scene(path):
  call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
  # It is now safe to remove the current scene
  current_scene.free()

  # Load the new scene.
  var s = ResourceLoader.load(path)

  # Instance the new scene.
  current_scene = s.instance()

  # Add it to the active scene, as child of root.
  get_tree().get_root().add_child(current_scene)

  # Optionally, to make it compatible with the SceneTree.change_scene() API.
  get_tree().set_current_scene(current_scene)

###########################################################################
# Public Helpers
###########################################################################

var main_menu = "res://src/ui/MainMenu.tscn"
func goto_main_menu():
  goto_scene(main_menu)

var controls = "res://src/ui/Controls.tscn"
func goto_controls():
  goto_scene(controls)

var credits = "res://src/ui/Credits.tscn"
func goto_credits():
  goto_scene(credits)

# var level_select = "res://src/ui/LevelSelect.tscn"
# func goto_level_select():
#   goto_scene(level_select)

### demos ##########################################################

var tiles_demo = "res://src/demos/TilesDemo.tscn"
func goto_tiles_demo():
  goto_scene(tiles_demo)

var enemy_demo = "res://src/demos/EnemyDemo.tscn"
func goto_enemy_demo():
  goto_scene(enemy_demo)

### levels ##########################################################

var level1 = "res://src/progression/Level1.tscn"
func goto_level1():
  # TODO consider scene transitions
  goto_scene(level1)

var level2 = "res://src/progression/Level2.tscn"
func goto_level2():
  goto_scene(level2)

var level3 = "res://src/progression/Level3.tscn"
func goto_level3():
  goto_scene(level3)


### general ##################################################################

func win():
  goto_main_menu()

func start():
  goto_level1()
