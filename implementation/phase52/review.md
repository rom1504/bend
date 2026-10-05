# Phase52 independent architecture and correctness review

This is a static review checkpoint, not executed qualification. Root owns target
execution and integration. The direct backend must be explicitly selected;
legacy remains the default and retains its existing runtime and public contract.

The direct contract should follow the pinned upstream JavaScript backend, not
inherit the legacy descriptor ABI. The reference is
`selfhost/.bootstrap/upstream-phase23/bend2/comp.ts`, SHA-256
`3bd7ed49d33f1c61334d75a905e38c0345fb15a10b45d85884b77f49833dc5ee`.
Mutable `G` descriptors, legacy forcing markers and shared legacy float-view
writes are not automatically obligations of this separate ABI. Ordinary source
effects, upstream host marshalling and observable argument demand still are.

## First architectural checks

- Keep runtime values and calls direct throughout the new backend. Reusing a
  legacy printer is safe only after accounting for every emitted free helper
  name and its representation. A small primitive expression can still depend on
  `checkedNat`, `bitsFloat`, `word`, `ctor`, `get`, `callOwned` or descriptor-valued
  callbacks. An unsupported node must fail explicitly rather than emit a mixed
  calling convention or silently select legacy code inside a direct module.
- Follow upstream `fun_of`, `term_spine` and `js_func` when selecting live arity.
  Upstream consumes declared arguments through matchers and later lambdas; the
  legacy leading-lambda arity is not the direct ABI specification. Erased
  arguments and fields disappear consistently from calls, functions, partial
  prefixes and constructors, without evaluating their source expressions.
- Emit effects once and in source order before reusing arguments in intrinsic
  templates. Tiny native wrappers whose templates read evaluated local parameters
  are a sound initial implementation. Tail transfers must capture all new values
  before replacing parameters, and introduce fresh lexical bindings each turn
  so an escaping closure keeps its original captures.
- A conservative trampoline must recognize its private messages without adding
  observations on ordinary host values. Reusing `run_loop` indiscriminately
  adds an object `.$` read where upstream can omit forcing. It is also a
  measurable cost: do not attribute direct-backend speed to eliminating dispatch
  if every call still constructs a bounce or argument vector.
- Native/foreign recognition needs declaration provenance and typed arity,
  rather than names alone. Preserve source-qualified constructor tags and protect
  the `__proto__` field spelling. Separate imported-effect registration and
  marshalling from ordinary pure native calls.

## Cheap distinguishing cases

| Case | Required observation |
| --- | --- |
| Erased throwing argument/field | No evaluation; following live arguments keep their order and position. |
| Matcher then returned lambda | Match selection, partial application and captured fields agree with upstream; no legacy descriptor requirement is imposed. |
| Partial factory reused after another factory call | The first closure retains its own prefix and lexical captures. |
| Parallel let and permuted tail arguments | All right-hand sides see the old scope; a loop does not overwrite a value needed by another argument. |
| Constructor with effectful/throwing fields | Each live field is evaluated once, left to right; later fields are not evaluated after a throw. |
| Computed nullary source reference twice | Both demands execute; source evaluation is not moved to import or memoized accidentally. |
| Same-named nonnative primitive/constructor | Its source body/layout is honored; no name-only intrinsic substitution. |
| Imported Nat outside canonical range | Match and arithmetic demand agree with actual upstream conversion behavior, rather than an invented eager boundary check. |
| Mutable array containing Nat through a host call | Input conversion, result conversion, input restoration and exceptions occur in upstream order, with the required alias behavior. |
| Deep tail cycle and constructor-producing recursion | Stack behavior and returned structure are checked separately; a tail-only loop does not establish safety for non-tail construction. |

The Nat distinction needs particular care. Pinned `nat_host` accepts an integer
Number or BigInt from zero through `2**53`, converts it to Number, and otherwise
returns an object whose `Symbol.toPrimitive` throws. Failure is therefore
demand-dependent. The negative-Nat fixture's descriptive comments are not proof
that the current backend retains raw BigInt internally: a matcher can select
the successor arm without demanding an unused predecessor. Pinned `js_host`
marshals live inputs, calls and forces the result, marshals that result, then
performs output-direction conversion of inputs. This ordering is part of the
host contract; it is not interchangeable with legacy scalar-entry validation.

## Measurement and release boundary

Compare the same public export, arguments, complete result and amount of work
against pinned upstream. Publish the new direct contract next to each comparison;
do not call it parity with the legacy mutable-descriptor ABI. Preserve negative
results and unsupported cases. Prototype coverage, complete checked-source
coverage, host compatibility, stack behavior and release qualification are
separate claims. Default-mode output must remain bound to the installed legacy
baseline until root explicitly selects a different release policy.

## First implementation audit

The following findings came from reading the initial direct core, constructor,
pattern, primitive, runtime and host modules. They are static counterexamples;
this reviewer ran no compiler or generated program.

- The initial named `jd_tail` inspected `f.j`. Unlike upstream `run_tail`, it is
  used for known lexical functions, so a `Function.prototype.j` getter added a
  new observation. The runtime owner removed that lookup. The separate upstream
  closure-tail protocol retains its original lookup.
- Initial match lowering eagerly bound every field expression. Pinned
  `js_func` (lines 3184–3190) suppresses unused computed views and substitutes
  its `VIEW` categories at each use. A deferred invalid Nat must not be coerced
  by an unused predecessor; ignored record getters must remain unread. Repeated
  Char views require the upstream `codePointAt` demand count, not an unconditional
  single binding. The core successor uses exact emitted-Var markers and VIEW
  aliases; static review of that correction passed.
- Initial `jd_let_values` evaluated every non-erased right-hand side. Pinned
  `js_open` (lines 3101–3104) uses `let_live` (732–735) and does not emit an unused
  reusable binding. An unused Nat overflow distinguishes the two paths. The
  core successor omits unused bindings and retains left-to-right evaluation of
  those used. Its nested dead-binding behavior matches upstream `term_kids`.
- Initial unconditional `jd_run` around named non-tail calls inspects `.$` on
  returned objects. Upstream selectively omits forcing for non-bouncing callees.
  A public identity helper over a record with a `$` getter or Proxy distinguishes
  the paths. Named bounces also spread a new private argument array, adding an
  iterator lookup absent from upstream named calls or tail-SCC loops. Ordinary
  scalar output alone cannot qualify these boundaries. The shared call-facts
  successor removes forcing on acyclic non-bouncing calls. The subsequent SCC
  emitter replaces mutual named bounces with positional loop transitions.
- Compact F32 literals initially called `f32_from_bits` at runtime, although
  upstream folds those bits during compilation. Valid constant Char constructors
  likewise have an upstream literal path. The pattern owner is preparing constant
  and Word lowering; runtime typed-array or `String.fromCodePoint` observations
  must not be added to source literals that upstream has already folded.

Host-specific fixes were reviewed: budget exhaustion now carries the driver's
recognized unsupported marker rather than accepting a delayed surprise, unknown
type-graph status remains distinct from absence of Nat, and malformed constructor
tags throw the pinned string message. Telescope advancement uses the upstream
dummy-substitution policy. This does not qualify the separately pending core
call integration or replace execution of the corrected demand controls.

The acquisition harness explicitly binds the direct runtime path, requires it
among checked emission inputs, compares its exact emitted prefix and rehashes it.
The semantic acquisition queue retains all emission failures and labels its
result as checked emission only. Neither successful acquisition nor this static
review constitutes execution of the semantic controls.

The next static checkpoint also corrected three narrower integration issues.
Projected Word views (`u32_to_word(...)["tail"]`) must be held once when used,
although upstream substitutes bare Word views per use; otherwise returning a
residual Word twice loses shared identity. Arity inference must retain a negative
residual through nested matcher arms, since a later constructor can add fields;
clamping at zero changes the number of raised formals. Finally, a partially
applied source call whose remaining formals are all erased creates no runtime
closure: call facts, forcing context and self-tail handling now treat that as an
actual call. Those corrections received static approval before execution.

The SCC successor received a separate static approval: bidirectional reachability
provides identical ordered members and program counters for every entry; maximum
live parameter width covers every transfer; all argument temporaries precede
slot and counter updates; and each case opens fresh lexical source bindings.
Closure and expression contexts clear the loop owner. Named calls no longer emit
`jd_tail`, while reachable unknown closure tails still propagate forcing. This
addresses the identified extra named-bounce iterator observation without claiming
that execution controls or the separate foreign-call integration have passed.

The first Word matcher had separate host-effect limitations: it cached one F32
bit conversion across rows and did not cancel all native view round trips.
These could change post-import `Number`, typed-array or `String.fromCodePoint`
observations, independently of the correctly folded compact literals. The
numeric-row successor now replays upstream default coverage and emits F32
conversion at each demanded condition/view. Typed metadata on compiler-generated
bare views supports the corresponding inverse constructors. Static review passed;
the call scanner consumes these exact rows rather than reimplementing pruning.

## Full-stage integration checkpoint

Review of the actual driver exposed a component lookup mismatch: selected
definitions were annotated, but the original context book supplied bodies for
mutual SCC cases. Both library and program entry now overlay the annotated
selected definitions before deriving call facts and looking up member bodies.

The host/program checkpoint received static approval for its public export
predicate, foreign CPS order and packed readback schema. Library exports use the
original whole type when excluding IO, retaining functions whose result is IO.
Foreign wrappers resolve registry `run`/`need` before marshalling ordinary
arguments and then the final live continuation. Readback uses symbolic offsets
and constructor-name indices, rejects erased/dependent fields, and retains the
existing foreign-main rejection. This review does not assert executed IO parity.

Program and foreign output now have a Node `createRequire` prologue. The separate
acquisition-v2 tools accept exactly that optional prologue followed by the pinned
direct runtime; consumed prototype tools remain preserved. A proof-valued `Rfl`
expression was separately flagged as missing from the core emitter despite
readback supporting equality values. The 05 successor adds `Rfl` to the null-valued
proof/type expression branch; static review of this correction passed.
## Emission-based runtime reachability

The 05 successor received static approval for its `JD_REF` reachability pass.
Named calls, partial-call bodies and overapplication heads share the marked call
emitter. Same-component loop transfers emit the same metadata before unchanged
parallel argument captures and stores. Library roots match the host export
predicate; programs root `main`. Export wrappers therefore do not need separate
metadata edges to their already selected roots.

The scanner accepts reserved comments only after a physical newline, and encoded
names cannot contain comment delimiters. Quoted source strings cannot forge those
lines. Unknown marker names and definition, edge or character budget exhaustion
refuse the whole result. The initial annotated context remains available for
checking and code generation; filtering removes only unreachable runtime `Def`
entries. Dead-let and erased-argument demand follow actual emitted code. Foreign
source checks and selection now occur after this direct-only filtering; the
legacy ordering is unchanged. This is a static completeness check, not execution
of the independent dead-foreign initializer witness.

The proposed 26-row direct conformance gate correctly requires both unchanged
fixture judges and all paired semantic observations to pass, while reporting
exact diagnostic agreement separately. Review identified a harness precondition
issue: recursively rehashing snapshot `original` paths also required the mutable
live compiler to remain identical to an older frozen attempt. The owner was
asked to bind consumed frozen identities while retaining original paths as
provenance. The unconsumed correction received static approval: original and
frozen recorded hashes must agree, while only consumed frozen paths are rehashed.
This issue does not constitute a direct-runtime semantic failure.

The 05 native-Nat matcher correction also received static approval. Its shared
rows reproduce pinned `mat_nats`: strict comparisons use the original held
scrutinee, the last arm is unconditional, and predecessor subtraction occurs
only when the selected arm uses that view. This preserves deferred failure for
invalid host Nat values across literal alternatives. Call analysis consumes the
same typed rows and field counts, avoiding a second fallback traversal.
