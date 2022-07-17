extends PopupPanel

onready var song = $PauseSong
onready var voice = $GameOverVoice

func _on_MainMenu_pressed():
	Nav.goto_main_menu()

func _on_Start_Over_pressed():
	Nav.start()
