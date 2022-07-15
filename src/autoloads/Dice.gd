extends Node

var six_sides = ["one", "two", "three", "four", "five", "six"]

func roll_six_sided(exclude=[]) -> String:
  var sides = []
  for side in six_sides:
    if not side in exclude:
      sides.append(side)
  return sides[randi() % sides.size()]
