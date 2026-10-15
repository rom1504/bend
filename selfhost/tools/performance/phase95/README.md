# Native physical cleanup attribution

Reuse the unchanged Phase88 ownership sampler and analyzer. The Phase87 sampler
records leaf PCs only; it cannot provide these return addresses. No compiler image
is rebuilt or patched. Root owns all library builds and compiler executions.

The offline table at `selfhost/build/phase95/ownership-b1-table01/` was produced by
the unchanged `phase88/ownership/make-table.py` for Phase92 B1 ELF
`6bb07e94e2f8ef383a9b8a476441ea751bb2c22e92c776ae66d779a6d6b72b22`.
It accepts 55 `rsp`-relative unwind rows for `term_drop`, `span_fade`, and
`rfc_wrap`; no speculative stack scanning or frame-pointer requirement is added.

Build only `phase88/ownership/sample-ownership.c` under the root guard, using the
pinned Clang, `-std=c11 -O2 -Wall -Wextra -Werror -fPIC -shared`,
`-I /absolute/path/to/ownership-b1-table01`, and `-pthread -ldl -lrt`. Retain the
successful guard's `process.json`; use absolute table and output paths. Source
paths may be relative to the repository. The runner checks that receipt binds the
sampler, source and table directory.

```sh
python3 -B selfhost/tools/performance/phase95/profile.py \
  --case map_closed --out FRESH_MAP_DIRECTORY \
  --sampler ABSOLUTE_SAMPLE_SO --sampler-build BUILD_GUARD/process.json
python3 -B selfhost/tools/performance/phase95/profile.py \
  --case self --out FRESH_SELF_DIRECTORY \
  --sampler ABSOLUTE_SAMPLE_SO --sampler-build BUILD_GUARD/process.json
```

`--check-only` authenticates without launching a target. Map runs five requests at
4 ms sampling; self runs one at 8 ms. Both use CPU3, one runtime thread, GPU off,
the same prepared Base/cache as Phase92, a 2 GiB process-tree limit, 4 GiB memory
headroom, and a 240 s outer deadline. The 25,000-sample per-thread capacity allows
about 200 CPU seconds at 8 ms; a longer self run may exhaust it before the outer
deadline, in which case the unchanged strict analyzer rejects it. Complete C is
checked against the independent retained oracle before analysis. Compiler success
and profile usability have separate fields. Every attempt remains in its fresh
directory, including rejected captures and analyzer stderr.
At least 512 MiB of free output-filesystem space is required before launching.
The unchanged historical analyzer checks coverage but does not reject overruns;
this wrapper additionally requires zero overruns, drops, thread overflow, thread
clock failures and timer disarm failures. `analyzerAccepted` preserves the
historical reader's result separately from `diagnosticUsable`.

Read `analysis.json` by request phase, not just whole-process totals. Its
`ownership_return_sites` identifies the cleanup leaf and bounded physical chain;
`ownership_callers` assigns the nearest recovered non-cleanup owner. Confirm high
sites with the exact ELF's disassembly and
`selfhost/build/phase92/upstream-checked01/compiler.c`. Return addresses are
symbolized after subtracting one, so reported addresses fall inside the preceding
call instruction, not necessarily at its beginning. Generated `spin_*`/`WL_*`
segments must be mapped to that C before naming a Bend helper.

`term_drop` traverses children with an explicit heap-threaded stack rather than C
recursion. Samples inside it below `span_fade` belong to that same physical
ownership site; do not add nested helper estimates as independent costs. Musttail
dispatch removes logical ancestors, and inline allocation/ownership operations
have no separate runtime frame. These data establish neither general allocation
counts nor an inclusive Bend call tree. A TLS active-function diagnostic would
alter every dispatch and require another image/overhead control; defer it unless
physical attribution leaves the concrete question unresolved. Sampler elapsed
time includes observer overhead and is not a compiler speed result.

## Explicit period derivative

The frozen `profile.py` (SHA256 `3771e8e319daef36e38e1c1b7dd57dddae632e04de4e2e37d629e738573c54df`)
remains unchanged. Its first Map capture, `phase95/map-profile01`, passed all five
complete C comparisons but recorded one timer overrun; the historical analyzer
accepted it and the wrapper correctly marked `diagnosticUsable:false`.

`profile-v2.py` adds `--period-us 4000|8000|16000`, retaining case defaults when
omitted and preserving every quality gate. It records and pins its v1 origin.
The next planned Map attempt uses 8000 us to reduce sampling pressure, accepting
lower precision (roughly 950 samples across all five requests, often fewer than
200 per request). Full self also uses 8000 us. This is a declared method change;
the rejected 4000 us capture stays exploratory, and repeated attempts at the same
period are not a search for a passing result.

## Reproducible offline caller totals

```sh
python3 -B selfhost/tools/performance/phase95/callers.py \
  --capture selfhost/build/phase95/map-profile02 \
  --out FRESH_CALLER_SUMMARY.json
```

The reader requires an accepted, complete, loss-free capture. It binds the raw
samples, prior analysis, process/stderr, exact ELF, source C/Bend and reader. It
aggregates all request phases with a common denominator, records each request
separately, and divides each request into ten-second windows from its existing
clock mark. Those windows are temporal bins, not inferred compiler stages.
The completed self capture requires the explicitly exploratory reader below;
the strict reader deliberately refuses it.

This image's `spin_1`, `spin_2` and `spin_33` correspond to `tg`, consuming
`p88_string_eq` and `ks`; the report supplies exact generated-C and Bend lines.
It reports `nb_contains`, `has_name`, `nt_choose` and `kc` physical families
separately. Combined helper counts add disjoint own-leaf and owned-cleanup
samples; a shared equality helper is never charged to an erased logical caller.

The completed self capture emitted exact C but recorded two overruns, so its
strict status remains failed. `callers-exploratory.py` is a separate derivative
of the frozen accepted-capture reader, with an explicit rejection label:

```sh
python3 -B selfhost/tools/performance/phase95/callers-exploratory.py \
  --capture selfhost/build/phase95/self-profile01 \
  --out FRESH_EXPLORATORY_SUMMARY.json
```

It requires successful compilation and historical analysis, failed zero-loss
qualification, positive overruns, and no other loss counter. It does not repair,
qualify, impute or rescale samples. The actual two unrecorded expirations out of
17,336 are 0.01154%; this descriptive fraction does not waive the quality gate.

Static native07 C comparison uses
`selfhost/build/phase90/native06-new-runtime01/output.1.c` (`dae071f0…`). Its host
functions retain the consuming pattern: equality worker at line77227 takes both
string cells before testing its `same` flag; `tg` at76663 and `ks` at76840 take all
eight KTerm fields and sink unselected fields. The shared `ctr_take` path at41022
uses `span_fade` at41010, retaining fields before dropping the parent. These are
source-shape observations on the qualified B2 product, not B2 CPU attribution or
a transfer of B1 sampled costs. Exact self-emission also does not prove unsafe
compiler helpers sound.

## Eager membership experiment

`membership01/prepare.py` extracts the exact D04 helpers and independent edge
controls. `membership01/frozen01` and `frozen02` preserve two rejected harness
sources; `frozen03` is the accepted harness. See its [method](membership01/README.md).
`acquire.mjs` is the Phase94 upstream-checking acquisition method with only the
output-directory prefix changed, recorded in `acquire-derivation.json`.

Acquire both frozen03 roles under `phase86/guard.py`, then build each resulting
`program.c` with the pinned Clang, `-std=c11 -O3 -lm -pthread`. The membership
controls use the same recipe and must match every byte of the frozen expectation.
Run `membership-run-v2.py --out FRESH --products PRODUCT_DIRECTORY`. Its only
change from v1 is a higher repetition ceiling so the faster helper can pass the
doubled-count control; the incomplete v1 campaign remains excluded. Independent
calibration per role is necessary for the large head-hit speed difference.

`membership01/prepare-candidate.py` makes one replayable body replacement in
D04: `nb_contains` delegates to existing `has_name`. It changes no production
file or installed image. The candidate is upstream-checked and C-emitted into
`selfhost/build/phase95/membership-checked01`, then compiled with Clang **O2**,
matching native B1. The guard requires 16GiB available-memory headroom for this
6GiB-RSS build. Preserve the guard at `membership-build01`.

```sh
python3 -B selfhost/tools/performance/phase95/compiler-compare.py \
  --mode screen --out selfhost/build/phase95/compiler-screen01
python3 -B selfhost/tools/performance/phase95/compiler-compare.py \
  --mode self --out selfhost/build/phase95/compiler-self01
python3 -B selfhost/tools/performance/phase95/compiler-compare.py \
  --mode broad45 --out selfhost/build/phase95/compiler-broad01
```

Run these sequentially. Screen uses four balanced fresh-process pairs for each
of six sources. Self uses one baseline/candidate pair on **unchanged D04 input**,
with a 300s per-process deadline and the original full C oracle. It requires the
exact existing unsafe proof-refusal diagnostic after removing clock lines; that
is not an independent proof of the compiler. Broad45 compares every candidate
product to its qualified historical C. All modes bind and recheck their inputs.
The comparator and its exact Phase94 derivation are frozen before execution.

These checks establish candidate B1 behavior. Promotion additionally needs the
candidate's own-source C and successor-stage equality, applicable native
conformance and any shared JS-source gates. Compiling unchanged D04 faster does
not establish a new B2 or prove arbitrary unsafe helper equivalence.

## Completed result and preservation

The [report](../../../../implementation/phase95/README.md) records a neutral
six-source screen and a1.2% full-input difference in one pair. The candidate is
not promoted. All95 complete C comparisons pass; no candidate B2 or new program
runtime measurement is claimed.

`collect.py --out FRESH_EVIDENCE_DIRECTORY` verifies accepted measurement inputs,
both helper build receipts, control output and the serial process ledger, then
archives every Phase95 raw file and verifies each member on readback. The completed
[evidence01](evidence01/summary.json) has824 archived files, including rejected
captures, source failures and incomplete calibration. `helper.csv`, `compiler.csv`,
profile summaries and the execution ledger provide compact views. Restore raw.zip
from the repository root; the archive uses repository-relative paths and records
original modes in archive.json. Prior Phase92/93 dependencies are not duplicated.
