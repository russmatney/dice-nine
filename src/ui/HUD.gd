extends CanvasLayer

var lives_anim: AnimatedSprite
var lives: int = 0

onready var dice_scene = preload("res://src/ui/HUDDice.tscn")

### ready #####################################################################

func _ready():
  lives_anim = find_node("LivesAnim")

  player_dice = find_node("Player")
  dice_container = find_node("DiceContainer")

  if lives:
    set_lives(lives)

### lives #####################################################################

func set_lives(num: int):
  lives = num
  var anim = Dice.side_for_num(lives)
  if lives_anim:
    lives_anim.set_animation(anim)

### dice #####################################################################

var dice_offset_x = 32
var player_dice
var clone_dice = []
var dice_container

func set_dice(player_side, clone_sides = []):
  player_dice.set_animation(player_side)

  # clear clones
  for d in clone_dice:
    d.queue_free()

  if dice_container:
    # reset
    clone_dice = []
    var i = 1
    for side in clone_sides:
      var clone_die = dice_scene.instance()
      clone_die.set_animation(side)
      clone_die.position = player_dice.transform.origin + Vector2(dice_offset_x * i, 0)
      dice_container.add_child(clone_die)
      i += 1
