# Independent helper challenges, frozen before execution

This review freezes eight plausible semantic faults and two legitimate
equivalent changes against the maintained compiler helpers. The
[manifest](../../selfhost/tools/laws/phase97/challenge/manifest.json) was written
at `2026-10-15T19:15:24.050375+00:00`, before this author observed any Phase97
results. Its SHA-256 is
`4ae912048532e59fb3f058a69f69893b560c7defedac070c07ce6c13ebd977a3`;
the source commit is `52065f4e1a793805698803873c51234f79f35ed9`.

Selection used only maintained `core/{term,index}.bend` and native
`{uses,ir,text,identity,tables,bridge}.bend`, their comments/types and restricted
Git history. During selection, the author and the history-search agent did not
inspect Phase96 law bodies, mutation recipes, case corpus or `reference.py`. The broad assignment
and high-level frontier summary were known; this is independent selection, not a
rigorously blinded study. The challenge authors ran no compiler/program target
and changed no production source. `freeze.py` only hashed sources and wrote
fresh recipe data. Root subsequently ran the frozen-suite evaluation below.

Each edit occurs exactly once in its pinned source. The recipes record complete
before/after source hashes, precise replacement text and an independently
reasoned witness with complete expected values. The adjacent `.witness.bend`
files contain typed helper expressions for later targeted follow-up; they have
not been validated by execution at freeze time. Actual baseline-suite detection
was unknown when the choices and predictions were fixed.

| ID | Helper and challenge | Distinguishing input and expected difference |
|---|---|---|
| bad01 | `k_with_span`: reset literal number while updating metadata | `U32` literal37, old span2–4, new span11–19 must remain37; fault gives0. |
| bad02 | `index_remove_step`: stop after first matching definition | Event names `x,y,x` with distinct payloads, remove `x`: only `y` must remain; fault leaves the final `x`. |
| bad03 | `nu_has`: mask off the high binder-ID bit | Leaf1 queried with2147483649 must be absent; fault aliases the two IDs. |
| bad04 | `nt_join_chunks`: omit separators for empty elements | Join `a,"",b` with comma must produce `a,,b`; fault produces `a,b`. |
| bad05 | `nb_frame_results`: subtract frame pop instead of slot count | Five parameter words, two captured slots, pop1: correct result3, fault4. |
| bad06 | `nc_remove_env`: delete all matching IDs instead of the first | IDs7,8,7 with different words/kinds, remove7: retain8 and the second7; fault also removes the latter. |
| bad07 | `nc_ctor_decode`: remove canonical round-trip check | Display `$ctor.065_` must preserve the original noncanonical spelling; fault displays `A`. |
| bad08 | `nt_fid`: restore the actual old uppercase/cleanup encoder | `foo` and `Foo`, or `a.b` and `a_b`, must encode distinctly; historical expression aliases each pair. |
| good01 | `nt_append`: replace two reversals with structural recursion | All finite lists preserve values, order, empty elements and duplicates. Sample `a,"",a` appended to `z` remains `a,"",a,z`. |
| good02 | `index_split_bit`: use `x xor (x and (x-1))` | Equivalent to `x and (0-x)` for all U32 values, including0 and the high-bit boundary. |

The duplicate-removal pair is intentional. A single generic “remove by key”
rewrite could accidentally impose the same semantics on both helpers, although
one removes all matching definition events and the other removes one binding.
The witnesses retain complete definition and binding payloads; observing only
membership would hide this difference. The environment and frame witnesses use
well-typed helper data without asserting that every checked source program can
produce those exact internal combinations.

The literal-span and canonical-decoding challenges test preservation of data
beyond a convenient projection. The occurrence-set witness checks full unsigned
width. The text witness checks element position even when its payload is empty.
These are source-derived hypotheses, not tuned variants of known suite mutants.

The two good controls should preserve extensional results. For append, induction
on the finite first list equates structural append with reversal into an empty
accumulator followed by reversal onto the suffix. For bit isolation, `x & (x-1)`
clears the lowest set bit for nonzero x; xor with x keeps exactly that bit. Both
formulas return zero at x=0 under unsigned wraparound. These arguments are not
new mechanically checked proofs. Stack use, allocation and performance may
change; those properties are outside these equivalence claims.

## Historical provenance

Exactly one challenge has strong historical provenance. Commit
[`5350b2fec8f6f8484c7a689e915b359d7ce86847`](https://github.com/rom1504/bend/commit/5350b2fec8f6f8484c7a689e915b359d7ce86847),
“selfhost: reduce lookup overhead and fix emission name collisions,” dated
2026-09-29, changed `nt_fid` from
`"FID_" ++ String.to_upper(nt_clean(k))` to
`"FID_" ++ nc_ctor_codes(k)`. Its parent is
`dcae30ca0a3ea940dfc3edd1cb93c26db0f02696`. The same commit changed the main macro
to call `nt_fid("main")`; the current main macro already does so.

The [exact restricted fixing diff](../../selfhost/tools/laws/phase97/challenge/historical-fid-fix.patch)
and recipe preserve the parent/fix blob identities. The one-line current
regression restores the exact old helper expression and still creates the same
collision mechanism. The witness names are newly derived; they are not claimed
to be recorded historical tests.

No equally strong second historical defect was found in the bounded search.
Constructor-ownership history did not establish a semantic repair. An older
reserved-name collision could not be faithfully reproduced by a tiny current
rename because current name encoding already prevents it. Neither was relabeled
as historical evidence; the other seven faults remain synthetic.

## Interpretation before results

Run the frozen Phase96 baseline corpus unchanged first. Preserve whether each
challenge was applied, admitted, executed and observably rejected. An absent
helper is a coverage gap. A parser/type/extraction failure is not evidence that
the semantic oracle detected the predicted fault. A surviving bad recipe is an
escape for this suite, not evidence that its changed semantics are correct.
Rejecting a good control can reveal overly rigid extraction or an incomplete
contract rather than a compiler defect.

Only after those outcomes are recorded should the supplied distinguishing
witnesses become targeted follow-ups. Keep those newly covered outcomes separate
from the original frozen-suite result. Recipes and expected values must remain
unchanged after seeing results; amendments need new, explicitly labeled files.

## Frozen-suite outcomes

Root ran the unchanged 226-case suite after the manifest was frozen. Its
[closed receipt](../../selfhost/build/phase97/challenge-check01/report.json)
has SHA-256
`43f068a2943c0362322ecffd14b6011d3205833b412668c89304093fe5b05332`
and records `complete: true` and `inputsUnchanged: true`. The unmodified baseline
passed all 226 cases. The initial results update read only the Phase97 outcome
summary; it did not alter recipes or inspect Phase96 law bodies/corpus/reference.

| Frozen recipe | Observed outcome | Interpretation |
|---|---|---|
| bad01 literal span payload | Semantic mismatch detected | The frozen suite observes preservation of the literal payload. |
| bad02 definition removal | Semantic mismatch detected | It distinguishes removal of all matching events from first-hit deletion. |
| bad03 high-bit membership | Semantic mismatch detected | It distinguishes full U32 keys from the proposed 31-bit alias. |
| bad04 empty join element | Compiler affinity refusal | The authored edit uses `h` twice without changing its binder to `+h`; no semantic execution credit. |
| bad05 frame result width | Outside extracted helper closure | `nb_frame_results` is not covered by this extraction; no target ran for this recipe. |
| bad06 environment removal | Semantic mismatch detected | It distinguishes first-hit environment removal from filtering all duplicates. |
| bad07 constructor display | Semantic mismatch detected | It observes fallback behavior for noncanonical encodings. |
| bad08 historical identifier collision | Outside extracted helper closure | `nt_fid` is not covered by this extraction; the actual historical fault is not exercised. |
| good01 structural append | Equivalent change accepted | This particular implementation change is allowed by the frozen suite. |
| good02 low-bit algebra | Equivalent change accepted | This particular equivalent arithmetic expression is allowed by the frozen suite. |

The result is **five observed semantic detections, one admission refusal and two
explicit coverage gaps** among the eight bad challenges; both good controls
were accepted. The affinity refusal is a defect in the submitted challenge's
admissibility, not proof that the semantic test detects its intended separator
error. It receives no semantic-detection credit. The two unextracted helpers
remain untested by this frozen evaluation, including the historical defect.

This deliberately chosen, small set is not a random sample of compiler changes
or possible defects. It provides no statistical mutation-coverage estimate,
general detection probability or whole-compiler correctness evidence. The
accepted good controls show that these two changes are possible; they do not
establish that the harness accepts every valid implementation. Detection here
also does not establish a universal proof over all helper inputs.

Root's announced follow-ups were deliberately separate: add focused frame-width and
identifier witnesses, and create a new after-the-fact separator recipe with
`+h` to repair affinity admission. The original bad04 recipe and refusal remain
unchanged. Any successful follow-up will be credited to the expanded cases or
repaired recipe, never retroactively to the original frozen 226-case result.

## Completed targeted follow-ups

Independent offline review of the
[targeted preparation receipt](../../selfhost/build/phase97/challenge-targeted01/receipt.json)
and [follow-up campaign](../../selfhost/build/phase97/challenge-followups01/report.json)
confirms the intended separation. Their SHA-256 values are, respectively,
`20a1356ad7d2946ab93c452b92a58fb5b6b4124a1856659b83365c6904fca868`
and `48bca51ad77ab4de5197cf510e7519a6b10050740d6854c0765478d6603f0f58`.
The reviewer ran only source/data checks, not any compiler/program target.

The [preparer](../../selfhost/tools/laws/phase97/targeted-challenges.py) keeps the
original 226 case objects unchanged as parsed JSON in each of its
four role manifests and appends exactly two witnesses. Their expressions and
expected wire values match the independently frozen bad05/bad08 recipes. The
native selection preserves its original 32 IDs and appends those same two.
Case equality was checked without using the original corpus to redesign a
challenge. The original recipes and first-run results remain unchanged.

The preparer recomputes extraction dependencies separately after each mutation.
This matters for the historical encoder: restoring its old body brings
`nt_clean` into the helper closure, so a missing dependency cannot masquerade as
detection of the collision. For bad04, the sole additional admission repair is
the recorded change from `Con{h,t}` to `Con{+h,t}` in its changed branch. It is
explicitly an after-the-fact recipe variant, not a revision of the frozen edit.

| Follow-up | Verified observation |
|---|---|
| Unmodified expanded JS baseline | All 228 cases pass. |
| Unmodified expanded native baseline | All 34 selected outputs match the complete expected bytes; Clang build and native execution succeed. |
| bad05 frame width | Compilation succeeds; the added witness returns 4 instead of 3. |
| bad08 historical identifiers | Compilation succeeds; the added witness produces duplicate `FID_FOO` and `FID_A_B` pairs instead of four distinct encoded names. |
| Affinity-repaired bad04 | Compilation succeeds; existing `text-assembly-002` observes `a\|b` instead of `a\|\|b`. |

For all three negative runs, the child execution receipt has compilation status
`ok`, unchanged inputs and an actual value unequal to its expected value at the
declared witness. Thus these are semantic rejections, not admission failures or
guard timeouts. Child/manifest/method hashes, the changed source spans and guard
receipts were independently checked. Native baseline output was compared directly
with its pinned expected file, not merely counted by lines.

The negative runs use the JS execution lane. The 34-case native run is an
**unmodified baseline**, not three native mutation detections. These follow-ups
add finite evidence for the two previously unextracted helpers and demonstrate
the separator fault after fixing its admission. They do not change the original
score: **five semantic detections, one affinity refusal, two extraction gaps**,
with both equivalent controls accepted. Nor do the added witnesses establish
universal frame/identifier correctness or statistical mutation coverage.

## Completed formal follow-up for bad01

After the recipes and all above outcomes were fixed, the reviewer inspected only
the relevant Phase96 representation proof and extraction method for this plan.
This later inspection does not form part of the independent challenge selection;
no Phase96 mutation recipes or `reference.py` were consulted.

Bad01 directly contradicts two existing, unchanged universal statements in
[representation/laws.bend](../../selfhost/proofs/phase96/representation/laws.bend):
`span_put_back` at line 28 and `span_preserves_semantics` at line 90. For
`KLiteral{kind,number,text,begin,end}`, the first requires restoring its own span
to return the entire original term. The second compares `Semantics`, which
explicitly contains `kl_number(t)`. Resetting `number` to 0 violates both equations
for arbitrary nonzero payloads. A concrete 37 witness is unnecessary for the
universal theorem rejection. Other laws, such as span last-write or reading the
new endpoints, can still hold; counting those alone would miss this fault.

The existing accepted source is
`selfhost/build/phase96/representation-source03/production.bend`, SHA-256
`c444560110b575409fe916e784e3c9502ccb29943736208d43418f59fb893c42`
(5,507 bytes). Its copied laws are SHA-256
`6fc7ebb6a229aba1faf0ed2948efc6b355d7995cbe8809544ee521fec8417acd`
(7,937 bytes). The manifest's production `term.bend` hash equals the frozen
bad01 source pin. Applying that exact recipe to the extracted helper matches
once and predicts a 5,502-byte helper with SHA-256
`a8412ba75db1e65effff8318b60cd93ab498b7b76a973bc49e541d756761441d`.
The reviewer predicted this hash in memory before root prepared or ran the
follow-up. The subsequently executed mutant has exactly that hash and size;
both law files remain byte-identical to the frozen positive laws.

Root prepared the isolated sources with
[formal-challenge.py](../../selfhost/tools/laws/phase97/formal-challenge.py) and
executed the three ordered source-check jobs through
[proof-negatives.py](../../selfhost/tools/laws/phase97/proof-negatives.py).
The [completed report](../../selfhost/build/phase97/formal-challenge01/report.json)
has SHA-256 `ae916834e317f5c21867d295742dd186a8f81f9c6a66ca5cb6a7aa439dfac95f`.
Its pinned plan and all three child receipts were independently inspected and
their source, snapshot, method and tool hashes rechecked offline.

| Ordered job | Observed result | Guarded target time |
|---|---|---:|
| Baseline laws with unchanged helper | Accepts, exit 0. | 0.555s |
| Mutant helper alone | Accepts, exit 0; the fault is admissible code. | 0.514s |
| Unchanged laws with mutant helper | Rejects, exit 1, at `span_put_back`. | 0.514s |

The last diagnostic compares `P.KLiteral{kind, 0, text, begin, end}` with
`P.KLiteral{kind, number, text, begin, end}` in the literal case. This is the
predicted payload-preservation failure, rather than a syntax, affinity or
missing-dependency error. The negative checker child records `complete: false`
because its normal positive check failed; the enclosing negative runner records
the expected rejection as passed. The three guards total 1.583s, with no stop or
timeout. The checker stops at this first failed law, so this run does not claim a
second observed rejection at `span_preserves_semantics`.

This is a **frontend rejection of a wrong helper by frozen formal laws**,
alongside the existing independently checked positive
[representation proof](../../selfhost/build/phase96/representation-check03/report.json).
All three new children explicitly report `sourceOnly: true` and
`independentlyChecked: false`: there is no new kernel verdict for the mutant,
whole-compiler correctness proof, or proof of surrounding unsafe runtime
behavior. The reviewer ran no compiler or program targets.
