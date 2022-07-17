extends Node

var six_sides = ["one", "two", "three", "four", "five", "six"]

func roll_six_sided(exclude=[], available=six_sides, current="") -> String:
  var sides = []
  for side in available:
    if not side in exclude:
      sides.append(side)
  if not sides.size():
    return current
  return sides[randi() % sides.size()]

func side_for_num(num: int) -> String:
  var side = "none"
  match num:
    0: side = "none"
    1: side = "one"
    2: side = "two"
    3: side = "three"
    4: side = "four"
    5: side = "five"
    6: side = "six"
    7: side = "seven"
    8: side = "eight"
    9: side = "nine"
    _: print("unknown num passed to side_for_num", num)
  return side

func num_for_side(side: String) -> int:
  var num = 0
  match side:
    "none": num = 0
    "one": num = 1
    "two": num = 2
    "three": num = 3
    "four": num = 4
    "five": num = 5
    "six": num = 6
    "seven": num = 7
    "eight": num = 8
    "nine": num = 9
    _: print("unknown side passed to num_for_side", side)
  return num
