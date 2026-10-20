# Optional flat-product and bounded-DAG inlining

The products11 local-pair output shows a chain
`$product.cell -> f1 -> f2 -> f3 -> f4`. Its flat signatures reach nine
arguments and two results. The helpers contain array-pair imports and further
direct calls. Merely accepting two return values in the scalar leaf inliner
would leave this chain untouched.

This optional profile composes after source13's direct inliner and the checked
product runtime profile. Append `scratch.bend`, `helpers.bend`, `buffers.bend`,
`audit.bend`,
then apply `overrides.bend` as explicit final declaration overrides. Public
entry and optimizer APIs stay `p113d_lower_request` and `p113i_optimize`.
No base source13 files change.

The extension admits scalar or flat-product workers with 1–8 results and up to
32 arguments. Copied bodies may contain verified direct calls: their targets
remain earlier functions in the original DAG. Self-loop edges are still
refused as callees. Result vectors are copied into fresh result temporaries
before any caller destination is assigned. Every callee local, argument,
scratch buffer and nested call destination receives the normal fresh prefix.
Runtime calls remain in their original order.

Policy is bounded: 192 nodes per candidate, 2,048 initial caller nodes,
16 expansion sites, and 512 additional nodes per function. Explicit stack
reservations remain limited to 8 KiB per candidate and 16 KiB per transformed
caller. Expanded-node accounting includes every result snapshot and destination
assignment. Bottom-up processing can expose small wrappers; it need not first
flatten every call in a candidate.

An inline scratch allocation uses the maximum known footprint of fixed loads,
stores and exact counted runtime imports. Unknown pointer use keeps all
2,048 bytes; an unused scratch pointer requires no allocation. The footprint
does not change the emitter's ordinary per-function scratch reservation.
Post-transform structural verification checks the reduced capacities again.

`p113j_audit(program)` lists every function's argument/result widths, current
node count, explicit stack bytes, implicit scratch footprint, candidate status
and remaining direct-call targets. Export it for bounded before/after admission
diagnostics; normal compilation does not construct this report.

`audit.mjs CHECKED_API INPUT FRESH_PHASE113_OUT [cache|live]` reproduces source
checking and runtime admission before recording verified before/after audit
text. Export `p113pl_lower_request` to obtain the actual pre-inlining product
IR; without a raw lowerer export the report explicitly labels its input as
possibly already optimized. The driver never builds or executes a target.

`policy-wide.bend` is an isolated optional final override for the candidate
node limit (192→384) and per-caller growth budget (512→1,024). It retains all
other structural, site and stack gates. Select it only after admission evidence
identifies a node-boundary bottleneck; it is not the default policy.

The product import's name gate now accepts only original `scratch` /
`p113p_out_*` names or recursively nested exact
`p113i_<0..15>_local_` prefixes. All original operation, type, state, arity,
capacity and output-width checks remain. This permits hygienic renaming
without making arbitrary raw heap accesses legal.

Qualification must cover swapped/overlapping result vectors, calls retained
inside copied bodies, nested namespaces, array ownership, scratch footprint
boundaries and conservative unknown-use behavior. Measure actual surviving
calls and runtime after those gates; source readiness alone is not a speedup.
