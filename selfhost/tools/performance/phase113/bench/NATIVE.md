# Candidate native image and self-host qualification

All commands below are root-only targets, run serially on CPU3 inside the
process-tree guard. This document is source review and a command recipe, not
an acquisition receipt. Keep every source, API, runtime, emission and build
report; do not rename their producer roles.

## Freeze the complete candidate first

Bind the final `compiler.bend`, composition manifest, ordered module snapshots,
checked API/report, exact Base/cache assets, and
`selfhost/build/phase113/runtime-products-build01/runtime.o` (profile11301).
The runtime object SHA is
`c0f6f2ca5b5a58418f326794e97a29cc21a68f32e924ce5974ad4ffccfc9c9f9`.
Use that same object for N1, N2 and generated programs.

At this review, `facts-source14/compiler.bend` has SHA
`b7148f6a6bef3e749b515775ee1bd93e2d84cc0c523190a1c54afd02a36c8dff`.
It includes products, direct field facts and Nat facts, but **not the inliner**:
`p113d_lower_request` still calls `p113pl_lower_request`, and `p113i_lowered` is
absent. A final products+facts+inliner composition must add the direct-opt
modules and its final `overrides-products.bend`, then obtain a new checked API.
Do not describe source14 alone as that combined candidate.

The native hook is present:
`main → p111_native_args → p111_native_request → p111_compile_source →
p111_compile_prepared → p86_plan → p111_emit_plan →
p111_runtime_admission → p111_emit_admitted → p113d_lower_request`.
The selected `p111_emit_admitted` calls `p113d_emit_lowered`, which verifies
before `p113e_admitted_chunks`. Mature file IO, cache/live preparation, checked
request creation and print behavior remain on this path.

The hosted API needs `p88_cache_prepare`, `p86_prepare`, `p86_plan`,
`p111_runtime_admission`, `p113d_lower_request`, `p113d_verify`, `p113d_chunks`
and `p111_compile_source`. Bind its checked receipt to the exact final source.
The last export also satisfies existing product binders; staged direct
emission must use the direct exports. Export selection does not remove source
modules from the composed input. Production lowering follows reachability from
`main`; unused reflected control functions need not become native image code.

## Full emission and N1

Set these task-local variables to concrete frozen paths. `p113-final01` is an
example fresh prefix; never overwrite a prior attempt.

```sh
P113_SOURCE=/absolute/path/to/frozen/compiler.bend
P113_API=/absolute/path/to/checked/api.mjs
P113_RUNTIME=/home/ai/bend2/build/publish/bend/selfhost/build/phase113/runtime-products-build01/runtime.o

selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase113/staged-emit.mjs \
  "$P113_API" "$P113_SOURCE" \
  selfhost/build/phase111/p113-final01-full-emit cache direct

python3 -B selfhost/tools/performance/phase111/build.py \
  --source selfhost/build/phase111/p113-final01-full-emit/program.ssa \
  --runtime "$P113_RUNTIME" \
  --out selfhost/build/phase111/p113-final01-n1 --seconds 120
```

Require complete frontend/runtime admission, direct lowering, structural IR
verification, QBE emission and build receipts. Record segment/direct-function
counts and RSS from the actual staged report. The same full compiler source
must be the later self-emission input.

Current staged emission verifies explicitly, then calls `p113d_chunks`, which
verifies again. The native entry verifies once and calls
`p113e_admitted_chunks`. To remove only the duplicate hosted check, acquire an
explicit `p113e_admitted_chunks` export and version the transport to call it
only after successful `p113d_verify` on the same in-memory program. Keep
`p113d_chunks` as the checked standalone API. Do not silently change a frozen
transport. The optional inliner also verifies its input and candidate; those
internal pass checks are separate from the final transport verification.

## N1 semantics, self-emission and N2

```sh
python3 -B selfhost/tools/performance/phase111/coverage/native-run.py \
  --image selfhost/build/phase111/p113-final01-n1/program \
  --runtime "$P113_RUNTIME" --suite focused --seconds 30 --build-seconds 30 \
  --out selfhost/build/phase111/p113-final01-n1-focused

python3 -B selfhost/tools/performance/phase111/native-emit.py \
  --image selfhost/build/phase111/p113-final01-n1/program \
  --source "$P113_SOURCE" --mode cache --runtime "$P113_RUNTIME" \
  --seconds 650 --build-seconds 120 \
  --out selfhost/build/phase111/p113-final01-self

cmp selfhost/build/phase111/p113-final01-full-emit/program.ssa \
  selfhost/build/phase111/p113-final01-self/program.ssa
```

Record the `cmp` command, exit status, both emission reports and both product
pins in the root plan/receipt. It must succeed before qualifying N2. The old
native transport's `--reference` whitelist does **not** accept
`phase113-staged-checked-source-qbe-emission`; this explicit byte comparison
avoids altering that tool or relabeling a real receipt. The native output is
raw stdout, one LF per IO.print chunk, with no normalization.

N2 is `p113-final01-self/build/program`. The native transport binds N1's build
receipt, exact input/asset pins, native stdout and N2 build report. A differing
ELF hash alone does not establish a semantic difference; generated QBE bytes
and complete source/build lineage are the reproducibility gate here.

```sh
python3 -B selfhost/tools/performance/phase111/coverage/native-run.py \
  --image selfhost/build/phase111/p113-final01-self/build/program \
  --runtime "$P113_RUNTIME" --suite focused --seconds 30 --build-seconds 30 \
  --out selfhost/build/phase111/p113-final01-n2-focused

python3 -B selfhost/tools/performance/phase111/coverage/full45/native-run.py \
  --partition all45 \
  --image selfhost/build/phase111/p113-final01-self/build/program \
  --runtime "$P113_RUNTIME" --seconds 120 --build-seconds 10 \
  --out selfhost/build/phase111/p113-final01-n2-full45
```

The focused suite remains 19 actual source requests: 16 positive executions,
two checked-source refusals and one unavailable-foreign-provider backend
refusal. A crash, timeout or invalid-IR failure cannot replace an expected
refusal. Original outputs and refusal rules stay unchanged. The full45 suite
uses the original finite one-shot sources/outputs; it is separate from the
45 batch-wrapper runtime benchmark.

For successor compiler-output reproduction, have N2 emit the same full source
against N1's completed native emission receipt:

```sh
python3 -B selfhost/tools/performance/phase111/native-emit.py \
  --image selfhost/build/phase111/p113-final01-self/build/program \
  --source "$P113_SOURCE" --mode cache --seconds 650 \
  --reference selfhost/build/phase111/p113-final01-self \
  --out selfhost/build/phase111/p113-final01-n2-reemit
```

This reference kind is already accepted. Require its exact-byte comparison
gate. No N3 build is needed for that QBE reproduction claim. For selected
application-output reproduction, use identical source paths for hosted and
native requests and preserve separate exact-QBE comparisons; do not compare
one-shot conformance wrappers with differently parameterized batch wrappers.

## Scope and remaining gates

The original native CLI remains
`IMAGE --threads 1 --gpu off -- phase111 ABS_INPUT ABS_BASE cache ABS_CARRIER STAMP`.
`phase111` is the unused program-name placeholder consumed by `IO.args`, not a
pipeline selector. The reused transports supply and authenticate these assets.

`N_Imm64` intentionally supersedes the old reflected
`typed-nat-conservative` classification expectation. It does not change
the original19 semantic oracles. Qualify the separate Nat high-value,
owned-record and strict-overflow fixtures; a changed internal fact is not
permission to weaken overflow or lifetime results.

Full-compiler acceptance, direct-call depth, final stack usage, runtime import
closure and source-to-native reproduction remain execution gates. The complete
fallback program stays in `P113DProgram.original`, and public/private wrappers
are emitted alongside the new functions; source presence alone does not prove
the full compiler qualifies or that every function used direct lowering.

For planning only, the old facts campaign took about 284s hosted full emission,
6.5s build, 22s per focused suite, 283s native self-emission/build and 98s
N2 full45. Current candidate costs are unknown. Initially bound full emission
at 500s, full build at 150s, focused suites at 180s each, self-emission/build
at 1050s, full45 at 250s and N2 re-emission at 700s in the outer guard.
These are ceilings, not speed predictions or completed work.
