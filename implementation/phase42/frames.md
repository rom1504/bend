# Phase42 frames: implementation status

The saved-output prototype and bounded recursion diagnostic are ready in
`selfhost/tools/performance/phase42/frames/prototype01/`. The producer records
input/output SHA256 and exact live variable lists in `derive.json`; all three
modules pass Acorn syntax parsing. No production source or old evidence changed.

| Worker | Original bytes | Live-continuation bytes | Saved live slots |
|---|---:|---:|---:|
| warp | 4675 | 2443 | 3 |
| flow | 3930 | 1986 | 3 |
| bsort | 2570 | 1920 | 3 |
| scan | 1655 | 1021 | 1 |

Total four-worker text shrinks 12830 to7370 bytes. Counts are static code size,
not executed work or performance. The live role removes two resumed match
prefixes, parent argument restoration, and per-push saved args array allocation.
The child `$next` tuple remains unchanged. Original has full original argument
vectors; live has scalar properties holding needed right/combine lexical values.

`prepare-controls.mjs` derives diagnostic modules and a scoped copy of the
existing Phase41 independent control owner. It records both owner hashes and
marks the new derivation `checked:false`. The recursive-ceiling role is excluded
from deep-stack equivalence; it is diagnostic and nondeployable.

Initial tool attempts failed because node was not in PATH, then because the
standalone identifier analysis lacked the `$visit` label, then because combine
extraction repeated prefix declarations. These were corrected before generation;
no failed candidate was timed. Adapter preparation exposed a syntax typo and a
missing inherited `all` constant; both were corrected before control execution.
The observed failures remain in the collaboration transcript; the bounded sanity check subsequently passed.

Correctness: syntax and tiny18bench/6alias controls passed on Node24.12.0 in0.11s; awaiting root reproduction on pinned Node24.18.0 and full controls. Measurement: awaiting root.
Decision: investigate; source promotion and source.patch depend on a surviving
mechanism and exact binder/live-use proof. Existing Phase41 proof is reused,
not weakened. Four-worker fixture restriction is explicit; unary remains excluded.

Root's corrected pinned-node screen reports live continuations only
1.015/1.018/1.029× faster at the three tree points; the bounded recursion
ceiling spans0.998–1.083×. This is a final small/null mechanism result, not a
source promotion. Root retains the exact serial run receipts. The frame rewrite
is deferred; its syntax tools, original diagnostic artifacts and failed attempts
remain preserved.

The subsequently assigned inherited-proof context investigation has an independent
source proposal at `frames/context-source.patch`, generated reproducibly by
`frames/make-context-patch.py`. It does not install the live-frame rewrite.
The proposal rewrites only admitted component emission bodies under their complete
JPure context. A nonself target must have its own valid component plan and every
transitive definition must match the context and canonical book by `exact_def`.
Missing, changed or same-name/different-body definitions retain guarded emission.
The public/runtime entry guard remains untouched. Existing JCall carries a private
mode bit selecting the already emitted `$tree` function; Ann preserves original
result typing for ordinary binder inference.

This patch intentionally depends on the calls owner's `j_direct_call_term` fallback
for acyclic helper lowering. It has not been compiled, timed or integrated here;
root's serial queue owns those gates. Source review is pending. Original frame
admission, self-recursive Ref nodes, argument vectors and deep continuation shapes
remain in the original emitter.

The whole-private-graph followup has a separate source proposal at
`frames/owned-constructor-source.patch` and generator `frames/make-owned-patch.py`.
It includes private component activation, direct tagged constructor literals and
marked unary reconstruction. Calls owner's `calls/owned-helper.patch` activates
admitted acyclic helpers. This is an uncompiled experimental supplement to the
already separate calls/context candidate; no constructor timing claim is made.

The final proposal leaves generic deferred `build` lowering unchanged. Closed
nonnative source types gate same-tag object/field-array construction; native
constructors remain on their original emitter. The guard and graph proof still
come from the original terms. Exact field order, fresh root allocation, child
aliasing and existing structural frames are preserved by construction; root must
validate the actual checked emission and controls before admission.

Actual constructor comparison tools are prepared, unexecuted:
`frames/owned-actual-derive.mjs` / `owned-actual-controls.mjs` compare checked02
and checked03 tree modules with clean-byte preservation, full inherited calls
controls, native ABI checks and exact direct-constructor AST/admission counters.
The separate `owned-fixture.bend` / `owned-fixture-derive.mjs` /
`owned-fixture-controls.mjs` cover unary reconstruction, every-node freshness,
native List/Nat/Bool helpers, generic getter/throw ordering, and unguarded public
unary depth30000 deferred fallback. The fixture's independent scalar oracle is
46 at main, and modulo-U32 arithmetic-series totals for the ordinary root grid.
Root owns parsing/checked emission/control execution; this owner has not run them.

The broader actual list gate exposed a real inherited-context bug: rewriting an
outer unary combiner App to JDirectCall erased the saturated original spine used
by structural child-position discovery. The broken keep_gt1 worker emitted an
empty next vector and invalid resume variables/name. Those failed actual modules
and source build attempts remain root-owned retained evidence; controls were not
weakened. `owner-thread-source-v1.patch` preserves the first corrective attempt,
whose generator omitted the new owner parameter from j_covered_terms due to a
literal replacement typo. Root's checked06 cheap gate caught that compile blocker.

The correction is `owner-thread-arity-fix.patch`; the reproducible producer is
`make-owner-thread-patch-v2.py`. The owner is explicit in the existing transform
family. An App subtree containing the original owner Ref keeps its original
App/Call shell while independent argument descendants still optimize. Bounded
reference-scan exhaustion conservatively refuses replacement. Static read-only
arity review covered all10 changed definitions/calls, and a search of every
selfhost source Bend module found no external callers requiring another update.
No compiler rerun or production edit was performed by this owner.

BST probe02 established the actual pair quantities1/1 (nonerased) and List
quantity2, superseding any2/2 Sigma assumption. Down prefix already passes,
Tuple elimination blocks step/insert.fin, and up's mutually exclusive branches
have single self-tail leaves. Build's computed scalar Let and inorder's sequential
child calls remain independent structural admission obligations. The representation
proposal explicitly retains them; it does not claim native layout admission alone
reaches the manual whole-graph ceiling.

Root/review accepted the simpler logically closed global JPure domain instead
of a new owned mode/cache hierarchy: source shape proof is not public ownership,
and every private call still requires the full scalar-root guard/proof. The
candidate native emitter is `frames/bst/native-emitter-source.patch`, generated
by `make-emitter-patch.py`, adding27lines over tree/finite sources. It covers
component and finite/direct helper Tuple projection and closed List admission,
retains runtime/native constructors and the U32 list algorithm selector, and
passes a read-only12-occurrence signature/call arity check. Actual checked
emission, complete values and negative controls remain root/calls-owned pending.
