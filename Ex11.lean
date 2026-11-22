import ReadySetBoole.Curve

open ReadySetBoole

private def parseFloat (s : String) : Option Float :=
  match s.toNat? with
  | some n => some n.toFloat
  | none =>
    -- accept simple "0", "1", "0.0", "1.0"
    if s == "0.0" || s == "0." then some 0.0
    else if s == "1.0" || s == "1." then some 1.0
    else none

def main (args : List String) : IO UInt32 := do
  let n ← match args with
    | [s] =>
      match parseFloat s with
      | some n => pure n
      | none => do
        IO.eprintln "usage: ex11 <f64>"
        return 1
    | [] => pure (map 0 0)
    | _ => do
      IO.eprintln "usage: ex11 <f64>"
      return 1
  let (x, y) ← reverseMap n
  IO.println s!"({x}, {y})"
  return 0
