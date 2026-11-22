import ReadySetBoole.Formula

open ReadySetBoole

def main (args : List String) : IO UInt32 := do
  let formula ← match args with
    | [f] => pure f
    | [] => pure "AB|"
    | _ => do
      IO.eprintln "usage: ex07 <rpn-formula>"
      return 1
  let b ← sat formula
  IO.println (if b then "true" else "false")
  return 0
