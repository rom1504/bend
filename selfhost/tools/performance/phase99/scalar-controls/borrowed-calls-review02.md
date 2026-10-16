# Independent review of implemented borrowed calls

Exact candidate: `borrowed-calls-source03/compiler.bend`, SHA-256
`3a3d9c098fc8d091e0fde08f2b02a54e6fe96e5e0705ca8195144acb4cae5ccb`.
Reviewed `helpers-v3.bend`, its source recipe and the completed
[`borrowed-small04` receipt](../../../../build/phase99/borrowed-small04/report.json)
against [the seven earlier requirements](borrowed-calls-review01.md).
No blocking safety defect was found in this bounded source review. This is not
a complete compiler or native-lifetime proof. The reviewer ran no targets.

The implementation satisfies the planned first-stage boundary:

- `no_route_pair` publishes a `NO_Callee` only after both fresh private worker
  and owning adapter pass admission. The private worker name is derived from its
  certified owner; `no_route_plan` checks that neither book nor existing workers
  owns that name. The initial registry is empty and the route permission gate
  encloses construction. Synthetic inspection APIs can supply internal values;
  these are not a source-language authority path.
- Existing plain/nondependent schemas are unchanged. `nob_arg_word` requires
  the expected exact nominal type, an `OA` containing a runtime `Var`, and
  `nob_live_root` ancestry under some matching caller entry root. Root order may
  differ and read-only aliases may coincide. Applied types cannot gain authority
  from the current name-only representation. Full arity is enforced by the
  simultaneous parameter/actual traversal.
- `noa_borrow_call` assigns a fresh `OUnique` scalar observation. Results remain
  full `Term`, including Nat. Residual calls preserve the continuation and its
  errors. The emitter validates registry membership, shape, arity, bound atoms
  and fresh result binding before emitting a direct private borrowed-worker call
  with its `NC_Code` dependency and success/error checks.
- Owned adapters remain responsible for final root cleanup. The original owning
  worker remains behind the unique-root fallback. The pending list receives only
  helper-effect/cycle/depth refusals, is processed once, and already certified
  owners are skipped. Remaining source-order misses retain the ordinary route;
  the retry does not promise to admit every acyclic call graph. Existing self-loop
  cursor/tail-result rules and the lazy `noa_below` fix remain intact.

The existing receipt establishes 15 finite predicate cases and 11 complete native
program executions, covering five paired emission groups plus the raw marker
control. It checks wrong types, missing ancestry, virtual roots, arity and missing
certificate refusal, and exercises retained aliases and ordinary escape fallback.
The API tests use authenticated checked permission; they are not a deployed
candidate compiler image, full B2 qualification or nine-provider integration test.

The [exact C-span record](borrowed-calls-review02.json) independently binds six
selected bodies. `p98_string_eq`'s borrowed worker calls borrowed `p98_eq_walk`
and borrowed `p98_eq_finish` without root retains/releases. Its owning adapter
releases both saved roots after the final observation, while its ordinary worker
retains the prior keep/call path behind the shared-root redirect. The alias worker
passes the same root twice without manufacturing owned references. The tail-read
worker uses `term_peek` and passes the descendant to borrowed equality. These are
actual emitted mechanisms, not inference from helper names or passing output.

The [three prepared argument-list contracts](borrowed-args-laws01/manifest.json)
extract the actual `nob_words_cons` plus its exact KTerm/tag/helper closure from
this candidate using the existing Phase98 extractor. They constrain prepend
order and rejection propagation. All are unexecuted at preparation time; root
receipts are authoritative for subsequent outcomes. Mutants remove the head
guard, remove the tail guard, or append in reverse order. Each must admit alone
before the unchanged laws reject it. Removing the tail guard still preserves an
`Absent` tag through `k_with_children`; that mutant violates the complete failure
value contract rather than independently admitting a call. The emitter supplies
another validation boundary, so no mutant is claimed to defeat the whole compiler.

A universal ancestry theorem would require a larger bridge through typed symbolic
values, schemas, entry origins and borrowed execution. The small contracts above
do not substitute for that proof. Complete C/runtime alias and escape controls
provide more immediate value than adding an abstract ancestry model at this stage.
