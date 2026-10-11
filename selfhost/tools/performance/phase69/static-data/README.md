# Native immutable constructor images — source candidate

Experiment: [P69-002](../../../../../experiments/phase69/P69-002-static-data.md).
Current proposal is v2, frozen after independent source review. The initial
v1 proposal is preserved in `v1/`; it was not executed or integrated.

This directory is a source proposal; no compiler or native target was executed
by its owner. Root owns integration, qualification, measurement and promotion.

`static.bend` is the proposed new native module. `integration.json` describes
13 exact single-occurrence source replacements plus the new file;
`integration.patch` is their diff against c84246e. The root's reachable-bang
change must supply `nc_bangs_names(book, names)`. Run
`prepare-integration.py` only to regenerate these descriptions; it never edits
production files. It reads the pinned Git source, so it cannot absorb another
agent's production changes.

## Mechanism and boundaries

1. After existing `nc_compile` validation, strip previous private BookCache
   payloads, retaining the source index and original definitions exactly. A
   non-head BookCache sentinel conservatively disables preparation, preserving
   its authoritative index/ignored-tail lookup semantics.
2. Compute reachable names, erase/compact each ordinary body once, and retain
   a request-private indexed body cache. Native primitives/foreign bodies keep
   their old path because their temporary binder IDs may depend on emission.
3. Traverse bottom-up. A known constructor with exact erased arity and only
   canonical U32 words or already-proven static fields can become static.
   Bool/Char immediate wrappers are preserved as their ordinary scalar words.
   Arrays, IO nodes, nonconstant expressions and malformed wrappers fall back.
   User-foreign books conservatively disable this whole optimization.
4. Intern nodes by constructor identity and exact field words. Child locations
   precede parents; image growth is bounded at 65,536 words. Exceeding the bound
   leaves remaining nodes dynamic without invalidating earlier static children.
   Zero-field and fitting user one-field scalar constructors keep packed words.
5. Every lowering route uses the same prepared term. A static product result
   can still return fields through `nq_transfer`, preserving product admission;
   scheduler and opaque destinations return the immortal word. Native atom lets
   recognize these already-evaluated words without continuation frames.
6. Existing `STAT_IMG` initialization, `term_triv`, `ctr_take` and `spare_free`
   implement lifetime behavior. The image contains only immediate words and
   immutable constructor pointers; it contains no closure, array, task or
   mutable state. No runtime ABI change is needed.

Raw input carrying `NStatic` is rewritten to an unsupported marker during
preparation, so a stale/forged image offset cannot become a trusted image fact.
Source definitions themselves remain unchanged for arity/layout/type queries.
The old image and installed compiler are unaffected until root promotes a
qualified build. There are no JS changes.

## Focused controls

- `fixtures/string-shared.bend`: Unicode String, repeated consumption and a
  static tail in a dynamic constructor, expected 7n.
- `fixtures/nested-shared.bend`: independent recursive ADT, sharing, consuming
  recursion and dynamic/static mixture, expected 16.
- `fixtures/product-and-packed.bend`: nested record, packed immediate field,
  constant product producer and consuming product worker, expected 1131.

`raw-review-cases.mjs` adds interior-cache lookup, forged prior-payload and
forged static-node controls from independent review.

Root should additionally retain raw malformed controls, source API/cache-forgery
checks, existing IO/foreign controls, nonconstant/array fallback, deterministic
B1/B2 C equality and a thread-4 run. Expected source shapes are STAT_LEN > 0 for
nontrivial graphs, no tpl heap allocation, preservation of ordinary fallback,
and no product-worker rejection introduced by NStatic.

This adds a preparation concept rather than another scheduler/worker-specific
optimization. It also avoids repeating erasure/compaction across candidate
worker retries. Whether that amortizes its new pass cost belongs to fresh B1/B2
measurements; no compilation-speed gain is claimed in this proposal.

The 65,536-word limit bounds image growth; it does not newly bound AST depth.
The pass is linear in the visited AST plus indexed graph operations. A long
literal control should qualify stack behavior against the existing compact
pass; no out-of-bound image word is emitted after the limit.
