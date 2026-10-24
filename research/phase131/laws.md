# Phase131: source-connected usage-summary laws

Fifty-five distinct Bend laws were accepted by the retained independent BendTT
kernel. They cover the actual saturating-count helpers, the actual missing-side
summary transform, and a source-connected safe replacement for merge and lookup
on an explicitly restricted domain. Two type-correct wrong algorithms were
accepted without their laws and rejected with the unchanged laws.

This establishes useful reusable proof obligations. It does **not** establish
correctness of the whole usage analyzer, its callers, or native code generation.
These proofs make no whole-compiler speed or production-selection claim.

The machine-readable [evidence](../../selfhost/tools/performance/phase131/laws/evidence.json)
records exact source closures, elaborated terms, report hashes, costs and failed
attempts. The [replay instructions](../../selfhost/tools/performance/phase131/laws/README.md)
use the existing authenticated toolchain; no toolchain was rebuilt.

## What is actually proved

| Component | Scope | Independent result |
|---|---|---|
| `p131a_add` | For counts encoded as 0, 1 or 2, actual `min(2, U32.add(a,b))` equals the independent constructor truth table | Accepted |
| `p131a_low`, `p131a_high` | Actual sequence, Mat and NWPattern combiners equal independent truth tables for the same bounded counts | Accepted |
| `p131u_absent` | On every finite entry list, mode0 is identity; modes1/2 clear every minimum, preserving the entire ordered key/high payload | Accepted, exact production body with only `@unsafe` removed |
| Safe lookup replacement | Missing branch preserves maximum lookup and forces minimum lookup to zero, for arbitrary lists and arbitrary U32 query IDs | Accepted |
| `Word.cmp`, `U32.cmp` | Actual comparison is reflexive, proved by induction over the dependent `Word(n)` representation | Accepted; no assumed comparator law |
| Safe merge replacement | For two arbitrary-length maps with the same key sequence, actual merge returns exactly the pointwise combination | Accepted |
| Safe merge plus lookup | Both minimum and maximum lookup of that merged result equal the relevant combination of the two original lookups | Accepted for sequence, Mat and NWPattern |

The aligned-map theorem quantifies over arbitrary U32 keys, arbitrary U32 count
fields and query IDs. Neither sortedness nor uniqueness is needed for this
particular domain: both sides follow exactly the same comparison path. The
`P131UAligned` record is a way to quantify over pairs of maps with the same key
sequence, **not** a new runtime representation. It contains no proof axioms.
The theorem does not cover two maps with different key domains.

The arithmetic laws separately establish the 0/1/many invariant for bounded
inputs. The merge/lookup equalities themselves retain actual U32 arithmetic,
including its behavior outside that intended invariant. They therefore must not
be read as a proof that arbitrary count fields are valid usage summaries.

## Connection to the compiler

The actual candidate is
[`usage/summary-v02.bend`](../../selfhost/tools/performance/phase131/usage/summary-v02.bend).
Its two consumers in
[`consumers-v01.bend`](../../selfhost/tools/performance/phase131/usage/consumers-v01.bend)
reuse the summary for an immutable body in `ns_unshared_terms` and `nh_terms`.
The old queries remain available as independent finite differential oracles.

`source-bridge.py` compared complete declaration bodies in the acquired
`usage-source02/compiler.bend`: the three arithmetic helpers, `P131UEntry`, and
`p131u_absent` are byte-identical to their proof inputs. The only permitted
extraction change was removing `@unsafe` from `p131u_absent`; its body and type
then passed ordinary safe checking and independent BendTT verification. This is
a source identity check, not a proof of compilation.

The original merge and lookup use mutually recursive dispatch helpers. A local
computed `Cmp` match is forbidden by the language parser. The safe replacement
instead uses small dispatch functions with deferred continuations. Every
recursive call visibly decreases a source list; no fuel or runtime proof
argument is introduced. Its branch choices and early stopping match the old
algorithms, but native optimization of the closures still needs measurement.

[`prepare-safe-summary.py`](../../selfhost/tools/performance/phase131/laws/prepare-safe-summary.py)
constructs a complete candidate from the actual summary, replacing four
algorithms and removing three mutually recursive dispatch declarations. Every
other analyzer declaration is checked byte-for-byte unchanged. The proof
module qualifications `A.` and `P.` are removed explicitly, and every resulting
safe declaration is checked against its proof source. The generated candidate
is **2,757 bytes versus 3,185 bytes** for the original summary. It is an
experiment, not the selected compiler; its executable source is retained at
`selfhost/build/phase131/laws-safe-summary01/summary.bend` with a receipt.

The aligned lookup laws directly support a consumer using `max > 1` or
`max <= 1`: equality of the count preserves either Boolean observation. They do
not prove that the generic KTerm traversal chose the correct children or mode.
In particular, preserving `NWPattern`'s `kid(row,0)` traversal and minimum-zero
rule remains an explicit integration obligation.

## Falsification and rejected attempts

1. **Wrong count operation.** The independent kernel accepted the law-free
   program with saturated addition changed to minimum. Adding the unchanged
   count law failed at a semantic equality (the first reported mismatch is
   Zero followed by Once). This was not a syntax or resource failure.
2. **Wrong merge decision.** The kernel accepted a law-free merge whose LT and
   EQ continuations were exchanged. The unchanged same-key merge law failed.
   Exchanging both continuations preserves their affine use counts, isolating
   semantic choice from linearity checking.
3. The initial mutation duplicated a continuation across LT/EQ. The kernel
   rejected its affine program before reaching a law. That is useful feedback,
   but it is **not** counted as the semantic negative control.
4. The first combined arithmetic/associativity file passed source checking but
   exceeded the 60-second kernel budget. Associativity from that file is not
   counted as proved. Smaller entries passed without raising limits.
5. The exact missing-side extraction exposed the original `match mode entries`
   binder-order error. `summary-v02` fixes it. Two subsequent proof scripts
   failed because their reflexivity/rewrite terms were incomplete; corrected
   structural proofs passed. Rejected snapshots remain available.
6. The local-computed-match lookup candidate was rejected by the parser. The
   deferred-dispatch form passed safe checking and independent verification.

## Cost and trust boundary

All targets used CPU4, a 2GiB RSS cap, a 16GiB available-memory floor and a
60-second deadline under a separately authorized serialized proof lock.
No full compiler image or benchmark target was built or executed by this task.

The final ten-law aligned merge/lookup closure took **0.68s source checking,
0.80s elaboration and 1.77s independent kernel checking**, with about **608MiB**
peak kernel RSS. The first standalone saturated-addition kernel check took
22.47s; subsequent successful kernel checks were 0.33–1.77s. These are observed
execution costs, not a warmed controlled comparison or a compiler-speed gain.
Recorded supervised target time across the initial twenty-law campaign,
including the 60-second failure and negative controls, was **117.1s**. This excludes agent research,
source-writing time and any parent integration work.

The runner reauthenticates the retained Phase94 Lean/BendTT installation and the
pinned Bend frontend/elaborator bytes. Every accepted elaboration had **zero
opaque definitions**, and every named law had an actual emitted body. An
independently rejected false equality also accompanies each positive kernel
run. The trusted statement is the kernel's judgment about those elaborated
terms. It does not prove the elaborator correct, the production backend's U32
intrinsics faithful, the native runtime's ownership implementation sound, or
stack/resource behavior. No `@unsafe` or assumed comparator implementation was
used inside the proved dependency closures.

## Co-optimizing the proved algorithm after a performance failure

The parent measured the initial safe candidate on a fixed native usage proxy:
**0.094279s → 0.241731s**, or **2.564× slower** than the original summary.
The five alternating paired runs are retained in
`selfhost/build/phase131/usage-safe-jobs01/timing/report.json`. This is a proxy
runtime comparison, not whole-compiler latency. The first source-level proof
success therefore did not justify promoting its implementation.

Two distinct responses are being evaluated. A general compiler admission fix
can retain the unchanged proved source. Separately, we produced a first-order
algorithm that does not need closure optimization:

- Lookup carries its pending `Cmp` and result value in a direct recursive
  worker. Only LT advances the entry list; EQ/GT do no further comparison or
  recursion. Pattern dispatch may still inspect the remaining list constructor
  before releasing its owned value.
- Merge carries the two current heads as six U32 fields, alongside their tails
  and pending comparison. It no longer reconstructs the nonselected head/list
  just to take it apart at the next step. No callback or fuel argument remains.
- Structural list arguments precede changing scalar state. This is necessary
  because the safe checker requires arguments to be unchanged, left to right,
  until a structurally decreasing argument appears. The initial order-first
  lookup version was correctly rejected.

These exact algorithms are in
[`lookup-first-order-v02.bend`](../../selfhost/tools/performance/phase131/laws/lookup-first-order-v02.bend)
and
[`merge-first-order-v01.bend`](../../selfhost/tools/performance/phase131/laws/merge-first-order-v01.bend).
Both passed safe checking. Eight further laws were independently accepted:
four establish complete lookup equivalence, two establish complete merge
algorithm equivalence, and two transport the aligned lookup-combination
contract directly to the first-order implementations.

The algorithm-equivalence laws quantify over **all** finite input entry lists,
all U32 modes/counts/keys and queries. They require no sorting or aligned-domain
precondition. This is stronger than merely repeating finite differential tests,
but it is equivalence to the prior proved safe algorithm, not a new full map
correctness theorem. The pointwise map-specification theorem still has its
explicit aligned-domain restriction.

The final eighteen-law dependency closure took **2.10s** in BendTT with about
**607MiB** peak RSS and zero opaque definitions. The exact source closures,
failed variants and performance falsifier are preserved in
[`first-order-evidence.json`](../../selfhost/tools/performance/phase131/laws/first-order-evidence.json).
The source files and proofs are frozen for independent compiler acquisition.
The parent's subsequent five paired native proxy executions measured
**0.094172s → 0.096660s**, or **1.0264×** the original fast summary, versus the
initial safe version's 2.564× penalty. This independently measured result is
retained in `usage-first-order-jobs01/timing/report.json`; it does not establish
whole-compiler request latency or final production qualification. Proofs and
performance gates jointly found a practical algorithm rather than forcing the
slow proof-friendly source into production.

The independent `first-order-source-bridge.py` check authenticated all eleven
actual declarations in `usage-first-order-proxy01/main.bend` against their
accepted proof snapshots, removing only the explicit local module qualifiers.
Successor native admission must rerun that exact bridge on its own full source.

## Consolidation: the next missing contract is count validity

Fourteen additional laws establish a universal bounded-count lookup result and
an empty-right merge base case. They quantify over arbitrary-length entry
lists, arbitrary U32 keys and queries, including duplicate or unsorted keys;
this is not a finite test catalogue. The input-domain witness represents each
count by Zero/Once/Many and encodes it as 0/1/2. Actual first-order maximum and
minimum lookup are proved equal to an encoded count, and therefore at most 2.
For all three admitted combination modes, maximum lookup after merging such a
map with an empty right map equals the intended pointwise combination with 0.

This exposes an essential limitation of a proposed unrestricted merge law.
For `[P131UEntry{0,0,3}]`, an empty right map and sequence mode, actual merge
preserves the existing count 3; applying the saturating combiner to 3 and 0 yields 2.
That is a counterexample by direct reduction of the source definitions, not a
separate runtime measurement. Full summary correctness must establish the
bounded-count invariant as well as sortedness and uniqueness. The new domain
witness does not prove that `p131u_build` always produces such inputs.

The complete eighteen-law dependency closure for the empty-side result took
**2.09s** in the independent kernel with zero opaque definitions. Reproducible
sources are `bounded-lookup-laws.bend` and `empty-merge-laws.bend`;
[consolidation-evidence.json](../../selfhost/tools/performance/phase131/laws/consolidation-evidence.json)
binds the new receipts, the actual eleven-declaration source bridge and the
first-order native proxy result.

The smallest remaining universal obligations are: prove bounded-count and
sorted/unique preservation through arbitrary merge branches; prove query-order
compatibility using actual U32 comparison; then prove lookup combination for
nonempty different key domains. Only after that does the generic KTerm
traversal become the main missing theorem. Its Var, exact-arity Mat,
NWPattern and malformed-fallback cases must match the existing queries exactly.
The present laws do not constitute a whole-analyzer or compiler theorem.

## A directly useful identity law for borrowed String readers

The exact current safe `p88_string_eq_go`, `p98_eq_finish` and public
`p88_string_eq` bodies were copied unchanged from `combined-codegen-source01`.
Historical Phase98 laws already connected consuming equality to a structural
reference, but that alone was not a proof of character reflexivity. Reusing the
proved actual Word/U32 comparison law, three new laws now establish:

- `Char.is_eq(c,c) = True` for every Char.
- `p88_string_eq_go(x,x,same) = same` for every String and Bool.
- The held-root public wrapper satisfies `p88_string_eq(x,x) = True`.

The five-law dependency closure passed independent BendTT in **0.35s**, with
zero opaque definitions. Exact proof/source pins are in
[string-evidence.json](../../selfhost/tools/performance/phase131/laws/string-evidence.json).
`string-source-bridge.py` authenticates the three actual declarations against
those accepted snapshots; no historic implementation is silently substituted.

This supports a bounded native experiment: in the exact borrowed String
reader, full-Term identity with incoming pending flag True may return True.
Returning True unconditionally is wrong when the pending flag is False. No
reflexivity is assumed for Float equality, arbitrary callbacks or user-defined
comparison functions.

The runtime premises are separate: identical native words must denote the same
valid live immutable String; the reader's Bool encoding must match; outer
held-root/provenance guards and the normal release epilogue must remain intact.
A root constructor check alone does not establish preservation of errors in
malformed native tails, which are outside the source theorem. The experiment
must also measure alias frequency in actual composable reader calls: a public
guard can refuse root aliases even while nested readers see identical values.
No native identity shortcut was implemented or benchmarked by this proof task.

## Universal count preservation through the actual merge

A bounded follow-up proved the missing count-range invariant for the exact
first-order merge, including differing key domains. For every pair of finite
input lists whose fields are encoded from Zero/Once/Many, and all three
admitted modes, `all_counts_bounded(p131u_merge(...)) = True`. The predicate
inspects the actual raw output list and checks both fields with the real
`U32.is_le(field,2)` operation. The stronger worker law allows any pending
`Cmp`, including LT/EQ/GT states with no ordering premise.

This theorem permits arbitrary U32 keys, unsorted input lists and duplicate
keys. It assumes neither alignment nor a comparator axiom. Its induction
follows every real merge branch, uses the already-proved actual low/high
combiners, and proves the missing-side transform preserves bounds. Ten new
laws were accepted, bringing the total to 55. The complete 24-law dependency
closure took **2.96s** in independent BendTT with zero opaque definitions and
about **611MiB** peak RSS. Exact receipts are in
[merge-range-evidence.json](../../selfhost/tools/performance/phase131/laws/merge-range-evidence.json);
the reproducible entry is `merge-range-laws.bend`.

This is additional source proof evidence for unchanged production bodies. It
neither changes nor retroactively expands the frozen native admission or
qualification receipts. The earlier unbounded-count counterexample remains a
necessary negative domain control.

The theorem bounds low/high independently: it does not establish `low <= high`,
sortedness, uniqueness, semantic lookup equivalence or KTerm traversal. Its
input domain uses a constructive Count witness; chaining arbitrary runtime
summary results through a complete analyzer proof will require a proved bridge
from the output range predicate back to that witness, or a version of merge
correctness that directly constructs an encoded bounded result. That is a
precise remaining proof obligation, not a property supplied by source checking.

## Highest-value next steps

1. Compare the unchanged safe source with the general compiler admission fix
   against the new first-order source. Reuse the full differential corpus and
   exact QBE output gates, then measure native request/proxy cost. Do not
   promote a proof-friendly algorithm merely because its laws pass.
2. Extend the merge theorem to differing sorted key domains. The missing
   reusable theory is ordering compatibility/transitivity of actual U32
   comparison, followed by preservation of sorted, unique sparse maps.
3. Prove that `p131u_build` and its list/row traversals refine the old
   `nq_uses`/`nq_min_uses` queries. This needs faithful Var, exact-arity Mat,
   malformed fallback and NWPattern treatment; the present laws do not skip
   those obligations.
4. Keep mathematical proof, finite differential checks and native performance
   gates separate. Their combination can justify an optimization; none
   substitutes for the others.
