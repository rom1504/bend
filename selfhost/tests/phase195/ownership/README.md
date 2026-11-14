# Owned-projection ceiling experiment

This is a hand-authored, checked compiler-IR application, not a compiler
optimization or a benchmark-name recognizer. `ceiling.bend` emits both baseline
and candidate using the unchanged selected x86 emitter. Original direct-IR
verification (including the original borrowed-import projection check) runs
before emission. Finite tests and source checking remain separate from any
independent proof; there is no generalized observer admission yet.

The input is a full binary search tree of depth0..8 with linked heap payloads.
The result is `(preserved tree, found flag, owned payload, diagnostic route)`;
the flag/payload pair is the flat Maybe result ABI. Baseline consumes/rebuilds
only the searched path and acquires one payload reference at a hit. Nine
statically depth-bounded workers avoid introducing unbounded native recursion.
Candidate holds the original root while a stack-safe Again worker borrows fields.
It acquires an already-RFC/trivial hit once; a raw hit falls back to the exact
baseline because wrapping a raw borrowed child without replacing the parent's
word would be unsound. Static raw constructors also conservatively fall back.

The observer builds trees through the real runtime. Hot policy seals children;
cold capability8 leaves eligible links raw. Both policies run360 observations
covering both algorithms, depths0..8, root sharing, empty trees, hits and misses.
It checks full tree/payload content and preserved aliases, releases both root
aliases, churns allocation, then checks the surviving payload. No malformed
runtime/failure probes are performed. Candidate route flags prove hot hits and
misses actually use borrowing and first cold hits take the fallback.

Prepare and acquire a fresh API, then run the finite machine controls in the
root-owned CPU3 lane (use new names if any output already exists):

```sh
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source selfhost/build/phase194/selected-source02/compiler.bend \
  --assets selfhost/build/phase194/assets.json \
  --out selfhost/build/phase195/ownership-api-source01 \
  --module selfhost/tests/phase195/ownership/ceiling.bend \
  --export p195o_controls --export p195o_validate --export p195o_emit
python3 -B selfhost/tests/phase195/job.py ownership-api01 90 48 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase195/ownership-api-source01/compiler.bend \
  --exports selfhost/build/phase195/ownership-api-source01/exports.json \
  --out selfhost/build/phase195/ownership-api01 \
  --engine selfhost/.assets/bin/bun --upstream selfhost/.bootstrap/upstream-phase182
python3 -B selfhost/tests/phase195/job.py ownership-controls01 120 48 \
  selfhost/.assets/bin/bun selfhost/tests/phase195/ownership/driver.mjs \
  --api selfhost/build/phase195/ownership-api01/report.json \
  --assets selfhost/build/phase194/assets.json \
  --out selfhost/build/phase195/ownership-controls01 --seconds 110
```

The finite driver preserves direct-object and rendered-assembly products,
commands, reports, stdout/stderr and exact runtime/source identities. No timing
claim follows from those controls. The executables accept
`bench ROLE REPETITIONS DEPTH SHARED`, where ROLE is0 baseline or1 candidate,
DEPTH<=8 and SHARED0/1. Root can run balanced paired subprocesses using these
already-built products. Each iteration checks the payload and checksum; timing
includes these identical observations and excludes tree construction/destruction.
Whole-process cost also includes runtime initialization and those boundaries.
The output includes elapsed_ns, checksum, fast-route count and failures. Use the
hot product for the main ceiling: cold repeated requests can gradually seal
previously visited payloads through baseline reconstruction, so its fast count
must be reported rather than assuming every cold iteration falls back.

Stop before planner work unless the actual emitted hot candidate loses all
per-level take/construct and reconstruction calls and shows a substantial
bounded runtime gain. Then test actual Map.seek admission under an explicit
owned-result descriptor and origin proof. This experiment cannot establish
compiler transfer, whole-Map speedup, changed failure semantics or safety for
arbitrary runtime representations.
