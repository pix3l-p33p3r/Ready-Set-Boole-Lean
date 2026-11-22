import ReadySetBoole.Curve

open ReadySetBoole

private def parseFloat (s : String) : Option Float :=
  match s.toNat? with
  | some n => some n.toFloat
  | none =>
    let parts := s.splitOn "."
    match parts with
    | [a, b] =>
      match a.toNat?, (if b.isEmpty then some 0 else b.toNat?) with
      | some ai, some bi =>
        let denom := (10 : Nat) ^ b.length
        some (ai.toFloat + bi.toFloat / denom.toFloat)
      | none, some bi =>
        if a.isEmpty then
          let denom := (10 : Nat) ^ b.length
          some (bi.toFloat / denom.toFloat)
        else none
      | _, _ => none
    | _ => none

def main (args : List String) : IO UInt32 := do
  match args with
  | ["--rt", sx, sy] =>
    -- exact Morton round-trip (avoids Float print/parse loss)
    match sx.toNat?, sy.toNat? with
    | some x, some y =>
      let (x', y') := reverseMapExact x.toUInt16 y.toUInt16
      IO.println s!"({x'}, {y'})"
      return 0
    | _, _ =>
      IO.eprintln "usage: ex11 --rt <u16> <u16>"
      return 1
  | [s] =>
    match parseFloat s with
    | some n =>
      let (x, y) ← reverseMap n
      IO.println s!"({x}, {y})"
      return 0
    | none =>
      IO.eprintln "usage: ex11 <f64> | ex11 --rt <u16> <u16>"
      return 1
  | [] =>
    let (x, y) ← reverseMap (map 0 0)
    IO.println s!"({x}, {y})"
    return 0
  | _ =>
    IO.eprintln "usage: ex11 <f64> | ex11 --rt <u16> <u16>"
    return 1
