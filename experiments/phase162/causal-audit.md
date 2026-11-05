# Phase162 causal audit: what the new frontend result explains

The new result isolates a large **runtime-policy cost inside bendc executing
the same frontend algorithm**. It does not establish a 100× compiler-algorithm
advantage, and it does not explain the entire self-compilation gap. The next
useful evidence is the current parser/checker stage and operation counts, not
another inference from source or output size.

This independent audit read the Phase157–161 records and the new Phase162
receipts. It ran no compiler, benchmark or build. The results below retain their
different measurement boundaries; they must not be multiplied into a purported
factorization of one benchmark.

## What is causally controlled now

`check-original01/report.json` and `check-full01/report.json`, under
`selfhost/build/phase162`, bind exactly the same 3,085,157-byte compiler source,
75,064-byte Base, CLI check-only mode, one worker, disabled GPU and
`BEND_RC=0 BEND_NO_FREE=1 BEND_AUTO_PAR=0`. The two executables are built from
the same current bendc `56edcc65` seed C with pinned Clang-O2; the private header
bounds GC's optional free-block candidate search. No parser/checker algorithm,
source input, proof-report selection or optimization flag changes.

| Check-only observation | Original runtime | Bounded-search runtime |
|---|---:|---:|
| Fresh-process wall seconds | 63.111169 | 17.153183 |
| Total CPU seconds | 63.109993 | 17.151785 |
| Peak RSS, KiB | 1,191,864 | 1,196,388 |
| Exit status | 1 | 1 |
| Exact unsafe-report bytes | 122,602 | 122,602 |

That is **3.679× faster, 72.82% less elapsed time, 45.958 seconds saved**, with
0.38% more peak RSS, in one fresh observation per role. It is not a repeated
median or a confidence interval. I independently read and rehashed both reports:
both list 7,026 unsafe/foreign-dependent names and have SHA-256
`9140d5573caea16496ef1599ac67a258cc26fba0e250e70fa019597f025a76b6`.
Both stdout files are empty. The source SHA-256 is
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`;
Base is `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.

The exact policy boundary and remaining allocator checks are in the
[Phase159 source audit](../phase159/refill-audit.md). This cap changes a reuse
search preference, not tracing correctness or a checker admission condition.
It can also change allocation addresses, locality and collection cadence, so
the entire 45.958s difference cannot yet be assigned exclusively to instructions
in the search loop on this new frontend workload. Prior Phase159 physical-PC
evidence establishes that mechanism on the captured backend workload; fresh
frontend diagnostics are the transfer evidence still being collected.

The successful unsafe verdict is reached only after `Chk.check_book` returns
Done. Unsafe does not skip type or body checking; it relaxes the specific
termination, live-forward-reference and kind-demand rules recorded in
[the frontend boundary audit](bendc-frontend-boundaries.md). The exact verdict
comparison establishes the same observed checking/report result between these
two bendc images, not general semantic equivalence to our checker.

## How the earlier experiments constrain the explanation

| Evidence | What it establishes | What it cannot establish |
|---|---|---|
| [Phase158](../../implementation/phase158/README.md): historical 9c self-emission, local medians 4.499s unchecked / 8.810s checked; complete committed C reproduced | Few-second historical self-emission is real on this host | Published M4 Pro 2.13s is not a matched checked-Xeon/QBE comparison; checking flag is unspecified in the table |
| [Phase160](../../implementation/phase160/README.md): current 56ed own-source checked emission 39.728s original / 11.374s bounded-search | The runtime-policy effect already transfers to real current bendc self-compilation | Current 56ed source/runtime cannot replace historical 9c in the published benchmark |
| [Phase159](../../implementation/phase159/README.md): same captured five-owner algorithm, original GC 13.836s / bounded 2.585s, four balanced pairs | Allocator search explained most of that workload's original negative result | It is not a fivefold improvement to our compiler or proof that GC is universally faster |
| [Phase160](../../implementation/phase160/README.md): same complete compiler implementation and full input, QBE 223.237s / bendc-C 167.602s; collection-factor screen 138.383s | Execution representation/runtime can materially affect our real complete request while preserving all 118,227,421 QBE bytes | Bundled codegen/GC/Clang changes do not isolate one mechanism, and do not make our algorithm run in 8–11s |
| [Phase161](../../implementation/phase161/source-metrics.json): remove 44.97% input bytes, 226.912s → 194.417s | Redundant source inventory has a measurable but modest whole-request cost in this screen | Reduced output is different/unqualified; source size is not an operation count or a demonstrated full explanation |
| [Phase161](../../implementation/phase161/profile-metrics.json): 29.519s parse/load + 33.684s checking/publication + 3.317s proof report | Our diagnostic frontend is substantial, with publication/name operations visible in samples | Its 66.520s is prepared-Base, instrumented stage CPU, not a clean counterpart to either new fresh-process bendc time |

The last row matters: original bendc's 63.111s is in the same broad range as
our earlier 66.520s diagnostic frontend. It invalidates a confident account in
which a 3–4× difference is automatically attributed to checker architecture.
It does **not** prove frontend parity. The experiments use different binaries,
instrumentation, Base preparation and teardown boundaries. The 17.153s result
is a valid faster private bendc frontend observation, with its runtime-policy
change made explicit.

The historical self-emission counters also reject some easy explanations:
all 3,406 loaded declarations reached lowering, with 327.8 million allocation
requests in the separate counted diagnostic. Historical bendc was neither
optimizing only reachable bodies nor avoiding allocation. Its later reachable
emission is a different boundary. Allocation request counts are not live bytes
or system allocator calls, and the counted diagnostic was slower.

## What the “100×” question now means

Dividing roughly 205–215s by the published 2.13s mixes host hardware, compiler
revision/source, checking policy and output responsibility. The matched-host
historical checked figure is 8.810s, so a large gap remains even after removing
that presentation mismatch. It is still a comparison of two different compiler
programs compiling different inputs into different representations.

Three independent dimensions remain:

1. **Cost per operation.** The new unchanged-algorithm runtime ablation is direct
   evidence here. Phase160's same-implementation cross-execution experiment also
   isolates the implementation from its execution route, but bundles several
   codegen/runtime effects and has a large memory tradeoff.
2. **Amount and shape of frontend work.** Identical source/Base now controls input
   inventory. It does not make the two parsers' term representations, declaration
   publication, memo behavior or checker operations identical. The fresh coarse
   clocks and loop-level counts should reveal whether the remaining cost is in
   character processing, term checking/normalization, lookup/publication or runtime
   work. Native memo, String and Map intrinsics must count as part of bendc's
   implementation, not disappear from an all-Bend source comparison.
3. **Different backend responsibilities.** Our whole compiler request still
   performs lowering/candidate production, optimization, independent verification,
   registry preparation and QBE rendering after its frontend. That work cannot
   be explained by a frontend-only result. Large output/function counts are
   indicators of different representations, not instruction-count multipliers.
   Shared compacted-body preparation already exists; proposing it again would
   repeat the Phase161 false lead.

There is no valid measured decomposition of the total gap into, for example,
“source factor × runtime factor × checker factor.” The effects interact and the
existing ratios concern different revisions or workloads. Nor can the independent
5.420s parse-only run simply be subtracted from 17.153s to label the remainder
pure checking: startup, retained objects, GC and report work differ. The diagnostic
pure-stage clocks are the direct way to determine that partition.

The most decisive next answer is therefore narrow: on this already admitted
identical input, report actual parse/check/report CPU and the concrete operations
that account for each, then compare like operation boundaries with ours. Keep
clean timings separate from counters, and preserve complete checking/report
gates. This advances the user's speed question without converting a promising
runtime experiment into an unsupported compiler redesign prescription.

Audit note: `unsafe-control01` actually emits the expected U32-versus-Bool body
error under `@unsafe`, but its receipt is `complete:false` because the initial
runner rejects every `SOME PROOFS FAIL` prefix for a type error. Both failure kinds
share that prefix. This needs an exact diagnostic admission correction; the
failed receipt must not be described as a passed control. Root was notified.
