# Phase144 profiling, measured costs and evidence boundaries

The profiling work identified repeated parser and constructor-ownership searches,
then verified that the integrated changes removed their measured cost. It also
made the remaining frontend, optimizer/verifier and output budgets visible.
The 50-second goal is not achieved. These findings distinguish the first
integrated source, the later serial-runtime experiment and the final compiler.

## What improved in the measured source01 compiler

Both clean requests compile the unchanged Phase142 source and emit the exact
115,909,112-byte QBE oracle (`1dca2d0e…28643`). The candidate is source
`992893e6…483b`, compiled as native N1; the reference is qualified Phase143 N2.

| Observation | Seconds | Interpretation |
| --- | ---: | --- |
| Fresh parent, original runtime | 304.534 | Matched unchanged input |
| Integrated source01, original runtime | 266.862 | 12.37% less time; one clean pair |
| Same integrated program object, serial-reference-count runtime | 249.679 | Separate runtime experiment; 6.44% below the preceding candidate observation |

The first pair measured candidate before parent. These are individual clean
observations, without confidence intervals. The runtime comparison uses the same
program-object bytes but a different linked runtime. Neither observation is an
upstream comparison, complete source-to-machine time or a generated-program
benchmark result. The older 296.541-second parent observation is historical and
is not substituted for the fresh 304.534-second reference.

The [exact comparison and receipts](../../research/phase144/integrated-profile-v2.json)
bind inputs, linked images, actual output and runtime provenance. The serial
runtime is restricted to the admitted single Bend heap mutator; host IO workers
remain. It does not authorize arbitrary concurrent embedding or future parallel
heap access. See the [runtime audit and tests](../../research/phase144/serial-rfc.md).

## Where the measured source changes helped

The following full captures use the original runtime family plus diagnostic
instrumentation. They do **not** profile the faster serial runtime or final03.
The new stage boundaries explicitly map the three changed ownership entry
functions onto their corresponding old semantic boundaries.

| Diagnostic partition | Parent | Source01 |
| --- | ---: | ---: |
| Frontend through erasure | 117.000 s | 94.833 s |
| Admission/static preparation/raw lowering | 50.806 s | 44.819 s |
| Initial optimization and first independent verifier | 64.031 s | 64.431 s |
| Observer work and selected final admission | 28.434 s | 25.150 s |
| Registry preparation/finalization | 18.284 s | 17.400 s |
| Rendering/output/teardown | 51.845 s | 47.831 s |

Parse/load itself falls 47.950→35.906 seconds, with `f_find` active samples
480→27. Erasure falls 15.785→5.899 seconds and raw lowering 44.631→38.690;
the old `nc_ctor_owned` scan falls from 610 samples to zero. Replacement
construction/query/destruction is still charged to the real intervals. Zero
samples are not proof of zero calls.

Output-tail `String.append` samples fall 350→240, consistent with flattening
chunks directly into the caller's suffix. The new body-tail helper replaces
the old body-text helper; that name change alone is not eliminated work.
Remaining instruction-string construction, including `p111q_memory`, is visible.

The source01 capture passes the full byte oracle with **9,158 samples, zero
drops/overruns and 99.545% main-thread/process CPU coverage**. There are 362
samples without a resolved active source owner and 428 without a resolved
physical function; they stay in every denominator. All 411 selected-libc
eligible callers were recovered, but this is not a general logical call stack.

Total diagnostic wall is 330.816→294.871 seconds, a 10.87% reduction. The marker
runtime implementation changed as well, and clean/diagnostic timings came from
different observations. Do not translate those stage deltas mechanically into
the clean 12.37% gain or claim instrumentation neutrality. The conditional final
verifier's 10.351-second interval is inside observer composition and must not
be added again. [Full attribution and limitations](../../research/phase144/integrated-profile.md).

The largest remaining source budgets are optimizer/verification, actual
parser/checker work and registry/output. Physical drop/fade still accounts for
24.53% of samples; register-bank work, including its recovered libc callers,
accounts for 6.68%. Those physical views overlap the source budgets. The compact
sum-record verifier slice improved 11.06%, but its whole-compiler benefit remains
unmeasured; it is not evidence that the entire 64.43-second region disappears.
[Ranked next experiments and conditional 50-second budget](../../research/phase144/remaining-opportunities.md).

## Reusable profiler delivered

The profiler now supports a pinned, data-defined specification of exact native
dispatch markers, their required order and once/first/optional multiplicity.
Each observation records wall, process CPU, main-thread CPU and the actual
delivered-sample ordinal. The offline observer binds the sidecar to its capture,
manifest, exact ELF addresses, owner map and independent output contract.
Historical captures remain unchanged; their legacy import is explicit.

The sampler's signal handler remains unchanged. The added delivered-count getter
supports ordinal association; runtime stage recording stays outside the signal
handler. Missing/repeated required markers fail admission. Missing or repeated
optional markers suppress the corresponding interval rather than invent a stage.
The observer excludes one sample at each edge and requires at least 500 samples
plus loss/coverage checks for quantitative sample attribution.

Validation includes ten synthetic contract tests, exact offline transfer of the
old full/pilot captures, a fresh native generic Lexer gate with complete QBE
and 192 samples, and the subsequent integrated full capture above. The first
phase-specific pilot's incorrect unconditional-final-verifier assumption and
the failed binary-framed-JSON discovery attempt remain recorded. The generic
gate validates profiler use on that native workload, not the compiler's entire
semantics or instrumentation overhead. [Usage](../../selfhost/tools/profiler/STAGES.md),
[native gate](../../selfhost/build/phase144/generic-gate01/qualification.json),
[integrated plan](../../research/phase144/integrated-profile-plan.md).

Retained program objects made each diagnostic acquisition a runtime compilation
and relink, without another full Bend/QBE self-build. The integrated diagnostic
build guard took approximately 2.54 seconds; the full sampled request remained
the expensive part. That reuse is a demonstrated workflow improvement, not a
compiler execution speedup.

## Final03 reproduction is separate evidence

Final source `31e1b13a…e3ea2` includes the later append/predicate changes and uses
the serial runtime `2d078323…93a3`. Its chain is:

| Product | Producer | QBE bytes | QBE SHA256 prefix |
| --- | --- | ---: | --- |
| Q1 / N1 acquisition | Qualified Phase143 N2 | 117,094,086 | `248328cd9ee8` |
| Q2 / N2 acquisition | Final03 N1 | 117,151,119 | `445b66f6c8fb` |
| Q3 reproduction | Final03 N2 | 117,151,119 | `445b66f6c8fb` |

Q2 equals Q3 byte-for-byte. Q1 differs because the new compiler applies different
optimizations; it is not reported as a Q1=Q2 fixed point. Both N1 and N2 pass the
19-case focused gate (16 executed positives, three expected refusals), and N2
passes all 45 ordinary compile/build/execution oracles. Final qualification and
installed selection require their separate binder; these facts alone do not
promote a compiler or cover the experimental incremental interface.

N1→N2's piped acquisition takes 282.933 seconds including overlapping QBE and
machine construction. N2's standalone Q3 self-source request takes 250.296
seconds. Neither is comparable directly with the source01 frozen-Phase142-input
timings above. Actual linked runtime identity comes from the build receipts:
the generic native-request receipt's `runtime` field explicitly describes a
future-build context, not the runtime linked into the supplied image.

Receipts: [N1](../../selfhost/build/phase134/p144-final03-n1/report.json),
[N2](../../selfhost/build/phase134/p144-final03-n2/report.json),
[Q3](../../selfhost/build/phase130/p144-final03-q3/report.json),
[N1 focused](../../selfhost/build/phase111/p144-final03-n1-focused19/report.json),
[N2 focused](../../selfhost/build/phase111/p144-final03-n2-focused19/report.json),
[ordinary45](../../selfhost/build/phase111/p144-final03-n2-full45/report.json).

## Cost accounting remains a final snapshot operation

The [ledger method](../../research/phase144/cost-ledger-method.md) includes every
Phase144 `process.json`, including `guard01`, plus the Phase111 and chooser-law
guards. It separates summed guarded wall, interval union, failed commands,
expected negative checks, resource stops and unfinished work. Six metadata tests
cover nesting/overlap, pending durations and category behavior. No final ledger
was generated for this note while root jobs were still executing.

Two Clang acquisitions hit explicit process-tree RSS limits, spending about
207.77 seconds together. There is still no same-source C executable runtime
comparison from those attempts. They are bounded acquisition failures, not
evidence of a kernel OOM or a diagnosis of one particular LLVM pass.

Time outside guarded intervals cannot be labeled agent reasoning, idle time or
quota. The receipts do not measure those quantities. Failed harnesses and
rejected experiments remain real research costs, but are not all compiler
semantic failures. The final ledger should be run only after the remaining
qualification and measurement receipts close, using a fresh destination.
