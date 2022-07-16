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
