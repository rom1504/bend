# Phase97: consume a lookup row once

`prepare.py --out selfhost/build/phase97/projection-frozen02` prepares data only.
Use a fresh directory on every revision. It authenticates the D04 compiler and
the exact canonical `f_find` body, extracts ten complete declarations, and
replaces `f_find` plus adds its typed branch helper in an isolated full compiler.
Production is unchanged.

The candidate opens each `KDef` once, compares its name, reconstructs the complete
ordinary row only on a hit, and otherwise recurses. Index leaves/nodes still expose an
empty name: an empty query returns the first such row, while a nonempty query
skips it. This is the existing linear `f_find`, not cached/tree lookup. The
unchanged old `f_find_next` handles reconstructed index rows; ordinary rows use
the new `f_find_fields` Bool-parameter helper. Index miss reconstruction is a
known cost of this version, not a claimed optimization for index-heavy lists.

Frozen01 is preserved: baseline JS passed24 cases; candidate failed during
frontend load with a stack overflow and executed no cases. Its computed match
scrutinees violate the explicit rule in `guide/GUIDE.md:123`: computed values
must be passed to a helper that matches a parameter. Frozen02 applies that
repair to the caller and to the micro's expected-token selector. The input and
expected-value corpus is unchanged. The stack overflow is an unhelpful rejection
of this unsupported source shape, not evidence that consume-once semantics fail.

Each role gets `manifest.json`, `library.bend`, `native.bend`, complete expected
stdout, and `micro.bend`. The manifest and copied Phase96 `methods/run.mjs`
support the same guarded JS and `emit-native` worker interface. Root owns all
target execution. The old Phase96 outer runner restricts output to Phase96;
use its worker under the current guard or a Phase97 wrapper rather than editing
the historical runner. Worker invocation is:

```
node --stack-size=4096 --max-old-space-size=1024 ROLE/methods/run.mjs ROLE/manifest.json FRESH-OUT js
node --stack-size=4096 --max-old-space-size=1024 ROLE/methods/run.mjs ROLE/manifest.json FRESH-OUT emit-native
```

There are 24 finite contracts. Every output contains the returned name, the
complete returned constructor, the complete surviving original list, and the
surviving query. Inputs distinguish every field: names, kinds, arities, template
counts, both term payloads, duplicate constructor rows, both flags, duplicate
removed names, source spans, Lambda quantity-presence, Unicode text and literal
numbers. A result is shared between `dn` and the complete observer; the original
book remains live across lookup. Observers directly match constructors, with
the accepted Phase96 observer prefix copied and renamed. Python expected values
use an independent first-matching-position specification, never production
execution. Index wrappers are algebraically valid values for the public helper;
these cases preserve its existing neutral projection behavior and make no claim
that arbitrary index trees are well-formed caches.

Five mutants edit the actual candidate caller: wrong query, swapped type/value,
lost unsafe flag, skipped empty-name index hit, and lost missing name. Oracles
stay byte-identical. Compilation failure is not a semantic mutant kill. Require
successful compilation and an actual full-value mismatch at the named witness.
All unchanged Phase96 helper laws can still pass these caller faults because
their accepted extraction does not contain `f_find`. These new contracts bridge
that specific gap; they are finite tests, not a universal equivalence proof.

The micro accepts final CLI words `repetitions size mode`, with modes head=0,
middle=1, miss=2, tail=3. The list is constructed once and retained throughout
the loop, then fully serialized after timing to expose alias destruction. The
five stdout lines are complete first result, successful arity checks, elapsed
milliseconds, complete final result, complete original list. `reference.py`'s
`micro_expected` supplies exact lines 1/2/4/5. Repetitions must be below 2^32;
sizes are bounded below 2^32−1 and modes to 0..3 by the supervising runner.
The timed loop checks a cheap discriminating scalar, while the separate contract
suite validates every field. Do not describe the scalar loop as full semantic
validation. Timing includes the success-count print, excludes setup and final
serialization, and measures an extracted helper with shared roots, not compiler
latency. No target has been run by this preparer/author.

Admission order: baseline/candidate JS24; baseline/candidate native24 with exact
stdout; five semantic mutant witnesses; then shared-root helper timing. Start
at sizes 8/128/1024 with head/middle/miss/tail, independently calibrate both roles
above 200ms, use alternating order and at least three rounds, and check doubled
repetitions. Inspect generated C for the actual removal of the `dn` call,
retains/sinks and hit reconstruction. A miss win with a hit regression is a
tradeoff, not an overall compiler win. Only a convincing helper result warrants
full candidate acquisition and the Phase95 six-source request screen; exact C
and diagnostics must remain accepted before 45-source/full-input expansion.

The Phase95 upstream acquisition recipe can consume the fresh `compiler.bend`;
copy/parameterize it for Phase97 if needed and freeze that derived method. Use
the pinned upstream and Clang recipe already authenticated by root. The helper
native control uses C11/O3, `-lm -pthread`; the full compiler comparison uses O2
to match the baseline. Previous full acquisition/build cost about 228 seconds,
so do not build the full compiler merely to learn that a small control fails.

`measure.py --out selfhost/build/phase97/projection-timing01` is a root-only
runner (default frozen02) for the acquired/compiled programs in `projection-micro-baseline01` and
`projection-micro-candidate01`. It imports the common Phase97 guard and verifies
the frozen micro source, upstream acquisition receipts, binaries, and reference
before use. Six shapes (128 head/middle/miss/tail, 8 miss, 1024 miss) get three
alternating rounds. Roles calibrate independently toward 300ms; accepted timing
samples must be 200–800ms, with at most two million repetitions. Each child has
a 30-second deadline and the campaign has a 180-second sampling budget. One
paired doubling check per role also must pass. All five output lines are
retained, all four non-timing lines must exactly match the frozen independent
reference, and full alias output stays in raw logs rather than duplicated in
the summary. The runner does not compile images. Root retains the guarded
Clang receipt linking the pinned acquired C to each pinned program binary.
