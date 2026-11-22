namespace ReadySetBoole

private def spread (n0 : UInt32) : UInt32 :=
  let n := n0 &&& 0xFFFF
  let n := (n ||| (n <<< 8)) &&& 0x00FF00FF
  let n := (n ||| (n <<< 4)) &&& 0x0F0F0F0F
  let n := (n ||| (n <<< 2)) &&& 0x33333333
  (n ||| (n <<< 1)) &&& 0x55555555

private def compact (n0 : UInt32) : UInt32 :=
  let n := n0 &&& 0x55555555
  let n := (n ||| (n >>> 1)) &&& 0x33333333
  let n := (n ||| (n >>> 2)) &&& 0x0F0F0F0F
  let n := (n ||| (n >>> 4)) &&& 0x00FF00FF
  (n ||| (n >>> 8)) &&& 0x0000FFFF

private def morton (x y : UInt16) : UInt32 :=
  spread x.toUInt32 ||| (spread y.toUInt32 <<< 1)

private def demorton (z : UInt32) : UInt16 × UInt16 :=
  (compact z |>.toUInt16, compact (z >>> 1) |>.toUInt16)

private def u32Max : UInt32 := (0xffffffff : UInt32)

/-- Exercise 10 — Morton / Z-order curve into [0, 1]. -/
def map (x y : UInt16) : Float :=
  (morton x y).toFloat / u32Max.toFloat

/-- Decimal string for `map` (Lean's Float printer is %.6f and hides tiny values). -/
def mapToString (x y : UInt16) : String :=
  let num := (morton x y).toNat
  let den := u32Max.toNat
  if num == 0 then "0"
  else if num == den then "1"
  else
    Id.run do
      let mut rem := num
      let mut s := "0."
      for _ in [:20] do
        rem := rem * 10
        let digit := rem / den
        s := s ++ toString digit
        rem := rem % den
        if rem == 0 then break
      -- trim trailing zeros
      let chars := s.toList
      let trimmed := chars.reverse.dropWhile (· == '0') |>.reverse
      let trimmed := if trimmed.getLast? == some '.' then trimmed.dropLast else trimmed
      return String.ofList trimmed

/-- Exercise 11 — inverse of `map`. -/
def reverseMap (n : Float) : IO (UInt16 × UInt16) := do
  if !(n ≥ 0.0 && n ≤ 1.0) then
    IO.eprintln "error: map value out of range [0, 1]"
    return (0, 0)
  let z := Float.floor (n * u32Max.toFloat + 0.5) |>.toUInt32
  return demorton z

/-- Round-trip helper for tests. -/
def reverseMapExact (x y : UInt16) : UInt16 × UInt16 :=
  demorton (morton x y)

end ReadySetBoole
