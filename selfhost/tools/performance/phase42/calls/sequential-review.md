# Held sequential continuation review

Reviewed facts/map-bst/sequential-candidate03/candidate.patch (63 added lines).
No production edits or target/compiler execution. The independent fixture is
fixture-sequential-v1.bend; sequential-oracles.mjs is a separately written,
iterative BigInt oracle (syntax checked only). Root must first pinned-TS
parse/check the fixture, then acquire baseline/candidate checked emissions.

No static semantic blocker found in the current restricted proposal. The
initial alleged annotated-inner-call failure was withdrawn: emit.bend's
j_call_spine already recursively strips Ann, so candidate02 was safe on that
point. Candidate03's explicit finder strip is harmless normalization. Retain
both annotated inner and annotated primitive-context regressions.

## Why the admitted shape is narrow

For f(left,U32.add(f(right,acc),value)), original typed JPure and prefix checks
establish closed input/result types and exact graph coverage. Both self calls
must separately satisfy j_component_self's saturated proper-child provenance.
Exactly two original self Refs means a unique inner hole. Its arguments are
only existing local variables, literals, or native Bool constants; every
surrounding operation is an independently recognized saturated U32 primitive
from add/sub/mul/and/or/xor. These operations are total and inert under the
complete original descriptor guard. Delaying another scalar arithmetic sibling
until after the inner call cannot introduce host observations or demand effects.
The outer child's existing local pointer can likewise be read again after the
inner call. Unsupported helpers, constructors, function references, field-read
expressions, allocation, conversion, division, shifts, and F32 contexts refuse.

Emission saves the original worker argument vector, visits the inner child,
then restores original prefix locals before phase3. The annotated JSlot has the
original function result type and emits the inner value. The continuation is
popped BEFORE outer tail transfer; continue $visit otherwise bypasses the
ordinary loop decrement and would leak/reuse that frame. Both outer and inner
calls remain stack-safe transfers. Existing owner-thread rewriting preserves
all App shells containing self before structural classification. Existing
parallel Let emission remains independently unchanged.

## Concrete falsification matrix

Positive source fixture functions cover the exact add-only shape, weighted
noncommutative context, mirrored child orientation with subtraction, and source
Ann wrappers. Closed scalar roots produce right/left skew trees using native
Nat countdown and return U32. The fixture main oracle is11. Test depths
0/1/2/7/32/30000 and seeds0/1/17/2147483648/4294967295 against the BigInt oracle;
count actual worker entries and phase2 resumes so fallback-only success is
visible. Add a diagnostic full branching tree with unequal child depths,
duplicated values and zero-value leaves. A chain of at least three nested inner
frames catches pop/tail ordering; final proof and frame top must restore.

Static negative substitutions must preserve generic emission: outer root rather
than proper child; inner root/nonchild rather than proper child; child alias
without independently established provenance; partial self; three self calls;
non-tail add of two child results; sequential dependent lets; allocating/effectful
argument lets; arbitrary helper/constructor/App around a hole; U32 conversion,
div/mod/shift and F32 contexts; inner self argument containing another helper;
primitive context deeper than32. Existing source bounds and typed call checks
must continue refusing saturation/type mismatches. Native U32 operation aliases
in the source book require canonical primitive recognition and full guard
coverage; renamed graph/function symbols must behave identically.

For runtime refusals mutate every full transitive dependency binding and each
in-place code/env/bound field, include getter reentry/throw/mutation, and verify
candidate entry/resume counters remain unchanged when guard admission refuses.
An overridden producer returning lazy/proxy ADTs must follow the original
fallback with exact field/demand trace. Host replacements and exception paths
must restore proof. Public arbitrary ADT inputs never acquire ownership.

This fixture demonstrates the existing closed scalar domain only. It cannot
establish ordinary original BST benchmark entry: the separate Sigma/List graph
proof refusal remains, and no benchmark-name selector or widened ownership is
proposed here. No performance or successful fixture-compilation claim is made.
