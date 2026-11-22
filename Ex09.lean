import ReadySetBoole.Set

open ReadySetBoole

def main (_args : List String) : IO UInt32 := do
  let r1 ← evalSet "AB&" #[#[0, 1, 2], #[0, 3, 4]]
  IO.println (toString r1.toList)
  let r2 ← evalSet "AB|" #[#[0, 1, 2], #[3, 4, 5]]
  IO.println (toString r2.toList)
  let r3 ← evalSet "A!" #[#[0, 1, 2]]
  IO.println (toString r3.toList)
  return 0
