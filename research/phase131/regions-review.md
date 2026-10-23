# Independent shallow-record borrowing review

The reviewed candidate has **no source-level correctness blocker found** under
its existing checked-source and sequential-runtime contracts. This is a manual
semantic argument and bounded source audit, not a machine-checked proof or a
native qualification. This review ran no compiler, generated program, benchmark,
or new target. Root owns the13 new/17 retained structural controls and actual
native fixture executions; their results are not assumed here.

The candidate changes only `p128bl_node` and adds11 private helpers. A source-only
check confirmed that its first decision contains the complete original decision
expression, modulo whitespace/comments; no inherited runtime-authority declaration
is overridden. The original analyzer, residual verifier, borrowed lowering,
complete-program verification, runtime guard and runtime layout remain in use.

## Why an opaque field cannot become an escaping value

A successfully specialized constructor field is either an already recognized
scalar/simple spine, or an `OA` abstract value whose type name is the fresh
`$p131.borrowed.opaque`. Its origin still identifies the parent, constructor and
field index. `p131rg_symbol_available` refuses the candidate if that name resolves
in the current book. It is never added as a real type, layout or scalar.

The unchanged consumers enforce the following boundaries:

| Attempt | Existing refusal or restriction |
| --- | --- |
| Interpret the field as a scalar or feed a primitive | `noa_scalar` requires `nol_scalar` for its actual abstract type; no opaque ADT exists. `noa_primitive` rejects an absent scalar argument. |
| Match/destructure it | `noa_match_spec` requires the abstract type name to equal the constructor specification's owner. No specification has the opaque owner. |
| Pass it to an already qualified borrowed reader | `p128br_arguments` requires the helper parameter's actual type name and a held origin. Held origin alone does not grant access. |
| Inline an arbitrary helper | The helper is analyzed in the same context; it cannot regain the discarded type. Foreign/native effects, helper cycles and depth overflow are refused. Passing an unused opaque value through a pure ignored parameter can be accepted; that does not read or retain it. |
| Turn it into a recursive root | `noa_loop_valid` requires an `OA` of the same root type, descended from that corresponding original root, plus a strict descent somewhere. The opaque name cannot satisfy the real root type. |
| Return it from the borrowed function | `p128bl_finish` supplies a scalar-result wrapper. `noa_finish_value` checks the exact scalar result type and scalar extraction; `p128br_eligible` separately requires that scalar wrapper. |

Virtual constructors and locally inlined lambdas may carry opaque abstract
values during analysis. That is permitted only while the eventual operation
still satisfies these gates. This is why saying “opaque values never move” would
be too strong; the relevant property is that they cannot be interpreted, passed
to an owning runtime operation, or become an observable borrowed result. This
argument depends on the independently checked source and existing NO analysis;
it does not authorize arbitrary hand-built internal terms or unsafe API callers.

## Lifetime, aliasing and recursion

`p118b_match` tests the exact constructor identity before `p118b_reads` calls
`p118_rt_borrow_fields`. The latter checks constructor ID, declared field count
and representation, then uses `term_peek` and copies field **words** to scratch.
It neither takes the parent nor retains/drops those children. Immediate loads
copy scratch words into locals before subsequent matches/helper calls can reuse
scratch. The parent root remains owned across the whole reader invocation.

The scalar owning adapter still calls `p118_rt_borrow_scalar_safe`: nontrivial
roots require an external shared reference, and two adapter-owned references to
the same RFC cell are refused. On acceptance it invokes the reader first and
drops the adapter-owned roots afterward. On refusal it calls the complete
original owning worker with unchanged arguments. A shared parent consequently
keeps even unread opaque descendants alive during the observation; allowing
additional unread fields does not require child keeps or early destruction.
Parent/child and shared-descendant relationships do not introduce a new lifetime
rule: the same held ancestor and unchanged shared-root guard are required.

Qualified helper calls use their **reader**, not their owning adapter. Their
arguments must descend from a caller-held root, and their result must be scalar.
Self-recursion remains a tail observation with the same per-root descendant/type
checks. A continuation that modifies or discards a recursive result is refused
by `noa_recur_done`. Existing loop depth/analysis fuel and graph budgets remain.

The new shallow view does **not** generally enable traversal through recursive
record fields: fields lacking an old scalar/simple-spine view become opaque.
Recursion through a visible existing spine, such as String, keeps its original
rules. No concurrency, shared mutation or GPU lifetime claim follows from this
sequential borrowing argument.

## Layout and identity constraints

`p131rg_node` requires a plain, non-native ADT, no parameters/removals, a valid
owner and at least one constructor. Each constructor is specialized with the
unchanged `nol_ctor_fields`: a live telescope, no unsupported dependent field,
no indexed result, exact owner/result arguments, and at most8 fields. The new
check additionally equates field-list length with declared live arity. Only
width0 or2–8 is accepted. Width1 remains refused; this avoids extending the
existing packed-unary layout contract.

Width0 uses `Nullary`; width2–8 uses `Boxed`. Each new view has at most8
constructors. The later `no_emit_match_found` checks the layout, binder count,
bound argument and fresh field binders. `p118b_project_borrow` binds the eventual
runtime call to an actual declared constructor with that exact2–8 arity; the
runtime repeats the shape check. A successful synthetic width predicate alone
therefore does not establish a valid complete constructor descriptor.

Constructor keys use the original `nc_ctor_identity`, not field/type display
names. Non-native names are encoded by their complete Unicode codepoints with
separators; native identities keep the original special handling. This avoids a
new short-name collision or a user constructor being mistaken for a native
scalar constructor. The sentinel collision guard is separate from constructor
identity. Final generated-symbol collision and complete-program gates remain
unchanged.

## Safe refusals and remaining evidence gaps

There are two concrete **coverage limits**, not discovered unsoundnesses:

1. Shallow fallback is attempted only when the immediate old `p128bl_node`
   returns an error. If an old two-constructor spine node succeeds and a later
   `p128bl_graph` child fails—such as incompatible parameterizations of a nested
   List—the shallow view is not retried. Do not claim this covers every record
   with otherwise unread heterogeneous children.
2. Visibility uses `nol_scalar` or the old `nol_root_specs`, not recursive
   shallow-view discovery. Nested arbitrary records, most parameterized fields
   and opaque recursive children remain inaccessible. This intentionally limits
   power and keeps the new proof obligation small.

The13 structural controls check width predicates, sentinel collision and five
opaque-consumer boundaries. They do not by themselves establish all of the
following end-to-end conditions:

- Exact constructor descriptors at widths0/2/8, rejection of1/9, and constructor
  counts8/9; malformed/indexed/dependent or native owner fallback.
- A namespace/collision fixture passing through actual checked loading and
  generated constructor IDs, rather than only a synthetic book lookup.
- Shared same-root aliases, parent/child aliases and unique-root fallback using
  the actual adapter/runtime. The guard implementation is inherited, but a
  newly admitted record must reach it through the intended generated adapter.
- A borrowed helper called with a visible child while opaque siblings remain
  live, followed by independent observations of the original owner/children.
- Actual fallback for opaque matching and opaque result escape, plus a successful
  ordinary unrelated record query. The supplied workload includes both opaque
  fallback operations, KTerm width8 and a separate three-constructor record;
  its source alone is not an execution result.

These are finite control obligations or claim limits, not reasons to add a new
IR or weaken fallback. Preserve failed/refused attempts. Before native promotion,
retain full independent outputs and qualify the actual final images. A changed
emitter product must use the explicit extra native generation when Q1/Q2 differs;
source-level opacity review cannot substitute for Q2/Q3 reproduction.

## Exact reviewed inputs

| Input | Bytes | SHA-256 |
| --- | ---: | --- |
| Phase130 `mode-source01/compiler.bend` |2613588|`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`|
| Phase131 `regions/shallow.bend` |3817|`5df530756c280f5311b8320c4a910602d24f7a8def506db2d7efe418063c1852`|
| Phase131 `regions/controls-v02.bend` |2236|`aab77a235fcc7ed51ab91b1171a4cad6d8f01b118a0c65c5da5bc4c92b17ef74`|
| Phase131 `regions/workload.bend` |3945|`b9cfca7f89b2d4f370ceb35f6751acf7f3b335550dda1185a89afb354335bcdd`|
| Phase128 `runtime-borrow01/runtime.c` |149279|`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`|

All compiler declarations cited above were read from the pinned full Phase130
source, including `nol_*`, `noa_*`, `p128bl_*`, `p128br_*`, `p128bs_*`,
`p118b_*`, `nc_ctor_identity` and the final verifier connections. The source-only
comparison checked the sole override and unchanged original decision expression;
it did not execute those declarations or establish a formal ownership theorem.
