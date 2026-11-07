# Phase173: preserve a flat call across an owned product argument

Status: experimental implementation. The coordinating agent's `abi-api03`
checked acquisition succeeded in 14.81 seconds and `abi-finite03/report.json`
passes all 21 SCC controls and all 25 adapter controls. The initial finite run
passed 24 of 25 adapter controls; the remaining failure was a fixture that
redeclared the direct ABI's implicit `scratch` allocation. The fixture-only
revision3 removes that duplicate and exports both old/new verifier errors.
The independently checked native alias/deep-cycle workload subsequently passed
its entire expected list of values. A harness initially omitted the normal
readback spaces; correcting that expected formatting did not change compiler or
program behavior. This note does not claim a store speedup or full native
compiler qualification.

The subsequent `abi-store-admission03/complete-candidates.json` resolves all 13
shape errors: all 309 raw candidates are error-free. The formerly broken product
boundaries now expose the complete intended tail components:

| Computation | Members | Max argument words | Result words | Source statements | Reported scratch bytes |
|---|---:|---:|---:|---:|---:|
| Import | 9 | 8 | 2 | 664 | 200 |
| Reference collection | 6 | 7 | 2 | 259 | 56 |
| Export | 11 | 11 | 2 | 643 | 208 |
| Compaction | 36 | 16 | 2 | 2,051 | 616 |

All satisfy the unchanged experimental tail-SCC obligations and budgets. The
largest dispatch signature uses 17 words including its tag, below the 32-word
cap. Separate word/natural-number/successor/validation cycles also recover.
These counts concern raw source bodies and explicit scratch accounting, not final
physical machine stack usage, register spills, ready-worker selection or runtime.

Actual `abi-store-emission03/program.ssa` subsequently contains eleven fused SCC
workers. Import, reference collection, export and compaction wrappers now call
workers `.0`, `.7`, `.8` and `.5`, respectively. Their recursive edges are local
loop jumps; none of the eleven workers contains a native self-call or generic
scheduler/frame/stack/return transition. Exact input identity, source lines and
static call counts are retained in `product-argument-qbe-evidence.json`. The
largest compaction worker is still 299,091 bytes of textual QBE, making dispatcher
cost, instruction layout and register pressure important remaining hypotheses.
This is emitted-IR evidence, not a dynamic-work or machine-runtime measurement.

## Observed obstruction

The indexed-store native pilot was correct on the full frozen 101-body corpus,
but about twice as slow as the original recursive-term computation. General
tail-SCC fusion recovered only about 5.7% of the pilot runtime. Inspecting actual
generated code showed that only the `push_edges` and `valid_edges` cycles fused;
the principal import/export/reference/compaction computations still scheduled.

The independent admission diagnostic in
`selfhost/build/phase173/scc-store-admission01/complete-candidates.json` contains
309 raw candidates, 296 without errors and 13 reporting `product result shape
mismatch`. The import component itself has a legal nine-member tail SCC, eight
argument words, two result words, 664 source statements and 200 explicit scratch
bytes. Its external dependency chain fails before the component can become ready.

The decisive boundary is an **argument**, rather than missing knowledge of the
callee's result. For example, `p173take_14` obtains a boxed `P173Node` through a
tuple field, then calls `p173branch_15`. The checked callee signature expects
three flat `P173Node` fields. `nq_args_fit` accepts an `NQBundle` there but rejects
an ordinary `Var`. `p113pl_call` consequently calls the boxed `$direct` worker;
its opaque result cannot satisfy the caller's known two-word result target.
Equivalent failures affect import, export and compaction boundaries.

Making the result adapter box and then unbox would retain additional work and
could turn a tail edge into a non-tail edge with inconsistent result widths.
Adapting the argument lets the existing two-word result convention survive.

## Experimental change

The private `product-arguments-v2.bend` module replaces only `p113pl_call` through
an overlay. It retains the existing successful fitting path exactly. For a
checked `NQSig`, an ordinary finite product argument represented by a boxed Var
may instead be transferred as follows:

1. All original argument expressions have already been sequenced and evaluated.
2. Check the runtime constructor using the existing `p111_test` operation.
3. Consume one owned shell using the existing `p111_take` operation.
4. Pass its owned field values directly to the existing flat worker ABI.
5. Retain the existing result vector, tail transfer and independent final checks.

There is no borrowed pointer, raw unchecked load, new runtime operation, new
datatype or verifier exemption. Shared/static handling remains the established
runtime take operation's responsibility. Source aliases keep their independently
retained ownership tokens through the existing sequence/liveness lowering.

Admission requires ordinary one-constructor shapes already derived from the
checked signature; special numeric/array/effect constructors are excluded.
Every argument leaf must have a real binding. A consumed argument occurs once
in the current argument syntax, has one binding and one emitted local name, and
is not a nonowning scalar. Fresh semantic IDs and emitted local names must not
collide; the 32-word ABI bound reserves one further counter step for the call.
Unknown signatures, unsupported shapes, repeated tokens and failed admission
retain the prior fallback.

The impossible constructor-mismatch branch uses the existing `Efq` error code
4 and the expected-width terminal result. The guarantee concerns well-typed
values under a checked signature; it does not claim equivalence for malformed
payloads manufactured by unsafe foreign code.

## Avoid replacing an already useful boxed implementation

A signature alone does not mean its flat implementation will become ready.
Unconditionally replacing a working boxed call with a flat dependency could
therefore lose a previously admitted worker.

Revision2 only attempts the bridge when the caller requires a known product
result equal to the checked callee result. At precisely this boundary, the old
opaque boxed fallback cannot satisfy the result shape anyway. Opaque-result and
incompatible-result targets retain byte-identical old lowering. Readiness is
still established by the normal dependency closure and independent verifier.

Revision1 remains preserved as a rejected broader-admission experiment. Its
correctness is not the issue; losing useful optimization admission is.

## Gates and falsification

The revision3 finite fixture exports `p173ab_controls` with 25 controls: ordinary
and mixed arguments, separate ownership tokens, duplicate IDs and local names,
unbound/shadowed bindings, nonowning arguments, special/large shapes, missing
signatures, argument arity, fresh-range/name collisions, overflow, unchanged
fitting/fallback paths, and both the legacy and selected independent verifiers.
Negative verifier controls remove the constructor identity or change result
arity. These are finite checks, not an ownership theorem.

The retained revision2 failure was `bridge-both-independent-verifiers`. Source
inspection identifies its explicit `N111Alloca{"scratch",2048,8}` as invalid:
both direct verifiers seed that allocation already, and deliberately reject its
redeclaration. Real product candidates contain no such declaration. Revision3
also exposes `p173ab_verifier_errors`, including the deliberately duplicated
fixture, so the explanation is testable without relaxing either verifier.

The independently written `vertical-abi-workload.bend` exercises shared aliases,
the same source object supplied twice, nested products, an opaque sum fallback,
and a 65,536-step recursive cycle. Its entire list result is the oracle.

The cheap causal gate was to rerun the existing raw-candidate diagnostic:
which of the 13 product-result errors disappear and which complete SCCs become
eligible? Its successful result above justifies the full store rebuild. Native
performance must be compared with both the unchanged
recursive-term baseline and the pre-bridge store pilot; improving a slower pilot
is not by itself an architectural win.

For possible broader integration, module revision3 separately removes a
guaranteed duplicate signature lookup on declined bridge calls. The original
reference entry retains its lookup and delegates to `p173ab_original_info`;
the candidate passes its already obtained immutable signature. No admission or
generated instruction changes are intended. This cleanup is unqualified until
its own check and exact-output gate; the measured acquisition03 files stay
unchanged.

## Interpretation

If this works, the reusable capability is preservation of a checked product ABI
across an owned argument boundary. The experiment does not justify a general
continuation rewriter. It also does not establish that indexed storage is faster:
remaining state transport, repeated constructor guards, large SCC dispatch and
extra storage operations may still dominate. Those are measured hypotheses for
the complete computation, not reasons to weaken the current semantic gates.
