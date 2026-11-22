# Ready, Set, Boole! (Lean 4)

42 subject v2.1 implemented in **Lean 4**. Exercises 00–11 (10–11 bonus).

Language choice is allowed by the subject (prototypes are Rust): generics, first-class functions, and bitwise integer ops.

## Requirements

- [elan](https://github.com/leanprover/elan) / Lean 4 (`lean-toolchain` pins `v4.36.0`)

On 42 machines with tiny `$HOME`, install elan on goinfre:

```bash
export ELAN_HOME=/goinfre/$USER/elan
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf \
  | sh -s -- -y --default-toolchain leanprover/lean4:v4.36.0 --no-modify-path
export PATH="$ELAN_HOME/bin:$PATH"
```

## Build

```bash
make
```

or

```bash
lake build
```

Binaries: `.lake/build/bin/ex00` … `ex11`.

Subject PDF: `Ready, Set, Boole!.en.subject.pdf`.

## Subject examples

```
$ .lake/build/bin/ex00 2 3
5
$ .lake/build/bin/ex03 10&
false
$ .lake/build/bin/ex05 AB&!
A!B!|
$ .lake/build/bin/ex04 AB&C|
| A | B | C | = |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
...
```

XOR in formulas is ASCII `^`.

## Layout

```
ReadySetBoole/
  Bits.lean      adder, multiplier, grayCode
  Formula.lean   eval, truth table, NNF, CNF, sat
  Set.lean       powerset, evalSet
  Curve.lean     map, reverseMap
Ex00.lean … Ex11.lean
```

## Rules respected

- Adder / multiplier: only `& | ^ << >>` (and loop index); no `+`/`*` on the result
- No external math libraries
- SAT is brute-force `O(2ⁿ)`
- `map` / `reverseMap`: Morton / Z-order (bonus)
