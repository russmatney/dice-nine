extends LevelBase

### ready #####################################################################

func _ready():
  .hide_portals()

# _on_enemies_cleared #######################################################################

func _on_enemies_cleared():
  ._on_enemies_cleared()
  .show_portals()
