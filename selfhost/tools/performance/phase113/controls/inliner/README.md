# Independent inliner controls

Run these only through the root's serial CPU3 process-tree guard. The control
author prepared sources, interpreters and frozen expectations without executing
a compiler API, native target or benchmark.

`manifest02.json` freezes `reflect-v2.mjs`, the corrected scalar13 suite:

```sh
BUN selfhost/tools/performance/phase113/controls/inliner/reflect-v2.mjs \
  CHECKED_SCALAR13_API selfhost/build/phase113/FRESH_SCALAR_CONTROLS
```

Nineteen cases compare independent finite IR interpretation before and after
the pass. Exact values and runtime-call traces accompany structural checks for
aliases, scratch isolation, branches, wrapper chains, retained calls and
node/site/stack budgets. All original fallback IR must remain structurally
identical. These hand-built original programs must not execute natively.

The first run (`inliner-reflect01`) exposed a control-method error: nine
unchanged checks compared JSON property insertion order. Every affected
complete before/after graph is structurally identical under independent Python
decoded-object equality. `comparison-correction01.json` preserves the exact
proof files and hashes. The original method and failed receipt remain intact;
v2 replaces only IR object equality with standard structural equality. No
semantic expectation, refusal, budget or exact trace was weakened.

`products-manifest01.json` freezes a separate extension suite:

```sh
BUN selfhost/tools/performance/phase113/controls/inliner/products-reflect.mjs \
  CHECKED_PRODUCT_INLINER_API selfhost/build/phase113/FRESH_PRODUCT_CONTROLS
```

It retains scalar13's policy and evidence separately. Eight finite execution
cases exercise two/three-result permutations, retained calls inside copied
functions, nested array-pair buffers, swap/get ordering and partial-return/loop
refusal. Eleven scratch-footprint cases, seventeen buffer ancestry cases and
six full verifier capacity/ancestry checks cover the renamed product imports.
Some footprint inputs deliberately contain invalid IR: they test conservative
analysis results and must not be confused with verifier acceptance.

The independent interpreter uses mathematical U64 words and explicit local
memory. Its array contract supplies one logical array `[7,11]` at opaque token
100; it does not use production tags, allocator layout or reference counts.
Runtime ownership evidence comes from the separately frozen C boundary cases
and actual Bend source controls. Matching runtime-call traces establish
ordering for those finite cases, not a general ownership proof.

`source-manifest01.json` freezes two actual Bend witnesses and complete outputs:
`hot-helper.bend` has 100,001 U32 helper iterations; `owned-helper.bend` retains
Unicode String aliases across identity, append and reverse. The independent
`oracle.py` computes their mathematical/literal outputs. `prepare-jobs.py`
prepares matched original/candidate emission, build and execution jobs:

```sh
python3 -B selfhost/tools/performance/phase113/controls/inliner/prepare-jobs.py \
  --baseline BASELINE_DIRECT_API --candidate CANDIDATE_DIRECT_API \
  --runtime CACHED_RUNTIME_OBJECT \
  --prefix selfhost/build/phase111/FRESH_INLINE_PREFIX \
  --out selfhost/build/phase113/FRESH_INLINE_PLAN.json
```

Actual source acceptance, output equality, helper-call disappearance and
performance are separate gates. An unchanged output produced entirely by
generic fallback is not evidence that an inliner transformation executed.
