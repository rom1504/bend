# Phase97: do the laws help us optimize?

The experiments support using laws and executable contracts during optimization,
but also show that coverage and the connection to production matter more than
the number of laws. Independent faults exposed two missing helper contracts. A
native lifetime mutation escaped the scope of the source proofs and failed at
runtime. A small ownership transformation was proved under arbitrary surrounding
operations. A real lookup candidate passed complete finite observations and ran
about three times faster in extracted native workloads. Actual compiler-request
time differed by only about 1% in the small screen, with noise and execution-order
effects, so the candidate is not promoted.

[Design](../../design/phase97/law-usefulness-experiments.md) ·
[Experiment](../../experiments/phase97/P97-001-law-usefulness.md) ·
[Methods](../../selfhost/tools/laws/phase97/README.md) ·
[Evidence](../../selfhost/tools/laws/phase97/evidence01/summary.json).

## Independent fault challenges

An offline reviewer selected eight faults and two equivalent rewrites from
maintained production source before inspecting the Phase96 law bodies, mutations
or finite oracle. The recipes and witnesses were frozen before execution. This
is independent selection, not a statistically representative or fully blinded
study. Root ran every target serially under resource guards.

| Unchanged Phase96 executable contracts | Result |
| --- | --- |
| Full baseline | 226 complete expected values pass |
| Semantic faults detected after compilation | 5: literal payload, index removal, high-bit membership, environment removal, constructor display |
| Fault rejected before execution | 1: the separator recipe violated affine usage |
| Helpers outside extracted coverage | 2: frame result count and emitted identifiers |
| Equivalent changes accepted | Both: direct append and equivalent low-bit algebra |

Do not call this eight semantic detections. The original score remains five
detections, one admission refusal and two extraction gaps. Accepting two finite
equivalence controls is useful evidence against overrestrictive tests, not a
universal no-false-alarm result.

The identifier challenge restores a real old implementation from the parent of
[`5350b2f`](https://github.com/rom1504/bend/commit/5350b2fec8f6f8484c7a689e915b359d7ce86847).
Uppercasing/cleaning identifiers merges distinct names; the current codepoint
encoding distinguishes them. The retained historical diff establishes this was
a real fix. Our independent `foo`/`Foo` and `a.b`/`a_b` witnesses are new tests,
not claimed to be the original historical reproducer. Only one defensible
historical bug was selected.

After recording the gaps, we added their two pre-frozen witnesses, keeping all
226 original case objects unchanged. The strengthened baseline passes **228 JS
cases and 34 native witnesses**. Both newly covered faults produce the expected
semantic mismatch. A separately labeled affine repair to the separator mutant
also fails an existing full-value case; its original recipe remains untouched.
Those three mutation runs use JS; the native run is the unmodified baseline.

The literal-payload challenge also tested the **formal** layer. The same bad
helper passed its law-free safe check, then the unchanged `span_put_back` law
rejected it with `number` versus `0` in the complete literal. The unchanged
positive laws passed again. This negative result is a frontend semantic
rejection, alongside Phase96's existing independently checked positive proof.

Detailed provenance, exact values and scope:
[challenge review](challenge-review.md). Raw accepted campaigns:
`challenge-check01`, `challenge-followups01`, `formal-challenge01` under
`selfhost/build/phase97/`.

## Can laws permit a worthwhile optimization?

We tested consuming a definition row once in `f_find`: open its fields, compare
the name, reconstruct the complete row only on a hit, and continue on a miss.
The original path projects `dn(d)` while preserving another owner of `d`.
The candidate removes that whole-row alias and separate projection call.

The frozen operation-specific corpus observes the entire result, the surviving
original book and query, every metadata field, duplicates, misses, Unicode and
empty-name index rows. **All 24 cases pass through both JS and generated C for
baseline and candidate.** Five broken caller variants compile and yield their
named full-value mismatches. Existing helper proofs did not contain this caller;
these finite contracts close that particular connection, not every backend gap.

| Shared-book native helper workload | Baseline µs | Candidate µs | Candidate / baseline time |
| --- | ---: | ---: | ---: |
| 128 rows, head hit | 0.610 | 0.210 | 0.344× |
| 128 rows, middle hit | 31.130 | 10.246 | 0.329× |
| 128 rows, miss | 61.603 | 20.667 | 0.335× |
| 128 rows, tail hit | 62.883 | 20.266 | 0.322× |
| 8 rows, miss | 3.852 | 1.328 | 0.345× |
| 1,024 rows, miss | 518.000 | 164.817 | 0.318× |

These are medians of three alternating samples after independent calibration,
with full outputs/alias survival checked outside timing and discriminating arity
checks inside. Both doubled-count controls pass. The accepted run retains 81
guarded invocations, including calibration; samples are 200–800ms. This measures
extracted helpers compiled by pinned upstream TypeScript/Bun to C, not compiler
latency, native B2, or general generated-program speed. The measured composition
includes a consuming arity observer: on a hit, the baseline returns a shared
original row while the candidate returns a reconstructed row. That downstream
ownership difference is part of the result, not isolated lookup-only time.

The emitted C confirms that the projection call disappears, but disposal work
does not vanish: the candidate still retains/drops children, captures more
fields, and reconstructs hits. Index rows take a different cold path and have
correctness coverage but no timing coverage here. See
[projection analysis](projection-analysis.md) for the actual code shapes.

The single full native B1 candidate then passed **48 complete C and diagnostic
comparisons**: six frozen inputs, four alternating rounds per role, identical
request assets/cache and Clang O2 flags. Equal-case geometric time ratios are
**0.990332× request** and **0.991748× process** versus unchanged native B1.
Request excludes startup/preparation; process includes them. The largest apparent
case improvement, functions65, is noisy: baseline 226–255ms, candidate 224–227ms.
Its two large differences occur when baseline runs first; the candidate-first
pairs are essentially equal. This limits causal attribution of that gain.
The other request median ratios range from 0.991× to 1.000×.

This is a small screening difference, not a demonstrated material compiler win
or parity with upstream. The source change adds 17 nonblank helper lines and a
branch helper. **Do not promote it on this evidence.** No full-self, candidate B2,
45-program runtime or broad conformance campaign was justified or run. Production
and installed images are unchanged.

Source inspection locates this linear lookup in parser/context/sugar/import
paths; some calls deliberately use an empty book or are gated by an index result.
We did not measure dynamic invocation counts. The screen shows that this specific
intervention has little aggregate effect on these inputs; it does not establish
the proportion of time in every lookup or rule out value elsewhere. Before another
full candidate build, measure the caller's inclusive cost or use a bounded caller
intervention. The high-leverage target remains shared observation/ownership across
many callers, rather than another isolated helper win.

## What the ownership experiments establish

The new safe Bend model has an immutable cell, explicit roots and `Keep`, `Read`,
`Drop` operations. Execution returns the full final cell and chronological read
trace, or an explicit dead-root fault with prior observations. Four public laws
and three support lemmas prove:

```text
prefix; Keep; Read; Drop; suffix  ==  prefix; Read; suffix
```

The prefix, suffix, payload and initial state are arbitrary, including contexts
that fault. All seven actual proof bodies passed the independent unchanged
BendTT kernel; the 26-definition elaboration has no opaque definitions. Three
well-formed bad protocols—drop too early, omit the read, retain without release—
passed helper admission and were rejected by the frozen preservation law.

This is stronger than a local test and much narrower than verifying our runtime.
`Read` observes an immutable value, not an escaping native pointer. The model has
one cell and unbounded structural counts, not a heap graph, concrete handles,
machine counter overflow, allocation failures, threads or GPU schedules.

We separately modified one actual generated-C runtime operation: the child
retain inside `span_fade` increments by zero instead of one. The C compiled,
printed eight correct prefix lines, then failed with `bend: a function the
device does not hold`. The unchanged baseline prints all 32 expected lines.
There was no memory stop or deadline. This is an observed runtime failure from
a controlled missing-retain defect, not a sanitizer diagnosis of use-after-free.
The source proofs are unchanged by that C edit and cannot certify it.

The next useful ownership obligation is therefore **parent/child ownership
transfer with individual handles**, followed by a checked connection to the
actual `span_fade`/constructor-lowering operations. Adding more equations to the
one-cell model would not establish that connection. See the
[semantic pilot](semantic-pilot.md) and
[proof package](../../selfhost/proofs/phase97/README.md).

## Which laws should come next?

Prioritize obligations where a planned optimization crosses an observed gap:

1. **Observation and ownership transfer.** Preserve complete values and validity
   of surviving aliases when a parent is dismantled or a child escapes. This is
   directly motivated by the native failure and current allocation costs.
2. **Caller/reference equivalence.** Prove first-match lookup against a simple
   list specification, including duplicate order, misses and every field.
   Relate indexed lookup to that reference under an explicit cache invariant.
3. **Bindings and normalization.** State substitution/renaming correctness against
   a small executable semantics. Preserve beta-rebuilding behavior rather than
   assuming absent identifiers imply byte-identical terms.
4. **Representation boundaries.** Encode/decode preservation and collision-free
   emitted identifiers; frame capture counts versus result-slot counts. Keep
   finite boundary tests until the actual production operation has a safe proof.

Use each new obligation to reject a well-typed wrong implementation and admit a
legitimate rewrite. Measure checking cost and whether it changes a real engineering
decision. Track escaped faults and model/production gaps explicitly. Law count
alone is not a coverage metric, and these experiments do not quantify how much
developer time laws save compared with an otherwise identical no-law campaign.

## Should we aim at whole-compiler correctness?

Yes as a direction; **do not wait for a complete proof before optimizing**. The
tractable path is compositional semantic preservation with production connections,
not accumulating isolated equations and declaring the compiler verified.

| Scope | Deliverable | Rough planning effort, not measured forecasts |
| --- | --- | --- |
| Next ownership model | Two-object/individual-handle model and semantic falsifiers | Several days to a week |
| One production ownership rule | Connect a restricted actual lowering rule to that model, with explicit runtime assumptions | Weeks; proving the C runtime itself is a larger scope |
| One optimization/pass | Explicit input invariant, reference semantics and preservation proof over actual safe implementation | Weeks; depends strongly on pass and proof-ready representation |
| Restricted end-to-end compiler | A small specified language subset, actual lowering/backend relation, explicit trusted C/runtime boundary | Several person-months |
| Full current language and native runtime | Bindings/types, unsafe algorithms, effects/foreign calls, representation, allocation and native execution; separately concurrency/GPU | A multi-person-year research/engineering project with substantial uncertainty |

The pilot establishes feasibility and cheap checking for a small model. It does
not calibrate whole-compiler proof authoring time. Upstream's BendTT checker proves
claims about accepted safe definitions; that does not by itself verify this
compiler's unsafe implementation, C emission, Clang or hardware. A useful first
end-to-end statement must specify its supported subset, observables, failures and
trusted components before implementation begins.

## Cost, failures and production status

The complete ownership proof's source check, elaboration and cached kernel
acceptance took about 0.53s, 0.55s and 0.37s. The strengthened finite campaign took
37.34s including native compilation and negative controls. Source preparation,
review and toolchain installation are excluded from those target timings. The
single full native candidate cost 33.89s to acquire C and 177.05s in Clang;
it was built only after the small semantic and performance screens passed.
The accepted six-source screen occupied 22.00s of guarded target time (33.25s
including orchestration/authentication). Its 176 active input pins and all 48
outputs/diagnostics were independently reviewed offline.

Preserved failures include the original affinity-invalid separator recipe,
unsupported computed-match candidate (upstream gives a clear error; JS B2
reports stack overflow), the first micro doubling-count cap, and one launcher
argument error before a target started. The first collector also tried to reopen
an intentionally reclaimed historical C file embedded in baseline provenance;
its scoped repair distinguishes active authenticated inputs from recorded old
provenance, keeping the missing historical claim visible. No semantic failure was relabeled as a
pass. The repaired candidate retains all pre-frozen input/expected values.

Final target/resource accounting and archive verification are recorded in the
evidence summary. Across all attempts, **207 guarded jobs occupied 381.65s**;
first-to-last target span was **25.19 minutes**, peak process-tree RSS **4.00GiB**,
with no overlapping targets, OOM or deadline stops. Span includes preparation
gaps and is not a measurement of total authoring effort. Three primary offline collaborators prepared/reviewed the
challenge, proof and projection tracks; one bounded child reviewed history and
comparison methodology. Root alone ran targets serially. Quota percentages and
saved development hours are not observable from these receipts and are not claimed.

Production source, installed B1/B2 images, existing conformance results, compiler
latency scoreboard, generated-program speed and active compiler line count remain
unchanged unless a separately qualified promotion is recorded. The artifacts
added here are experimental checks, model proofs, candidate sources and evidence.
No PR comment was posted.
