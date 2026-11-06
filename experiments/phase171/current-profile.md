# Phase171: current installed compiler cost profile

The capture is valid. It identifies several substantial costs, rather than a
single remaining check: parsing/loading **28.74s**, private candidate production
**25.51s**, checking/publication **21.24s**, registry preparation **12.18s**, and
cursor rendering/output/exit **32.45s**. The final view/certificate plus direct
verifier interval is only **3.13s**. Optimizing that verifier cannot by itself
close the full-build gap from 189.33s to 100s.

This is a diagnostic profile, not a new clean performance result or a change to
the installed compiler. The machine assembler/linker and QBE process are outside
this capture. [The cost model](cost-model-plan.md) retains their measured bounds.
[The bounded JSON](current-profile.json) contains every disjoint clock, sample
denominator, classification rule and source receipt identity.

## Measurement and validity

- Input: the exact 3,150,535-byte maintained Phase170 source,
  SHA256 `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
- Compiler: diagnostic relink of the retained installed N2 program object; the
  selected image is `0dba3d4d19cd974e759058afbe86608fc7e1770d0c5ebf8f9d06c2697b658f4f`.
  Runtime instrumentation is explicitly diagnostic; this is not the unchanged
  installed ELF executing without hooks.
- Prepared Base, exact request/runtime assets, CPU3, one heap mutator, GPU off,
  fresh process, regular-file stdout. No event/allocation counters enabled.
- Full 97,488,970-byte QBE output exactly matches the independent retained Q3
  oracle, SHA256 `661b62664acdac83d12bc3192b5f9113a2bb946dd331433e64ca0452f6f83850`.
  The run is complete/passed with no changed inputs.
- Child wall **180.095051s**, process CPU **179.901145s**, peak RSS
  **811,912KiB**. The outer guarded-tool interval is a different boundary.
- **5,584 samples at 32ms**, 99.3751% main-thread/process CPU coverage, zero dropped
  samples/overruns, intact handler and valid shutdown. All exact markers pass
  order/multiplicity and ELF/FID binding. 45,896 actual table FIDs and 60,569
  function symbols are checked by the owner binding.
- The 29 adjacent intervals sum to **179.960586s**, leaving 0.134465s outside the
  first marker/exit-hook span. Each interval excludes the samples adjacent to
  its two boundaries; excluded samples remain in the whole-capture denominator.

Prior clean Q3 was 164.616132s. The 9.4% difference cannot isolate instrumentation
overhead from run variation: there is no same-block unsampled diagnostic parent.
Use these clocks to choose work and require a subsequent clean comparison for
speed claims. The Map pilot passed output/marker gates but had too few samples
for whole-process quantitative attribution; it was only a calibration control.

Evidence: `selfhost/build/phase171/profile-build01/report.json`,
`profile-pilot01/report.json`, `profile-pilot-stages01.json`,
`profile-full01/report.json`, `profile-full-stages01.json`, and the pinned
`profile-prep01/spec.json`. The initial incompatible guard-root preflight
refusal started no job and remains preserved; the successful relocated plan is
`profile-plan-v2.json` with products under `profile-products01`.

## Disjoint stage clocks

These are first-entry intervals, including their continuation, argument
evaluation and ownership work. They do not measure inclusive source functions.
The first column gives the semantic boundary; exact marker names remain in JSON.

| Region | Wall seconds | Interior samples |
| --- | ---: | ---: |
| Prepared Base setup |0.236|6|
| Parse/load |28.742|896|
| Check/publication |21.239|662|
| Reporting, ownership, context, annotation and erasure |18.080|553|
| Backend runtime/catalogue/static/observer/signature preparation |8.417|252|
| Raw private candidates |25.514|795|
| SCC and dependency admission |1.290|38|
| Selected inline preparation |0.108|2|
| Scalar finish and retry composition |8.635|268|
| Demanded generic fallback families/adapters |8.443|261|
| Actual generic/static/adapter verifier |8.914|277|
| Private discipline |0.001|0|
| Flag-only view/certificate and borrowed/direct verifier |3.129|96|
| Namespace/live/cold metadata |2.341|71|
| IDs, tables, fusion index and seeded registry |12.182|379|
| Cursor/forwarder/prefix preparation |0.238|3|
| Cursor rendering, output and exit hook |32.451|972|

The 18.08s frontend block contains 2.57s reporting, 0.19s ownership eligibility,
0.66s context preparation, 6.30s annotation, 2.53s layout preparation and 5.83s
remaining request preparation. They are separate clocks, not costs inferred from
function samples. The backend preparation block includes 4.13s static-body
preparation and 1.72s observer classification. See exact intervals before drawing
conclusions about an individual helper.

The backend from runtime admission through exit is 111.66s; frontend preparation
through request creation is 68.30s. Only four individual intervals have the
predeclared 500-sample minimum: parse/load, check/publication, raw candidates and
render/output. Smaller intervals have valid clocks but descriptive distributions.
Combining clocks does not automatically qualify their owner distributions.

This exact request takes `p169q_closed` once and never takes `p169o_closed`:
the measured inline preparation is the selective route, not a new measurement
of broad ordinary inlining. The authenticated runtime descriptor has capability
bits5 and live-register-bank support; no arrays capability is inferred.

## What executes inside the expensive regions

Physical symbols resolve 95.74% of samples. Active lexical owners are much less
complete: **53.58% are unknown**. The new demanded factory/adapter arrangement
does not always satisfy the old contiguous lexical-owner grouping contract.
Actual addresses/FIDs are authenticated; source-owner grouping remains
conditional. Unknown samples stay in denominators. A private call can also retain
its caller's dispatch context, so an active owner is not a logical call stack.

| Region | Leading known active contexts | Physical evidence |
| --- | --- | --- |
| Raw candidates |`nc_uses_term`76, `nc_uses_list`42, `nq_layout_subst`26, `nd_arity`25 /795|25.2% lifetime/reclamation,16.1% product access/construction,12.3% selected string/hash workers;46.9% owner unknown|
| Demanded fallback |`nc_uses_term`33, `nq_layout_subst`19, `nc_uses_list`11 /261|28.4% lifetime/reclamation,14.6% products;37.9% owner unknown; descriptive|
| Original verifier |`p111v_decl`19, `p111v_assign`15, `p111v_step`15 /277|26.0% lifetime/reclamation,16.6% selected string/hash workers;63.5% owner unknown; descriptive|
| Direct/view verifier |`p111v_decl`7, `p111v_assign`4, `p118ns_project`3 /96|Small whole-stage ceiling3.13s;66.7% owner unknown; descriptive|
| Scalar finish |`nol_scalar_specs`63, `nd_arity`14, `nol_owner`11 /268|38.1% lifetime/reclamation,18.7% products;47.4% owner unknown; descriptive|
| Registry/index/tables |`p112r_scalar`20, `p112c_try`16, `p112r_buffer`15 /379|25.9% products,23.5% lifetime/reclamation,12.4% selected string/hash workers;55.1% owner unknown; descriptive|
| Render/output |`p112t_scalar_safe`25, `p112f_clean_stmt`17, `p112w_private`14 /972|38.8% products,17.0% lifetime/reclamation;72.7% owner unknown|

Parse/load has `f_grow_base`48, `f_pattern_sub`39 and
`f_context_material_children`33 known active samples. Check/publication has
`index_remove`56, `subst_node`16 and `book_final_scan`15. Their unknown-owner
fractions are 54.9% and 56.5%. These observations justify examining repeated source
traversal and publication work; they do not prove any one operation dominates its
entire interval.

Whole-capture physical groups, classified by explicit ordered rules in JSON:

| Disjoint physical group | Samples | Share |
| --- | ---: | ---: |
| Lifetime/reclamation, including sink/keep |1424|25.50%|
| Product access/construction, including take/constructor/extend |1132|20.27%|
| Selected named string/hash workers |631|11.30%|
| Registers/transport control |323|5.78%|
| Scheduler |252|4.51%|
| Allocator entry bodies |89|1.59%|
| Other generated code |1172|20.99%|
| Other resolved physical code |323|5.78%|
| Unresolved physical code |238|4.26%|

The largest individual leaves are `term_drop`633, `span_fade`377, the existing
borrowed `p88_string_eq_go`355, `p125_rt_take2`250 and scheduler250.
Lifetime/products/allocator together account for 47.37% of samples **under these
explicit rules**, which differ from historical profiler groups. This is not a
removable 47% allocation cost: these helpers execute required value movement,
ownership and construction. Allocation counts and allocator-origin attribution
were not collected. No historical allocation count or speed ratio is transferred.

## Best work-elimination hypotheses from this capture

1. **Reuse prepared source facts across private attempts and demanded fallback.**
   The 25.51s raw stage and 8.44s fallback stage expose the same use-set, layout and
   arity computations. `flat-products.bend:431` constructs raw candidates after
   source eligibility; `early-observers.bend:254` later starts demanded generic
   production. A shared, source-bound prepared representation could remove
   repeated analysis and temporary values without removing final verification.
   The combined 33.96s interval is a generous total envelope, not predicted gain:
   many owners are different and necessary lowering remains. Require complete
   actual compiler-helper products, fallback refusals and final output equality;
   a scan-only microbenchmark is insufficient.
2. **Retain final emission plans instead of rediscovering public fusion.**
   Registry and render together occupy 44.63s. Rendering includes real analysis:
   `stream-emission.bend:67` calls `p124r_public`; the mode0 branch explicitly
   calls `p112c_plan_index`, and the direct-aware route also performs public
   fusion preparation. Registry entries already retain private plans, but public
   rendering still uses the final registry to derive plans. A bounded plan made
   against that exact final registry and consumed once might save duplicate
   scans/reconstruction. Do not reuse an earlier rank's incomplete registry or
   merely disable fusion: prior experiments established generated-runtime harm.
  44.63s is the entire-region ceiling; text generation, machine semantics and
   cleanup remain. The capture does not isolate the redundant portion.
3. **Cache the exact scalar catalogue within one immutable prepared book.**
   This is the cheapest focused lead. `nol_scalar_specs` is the leading known
   scalar-finish context, and `borrowed-regions.bend:538` appends
   `nol_scalar_specs(book,book)` in `p128bl_finish`;
   `observer-layout.bend:261` has a corresponding successful-schema path. Existing
   request scan reuse does not establish reuse through every retry/schema path.
   Pass the same exact catalogue into those consumers, preserving errors,
   ordering and complete final output. The entire 8.64s stage is the absolute
   local envelope; the 63/268 active samples are descriptive, not 2.03s of proven
   removable work. This can be a useful fast-loop test but cannot meet 100s alone.

For a larger combined result, parsing/checking/publication deserve equal status:
they total 49.98s before the other 18.08s frontend work. The present evidence does
not support another standalone consuming-string-equality rewrite, index zipper,
or verifier-disable experiment. Equality already uses the borrowed worker, the
earlier zipper was neutral, and independent final gates remain mandatory.

## Honest envelopes against 100 seconds

The clean 189.329s whole build needs 89.329s less time. Its separately timed
assembly+link is 4.856s. The cross-run 24.713s difference from clean Q3 is **not**
exclusive measured machine time; it includes machine work, relay/backpressure,
bookkeeping and run variation.

Conditionally keeping that residual unchanged leaves 75.287s for the compiler,
requiring 2.19× compiler speed. Even making the entire compiler 2× faster would
give 107.02s under that budgeting assumption. No single measured stage is remotely
large enough: the largest is 18.0% of diagnostic wall time. Making only candidate
production, demanded fallback, registry and rendering all 2× faster would remove
39.29 diagnostic seconds, 21.8% of the capture, before conversion to any clean
whole-build claim. Such a large collective gain still would not establish 100s.

The next implementation should therefore prove elimination of repeated work in
one complete producer-to-consumer path, with cheap exact-product gates, while
retaining frontend and representation improvements as additional necessary
avenues. This capture provides ceilings and priorities, not a 100s forecast.
