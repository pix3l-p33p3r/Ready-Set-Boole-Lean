#!/usr/bin/env bash
set -euo pipefail
export ELAN_HOME="${ELAN_HOME:-/goinfre/elel-yak/elan}"
export PATH="$ELAN_HOME/bin:$PATH"
cd "$(dirname "$0")"
lake build >/dev/null
B=.lake/build/bin
fail=0
check() {
  local name="$1" got="$2" want="$3"
  if [[ "$got" == "$want" ]]; then
    echo "OK  $name"
  else
    echo "FAIL $name"
    echo "  got:  [$got]"
    echo "  want: [$want]"
    fail=1
  fi
}

check ex00 "$($B/ex00 2 3)" "5"
check ex01 "$($B/ex01 7 8)" "56"
for n_g in 0:0 1:1 2:3 3:2 4:6 5:7 6:5 7:4 8:12; do
  n=${n_g%%:*}; g=${n_g##*:}
  check "ex02_$n" "$($B/ex02 "$n")" "$g"
done
check ex03_a "$($B/ex03 '10&')" "false"
check ex03_b "$($B/ex03 '10|')" "true"
check ex03_c "$($B/ex03 '11>')" "true"
check ex03_d "$($B/ex03 '10=')" "false"
check ex03_e "$($B/ex03 '1011||=')" "true"

want04=$(printf '| A | B | C | = |\n|---|---|---|---|\n| 0 | 0 | 0 | 0 |\n| 0 | 0 | 1 | 1 |\n| 0 | 1 | 0 | 0 |\n| 0 | 1 | 1 | 1 |\n| 1 | 0 | 0 | 0 |\n| 1 | 0 | 1 | 1 |\n| 1 | 1 | 0 | 1 |\n| 1 | 1 | 1 | 1 |\n')
got04=$($B/ex04 'AB&C|')
if [[ "$got04" == "$want04" ]]; then echo "OK  ex04"; else echo "FAIL ex04"; fail=1; fi

check ex05_a "$($B/ex05 'AB&!')" "A!B!|"
check ex05_b "$($B/ex05 'AB|!')" "A!B!&"
check ex05_c "$($B/ex05 'AB>')" "A!B|"
check ex05_d "$($B/ex05 'AB=')" "AB&A!B!&|"
check ex05_e "$($B/ex05 'AB|C&!')" "A!B!&C!|"
check ex06_a "$($B/ex06 'AB&!')" "A!B!|"
check ex06_b "$($B/ex06 'AB|!')" "A!B!&"
check ex06_c "$($B/ex06 'AB|C&')" "AB|C&"
check ex06_d "$($B/ex06 'AB|C|D|')" "ABCD|||"
check ex06_e "$($B/ex06 'AB&C&D&')" "ABCD&&&"
check ex06_f "$($B/ex06 'AB&!C!|')" "A!B!C!||"
check ex06_g "$($B/ex06 'AB|!C!&')" "A!B!C!&&"
check ex07_a "$($B/ex07 'AB|')" "true"
check ex07_b "$($B/ex07 'AB&')" "true"
check ex07_c "$($B/ex07 'AA!&')" "false"
check ex07_d "$($B/ex07 'AA^')" "false"

check ex08_size "$($B/ex08 | head -1)" "powerset size: 8"

mapfile -t lines < <($B/ex09)
check ex09_0 "${lines[0]}" "[0]"
check ex09_1 "${lines[1]}" "[0, 1, 2, 3, 4, 5]"
check ex09_2 "${lines[2]}" "[]"

check ex10_00 "$($B/ex10 0 0)" "0"
check ex10_ff "$($B/ex10 65535 65535)" "1"
g10c=$($B/ex10 1 0)
if [[ "$g10c" == 0.* && "$g10c" != "0" ]]; then echo "OK  ex10_10"; else echo "FAIL ex10_10 got [$g10c]"; fail=1; fi
check ex11_0 "$($B/ex11 0)" "(0, 0)"
check ex11_1 "$($B/ex11 1)" "(65535, 65535)"
check ex11_rt10 "$($B/ex11 --rt 1 0)" "(1, 0)"
check ex11_rtxy "$($B/ex11 --rt 123 456)" "(123, 456)"
check ex11_rtff "$($B/ex11 --rt 65535 65535)" "(65535, 65535)"
check ex00_wrap "$($B/ex00 4294967295 1)" "0"
check ex01_wrap "$($B/ex01 4294967295 2)" "4294967294"

if [[ $fail -eq 0 ]]; then
  echo "ALL_PASS"
  exit 0
fi
echo "HAS_FAILURES"
exit 1
