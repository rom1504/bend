# Literal-array producers and demanded scalar entries

Status: separate source slice after the frozen typed-array checkpoint; execution
and activation pending. The target is a general representation boundary, with
Evening's `fpart` serving as an existing attempted consumer.

The typed U32/F32 effect proof does not admit a literal Array tree or a nullary
entry. Converting such a constructor to raw backing storage would move lazy
`arraydata` realization, iterator demand and potentially observable field work.
This slice instead keeps the original ctor handle all the way through private
helpers. It removes dispatch around already-proved effects; it does not flatten
or rewrap public arrays.

The shared region constructor planner gains an explicit `@array-handles`
analysis context. Only canonical ALeaf/ANode owned by the native Array type can
use it. The original typed field walk still validates every specialized field.
A bounded structural fence permits only variables, literals, annotations and
nested Array constructors in those fields. Calls and opaque computations inside
constructor fields refuse the plan. F32 literals can write the shared float
view, so the emitter preserves their original left-to-right field evaluation;
they are not described as universally effect-free. Ordinary ctor and first-use
arraydata behavior remain unchanged.

An explicit handle-constructor mode extends the existing closed-array audit.
All existing raw callers are wrappers fixed to false. The new true mode changes
only the admitted constructor forms; unsupported calls, callbacks, public arrays
and aggregate results retain the same refusals. Original and planned helpers
remain in the dependency proof and every known nonself call is normalized to the
same private helper ABI. No global mode or runtime proof cache is added.

The scalar entry adapter accepts zero or positive arity, requires the original
contiguous leading-lambda boundary, and preserves the original generic fallback.
It only runs after no existing region implementation was selected, and requires
a literal-array occurrence plus a proved native array effect. Scalar parameters
and result prevent handles escaping. A fresh full array host guard precedes input
and live dependency validation. No inherited proof grants entry. The nullary
wrapper uses the established `exactCode(..., false, true)` form, preserving
zero formal parameters, missing-vector behavior, normal function constructibility
and raw-code refusal. Each call reruns the source computation; no constant cache.

The first implementation does not add nullary private callees or arbitrary
recursive Array producers. Evening's `fpart` is a nullary root with positive-arity
pair consumers and constant ANode/ALeaf fields, so it should fit this domain.
Its enclosing Map/Set/string program remains independently constrained.

Falsifiers are precise: no actual new entry in `fpart`; moved constructor/iterator
or FloatView observations; mismatched public descriptor metadata; a raw `.code`
or constructed-call entry receiving private permission; collapsed repeated
nullary evaluation; fresh handles escaping via a public array result; or changed
dependency mutation/error/reentry traces. Add renamed positive/nullary sources
and event controls, retain the old Phase45 nullary boundary methodology, then
attempt acquisition and activation on the actual maintained Evening source.
The root alone executes checked builds and programs. Capability, correctness,
runtime measurements and promotion are recorded separately.

## Loop-qualified follow-on after the adverse acyclic result

Arrays02 established actual Evening entry and correct values, but the first
screen made Evening 34.91% slower. Its entire generated module differs only in
the new small `fpart` adapter. Preserve that candidate and its controls/results;
do not weaken its required host proof to rescue timing.

The next candidate adds the existing `j_region_has_loop` predicate to completed
literal-root plans. This is the same admission used by ordinary region roots,
not a new cost score, source name or trip-count threshold. Tuple consumers have
already lowered to JUnpack and do not qualify as countdown Mat helpers. The
full array host guard, source dependencies, nullary ABI and generic fallback
remain identical for admitted roots. This is a profitability heuristic, not a
proof that every loop is profitable: a zero/short loop can still pay excess
entry cost and must stay in the measurements.

New v2 controls preserve the acyclic examples as explicit marker-absence and
ordinary-fallback cases. A renamed countdown carries a literal Array<F32> and
an F32 accumulator through ordered swap operations. Positive-arity and demanded
nullary roots test actual private entry; independent rounding oracles cover
zero, short, nonfinite and long inputs. Mutated helpers, swap/Number/DataView
hooks and thrown errors must refuse entry and agree with ordinary source.
Separate diagnostic points at 0/1/128/8192 iterations measure amortization without
changing the maintained 45-point corpus. The actual Evening fpart should return
to ordinary emission and continue to produce 8 and 81111, with no new marker.
