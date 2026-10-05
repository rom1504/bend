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

## Contract and remaining gates

The new backend is written in Bend and reuses the checked frontend. It produces
lexical functions, native closures and upstream-compatible callable exports.
Existing mutable-descriptor JavaScript output remains the compatibility mode;
the new mode is explicit, because those interfaces expose different contracts.
Ordinary user compilation does not call the TypeScript compiler.

Expansion is in progress: mutual tail-call dispatch, complete program output,
effects/FFI, independent semantic comparisons and the unchanged 45-point corpus.
The 36 strict frontend build witnesses passed for direct02 and direct03; they
are not direct-backend semantic coverage. Upstream reference controls pass all
59 prepared scenarios. The frozen direct03 candidate passes all 55 library
scenarios; four CLI scenarios await the complete candidate.

No full-corpus parity, promotion, compiler-throughput gain or self-emitted fixed
point is claimed at this checkpoint. No PR comment was posted.
