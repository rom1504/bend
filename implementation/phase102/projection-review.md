# Phase102 observer projection review

The final combined source is `projection-cold-source01/compiler.bend`,
SHA256 `b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f`.
It has **39,370 physical lines, 580 above Phase98**: 438 for the qualified
bounded-inline parent, 119 for projection, 14 for concrete stable eligibility
filtering, and nine for the separate TRMC destination-policy correction.
Its checked API passes, all 23 projection-helper cases pass, and the 29-case
focused program manifest passes all 171 exact-output executions. The five
unique-chain constructor-policy variants also pass all 15 executions. Native
B1/B2 qualification and the broad runtime comparison are still separate gates;
these focused results do not qualify an image.

The pass replaces an already admitted ordinary worker whose entire body is a
pure scalar projection of an admitted owning observer. Its one or two inputs
must be full Terms passed exactly once in the original order. The actual
`NOObserverEntry` comes from the admitted route; both the owning adapter and
borrowed observer worker must already be ready. Missing authority, different
arguments, unsupported syntax or any failed certificate preserves the original
worker. No input type, public constructor ABI or observer permission changes.

Two review findings rejected earlier prototypes before qualification:

- Source01 beta-substituted arbitrary arguments. An ignored argument containing
  an effect or a failing computation could disappear before strict evaluation;
  matching a newly constructed shell could similarly discard effectful fields.
  V3 accepts each consumed argument only when it is structurally identical to
  a subtree of the immutable original schema wrapper. Those subtrees contain
  already evaluated root/result variables and known constructor shells.
- Source02 excluded reserved IDs only through variable occurrences. An unused
  lambda binder could still capture a root introduced by substitution, turning
  a root projection into an apparently valid scalar projection. V3 checks
  every original variable and lambda binder against the entire reserved
  root/result ID span before substitution. The helper controls retain this
  exact counterexample as well as discarded-effect and failing-argument cases.

The syntax machine is bounded to 32 reduction steps and a 256-node original
projector, with the existing 4096-node substitution-growth limit. It permits
only lambda substitution and matches on known wrapper constructors, then
requires the exact schema scalar-result variable. Matches on unknown input
roots, references, primitives and opaque syntax refuse. The immutable known
values also keep substitutions free of source-computed work; the reserved-ID
check prevents those substitutions from capturing a local binder.

Ownership uses the existing `no_adapter`. It keeps the original owned input
roots alive across the borrowed call and its post-call error check. Selecting
only the scalar causes the ordinary environment/liveness emitter to drop the
unused roots before returning that scalar. The transformation adds no borrowed
public interface and does not expose a partially built node. It removes fresh
immutable shell construction and destruction; allocation-failure timing can
therefore change. This review is a bounded correspondence argument and finite
control plan, not a new safe-kernel or universal native-lifetime proof.

Three actual compiler checks caught frontend constraints in the experimental
composition. `projection-api01` rejected a computed `match no_adapter(...)`
scrutinee; a named-parameter matcher now receives that same call result.
`projection-api02` rejected a captured predicate passed to the Base filter;
a concrete `NF_Worker` filter now preserves the same order and predicates
without template partial application. `projection-api03` rejected a repeated
unmarked argument; the single pattern binder is now explicitly shared. Each
failed acquisition is preserved. These corrections change neither the strict
projection guard nor its ownership behavior. The final checked acquisition is
`final-api03`; its source identity is the one above.

The [source-audit successor](../../selfhost/tools/performance/phase102/qualification/audit-source-v7.py)
binds the exact helper bytes, the single `nfo_finish` hook, grammar/linearity
corrections, concrete stable filter, and the separately reviewed TRMC cold-field
policy. The consumed `authority-source-audit05/report.json` is complete/pass
(SHA256 `5a6adf7a21dabf76c20087d5d4d1c52e698118cc72e20eca07767c483fd73180`).
It retains the 14 unchanged authority declarations, two explicitly audited route
changes, 13 original safe-law checks and their source identities, and the exact
helper closures supporting inherited finite certificates. All 159 type
constructors remain unchanged. Fresh API authority controls and complete
final-source native outputs remain mandatory; source correspondence cannot
substitute for those execution gates. Earlier reviewed and failed sources
remain distinct historical evidence.
