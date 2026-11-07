# Phase173: effects and the owned-decomposition equation

Status: independent source audit, not a new proof or a performance result.
Read against HEAD `5a6baaa00895b1a6be054e0715245f44aad99883` plus the current
experimental `owned-decomposition*.bend` files. No targets were run by this
reviewer. The separate provider audit is
[owned-decomposition-review2.md](owned-decomposition-review2.md).

## Conclusion

The transformation does **not** need the worker to be pure. It needs the
getter/setter to be total structural operations, the worker evaluation to stay
in place, and the execution environment not to observe the changed ownership
representation. These are different requirements.

For the selected, checked direct-QBE path, the existing authenticated fixed
provider ABI supplies the last boundary. Removing the experimental
whole-request no-foreign restriction is therefore defensible within that path,
while keeping its existing provider admission, ordinary-Data summary checks,
ownership lowering and final verifiers. This is a source-grounded semantic
argument, **not** a BendTT-checked compiler theorem or a substitute for the
planned effect/alias controls.

Do not interpret this as permission to apply the transform to arbitrary foreign
C or arbitrary forged internal compiler inputs. The hook is an internal
`p112s_prepare` replacement; it does not itself authenticate a runtime or book.
Its callers must establish the existing checked-QBE preconditions. Reuse by a
different backend requires that backend's corresponding provider contract.

## The equation, including an effectful worker

For an admitted constructor row, write the original value as `C(x1,...,xn)`.
The checked getter summary supplies `g(x)`, which is one projected field or a
closed constructor/word value. The setter summary supplies
`C(h1(x,y),...,hn(x,y))`, where each field is its original positional field,
except for at most one occurrence of replacement `y`. A rewritten row must
actually contain that replacement.

For already evaluated extra arguments `a`, the equation is:

```text
setter(C(x), F(getter(C(x)), a))
    ≈ let y = F(g(x), a)
      C(h1(x,y), ..., hn(x,y))
```

Here `let` is strict and `≈` observes language values, defined errors and effect
traces, not heap addresses, reference counts or allocator traffic. In a trace
semantics, if

```text
F(g(x), a), state ──trace──▶ y, state'
```

then both sides run that same worker computation and return the same constructor
fields in `state'`, with that trace. No commutation of two effects is needed:
only total, nonobservable structural helper work moves across the boundary.
The worker can perform effects, return normally, fail, or diverge.

This is a contextual law, not a law requiring `F`'s source to be visible or
transitively effect-free. Current syntactic admission nevertheless requires a
known saturated ordinary worker, and that conservative restriction remains.

## Case analysis and implementation correspondence

| Case | Why behavior is preserved; remaining qualification boundary |
| --- | --- |
| Reconstructing row, worker returns | The same getter value and atomic extra arguments reach `F` exactly once. A strict binding precedes the same constructor and unchanged positional fields. |
| Worker raises a defined error | Reconstruction occurs only after the worker returns, so neither side returns a constructor. Keep existing error propagation; an optimization must not turn the strict binding into dead-code removal. |
| Worker diverges or loops | Both enter the same worker after finite structural work, and neither reaches reconstruction. A smaller live heap is intended, not a new termination claim. |
| Setter ignores its replacement | The automatic transform does **not** simplify this case. Its fallback retains the whole original expression, including `F(default, a)` when the getter produces a constant. This avoids the incorrect shortcut of dropping an ignored computation. |
| Constructor not rewritten | The fresh-root fallback is an alpha-renamed copy of the original expression. Unknown/unsupported rows retain the old getter, worker and setter. |
| Root expression has effects | Refused: the root must be the same already evaluated variable at getter and setter. There is no duplicated or reordered root-producing call. |
| Extra argument is effectful | Refused: extra arguments are variables, native words or static values. The pass does not move arbitrary argument evaluation through a match. |
| Same root ID appears in extra arguments | Refused by the current syntax gate. This is conservative admission, not a proof that all aliases have disappeared. |
| Another variable aliases the root | Allowed under ordinary ownership. It remains live as an extra argument or outer-context value. Matching releases only the transformed occurrence; normal sharing/take rules preserve every other occurrence. No uniqueness assumption is made. |
| A child is shared outside the root | Its external occurrence remains live. Moving the parent match may change ownership counts and copy-on-write decisions, but cannot grant permission to overwrite a live alias. |
| Worker returns or reconstructs an alias | Returned values remain subject to ordinary ownership. Physical identity may differ; defined value observations must agree. |
| Worker mutates an owned Array reachable through a field | Ordinary Array/ownership semantics must preserve aliases, as in the unchanged compiler. The pass must not introduce a private mutation/unique-parent path. Its summary excludes Array as the matched root. |
| Root live after the whole expression | Liveness is recomputed after transformation. The later occurrence keeps the old value alive; the pass does not assume its root was unique. |

In `owned-decomposition.bend`, `p173oa_row_body` constructs the strict worker
binding with `nc_mklet`, then `p173oa_result_fields` reconstructs the row.
`p173oa_row_changed` skips rows without replacement. `p173oa_summary_result`
builds the original-expression fallback with fresh IDs, and
`p173oa_application`/`p173oa_call` enforce the root/argument restrictions.
All field and fallback-root binders have quantity 2; shared fields are not
silently declared affine.

The strict binding is real in the existing lowering paths:

- `selfhost/src/back/native/bridge.bend:nc_mklet` constructs a quantity-1 Bind.
  `nc_lets` lowers its value before the body; `nc_let_cut` schedules the body as
  the continuation of that value. The native local-value route similarly
  emits the value code before continuing.
- `selfhost/src/back/qbe/flat-products.bend:p113pl_bind_flat` and
  `p113pl_bind_boxed` lower the value first, then join the body, preserving the
  necessary live references. Existing final verification is retained.

This is evidence about the selected implementation, not a new formal semantics
for every optimization that may later consume the transformed body.

## The actual foreign boundary

`selfhost/src/back/native/effect-admission.bend` already distinguishes provider
permission from purity. Its comment requires that allowed providers do not
expose or mutate immutable-root identity. `no_effect_foreign_allowed` permits
authenticated IO/File providers, and `no_effect_terms` rejects rewrites; neither
function proves a worker pure.

`docs/self_hosted/NATIVE_OBSERVERS.md` explains the checked source/layout/runtime
preconditions and explicitly says a forged internal permission flag is not
authentication. Its provider examples are older and narrower than the current
native source catalogue.

The **selected QBE route** has its own broader fixed runtime provider admission:

```text
p134e_plan
  → p128raw_emit_admitted(request, p111_runtime_admission(request))
  → prepared lowering
```

See `selfhost/src/back/qbe/stream-emission.bend`, `prepared-context.bend`, and
`lower.bend:p111_runtime_names`/`p111_runtime_admission`. The actual provider set
also includes byte-file and NativeHost operations. Consequently adding the
older `no_effect_definitions` whitelist would conservatively reject some already
authenticated QBE requests; it is not necessary just to avoid a purity analysis.

The separate review traces those providers through the selected runtime. Do not
infer representation independence from a provider's name or result type alone:
arbitrary foreign C receives runtime state and can inspect representation and
reference counts. That is a concrete reason to retain the fixed authenticated
provider boundary.

Earlier reclamation changes allocation/refcount timing. The audited runtime
does not attach user finalizers to the matched ordinary Data objects. Timing,
allocator counters, out-of-memory limits and OS scheduling are not exact-output
equivalence oracles for optimizing execution. In particular, an `IO.now` value
can change whenever code becomes faster; the obligation is preserving the
clock operation's order/count, not identical wall-clock samples.

## Why a new per-worker purity framework is the wrong first step

A reachability scan over named references is insufficient: a foreign-free
helper can invoke a callback parameter. `f_choose` in the real substitution
computation is already a higher-order example. A genuine reusable
`NoForeignInvocation` summary would need direct foreign use, named dependencies
and invoked callable-parameter obligations, instantiated at calls. Unknown
callable origins, function-valued fields or unsupported partial applications
would refuse. Recursive SCCs must have all bodies inspected before publishing
any member as safe; bounded-analysis exhaustion must return unknown.

The JS backend's `j_pure_graph`/`j_pure_call` in
`selfhost/src/back/js/jpure.bend` are stricter existing analyses, but recheck
types and reject unknown call heads. They are not a current reusable QBE fact,
and their adequacy/cost for this higher-order compiler workload is unmeasured.

Neither mechanism is needed to justify the equation above under the existing
admitted QBE runtime. Building one now would solve a stronger and more expensive
problem than this transformation requires.

## Minimal next controls

Keep the existing structural, full-value, ownership and final-verifier controls.
Before extending experimental request scope, add a small authenticated-IO
request containing the same pure rebuilding computation plus an effect trace,
and verify the full trace and result against the unchanged compiler. Include:

1. A changed constructor, an ignored-replacement constructor, and an outer root
   alias, with ordered markers around the computation.
2. A worker error or an independently bounded nonreturning worker: it must not
   expose a reconstructed result or bypass the worker. This is a correctness
   control, not a timing benchmark.
3. An unknown/custom foreign provider: the **existing outer QBE admission** must
   still refuse it. The optimization must not manufacture runtime permission.

Some IO effects are represented as IO values rather than performed by ordinary
Data-returning workers. Preserve that distinction when writing the fixture;
do not claim an effectful worker was tested if the effects merely surrounded a
pure computation. The algebraic argument covers the broader effect-order case,
while actual fixtures must report the language behavior they exercise.

If these bounded gates pass, scope extension removes an unnecessary global
barrier to testing the real compiler CLI. It does not establish that the CLI
will run faster; actual hit coverage, transformed code and complete build cost
still have to be measured.

## Minimal IO fixture and exact oracle

`selfhost/tests/phase173/owned-decomposition-io.bend` is the 50-line fixture;
the adjacent `.stdout` file is a literal, independently derived expected trace.
It has two deliberately distinguished paths:

- `p173io_change` has the intended syntactic composition. It
  updates a String field while retaining the original root, a second field
  aliasing that String, and an external alias to that same String. The original
  root and aliases are printed after the updated value. Vacant tests the exact
  original-expression fallback.
- `p173io_effect` uses a genuine Base `IO(String)` worker that prints `F:` and
  then returns the replacement through IO bind. The Vacant setter ignores that
  replacement, but the trace must still include `F:`. This is an effect-order
  reference path, **not** the direct `setter(root,F(getter(root)))` pattern: the
  current pass should leave its IO bind boundary alone.

The distinction is necessary. Base `IO(A)` is a CPS computation of kind Type;
supported foreign definitions must return Base IO directly. Pretending that
`IO.print` can run inside an ordinary Data-returning worker would require an
effect escape absent from this test's source contract. No forged foreign
provider is introduced merely to obtain that syntax.

The oracle is simple concatenation and positional reconstruction: updating
`row(seed,seed)` yields `row(seed!,seed)`; the retained root and child still
contain `seed`; both Vacant results retain tag 7. The second worker prints the
empty getter value before the ignored result is discarded. Exactly ten lines,
each terminated by a newline, are expected. Source checking and native/independent
execution are left to the coordinating agent's single execution lane.

Subsequent root-owned evidence refined its scope: the unchanged IO trace passes,
and all32 structural/permission controls pass, but
`owned-decomposition-qbe-observe07/report.json` records **zero transformed rows**
for this particular String fixture. Source inspection identifies a sufficient
refusal: the ignored variant's getter returns literal `""`; `nc_erase` preserves
literal nodes, while the getter summary admits only field variables, constructor
constants and native words. This must not be reported as a positive transformed
IO test. A separately acquired Packet-with-IO fixture uses its already admitted
getters; `owned-packet-io-observe07/report.json` records one actual changed row in
`p173odw_change`, with the corresponding root-owned native pair receipt.

## Rejected stronger IO fixture: Church elimination is not effect execution

A later proposal tried to obtain a genuinely printing Data-returning worker by
fully applying `IO.print(text, U32, unit => Emit{value})`, then matching its
`IO.OP<U32>` result to extract the emitted word. This may be a well-typed term,
but the proposed successful print-and-return behavior is **not** its operational
meaning.

`bend2/comp.ts:1146` explicitly preserves the default branch of an `IO.OP`
match because a foreign request is neither Emit nor Halt and must fail-stop.
`mat_ctrs` implements that special boundary. The C event loop invokes registered
effect handlers only in `io_step` (around line 5854), and the JS equivalent is
`io_run` (around line 6322). Applying the foreign IO term constructs the request;
it does not run its handler before the enclosing ordinary matcher.

Consequently `p173oe_extract` in the proposed
`owned-decomposition-qbe-v3-io.bend` cannot be a positive print/return oracle.
No execution was needed to identify this obstruction. Preserve the proposal as
a rejected hypothesis or negative boundary control, not an optimization success.
An independent source check alone would not establish the intended behavior.
The ordinary IO-bind fixture above remains the honest positive request-scope
control.

## v3 entry and permission-control audit

The separate v3 experiment overrides `p168_catalogued`, preserving the original
`p112s_prepare` exactly once. Both selected public callers, `p169np_plan` and
`p169s_plan`, call `p111_runtime_admission` before `p168_request_mode` reaches
that hook. The existing `p167ob_permission` source check also remains in place.
No runtime-admission check is repeated inside the optimization hook.

The experiment deliberately retains an extra, conservative observer-effect
certificate. It uses the existing stack-safe
`p118ns_effect_definitions(True{}, book, names)`. Inspection shows its
per-definition predicate is the same as `no_effect_definitions`: native
primitive priority, authenticated filled provider membership, otherwise an
ordinary definition without Rwt. This certificate is not purity and does not
independently authenticate forged inputs. NativeHost and byte-file providers
remain refused even though the outer fixed QBE runtime supports them.

`owned-decomposition-qbe-v3-controls.bend` adds sixteen finite predicate controls:
ordinary/empty cases; IO and File positives; missing, rewrite, unknown,
untrusted and unfilled negatives; the narrower NativeHost/byte-file scope;
annotated foreign recognition; unreachable-provider exclusion; and a check
that a prepared-book replacement cannot hide an unknown foreign provider still
present in the source catalogue. These fabricated values test predicates, not
checked-program authenticity. Their execution is left to the root agent.

This extra full-name/body traversal is an explicit experiment cost. It should
not be represented as free merely because it reuses existing code. If the
candidate is later integrated, the established checked-QBE contract may justify
removing this redundant restriction or reusing an already established
certificate; that is a separate measured decision.
