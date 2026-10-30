#!/bin/bash
# Deterministic band check: latest value vs mean/stddev of the previous N points.
# Prints one line per metric: name tier z latest mean. Exit 3 if any metric hits 3sigma.
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
N=$(awk '/^baseline_window:/{print $2}' ops/bands.yaml)
worst=0
while read -r name dir; do
  f="ops/metrics/$name.csv"
  [ -f "$f" ] || { echo "$name no-data"; continue; }
  # Rows whose value isn't a number (the date,value header) are skipped, not read as 0.
  read -r tier z latest mean < <(tail -n $((N+1)) "$f" | awk -F, -v dir="$dir" '
    $2 !~ /^-?[0-9]*\.?[0-9]+$/ {next}
    {v[++c]=$2} END {
      n=c-1; if (n<3) {print "no-baseline 0 " v[c] " 0"; exit}
      for(i=1;i<=n;i++) s+=v[i]; m=s/n
      for(i=1;i<=n;i++) q+=(v[i]-m)^2; sd=sqrt(q/n); if (sd==0) sd=1e-9
      z=(v[c]-m)/sd; if (dir=="lower_is_bad") z=-z
      t = z>=3 ? "3sigma" : z>=2 ? "2sigma" : z>=1 ? "1sigma" : "ok"
      printf "%s %.2f %s %.3f\n", t, z, v[c], m }')
  echo "$name $tier z=$z latest=$latest mean=$mean" | tee -a ops/bands.log
  [ "$tier" = "3sigma" ] && worst=3
done < <(awk '/- name:/{n=$3} /direction:/{print n, $2}' ops/bands.yaml)
exit $worst
