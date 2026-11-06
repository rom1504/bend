# Independent review: admission metadata and immutable scalar eligibility

Source-only review,2026-11-06. No target execution or source modification.
Reviewed `selfhost/tests/phase169/admission-work.bend`,6,045 bytes,SHA256
`3952e24256f0e70aab26785887c3b51a6f1556825e16270c139cb1a61b68c8fe`, and
`admission-controls.bend`,5,087 bytes,SHA256
`274e8ae0878e81f547f5777f5dbe425719429ec2b92d760fab8356fc027c5683`.
Prepared source02 is1,623,503 bytes,SHA256
`2fb61127018bc5731e8bf811c185fa43134e819b901920812173fb8d84a2b21e`.

**No semantic blocker found in the admitted finite compiler domain.** Source
checking, actual output equality and performance still require the root's jobs.

The early metadata test is exactly the existing conjunction
`incoming==0 && flags==0 && result==1 && arity<=32`. It is a necessary condition
in both original `p168j_eligible` and maintained `p112c_candidate`. Therefore:

- A failed condition makes original import eligibility False independently of
  the direct map. Delaying the lookup until after that condition preserves the
  result and exact remaining kind/arity/result/public checks.
- The old candidate walk either skips an imported segment or applies
  `p112c_candidate`; a metadata-failing segment cannot survive either branch.
  Skipping its imports lookup preserves output membership and reversal/order.
- For metadata-valid segments, imported-first filtering, candidate body hygiene,
  accumulation and final reverse are unchanged. No invalid segment becomes a
  candidate. This reorders pure finite queries; it does not claim equivalent
  resource-exhaustion behavior on fabricated cyclic host values.

Scalar caching is also at the correct boundary. The unchanged
`p128bs_eligible(book,plan)` reads the plan schema, error, wrapper, root list,
prepared book and generated reader-body validity. It does **not** read the list
of direct functions. Original `p168t_selection` and later `p168_scalars` query
the same immutable book and exact plan; intervening selective inlining changes
only direct function bodies. Thus the cached Boolean remains valid there.

Crucially, `p128bs_find` is still called with the **post-inlining actual function
list**, where it independently checks name, public flag, single result, leaf body
and parameter count before constructing workers. The cached predicate does not
stand in for those checks. `p169q_scalar_ready` preserves added-worker reversal,
helper seeding, empty-result retry insertion, error propagation and final order.
`p168_scalar_result` and downstream closed-worker/actual-program gates remain the
same consumers. The initial observer scan and later replanned consumer retries
are not replaced by cached answers.

Mode1 computes each post-scan eligibility once and reuses it in selection and
materialization. Mode0 keeps the original `p168_inlined` route. Both append the
same one-element function-count statistic exactly once. Early metadata filters
apply wherever those overridden registry helpers are used, but remain the
membership/order-preserving transformation above. There is no new global cache,
cross-request identity or serialized success certificate.

The `+` annotations retain the same immutable books/plans/functions across their
consumers; new `P169ScalarPlan` records add retention/allocation work that must be
charged. Pure source equivalence does not establish net speed. The record is a
private intermediate constructed by `p169q_plans`, not an externally accepted
authority to skip actual machine-code verification.

The14 controls include literal metadata boundaries, import rejection, candidate
order, positive/negative predicate values, complete selection-index comparison
and retry-plan comparison. Their scan fixture has **no owning function**, so it
does not directly exercise successful added-worker construction or its error
branch. That is a coverage limit, not a discovered implementation defect. Before
promotion, retain the planned exact emitted-QBE comparison on real compiler
computations with actual scalar worker additions; a tiny genuine-worker fixture
would also close that boundary cheaply. The fixture's plan comparator deliberately
requires empty specialization lists, so it is not a general plan-equality oracle.
