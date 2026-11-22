import ReadySetBoole.Set

open ReadySetBoole

def main (_args : List String) : IO UInt32 := do
  let p := powerset #[0, 1, 2]
  IO.println s!"powerset size: {p.size}"
  for s in p do
    IO.println (toString s.toList)
  return 0
