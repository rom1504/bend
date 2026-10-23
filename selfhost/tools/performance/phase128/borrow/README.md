# Phase128 scalar-result borrowing experiment

Status: source-only bounded candidate; the coordinating agent owns checking,
execution, measurement and promotion. No target was run by this implementation
agent, and nothing here changes the selected compiler.

Parent source is Phase127 `live-bank-source01/compiler.bend`, SHA256
`f4eb3c6b8aca8cdfc72c8eb308db83af50c6bee888a93b69415a77aa5101318d`.
The candidate derives from the reviewed Phase118 `scalar-observer-v2.bend`.

## First obtain a refusal census

Append `diagnostics.bend`, which overrides nothing. Export:

- `p128bs_plan_diagnostic(request, owner)` returns schema, analysis and residual
  errors, wrapper/result type, root count and current admission.
- `p128bs_ready_diagnostic(request, owner)` runs ordinary request lowering once
  and reports the public owning worker, arity/results and direct dependencies.

Use the actual Phase127 name-search request and owners `p88_string_eq_go`,
`p88_string_eq`, `has_name`, `has_name_next`. Diagnostics select a requested
owner only for reporting; the transformation never recognizes these names.
`has_name` is expected to fail schema admission because `List<String>` has an
owned String payload, whereas the existing observer schema only admits one
recursive child plus scalar fields. This is a principled limitation; it is not
evidence that whole-list borrowing is illegal.

## Candidate assembly

Append `scalar-observer.bend` and replace exactly these definitions:

- `p118b_project_call`
- `p118e_permitted`
- `p118i_borrow`
- `p118z_runtime`

Append `controls.bend` and export `p128bs_controls` for twelve finite interface
and rejection checks. Runtime assembly must add the unchanged reviewed helper
from `phase118/runtime-scalar-borrow.c`. Preserve its SHA and the runtime identity
in the immutable source/build manifest. Its guard accepts one or two roots that
are trivial or have external shared ownership. Two aliased nontrivial RFC roots
are conservatively refused, ensuring final root sinks are constant-time.

The adaptation preserves the current Phase126 root-returning observer and flat
worker closure (`p126bp_integrated`) rather than restoring Phase118 composition.
It retains the repaired `p126_rt_nat_divmod` transport whitelist and adds the new
readonly scalar guard, which neither transitions nor touches register banks.

The scalar schema, result index, observation type and explicit `nol_scalar` check
establish a typed nonowning result. NO analysis derives the read-only recursion.
The guard wrapper holds both owning roots until the reader has returned, sinks
them exactly once, and otherwise invokes an exact copy of the original owning
worker. Each fallback remains restricted to a body with no `P113DCall`; this is
needed because additions precede existing functions and the independent verifier
admits direct dependencies in order. Do not remove that restriction in isolation.

All original request verification remains. The new guard receives an exact
state/word/word/U32/result/count interface check before structural projection.
The unchanged independent projected-function verifier checks dependencies and
ordinary readonly field imports. The existing flat closure and final verifier
remain active. No permission, ownership or result admission condition is relaxed.

## Decisive checks

1. Check the assembled Bend producer and twelve finite controls.
2. Emit the unchanged name-search proxy; inspect actual selected
   `$p128borrow.owned.*` and `$p118borrow.read.*` symbols. Correct output without
   selected workers is fallback correctness, not an optimization success.
3. Run the independently frozen name-search output controls and
   `ordinary-controls.bend`: the unchanged Phase118 renamed equality/unique/
   shared/mixed/alias/Unicode controls plus dynamic distinct roots sharing a
   suffix, early mismatch, and non-tail/owned-result refusal examples. The
   latter two must be inspected in the plan diagnostics; correct ordinary
   output alone does not prove that the candidate refused them.
4. Compare the identical name-search work and counters, then an unrelated
   borrowed String observer. Preserve unique-root guard overhead and all
   refusals. Do not extrapolate a proxy speedup to whole-compiler throughput.

If direct dependencies block an otherwise useful scalar observer, the next
bounded extension is insertion at its original topological position, retaining
every prerequisite and checking the complete projected function list from an
empty ready set. Preseeding all signatures would admit cycles and is not an
acceptable shortcut. Wait for the census before implementing that extension.
