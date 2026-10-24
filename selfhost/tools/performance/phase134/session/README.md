# Experimental native two-revision session

The frozen timed `session-source04` has now passed a native two-revision
experiment, including independent complete-QBE comparisons, five refusal
controls and two balanced warm/cold pairs on real Lexer and Map edits. Retained
state reduced the second request by 21.3% / 6.1% and complete sessions by 9.1% / 2.6%,
respectively. See the [native report and reproducible evidence](../../../../../implementation/phase134/session/README.md).

This separate CLI mode extends the audited no-copy compiler with same-request
verification reuse and an isolated exact private-function cache. It is checked
with 109 finite controls and a hosted raw-plan bridge. The session image is still
experimental: it has not completed native self-reproduction, has not replaced
the qualified core, and has no measured no-cache adoption-cost baseline. The
earlier `session-source03` remains frozen as preparation history.

```sh
SESSION_IMAGE --threads 1 --gpu off -- phase134-session \
  ABS_REVISION_A ABS_REVISION_B ABS_BASE ABS_CARRIER STAMP \
  FRESH_OUTPUT_A FRESH_OUTPUT_B warm
```

Use `cold` instead of `warm` to discard A's returned cache before compiling B.
Both modes prepare Base once and parse/check both source revisions. The same
producer, runtime and optimization policy remain fixed within the process.
The supervised caller must allocate distinct fresh regular output paths, resolve
aliases, and pin the input/source/runtime identities. The Bend argument checker
requires absolute paths and refuses literal output/input or output/output
collisions; it cannot establish filesystem identity across symlinks.

Both source files, Base and the authenticated carrier are read before either
output file opens. A's sealed plan is rendered with the existing no-copy cursor
writer directly to output A; close completes before B compiles. B similarly
opens its file only after frontend/runtime/backend admission has returned a
sealed result, and returns success after draining and closing the file. A failure
terminates the IO sequence and drops retained state. Failed writes may leave a
partial explicit output file; the supervisor must not publish such a file.

Successful stdout contains two short lines:

```
phase134 A INLINE_HITS INLINE_MISSES PRIOR_RANGE_HITS INNER_RANGE_HITS RANGE_MISSES
phase134 B INLINE_HITS INLINE_MISSES PRIOR_RANGE_HITS INNER_RANGE_HITS RANGE_MISSES
```

The process retains only typed state actually returned by its own first request.
There is no serialization, externally supplied cache, daemon or watch service.
It retains cache IR and the prepared Base across the two requests; bounded text
rendering does not imply a constant-size semantic cache. No frontend,
common-preparation, final rendering, QBE machine-build or linker work is cached.

## Exact implementation boundary

`prepare-v03.py` composes frozen audited `units-source01` with:

- `units-raw-v01.bend`: removes only `p134e_collect` around the already verified
  result of `p134u_emitted`. This experimental units entry now returns a sealed
  plan; the original hosted units fixture/source remains frozen.
- `session-v03.bend`: new session, file-output, reporting and finite-control code.
- `entry-v01.bend`: adds the nine-argument session arm to `p111_native_args`.
  The original six-argument ordinary arm and its failure text are byte-identical.

Every other existing declaration is unchanged, including the ordinary native
request, pure collecting API, renderer, admission predicates, independent final
verifier and connected proof declarations. No installed compiler selection changes.
The raw adapter delegates to the existing optimization and verification path;
it does not reimplement any transformation or cache admission decision.

## Evidence

- Frozen source: `selfhost/build/phase134/session-source03/compiler.bend`, SHA256
  `04d95447084ca8c005be5a61843d02b30abde2e30c28ee48d03bbc22d5d61ad9`.
- `selfhost/build/phase111/p134-session-api01/report.json`: checked 13-export API,
  14.04 seconds guarded, 2.02 GiB sampled process-tree RSS.
- `selfhost/build/phase134/session-finite01/report.json`: original 99 controls
  plus 10 path/cold/warm-state controls, all pass (2.08 seconds guarded).
- `selfhost/build/phase134/session-bridge01/report.json`: actual two-file checked
  source edit, cold and retained-cache results both match independently fresh
  complete QBE. Both raw results are `P134Planned`; only the external oracle
  intentionally collects them to compare bytes (4.33 seconds guarded).

The tiny source edit changes `edited()` from 11 to 12. A has 0/3 inline hits;
B has 1/3 hits with retained state and 0/3 cold. Both versions emit 49,380 bytes
with distinct hashes, confirming the edit did not disappear. This demonstrates
correct state transfer in the checked hosted API. It does not establish native
session execution, file publication behavior or a native cache speedup.

`session-v01/v02` and `prepare-v01/v02` retain source-only preparation history:
v02 moved both reads before outputs; v03 fixed a finite-label helper's affine
quantity before the first source check. Only v03 was checked. All target checks
were successful; no full compiler build was launched by this implementation task.

## Timed v04 session

`session-v04.bend`/`prepare-v04.py` retain all v03 semantics and add four calls to
already-registered `IO.now() -> IO(Nat)`. The pinned runtime implements it using
`CLOCK_MONOTONIC` nanoseconds divided by one million, so readings are monotonic
milliseconds, not CPU time. No timer/runtime/admission change is needed.

The three intervals are:

1. Preparation: Base/carrier reads and preparation, plus reading both immutable
   source snapshots before any output opens.
2. A: full source planning/checking, runtime admission, cache acquisition,
   backend lowering/verification, cursor rendering, output writes and close.
3. B: the same complete request, with retained cache or its cold reset.

All printing is deferred until B closes. Stdout becomes:

```
phase134 prepare_ms PREPARATION_MS
phase134 A INLINE_HITS INLINE_MISSES PRIOR_RANGE_HITS INNER_RANGE_HITS RANGE_MISSES ms=A_MS
phase134 B INLINE_HITS INLINE_MISSES PRIOR_RANGE_HITS INNER_RANGE_HITS RANGE_MISSES ms=B_MS
```

Use the supervising process's wall clock as the complete-session cost; startup,
argument validation, final reporting, process teardown and OS scheduling can
make it exceed the sum of the three internal intervals. Small sub-millisecond
stages need repetition; these timer readings do not establish a speed gain by
themselves. Source04 SHA256 is
`1cadf44f486825a6f161ff01b15b582eca13522585deff8415d6c8c2aea7be45`.
The v03 source and all of its evidence remain unchanged.

The timed source passed `phase111/p134-session-api02/report.json` (14.13 seconds,
2.02 GiB), `phase134/session-finite02/report.json` (109/109), and
`phase134/session-bridge02/report.json` (both real revisions, cold/warm exact
fresh QBE). These checks validate the source and pure semantic bridge; the IO
clock/output path still requires the separate native session experiment.
