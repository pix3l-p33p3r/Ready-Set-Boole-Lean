namespace ReadySetBoole

private def uniq (v : Array Int) : Array Int :=
  let sorted := v.qsort (· < ·)
  Id.run do
    let mut out : Array Int := #[]
    for x in sorted do
      if out.isEmpty || out.back! != x then
        out := out.push x
    return out

private def has (set : Array Int) (x : Int) : Bool :=
  Id.run do
    -- linear membership is fine for subject-sized sets
    for y in set do
      if y == x then return true
    return false

private def union (a b : Array Int) : Array Int :=
  uniq (a ++ b)

private def inter (a b : Array Int) : Array Int :=
  uniq (a.filter (fun x => has b x))

private def diff (a b : Array Int) : Array Int :=
  uniq (a.filter (fun x => !(has b x)))

private def symdiff (a b : Array Int) : Array Int :=
  union (diff a b) (diff b a)

/-- Exercise 08 — powerset. -/
def powerset (set : Array Int) : Array (Array Int) :=
  let n := set.size
  Id.run do
    let mut out : Array (Array Int) := #[]
    let limit := 1 <<< n
    for mask in [:limit] do
      let mut subset : Array Int := #[]
      for i in [:n] do
        if (mask &&& (1 <<< i)) != 0 then
          subset := subset.push set[i]!
      out := out.push subset
    return out

private def parseSetRpn (formula : String) (sets : Array (Array Int)) (univ : Array Int)
    : Except String (Array Int) := do
  let mut st : Array (Array Int) := #[]
  let mut used : Array Bool := Array.replicate 26 false
  for c in formula.toList do
    if 'A' ≤ c && c ≤ 'Z' then
      let i := c.toNat - 'A'.toNat
      used := used.set! i true
      if i >= sets.size then
        throw "not enough sets for variables"
      st := st.push sets[i]!
    else if c == '!' then
      let a ← match st.back? with
        | none => throw "invalid formula"
        | some x => pure x
      st := st.pop
      st := st.push (diff univ a)
    else if c == '&' || c == '|' || c == '^' || c == '>' || c == '=' then
      let r ← match st.back? with
        | none => throw "invalid formula"
        | some x => pure x
      st := st.pop
      let l ← match st.back? with
        | none => throw "invalid formula"
        | some x => pure x
      st := st.pop
      let res := match c with
        | '&' => inter l r
        | '|' => union l r
        | '^' => symdiff l r
        | '>' => union (diff univ l) r
        | '=' => union (inter l r) (inter (diff univ l) (diff univ r))
        | _ => unreachable!
      st := st.push res
    else
      throw s!"invalid character: {c}"
  if st.size != 1 then
    throw "invalid formula"
  let nvars := used.foldl (fun n b => if b then n + 1 else n) 0
  if nvars != sets.size then
    throw "set count does not match variable count"
  return uniq st[0]!

/-- Exercise 09 — set evaluation; universe = union of input sets. -/
def evalSet (formula : String) (sets : Array (Array Int)) : IO (Array Int) := do
  let sets := sets.map uniq
  let univ := uniq (sets.foldl (fun acc s => acc ++ s) #[])
  match parseSetRpn formula sets univ with
  | .ok v => return v
  | .error e =>
    IO.eprintln s!"error: {e}"
    return #[]

end ReadySetBoole
