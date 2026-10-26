# Native development: qualified checkpoint and incremental experiments

The current qualified research compiler is [Phase137 N3](../../implementation/phase137/README.md).
The commands below preserve the historical Phase134 checkpoint; they do not
silently select a newer executable.

The active optimization effort has returned to cold builds. The
[Phase143 ordinary-native checkpoint](cold-native-development.md) is separately
qualified and reduces a matched complete cold build by20%; installed/selected
defaults remain unchanged. Incremental work below is preserved, with no new
incremental-session qualification claimed by Phase143.

[Phase142 plan: retained units and10×/100× warm-build ambitions](../../design/phase142/README.md)
sets out the next experiment: exact producer change evidence into verifier reuse,
then persistent frontend products and direct unit-to-object construction. It
defines complete-build targets, validation gates, execution priorities and traps.
The [Phase142 execution report](../../implementation/phase142/README.md) records
the reuse prototypes, native warm-edit profile and indexed traversal experiment.
Use its exact artifacts and [reproduction methods](../../selfhost/tools/performance/phase142/README.md);
the installed compiler and qualification boundary remain unchanged.

[Phase140 early incremental sessions](../../implementation/phase140/README.md)
now reuse parser/checker checkpoints, owner preparation, lowered products and
verified/rendered results across real compiler source edits. This is a checked,
experimentally measured native batch path, with exact independent output checks,
not the installed default or a general interactive build service. Its cold
overhead fails the promotion target. See the report for final timings and scope,
and the [batch interface](../../selfhost/tools/performance/phase140/session/batch-README.md)
for bounded reproduction. The10× warm-build objective remains unmet.

[Phase135 real compiler rebuild](../../implementation/phase135/README.md) adds
native compiler-announced object groups and independent current/cold validation.
It is a tested experimental route, **not yet a faster complete edit loop** and
not the selected compiler. Use its [bounded commands](../../selfhost/tools/performance/phase135/machine/README.md)
for experiments; the qualified core remains below.

[Phase134 implementation plan](../../design/phase134/README.md) ·
[Validation gates](../../design/phase134/validation.md) ·
[Execution budget](../../design/phase134/execution.md).
The plan starts with exact-output bounded emission, then reusable owner units,
semantic dependencies, stable binding and persistent preparation. It preserves
the qualified compiler and distinguishes design targets from measured results.

[Phase132 investigation](../../implementation/phase132/README.md) ·
[Go source research](../../research/phase132/go-build-reuse.md) ·
[Experimental commands](../../selfhost/tools/performance/phase132/incremental/README.md).

The [Phase134 report](../../implementation/phase134/README.md) and
[final capsule](../../implementation/phase134/final/README.md) preserve a
native-qualified compiler with streaming output, no-copy writes and reuse of
successful verification for unchanged functions. Its complete source SHA-256 is
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
It does **not** implement an incremental frontend, and the installed selection
has not changed.

| Evidence | Final Phase134 core |
|---|---|
| Same-source sampled peak descendant RSS | 2.918 → 1.009 GB, **65.43% lower** |
| Small request screen, N1 / same-block Phase131 N2 | 0.98166×, **1.83% less time** |
| Separate small request screen, N2 / same-block Phase131 N2 | 1.00255×, **0.26% more time**, effectively flat |
| Final N2 request screen / upstream | 1.41377× |
| Full-source native request observation | 366.836 → 384.281 seconds, **4.76% longer**, noisy concurrent observation |
| Correctness | 59 finite controls; focused19 on N1 and N2; ordinary45 on N2 |
| Self-reproduction and generated code | Exact Q1=Q2; all 45 native benchmark wrappers byte-identical to Phase131 |

The small screens each contain three rotated rounds over Lexer, Closures256
and Map128; their separate windows do not establish a universal speed gain.
The full-source observations overlapped CPU6 correctness work. Sampled
descendant RSS can double-count shared pages. The native wrapper identity bridge
preserves the existing corpus's generated code with the same runtime; historical
Phase131 runtime measurements are reused, not reported as new Phase134 timings.

## Use the qualified core explicitly

From the repository root, compile a source with the qualified N2 image and the
authenticated compact Base carrier. The output directory must be fresh:

```sh
python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p134-selected-n2/program \
  --source /absolute/path/to/program.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase130/my-phase134-request --seconds 60
```

This writes complete raw QBE to `program.ssa` and records input/product identities.
The [capsule guide](../../implementation/phase134/final/README.md) gives the
aligned machine-build command and source restoration instructions. Native
images, runtime and toolchain are pinned workspace artifacts; the capsule itself
archives the checked source and evidence. Use the existing resource guard for
large requests and retain Phase131 as the installed fallback.

## Separate pipe and reuse experiments

The [supervised pipe tool](../../selfhost/tools/performance/phase134/pipe/README.md)
can send native compiler stdout directly into QBE without materializing the
complete textual IR file. For a bounded ordinary request, run:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase134/my-pipe-guard --seconds 75 \
  --rss-mib 4096 --available-mib 16384 --file-mib 256 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase134/pipe/build-v02.py \
  --image selfhost/build/phase111/p134-selected-n2/program \
  --source /absolute/path/to/program.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase134/my-pipe-build --seconds 60
```

Both output directories must be fresh. This produces an executable and a receipt;
it changes no compiler selection. Add `--expected-qbe PATH` for a strict
independent byte-digest comparison or `--expected-stdout PATH` for an ordinary
execution oracle. Without these, successful compilation is not a cross-compiler
equality claim. The pipe's three strict pilot cases used an earlier no-copy N1;
the final core's qualification above covers its file-emission path. Its N2 also
emitted the full experimental session compiler through this pipe: 108.11 MB,
399.72 s emission/QBE, 1.039 GB guarded peak RSS, no QBE file. The original
wrapper refused known assembler warnings; a reviewed exact-object continuation
linked successfully. The warning policy now matches the established builder.
A controlled pipe-versus-file speed comparison remains unmeasured.

The first [owner cache](../../implementation/phase134/reuse/README.md) was rejected
because its hits covered cheap primitives without improving complete requests.
The later [optimization-unit cache](../../implementation/phase134/reuse/cross-edit-units.md)
and [two-revision session](../../selfhost/tools/performance/phase134/session/README.md)
are separate experimental sources, not part of the qualified core. The
[native experiment](../../implementation/phase134/session/README.md) passes
all16 output comparisons and5 refusal controls. Compared with resetting its
cache, retaining state cuts Lexer edited-request time21.32% and complete two-edit
process time9.08%; Map6.12%/2.62%, with more variation. Both modes construct cache
state, so this is not adoption cost versus a cache-free compiler. Phase135 now
tests a full compiler source edit:1387/1507hits, but374.922s warm versus364.183s
through the same image's ordinary entry once. There is no demonstrated adoption
gain. General incremental frontend and native self-reproduction of the
experimental session image remain unestablished.

## Remaining architecture boundary

Phase135 removes the whole-QBE boundary-discovery scan by emitting grouped units
directly from Bend. A real edit reuses56/66 objects; cached/cold loaded machine
images and independent outputs agree. Backend-only replay falls38.906→15.979s,
yet cached replay's full guard16.064s still exceeds monolithic14.699s. Keep the
new bookkeeping cost visible. All current semantic preparation and rendering
remain;62.7% of the full B interval precedes the existing optimization cache.

Phase132 demonstrates exact machine-object reuse after a real one-function
compiler edit. It still runs the entire native source request and scans all
emitted QBE. Do not describe its~6s warm object build as a~6s compiler rebuild.

Use an explicitly pinned qualified native producer and compact Base carrier
for ordinary research acquisition. Preserve independent
source checks, mathematical proof checks when applicable, semantic/ownership
controls and periodic native reproduction. Full JS-hosted compiler execution is
an independent bootstrap/differential/recovery path, not an obligatory step for
every harmless source edit. Riskier runtime/backend changes still need it when
it provides independent evidence.

Measure the complete path: source checking/preparation, analyses/lowering,
verification, rendering/writing, QBE, assembly, link, selected validation and
periodic qualification. Current receipts do not split all internal source phases;
RSS samples and active owners cannot substitute for exclusive stage timers.

The proposed reusable unit is a source owner or recursive group plus its generated
continuations/private workers, represented before numeric FID/CID/static binding.
Its receipt must bind source, consumed definition bodies and semantic summaries,
negative/admission dependencies, producer, policy, runtime ABI and verifier.
Compare semantic-interface and machine-object identities separately. Preserve
symbolic literal and function references until binding so unrelated changes do
not rewrite cached instructions.

The first implementation gate is one real unchanged lowering-unit hit with
complete fresh-reference equivalence. Then challenge callee bodies, constructor
layout, static literals, insertion/deletion, helper admission, policy and ABI.
Unknown dependencies fall back to rebuilding. A mathematical resolution law
could support this narrow boundary; it cannot prove the entire compiler or
replace independent verification.

A changed compiler executable is a new producer epoch. The first cache experiment
keeps the producer fixed; do not silently reuse an old compiler's products after
adoption merely because source text is unchanged. Account for acquisition and
qualification separately from warm edit latency.

Current experimental tools operate on frozen artifacts outside production.
They preserve exact identities, failed attempts and cached/fresh machine
comparisons. None is installed as an alternative compiler or frontend.

## Zig-informed refinement

The [Phase133 research](../../research/phase133/README.md) sharpens this design:
keep compact checked facts and interned identities persistent, but bound and
release function lowering/rendering state. Track dependencies on a type, value,
layout or admission result rather than invalidating every consumer of an entire
definition. QBE itself already processes functions independently, so this can be
tested with the current backend. The proposed near-interactive loop is not yet
implemented; the report separates cold/warm targets and validation costs.
