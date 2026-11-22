namespace ReadySetBoole

inductive Ast where
  | val : Bool → Ast
  | var : UInt8 → Ast
  | not : Ast → Ast
  | and : Ast → Ast → Ast
  | or  : Ast → Ast → Ast
  | xor : Ast → Ast → Ast
  | imp : Ast → Ast → Ast
  | iff : Ast → Ast → Ast
  deriving Repr, Inhabited

private def parse (formula : String) : Except String Ast := do
  let mut st : Array Ast := #[]
  for c in formula.toList do
    match c with
    | '0' => st := st.push (.val false)
    | '1' => st := st.push (.val true)
    | c =>
      if 'A' ≤ c && c ≤ 'Z' then
        st := st.push (.var (c.toNat.toUInt8 - 'A'.toNat.toUInt8))
      else if c == '!' then
        match st.back? with
        | none => throw "invalid formula"
        | some x =>
          st := st.pop
          st := st.push (.not x)
      else if c == '&' || c == '|' || c == '^' || c == '>' || c == '=' then
        let r ← match st.back? with
          | none => throw "invalid formula"
          | some x => pure x
        st := st.pop
        let l ← match st.back? with
          | none => throw "invalid formula"
          | some x => pure x
        st := st.pop
        let node := match c with
          | '&' => Ast.and l r
          | '|' => Ast.or l r
          | '^' => Ast.xor l r
          | '>' => Ast.imp l r
          | '=' => Ast.iff l r
          | _ => unreachable!
        st := st.push node
      else
        throw s!"invalid character: {c}"
  if st.size != 1 then
    throw "invalid formula"
  return st[0]!

/-- Parse with stderr on error (IO). -/
def parseFormula (formula : String) : IO (Option Ast) := do
  match parse formula with
  | .ok ast => return some ast
  | .error e =>
    IO.eprintln s!"error: {e}"
    return none

private partial def evalAst (ast : Ast) (env : Array Bool) : Bool :=
  match ast with
  | .val v => v
  | .var i => env[i.toNat]!
  | .not x => !(evalAst x env)
  | .and a b => evalAst a env && evalAst b env
  | .or a b => evalAst a env || evalAst b env
  | .xor a b => evalAst a env != evalAst b env
  | .imp a b => !(evalAst a env) || evalAst b env
  | .iff a b => evalAst a env == evalAst b env

private partial def walkVars (ast : Ast) (seen : Array Bool) : Array Bool :=
  match ast with
  | .val _ => seen
  | .var i => seen.set! i.toNat true
  | .not x => walkVars x seen
  | .and a b | .or a b | .xor a b | .imp a b | .iff a b =>
      walkVars b (walkVars a seen)

private def vars (ast : Ast) : Array UInt8 :=
  let seen := walkVars ast (Array.replicate 26 false)
  Id.run do
    let mut out : Array UInt8 := #[]
    for i in [:26] do
      if seen[i]! then
        out := out.push i.toUInt8
    return out

private partial def rewrite (ast : Ast) : Ast :=
  match ast with
  | .val v => .val v
  | .var i => .var i
  | .not x => .not (rewrite x)
  | .and a b => .and (rewrite a) (rewrite b)
  | .or a b => .or (rewrite a) (rewrite b)
  | .imp a b => .or (.not (rewrite a)) (rewrite b)
  | .iff a b =>
      let a := rewrite a
      let b := rewrite b
      .or (.and a b) (.and (.not a) (.not b))
  | .xor a b =>
      let a := rewrite a
      let b := rewrite b
      .or (.and a (.not b)) (.and (.not a) b)

private partial def pushNot (ast : Ast) (neg : Bool) : Ast :=
  match ast with
  | .val v => .val (v != neg)
  | .var i => if neg then .not (.var i) else .var i
  | .not x => pushNot x (!neg)
  | .and a b =>
      let a := pushNot a neg
      let b := pushNot b neg
      if neg then .or a b else .and a b
  | .or a b =>
      let a := pushNot a neg
      let b := pushNot b neg
      if neg then .and a b else .or a b
  | .xor _ _ | .imp _ _ | .iff _ _ => pushNot (rewrite ast) neg

private def nnfAst (ast : Ast) : Ast :=
  pushNot (rewrite ast) false

private partial def rpnNnf (ast : Ast) : String :=
  match ast with
  | .val false => "0"
  | .val true => "1"
  | .var i => String.singleton (Char.ofNat ('A'.toNat + i.toNat))
  | .not x => rpnNnf x ++ "!"
  | .and a b => rpnNnf a ++ rpnNnf b ++ "&"
  | .or a b => rpnNnf a ++ rpnNnf b ++ "|"
  | .xor _ _ | .imp _ _ | .iff _ _ => rpnNnf (nnfAst ast)

private partial def dist (a b : Ast) : Ast :=
  match a, b with
  | .and a1 a2, b => .and (dist a1 b) (dist a2 b)
  | a, .and b1 b2 => .and (dist a b1) (dist a b2)
  | a, b => .or a b

private partial def cnfAst (ast : Ast) : Ast :=
  match ast with
  | .and a b => .and (cnfAst a) (cnfAst b)
  | .or a b => dist (cnfAst a) (cnfAst b)
  | other => other

private partial def collectAnd (ast : Ast) (out : Array Ast) : Array Ast :=
  match ast with
  | .and a b => collectAnd b (collectAnd a out)
  | other => out.push other

private partial def collectOr (ast : Ast) (out : Array Ast) : Array Ast :=
  match ast with
  | .or a b => collectOr b (collectOr a out)
  | other => out.push other

private def rpnCnf (ast : Ast) : String :=
  let clauses := collectAnd ast #[]
  Id.run do
    let mut s := ""
    for c in clauses do
      let lits := collectOr c #[]
      for lit in lits do
        s := s ++ rpnNnf lit
      for _ in [1:lits.size] do
        s := s.push '|'
    for _ in [1:clauses.size] do
      s := s.push '&'
    return s

/-- Exercise 03 — evaluate a closed RPN propositional formula. -/
def evalFormula (formula : String) : IO Bool := do
  match ← parseFormula formula with
  | none => return false
  | some ast =>
    if !(vars ast).isEmpty then
      IO.eprintln "error: formula has unbound variables"
      return false
    return evalAst ast (Array.replicate 26 false)

/-- Exercise 04 — print truth table (subject gold format). -/
def printTruthTable (formula : String) : IO Unit := do
  match ← parseFormula formula with
  | none => pure ()
  | some ast =>
    let vs := vars ast
    let n := vs.size
    let mut out := "|"
    for v in vs do
      out := out ++ s!" {Char.ofNat ('A'.toNat + v.toNat)} |"
    out := out ++ " = |\n|"
    for _ in [:n+1] do
      out := out ++ "---|"
    out := out.push '\n'
    let rows := 1 <<< n
    let mut env := Array.replicate 26 false
    for i in [:rows] do
      out := out.push '|'
      for k in [:n] do
        let v := vs[k]!
        let bit := (i >>> (n - 1 - k)) &&& 1
        env := env.set! v.toNat (bit == 1)
        out := out ++ s!" {bit} |"
      let r := if evalAst ast env then 1 else 0
      out := out ++ s!" {r} |\n"
    IO.print out

/-- Exercise 05 — Negation Normal Form. -/
def negationNormalForm (formula : String) : IO String := do
  match ← parseFormula formula with
  | none => return ""
  | some ast => return rpnNnf (nnfAst ast)

/-- Exercise 06 — Conjunctive Normal Form. -/
def conjunctiveNormalForm (formula : String) : IO String := do
  match ← parseFormula formula with
  | none => return ""
  | some ast => return rpnCnf (cnfAst (nnfAst ast))

/-- Exercise 07 — SAT via brute-force 2ⁿ. -/
def sat (formula : String) : IO Bool := do
  match ← parseFormula formula with
  | none => return false
  | some ast =>
    let vs := vars ast
    let n := vs.size
    let rows := 1 <<< n
    let mut env := Array.replicate 26 false
    for i in [:rows] do
      for k in [:n] do
        let v := vs[k]!
        env := env.set! v.toNat (((i >>> k) &&& 1) == 1)
      if evalAst ast env then
        return true
    return false

end ReadySetBoole
