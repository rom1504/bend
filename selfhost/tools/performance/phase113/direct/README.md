# Complete ordinary functions before runtime frames

This candidate lowers the actual checked, erased function body into a local
destination representation. It does not recover a function from dispatcher
segments or parse generated C. The generic/static result remains alongside it
as the unchanged fallback for unsupported definitions.

`p113d_lower_request` performs the existing native admission and static
preparation, then uses that same prepared book for both paths. A candidate
reapplies the compact erased body to the mature typed entry parameters, as
`nf_candidate` does. Application normalization reuses `nd_beta`, `nc_sequence`,
`nd_match_sequence`, `nc_field_apps` and the original live-arity checks. Primitive
operations, constructor operations, tests, takes and ownership partitions remain
the selected Phase112 structured operations. No new runtime ABI is needed by the
first one-result slice.

The new mechanism is a local result destination. A let evaluates its value into
a named U64 local and continues with the common suffix; a match assigns that
same local in both branches. It does not save a runtime continuation for an
ordinary call or branch. Existing `keep`, `sink` and live-environment decisions
are retained. The initial result classifier remains conservative for unknown
call and primitive results.

Ordinary calls use explicit argument/result vectors in the plan. Self calls are
accepted only in return position and become a local `Again` edge with parallel
argument transfer. Non-self callees must already be admitted. The resulting
function list is ordered callee before caller, and the independent structural
verifier checks this order. Non-tail self recursion and mutual native-call
cycles fall back. This gives constant native stack usage for a self-tail loop;
ordinary call depth is bounded by the admitted acyclic function graph.

The first slice has full-Term parameters, one full-Term result and a32-parameter
bound. Missing callees, partial or dynamic applications, escaping lambdas,
parallel forms and effect matches decline the complete function. Unhandled
forms retain the generic path. The32-pass dependency bound is a compile-time
admission limit, not a claim of semantic rejection. Efq retains the existing
runtime04 CPU fail-stop premise: `p111_rt_fail` reaches `err_post`/`err_fail` and
terminates the process before the syntactic return. Device behavior is outside
this candidate.

The vector model reserves multi-result products for a separate qualified layer.
`public` marks ABI-compatible wrappers. A private-only flat function must not
replace a boxed public entry merely because its numerical arity happens to
match. Product shape, layout and runtime qualifications remain separate.

Source composition order is `model.bend`, `helpers.bend`, `lower.bend`,
`plan.bend`, followed by `../direct-emit/` modules. No Phase112 declaration is
overridden by this first prototype. API:

- `p113d_lower_request(NR_Request) -> P113DLowering`, constructor
  `P113DLowered{program,error}`.
- `p113d_candidate(book,name) -> P113DCandidate` exposes a local refusal
  diagnostic for checked-request transports.
- `P113DProgram{original:P112StaticProgram,functions}` retains the complete
  fallback. The emitter/verifier owns final output admission.

Source authentication must bind these modules, the exact Phase112 facts source,
the selected runtime04/header, the original structural verifier and the mature
normalization/ownership helpers listed above. Also bind `nc_compact_definition`,
`nc_ref_name`, `nd_arity`, `nf_worker_kinds`, `nk_typed_bindings`, `nk_binding`,
`p111_partition`, `p111_keep`, `p111_intrinsic`, `p111_constructor`, `p111_test`,
`p111_take`, and static preparation. Raw caller-supplied plan records are not
proofs of ownership or provenance; the public compiler constructs them only
from its authenticated checked request. Structural tests do not establish
whole-compiler correctness.

Initial source01 was accepted by the parent's checked API in8.97s. Native
semantics, complete-loop shape and matched performance remain pending at this
milestone. Independent controls are frozen separately in `../controls/`.
