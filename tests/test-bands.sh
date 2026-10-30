#!/usr/bin/env bash
# check-bands.sh tests: tiers, direction, missing and short data, exit codes. Runs in CI.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BANDS="$ROOT/plugins/sdlc/scripts/check-bands.sh"
T=$(mktemp -d)
cd "$T" || exit 1
git init -q -b main
mkdir -p ops/metrics
fail=0; n=0
series() { # series <name> <values...>: ops/metrics/<name>.csv with a header row, one point per week
  local name="$1" i=0 v; shift
  echo "date,value" > "ops/metrics/$name.csv"
  for v in "$@"; do i=$((i+1)); printf '2026-%02d-01,%s\n' "$i" "$v" >> "ops/metrics/$name.csv"; done
}
bands() { # bands <name:direction>...: ops/bands.yaml with an 8-point baseline window
  printf 'baseline_window: 8\nmetrics:\n' > ops/bands.yaml
  local m; for m in "$@"; do printf '  - name: %s\n    direction: %s\n' "${m%%:*}" "${m#*:}" >> ops/bands.yaml; done
}
expect_tier() { # expect_tier <metric> <tier> <label>
  n=$((n+1))
  if grep -qE "^$1 $2( |\$)" <<< "$out"; then echo "ok   $3"; else echo "FAIL $3: $(grep "^$1 " <<< "$out")"; fail=1; fi
}
expect_exit() { # expect_exit <want> <label>
  n=$((n+1))
  if [ "$code" = "$1" ]; then echo "ok   $2"; else echo "FAIL $2 (want $1 got $code)"; fail=1; fi
}

BASE="10 11 9 10 11 9 10 11"  # mean 10.125, sd ~0.78
series steady  100 $BASE 10    # the old 100 falls outside the 8-point window
series slower  $BASE 12        # +2.4 sd
series better  $BASE 13        # lower_is_bad, going up is good
series short   10 11 30        # two baseline points
series flat    5 5 5 5 5 5 5 5 5
series young   10 11 9 10 10   # shorter than the window, so the header row is inside it

echo "== no breach"
bands steady:higher_is_bad slower:higher_is_bad better:lower_is_bad short:higher_is_bad flat:higher_is_bad missing:higher_is_bad young:higher_is_bad
out=$("$BANDS"); code=$?
expect_tier steady  ok          "steady metric is ok; points outside the window are ignored"
expect_tier slower  2sigma      "higher_is_bad rise of 2.4 sd is 2sigma"
expect_tier better  ok          "lower_is_bad metric going up is ok"
expect_tier short   no-baseline "fewer than 3 baseline points, header row not counted"
expect_tier flat    ok          "flat series is ok"
expect_tier missing no-data     "missing CSV is no-data"
n=$((n+1))
grep -q "^young ok .* latest=10 " <<< "$out" && echo "ok   short history reads the real latest value" || { echo "FAIL young: $(grep "^young " <<< "$out")"; fail=1; }
expect_exit 0 "exit 0 without a 3sigma breach"
n=$((n+1))
[ "$(grep -c . ops/bands.log)" = 6 ] && echo "ok   results appended to ops/bands.log" || { echo "FAIL bands.log: $(cat ops/bands.log)"; fail=1; }

echo "== breach"
series crashfree $BASE 7       # lower_is_bad drop of 4 sd
series flatjump  5 5 5 5 5 5 5 5 6
bands steady:higher_is_bad crashfree:lower_is_bad flatjump:higher_is_bad
out=$("$BANDS"); code=$?
expect_tier crashfree 3sigma "lower_is_bad drop of 4 sd is 3sigma"
expect_tier flatjump  3sigma "any jump from a flat baseline is 3sigma"
expect_exit 3 "exit 3 on a 3sigma breach"

cd / && rm -rf "$T"
[ $fail = 0 ] && echo "all $n band tests passed"
exit $fail
