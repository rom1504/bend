# Build costs and construction fusion: Phase102

This lane prepares offline experiments. Root alone runs guarded Clang/program
jobs; no active compiler source, installed image or previous raw evidence is changed.
The bounded build screen is closed below; generic construction-loop targets remain pending.

## Generated C is mostly application-specific code

The installed Phase98 B2 products acquired in Phase100 are 555,516 bytes for
image-render, 726,938 for source-index and 748,255 for dependency-plan. Their
complete saved Clang build durations were respectively 4.445, 3.594 and 5.317
seconds; these older single acquisitions are context, not current controls.

The canonical native runtime template is 83,683 bytes. Generated Tables account
for 76–100 KB, Segments for 340–505 KB, and Spins for 55–94 KB. Runtime code is
interleaved with generated tables, inline observers and worker segments. Its
function IDs, constructor IDs, static image, and even `WL_SIG`/`WL_BANK` register
width depend on the program (`tables.bend:nb_bank`). Extracting an independently
reusable runtime object requires an explicit ABI and ownership/inlining decision;
simply dropping its text from a build would not measure that architecture.

## First bounded build experiment

[compact_ids.py](../../selfhost/tools/performance/phase102/build/compact_ids.py)
replaces only declared decimal-encoded generated FID identifiers with collision-
checked compact IDs. A C lexical scan preserves every string, character literal,
comment and non-identifier byte. Inverse renaming reconstructs the original C
exactly. No function, branch or fallback is removed. This isolates identifier
text cost rather than introducing an optimizer or using an application name.
The originating compiler helper is `selfhost/src/back/native/text.bend:nt_fid`,
with table emission at `tables.bend:nb_seg_ids_chunks`.

| Saved product | Original C | Compact C | Removed identifier bytes |
| --- | ---: | ---: | ---: |
| Renderer | 555,516 | 452,041 | 103,475 (18.63%) |
| Source index | 726,938 | 593,542 | 133,396 (18.35%) |
| Dependency planner | 748,255 | 603,394 | 144,861 (19.36%) |

These are measured text sizes from offline Python, not predicted executable or
runtime gains. A modest clean-build improvement is plausible; unchanged build
time would indicate optimization/code generation dominates identifier parsing.
The experiment does not measure the compiler's own cost of constructing these
names; any emission-time gain needs a compiler-emitted implementation later.

[build_cost.py](../../selfhost/tools/performance/phase102/build/build_cost.py)
compares complete original and renamed C under identical Clang C11/O3 flags,
rotates build order and checks full application output against pinned Phase100
oracles. It also includes a deliberately narrow prefix-PCH ablation: the exact
prefix before Tables is compiled as a header, and the exact remaining suffix
is compiled with that PCH. Prefix plus suffix reconstructs the original unit.
This reuses parsed AST, **not a reusable runtime machine-code object**. The
header is roughly9 KB; optimization of runtime/functions is not skipped.

The report keeps three clocks distinct: ordinary full build; header preparation;
and warm PCH compile/link. **Clean PCH total is preparation plus compile/link**.
Every round creates a fresh PCH and reports both clean total and warm reuse.
This tests whether header work warrants an object-split project without claiming
that amortized preparation is free or a cached build is a clean build.

Suggested first root-owned command (two rounds, complete renderer oracle):

```sh
python3 -B selfhost/tools/performance/phase102/build/build_cost.py \
  --out selfhost/build/phase102/build-screen01 \
  --apps image-render --rounds 2 \
  --fixtures selfhost/build/phase100/image-production01/report.json \
  --cases survey-production
```

This is expected to cost about30 seconds from older build durations, plus
supervision. That is a budget estimate, not a measured Phase102 duration.
Root may expand to all three applications only if the first result is useful.

## Further opportunity: eliminate produced-and-immediately-matched sums

Dependency planning creates `DPNext{DPState{...}}` in `dp_step`, returns through
a continuation, then `dp_walk` immediately matches that sum and the next step
unpacks the state again. This survives existing product lowering, whose layout
admission accepts only single-constructor types. `DPUpdate` is a two-way sum.
The saved dependency C has a five-field state allocation around line13288 and
its one-field Next allocation around13321; the walk consumer inspects Next
around12725–12735. This is a real allocation/scheduling boundary rather than
an assumed missing product optimization. A bounded sum-of-products return ABI
or continuation fusion could carry the tag and scalar/owned fields directly.

The offline review is still selecting the smallest general intervention and
ownership controls. A handwritten application rewrite is not a compiler gain;
a prototype must preserve both Done/Next branches, aliases, fuel exhaustion,
cycle diagnostics and complete output. No fusion timing or correctness claim
is made yet.


## Reused branch specialization and generic construction loops

The existing Phase99 selector specialization is retained as exactly its two
original edits: the saturated-call hook and bounded literal-branch helpers.
[prepare_branch.py](../../selfhost/tools/performance/phase102/fusion/prepare_branch.py)
produced the first derivative; the corrected typed-call parent is composed with
root's generic `compose.py --branch` into `typed-branch-source02`. This does not
import Phase99's borrowed views, permission changes or other optimizations.
The parent inverse is exact. Branch specialization is a reused result, not a new
algorithm discovered here.

The next prototype addresses a general restriction: `nf_call_local` admits a
self-call only in tail position. Constructing `Con{head, recurse(tail)}` currently
makes that recursion non-tail and retains a scheduler continuation per element.
The same pattern appears in canonical `String.append`, user `dp_push`/`dp_roots`,
and compiler name-list builders. A generic construction loop can remove those
continuations while retaining the existing linked value representation.

[trmc_helpers.bend](../../selfhost/tools/performance/phase102/fusion/trmc_helpers.bend)
retries only the old `flat worker: non-tail self call` rejection. It bounds source
bodies to512 nodes and arity to1–8, and accepts an ordinary boxed2–8-field
constructor whose final field is a saturated direct self-call. Prefix fields and
recursive arguments cannot themselves mention that self function. Existing
worker readiness still rejects unsupported calls, parallel lets and mutual
cycles. Ordinary ordered lets evaluate prefix fields and recursive arguments in
the original order; this is not map-map fusion or a reordering of predicates.

An inner worker owns two private words: a root and the unfilled final slot.
Each iteration allocates a normal constructor with its last field initialized
to `TERM_HOLE`, links it using the existing `rfc_seal` policy, and updates normal
loop arguments. The terminal value fills the final slot. An outer wrapper exposes
only the existing one-Term result ABI; on failure it sinks the partial root.
No input node is mutated and no incomplete result reaches another thread.
Fresh constructor allocation moves before the recursive body, so exact resource
exhaustion timing is outside the current correctness claim. Existing scheduler
and device fallback remain; the typed02 parent separately needs its known
host-segment marking correction before any promotion.

The first source01 was rejected in source review: `NC_Code.body` requires
`NC_Text`, so the new terminal transfer must wrap its String in `nct_leaf`.
Rejected bytes remain. Corrected source02 is1,772,241bytes, SHA
`5a859fa3cb0e45a795b70c1dc31bfa8c513fd8244e428e44c1a183611478076a`,
with158 added lines/8,692bytes relative to typed-branch-source02. Independent
review verified the source pins and both inverse paths, and found no remaining
root/hole, alias-retain or result-ABI blocker. That is source review only.
No generic TRMC execution or performance result is claimed yet.

[controls.json](../../selfhost/tools/performance/phase102/fusion/controls.json)
registers renamed user append, an unrelated user constructor, empty/nonempty
values, retained shared inputs/suffixes, a30,000-character result, conservative
refusals and a late native Nat overflow. Complete expected output is explicit.
Generated `_trmc` workers must witness positive activation; negative functions
must retain ordinary lowering. Prefix values flattened to `NQBundle` currently
fail the Var-only gate and safely decline; some nested record builders will not
benefit. Final output allocations remain: this optimization removes continuation
traffic, not the observable result list itself.


## Closed build screen: small naming benefit, no PCH win

Root ran `build-screen01/report.json` (SHA
`5a6bbb9254f6a9dad99dcdd220699584a8a3ded783a50e14ab282f915ad18711`)
in 30.16 seconds overall. All six full renderer output checks passed. Two
rotated rounds are a cheap screen, not a precise steady-state estimate.

| Complete renderer build | Round 1 | Round 2 | Median |
| --- | ---: | ---: | ---: |
| Original C | 4.382 s | 4.127 s | 4.254 s |
| Compact identifiers | 4.194 s | 4.063 s | 4.128 s |
| Warm PCH compile/link | 4.494 s | 4.040 s | 4.267 s |
| PCH preparation | 0.258 s | 0.109 s | 0.184 s |
| Clean PCH total | 4.752 s | 4.149 s | 4.451 s |

Compact names reduced the two-sample median build time by about3.0%; warm PCH
was about0.3% slower, and clean PCH about4.6% slower. The unstripped compact
executable was218,920 bytes versus240,800 bytes, partly because symbol names
also shrink. Offline ELF comparison now confirms every allocated code/data section is byte-identical at the same offset and address. Only `.symtab` and `.strtab` differ; the executable-size reduction is symbol metadata, not machine code.
The compact output-check executions were about8.9% slower than the original
checks (.377/.380 versus .346/.349 seconds). These are descriptive checks,
not a clean runtime comparison. Since the loaded code/data are identical, they do not support a generated-code slowdown attribution. The two-round build hint is still too small to prioritize over construction and worker improvements. No PCH or identifier change is selected.

## Successor after the typed-call device correction

`trmc-source03` retains the same reviewed generic delta and composes it onto
`typed-bend-source03` plus only the existing branch specialization. Its source
is1,773,478 bytes, SHA
`ad1567e07c883ce8ad14d4b4e03a09a06998c448ff500581c5020db133410858`.
This parent includes the typed-call host-segment marking correction. Source02
remains the preserved CPU-only predecessor. No canonical append intrinsic is
included, so any structural construction-loop activation is attributable to
TRMC rather than the separate append matcher.


The first actual checked acquisition (`trmc-api01`, consuming source03) rejected
`match xs` nested inside an `nt_choose` closure: Bend requires this pattern
match before local/later-binder operations. No C or program was produced.
Source04 moves only the take/drop helpers to top-level list matches and keeps
all previous bytes in their original artifacts. The versioned helper is
[trmc_helpers-v2.bend](../../selfhost/tools/performance/phase102/fusion/trmc_helpers-v2.bend);
source04 SHA is
`df2101db94e27eb6189e37f79af1c0b18a345902b8777f302aac3507c9eb0782`.
This is a syntax/checking correction, not a measured optimization change.


The offline section comparison is reproducible with
[elf_sections.py](../../selfhost/tools/performance/phase102/build/elf_sections.py);
`build-screen-elf01.json` pins both round-one executable files and the method.
It reads ELF bytes only and executes no generated program.


The corrected source04 passed checked acquisition in `trmc-api02`; the testing
API SHA is `6b249168207fee6db2083243fbf1c369527b7ce5ef495292c316d9d08b071307`.
`trmc-emission02` then emitted all three real applications. Source-index and
image-render each contain one generic `String.append` worker; dependency-plan
also contains `dp_push` and `dp_roots` workers. Emitted code inspection confirms
an ordinary constructor loop and unchanged public one-Term wrapper. These are
activation facts; complete C build/output checks and speed comparisons remain
separate gates.

The same emission batch then rejected the first focused fixture because its
literal local bindings lacked annotations (`main: cannot infer: annotation
required`). The original fixture and manifest remain unchanged. Successor
[controls-v2.json](../../selfhost/tools/performance/phase102/fusion/controls-v2.json)
adds explicit String types to the four construction-fixture locals; all source
algorithms and expected outputs remain unchanged. The checked compiler source
and three emitted application products are unaffected.


The generic constructor-loop mechanism, first 72-execution application screen,
remaining focused-law gates and optional unique-cell reuse experiment now have
a concise companion report: [trmc.md](trmc.md). The screen's composed candidate
improves all six measured points; those ratios include typed-call composition
and retained branch specialization, so they are not attributed solely to TRMC.
