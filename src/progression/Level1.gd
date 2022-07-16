extends LevelBase

# ready #######################################################################

func _ready():
  pass

func _on_enemy_death(en):
  # invoke parent method
  ._on_enemy_death(en)
  print("child on enemy death")
