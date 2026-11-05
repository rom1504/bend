# Phase165 — causal source bisection against bendc

We can now replace specific bendc capabilities while keeping the input, executor,
runtime, checking mode and complete outcomes fixed. The first cuts eliminate
native memoization as a large explanation on our compiler source, identify a
substantial Map/String contribution, and provide a shared-request C/QBE backend
comparison. A reciprocal transplant of our existing equality algorithm changes
the full check-only request by about 1.5% relative to bendc's native-equality baseline.
**No production compiler changed and no cold-build speedup is claimed.**

[Design](../../design/phase165/README.md) · [Metrics and receipts](metrics.json) ·
[Memo mechanism](../../experiments/phase165/emitted-memo-audit.md) ·
[Independent outcome audit](../../experiments/phase165/memo-observation-audit.json) ·
[Lookup method](../../experiments/phase165/native-lookup-method.md) ·
[Generated calls](../../experiments/phase165/native-lookup-code-shape.md) ·
[Backend replay](../../experiments/phase165/backend-replay-method.md).

## The first source cuts

These are fresh-process **check-only** times: live Base preparation, parsing,
checking, complete diagnostic rendering and process teardown. They exclude C/QBE
emission and machine construction. Every timed point uses the same source and
Base bytes. Each row has two alternating-order pairs; the medians are screening
observations, not tight confidence intervals.

| Capability changed in bendc | Input | Original | Variant | Variant/original |
|---|---|---:|---:|---:|
| Disable all six native memo operations | 182 KB compiler-checker source | 1.211s | 1.201s | 0.992× |
| Disable all six native memo operations | Full 3.085 MB compiler source | 17.142s | 16.905s | 0.986× |
| Portable Map operations; native String retained | 182 KB checker | 1.100s | 1.203s | 1.093× |
| Portable Map operations; native String retained | Full compiler | 17.245s | 19.852s | 1.151× |
| Portable Map and String operations | 182 KB checker | 1.125s | 1.482s | 1.317× |
| Portable Map and String operations | Full compiler | 16.881s | 29.644s | 1.756× |
| Our exact safe equality; native Map/memo retained | 182 KB checker | 1.102s | 1.108s | 1.005× |
| Our exact safe equality; native Map/memo retained | Full compiler | 16.878s | 17.137s | 1.015× |

**Memo result:** no material slowdown on these actual compiler inputs. The native
memo implementation matters for some shared proof computations, but it does not
explain a large compilation gap here. The portable bodies deliberately disable
memoization; this is not an equivalent portable implementation of a mutable cache.
The small sharing controls pass, but arbitrary proof workloads are not qualified.

**Lookup result:** the combined native implementation saves about 43% of the
portable variant's full checking/reporting time. Keeping native String while
making Map portable leaves a much smaller deficit. This makes String processing
a stronger transfer hypothesis than Map traversal alone. We did not build the
String-only arm, so there is no standalone String estimate or assumption that
the effects add independently. The increased slowdown on the larger source is
measured; algorithmic scaling and the checking/reporting split remain to be
attributed with dynamic counters.

The native boundary was traced rather than guessed. `Chk.Map.find.go` uses
`String.eq` and `Map.bit`; `Set.has` introduces indirect `Map.has` calls. After
the combined treatment, checker native references change from 36→0 for String.eq,
1→0 for Map.bit and 4→0 for Map.has. No selected native survives transitively
through 120 reached private helper bodies. The Map-only arm retains 36 String.eq
references and allows native String.cmp within its portable Map closure. Native
memo references remain unchanged in both lookup arms. These are static call-site
counts, not dynamic operation counts.

All 72 observations across the four treatments pass their exact exit/stdout/
stderr gate. The full compiler produces the same 122,602-byte unsafe-dependency
report as Phase162; this is completed checking/reporting, not a claim that its
unsafe declarations have mathematical proofs. The checker slice has the same 464
unsafe names independently identified from the full-source oracle. Controls
include two small sharing proofs, an annotated-lambda mismatch, a typed-let
mismatch and an invalid body marked unsafe. The independent audit records one
trailing gutter-space normalization allowed by upstream's test harness; outputs
between variants remain byte-identical.

**The reciprocal cut changes the diagnosis.** Our selected compiler already uses
the non-reconstructing `p88_string_eq_go` through its held wrapper. We copied just
that worker, `p98_eq_finish` and `p88_string_eq`, preserving their exact safe Bend
bodies modulo private names, into bendc. Only the checker's 41 String.eq references
change; native Map operations and memo remain intact. The generated private
predicate reaches U32.is_eq and no hidden native String.eq. Ordinary source
checking and all output gates pass. Its whole checking cost is near the native
baseline on both inputs. This is an actual transplant of our implementation into
the faster system, not a forecast from a synthetic character loop.

Consequently the slower Base-comparison transplant is not evidence that our
compiler needs that algorithm replaced. It reconstructs String pairs that our
current predicate already avoids. The reciprocal result does not establish
identical per-call machine cost or all-workload parity; the native Map/reporting
and remaining checker work can dilute a small predicate difference. It does
rule out a large whole-request penalty from using these exact three Bend functions
in this bendc configuration.

## A complete backend seam, with no new compiler acquisition

The retained checked Phase152 API already exposes both backends. We pass the
**same complete `NR_Request`** to mature C and direct QBE, fully render both
products, and include file writing in the backend clocks. Base preparation and
frontend checking are measured separately. These are hosted execution screens;
they are not native compiler or complete cold-build timings.

Initial QBE-first observations:

| Same prepared computation | QBE backend | C backend | QBE/C | QBE / C text bytes |
|---|---:|---:|---:|---:|
| Original Map workload | 8.266s | 6.548s | 1.262× | 1,028,598 / 809,678 |
| Compiler-verifier slice | 15.457s | 7.594s | 2.036× | 2,146,264 / 998,317 |

Both QBE products match independently retained native products. The corresponding
C and QBE executables produce the required complete outputs (`3714872484\n` and
`0\n`), empty stderr and exit0. This establishes a useful backend responsibility
boundary and preserves observable behavior on these points. The verifier fixture
compiles real verifier code but executes its deliberately small empty-program
control; it is not a runtime benchmark of a large verification request.

Reversing to C-first gives Map **5.710s C / 8.984s QBE (1.573×)** and verifier
**9.141s C / 16.144s QBE (1.766×)**. Both complete products remain byte-identical,
so the earlier machine gates transfer without rebuilding. These diagnostics also
omit the earlier out-of-clock request graph capture; heap/JIT warmup conditions
therefore differ. Across the two screens the gap is 1.26–1.57× on Map and
1.77–2.04× on the verifier, not a precise isolated architecture estimate.

Our mature C backend shares considerable preparation and optimizer machinery
with QBE. This comparison locates a QBE-specific cost; it does not measure
bendc's direct backend or justify assigning all residual work to QBE. The prior
2.132B allocations outside parse/check/report still need stage attribution.

## What the failed cuts taught us

1. The private source tree initially omitted source-relative C/JS effect files.
   Checked emission stopped with an IO error. Adding the exact authenticated
   imports made the original source reproduce the committed C seed byte-for-byte;
   the already acquired identical executable could then serve as control.
2. Copying Base helper bodies after checker definitions produces an unfilled-law
   refusal. Base's publication treatment is special; ordinary copied helpers
   must be ordered before their callers. Three mutually recursive helper pairs
   also required a legal source adaptation.
3. Two attempted adaptations failed parser admission: matching a local value,
   then matching a parameter after another match had consumed its context.
   The successful version unfolds only the worker's recursive branch into its
   helper and matches all helper parameters together. Outer reconstruction,
   comparison order and the single shift evaluation are preserved. No unchecked
   flag, new unsafe annotation or Base trust exemption was introduced. These
   three rewrites are part of the treatment, not mere identifier renaming.
4. An old verifier QBE oracle and the manifest's default native asset belonged
   to an older compiler source than the hosted API. Both mismatches are retained.
   An explicitly bound Phase152 N2 image reproduces the API's complete bytes in
   a 4.248s request. Comparing executable names without source identity was not
   sufficient.
5. A 32 MiB file-limit plan was refused before starting; the guard's supported
   64 MiB limit was used. A Map-only machine adapter rejected the verifier before
   building; an explicit source-pinned verifier adapter supplies its own oracle.

The failed source cuts took seconds of target time. Making the transplant legal
and auditing identities consumed substantially more research time. Preserve the
existing boundaries and reuse the now-checked methods instead of repeating this
preparation for every future hypothesis.

## What to do next

The [transfer audit](../../experiments/phase165/transfer-note.md) changed the
interpretation: our selected compiler already uses `p88_string_eq_go`, avoiding
the reconstructed String pairs in the Base fallback. Its qualified borrowed
reader performs no heap allocation; public ownership/alias adapters still cost
work. Our index hashes once and tests stored U32 masks, rather than repeating
Base Map.bit character walks. Adding those same capabilities again would be
misdirected. A reciprocal transplant of our exact safe equality implementation
into bendc separates the algorithm from its execution costs.

In parallel, use the prepared-request seam to bisect backend responsibilities:
semantic production, ownership/representation analysis, private-worker preparation,
optimization/verification and output. Count the actual work in both implementations
before transplanting a complete responsibility. Keep the final independent
verifier and compare full outputs where the transformation is cleanup-only.
Our C backend's shared costs must remain visible; it is an intermediate reference
before comparing a complete bendc backend computation under matched execution.

The next decisive performance cut is therefore **the same existing predicate and
complete lookup computation under our QBE execution**, including ownership
adapters, calling convention, name representation and teardown. Count work around
the already allocation-free reader rather than adding a redundant native equality
primitive. Backend work accounting remains the second track. Do not sum the
checker and backend ratios into a predicted full-build gain.

Stop treating memoization or a smaller line count as a demonstrated explanation
of the headline gap. Earlier few-second bendc results concerned historical C
emission, often without checking; our cold-build metric includes different source,
QBE emission and machine construction. Phase160's same-implementation execution
comparison and this phase's capability cuts provide narrower causal evidence.
They do not yet explain or close the full gap, or establish a five-second path.

## Cost, retention and scope

The design was committed and pushed before measurements. Root owned one bounded
CPU3 execution lane; agents prepared sources and audited semantics/code generation.
All four private native acquisitions use the same Clang `-O2` flags, bounded-
search runtime, one worker, GPU off, `BEND_RC=0`, `BEND_NO_FREE=1` and disabled
auto-parallelism. Acquisition uses bendc's matching 2.0.34 Base; the measured
workloads retain the common Phase66 Base. Those roles are deliberately separate.

Guard receipts report target cost and resource limits. No full self-host campaign
or broad generated-runtime benchmark ran. Existing archived Phase163/164 generated
intermediates supplied 146.48 MiB of reviewed reclamation; sources, executables and
qualified inputs stayed available. Every new run is classified and sealed at
campaign close. Three captured request graphs were then pruned only after fresh
archive/member verification; their exact restore commands are in
[the retention receipt](evidence/retention/graph-pruning.json). Restore those
graphs before rerunning consumers that authenticate their pins. Generated C/QBE,
executables, source and reports remain hot. Exact receipts and failed outcomes
are in [evidence](evidence/).
Maintained source, installed selectors and Phase152 qualification remain unchanged.

There were **31 guarded jobs, 946.94s (15.78 minutes) total guarded time**, with
peak sampled process-tree RSS **1.16 GiB**. The minimum free space during targets
was **5.04 GiB**, above the unchanged reserve. Source preparation, independent
audits, diagnosis of rejected transplants and reporting consumed the remainder
of the approximately 70-minute investigation. This was not 70 minutes waiting
on full compiler qualification. Agent tokens/quota were not available as a
reliable measured counter and are not estimated here.
