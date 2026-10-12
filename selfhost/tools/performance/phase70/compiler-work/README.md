# Phase70 compiler-work source lane

[Ranked audit](../../../../../implementation/phase70/compiler-work-audit.md) ·
[P70-005 registration](../../../../../experiments/phase70/P70-005-compact-body-reuse.md).

No compiler/Node/Clang/native target was run here. Production sources were not
edited. Root owns integration, execution and commits. Phase69 evidence is read
only. `compact-body-v1.patch` adds six lines and changes three consumers; its
manifest pins exact baseline and proposed bytes. The complete proposed files
are retained in `compact-body-v1/` for review.

## Restricted fixed-point argument

Let C be `nc_compact`, and S be `ns_static_term` using this request's constructor
table and static image. `ns_defs` saves the term projection of S(C(erased body)).
For these freshly produced bodies, applying C once more returns the same term.
This is a source argument, not a checked proof or a blanket normalization law.

- C removes literal leaves and recursively clears removed/span metadata using
  `k_rebuild`; lambda representation and quantity-presence fields are preserved.
  Existing `NStatic` nodes are opaque, but S replaces source-supplied ones with
  the unsupported `NativeStaticInput` marker before saving a fact.
- S retains ordinary structure and normalized metadata, replaces exact Bool/Chr
  scalar forms by `NWord`, and replaces eligible closed constructor graphs by
  opaque `NStatic`. Static-image overflow retains the same constructor structure.
- Neither `nc_nat_literal` nor `nc_word_literal` recognizes a newly inserted
  `NWord` or `NStatic` child as a fresh source literal/Zero/Succ/word spine. Thus
  S cannot expose a newly successful parent compact fold. It also introduces no
  Succ chains. Malformed wrappers retain their original fallback shape; these
  are explicit helper witnesses rather than an assumption of typed-only input.
- C returns NStatic unchanged and structural rebuilding leaves the saved
  metadata, lambda variant and quantity flag exact. Generated NWord and marker
  terms are already canonical for this pass.

The fast path applies only to exact `NativeStaticBody` facts already used by
`nc_definition`. Public production entry goes through `ns_source`, which strips
old payloads. Interior-cache/unprepared books receive no invented admission.
No fact means the exact old compacted definition computation, including foreign
fresh IDs, intrinsic bodies, absent definitions and raw terms.

Independent review agreed with this producer-specific argument and requested
actual helper checks for malformed wrappers/metadata and static nodes before
promotion. `compact-body-controls-v1.mjs` supplies 124 producer fixed-point terms
and accessor comparisons over three fresh IDs, prepared/unprepared, stale
payload stripping, foreign, absent, intrinsic and missing cases. It is source
only and has not been imported or run. It exports helper names/arities for an
append-only checked-B1 diagnostic wrapper following Phase69's static controls.

The reviewed [paired controller](run-compact-body-controls.mjs) consumes
`compact-body-controls-v2.mjs`, whose exact derivation only retains complete terms
for cross-role comparison. It requires 155 queries per role. Root runs it inside
the existing CPU3 guard, binding actual checked images to their build receipts:

```sh
node selfhost/tools/performance/phase70/compiler-work/run-compact-body-controls.mjs \
  BASELINE_B1_API CANDIDATE_B1_API selfhost/build/phase70/FRESH_COMPACT_QUERY_RUN
```

[Independent review](independent-review.md) found no source or method blocker.
The controller is ready to execute; no result is claimed here.

## Saved profile reduction

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase70/compiler-work/profile-work.py \
  --summary selfhost/build/phase70/compiler69-profile02-summary.json \
  --out selfhost/tools/performance/phase70/compiler-work/profile-work-v2.json
```

The output must be fresh; the command above describes the completed reduction,
not permission to overwrite it. The producer verifies every consumed profile
against the original summary and records its own hash. Its sampled stack-union
rows overlap, are not call counts, and can miss inlined/trampolined frames.
`profile-work-v1.json` preserves the exploratory reduction before the standalone
producer was written; use v2 for the verified receipt.
