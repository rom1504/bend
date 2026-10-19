# Phase112: direct QBE speed campaign

Status: in progress, 2026-10-19. Work window 00:41–03:41 UTC or later.
The [design](../../design/phase112/qbe-parity.md) defines the frozen comparison,
three ambition levels, resource limits and promotion gates. Production is unchanged.

## First findings

The initial generic lowerer repeatedly scans let suffixes for variable uses. A
backwards persistent use-set pass preserves the complete emitted QBE for six
source inputs and passes 47 independent/differential helper controls. In paired
warm hosted lowering diagnostics, the 64/128/256-statement chains take 0.612/0.184/
0.123 times baseline; lexer/list/U32 fixtures take 0.807/0.942/0.941 times baseline.
These are lowering-only observations, not native compiler or upstream ratios.

The frozen Unicode batch source timed out after 120 seconds under the baseline
native compiler and 60 seconds under its checked hosted API. The liveness
candidate completes staged emission in 13.26 seconds (frontend 2.06; lowering
8.34; verification 1.22). A longer staged baseline failed naturally with a hosted stack overflow after
56.48 seconds inside lowering (60.39 seconds outer wall); no product equality
claim is possible for this source. The transformed product passes native execution.

Direct scalar U32 lowering passes 57 source boundary observations. A first
self-tail-loop planner passes 13 controls but initially admits no loop in the
real arithmetic fixture: an error branch contains a continuation frame. The
revised planner preserves exact terminal failure branches while refusing frames
that can reach a loop. Independent review also found that secondary runtime
buffers must be constrained to scratch, not arbitrary state pointers. Neither
change is promoted solely on source review.

## Evidence locations

Local raw receipts live under `selfhost/build/phase112/` and the explicitly named
`selfhost/build/phase111/p112-*` products required by existing tooling. Full
source/API/input hashes accompany acquisitions. A compact committed evidence
capsule will be sealed at phase completion. Failed timeouts and rejected compiler
checks are retained.

- `liveness-controls01/report.json`: 47 controls.
- `liveness-scaling02/report.json`: paired diagnostics and exact QBE hashes.
- `phase111/p112-liveness-unicode01/report.json`: staged Unicode emission.
- `baseline-acquisition-guard01`: native Unicode timeout.
- `baseline-api-guard01`: hosted Unicode timeout.
- `loops-controls01`: initial loop controls.
- `phase111/p112-scalar-boundary-build01`: native scalar observations.

Disk pressure was reduced by hardlinking 950 authenticated identical generated
files, recovering 1,265,594,368 bytes while retaining every pathname and byte.
All subsequent generated products use fresh paths.

## First generated-program screen

The six frozen Phase93 batch sources now have independently authenticated QBE
products. Three alternating rounds with the separately frozen fast profile yield
these combined-candidate/upstream runtime ratios: lexer35.53, ray211.81, closures
13.86, Unicode6.50, map11.08, numeric15.13; geometric mean22.01. This candidate
has backward liveness, U32 operations, self-tail loops and safe accessors. It
does not include the later private workers or static data. All measured outputs
are exact. These six points are a development screen, not the45-program claim.

The scalar recurrence kernel improves from87.86ms baseline to49.40ms with scalar
operations and5.51ms with the combined loop/accessor changes (0.0627 time ratio).
The representative results demonstrate why that narrow16x win cannot establish
whole-language parity. Continuation/call structure and primitive exposure need
further work.

Private-worker controls now pass native ordered calls, eight-argument transport,
pending continuations and four unique/shared owning loops. The CPU-only fail-stop
adapter preserves actual exit status/stdout/stderr for framed and unframed
failures, bound to exact runtime04 where err_post exits the process. Static-image
controls pass19 checks initially,20 after effect-name exclusion, plus8 native
semantic observations. Images stay capped at65536 words with dynamic fallback.
The original structural verifier remains mandatory.

The first full candidate image built successfully in 289.86 seconds under the
4 GiB process-tree guard (peak RSS 3.12 GB). Its 19 focused native semantic tests
pass. It contains 39,957 generic segments plus 241 private workers, and its QBE
is 44.35 MB. Native self-emission completed in550.531 seconds and reproduced all44,349,671
QBE bytes exactly; QBE/as/link produced the next generation. Its ELF executable
code/data sections match the first image; build-id and nonloaded symbol tables
differ. This is a deterministic bootstrap milestone, not a same-source timing
comparison with the earlier944.818-second Phase111 result. Broad45 and final
selection remain outstanding.

The matched baseline/combined/static screen in `runtime-all01/report.json` shows
a geometric static-candidate/baseline ratio of 0.6633 across the five baseline
products. Unicode remains explicitly missing from that baseline. The six-case
static-candidate/upstream ratio is 21.2194: lexer29.87, ray231.81, closures13.60,
Unicode5.92, map10.72, numeric15.28. All three rounds and exact outputs qualify.
This new QBE route has substantial missing optimization capabilities; these are
not measurements of the mature C backend.

Full-source hosted stages are frontend150.25s, lowering28.62s, verification39.07s,
and emission59.57s. Source differs from Phase111 because new optimizer definitions
are present, so these are diagnoses rather than matched speedup claims. Worker
planning introduced a new emission cost. An optional short-circuit planner passes
18 controls with identical valid plans, indexes and emitted QBE; long rejected
suffix tests take 0.065–0.373 times the old planner. An integrated remeasurement
is still required.

Further candidates are being checked: exact scalar F32 operations, up to32
private owned arguments, bounded continuation fusion, and reuse of mature
selector specialization. Production remains unchanged.


## Qualified composition at01:50 UTC

Fusion03 passes the original source checker, indexed lookup controls, bounded
fusion/refusal controls, and22 native paired builds covering six continuation
fixtures, four wide-call permutations, and104 floating-point observations.
The initial two source-check refusals (pattern ordering, explicit sharing) remain
in the receipts. All successful floating observations preserve upper-word zero;
arithmetic NaNs are checked by class, not exact payload identity.

On the same frozen six-program fast profile, fusion/F32/wide32 takes14.6944x
upstream geometrically, versus21.2071x for static/direct8 in the same campaign.
Per-program candidate ratios are lexer26.875, ray150.806, closures12.421,
Unicode5.130, map9.367, numeric4.161. Every measured output passes. These are
still development-screen results; no upstream-parity claim is justified.

The selector-core adapter passes23 finite admission controls,11 strict/lazy
semantic differentials and eight native fixture observations, including the
required Nat overflow failure and captured/returned closures. One initial test
incorrectly expected admission at the arithmetic limit despite a fresh-ID
collision; the test now distinguishes the budget gate from full admission.

Runtime diagnostics are independently qualified and explained in
[profiles.md](profiles.md). They reveal that U32-to-Word pattern materialization
accounts mechanically for82.14% of the compiler request's heap-allocation calls.
This motivates the next general scalar-pattern adapter, plus bounded composition
of fused private workers. Neither is claimed implemented or measured here yet.

## Representation and call-composition controls at02:00 UTC

The new `word` profile reuses mature `NW_Rows` recognition and selector
specialization before generic lowering. It passes independent low32/F32 raw-bit,
ordered-row, restored-value, fresh-ID and exact-fallback controls. Four checked
source fixtures each pass baseline/candidate native builds and independent full
stdout: scalar/character boundaries, dynamically owned Unicode branches, escaping
31-bit Word tails, and signed-zero/NaN/infinity bit patterns. The first source
check failed a missing local type annotation; that failure is preserved.

The optional `regions` profile composes continuation fusion with private-worker
admission through six immutable ranks. It freezes each first-admitted transformed
body and exact plan; native call dependencies point to earlier ranks. Non-tail
self/mutual recursion retains generic fallback. Five paired native fixtures pass,
including a10,001-iteration local tail loop calling a private leaf and both shared
String release orders. Independent source admission binds278 declarations and
refuses11 mutations. Arity remains8 in this initial prototype; it is not yet a
selected replacement for the wider32-argument worker profile.

The three-input normal prepared-Base compilation screen completed three rotated
rounds for Phase111 N2, first Phase112 N1 and upstream TypeScript/Bun. Request
geometric ratios are0.8355 versus Phase111 and5.5911 versus upstream; ready-binary
stage-sum ratios0.8375 and2.6530. Native emits QBE, upstream emits C, and the
native runtime object is cached while upstream C/Clang recompiles its runtime.
These are configured workflow comparisons, not same-format frontend throughput.
The newer word/selector/fusion profiles are not included in those timings.

A second disjoint authenticated hardlink tier recovered213,897,216 bytes while
preserving1,027 additional artifact paths and all contents.

## Negative fast-screen result at02:03 UTC

The matched `word-regions-runtime01` campaign completes all three rounds and full
outputs. Six-case runtime geometric ratios to upstream are fusion14.2237,
word14.2519 and regions14.2732. Neither new composition demonstrates a material
program-runtime improvement. The word change reduces lexer's QBE from864,663 to
485,244 bytes and static take sites from106 to42, but its actual timed workload
does not establish a speed gain. Regions increases that QBE to597,013 bytes and
adds more private calls without reducing measured time. It remains experimental.

The word-profile full compiler acquisition is justified separately by the actual
compiler allocation profile; this is not a claim that all programs share that
bottleneck. A bounded repeated-fusion extension will test the observed limitation
that an inlined continuation may still contain another frame/call. It must pass
independent sequential-call, lifetime, branch-freshness and recursion/budget
controls before another whole-compiler acquisition is considered.

## Full word-profile compiler and matched comparison at02:12 UTC

`word-source02` checks and acquires N1 successfully. QBE is28,462,589bytes
(SHA256 `bdbf31bcea3c1d99599c896ec48e4fb67430e47b34134c5b834fbed146047617`),
and the executable8,082,216bytes (SHA256
`12caac8e8aecdc873cdd06d6c46f682db88e9e976e5bc2ecd1917544b9020a80`).
Hosted stages are159.18s frontend,29.61s lowering,23.29s verification and27.60s
emission; machine construction4.50s. Complete acquisition plus19 focused native
cases takes272.97s, peak2.762GB under the4GiB cap. All16 positive executions and
three expected source/backend refusals pass. Final self-hosting/corpus selection
is still pending at this checkpoint.

The matched `transport02` screen uses the same fixed three inputs and flags as
transport01, substituting only the qualified word-profile N1. Three rotated rounds
give request ratios0.34461 versus Phase111 N2 and2.38072 versus upstream, and
ready-executable ratios0.35341 and1.14736. Per-input request seconds
(Phase111 / word / upstream): lexer5.334/1.796/0.732; closures3.554/0.976/0.551;
map7.634/3.377/1.088. Ready-executable seconds: lexer5.398/1.867/1.406;
closures3.592/1.013/1.088; map7.778/3.519/2.883. Retain the cached-native-runtime
versus full-upstream-C build-policy difference and distinct QBE/C output formats.

The independent diagnostic [comparison](profile-comparison.md) confirms
heap-allocation calls124,677,389→16,515,651 (−86.75%), all1,625,654 U32 special-takes
and23,670,366 WCon takes gone. Selector composition independently collapses
closure calls2,149,393→3,020 and applies1,075,823→2,599. These composed gains are
not all attributable to the word pass. Instrumented clocks are not benchmark
times. Fixed `p88_field_number` entries stay228,745, while its public QBE body
shrinks668,588→6,886bytes. This removes representation work for unchanged source
computations.

A repeated-continuation prototype passes the source checker and eight paired
native fixtures. The first host-control attempt used a nonexistent `.site` field
instead of `.next`; its failure is retained and a versioned test fixes the field.
An optional32-argument/32-capture overlay retains eight copied sites,128 statements
per continuation and six immutable ranks. Its native qualification and matched
runtime screen are underway; no performance claim or selection yet.

## Native successor checkpoint at02:28 UTC

The word-profile N1 compiles its exact1,990,734-byte source in349.697seconds,
reproduces all28,462,589 QBE bytes exactly and builds N2. Complete guarded wall
is355.248seconds with934,252,544bytes peak RSS. Authenticated ELF comparison
confirms matching headers, program headers and allocated code/data except the
build ID; whole binaries differ. These are self-hosting observations, not a
same-source comparison with earlier Phase111's944.818seconds. N2 focused
semantics and same-source N1/N2/upstream timings are underway.

The repeated/wide screen finished: word14.6533, multi14.6928 and multi-wide14.6605
times upstream across the same six points. No material improvement is selected.
Concrete follow-up inspects post-frame pure assignment gaps; bounds alone did not
remove hot frames. Runtime zero-tail clearing is retained because the current
structural verifier does not establish a valid-prefix-only read contract.

## Pure-assignment fusion at02:34 UTC

Five independent native baseline/candidate pairs and22 structural/refusal
controls pass, including capture redefinitions, frame-result zero, exact32-node
budget and both shared Unicode ownership release orders. Conjunctive source
admission binds322 declarations and refuses30 mutations; word/selector and
scalar/static companions pass separately.

Three matched runtime rounds give word14.8475 versus gap12.3691 times upstream
geometrically (16.69% less time). Median word→gap milliseconds: lexer843→715,
ray4713→2075, closures1349→1344, Unicode239→225, map467→456, numeric133→130.
All complete outputs/counts match. This is the initial six-point screen only.
Actual typed-IR diagnosis confirms332 frozen workers across six ranks; sx/sy
and the isect chain now admit. Remaining nested outer frames still block nearest.

The same-source word N1/N2/upstream screen completes with all fresh outputs
checked. N2/N1 ratios are0.99686 request and0.99728 ready-executable stage sums.
N1/N2 request ratios to upstream are2.45599/2.44827; ready-executable ratios
1.14982/1.14669. Both stages therefore retain the same measured speed within this
small screen's variation. No production B1/B2 relabeling is implied.
