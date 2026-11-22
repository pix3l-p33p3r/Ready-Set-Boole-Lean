namespace ReadySetBoole

/-- Exercise 00 — adder via XOR + AND-shift carry. No `+` on the result. -/
partial def adder (a b : UInt32) : UInt32 :=
  let rec go (x y : UInt32) : UInt32 :=
    if y == 0 then x
    else
      let carry := (x &&& y) <<< 1
      go (x ^^^ y) carry
  go a b

/-- Exercise 01 — multiplier via 32 shift-add steps using `adder`. -/
def multiplier (a b : UInt32) : UInt32 :=
  Id.run do
    let mut acc : UInt32 := 0
    let mut x := a
    let mut y := b
    for _ in [:32] do
      if (y &&& 1) != 0 then
        acc := adder acc x
      x := x <<< 1
      y := y >>> 1
    return acc

/-- Exercise 02 — binary reflected Gray code. -/
def grayCode (n : UInt32) : UInt32 :=
  n ^^^ (n >>> 1)

end ReadySetBoole
