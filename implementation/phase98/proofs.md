# Phase98 proof track

The first accepted result establishes exact value preservation for the real
held-root string comparison candidate. It uses the D04 compiler source
`d04ad79c…`, candidate `held-source01/compiler.bend` (`81c017c8…`), and exact
declaration extraction authenticated against the candidate's replay receipt.
The unchanged recursive worker is proved equal across separately imported
baseline and candidate modules; the reference cannot change with a candidate
mutation.

The package has three public contracts and two support lemmas. Public contracts
state the original comparator's structural meaning, the complete held
observation (Bool plus both original strings), and the candidate's public Bool
equality to the original. The arbitrary pending-flag invariant catches the
important case of a mismatch at the last character. Every helper used by these
theorems is safe and nonopaque in the emitted inventory.

[`held-proof-check01/report.json`](../../selfhost/build/phase98/held-proof-check01/report.json)
records source check, elaboration, independent kernel acceptance and an unrelated
false-equality kernel rejection. The measured guarded target times were about
0.49 s, 0.53 s, 0.37 s and 0.29 s respectively. These are target occupancy figures,
not an estimate of proof-authoring effort or a general proof-checking cost.

Separately,
[`held-control-oracle01.json`](../../selfhost/build/phase98/held-control-oracle01.json)
records exact native agreement on 1,444 pairs from 38 strings against the existing
Phase88 controls, genuine-JS output and codepoint-list oracle. Native execution
consumes the comparison results and reused input observations. Inspection of
the actual generated C found the intended read-only walker and root disposal
after traversal. Those observations support the optimization mechanism; the
Bend theorem does not prove that native code follows Bend semantics or that its
ownership operations are correct.

Exact ordered dispatch selection for four production selectors has now passed
source checking and the independent kernel in
[`dispatch-proof-check01`](../../selfhost/build/phase98/dispatch-proof-check01/report.json),
with four public laws, 33 support lemmas and no opaque definitions. The initial
literal-recognition proof failed at a residual suffix catch-all and remains
unaccepted. The actual tag candidate now avoids numeric recognizers. Dispatch proves the full
selected enum, not only a count or a membership summary. Its specification
retains every original ordered condition, grouped alternative and fallback
constructor. It deliberately does not claim equality of unsafe recursive caller
bodies, evaluation/diagnostic timing, or a full `KChecking` result. Exact source
replay and finite complete-value tests must cover that remaining integration
boundary. Prepared source is not reported as accepted proof.

The fused tag helper also has an accepted production-connected theorem in
[`tag-proof-check01`](../../selfhost/build/phase98/tag-proof-check01/report.json).
For every actual `KTerm` constructor and arbitrary key, `p98_tag_eq(term,key)`
equals original D04 `p88_string_eq(tg(term),key)`. This includes arbitrary generic
tags, all lambda fields, all literal payloads, recursive children and metadata.
The proof composes the unchanged held comparison theorem with a case split over
the exact observer/helper definitions. Six laws are checked in this closure:
one new public contract, one new support lemma, and four inherited comparison
laws. The observer's leading unsafe annotation is the sole change to its
extracted declaration; independent checking confirms this body is safe. Native
ownership and the unsafe production callers remain outside the theorem.

The unchanged tag statement and proof subsequently passed for v4 and v5. This
reuse is one contract with several implementation instances. The v3 generated C
still consumed the term, despite passing the value proof. V4's private generic
comparison path produced the intended borrowing in the tiny and full compiler
inspection. That contrast makes the boundary concrete: a correct value theorem
does not establish the optimization mechanism. The
[v4 source bridge](../../selfhost/proofs/phase98/comparison/tag-source04-bridge.json)
authenticates the exact proof helpers, actual full source and all 1,366 callsite
substitutions.

Two further public contracts independently passed in
[`scalar-proof-check01`](../../selfhost/build/phase98/scalar-proof-check01/report.json).
They compare the actual retained-root `ix` and `qt` wrappers with the complete
original U32 projections on every actual `KTerm` constructor. They require no
new abstract representation or finite index bound.

Independent challenges were selected before their author inspected Phase98 law
or finite-case bodies. The prepared formal trials admit each mutated helper on
its own, then apply the unchanged accepted laws. Carry-loss and Unicode
truncation change the public comparator; repeating the left string in both
observation fields changes the helper's complete result while its public Bool
may remain correct. That last case cannot be credited as detection of a real
whole-compiler regression. Source-check rejection also remains distinct from
independent kernel checking.

Two legitimate changes make maintenance observable. The independently chosen
codepoint implementation of character equality required a constructor case
split in a support proof while leaving public contracts unchanged. More directly,
the no-carrier held-root candidate removes the intermediate result datatype and
uses a three-argument finish helper. Its public equality statement is checked
byte-for-byte against the accepted statement, and the proof simplifies to the
existing walker lemma. The complete-observation law is explicitly retired
because its helper/type no longer exists. The observed outcomes below retain the
initial failures as well as the successful repairs.

The reusable source catalog and commands are in
[`selfhost/proofs/phase98/README.md`](../../selfhost/proofs/phase98/README.md).
Performance promotion is governed by actual compiler requests and broader
qualification, separately from helper proof acceptance.

The [ongoing-source guide](../../selfhost/proofs/phase98/RUNNING.md) gives a
data-only extractor and root-run check commands for future actual compiler
edits. Missing selected helpers and changed representation boundaries fail
preparation rather than falling back to a historical candidate. The
[catalog](../../selfhost/proofs/phase98/catalog06.json) deduplicates statements
and proof bodies: Phase98 currently has 16 distinct public contracts and 40
supports. Phase96 plus the Phase97 ownership model contributes 35 public
contracts and 10 supports; the combined count is 51 public and 50 support names.
The ownership model's missing native bridge is retained in that catalog, and
neither finite controls nor repeated checks increase the law count.

The actual source02 permission predicate independently passed seven laws in
[`permission-proof-check01`](../../selfhost/build/phase98/permission-proof-check01/report.json).
Four new public contracts specify the complete nine-name whitelist, require the
trust flag, require a filled body and reject every name outside the independent
structural-equality reference. One support lemma covers arbitrary lists and
names; two comparator laws are inherited. Exact helper bytes occur in the actual
classifier and its full source receipt replays. These laws treat both flags as
inputs. They do not prove host authentication, unsafe closure traversal, provider
implementation effects, observer ownership or correct routing of backend flags.
In particular, old packed permission does not universally imply the new
predicate for arbitrary unfilled `KDef` values; checked filled-program premises
would be needed for that wider claim.

The exact old-membership bridge also independently passed in
[`permission-bridge-check01`](../../selfhost/build/phase98/permission-bridge-check01/report.json):
one new public guarded-expression preservation law, one arbitrary-list/key
support lemma, and seven inherited laws. It uses the real source02 `nb_contains`
declaration with its name and recursive calls unchanged; only its leading unsafe
annotation is removed. No detached membership model replaces the old function.
The new helper is constrained both against that executable reference and against
the independently written closed-set specification. Its final-composite instance
also independently passed in
[`combined-membership-proof-check01`](../../selfhost/build/phase98/combined-membership-proof-check01/report.json).

The combined parent source `59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714`
independently passed the unchanged six-law tag and seven-law permission closures
in [`combined-tag-proof-check01`](../../selfhost/build/phase98/combined-tag-proof-check01/report.json)
and [`combined-permission-proof-check01`](../../selfhost/build/phase98/combined-permission-proof-check01/report.json).
The extraction includes the actual public held comparator and finish dependency.
It does not silently reuse an old candidate implementation. As recorded by
catalog06, 16 accepted closures contain 127 checked law instances but only 56
distinct Phase98 named statements and 58 proof-body variants. Counts of public
guard corollaries are declaration counts, not claims of logical independence.
The parent-source tag6, permission7 and membership9 closures share inherited laws,
giving thirteen distinct parent-source names: eight public and five support. The
larger catalog also includes historical and unpromoted candidate packages; it
does not imply that all sixteen public contracts describe that compiler source.

Three late candidate-specific faults were admitted as helpers and then rejected
by unchanged laws: generic tag/name confusion, missing trust guard, and missing
ninth provider. Their receipts are
[`tag-negative-check04`](../../selfhost/build/phase98/tag-negative-check04/report.json)
and [`permission-negative-check01`](../../selfhost/build/phase98/permission-negative-check01/report.json).
They remain separate from the original independently frozen eight-bad/two-good
set. The original unchanged finite suites caught five distinct bad changes; the
separate targeted follow-up caught all eight with previously frozen witnesses.
That follow-up improves finite coverage without rewriting the original result.
This campaign has demonstrated unbounded safe value contracts, maintained proofs
across real implementation changes and a stronger internal observation contract;
it has not demonstrated a same-contract public regression detected by proof and
missed by the unchanged finite suites. The
[independent review](review.md) retains the detailed detection matrix.

The later allocation-cost candidate adds an exact redirect preservation result:
[`redirect-proof-check01`](../../selfhost/build/phase98/redirect-proof-check01/report.json)
independently accepts one public complete-worker-list law and two supports.
It proves the actual old/new functions equal over arbitrary typed workers,
owner strings and root-index lists, including duplicate names and every nested
code/error/dependency/metadata field. All actual string/text helper bodies are
included safely; there is no opaque emitter callback. A reversible declaration
header bridge combines `nc_ctor_codes`' ordinary String-returning signature with
its unchanged body, without counting that function as a theorem.
The emitted closure has 145 definitions and no opaque definitions; its four
guarded targets occupied 9.73 seconds in total. This is a measured validation
cost, separate from authoring time or the compiler's resource use.

The proof closure is byte-identical in combined cost candidate `a0254c27…`.
The [offline source audit](../../selfhost/proofs/phase98/final-cost-data01/source-audit.json)
also checks all nine scalar-cache clones against their retained originals after
undoing cache threading. That cache audit is not a universal layout/planning
proof: descriptors can now be evaluated on permitted routes with no successful
schema, so totality and resource behavior still need separate justification.
The redirect theorem similarly does not establish a memory bound or C lifetime
safety. The [package account](../../selfhost/proofs/phase98/redirect/README.md)
contains source-bridge and run details.

A late redirect mutation, stopping after the first matching worker and therefore
missing later duplicates, passed safe helper admission and failed the unchanged
full-worker-list law in
[`redirect-negative-check01`](../../selfhost/build/phase98/redirect-negative-check01/report.json).
This was a source-level expected/observed mismatch, not an independent-kernel
rejection. The proof author selected this targeted case after positive
acceptance; it is separate from the original independent challenge set.

The minimal origin-guard successor `2a72bbdc…` starts from the combined parent
and adds a lazy `OField` guard in `noa_below`. It does not carry the unpromoted
redirect/cache edits. Its actual-source extractions independently pass the
unchanged six-law tag and nine-law membership closures in
[`origin-tag-proof-check01`](../../selfhost/build/phase98/origin-tag-proof-check01/report.json)
and [`origin-membership-proof-check01`](../../selfhost/build/phase98/origin-membership-proof-check01/report.json).
Their guarded targets occupied 1.85 s and 2.36 s respectively. The
[source account](../../selfhost/build/phase98/origin-proof-account01.json)
authenticates both preparation manifests, every selected helper and the accepted
source snapshots against the exact successor compiler. The two closures contain
fifteen checked law instances, sharing two comparator laws: thirteen distinct
names, eight public contracts and five supports. These repeated implementation
checks add no names to the catalog. The executable
[`origin-controls01`](../../selfhost/build/phase98/origin-controls01/report.json)
records the old mismatch's stack failure, eleven exact candidate origin cases,
three unchanged complete C products, and a valid owning root-swap program that
declines the borrowed observer route and executes with exact output. These are
executable controls, not new laws. None of the comparison or permission laws
proves the recursive origin analysis terminates, validates native evaluation
order, or detects the old eager-conjunction bug. A value-level Boolean identity
can erase the operational distinction which caused that failure.

Observed maintenance and challenge results:

- Bad03 carry loss, bad05 full-width character truncation, and bad08 repeated-left
  observation each passed standalone safe helper checking and failed the
  unchanged held proof. These are source-check rejections, not three independent
  kernel rejections.
- Good02's exact-codepoint refactor passed helper checking but failed the original
  support proof at the same flag-expression boundary as bad05. The first repair
  violated the frontend's match order restriction and was retained. The second
  moves `Chr` decomposition into the existing outer pattern; all five original
  laws then independently passed in
  [`held-maintenance-check02`](../../selfhost/build/phase98/held-maintenance-check02/report.json).
  Public statements, public proof bodies and the reference remain unchanged.
- The actual no-carrier refactor independently passed four laws in
  [`held-simple-proof-check01`](../../selfhost/build/phase98/held-simple-proof-check01/report.json).
  This retains the original public Bool contract and removes only the theorem
  about the deleted carrier/helper. The candidate also passed the existing
  1,444-pair native controls separately.
- The existing finite suite detected the public comparison faults but admitted
  bad08, whose public Bool may remain correct. The law adds an internal
  complete-result contract beyond that suite's scope. Report this scope
  difference rather than presenting it as a missed public compiler bug.
- The independently selected dispatch fault dropping the `Efq` alternative was
  admitted alone and rejected by the unchanged selector proof in
  [`dispatch-formal-check01`](../../selfhost/build/phase98/dispatch-formal-check01/report.json).

The valid refactor shows why frozen-proof failure is not itself a semantic
decision procedure. A changed support implementation can need a small proof
repair while preserving the full contract; independent counterexamples identify
the genuinely wrong variants.
