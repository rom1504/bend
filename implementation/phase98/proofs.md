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
