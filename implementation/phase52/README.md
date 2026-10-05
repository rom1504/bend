# Phase52: direct JavaScript backend

Work in progress, started 2026-10-05 14:49 UTC. The prototype value gate passed
within the first hour. The installed compiler remains Phase51 until the complete
candidate qualifies. [Design](../../design/phase52/direct-javascript.md),
[experiment](../../experiments/phase52/P52-001-direct-javascript.md),
[prototype measurements](prototype.md), [contract](parity-contract.md),
[independent review](review.md).

## Measured prototype result

Checked direct03 passes all eight prototype output checks and 72 timing samples.
Its geometric mean execution time is **1.03522× pinned TypeScript** on this subset,
versus **5.23997×** for unchanged Phase51 in the same run: a **5.06169× speedup**.
Individual ratios span 0.87772–1.12016×. These are short-screen results, not a
full-corpus parity or language-conformance claim. Raw receipts are in
`selfhost/build/phase52/screen-direct03/`; the detailed prototype report records
identities, failures, commands and individual measurements.

The first functioning direct02 prototype was 3.0700× TS on the same eight points.
Direct03 replaced unnecessary generic forcing and named tail bounces with direct
calls and added upstream-style arity raising. All earlier screen regressions
against Phase51 disappeared. This combined change supports the architectural
hypothesis; it does not isolate a speedup for each individual transformation.

## Current complete candidate and gates

Candidate `checked-direct06` contains the program, FFI, SCC, numeric-row and
emitted-dependency implementations. It is a checked equality-derived B1 API:
`472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`.
The direct runtime is
`417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a`.

- All 29 independent fixture emissions check successfully. **95/96 semantic
  comparisons pass.** The unchanged NaN-payload fixture expects 40, but upstream
  JavaScript returns 1 and direct output returns 39. The report remains failed;
  this observation is neither waived nor converted into a new passing oracle.
- All 26 new controls pass, including mutual-recursion capture and simultaneous
  updates, 50,000 tail steps, deferred Nat errors, dead/erased/live FFI inputs and
  proof output. These are part of the 96, not an additional disjoint total. Six further controls
  check native-inlining getter/coercion order and complete array aliasing.
- Direct04 passed the maintained 26-row JS census exactly: 18 runtime passes,
  four expected compilation rejections and four N/A. A final06 rerun is running.
- All **45 performance points from 23 sources** compile and pass their complete
  output checks on direct05. Two fresh batches completed: 30/45 points and 444 samples. The final batch
  was held to investigate numeric wrapper overhead; no full45 ratio is claimed. The
  separate NaN limitation does not disappear from the semantic report when
  these benchmark oracles pass.
- Legacy compatibility, installed/relocated CLI checks and promotion are pending.

See [conformance](conformance.md), [source accounting](accounting.md), and
[remaining work](remaining-work.md). The new backend adds 2,082 physical Bend
lines in nine modules; all 92 original modules are byte-identical. The retained
compatibility backend means the overall compiler grew by 8.8%, rather than
shrinking. Runtime, tooling and generated code are counted separately.

## Arithmetic follow-up

The [atomic-intrinsic experiment](../../experiments/phase52/P52-002-atomic-intrinsics.md)
completed all eight selected cases and 72 timing samples: **1.07426×** faster
than direct05, from **1.30162×** to **1.21165×** TS in that same run. Five sources
improve more than 5%; ray tracing improves 31.6%. Expression evaluation regresses
3.9%. The prewritten 1.10× average-gain target was **not met**. We retain the
measurement and are investigating the remaining non-atomic wrapper calls before
selecting the final image. All six new order/aliasing controls pass; the existing
NaN-payload failure remains.

## Contract

The new backend is written in Bend and reuses the checked frontend. It produces
lexical functions, native closures and upstream-compatible callable exports.
Existing mutable-descriptor JavaScript output remains the compatibility mode;
the new mode is explicit, because those interfaces expose different contracts.
Ordinary user compilation does not call the TypeScript compiler.

The selected interface does not promise arbitrary post-import global-hook
identity with every upstream optimization. In particular, upstream can emit
numeric match lookup tables using Math.min, while this backend currently emits
comparisons. Exact NaN payload readback also remains incomplete as above. The
[user guide](../../selfhost/docs/direct-javascript.md) records these limits and
bounded-analysis refusals.

No full-corpus timing conclusion, promotion, compiler-throughput gain, universal
conformance or new self-emitted fixed point is claimed at this checkpoint.
No PR comment was posted.
