# Phase43 exact String components

P43-001 tests one entry guard for the complete benchmark lexer graph, including
String production, materialized classification/mode/tuple values, lexing and
balanced batch. Phase42 lexer remains ~90.81× TypeScript and sampled allocation
56.52×; the earlier Phase40 lexical-consumer-only translation improved ~2× but
left the expensive generator generic. Expect >=2× over checked16 for the full
component; a <1.5× small-point screen or any semantic/activation mismatch rejects
source integration. No result has been measured at design time.

The saved-JS generator accepts checked16 emitted bytes, writes clean and
instrumented original/noise/guard/class/step/complete/full roles, and records
input, tool and worker identities. Original/noise modules are identical to each
other, with the same appended inactive workers and exact entry wrapper. Complete
retains generic generation; full translates every user definition on the ordinary
bench path. Timings use default.bench, not a diagnostic-only entry.

The wrapper consumes existing exactCode entry permission. Public saturated calls
may admit only canonical U32 depth/seed after captured descriptor guards; direct
code calls retain the original body. It reads source arguments once in original
order; fallback reuses those already-read values. Partial application stays on
the generic runtime until saturation. Public G functions other than bench remain
generic and diagnostic direct-call adapters are explicitly not compiler proofs.

Full workers retain tagged Slot, Cls and Mode plus fresh native Tuple arrays.
Native String stays a complete JS string. gen evaluates head/projection/salt then
recurses on the tail before expansion; the loop saves those already-computed
values and reconstructs inner to outer. ident/num compute PRNG and Chr before
recursive descent, then SCon reconstruction. No token fusion or skipped Cls is
admitted. Batch saves proper-child phases with BigInt Nat and existing >=32n
U32-shift semantics. String slicing/cursor behavior remains the exact runtime
project(SCon)/project(Chr) behavior, including astral and lone-surrogate handling.

Guard scope includes original entire function/code/bound descriptors for all 25
source dependencies; String global descriptor, constructor/static/prototype own
keys/descriptors/prototypes; existing regionHostGuard and scalarGuard. No proof
is opened or cached across calls. Mutable post-import hooks, getters, marker
properties, dependency changes and reentry refuse. Standard host initialization
is the existing documented premise. Error constructor reentry sees the active
scope and cannot acquire the operation.

## Source implementation proposal

Use an exact ABI proof j_pure_closed_char/string separate from j_primitive_type;
the latter's default branch checks U32 and must not be reused for String names.
Verify canonical ADT owner (native, zero parameters/erased arguments, grounded
Data kind), exact constructor set and native identities/arity/quantities: Chr
quantity1 U32 -> Char; SNil String; SCon quantity1 Char -> quantity1 String ->
String. A shadow owner, changed field quantity, parameterized native name,
foreign definition or changed constructor refuses. Shared fuel exhaustion fails.

Extend j_pure_type_head and literal checks through those predicates only, plus
j_pure_same_closed's closed owner identity. Existing independent closed Sigma
proof already admits Mode & U32; do not duplicate or weaken it. Native ctor
lowering must keep Chr's checkedChar and SCon's fromCodePoint semantics: plain
number concatenation is wrong, and copying malformed surrogate code points
without checkedChar is wrong. Owned tagged Mode/Cls stay current ABI initially.

A nullary literal definition is a separate exact gate: nonnative original Def,
arity0, erased0, body j_strip(Lit), grounded exact admitted result, bounded body.
Extend j_pure_call for a zero-argument spine only through that gate; j_pure_graph
then checks the full literal body. Extend capture to original literal wrappers
only, with arity0 accepted in runtime snapshots. Do not grant arbitrary nullary
helpers or effectful get(G,...) evaluation ownership. tpl uses a literal String
body, so its exact native-result proof must travel with the plan.

Bool.and must be audited in the actual book: checked16 emits a source matcher
for it, so a blanket native whitelist edit is not sufficient evidence. If the
canonical book marks it native, require the exact closed two-Bool telescope and
capture its original wrapper as existing Bool.xor does. The direct graph retains
source argument order and short-circuit result semantics.

Every observer-consuming entry of newly admitted String/Char plans must invoke
stringHostGuard before localGuard/region proof opening, and before uncaptured
Number/global host operations. Do not only add the guard in one scalar-root
emitter: finite/direct/global/component emitters also consume JPure predicates.
Keep String internal to scalar-owned graphs initially; public String/Char input,
returned native values and arbitrary record/callback parameters need separate
entry and escape proofs. Complete graph lowering must actually clone gen, ident,
num, expand, slot, tpl, op, lex, step, flush and batch edges, with structural
continuation lowering for gen's tail-first reconstruction. Existing JResidual
purity alone still calls generic workers, so widening purity alone cannot deliver
this experiment's full gain.

A reusable JDirectPlan should be request-local JSPlanContext metadata containing
exact original identities, typed ordered callee strategies, value-layout rows,
host-family obligations, saturation/escape flags, structural resume plan and
valid/fuel. It must not grant ambient ownership. Region entry opens existing
proof only after all plan obligations pass; records and callbacks can later add
strategies without inventing a second ownership mechanism.


The checked Bool.and body is now pinned structurally by bool-and-v3.patch rather
than admitted from name/signature alone. Its False arm returns False, True arm
returns the exact second argument binder, final arm is Efq; quantities, child
counts and empty removed lists are exact. Private && evaluates both source
arguments left to right before invocation and preserves the public source matcher.
type-controls-fast-v6.mjs adds canonical positive and eight altered-body/native
refusals. git apply --check succeeds against current production; Node24 syntax
checks pass for the controls. Parent/reviewer integration still pending.

Baseline fixture preparation found affine seed reuse in the branch roots before
emission. Original source files remain frozen. New *-v2.bend files explicitly use
+seed where both recursive branches consume it; fixture-catalog-v3.json pins these
new identities with unchanged independent expected values. Preparation/catalog
failures are not correctness passes or performance results.


Actual source checked08 qualifies complete ordinary lexer activation and full
materialized value/observer/alias/error/demand controls. Two short paired screens
show10.911–12.658× checked16 gain, leaving7.003–7.392× TypeScript; the saved-JS
prototype's roughly5× TS gap is separate. The remaining repeated resume-only
PRNG/projection work motivates a typed continuation layout with explicit live
postchild binders/fields. This extends the shared plan idea without introducing
new ambient ownership or changing public ABI. Final mandatory-owner integration
and installation remain parent-owned.
