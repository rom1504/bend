# Phase122 numeric and representation audit

Offline at HEAD920d691. No compiler, target, build, profile or subagent was run
by this audit. Fresh dynamic shares belong to the parent profiling lane. The
strongest next numeric experiment is a genuinely typed private loop/call region;
further untyped inlining alone has already shown limited value.

## Current identity and unchanged gap

Rehashed the Phase121 candidate source, API, runtime, checked-API receipt and
emission receipt against [candidate.json](../phase121/candidate.json); all match.
Source04 hash is `3edd22028a2c2601caa715d2dbbc3694b3fc0a402ad7eda588c438ce64d615d2`.
This is checked-hosted experimental Phase121 on qualified118, not a new native
N1/N2 image. It does **not** contain Phase120 numeric changes.

Rehashed both sides of Phase121's exact-parent-QBE bridge for active ray,
ordinary raytrace, scalar-region8192 and numeric-recurrence1024: all are identical.
Current active-ray QBE is
`selfhost/build/phase118/p121-broad-emit04/variation-ray-active-256-2240.ssa`,
SHA `1e0f9c024c12a1e7a9a52c976083e3c7a0468dd07d6c941fa84c2c1ad9fb6bb2`.
The earlier [Phase119 machine audit](../phase119/numeric-audit.md) therefore
remains structurally relevant; its old sample percentages are not new profiles.
The Phase121 broad screen leaves active ray8.43–8.47× and ordinary ray8.23×
pinned upstream. No conclusion here depends on averaging the fast list/closure
families into those deficits.

## Three concrete code facts

1. **F32 identity is erased before the structured interface.** Current source04
   `N111Type` at39371 contains only U32/U64/Ptr. `p113e_formals:45133` and
   `p113e_arguments:45140` serialize every private value as QBE `l`, regardless of
   NC_Binding kind. `p112fp_binary_text:42786` reloads integer operands from
   scratch, casts each to `s`, calculates, casts back to `w`, then zero-extends
   to `l`. Current `isect5` has ten integer-valued arguments despite ten source
   F32 parameters. The existing `s` arithmetic proves QBE can represent floats;
   the missing persistent F32 representation is in our lowering/interface.
2. **Some categories are already gone; others remain.** Current product-nearest
   returns through a flat result buffer: Hit boxing is already removed. Its
   QBE body is2081lines; nearest.t1987lines; isect5 552lines. These are static
   descriptions, not dynamic costs. Existing machine evidence shows isect5
   with49 GPR/XMM transfers and a2072-byte frame; nearest/tail have large frames,
   Boolean/selector control and separate arithmetic calls. Phase120 removes both
   intended intersection calls, but preserves integer ABI and only branch-local
   float facts. Its tail body grows559→603instructions and frame references
   139→167. Bigger copied regions can increase register pressure.
3. **Upstream's advantage is not just fewer wrappers.** Retained upstream C
   `phase93/broad01/variation-ray-active-256-2240/upstream.1.c:2050` gives Clang
   a large spin22 numeric region. The authenticated earlier machine body has
   packed add/sub/mul/div instructions; inspected QBE and mature-C nearest
   bodies have none. Mature selfhost C also inlines intersection but historically
   measures688ms against upstream201ms and QBE1703ms on the exact Phase119
   source/count contract. This is a product comparison across compiler vintages,
   not a backend-only ablation. Matching mature C would recover much, while still
   leaving approximately3.4× upstream on that measured case.

## Ranked experiments that could go beyond the known22% ray win

| Priority | Hypothesis and discriminating cheap test | Risk / what would falsify it |
| --- | --- | --- |
| 1 | **Keep a typed numeric loop and its private helpers in F32 lanes.** Compare the same frozen computation as integer-ABI baseline, typed-ABI-only, and typed loop-carried/call region. Start with intersection plus nearest, then one unrelated recurrence. Preserve floating operations as structured typed nodes rather than reconstructing their kind from runtime-op strings. Inspect conversions at entries, exits, backedges and calls as well as total time. | Needs F32 versus raw U32 distinction, typed phis/backedges, exact result adapters and spill/stack accounting. Unchanged integer transports or new spills falsify the proposed mechanism. The existing22% region result does not demonstrate this design. |
| 2 | **Specialize immutable scalar selection and loop-invariant fields before machine lowering.** Ray's source has four pure finite Nat selectors sx/sy/sz/sr used inside the nine-sphere fold; Phase120 arithmetic-priority expansion deliberately leaves them. Test one source-level diagnostic replacing the selector ladder with the same ordered constant data, under the original checksum. A positive ceiling justifies a general closed finite-selector plan. | Do not select by helper/workload name or silently change evaluation, Nat overflow, tail-default behavior, F32 rounding or signed zero. Do not infer usefulness from four call sites. Source specialization is a diagnostic ceiling, not an automatic compiler gain. |
| 3 | **Separate compact scalar code from vectorization headroom.** Once a complete typed scalar kernel exists, compare its exact arithmetic schedule through QBE and the retained Clang route, and inspect which independent component operations pack. A tiny equivalent scalar-versus-packed experiment can estimate the remaining machine-backend ceiling. | Upstream SIMD is real static evidence, but its share and attainable gain are unmeasured. Reassociation/FMA, changed reduction order, exceptions, NaN payloads and signed zero are not free. QBE scalar arithmetic is already capable; portable vector IR/emission would be a distinct larger extension, not a flag that automatically creates parity. |
| 4 | **Integrate the existing signed-word win only after cost repair.** Phase120 already demonstrated scalar30% and Mandelbrot10% reductions with exact SAR recovery. Reuse its exact-QBE prepared-graph loop to reduce analysis overhead before combining. | Initial fact maintenance costs2.368s versus0.519s verification on one Mandelbrot graph. The narrower prefilter cuts isolated analysis but has no demonstrated complete-request win. Boolean cleanup was either rejected by the width verifier or neutral. Do not repeat it or skip verification. |

No defensible evidence predicts8× from any single row. Full parity needs several
categories to disappear, or a much stronger semantic specialization than the
current machine-level patches. SIMD alone cannot remove dispatch, selectors,
representation traffic or algorithmic work. The old generic-op sample fraction
also cannot justify a whole-program multi-fold gain from one runtime helper.

## What can be reused from JS without copying its backend

There is more useful existing structure than list/callback fusion alone:

- `selfhost/src/back/js/local.bend:j_region_local_type` proves bounded closed
  private shapes, using a shared256-field budget and rejecting recursive type
  cycles. `j_region_local_fields` retains actual field types.
- `js/region.bend:j_region_result_type`, `j_region_float_signature` and the
  `JVector`, `JVirtual`, `JUnpack`, `JInline` plan nodes preserve scalar records,
  virtual loop-carried state and typed inputs before emission. They can supply
  checked descriptions for native typed fields and result/call boundaries.
- `j_region_number_counter` proves a narrowly used private Nat predecessor
  rather than assuming arbitrary Nats fit a machine word. This may transfer to
  numeric loops when current native admission lacks equivalent information.

These are semantic admission/planning assets, not permission to reuse JS strings
or remove native ownership checks. Source JS Number arithmetic, BigInt conversion
and host/protocol guards have different contracts from native Term/F32 values.
Historical Phase116 JS active-ray was slower than QBE, so JS is not itself a
performance oracle for this workload. Phase121's two substantial native wins
show that reusing an early semantic plan can nevertheless be valuable.

Prefer a small shared typed private-plan interface over another general IR
rewrite: explicit scalar representation, field layout, ownership mode, effects,
ordered operations and boundary adapters. Existing plans can feed it; C and QBE
can project it independently. This mirrors the useful representation/escape and
scalar-replacement ordering already documented in the repository's
[V8](../../research/compilers_architecture_and_techniques/v8.md) and
[Rust](../../research/compilers_architecture_and_techniques/rust.md) source audits.
Those architectures motivate the experiment; they are not measured Bend gains.

First obtain the source-level/typed-kernel ceiling and inspect its machine result.
If it cannot beat the retained untyped region substantially, stop before adding a
large typed ABI or vector backend. If it succeeds, require unrelated transfer,
complete outputs, accepted-transformation checks and whole compilation cost.
