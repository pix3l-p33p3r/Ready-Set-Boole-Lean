import ReadySetBoole.Formula

open ReadySetBoole

def main (args : List String) : IO UInt32 := do
  let formula ← match args with
    | [f] => pure f
    | [] => pure "AB&!"
    | _ => do
      IO.eprintln "usage: ex06 <rpn-formula>"
      return 1
  IO.println (← conjunctiveNormalForm formula)
  return 0
