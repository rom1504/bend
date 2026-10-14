# Consuming string controls

`helpers.bend` implements equality and codepoint ordering by consuming both
strings. It does not reconstruct the compared inputs or return them in a pair.
Both helpers are ordinary safe Bend; the checker must accept their ownership.
This is an isolated compiler-host experiment. No upstream or production module
has been changed.

`controls-v5.bend` is standalone and imports the pinned Base. It contains 38 strings
and tests all 1,444 ordered pairs. The corpus includes every word of length zero
through two over `{NUL, a, é, 😀}`, control characters, combining Unicode, the
U+E000/U+10000 ordering boundary, U+10FFFF and equal prefixes up to 64 characters.
For each pair it returns Base equality/order, candidate equality/order on shared
inputs and on fresh copied inputs, then lengths and codepoint sums of reused
inputs. `compare-output.py` checks the entire JS/native output and independently
checks every field against the frozen codepoint corpus. Invalid scalar values
and unbounded strings are outside this finite control.

The [retained V5 comparison](../../../../build/phase88/strings-controls.json)
passes: all 1,444 pairs agree with Base and the independent oracle, and raw
JS/native full stdout is identical (85,349 bytes, SHA256
`06c0fd2c626a3d5d62cfc010ec05e5e7b38e16e3eea7ee5dc15f044c4f1a5df6`).
The source passes upstream checking, and native code passes the pinned O2 build.
The final full-compiler gate passes45 exact C/execution points; live request
time falls22.4–32.3%. See the [phase report](../../../../../implementation/phase88/README.md)
for controlled results and the native-only integration boundary.

Root runs targets serially under the usual guards:

1. Use `phase88/component.mjs strings/controls-v5.bend NEW_ACQUISITION_DIR` to fully
   check the tiny source and emit JS/C. Do not use the full-manifest acquisition.
2. Run raw emitted JS; build the emitted C with pinned Clang/O2 and run it with
   `--threads 1 --gpu off`. Preserve all outputs and process receipts.
3. Run `python3 -B strings/compare-output.py strings/controls-v5.json JS_STDOUT C_STDOUT NEW_REPORT.json`.

`make-controls.py NEW_CONTROL.bend` reproduces the fixture and its `.json` corpus
and provenance. It is an offline source generator, not a compiler or benchmark.

Earlier fixtures and receipts are retained. `controls.bend` failed because a
match needs a parameter/field scrutinee, not a computed comparison. V2's separate
Bool/Cmp dispatch functions then failed because safe live code cannot use the
unfilled law involved in that helper cycle. V3 uses a single directly recursive
worker per operation: its Bool/Cmp parameter selects whether to match and consume
the next character pair. Public wrappers seed True/EQ. There is no law or mutual
recursion. V3 was then rejected because its first argument changes before the
later strings shrink: safe self-calls require a left-to-right decreasing tuple.
V4 puts the strings first and matches both strings and the carried comparison
together. Its first recursive argument is the consumed tail; earlier LT/GT
results remain authoritative for every remaining-string shape. V4's helpers pass
checking, but its control `main` used the concrete corpus before it was filled.
V5 moves the corpus definition before `main`. Retained failures are in
`selfhost/build/phase88/strings-control01/` through `strings-control04/`.

For a full native-host test, `native-assembly.py FROZEN_COMPILER.bend NEW_NATIVE_COMPILER.bend`
creates an isolated derivative of an already assembled compiler. It changes only
exact `String.eq` identifier tokens in the 132 active compiler-module sections to
`p88_string_eq`, inserts the checked helpers just after `import Base`, and records each input hash and
per-module replacement count. It preserves quoted text, comments, entry code,
the imported upstream Base and the Base/user text later compiled by the program.
Fully check this complete new source before C emission. Compare complete emitted
C to ordinary B2 on the same source requests before comparing timing; Base
preparation and request costs must remain separate.

Keep the ordinary JS assembly and its existing primitive-string equality guard
as the reference. The native derivative changes the compiler implementation and
is not a same-source host comparison. Running its raw JS at compiler scale may
reintroduce structural-recursion stack overflow: the existing `String.eq` guard
does not intercept `p88_string_eq`. A future shared-source integration needs an
explicit reviewed primitive-string guard for the new helper or a target-aware
library path. Do not silently describe that adaptation as raw upstream JS.

The order helper is tested but not installed by the derivative: the active
compiler modules call equality, with no direct order/paired-comparison calls.
Base maps retain their original ownership-preserving `String.cmp` contract.
No measured speed gain is claimed before guarded targets complete.
