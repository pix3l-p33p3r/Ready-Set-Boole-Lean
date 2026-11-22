import ReadySetBoole.Bits

open ReadySetBoole

def main (args : List String) : IO UInt32 := do
  let n ← match args with
    | [s] =>
      match s.toNat? with
      | some n => pure n.toUInt32
      | none =>
        IO.eprintln "usage: ex02 <u32>"
        return 1
    | [] => pure (8 : UInt32)
    | _ =>
      IO.eprintln "usage: ex02 <u32>"
      return 1
  IO.println (grayCode n)
  return 0
