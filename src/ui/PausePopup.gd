extends PopupPanel

onready var song = $PauseSong

var playback_pos

func resume_song():
  if playback_pos:
    song.play(playback_pos)
  else:
    song.play()

func pause_song():
  song.stop()
  playback_pos = song.get_playback_position()



func _on_MainMenu_pressed():
  ProgressionState.resume()
  Nav.goto_main_menu()

func _on_Unpause_pressed():
  ProgressionState.resume()
