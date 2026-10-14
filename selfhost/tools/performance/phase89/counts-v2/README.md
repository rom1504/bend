# Checked-source operation counters

This diagnostic derivative preserves the original `../counts/` tools. It keeps
their 31 stable counters and omits `match_joins`, whose generated continuation
identity changes with compiler source. The append-return case is discovered by
its name and validated as a unique `SCon` return continuation.

Run the Python source transform only after the acquisition report is complete:

```sh
python3 selfhost/tools/performance/phase89/counts-v2/instrument.py \
  selfhost/build/phase89/owned01/report.json \
  selfhost/build/phase89/counts-owned-source02 \
  --receipt-sha256 0935d6cd67e06405f659f52ed1ddcb3e5506814992028bf42543d98c9abb75af \
  --check-only
```

Remove `--check-only` to write a fresh `compiler.c` and `derivation.json`.
The explicit receipt pin binds completed load/check/JS/C phases, the Bend source
snapshot and emitted C. Pinned upstream `bend.ts` and `comp.ts` bytes are verified;
mutable production modules are not required to equal their historical snapshots.
Every hook must be unique. Reversing the recorded edits must recover every original
byte, and the first/last 1,024 bytes must remain unchanged. The receipt lists the
31-field header, source, method and output hashes. No build or target is launched.

The unchanged `../counts/analyze.py` accepts this counter set and validates phase
marks against existing `IO.now` request receipts. Root must independently validate
complete generated C outputs and preserve diagnostic build/runner identities.
Use instrumented clocks only as diagnostics. An `-O1` build retains the runtime's
optimized calling conventions; `-O0` disables them. Neither is a substitute for
the clean paired compiler-speed measurement, and cross-optimization allocation
counts need care. No native image admission or performance promotion is implied.

## Guarded requests

After root builds the diagnostic C, `run.py` requires its explicit binary digest,
guarded build directory and derivation, plus the clean parent's completed live gate:

```sh
python3 selfhost/tools/performance/phase89/counts-v2/run.py FRESH_OUTPUT_DIRECTORY \
  --parent-image selfhost/build/phase89/compiler-chunks02 \
  --live-evidence selfhost/build/phase89/chunks-cold01/report.json \
  --derivation COUNTER_SOURCE_DIRECTORY/derivation.json \
  --build-guard DIAGNOSTIC_BUILD_GUARD_DIRECTORY \
  --image DIAGNOSTIC_BINARY --image-sha256 DIAGNOSTIC_BINARY_SHA256 \
  --check-only
```

`--check-only` validates inputs and planned commands without executing targets or
writing output. Remove it to run Map, Lexer and Numeric, each with five calls;
`--cases` accepts the existing case names and `--calls` accepts 1 or 5. Requests
use the existing CPU3, memory-limited guard with a 90-second per-process deadline.

The diagnostic C must derive from the clean parent's exact checked acquisition.
Build inputs, the C argument and `-o` output must bind the diagnostic image. The
clean parent must have passed live Small/Map/Unicode with identical authenticated
external assets. Only this diagnostic harness then supplies the canonical prepared
Base carrier; the public native launcher remains unchanged. Every returned C file
must match the independent historical B2 oracle's hash and length. If that original
file was archived, a retained complete-C copy is verified against the same oracle;
the report records both identities. Counter phases must match the request count
and 31-field schema. Input hashes are rechecked after success or failure.

Offline validation of the runner passed the existing chunks02 parent/live gate
and rejected a mismatched owned01 parent. This checked 55 artifact references and
executed no targets; diagnostic-build preflight and execution require root's build.
