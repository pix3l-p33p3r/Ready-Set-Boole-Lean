import ReadySetBoole.Formula

open ReadySetBoole

def main (args : List String) : IO UInt32 := do
  let formula ← match args with
    | [f] => pure f
    | [] => pure "AB&C|"
    | _ => do
      IO.eprintln "usage: ex04 <rpn-formula>"
      return 1
  printTruthTable formula
  return 0
