# Phase82: remove fixed request work, then replace repeated native work

## Objective and baseline

Act on the [Phase81 investigation](../../implementation/phase81/README.md).
Keep the compiler implemented in Bend and preserve program execution speed,
checking, diagnostics and the ordinary proof-report contract. Target cold C
compilation parity through measured removal of work, rather than additional
caches whose construction costs exceed their benefit.

Phase78 is the qualified baseline: checked B1 `475610ea…`, genuine B2
`cc99ac9b…`, pinned upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
Its paired 45-request ratios are 1.73205× B1 and 1.38187× B2. These include
loading/checking/reporting/emission, exclude compiler imports, explicit Bend
Base preparation, Clang and execution, and disable backend products. Fresh
processes and exact previously executed C are required. Phase81's shorter
unchanged-source measurements are not a new improvement baseline.

## 1. Runtime text invariant

Phase81 measures 43–66 ms scanning the unchanged runtime for four insertion
markers. Produce the five chunks once with the **existing Bend scanner**, store
them as a small canonical artifact and transport them to native emission. A
private runtime value carries either raw text or prepared parts. Prepending
request-specific macros changes only the first part. Rendering and checks for
markers in inserted payloads remain in Bend; suspicious payloads use the exact
old sequential substitution behavior. Public raw String entry points remain.

The host may select the artifact only for its owned API, the exact runtime hash
and an explicitly pinned artifact hash. Missing, modified or custom assets use
the old path. Merely joining to the runtime does not prove insertion boundaries,
so an arbitrary supplied array must not authorize the optimization. Artifact
generation records the checked Bend producer. Input inventories include it.
This moves invariant computation to artifact generation, not outside a benchmark
clock by silently adding per-process preparation.

Controls compare raw/prepared rendering including malformed marker orders,
missing markers, inserted markers, comments, Unicode and empty pieces. Real
requests must retain C bytes, verdict and diagnostics. Checked B1 first, then
genuine B2. Expected request savings are approximately 4–7% on IO-heavy sources
and 10–20% on small ones; these are hypotheses, not promised results.

## 2. Exact-world facts

Trace the five freshness-bound scans and three final-book constructions before
removing any. Reuse only facts from the same checked world, or derive a new bound
from its unchanged prefix and changed definitions. Raw books, cache sentinels,
foreign inputs and generated binder ranges retain their original checks. A
smaller implementation with exact behavior is preferable to a second generic
memo framework. Measure this independently from template work.

## 3. Per-function replacement, if justified

Attempt a native function product that replaces repeated annotation, erasure,
compaction, signature or occurrence traversal and serves multiple consumers.
It must replace existing work rather than retain another whole-library graph.
Review rejected Phase79/80 prototypes first. Start on the three-source loop and
small/functions65 held-outs. Preserve rejected candidates and reasons. A broad
representation rewrite requires demonstrated net gain, not only a faster local
helper. The Phase81 15–25% request estimate is a discriminator to test.

## Gates and integration

1. Checked B1/frontend36, structural controls, rotated fresh-process screens
   against frozen Phase78 and TypeScript. Keep reports enabled. Inspect code
   equality before interpreting times. Reuse prepared Base only as before.
2. Repeat promising candidates with genuine B2; separate preparation cost and
   report individual cases, distributions and geometric means. Reject held-out
   regressions and changes whose complexity is unsupported by net gain.
3. Qualify the chosen source with native/raw/boundary checks, twelve-family C
   output identity, JS continuity, self-check/B3 and installed/relocated gates.
   Byte-identical C permits reuse of previous execution evidence; changed C
   requires fresh runtime checks. Do not claim universal conformance.
4. Document the mechanism, measurements, failed attempts, compiler stages and
   remaining gap. Commit/push designs, implementation and report separately.

One CPU3 target tree, 2 GiB aggregate RSS, 4 GiB available floor, Node 1 GiB heap
and 4 MiB stack. No agents or PR comments. Keep inherited Phase6/68 edits and
sealed history untouched. Use short discriminating tests first; do not spend a
broad release campaign on an unproven candidate.
