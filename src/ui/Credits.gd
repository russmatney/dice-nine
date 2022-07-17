extends Control

var credit_line_scene = preload("res://src/ui/CreditLine.tscn")
var credits_lines_container: VBoxContainer

var credits_scroll_container: ScrollContainer
var speed = 200

var initial_scroll_delay = 2.0
var scroll_delay_per_line = 0.05
var since_last_scroll = 0

func _ready():
  credits_scroll_container = find_node("CreditsScrollContainer")

  assert(credits_scroll_container, "Expected ScrollContainer node")

  credits_lines_container = find_node("CreditsLinesContainer")

  assert(credits_lines_container, "Expected VBoxContainer node")

  for lines in credits:
    var new_line = credit_line_scene.instance()
    new_line.bbcode_text = "[center]\n"
    for line in lines:
      new_line.bbcode_text += line + "\n"
    new_line.bbcode_text += "[/center]"
    credits_lines_container.add_child(new_line)

func _process(delta):
  if initial_scroll_delay <= 0:
    if since_last_scroll <= 0:
      credits_scroll_container.scroll_vertical += 1
      since_last_scroll = scroll_delay_per_line
    else:
      since_last_scroll -= delta
  else:
    initial_scroll_delay -= delta

var credits = [
  ["A game by Russell Matney"],
  ["Created for the 2022 Game Maker's Tool Kit Game Jam"],
  ["Made in Godot, Aseprite, and Emacs"],
  [
    "Songs",
    "",
    "Late Night Radio",
    "Kevin MacLeod (incompetech.com)",
    "Licensed under Creative Commons: By Attribution 4.0 License",
    "http://creativecommons.org/licenses/by/4.0",
  ],
  [
    "Sounds",
    "",
    "DWSD - Dan Wray",
    "jhd-prc-5, jhd-clp-28",
    "https://freesound.org/people/DWSD/sounds/191613",
    "Licensed under Creative Commons: By Attribution 3.0 License",
    "https://creativecommons.org/licenses/by/3.0",
    "",
    "The rest are public domain, from Kenney",
    "https://www.patreon.com/kenney"
  ],
  [
    "Fonts",
    "",
    "born2bsportyv2",
    "japanyoshi",
    "http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=383",
    "Public Domain",
  ],
  ["Many thanks to all the testers and brainstormers who listened and gave feedback during the challenge.",
    "",
    "Especially Duaa, Greg, and Josh!",
    "Thank you!"],
]
