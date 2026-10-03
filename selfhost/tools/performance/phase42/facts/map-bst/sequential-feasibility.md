# Sequential child-result tail continuation (held proposal)

> Contract clarification: [the executed preimport BigInt witness](returning-host-callback-assessment.md) falls outside the published standard-intrinsics-at-initialization contract (docs/BEND-IN-BEND-PERFORMANCE.md405–416, pre-Phase42). The earlier blanket promotion stop is superseded; retain the exact witness as boundary evidence. All43 static native-domain assertions passed, but supported postimport mutation, bounds and complete-value controls remain required.


A separate 63-line proposal reuses the existing unary structural phase-2 frame
for `f(right, U32.add(U32.mul(f(left, acc), 10), value))`. It also admits the
simpler `f(left, f(right, tail))` shape. Both outer and unique inner self calls
must independently be saturated proper-child calls under the original prefix
origin proof. Inner arguments and nonrecursive siblings must be inert atoms;
only checked saturated U32 add/sub/mul/and/or/xor can wrap the result hole.
Original JPure type, closure, field and graph checks are unchanged. A 32-level
context bound and existing source bounds contain compile-time search.

`sequential-candidate04/candidate.patch` is an unbuilt, unapplied review artifact
against current tree SHA recorded in identity.json. Candidate01 is retained as
an earlier draft with an unavailable helper name, corrected to existing
List.append in candidate02. Candidate03 explicitly strips the found inner self for normalization.
An initial review suspicion about Ann was retracted: j_call_spine already
recursively strips annotations. This is not a demonstrated correctness fix.
Earlier drafts remain retained. No production source was edited.

Emission descends into the unique inner self call and saves the original prefix
argument vector in a phase-2 frame. On phase3 resume it binds the result to
`$p0`, fills the typed hole using an annotated existing JSlot node, runs the
original shared argument/primitive emitter, **pops the continuation before**
tail-transferring to the outer self call. This ordering is necessary: the
existing frame-loop decrement after emission is skipped by continue $visit.
It uses no new IR tag, fresh source binder, native layout or runtime API.
The annotated hole's result type is the original source function result.

## Activation limitation

This proposal alone provides **no ordinary BST bench gain**. Private component
calls require a non-null scalar-root region proof covering the component's
complete original graph. Bench's graph includes build/insert/down/step, whose
Sigma/List-frame signatures currently fail JPure; it cannot open that proof.
An inorder declaration behind that guard is unreachable from the unchanged
BST benchmark. Public arbitrary ADT arguments do not acquire ownership.

Expected observation-only probe findings are: inorder has a valid pure graph
(BST/U32 types only), two self references, and rejected component prefix/plan;
bench/build/down graph proofs fail on the separate native container domain.
Root's actual probe must confirm these expectations before any patch promotion.
The held proposal can instead be tested on a separate scalar-root source whose
closed scalar-to-BST constructor producer uses only already admitted types and
feeds inorder. That tests a general sequential structural fold, not the original
BST zipper benchmark. Parent should hold applying source until entry/headroom is
shown for such a useful existing-domain source or the native data proof advances.

## Required falsification controls

Positive cases must include both descendant orientations, an empty/single node,
a skewed tree, nonzero accumulator, duplicates, and U32 wrapping multiplications.
Compare full results and count private entries/phase-2 resumes; entry zero cannot
support a speedup claim. A parent frame followed by two nested inner frames must
return with top zero, catching the resume-pop-before-tail-transfer error.

Separate compiler negatives must retain original generic emission for:

- outer self first argument is the original root or an allocating expression;
- inner self first argument is the original root/nonchild or aliases with no
  independently proved descendant provenance;
- partial self, three self references, and two recursive results retained by a
  non-tail combiner, including dependent sequential lets;
- effectful/allocating lets, helper/constructor/function contexts around a hole;
- Math/F32, conversion, division/remainder/shift contexts (outside the initial
  conservative primitive whitelist), and depth beyond 32;
- an inner self argument containing another helper or self call;
- open/mismatched source type, changed descriptor, missing complete coverage or
  externally supplied lazy/proxy ADT fields.

Existing independently accepted parallel-two-child patterns keep their old
emission; this feature must not reject them. Generic mutation/host/proof-finally
controls and exact existing family emission/runtime controls remain mandatory.
Root owns all compiler/target execution; no empirical result is claimed here.

Root probe02 confirms the central expectation: inorder signature/capture and
pure graph pass (graph ["inorder"], fuel32748), while component prefix and plan
fail with two self refs. Bench pure graph fails, so this patch alone still
cannot enter ordinary BST bench. These are actual original-predicate results,
not execution or validation of the held patch.

Candidate04 additionally reuses the existing leaf self-ref count to call the
new sequence proof only for exactly two references. It removes the duplicate
outer ref scan; ordinary single-self leaf admission keeps its original path.
Earlier candidates remain retained.
