# Same-entry JS screen without Clang

`run.py` runs the actual checked upstream JS sibling of the native Bend compiler
entry. It uses the original CLI argument protocol, existing `node-files.cjs`
syscall transport and authentic Phase88 prepared-Base carrier/runtime. It does
not substitute a Node compiler driver, decode the cache in Python, or claim
native execution/B2 provenance. No target runs during `--check-only`.

Root can screen the existing checked acquisition with:

```sh
python3 -B selfhost/tools/performance/phase90/js-sibling/run.py \
  selfhost/build/phase90/native-tables-stack01/report.json \
  selfhost/build/phase90/js-sibling01 --self-source
```

The default runs raw upstream JS. `--compat-equality` explicitly uses the
existing Phase86 primitive `String.eq` guard, preserving the original fallback
and labeling the derivative separately. Its complete transformation is checked
against the raw image. Retain a failed raw attempt and use a fresh output tree
if that compatibility option is needed. No other generated function or runtime
algorithm is changed.

Order is live Small, live Map, cached Small, cached Map, then optional same frozen
source. Each of the four controls must match the independent full C digest and
length, including all five outputs if `--calls 5` is selected. Cached execution
starts only after the live controls pass. Self-source output has no implicit
oracle and remains independently unqualified. Default self guard is 120 s;
`--self-seconds 60` or `180` is available. Every job retains the usual CPU3,
2 GiB RSS, 4 GiB free-memory and 64 MiB per-file guard, with a 1 GiB Node heap.
Timing logs distinguish preparation and requests; before/after input hashes and
failures are preserved. Inherited `BEND_*` and `NODE_OPTIONS` overrides are removed.

Admission replays the exact source derivation, checks pinned upstream load/check
and emission receipts, preserves the reference entry and carrier-decoder
definitions, and reuses the nine-effect reference proof and authenticated cache
producer. It requires an actual completed Phase90 acquisition, not a newly
asserted stamp. Current source `74b390d3…` and JS `c9ce274a…` passed offline
admission with 142 input pins. Preparation executed no compiler or target.

This saves a full Clang build for rejected candidates. JS timing is a useful
algorithmic screen, not a prediction of native linked-string ownership costs.
Native component tests and a qualified native run remain necessary for promotion.
The current acquisition still spends 74.36 s emitting C versus 10.53 s for
load/check/JS; a separate checked JS-only acquisition mode could shorten the
earlier screen further. This runner does not change the existing acquisition
method or accept a partial acquisition as complete.
