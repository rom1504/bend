# P39-005 — one-child producer with an existing private chooser

Status: checked05 emits the actual unary producer and private chooser after the
narrow nested-constructor extension. The first screen is positive; independent actual-source controls pass. Final
warmed speed, compiler-cost and broad regression acceptance remain pending.

Claim: the existing explicit producer stack can cover one self-recursive child
inside a known combiner's argument list, while the existing private Nat selector
handles reconstruction. Save pre-child argument values on descent and evaluate
post-child values only after the child returns. Keep tagged values, BigInt Nat,
public ABI, host/dependency guards, error order and bounded JS stack.

The warmed saved-output experiment gives 1.398×/1.388× for producer-only and
5.40×/8.83× for producer plus chooser at expression 32/128. These are incremental
against installed Phase37. Source integration must show that the chooser route
is actually selected; producer-only speed is not a proxy for the larger result.

The first source attempt (`checked04`) emitted no unary worker. An observation-only
API probe found correct unary shape, one self reference and child index one, but
the existing constructor-field grammar rejected the chooser's nested constructors.
The reviewed successor admits only bounded constructor nesting beneath the
whole-graph-proved `@producer` context; terminal leaves retain the old grammar.

The actual checked05 expression screen improves 6.896×/8.572× at depths 32/128
against the installed Phase37 compiler in the same run. This three-round screen
has substantial drift (candidate depth128 up to +59.8%), so it is not a warmed
acceptance result. The output contains one private unary worker and the direct
private chooser. Fixture v3 failed only its deliberately nonpredecessor function
at the source termination check; v4 adds `@unsafe` to that function and preserves
the refusal assertions. No compiler proof was weakened.

The v4 cohort checks with all three compilers. Its actual emitted controls pass
83 value oracles, 56 complete structural observations, three live admission rows,
32 boundary rows and three exact phase/error rows, including two 30,000-depth
chains with preserved shared children.

Decision: retain the reviewed source candidate through final warmed performance
and broad regression gates. No promotion follows from a checked build or saved-output measurements.
Stop for changed demand/error/reentry, absent private chooser admission, material
compiler-cost regression or a need for a broader IR redesign.

[Design](../../design/phase39/unary-producer.md) ·
[Report](../../implementation/phase39/unary-producer.md)
