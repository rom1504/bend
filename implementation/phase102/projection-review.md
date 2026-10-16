# Phase102 observer projection review

The current combined source is `projection-eligible-source02/compiler.bend`,
SHA256 `956a74765594da64ef30ef42ec0ec2b7710ab435fa7ddbd011501acf467048ad`.
The projection adds 119 physical lines to the bounded-inline candidate and
stable eligibility filtering adds six, for **563 lines above Phase98**. Static
review covers this exact composition, but its API acquisition failed because
the generic Base filter requires a closed predicate. It is not an executable
qualified candidate. A concrete worker-filter successor is being prepared;
actual activation, full outputs and native image qualification remain separate.

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

The first compiler check rejected a computed `match no_adapter(...)` scrutinee.
Source04 corrects only that grammar: it evaluates the same adapter call and
passes the result to a named-parameter matcher with identical checks and
fallback. The failed `projection-api01` acquisition remains preserved. The
separate six-line eligibility hoist filters by the same pure readiness and
size predicates once; the pinned Base filter preserves worker order for all
three immutable dependency rounds. This semantic correspondence did not imply
the captured predicate was accepted by Bend's template checker; failed
`projection-api02` is preserved as well.

The [source-audit successor](../../selfhost/tools/performance/phase102/qualification/audit-source-v5.py)
binds the exact helper bytes, the single `nfo_finish` hook, the grammar-only
correction and stable-filter transformation. It retains all previous
authority declarations, proof/source identities and exact helper closures.
Fresh API authority controls and complete final-source native outputs remain
mandatory; a source audit cannot substitute for them. Sources01 and02 remain
preserved as rejected review lineage.
