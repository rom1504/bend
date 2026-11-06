# Phase169 — early verified interfaces in a native self-hosting compiler

**The repaired experimental QBE compiler builds itself in147.764s**, including
QBE, assembly and linking, in one clean observation. Its native N1/N2 reproduce
the complete QBE, assembly, object and mapped executable bytes. All64 maintained
native qualification cases pass. The150s threshold is reached for the dedicated
1,538,604-byte native compiler source, with only a small single-run margin.

**The unchanged3,085,157-byte canonical source takes185.190s versus244.461s:**
24.25% less complete build time,1.320× speedup. That larger workload has not
reached150s. Do not attribute the source-size difference to compiler speed.
Installed production remains Phase152. No production source, runtime
or selection has changed; the candidate is explicitly selectable by image/receipt.

**The initial route is not an acceptable general replacement:** a six-family
runtime screen subsequently found1.820× geometric slowdown, including19.192×
on edit distance. Output correctness passed. Restoring existing verified array,
ordinary-composition and cold-constructor capabilities repairs the selected
six-family screen to0.982×. The repaired candidate's own147.764s native result
supersedes the rejected image's148.821s result. The final native45 screen is
0.969× geometric runtime versus Phase152, with no measured regression above5%.

## Measured checkpoint

All native builds use the authenticated prepared Base, original serial QBE
runtime, pinned QBE/assembler/linker and one guarded CPU3 execution lane.
Whole build clocks include compiler execution, bounded streaming into QBE,
assembly and linking. Compiler/QBE overlap is not counted twice.

| Producer → product | Exact input | Whole build |
|---|---|---:|
| Qualified Phase152 → experimental N1 |1,503,932-byte native closure|194.820s|
| Experimental N1 → same-source N2 |same closure|154.376s|
| Experimental N2 → same-source N3 |same closure|156.480s|
| Experimental N1 → canonical compiler |unchanged3,085,157-byte Phase152 source|197.355s|
| Fresh qualified Phase152 → canonical compiler |same canonical source|244.461s|
| Previous experimental N2 → single-verifier N1 |1,509,504-byte successor closure|159.160s|
| Single-verifier N1 → same-source N2 |same successor closure|148.821s|
| Single-verifier N2 → canonical compiler |unchanged3,085,157-byte source|187.496s|
| Single-verifier N2 → repaired native N1 |1,538,604-byte final native closure|150.262s|
| Repaired native N1 → same-source N2 |same final closure|147.764s|
| Repaired native N2 → canonical compiler |unchanged3,085,157-byte source|185.190s|

N2 and N3 reproduce the complete84,506,244-byte QBE stream, assembly and object
bytes exactly. This is a bootstrap consistency result, not a correctness theorem.
The fresh same-source baseline reproduces the qualified118,227,421-byte QBE
exactly. The experimental route takes19.27% less complete build time on that
input, a1.239× speedup in these single observations. The later single-verifier
candidate reaches187.496s,23.30% less than the same244.461s baseline, with exact
candidate QBE. The earlier249.222s result
is historical. Do not compare the smaller native closure's154s directly to
the canonical244s.

The final quality repairs preserve all94,447,397 expected canonical QBE bytes,
as predicted by their actual source-certificate gate. Final self-reproduction
has86,387,580 QBE bytes. The native qualification gate passes61 complete outputs
and three exact refusals with no unsupported cases. This is finite qualification,
not full language conformance or a compiler-correctness theorem.

The159.160→148.821s closure rows use identical source, runtime and machine policy:6.50% less
complete build time, with exact84,730,980-byte QBE, assembly and object identity.
Their ELF hashes differ in one non-loaded filename byte; all four executable
sections and all four loadable file ranges are exact. See the
[ELF audit](../../experiments/phase169/elf-reproduction.md).
This combines metadata guards, exact eligibility reuse, lazy admission and the
single final body verifier. It does not isolate their individual contributions.

N1 and N2 both emit the exact independently retained Phase168 verifier QBE and
produce its required768 result. The canonical-source product has the old main
and old algorithms: it is a generated-code transfer workload, **not** another
generation of the experimental compiler. That product emits the exact old
verifier QBE and also produces768.

## What changed

The checked Phase168 route exposes verified callable interfaces before dependent
continuation discovery. Actual forwarders satisfy those interfaces; ordinary
fallbacks, ownership/stack obligations and independent final checking remain.
The new native entry drains its results through the maintained streaming cursor,
using one File for prefix and cursor output. It also incorporates the separately
validated Phase156 publication-provenance improvement, which avoids redundant
canonicalization. That prior improvement is reused, not claimed as a new result.

The canonical product shrinks118.23→94.45MB of QBE and73,926→58,376 functions.
Direct workers remain2,254→2,274;1,150 common direct bodies and the inspected
hot equality/hash readers remain exact. Less duplicated/expanded direct code
accounts for much of the reduction. Static sizes do not prove runtime gains.
See the [source-grounded census](../../experiments/phase169/canonical-product-review.md).

The experimental entry implements the checked single-request QBE protocol.
It does not implement the maintained session/batch commands or establish new
JS/C/parallel/GPU qualification. Source extraction retains the QBE main's
dependency closure; the complete maintained source and other targets remain.

## Transfer and negative evidence

A new469KB workload performs320 real parser/loader/checker calls on ten nonempty
programs, including exact type-error results. Twelve hosted controls compare
complete values against frozen independent Phase156 results and verify the
digest consumer. Eight native runs match the fixed complete output.

Four balanced runtime rounds: baseline median0.362544s, early-interface
candidate0.349252s, ratio0.96333 (3.67% less time). This is one compiler-workload
transfer, not a claim about all generated programs. Its candidate compilation
took42.615s. The first
baseline build hit an underestimated65MiB artifact budget after emission.
Its complete retained QBE was separately rebuilt and output-checked; that
salvage supplies a runtime baseline, **not** a successful whole-build timing.

Four balanced rounds on six preselected timed wrappers against retained
Phase152 products give the following ratios (lower is better):

| Family | Initial native route / Phase152 |
|---|---:|
| editdist |19.192×|
| tree-bitonic |1.141×|
| lexer |1.250×|
| RLE |0.983×|
| Map/set |0.863×|
| raytrace |1.566×|

All48 timing outputs/counts and six acquisition outputs pass; all intervals meet
the timing resolution gate. This is a six-family screen, not the frozen45 result
or a fresh upstream comparison. The geometric ratio is1.820 and mean positive
log-slowdown0.6263. It blocks general promotion. The new route hardcodes ordinary
direct-emission mode and loses the existing verified scalar-array certificate;
ordinary bounded inlining and cold constructor facts are also absent. Restoration
experiments must preserve the original admission checks and isolate each cause.
See the [machine/source audit](../../experiments/phase169/editdist-quality-audit.md).

### Capability restoration

This repair keeps the smaller early-interface pipeline and restores three
semantic capabilities from the maintained implementation. Actual source
certificates authorize array emission; the existing bounded inliner composes
ordinary helpers while every retry/seed owner stays excluded; the unchanged
cold-constructor plan supplies metadata after complete verification. No
benchmark-name rule, raised inlining fuel or omitted verifier is involved.

| Frozen family | Initial native route | Arrays + composition | Plus cold metadata |
|---|---:|---:|---:|
| editdist |19.192×|1.008×|1.000×|
| tree-bitonic |1.141×|1.120×|1.012×|
| lexer |1.250×|0.983×|0.994×|
| RLE |0.983×|0.980×|0.986×|
| Map/set |0.863×|0.860×|0.862×|
| raytrace |1.566×|1.046×|1.047×|
| Geometric mean |1.820×|0.996×|0.982×|

Each column is a separate balanced four-round comparison with retained Phase152
executables, not a ratio to upstream. All48 final outputs/counts pass; all six
timings resolve, positive-log slowdown is0.00954 and none exceeds1.05×.
Candidate emission in the last two columns is independently checked hosted
Bend; native generated-program execution is measured. Subsequent native N2
acquisition reproduces all six complete QBE streams, assembly and objects,
and passes the independent outputs. Full ELF bytes differ in linker metadata;
see the [exact distinction](../../experiments/phase169/native-image-metadata.md).

The repaired editdist hot row is byte-identical QBE to Phase152: the larger
64KB complete computation replaces a6KB body that hid work behind helper calls.
Merely shrinking generated code was the wrong quality signal. Arrays alone
left editdist14.9× slower; composition was essential. See the
[causal code census](../../experiments/phase169/composition-result.md).

The final candidate passes152 finite controls and independent source/body
checking. Its native main closure is1,538,604 bytes, SHA`db744d67…`.
The earlier compiler closure was1,509,504 bytes; this growth and additional
certificate queries must be charged to the new self-build. Source checking
explicitly refuses proof completeness for unsafe/foreign dependencies;
no new BendTT correctness theorem is claimed.

### Final broad native result

All45 catalog programs were acquired using the actual repaired native N2 and
matched their independent outputs. The retained Phase152 products supply the
reference; the reference compiler is not rebuilt. Four balanced runtime rounds
produce360 correct value/count observations. Four very fast cases require the
[predeclared resolution repair](../../experiments/phase169/broad-resolution.md):
the same programs and arguments,40× repetitions for both images,32 further
correct observations. The original incomplete aggregate is preserved.

The [resolution-repaired per-call result](program-runtime.json) covers44 timed
cases and one original correctness-only case:

| Diagnostic against Phase152 | Result |
|---|---:|
| Geometric runtime ratio |0.96896× (3.10% less)|
| Equal-source geometric ratio,23 sources |0.96038×|
| Equal-family geometric ratio |0.95892×|
| Mean positive log-slowdown |0.006459|
| Cases above1.05× /1.10× /2× |0 /0 /0|
| Worst measured case |variation-symreg-4-17,1.03578×|
| Original scale1 fixed-batch median sum |20.231→19.4755s (3.73% less)|

The last row sums per-program measured intervals from the original scale1 run;
it excludes process/harness overhead and does not mix scaled clocks. Individual
small gains/regressions are screening observations without confidence intervals.
This is a comparison to Phase152, not a newly measured upstream speed ratio.

A separate saved-QBE consuming-projection ceiling rewrites84 checked-shaped
branches in the real checker. Ordinary published-state controls and exact full
output pass, including atomic disabled/flag code identity. Four rounds yield
0.364219→0.358888s (1.46% less); ABI-only is0.363756s. This small screen does not
justify a full compiler implementation or a claim about whole-build savings.
No production runtime change was made.

A separate runtime-only experiment passes126 focused state/output controls.
Disabled runtime flags reproduce the qualified object and ELF exactly; atomic
flags reproduce their atomic control. Two reversed verifier compiler-request
rounds improve only2.15% with both changes. This does not justify treating the
runtime tweak as the main architectural result or changing production.

## Profiling and next work

The actual N2 compiler profile preserves exact full canonical output. It has
5,484 samples,99.35% main-thread CPU coverage and zero lost samples. Physical
leaves include destruction/reclamation18.34%, borrowed String equality8.52%,
and take/sink helpers14.99%. These categories are not pass-level savings;
the diagnostic compiler-only176.90s is not a clean whole-build timing.
See the [profile](../../experiments/phase169/native-n2-profile-summary.md).

Guarded metadata lookups, lazy admission and same-book scalar eligibility reuse
now pass100 combined finite controls and exact real verifier QBE. That hosted
pilot is neutral overall; the native combined treatment does not isolate their
individual savings. In particular,
the existing eligibility query constructs an observer body, so caching its
NO_Plan alone does not reuse all that work. Independent source review found no
semantic blocker, but new records have a cost and exact-QBE/performance gates
must determine whether the candidate is worth retaining. See the
[bounded successor](../../experiments/phase169/admission-work.md).

A further candidate removes a duplicate complete body-verifier traversal. The
final flag-only callable view receives the unchanged complete verifier once;
original source/static/adapter and private-input obligations remain. On failure,
the old verification order is replayed for identical diagnostics. Independent
source review supports the success implication,116 finite controls pass, and
the real verifier QBE remains exact. Native self-build now takes148.821s, while
the same-source previous producer takes159.160s. The supplemental six literal
error-order controls also pass. The repaired successor now passes the full64
maintained finite native cases.
This is source reasoning and finite evidence, not a new BendTT theorem. See
the [implementation and obligations](../../experiments/phase169/verifier-single.md).

The next large architectural question is retained continuation construction:
the canonical product still contains44,295 scheduled functions, including37,607
continuations, accounting for77.9% of QBE text. A single recursive computation
with bounded resumable frames could remove construction, analysis, registry and
rendering work together. Text share is not time share; current profiling cannot
justify a20% gain prediction. Obtain new stage/owner attribution before another
rewrite. The equality/ownership micro-experiments do not establish that headroom.

All completed runs are sealed through verified retention. Old, authenticated
intermediates were archived before selective pruning; executables and current
inputs were kept. Keep `quality-native-n1`, `quality-native-n2`,
`quality-native-source01` and their qualification/source receipts available as
the explicit experimental checkpoint. The original Phase152 reference remains.
See [reproduction and explicit image selection](reproduce.md). Source preparation
and transport tools are host scripts; all compiler transformations are checked
Bend modules. This phase adds no host-language compiler implementation.

## Cost, evidence and limits

The [final receipt capsule](evidence/final03/capsule.json) is reopened and
byte-verified. [Machine-readable evidence](evidence/final03/metrics.json) retains
all70 bounded guard outcomes, six unsuccessful targets, exact methods and source
identities. Target-lane wall time totals3245.41s (54.09minutes):

| Root-owned work category | Guard wall time |
|---|---:|
| Native source-to-executable builds, including small gates |34.48min|
| Hosted/native program and pilot acquisition |5.49min|
| Program runtime measurement |5.73min|
| Profiling |3.03min|
| Independent source/API checking |2.77min|
| Controls and other bounded trials |1.47min|
| Final native64 qualification |1.11min|

These mutually exclusive guard categories do not double-count pipelined compiler
and QBE time. They exclude source preparation, agent work, retention and evidence
packaging. Quota/billing telemetry is unavailable; no token-cost estimate or
recursive research-acceleration claim is made. Bounded agents handled independent
source/machine audits, capability restoration and retention proposals; the root
owned the single resource-intensive execution lane.

Final native self-build peak sampled process-tree RSS is757.9MB; the full
canonical build peaks833.0MB. API checking reaches about2.17GB and used an explicit
3GiB ceiling. Every target retained the5GiB disk reserve. Single full-build
observations are not confidence intervals; the OS page cache was not flushed,
and the authenticated Base was already prepared in both compared compilers.

Retained failures include an underestimated checker artifact budget, incorrectly
typed finite-test literals, an invalid timing-budget choice, and the initial
runtime-quality rejection. Metadata-only failures include the overlong39-case
CLI hitting a guard path probe before launch (fixed by a selection wrapper),
overstrict mapped-ELF equality across different filename lengths, and two receipt
packaging errors (null request and relative path). These did not alter compiler
semantics or erase failed measurements. No further target jobs are needed to
reproduce the arithmetic from the capsule.
