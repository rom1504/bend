# Matched actual native B2 comparison

Run the frozen methods07 `b2-compare.py` only from the root controller. It binds
explicit final-source B1 and B2 build receipts and the unchanged native request
assets. Both candidate images must name the same exact source. Baseline is the
authenticated maintained native07 B2; no B1 timing is relabeled as B2.

```
python3 -B selfhost/build/phase98/qualification-methods07/methods/b2-compare.py \
  --mode screen --b1-build FINAL_B1.json --b2-build FINAL_B2.json \
  --backend-policy selfhost/build/phase98/combined-backend-policy02/policy.json \
  --out selfhost/build/phase98/final-b2-screen01
```

The six original Phase90 screen sources and old complete C oracles are frozen
inputs. Six candidate B1 preparation requests produce exact new C oracles and
must preserve the complete all-safe diagnostic. Those preparation times are
reported separately from the comparison. Then four balanced alternating rounds
run old/new B2 for each case:48 timed requests. Every old B2 request must reproduce
its historical full C; every new B2 request must reproduce the candidate B1 C.
Both must preserve the full diagnostic and empty stdout. Differences between old
and new C are recorded and require the explicit final-source backend policy.
Full C equality across the two different backend versions is not assumed.

Request/process-wall medians, ranges, paired ratios and equal-case geometric
ratios use the same definitions as the Phase95/98 B1 screens. Request excludes
Base/runtime preparation; process wall includes startup, preparation, writing
the complete output and teardown. Both stages use CPU3, one runtime thread, GPU
off, the same prepared Base carrier and runtime/providers,2GiB RSS and4GiB
available-memory floor. Each screen request has60seconds. Every attempt and
output remains at its fresh path. No Clang or generated product runs occur here.
Independent program behavior/native69 gates remain required: candidate B1/B2
agreement can share a backend defect. All report image qualification flags stay
false because this method measures a bound candidate, not a public admission.

For a full-self request comparison, reuse the actual same-source reference and
candidate-B1 self report already needed for the B2 build:

```
python3 -B selfhost/build/phase98/qualification-methods07/methods/b2-compare.py \
  --mode self --b1-build FINAL_B1.json --b2-build FINAL_B2.json \
  --backend-policy selfhost/build/phase98/combined-backend-policy02/policy.json \
  --baseline-self-reference BASELINE_B2_REFERENCE/report.json \
  --candidate-self-reference FINAL_B1_SELF/report.json \
  --out selfhost/build/phase98/final-b2-self01
```

Both images compile the **final candidate Bend source**, not two different
self sources. The old B2 product is the existing independent reference; the new
B2 product must match the actual B1 self C used to build it. The entire unsafe
dependency diagnostic must remain identical. No extra oracle request is made.
Default is one old/new pair, matching Phase95's bounded full-input convention;
`--rounds 2` adds the reverse-order pair when the remaining window justifies it.
Each request has a300second deadline. One pair is descriptive, not a stable median
performance claim. `--check-only` authenticates inputs and reports readiness
without launching a target in either mode.

## Optional physical CPU profile proposal

The existing `phase95/profile-v2.py` hardcodes upstream B1 and its ELF-bound
unwind table. Do not point it at the new B2 or reuse the old table. If the actual
B2 timing warrants explanation, the smallest valid continuation is:

1. Use unchanged `phase88/ownership/make-table.py --binary EXACT_B2 --out FRESH`
   separately for old and new B2. It reads the existing ELF via `nm`/`readelf`,
   requires all three cleanup symbols plus `io_now_run`, and refuses unsupported
   unwind rules. This does not rebuild the compiler.
2. Root builds unchanged `sample-ownership.c` against each table using the existing
   `-std=c11 -O2 -Wall -Wextra -Werror -fPIC -shared -pthread -ldl -lrt` recipe.
   The exact sampler, table and successful guard receipt must be pinned.
3. A small explicit successor to `profile-v2.py` would select the authenticated
   B2 producer and the corresponding accepted comparator oracle, preserving all
   sampling/output gates. For Map use five requests at8ms; for self use one at8ms
   or the separately declared16ms when the25000-sample capacity requires it.
   Require512MiB output headroom, exact complete C and diagnostics, empty stdout,
   successful guarded process and all five loss counters zero.
4. Reuse unchanged `ownership/analyze.py` with the **matching ELF/table**. Keep
   compiler success, analyzer acceptance and zero-loss qualification separate.
   Inspect physical ownership return sites and exact generated C. Musttail-erased
   ancestors are not reconstructed; sampling fractions include observer overhead
   and do not estimate optimization speed or allocation counts.

No profile wrapper or target is introduced by this proposal. Timing is the first
decision gate; reuse the existing sampler only if a concrete remaining question
justifies the extra target occupancy.
