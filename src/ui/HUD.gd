extends CanvasLayer

var lives_anim: AnimatedSprite
var lives: int = 0

var dice := []
var dice_label
var dice1
var dice2
var dice3
var dice4
var dice5
var dice6

### ready #####################################################################

func _ready():
  lives_anim = find_node("LivesAnim")

  dice_label = find_node("DiceLabel")
  dice1 = find_node("Dice1")
  dice2 = find_node("Dice2")
  dice3 = find_node("Dice3")
  dice4 = find_node("Dice4")
  dice5 = find_node("Dice5")
  dice6 = find_node("Dice6")

  if lives:
    set_lives(lives)

  hide_dice()
  if dice.size() > 0:
    set_dice()

### lives #####################################################################

func set_lives(num: int):
  lives = num
  var anim = "none"
  match num:
    0: anim = "none"
    1: anim = "one"
    2: anim = "two"
    3: anim = "three"
    4: anim = "four"
    5: anim = "five"
    6: anim = "six"

  print("setting lives_anim", num, anim, lives_anim)
  if lives_anim:
    lives_anim.set_animation(anim)

### dice #####################################################################

func hide_dice():
  dice1.visible = false
  dice2.visible = false
  dice3.visible = false
  dice4.visible = false
  dice5.visible = false
  dice6.visible = false
  dice_label.visible = false

func set_dice(d: Array = dice):
  dice = d
  # TODO animate a new dice's entrance
  if dice.size() > 0:
    # TODO maybe ignore if dice is "none"
    if dice_label:
      dice_label.visible = true
  if dice1:
    for d in dice:
      match d:
        "one": dice1.visible = true
        "two": dice2.visible = true
        "three": dice3.visible = true
        "four": dice4.visible = true
        "five": dice5.visible = true
        "six": dice6.visible = true
