import ReadySetBoole.Bits

open ReadySetBoole

def main (args : List String) : IO UInt32 := do
  let (a, b) ← match args with
    | [sa, sb] =>
      match sa.toNat?, sb.toNat? with
      | some a, some b => pure (a.toUInt32, b.toUInt32)
      | _, _ =>
        IO.eprintln "usage: ex00 <u32> <u32>"
        return 1
    | [] => pure (2, 3)
    | _ =>
      IO.eprintln "usage: ex00 <u32> <u32>"
      return 1
  IO.println (adder a b)
  return 0
