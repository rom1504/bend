# Exact final allocation diagnostic

Authored only; root owns checked API acquisition/extraction. No maintained
compiler source is edited. This route does not produce executable functions.

Prepare the normal Phase190 hosted API from frozen Phase194 selected-source02,
adding `diagnostic.bend` and exactly these replacements:

- `x190_allocate_legacy`
- `x190_j_checked`
- `x191_ordinary_facts`
- `x194fv_place`

Export `p88_cache_prepare,p86_plan,p169np_plan,x181_prepared`. Use
`diagnostic.mjs` with the standard `--api`, `--binding`, `--source-manifest`,
`--out`, `--cases` arguments in the root-owned guarded lane. Suggested initial
CSV: `variation-ray-active-64-2440,editdist,coverage-map-churn-32,tree-bitonic,lexer,coverage-unicode-text-16`.
The final Unicode case was historically held out; record it as research-used
for Phase195 rather than silently retaining its prior status.

The ordinary boundary computes the original `x191_placement` and frame. The
float boundary runs the original post-pruning identities and float-placement
metadata. Both invoke actual allocation. Two overrides insert a route marker
only after allocation has returned; no marker participates in liveness,
coloring or validation. Final frames are serialized directly without calling
callee-save planning, instruction rendering, assembly or target execution.

Payload `kind=phase195-allocator-ir` contains actual setup/placement rows,
parameter names and `allocation`:

- `path`: ordinary or float.
- `route`: joint (validation passed) or legacy (any joint refusal).
- `chosen`: actual joint candidate count; zero for the legacy route.
- `originalRows`: ordinary pre-selected-placement count, or float pre-identity
  post-pruning count. Neither is the old pre-float Phase194 diagnostic count.
- `placementRows`: saturated final setup plus placement row count.
- `safe`: current scalar-safety admission for setup/body.
- `eligibleNames`: positive-score stack-home names in the initial frame.
- `candidates32`: exact candidate selection if joint allocation were attempted,
  with current weighted scores and unchanged32-name bound.
- `homes`: `[name, kind, register-or-frame-offset, weighted-score]` for each
  counted name, from the returned frame. These are static placements, not
  dynamic spill counts or measured hotness. For float paths, they are GPR homes;
  separate XMM placement can supersede canonical private names.

The original setup/body size, parameter count, safety and toggle determine
size/safety refusal. A legacy result inside all these gates indicates a later
fixed-point/validation refusal; this diagnostic does not distinguish those two
reasons. Current unconditional enabled constants remain unchanged.

Never render or assemble a payload. Metadata FloatValues rows are fake integer
ADDs, solely for placement. This driver authenticates the exact four overrides
and extracts typed `PError` JSON, following the maintained Phase192 transport.

## Small next constant experiment

There is no maintained row-limit getter. A separate experimental replacement of
`x190_joint_frame` may change only its `U32.is_le(...,256)` literal to512, keeping
the64-parameter bound,32-name mask, safety tests, final graph validator and
complete legacy fallback. Test512 before1024. Do not change
`x190_liveness_frame`'s256 fallback gate in the same first experiment: that would
conflate joint admission with a second allocation policy change.

The32-name bound is not safely adjustable to64: candidate bits, live/header
sets, graph rows, color groups and affinities all use U32. A larger bound would
shift to zero and silently stop representing later names. Widening needs an
explicit larger-set representation throughout those contracts and its own
verification, not a source constant.

With K fixed at32, selection scans O(K×distinct names), graph collection
O(K×statements), and fixed point at most33 body traversals. The row-limit increase
does not by itself make the graph quadratic in statements. Increasing both
candidate count and statement count can approach quadratic work and increases
validation/affinity costs. Actual compiler request timing and memory remain
required; these bounds do not predict measured latency.
