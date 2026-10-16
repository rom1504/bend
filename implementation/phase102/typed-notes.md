# Composable native workers

This lane addresses the Phase101 indexing profile without changing the source
application or inventing another optimizer. The installed Phase98 compiler
already admits ordinary C `NF_` workers with scalar parameters, local destinations,
tail loops, and ownership-preserving constructor operations. Admission of the
*caller* is all-or-nothing: a parent with one unsupported dependency remains in
the scheduler even when many of its other callees are admitted direct workers.

## Mechanism and first experiment

In the source index, `index_lines` repeatedly calls small admitted workers such as
`next_mode`, `newline_mode`, `utf8_width` and `is_comment`. The scheduler stores
10–15 live values before each call, enters an NF adapter, then restores the same
values in a continuation. Three such continuation functions accounted for 34.5%
of the accepted Phase101 samples. That is physical instruction attribution, not
a promise that all of that fraction is removable.

[prepare.py](../../selfhost/tools/performance/phase102/typed/prepare.py) implements
a general generated-C ablation. It identifies an existing one-result NF adapter,
an exact save-frame shape, and its exact matching continuation prologue. It
snapshots live values into local C variables, evaluates original arguments in
order, calls that same NF worker, and resumes the same continuation locally.
All original ownership operations are retained. Original device branches and
unrecognized shapes are preserved. No application/helper names select a rewrite.

The initial source-index intervention finds 34 admitted wrappers and 46 expanded
call edges across 22 segments. Its static saved-slot count is 392, including
repeated expansion; it is **not** an execution count. This deliberately isolated
ablation retains the old continuation definitions and grows C by about 16%.
That growth is avoidable in the compiler integration below.

Root's first `typed-index01` screen passed full outputs and reported candidate
times of about 0.730× baseline for generated 10,000-line input and 0.622× for the
real compiler source. Corresponding upstream ratios were about 1.267× and
1.417×. Treat the root's complete receipts as authoritative, and later repeated
screens as the promotion evidence. This lane ran no native/compiler targets.

## Bend compiler integration

[prepare-bend.py](../../selfhost/tools/performance/phase102/typed/prepare-bend.py)
prepares a reversible derivative of the exact installed Phase98 source
`2a72bbdc…`. Initial candidate `52ba3d7e…` added 23 physical lines / 1,747 bytes,
but all three applications emitted their original C: the intended rule did not
activate. Preserve that negative result. Candidate 02, `b5331123…`, adds 59 lines /
3,934 bytes and repairs the discovered permission/planning boundary.
The canonical equivalent is emitted as an isolated `canonical-bridge.bend`;
production modules and installed selections are not changed by this preparation.

The implementation reuses the existing `NFCall` value node:

1. `nf_scheduler_name` accepts only a saturated, non-bang named application with
   the existing `NativeHostWorker` certificate and exact arity.
2. `nf_scheduler_bind` uses existing `nd_bind_value` to evaluate every argument
   once, in original order, before the direct call node.
3. `nf_scheduler_emitted` calls the existing ordinary NF function into a local
   one-word result slot. `nc_let_emitted` resumes the remaining scheduler body
   in the same scope, retaining its existing sharing and dead-value handling.

The emitter validates permission/arity again and requires all arguments to be
bound variables. This eliminates the continuation in the compiler's existing
value-producer abstraction; it does not copy continuation C or grant new
whole-function admission. Partial/dynamic/unknown calls keep `nc_let_cut`.
Ordinary NF workers keep their existing scalar-observer redirects where present.

The failed first candidate exposed a critical Phase98 distinction: source-index
uses File effects and has observer permission, but does **not** have the stronger
packing/sharing permission (`NATIVE_TYPED_SCALARS=0`). Its old pipeline therefore
planned NF workers only *after* scheduler lowering, so the local rule could not
see them. Candidate 02 builds the same existing NF plan before scheduler emission
for observer-qualified books without reachable bangs, then attaches a distinct
`NativeLocalPlan` permission. The old `nf_host_payload` rejects that marker;
factory removal, scalar arrays, constructor packing and sharing gates stay off.
Only the new local-call selector reads it. Existing strongly qualified host plans
remain accepted as before. No worker admission rule is expanded.

Any program containing reachable bangs, any raw unqualified emission and any
failed admission retain the prior route. The raw/bang fallback also retains its
original generic-lowering-before-planning error order. The new checked local lane
plans earlier. This is narrower than the generated-C experiment's CPU-only
intervention in arbitrary already-emitted programs. No new GPU behavior is claimed.

## Correctness obligations and controls

For an admitted callee, the old scheduler adapter already invoked the same NF
function with the same consuming arguments and returned its owned result. The
change removes the intervening storage/dispatch protocol. Its obligations are:

- Evaluate arguments once in their original order; preserve error checks.
- Retain exactly the roots shared with later computation, before transferring
  argument ownership; preserve result drops and escaping children.
- Keep saturation, arity, host permission and ordinary boxed-result ABI gates.
- Preserve unsupported, partial, dynamic and device-capable fallback paths.
- Do not select an optimization through benchmark/application names.

[controls.py](../../selfhost/tools/performance/phase102/typed/controls.py) freezes
independent expected outputs for four runtime-text inputs, aliases/escaped fields,
an unused result, asymmetric argument positions, U32 wraparound, partial calls,
and a dynamically returned function. A separate recursive bang control has the
independent answer 428 at one/two/four workers and requests baseline C identity.
These are finite executable controls, not a whole-compiler or lifetime proof.
Argument *positions* are independently observed; effect/error evaluation order
also relies on structural reuse of the existing ordered argument lowering.

The compiler image must be acquired from the isolated Bend source, then emit and
run the same application inputs. A generated-C win alone is insufficient to
claim a new compiler, native B1/B2 chain or promoted release.

## Device source review and candidate 03

Independent review found a real source-generation defect in candidate 02:
ordinary NF declarations are host-only, but a local call could appear in the
unused device fallback body of a scheduler segment. The no-reachable-bangs
permission prevents offloading these segments at runtime; it does not by itself
make their device C well-formed. CPU measurements remain valid, but candidate 02
is not suitable for promotion.

Candidate 03 reuses the existing `N_Segment.host` field. At `nc_finish`, a request
carrying either exact private local-plan or host-plan marker has its segments
marked host-only. Both markers are attached only after checked provider permission
and an empty reachable-bangs set. Existing `ne_segment` then excludes those cases
from the device switch. Numeric FIDs remain available; the host function dispatch
table is already inside `#if !DEVICE`. Segment bodies, ownership and host execution
are unchanged. This omits unused device bodies for a certified CPU-only request;
it does not claim literal preservation of those bodies. Bang-bearing, raw and
provider-unqualified requests retain the original route and device source.

The marker is request-local: `ns_source` strips the prior cache's appended facts
before request planning. `NativeLocalPlan` remains distinct from the stronger
`NativeHostPlan`, so this correction does not grant packing or layout permission.
The isolated canonical counterpart adds a single `nc_finish` wrapper in
`canonical-book.bend`; the main standalone candidate includes it directly.

Candidate 03 is 80 physical lines / 5,171 bytes larger than installed Phase98,
with source SHA256
`eb949e781f6e9467fd1e3183644ecb0637c4102717665532387aaa7824b54ddd`.
The coordinator owns all execution and validation receipts. Candidate 01 and 02
preparation methods and helpers have exact-hash snapshots alongside their local
build recipes, preserving both the inactive experiment and the device defect.

`typed/admission.mjs` adds read-only diagnostic exports and logging wrappers to
an unchanged checked-API prefix. It records existing NF worker admission errors,
dependency closures and refusal sites without changing their return values. This
supports the next question: which whole-function capability still prevents
`index_lines` itself from becoming an admitted worker after local composition?

## Whole-function admission: proof composition, not a new loop engine

The coordinator ran `typed-admission01`. It confirms the main `index_lines`
candidate already lowers to 11,154 bytes of ordinary C, with no lowering error
and **zero continuation segments**. Its failure is transitive admission, not an
inability to represent the state loop. Two independent dependencies block it:

1. `read_word`, `skip_space` and `read_quoted` pass literal closures to `choose`.
   Their ordinary candidates reject escaping closures; the bounded branch
   specialization lane addresses that mechanism.
2. `String.eq` depends on `String.order`, then `String.cmp`, whose dependency on
   `String.cmp.fin` closes a cycle. Both bodies lower without error, but ordinary
   NF admission requires dependencies to be ready first. Inlining the helper is
   insufficient: its equal-character branch calls `String.cmp.rec` **after**
   recursive comparison to rebuild both original strings. This is non-tail
   recursion, and the single-output constructor-chain TRMC experiment does not
   handle its two reconstructed roots.

The independent text reviewer identified a stronger existing capability:
source-index already emits `$observer.String.cmp` and its **owning adapter**.
The existing symbolic observer proof establishes that the comparison can borrow
the two live roots, compute the scalar observation, and return the original
owned pair plus comparison. The public scheduler entry already uses this
adapter. The ordinary NF dependency graph simply cannot use that proof yet.

`typed/observer-forward.bend` bridges this boundary. After the original NF plan:

- Offer only unready ordinary workers with no lowering error or segments,
  positive arity at most four, and the ordinary one-word result shape.
- Use the original observer schema, symbolic proof, residual validation,
  private-name freshness and worker-pair admission. The existing scalar observer
  ready-owner restriction stays unchanged; this pass accepts owning result
  adapters, not a broader shared/unique scalar policy.
- Replace the original unready worker with a same-name, same-parameter ordinary
  worker that forwards its owned arguments and result slot to the admitted
  owning adapter. Record the adapter dependency explicitly.
- Run ordinary NF admission again. Callers can now become ready through the
  proven adapter without admitting a recursive C call cycle or changing their
  bodies. No application or Base function name selects the transformation.

The first isolated candidate (`typed-observer-source01`, SHA256
`257eac636e9c2654ccb12f62553067f58c0d8080c56f6703ac2c1cff4431af64`)
adds 52 lines / 3,273 bytes to typed candidate 03. Independent static review
passed its ownership, ABI and permission boundaries. Execution remains the
coordinator's responsibility. This prototype conservatively omits late cold-layout
metadata for routes proved early: the private-name collision retains the existing
pair, and the ordinary public adapter invokes the new alias. Missing metadata
keeps normal sealing/ownership overhead; it cannot authorize colder stores.
Base String roots are excluded from that cold-layout mechanism already.

`typed/observer-controls.py` provides five independent complete-output controls:
empty/equal inputs, a proper prefix, Unicode ordering, long equal strings and
late mismatch. Each observes scalar equality, both restored roots and comparison,
held aliases, then the final consumed-root result. These target the owning
adapter boundary rather than merely checking its emitted C spelling.
