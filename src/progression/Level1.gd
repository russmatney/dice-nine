extends LevelBase

onready var move_directions = $MoveDirections
onready var move_arrow = $MoveArrow

onready var dodge_directions = $DodgeDirections
onready var move_arrow2 = $MoveArrow2

onready var upgrade_arrow = $UpgradeArrow

onready var roll_directions = $RollDirections
onready var fire_directions = $FireDirections

onready var portal_arrow = $PortalArrow

### ready #####################################################################

# signal start_tut

func _ready():
  move_directions.visible = false
  fire_directions.visible = false
  move_arrow.visible = false
  move_arrow2.visible = false
  upgrade_arrow.visible = false
  portal_arrow.visible = false
  dodge_directions.visible = false
  roll_directions.visible = false

  .hide_portals()

  start_tut()
  # yield(get_tree().create_timer(1.0), "timeout")
  # connect("start_tut", self, _on_start_tut)
  # emit_signal("start_tut")

func start_tut():
  # TODO fade in?
  yield(get_tree().create_timer(0.5), "timeout")
  move_directions.visible = true
  move_arrow.visible = true
  yield(get_tree().create_timer(3), "timeout")
  dodge_directions.visible = true
  move_arrow2.visible = true
  yield(get_tree().create_timer(3), "timeout")
  upgrade_arrow.visible = true


# _on_enemies_cleared #######################################################################

func _on_enemies_cleared():
  ._on_enemies_cleared()
  .show_portals()
  yield(get_tree().create_timer(3), "timeout")
  portal_arrow.visible = true

# _on_upgrade_collected #######################################################################

func _on_upgrade_collected(upgrade):
  ._on_upgrade_collected(upgrade)
  yield(get_tree().create_timer(2), "timeout")
  roll_directions.visible = true

# _on_player_rolled #######################################################################

func _on_player_rolled():
  ._on_player_rolled()
  yield(get_tree().create_timer(2), "timeout")
  fire_directions.visible = true
