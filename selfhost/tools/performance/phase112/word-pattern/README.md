# Fixed-width pattern recovery

This optional adapter exposes an existing semantic optimization to the direct
structured QBE backend. It accepts the mature `nw_applicable` U32/F32 wrapper
shape, obtains ordered low-bit pattern rows with `nw_walk`, and emits integer
mask/equality branches. It never materializes the 32-cell Word merely to test
a scalar literal. Algorithms remain in Bend; runtime ABI and checker stay fixed.

The compiler profile motivating this experiment counted 1,625,654 U32 special
takes. Runtime04's generic conversion allocates 32 Word cells and 31 reference
wrappers per take: 102,416,202 allocations, or 82.14% of the recorded 124,677,389
heap allocations. These are allocation counts, not a prediction that 82% of
elapsed time disappears. Runtime profile evidence is recorded by the separate
profiling task. No performance gain is established by this source candidate.

## Semantics and ownership

`p112m_body` reuses the mature beta-substitution, `nw_prefix`, `nw_restore`, and
remaining-argument reapplication order. Reconstruction of the original U32 or
F32 wrapper becomes the saved original low32 scalar. Float matching compares
raw representation bits, preserving signed zero and NaN payload distinctions.

All rows are planned before lowering starts. If any row still refers to an
escaping residual Word tail, the entire match uses the exact generic fallback.
A required bit is computed with `(low32 >> depth) & 1`; no tail allocation is
introduced. The independent classifier preserves the mature row order because
more specific matches can overlap later default prefixes. Depth32 uses an
explicit `0xffffffff` mask, avoiding a width32 shift corner case.

The matched U32/F32 is an immediate runtime word. Its consumed environment
binding is removed, the saved scalar/bit are immediate bindings, and unchanged
`p111_lower` partitions remaining owned values independently for each branch.
Three IDs are reserved before **every** branch, including exact depth32 rows.
Fresh supply advances across lowered row bodies while all row conditions refer
to the same reserved saved scalar. Admission rejects collisions in Var/Lam/Bind
IDs, environment IDs, and generated binding names, and rejects counter wrap.

Only the original raw `Mat` wrapper is accepted. A caller-provided `NWPattern`
marker is not a trusted row certificate. Nonmatching wrappers, malformed
recognition, empty rows, collisions and escaping tails retain the original
fallback. This scope deliberately omits a residual-Word allocation helper.

## Composition and qualification

Compose `original.bend` and `emit.bend`, then apply `entry.bend` as the final
`p111_match_apply` override. `original.json` pins the exact renamed fallback
from `failstop-source01`. No installed module list selects these files.
Do not modify an already frozen source snapshot; preserve separate profiles.

The source was independently reviewed for raw-bit representation, row priority,
restoration, reservation, branch freshness, fallback identity and owned-value
handling. That review is not target validation or a whole-compiler proof.

For host controls export `p112m_match_apply`, `p112m_original_match_apply`,
`p112m_plan_rows`, `p112m_emit`,
`p112m_mask`, `p112m_fresh_terms`, `p112m_fresh_env`, `nw_walk`, `nw_applicable`,
and `nw_prefix`, then run under the root's serial guard:

```sh
node selfhost/tools/performance/phase112/word-pattern/controls.mjs \
  CHECKED_API FRESH_REPORT.json
```

The independent N111 interpreter accepts only scalar operations, drops and
terminal returns. Any remaining constructor/materialization helper fails that
gate. Finite cases include zero/high-bit/all-bit literals, newline/CR, NaN and
infinity bit patterns, both wrappers, masks, overlapping defaults, wrapper
restoration, escaped tails, and malformed/freshness refusals. This tests scalar
semantics; native captures and runtime ownership still need checked fixtures.

Next gates: exact stdout/status/stderr for checked scalar-pattern fixtures;
inspect generated IR for removed special takes and Word construction; reuse
the small six-source compiler batch; acquire a compiler image only after those
mechanism and correctness gates pass. Attribute compilation overhead and native
compiler execution changes separately from generated QBE size and instruction
counts. Selector specialization is a separate optional experiment.
