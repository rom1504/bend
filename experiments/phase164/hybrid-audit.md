# Independent audit: mixed direct/generic integration

Phase164 starts at `d708eef`. This is a source-only audit of the maintained
pipeline and the Phase163 hybrid proposal. No compiler, benchmark, qualification
or generated target was executed. When this audit began, the Phase164 prototype
modules did not yet exist; implementation-specific review must be distinguished
from the source-grounded integration obligations below.

The smallest sound change is candidate-first selection, real adapters/factories,
a mixed opening check, and a final emission boundary that preserves all existing
direct optimizations. The closed-library shortcut from Phase163 is insufficient
for a mixed compiler: disabling late ownership/cold/transport optimizations would
change the performance experiment as well as the representation.

## Minimal integration map

| Boundary | Existing code | Required treatment |
| --- | --- | --- |
| Prepared source and common compacted bodies | `back/common/constructor-facts.bend:p144o_lower_bangs`, `back/qbe/static-data.bend:p112s_prepare` | Keep one actual prepared request. Build current direct candidates/admission before selecting generic work; do not add a second cache/preparation. |
| Factory versus worker | `back/qbe/lower.bend:p111_entry`, `p111_extend`, `p111_compile_step` | Preserve actual closure factory and its continuations; replace only the positively admitted worker body with a real adapter. |
| Independent opening check | `back/qbe/checked-boundary.bend:p114s_open` | New mixed checker validates ordinary segments with the unchanged verifier and adapters against an exact explicit ABI contract. Do not forge a successful original-program certificate. |
| Existing optimization boundary | `p114s_inline`, `p114s_commit`, `p146c_verify` | Reuse unchanged direct transformations/checks on truthful mixed header metadata; add omitted-owner obligations. |
| Late ownership/product/cold composition | `prepared-context.bend:p128raw_prepare` and its continuation chain | Reuse the actual request, raw candidates and transformed direct functions; the integrated chain is largely compatible with real adapter headers. |
| Final admitted plan | `P134Planned{P134Admitted{...}}` | Recheck every omitted owner's final boxed target after all replacements/retries, before any output. |
| Actual streaming renderer | `stream-emission.bend:p134e_admitted/p134e_prepare` | Preserve arrays/cold tables and direct renderers; build the mixed transport capability and registry with checked direct imports. |

`p134e_prepare`, not merely the older `p113e_registered`, is the active renderer
integration site. It computes IDs, fusion index, capability tables, registry and
the streaming context. Changing only an older whole-string emitter would leave
the native streaming path unchanged.

## Early admission and source identity

An omission requires an existing admitted boxed entry at the exact owner returned
by `p113d_public(book,name)`, matching source arity and one result. Reject omission
for native/foreign/bang owners, unsupported incoming captures or metadata, and
failed/unresolved candidates. Reuse the current checked tail-pair composition
and ordered dependency admission; do not seed signatures for otherwise
unadmitted recursive cycles.

For positive arity, `p111_entry` may construct an eta factory, or may lower the
original body when its typed/operational arities differ. Preserve that branch
exactly. The skipped computation is the body lowering inside `p111_extend`, not
the whole source definition indiscriminately. For zero arity, the actual source
entry can be the direct adapter. Initially declining tricky non-eta owners is a
valid conservative restriction; silently substituting an eta factory is not.

The original raw candidates must survive for later product/ownership retries.
One source definition can have an admitted boxed entry while another optional
candidate fails; selection is by the exact required entry, not by a nonempty
candidate list or the existence of any private worker with a related name.

The complete final header map authenticates symbolic `N111FuncId` references.
The retained generic verifier must reject a reference to an omitted continuation.
Function IDs are assigned after segment construction; new consistent numeric IDs
are acceptable. Global fresh-name advancement must remain unique across all
retained factory/generic lowering. Stable old QBE bytes are not the appropriate
first gate for this structural change.

## Mixed checker and final owner obligations

The ordinary verifier accepts runtime imports with explicit signatures; an
arbitrary `N111Call` whose symbol starts with `p113d_` is not thereby safe.
Use an authenticated adapter map or tagged entry descriptor. Independently
require exact worker identity, arity, one result, zero incoming captures,
ordinary flags and the exact argument-load/call/result-store/`rt_return` body.
Check all ordinary segments with the unchanged `p111v_segment`, using a complete
header/schema map containing both real generic entries and real adapters.

An important existing limitation is explicit in `verify-direct.bend`:
`p113e_functions` checks only functions present in its input. Likewise
`p114s_commit` checks the proposed list, not whether it retains every public
source entry. This was safe with generic fallbacks still present. Once a body
is omitted, deleting its direct worker can pass that checker yet leave a dangling
adapter/import.

Carry an explicit obligation set from omission to final output. After late
composition, every member must still have its exact public boxed entry and
signature. Refuse or reconstruct/reverify its genuine generic fallback if that
obligation fails. Do not repair it by inventing a function signature or empty
body. This check is required even if initial and intermediate direct verifiers
already succeeded.

## Late passes: a smaller wrapper surface than it first appears

After independently admitting the mixed original and running the existing direct
optimization checks, the integrated `p128raw_prepare(request,raw,original)` chain
can be reused, subject to the final obligations:

`p128raw_br_prepare -> p128raw_br_scanned -> p131p_scanned`, then the existing
borrowed/product retries and `p126bp_complete`/`p118b_compose`.

These paths use `p118b_verify_functions` for added/final direct functions. That
routine derives `P113Original` facts from entry headers and validates projected
direct bodies; it does not rerun the generic body verifier. Real adapter headers
can satisfy the same ABI obligations. Integrated `p118e_cold` is an internal
continuation of successful verification and rederives its cold names from the
actual source/book; it also does not rerun `p112s_verify`.

In contrast, external convenience wrappers such as `p118c_apply`,
`p118b_chunks`, `p113a_chunks`, and rejected/unchecked fallbacks can invoke
`p113a_verify` and therefore the old original-body verifier. Do not route mixed
adapters through those wrappers and misreport the resulting refusal as evidence
against direct-first. Do not weaken those protected verifiers. Use explicit new
entry/exit wrappers around the existing internal continuations.

## Two downstream performance traps

### Preserve generic-to-native call information

`closed-regions.bend:p112c_index_with` starts with an empty registry and discovers
`P112Worker` entries by analyzing generic bodies. Simply omitting the bodies
removes the evidence that generic callers previously used to call `p112w_*`
directly. Existing `p113e_old_private` turns those old private entries into
forwarders to final `p113d_*` workers.

Seed a separately checked direct-import registry from positively verified final
adapters. Each import binds the exact target, argument/result ABI, and emitted
ordinary forwarder. A fabricated `P112WorkerPlan{valid=True}` with no body is not
a proof. Keep imports distinguishable from analyzed generic regions. The native
target's dependencies must already be closed; registry rank must not make an
unbounded ordinary recursive cycle appear acyclic.

Normal fusion/local-continuation passes should scan actual generic segments and
may use these verified imports as available callees. If an imported target is
not emitted, fail before QBE output. All actual registered import/worker counts
must include the separately emitted forwarders, rather than making output
counters look smaller by excluding a new family.

### Preserve live-transport eligibility

The active renderer calls `p118z_eligible` in
`stream-emission.bend:p134e_admitted`. Its generic scalar check permits only known
runtime imports. An adapter's ordinary `p113d_*` call therefore fails that
whitelist, even when the body is the correct fixed adapter. Unmodified reuse
would conservatively disable live-transport capability for the whole program.
That is a performance regression, not a semantic failure, and can obscure the
construction saving.

A mixed eligibility scan may recognize only the exact independently validated
adapter contract; continue checking every other generic segment and every direct
body with the existing transport rules. In particular, direct bodies must still
exclude register reads, state aliases and hidden transitions. Do not globally
whitelist arbitrary native symbols. Unknown cases remain ineligible. Record the
old/new capability bits and cold constructor facts in every comparison.

## Ownership, callbacks, closures and stack safety

Keep the existing consuming word ABI, liveness partitions, keep/sink operations,
constructor representation, borrowed-reader selectors and owned fallbacks. A
direct adapter borrows the state pointer but transfers its owning arguments and
result under the existing convention; it must not add a second sink or retain
old argument registers after a terminal transition.

Generic callers may have pending frames. The adapter must finish through the
real `rt_return` rather than returning the owned word as a scheduler reply.
Generic first-class/partial applications must still use the real factory and
its captured-argument contracts. Unsupported dynamic calls/effects stay generic;
they need not make the whole hybrid request fail.

Direct ordinary dependencies remain an admitted DAG; self tails are loops and
checked tail SCCs use existing selector workers. Non-tail recursion remains on
the generic stack-safe path. A generic-to-direct call does not create a native
cycle if the direct closure cannot call back into the generic graph. Never turn
a generic callback/effect into a new unchecked direct import for coverage.

## Where work really disappears

| Work category | Effect of a correctly omitted body |
| --- | --- |
| Static preparation/common compaction | Unchanged; already shared and still required. |
| Generic body construction | Avoids `p111_lower` on the admitted worker plus its continuation/list/statement construction. Factories and nonadmitted owners remain. |
| Original body verification | Replaces that body's/continuations' traversals with a fixed adapter contract; ordinary retained bodies still receive the original checker. |
| Header/index construction | Fewer continuation entries reduce schema/FID/fusion-index work; required owner/factory headers remain. |
| Direct candidate construction and optimization | Largely unchanged. Early selection is not permission to skip later ownership, inlining or cold analysis. |
| Region registry | Avoids scanning/fusing omitted bodies and their continuations; explicit verified imports preserve fast call availability at bounded interface cost. |
| Rendering and teardown | Required adapters remain, but omitted continuation/legacy-region text and corresponding IR objects may disappear. Count actual changes. |
| QBE/assembly/link | Smaller emitted machine input can help, but this is a separately measured downstream effect, not guaranteed by source IR counts. |

The Phase161 generic-production envelope was11.59 diagnostic seconds for the
full workload. It is a ceiling for that stage alone, not the expected saving of
the first omission set. Do not attribute all48,096 emitted continuation segments
to the1,448 final direct-owner wrappers from the Phase163 census. Some final
workers are admitted only after later transformations, and generic fallback
continuations remain necessary.

## Cheapest useful controls and exact counterexamples

Positive mixed controls should prove an actual fallback exists, not merely call
the new API on an accidentally all-direct program:

1. Use real `constructor_exists` plus `book_final_reverse`/`lookup` on a small
   declaration book. The former's eager recursive Boolean fold is currently
   scheduled; the latter are real admitted direct helpers. Observe the complete
   reversed records and both successful/missing constructor results. Assert the
   selected helper was omitted and the caller retained genuine generic code.
2. A generic caller uses a direct helper's result non-tail (for example, an
   additional observation after lookup) with a pending continuation. Require the
   exact result and inspect that the callable fast import/forwarder exists.
3. A first-class partially applied admitted function crosses a generic
   `apply`/closure boundary. Assert the emitted fixture actually retains dynamic
   application/factory code; specialization can otherwise erase this control.
4. A long list through the admitted tail-loop helper plus a genuinely generic
   non-tail traversal checks stack preservation. Begin with a small control;
   scale only the justified stack test.
5. Keep an ordinary IO/effect fixture generic around a pure admitted helper; the
   hybrid should preserve the established effect behavior without admitting it
   as a native direct callback.

Small malformed typed-IR controls should reject before target execution:

- remove an omitted owner's final direct worker while retaining its adapter;
- change the worker's arity/result, adapter incoming count or effect flags;
- swap two argument loads, omit/duplicate a load, add a sink, or return the word
  directly instead of the scheduler reply;
- make the adapter target an unknown or merely similarly prefixed symbol;
- seed a direct-import entry with no verified final worker/forwarder;
- reference a removed continuation from a retained generic frame/closure;
- introduce a non-tail direct self-call or mutually recursive ordinary imports;
- add a direct register read/state alias and confirm live-transport eligibility
  refuses it even if the adapter shape itself is valid.

No whole qualification campaign is needed to discover these interface errors.
The first guarded machine test should cover one actual mixed control, then the
small positive/negative interface set, before a broader acquisition.

## Review of the implemented additive modules

The five `selfhost/tests/phase164/hybrid-{adapter,lower,verify,entry,render}.bend`
modules were subsequently inspected. The implementation follows the important
boundaries above:

- `p164l_factory` retains the original typed-arity/eta decision; omission applies
  to the worker side and retains genuine factory segments.
- `p164v_original` validates source-bound adapter obligations and all actual
  generic segments/static data. `p164h_original` then calls `p147d_functions`
  with the actual retained header IDs before exposing a valid optimizer boundary.
- `p164v_final` repeats obligations against final signatures and uses the existing
  borrowed projection/direct checker and namespace checks. Missing or changed
  final targets therefore cannot rely on their earlier admission.
- `p164h_final` now refuses an unexpected materialized success rather than
  allowing it around final obligations; existing materialized errors remain errors.
- The actual streaming override excludes only exact adapter shapes from generic
  registry/transport scans. Rank-zero imports get real forwarders emitted beside
  their final direct workers. Final admission, before rendering, authenticates
  those shapes and their targets. It does not broadly whitelist native imports.

No concrete blocking defect was found in this source review. This is not an
execution result or proof that all runtime cases are covered.

The broadened `p164a_ready` can use signatures of `p113d_passes`' admitted list
without repeating an empty-FID structural verification. This is sound as
**discovery only** because the actual mixed-original and all-function checks
still precede optimization/output, and final checks remain. A retained factory
`N111FuncId` can enable the existing permitted closure-creation operation without
admitting a direct scheduler transition. Missing factories or malformed bodies
must still fail actual-header checking. Discovery signatures are not themselves
a new verification certificate.

One assurance limitation is worth preserving: `p164a_shape` compares the body
against the same `p164a_body` constructor used by the producer. That is exact
self-consistency, not an independent proof that the constructor implements the
intended ABI. Source review plus an independently written literal adapter control
anchors the fixed zero-argument contract; real argument/closure/runtime controls
remain separate obligations.

`hybrid-controls.bend` adds28 named structural controls, including the independent
zero-argument adapter instructions, a complete positive final gate, lost targets,
missing/wrong maps, duplicate entries/workers, source bang refusal, malformed
headers/bodies/signatures, unknown/self calls, removed FIDs, scheduler transitions,
and the unexpected-materialized-success boundary. This audit agent did not run
them. Malformed IR is never meant to be executed.

## Optional retained-original ablation

The separate `hybrid-retained.bend` was also reviewed. At the successful mixed
opening boundary it retains the actual checked static program and original
request-derived certificate. After late passes it takes only final direct
functions and constructor hot flags, checks the exact ordered constructor
name/arity schema, and reconstructs emitted segments, static nodes, readback,
effects and purity from the retained value. Final omitted-owner, direct/borrowed
and namespace checks still run.

No blocking defect was found under that private continuation contract. This
avoids the second full generic-body traversal by preserving its input by
construction; it does not forge a successful generic check. The constructor hot
flags remain authorized only by the existing same-request cold pipeline.
`p164i_rebuild` must not become a public API accepting arbitrary trusted flags or
an unverified retained program.

`hybrid-retained-controls.bend` adds seven separate controls: unchanged success,
lost worker, changed constructor order/arity/name, malformed final direct body,
and a forged late program/certificate whose generic/static/descriptor/effect
fields and stronger certificate must be ignored in favor of the retained ones.
These controls were written without modifying the frozen base controls and were
not executed by this audit agent. The optional ablation's construction/lifetime
cost and exact-output agreement need their own measurement, distinct from broad
discovery.
