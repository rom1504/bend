# Experimental checker-prefix reuse

This is an append-only Bend implementation of the Phase139 conservative contract.
It is not installed, a serialization format, or a proved checker. The original
checker, diagnostic finalization, frontend and production entry are unchanged.

Current composition, in order:

1. `checkpoint-v02.bend`: actual event-prefix capture and exact admission.
2. `equality-v02.bend`: test-only complete structural state/result observer.
3. `controls-v01.bend`: fifteen checked Bend predicates over actual parsed sources.
4. `bridge-v01.bend`: private integration with the existing prepared Base world.

`checker-source03/manifest.json` binds these to selected Phase137 source
`2620d59a…ecf38`, preserving the entire parent as an exact byte prefix. The checked
API is `selfhost/build/phase111/p140-checker-api04/report.json`.

## Interfaces

`p140cp_seed(epoch, postFreshBook, cut)` runs the original initial declaration
installation, captures the complete actual world and seen-event book after `cut`
successful events, then finishes through original `dg_check_events`. The returned
`P140CPSeed` contains both checkpoint and complete ordinary `DChecking`.

`p140cp_replay(epoch, postFreshBook, checkpoint)` checks equal producer epoch,
complete fresh bound, exact prefix and ordered suffix declaration projection.
Only Foreign values remain in that projection; every other declaration retains
its complete declared type, constructor tree, flags and metadata. On admission,
it calls original `dg_check_events` with the new suffix and saved world/seen.
On refusal, it calls original `dg_check_world`. The input must already have passed
the ordinary parser, graph validation and global freshener.

`p140cb_check(epoch, load, prepared, checkpoint, cut, origins)` is the integration
entry for a trusted `FPrefixLoad` and its authenticated `KBasePreparedWorld`.
`cut` counts source events after Base. It returns
`P140CBResult{result,checkpoint,reused,skipped,reason}`. It preserves the existing
Base eligibility, disjointness and hash-collision gates. On an eligible cold/miss
request, its six-line world initialization is exactly the existing
`base_prefix_world_resume_state` initialization, and only source events execute.
On an admitted warm request, the saved whole checker state resumes at the source
cut. Both paths finalize with the **current complete source suffix**, saved Base
TODO count, current origins and `driver_program_checked_prefix`. Other inputs use
original `check_program_diagnostic_world`. A failed edit before the cut retains
the previous checkpoint so recovery can reuse it.

The root can feed `p140pl_load` from the parser experiment into this entry after
its original whole global freshening. Parser reuse and checker reuse are separate
facts. Pass the actual current `P86Seed.world`; do not construct a replacement.

`epoch` is a producer identity supplied by the trusted experiment owner. A string
comparison does not authenticate arbitrary forged worlds. Checkpoints are actual
in-process values produced by these routines; no user-provided/native raw heap
state or unchecked deserialization is supported. Keep builder A fixed while
candidate compiler sources B change. Adopting a new builder begins a new epoch.

Only one successful checkpoint is retained. Source trees, checked trees, indexes,
memo, fresh state, checked outputs and seen history remain immutable and shared.
The representation deliberately retains more state than a speculative minimal
cache. Exact comparisons and full global freshening still cost work; their cost
must be included in a future stage/whole-request comparison.

## Evidence

- `checker-observe02/report.json`: all15 Bend predicates plus ten real edit/revert
  cases; graph-aware complete state and final result equality against fresh B.
- `checker-bridge01/report.json`: all15 predicates, exact prepared-Base cold result,
  and six actual source requests (no-op, body edit, invalid suffix, invalid prefix,
  recovery, changed header). All complete DResults match original prepared checking.
  Snapshot cut498 comprises496 Base events and2 source events; hits skip2.
- `checker-adversarial02/report.json`: balanced binder edits both have maximum3 but
  change an intermediate header and correctly refuse; a later law-fill unsafe
  change refuses. Separate data-level probes cover flags, arity, template count,
  quantities, spans, children and Foreign bodies. Complete-world observer detects
  omitted fresh, checked and memo state. These forged-state probes do not claim
  that raw checkpoints are authenticated.

- `checker-memo01/report.json`: a real specialized `id(~A: Data, x: A)`
  leaves memo entry `id~0` in the captured prefix. Reused edited checking matches
  fresh checking completely. Deliberately omitting that memo still returns
  successful checking but produces a different whole state, detected by the
  independent observer. This is a concrete reason to retain complete state.

All evidence directories are under `selfhost/build/phase140/`. Host code only
supplies source/test data, invokes checked Bend functions and compares every
observable object field with pair memoization. It does not compile, freshen,
check or synthesize accepted cache entries. It never JSON-serializes the complete
shared checker graph.

Preserved failures: source/API01 found an affine capture missing `+`; observer01
misread the JS API's unboxed Bool; API03 named an absent test export `p86_header`;
adversarial01 used an invalid no-argument law-fill fixture spelling. Each has its
own failed receipt; fixes have new file/version or output names.

## Reproduce the bounded checks

Run under the existing Phase131 usage guard on the coordinator-approved lane,
with fresh output paths. `prepare.py` composes only new declarations; no overrides.
`check-api.py` checks the full source before exposing experimental functions.

```sh
python3 -B selfhost/tools/performance/phase140/checker/prepare.py \
  --out selfhost/build/phase140/checker-source-FRESH \
  --module selfhost/tools/performance/phase140/checker/checkpoint-v02.bend \
  --module selfhost/tools/performance/phase140/checker/equality-v02.bend \
  --module selfhost/tools/performance/phase140/checker/controls-v01.bend \
  --module selfhost/tools/performance/phase140/checker/bridge-v01.bend
```

The API04 receipt records the exact29-export acquisition command. Its existing
checked API can run `observe-v02.mjs`, `bridge-observe-v01.mjs`, and
`adversarial-v02.mjs`, and `memo-observe-v01.mjs`, each with arguments `CHECKED_API_REPORT FRESH_OUTPUT_DIR`.
Ordinary guards completed these checks in approximately1.8s,3.5s and1.6s; API
acquisition took10.1s separately. These are validation costs, not compilation
speedup measurements. No heavy native campaign ran in this lane.

Next: combine actual parser/checker reuse with verified owner/output reuse, then
measure same-B warm versus cold and incumbent with the entire admission and
finalization costs. The generic prefix mechanism alone cannot remove the global
lowering/rendering floor or establish a20s native rebuild.
