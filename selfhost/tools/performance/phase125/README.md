# Phase125: owned composition and verified runtime calls

Read the [design](../../../../design/phase125/owned-composition.md),
[report](../../../../implementation/phase125/README.md), and
[semantic interface](../../../../docs/self_hosted/owned-native-composition.md).

The selected source06 composition uses typed guarded append, primitive identity
lowering, and post-verification sized constructor/take calls. Compiler decisions
remain checked Bend. The additive C runtime preserves the Phase118 prefix. Host
scripts compose authenticated declarations, invoke tools, and record evidence.

## Reproduce the selected source and runtime

From the repository root, with authenticated Phase124 assets present:

```sh
python3 -B selfhost/tools/performance/phase125/prepare.py \
  --out selfhost/build/phase125/FRESH-source \
  --module selfhost/tools/performance/phase125/producer/model-v3.bend \
  --module selfhost/tools/performance/phase125/producer/controls.bend \
  --module selfhost/tools/performance/phase125/identity/model.bend \
  --module selfhost/tools/performance/phase125/identity/controls.bend \
  --module selfhost/tools/performance/phase125/verified-runtime/model.bend \
  --module selfhost/tools/performance/phase125/verified-runtime/controls.bend \
  --overrides p121f_selected p113e_scalar_safe p113e_stmt \
    p112_intrinsic_fallback p118xs_original
```

The expected source SHA256 is
`d1399234ad28a3d03ee06fdad436a1585278bcbaea127425a226b5ceb79029b2`.
The composition includes the pure test predicates, as does the measured source.
Preparation alone does not type-check or qualify a compiler.

The exact selected full source is also available as
[compiler.bend.gz](../../../../implementation/phase125/source06/compiler.bend.gz),
with a separate [identity receipt](../../../../implementation/phase125/source06/manifest.json).
Decompress with `gzip -dc` into a fresh file and check the source SHA above.
This avoids dependence on the historical composition chain for reading the
selected source; toolchain, Base/cache, API and executable acquisition still have
their separately authenticated prerequisites.

Run all compiler/API/native execution through `phase111/guard.py`, with one serial
CPU3 lane, 2048 MiB process-tree RSS, 16384 MiB available-memory floor, 64 MiB file
limit, explicit deadline and fresh output. Full native-image qualification has a
separate justified 6144 MiB /128 MiB budget, described below. Do not run competing
target jobs or change an existing artifact in place.

Inside that guard, acquire a checked API with `phase111/check-api.py`, exporting:

```
p88_cache_prepare p86_prepare p86_plan p111_runtime_admission
p111_emit_admitted p111_compile_source p125p_inspect
p125pc_controls p125ic_controls p125vc_controls
```

Build the additive runtime with `runtime.py --out FRESH-runtime` and two `--extra`
arguments, in order: `producer/runtime-concat-typed.c` and
`verified-runtime/runtime.c`. It authenticates Phase118's source and compiles with
the same GCC10-O2 strict-FP policy. The runtime build is guarded target work.

## Fast loop and broad gate

1. `finite.mjs`, `finite-identity.mjs`, `finite-verified.mjs` invoke the checked
   API's 12+9+11 pure admission/refusal predicates. Fabricated metadata is never
   executed as native memory operations.
2. `controls/cases.json` binds ordinary valid-source alias, sharing, static-value,
   changed-equation fallback, heap-payload and deep-list cases to 21 exact output
   lines. Emit through the original `phase118/emit-integrated.mjs`; execute with
   `phase123/functional-aligned.py` and the unchanged complete-output oracle.
3. Focused original RLE/tree/map/lexer screens use `screen.py`. The original45
   manifest, repetition profile, sources, outputs and upstream products remain
   unchanged. The assembler policy is `-mbranches-within-32B-boundaries` for both
   Phase124 and the candidate. Three rotated rounds at scale4 are the broad gate;
   `repeat-products.py` supports a longer matched ablation of existing products.
4. `transfer/cases02.json` is an independent varying-value map/append workload,
   deliberately excluded from the historical score. `transfer/screen.py` compares
   complete original results under explicit compiler roles. The earlier invalid
   affine fixture and failed checker attempt remain archived.
5. `counts/` derives a diagnostic runtime with source-checked counter insertion.
   Adjacent repetition totals remove startup contributions. Counts distinguish
   constructor allocation, consuming takes and allocator requests; they are not
   malloc counts. Counter-instrumented timings are not performance evidence.
6. Run `phase118/cost-v2.mjs` for paired whole prepared hosted compiler cost, with
   exact parent selection/API/runtime and both emission receipts. This includes
   checking, lowering, verification and rendering; it is not native compiler time.
7. Emit each original45 case once with the final producer, reusing complete
   authenticated disjoint batches via `merge-emissions.py`. Run one broad screen;
   `phase123/summarize.py` and `phase123/deficit.py` retain both the historical
   geometric mean and mean positive log-slowdown, threshold counts and excess time.

For integrated emission set `P118_RUNTIME_REPORT` to the completed additive
runtime receipt. Set `P118_CASE_MANIFEST` only for explicitly separate ordinary
controls or transfer. The independent original parent verifier remains enabled.
Every failed attempt, source/runtime identity, output and deadline is retained.

## Native checkpoint

Follow [native/README.md](native/README.md). `abi-receipt.py` authenticates the
reviewed Bend producer/import authority and additive runtime implementation;
symbol presence alone is not ABI admission. The native plan replays the original
full-source contract and preserves the original focused19/full45 output gates.

The planned chain is hosted→N1→N2, exact raw hosted/native QBE reproduction,
focused19 on both images and original45 on N2. The plan pins aligned machine
building explicitly. Success does not establish N2→N3, byte-identical ELF images,
parallel/GPU behavior, or installation. Separate native timing compares the
frozen three-source compiler-request and ready-executable workflows, retaining
their different upstream runtime-build costs.

Check disk before full images. Only after authenticated byte equality may exact
duplicate artifacts be hardlinked, preserving every original path and byte with
a receipt. Never silently delete evidence to make a campaign fit.

## Reading the results

Source-level repeat-into-tail is a ceiling, not an automatic compiler gain.
Raw-only append, RFC1, out-pointer, direct-result and typed variants preserve the
negative findings. Static site counts show eligibility, not runtime importance.
The independent transfer is not an extra point in the historical45 score.
Compiler speed, emitted-program speed and research-loop cost are distinct.
No recursive acceleration follows just from another self-reproduction checkpoint.
