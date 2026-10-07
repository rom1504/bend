# Phase62 profile reader

`profiles-v2.py` reads saved receipts and V8 CPU/allocation data. It does not import
or execute a compiler. Run it on CPU0 after the target campaigns finish:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase62/analysis/profiles-v2.py \
  --report selfhost/build/phase62/generations01/cpu46/report.json \
  --report selfhost/build/phase62/generations01/allocation46/report.json \
  --out selfhost/build/phase62/profile-analysis01
```

Output must be fresh. Consumed inputs are hashed before analysis and rehashed
before writing. Worker success, exact raw emission bytes, current B2/source
identities, private image and preparation, sample policy and CPU accounting are
checked. An input failure remains a failure; the reader never selects only
successful target observations to claim a complete population.

V1's first CPU-only readback retains TypeScript stripping under Node's Amaro/WASM
implementation as unassigned. V2 recognizes exact
`node:internal/modules/typescript` ancestors `parseTypeScript`,
`processTypeScriptCode` and `stripTypeScriptModuleTypes`. It changes no sample
weight or B2 classification. The V1 source and result remain preserved; the
successor's exact edits and input/output hashes are in
`profiles-v2.derivation.json`.

The reader extends the interpretation in Phase61's saved
`state06-analysis01/derive-profiles.py` and Phase60's
`analysis/summarize-v2.py`. Neither historical tool or result is modified. The
reviewed `cpu_views` function is extracted from the pinned Phase57 Python reader
without executing its command-line body. Its exact source hash is in each output.

Every CPU event contributes one to the count view. A separate weighted view is
written only if the signed-delta policy admits it: negative timestamp increments
must each be no more than 2 microseconds in magnitude and their sum no more than
10 ppm of raw profile duration. Refused weighted views remain refused. Allocation
samples contribute their original sizes; missing tree nodes stay in an explicit
unattributed bin. Allocation estimates are cumulative, including collected
objects, and do not measure live heap, object counts or elapsed-time savings.

Every sampled leaf gets one stage, using the nearest exact module URL and actual
named ancestor. GC and inspector overhead are separate. The expanded stage map
includes previously omitted annotation, layout validation, source reach,
frontend error scans, graph freshening, book context and Base identity work.
Final library emission, initial emitted reach and host wrappers remain separate.
TypeScript's `file_book` is an upstream-specific stage, not an asserted match for
Bend's emitted reach. Unmatched leaves retain their actual names, locations and
example stacks. A shared `$scc` worker name cannot trigger source-function or
stage attribution; another real named wrapper must provide the evidence.

Substitution, normalization, indexes, strings, definition emission, call facts
and arity-query unions overlap. Their reach/final-library/host intersections
are useful bounds on represented work, but must not be added to the disjoint
stage partition or converted directly into a promised speedup. Profiler windows
include instrumentation overhead and are never clean benchmark observations.
