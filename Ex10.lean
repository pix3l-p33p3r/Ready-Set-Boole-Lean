import ReadySetBoole.Curve

open ReadySetBoole

def main (args : List String) : IO UInt32 := do
  let (x, y) ← match args with
    | [sx, sy] =>
      match sx.toNat?, sy.toNat? with
      | some x, some y => pure (x.toUInt16, y.toUInt16)
      | _, _ =>
        IO.eprintln "usage: ex10 <u16> <u16>"
        return 1
    | [] => pure ((0 : UInt16), (0 : UInt16))
    | _ =>
      IO.eprintln "usage: ex10 <u16> <u16>"
      return 1
  IO.println (map x y)
  return 0
