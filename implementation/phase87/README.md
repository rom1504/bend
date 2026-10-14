# Phase87: native compiler mechanisms and a bounded optimization pilot

The user selects a fully native compiler as a worthwhile target. This phase
investigates the current native B1: upstream TypeScript compiles our Bend compiler
to C, Clang builds it, and the resulting executable compiles user Bend to C
without JavaScript/Node in its request path. It is not yet a native self-produced
B2 or the installed default. Pinned upstream is0592662; installed Phase82 is
unchanged.

[Design](../../design/phase87/native-compiler-investigation.md),
[methods](../../selfhost/tools/performance/phase87/README.md),
[Map audit and repair design](map-investigation.md),
[native source/allocator audit](native-cost-hypotheses.md).

## Confirmed correctness mechanism

Eight tiny controls isolate the Map failure in about23 seconds elapsed, with
15.84 seconds summed guarded execution. Eager branch thunks each capture the
same affine continuation; native reference counting rejects that closure sharing.
The unsafe source bypasses a checker rejection. Law and inline type variants
produce identical C/JS, disproving the earlier missing-signature hypothesis.

Direct branches or threading the continuation once work. Actual repeated calls
still fail. A Data continuation representation succeeds on the corresponding
control. The observer intentionally evaluates symbolic branches with the remaining
computation, so the scoped full repair needs eight Data frame constructors and a
dispatcher, preserving fresh/fuel/error order and recursive-tail validation.
The full Map repair is designed, not implemented by this investigation; never
weaken the runtime check to hide it.

## Native execution profiles

The existing Phase68 sampler works on the exact Phase86 binary; no rebuild or
profiler installation was needed. At4000us, the five-request Lexer profile has
10,983 delivered samples, zero overruns/drops and99.9999% sampled-thread/process
CPU coverage. The same executable supplies its symbols and matching .text;
there is no DWARF, dynamic call stack or caller-specific allocation attribution.
These are whole-process samples including startup/Base and teardown.

| Leaf symbol family | Five Lexer requests | Startup plus one Small request |
| --- | ---: | ---: |
| String.append and its return continuation |67.39%|small remainder|
| rfc_wrap |19.38%|3.62%|
| term_drop |6.63%|46.69%|
| span_fade |2.13%|15.86%|
| closure application |0.55%|5.74%|

The Small profile has801 samples with zero loss/overruns and99.9994% CPU coverage.
Its request is only about85ms whereas Base is about3.06s: this identifies a
startup-dominated lifetime/release cost, not a phase-isolated Base attribution.
The initial1000us Lexer profile delivered2119 samples with6356 timer overruns
(kernel delivery behaved near250Hz); it is retained as exploratory evidence,
while the4000us profiles above avoid that issue. All seven profiled C outputs
match independent B2 hashes. Profile timings are diagnostic, not clean benchmarks.

Native Strings are linked character nodes. Append traverses and reconstructs its
left operand, including ownership work. Three general output helpers repeatedly
append to a growing prefix. This produces quadratic character traffic, despite
reasonable performance of the equivalent source under JS string primitives.
The runtime does not recursively nest redirect wrappers or scan a lengthening
free list, so those proposed explanations are rejected by source inspection.

## Isolated builder pilot

The isolated candidate passes21 explicit helper edge assertions in native and
raw JS. [Frozen patch](linear-builders.patch) changes
only two copied modules: reverse-character indentation and reverse chunk lists
with each chunk appended once. The original helper signatures and nonempty
accumulator semantics are preserved. Upstream, production modules, native entry,
Base, runtime transport and installed images are unchanged.

The candidate is only26 extra physical Bend lines across two copied modules;
no new backend IR, runtime primitive or compiler host algorithm was introduced.
Checked acquisition took65.67s; the single optimized compiler-image build took
193.06s and peaked at4.03GiB RSS. The resulting executable is11,003,720 bytes,
SHA256 `0c93d7c5cc24f0b86662573c9ba47cbe5cb854c7e72ad4f747d9ba24ca83c98f`.

Clean results below are milliseconds **per prepared compilation request**,
including complete output consumption but excluding Base preparation and file
writes. First/fifth means position within one fresh process, not independent
samples or a steady-state guarantee.

| Source | Phase86 native first / fifth | Candidate first / fifth | Fresh baseline repeat | Candidate repeat |
| --- | ---: | ---: | ---: | ---: |
| Small |85 /90|85 /87|—|—|
| Functions65 |376 /406|357 /404|—|—|
| Numeric |240 /310|166 /171|263 /329|151 /158|
| Lexer |5,314 /10,791|646 /783|5,838 /11,259|654 /780|
| Unicode |84 /not measured|80 /83|—|—|
| Map |native fail-stop|same native fail-stop|—|—|

Lexer improves8.2–8.9× first and13.8–14.4× fifth across the historical and fresh
pairs. Numeric improves1.45–1.74× first and1.81–2.08× fifth. The fresh baseline's
Base took3.36–3.38s versus candidate3.07–3.10s, so host/frequency variation remains
a limitation; it cannot plausibly explain an order-of-magnitude Lexer change.
There is no randomized broad-suite confidence interval and no aggregate that
silently excludes Map. The three builder changes were tested together, not
individually ablated.

Five-request whole-process Lexer wall time falls43.55s→6.73s in the historical
pair,46.36s→6.73s in the new pair. The candidate still pays~3.1s Base preparation.
Its first/fifth request cost is now646/783ms versus simultaneous upstream
TypeScript470/258ms and ordinary JS-hosted B2's924/261ms. Native has beaten the
ordinary B2 first request on this case, but has not reached upstream or warmed
B2 parity for Lexer. Smaller sources vary: native first requests beat TS on four
successful sources, while Functions65's fifth request remains404ms versus TS185ms.
Those are narrowly scoped prepared-entry comparisons, not a native CLI speed claim.

All87 experimental-host request C outputs (57 native,30 sibling JS, including12
profiled outputs) match independent B2 byte-for-byte. Thirty contemporaneous
ordinary B2 outputs also match the retained independent hashes;30 upstream
TypeScript outputs are separate source products. Map's native worker fails before
emission and remains explicitly included as a failure. The21 edge assertions cover
empty inputs, prefixes, separators, newline/CR, Unicode and segment flags. The
first offline output validator incorrectly expected `True` instead of `True{}`;
this display expectation was corrected and recorded, with raw source/logs retained.
There was no false Boolean or compiler semantic mismatch.

The JS sibling's C stays exact, but this small screen is not enough to claim no
JS compilation-speed regression: first calls show variation, and helper changes
trade representations. Wider paired native/JS admission is still required before
applying the patch to production. User-program execution was not rerun because
this candidate emits exactly the same C on the successful checks; it changes
compiler execution, not those programs' instructions.

## What remains after the speedup

A second five-request profile on the candidate has1,676 samples, zero overruns or
drops and99.9997% sampled-thread/process CPU coverage. Append's share falls from
67.39% to9.01%, and rfc_wrap from19.38% to6.09%. Term_drop/span_fade rise in share
to56.86%, but their estimated absolute sampled CPU stays nearly unchanged:

| Symbol family | Baseline estimated CPU | Candidate estimated CPU |
| --- | ---: | ---: |
| String.append pair |29.6s|0.60s|
| rfc_wrap |8.5s|0.41s|
| term_drop + span_fade |3.85s|3.81s|

These estimates multiply sample fractions by recorded process CPU; they are
whole-process diagnostic attribution, not exact timers around those functions.
They support a specific causal interpretation: the patch removes repeated
character reconstruction and associated sharing, while a separate release/lifetime
cost remains. They do not identify the owning source pass or justify changing
runtime reference counting. Segment the native profile by request/preparation
and recover callers before choosing the next ownership rewrite.

Lexer repeat growth shrinks from roughly2× to~1.2×, but does not disappear. Numeric
is nearly flat. This supports reducing string traffic as a practical remedy while
leaving the proposed cache/free-list-locality mechanism unproven. Hardware counters
or bounded phase-local allocator observations would be needed to distinguish that
from changing ownership/layout. The system perf wrapper is still unusable; the
reused sampler solved leaf attribution without installing a profiler.

## Limits and next work

No broad native parity or native B2 claim follows from this restricted prepared
single-file entry. Map correctness, arbitrary module/foreign-effect hosting,
prepared Base persistence, negative diagnostics and native self-reproduction
need separate gates. The source audit does not establish the cause of allocator
locality changes across repeated requests; decreasing string traffic may remove
the symptom without proving its hardware mechanism.

## Native roadmap, ordered by value

| Work | Expected benefit | Implementation/verification estimate | Risk |
| --- | --- | --- | --- |
| Repair the observer with8 Data continuation frames | Removes the demonstrated Map correctness blocker; no supported speed forecast |2–4h for implementation and focused observer/Map checks; broader gate after |Medium: preserve branch state/error/tail semantics |
| Integrate the linear output builders after cross-host checks |Measured large Lexer and useful Numeric gains; no promise for every family |Candidate is implemented; allow1–2h for broader native/JS admission and documentation |Low semantic risk, medium performance risk across host representations |
| Native prepared-Base artifact/session lifecycle |Targets~3s fixed process cost; validated reuse could remove most of it from each invocation |2–4h feasibility prototype;1–2days for authenticated/versioned loading and integration |Medium–high: preparation identity, sharing, cache invalidation and native representation |
| Profile ownership by compiler phase/caller, then remove eager captures and needless retained products |Startup profile gives a large lifetime-work budget, but no reliable gain until callers are identified |1–2h bounded attribution;2–6h for one evidence-backed source change |Medium; do not infer allocation sites from leaf-only samples |
| Compact text/name storage and native B2 pipeline |Possible broad locality/allocation benefit and a complete native bootstrap; currently unquantified |Multi-day design/implementation after local fixes and full-host gates |High: Unicode, ownership, effects, backend portability and conformance |

The prepared-Base row is an opportunity estimate, not a measured cache speedup.
Keeping one process alive amortizes the existing cost but does not improve a
fresh CLI invocation. Request timing and end-to-end startup must stay separate.
The current prototype still accepts a restricted single-file import/effect set.
Complete that host contract and compare native B1/B2 C products before promoting
native hosting as the default. A native compiler with the same exact output C
does not itself make those user programs execute faster.

## Artifacts, validation and cost

[Summary](summary.json) records the complete comparison matrix and69 guard
receipts:64 successes and5 expected failures (three native closure controls,
one checker negative and the full native Map worker). Summed target wall time
is506.86s, guarded-campaign span17.57min, peak4.03GiB during the sole full Clang
build; no memory stop, OOM, deadline or unfinalized receipt. Two agents performed
bounded source audits; root alone executed targets. This is measured target time,
not total conversation time, billed tokens or a quota estimate.

[Evidence receipt](evidence.json) binds the archive in
`selfhost/tools/performance/phase87/evidence01/phase87.zip`, containing all new
attempts, immutable candidate source/C/JS/binary, profiles, exact emitted C,
failures and guard records. The original Phase86 binary/source/runtime remain in
that phase's capsule; no historical evidence was modified. The sampled binary
and equivalent .text checks are in the profile analyses. Current upstream, all
production compiler modules and installed images remain unchanged. Installed
release verification returns the same genuine Phase82 B2 hash `098320e8…`.

The candidate can be reproduced and exercised through the documented restricted
entry. It is an experiment retained for integration, not a supported default CLI.
Design/method/report are committed to the fork; no upstream PR comment is posted.
