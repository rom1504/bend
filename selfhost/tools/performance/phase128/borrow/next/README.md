# Composable scalar borrowing: staged extension

These are experimental overlays on the checked Phase128 bounded scalar reader,
not a new backend or a replacement for the original observer analysis. The
coordinating agent owns all compiler checks, execution and immutable receipts.
The implementation agent ran no compiler or target process.

## Stage1: preserve borrowed semantics through a helper boundary

The actual Phase127 name-search census establishes a useful split:
`p88_string_eq_go` already has a valid Bool observer and a leaf owning fallback;
`p88_string_eq` fails because recursively inlining that helper hits the NO
helper-cycle limit. Its recursion is already representable as the verified
private reader's local loop. Repeating that analysis at every caller loses the
existing capability.

Append `context.bend`, `read-calls.bend`, `residual-check.bend`, and
`integration.bend` after the bounded scalar candidate. Replace type `NO_Context`
and these definitions: `noa_book`, `noa_owner`, `noa_schema`, `noa_analyze`,
`noa_reference`, `p118b_eval`, `p118e_permitted`, `p118i_borrow`. Preserve the
existing `p118b_eval` law.

The new context carries summaries derived only from ordinary successful scalar
plans with an available leaf fallback. Those exact readers are emitted with the
ordinary added-worker set and independently verified. The summary's inputs are
the original typed parameters and root mask; its output is the exact scalar
observation type. A caller may pass only scalar atoms or borrowed words whose
origin lies below one of its held owning roots. It calls the private reader,
never an owning adapter. New composite readers are not added to this summary
set, so dependencies are one layer from new reader to seed reader. Source-local
tail recursion remains `P113DAgain`; native recursion is not introduced.

`NO_ReadCall` is a residual value, sequenced using the existing `NO_Let` form.
The old C residual emitter cannot emit it. Its structural projection checks the
actual argument atoms against their environment, substitutes a scalar placeholder
for this one operation, and runs the unchanged `no_emit` checks for layout,
binders, arity and control structure. This is explicitly not a claim that a call
equals zero. The actual lowered call subsequently passes the unchanged complete
direct verifier, including argument/result types and ready dependencies.

The owning fallback may depend on previously verified helpers. Each new
fallback→reader→adapter group replaces its old public worker at that worker's
original position. This preserves prerequisites. The entire projected function
list is independently checked from an empty ready set by `p126bp_complete`.
No signatures are preadmitted for verification. Existing flat-worker closure,
array namespace checks, stack checks and original request verification remain.

Add `diagnostics.bend` for `p128br_diagnose(request, owner)` and
`call-controls.bend` for ten finite provenance/type/atom rejection checks.

## Stage2: a finite concrete type graph

Append `layouts.bend` after Stage1; it overrides only `p128br_plan`. Ordinary
schemas succeed unchanged. A schema refusal may try the extended proof.

`has_name` has `List<&2,String>` and String roots. The old layout rejects both
parameterized roots and nonscalar payload fields. Merely allowing `List` would
be unsafe: NO stores owner/field names, which cannot distinguish List<String>
from List<U32>.

The extended schema proves a finite reachable layout graph before using those
names. Every nominal ADT has exactly one structurally equal instantiated KTerm
within the graph. Conflicting instantiations are rejected. Each accepted spine
has two constructors, one nullary and one with exactly one same-typed recursive
child; other fields recursively require a supported scalar or another proven
spine. Existing constructor specialization checks reject erased, dependent or
indexed field arrangements. Native representation admission is limited to the
existing String and the canonical boxed List; ordinary user ADTs use their
source-bound constructor identity. Exploration has a budget of 64 visits,
including repeated and scalar visits.

The outer list root remains held across all reads, helper calls and loop
backedges. Its String child can therefore be borrowed even if the child itself
has no independent shared reference. The private String reader neither destroys
nor returns that child. Only a proven scalar can escape. Existing strict tail
descent still proves stack-safe outer iteration.

This intentionally refuses List<List<String>> when both List instantiations
would inhabit the same graph, mixed List payload types among roots, general
tree recursion, owned results and effectful helpers. A future full type identity
in the residual IR could remove some restrictions; this experiment does not
pretend that a nominal name is a universal type identity.

`layout-controls.bend` supplies seven finite graph rejection checks.
`ordinary-transfer.bend` has an unrelated numeric List counter, a renamed generic
user spine sum and an intentional mixed-instantiation refusal. Check emitted
reader coverage and diagnostics as well as the five output lines.

## Avoid paying for the same plan three times

The first Stage1 integration deliberately made preparation costs visible: it
derived seed summaries, ordinary workers and extended plans separately. The
optional final `single-scan.bend` overlay replaces `p128br_prepare` with one
ordinary plan scan. It builds workers and summaries from the same plan and
lowered reader, retaining immutable schemas for targeted retries.

Retries are limited to helper-cycle boundaries, unsupported concrete parameter
schemas and successful scalar observers whose old fallback was not a leaf.
Successful schemas are reused. This also permits scalar-only nested numeric
observers when the request contains no String seed helper.

Compare output identities, selected worker sets and complete request time before
promoting this preparation change. The diagnostic export intentionally retains
its simple separate analysis; diagnostic timing is not production preparation
timing.

## Required evidence before promotion

Check the assembled compiler, all finite controls, ordinary ownership/alias
controls and unrelated transfer. Inspect selected workers and the actual work
removed. Preserve unsupported-schema refusals, unique-root guard overhead,
source/IR growth and preparation cost. Compare generated runtime and native
compiler request time separately. A name-search proxy improvement does not
establish whole-compiler throughput or general QBE parity; native qualification
and representative requests remain separate gates owned by the coordinator.
