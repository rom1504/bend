# Phase65 compiler measurement loop

The frozen baseline is Phase64 State09: genuine Bend-emitted B2
`b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e`, with
checked equality-derived B1
`a2f8b021c20becc730cf91e8e7fd6db98f2bba8b743adec89154ff9c6217bd6f` and
95 admitted exports. TypeScript uses upstream `018751270e800bc222a93dad7f257083ee53a5f7`.

`make-method.py` derives the closed Phase64 latency-method02 into a fresh
Phase65 directory. It changes the writable boundary and method paths, updates
the corresponding profiler hash, and adds one exact historical workflow mapping
for the selected Phase64 emission and checked attempt. That mapping requires
identical original/frozen hashes and canonical paths. All independent audit
imports, clocks, frame1–4 decoder admission, sampling, lineage checks and raw
output oracles stay frozen. Selected driver/helper bytes always come from the
selected checked snapshot.

`make-bindings.py` binds actual baseline B1/B2 and optional checked candidates.
A candidate B2 requires a completed own-source emission receipt. The existing
explicit previous-role binding supports cheap same-generation incremental
comparisons; it never manufactures checked sidecars or treats B1 as B2.
The source-backed export-admission reference is required when roots change.

The prepared baseline is `selfhost/build/phase65/baseline-state09/recipe.json`.
Root alone executes its command arrays serially on CPU3 with the inherited
resource guard; data-only tooling runs on CPU0. Execute `prepare` once, then:

| Recipe | Scope | Workers |
| --- | --- | ---: |
| `baseline-four` | Numeric, Lexer, Map/set, active raytrace; 2 roles, 2 balanced rounds | 16 |
| `cpu` | Same sources/roles, one instrumented first request each | 8 |
| `allocation` | Same sources/roles, one sampled-allocation first request each | 8 |

The separate stage factory prepares a fresh observer copy after baseline
preparation completes. It must not edit any consumed prepared driver or helper.
Clean timings exclude instrumentation. Compilation excludes host/API imports;
the combined clock includes both imports and first compilation. Persistent Base
cache preparation is separate from both. Full emitted modules must match each
role-qualified oracle; generated-program execution and semantic qualification
are separate gates. The catalog is the existing 23-source/45-point set; first
residual attribution uses only four sources, so it is not a new broad claim.

Data-only readers are `analysis/clean.py REPORT --out OUTPUT`,
`analysis/cpu.py REPORT --out OUTPUT`, and
`analysis/allocations.py --report REPORT --out OUTPUT`. Allocation analysis is
currently pinned to this four-case selected baseline. CPU shared-SCC names are
not attributed to individual members; allocation accounting uses sampled bytes
and retains tree-accounting mismatches. Timing and profile outputs must always
remain distinct.

Closed Phase64 remains untouched. Every derivative records parent and output
hashes; once consumed, use a fresh successor for method changes.


## Optional Base annotation product inputs

`make-method-v2.py` derives a new method from frozen Phase65 method01 for images
that export all four Base annotation product APIs. Pass the new method directory
to `make-bindings.py --method`. Explicit `prepareBase` creates and validates the
sidecar; the ordinary compiler request only reads it when applicable.

The method preserves the mandatory exact-one frame cache rule and separately
pins `build/typed/base-products` presence, exact file membership, byte hashes,
header identities, and actual parent frame segment hashes. Supporting candidate
images must produce one sidecar. Historical images must preserve directory
absence. Every worker verifies these inputs before and after its timed work,
including sources that only inspect the product header. Hashing is excluded from
the original compilation/import clocks. This does not measure OS-cold storage.
Consumed method01 and prior receipts remain immutable.
