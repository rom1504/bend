# Phase192 independent architectural survey

**Consume the already checked recursive-region plans before making global SSA
the main parity project.** Value identity is a real missing abstraction, but the
current evidence says it is the next foundation for selection and placement,
not the explanation for every large runtime gap. Expression evaluation is the
clearest counterexample: its named x86 evaluation leaf already has approximately
the same absolute sampled CPU as C, while the complete program takes much longer.

This survey preserves the user's requested investigation: compare SSA/global
value identity, dominance/def-use and cross-block optimization; lifetime
splitting/spilling/coalescing; alias analysis, MemorySSA, DSE and SROA; LICM,
induction/strength reduction, unrolling and vectorization; selection, scheduling,
ABI and cost models; and ownership simplification before lowering. Evaluate
runtime breadth, compiler latency/memory, maintained complexity, verification,
passes that can disappear and reuse by future targets. The ambition is 1.5× C
and then parity, without promising either from a favored abstraction. The
smallest falsifying experiment comes before a wholesale SSA or LLVM-like rewrite.

## Scope and identities

Inspected HEAD is `0e2a9d0` on the active branch; production source is dirty with
root's authorized Phase192 work. The qualified baseline is Phase191 `aa7cfa4`,
44-case geometric ratio **2.736569× mature C**. Installed Phase189 is unchanged.
[Phase190](../../implementation/phase190/README.md) and
[Phase191](../../implementation/phase191/README.md) supply the qualification and
negative results. No compiler, benchmark executable, sampler or build ran here.

The offline [method](architectural-survey/derive.mjs) authenticates the five
retained diagnostic inputs and nine tree/expression/lexer ELF products, extracts
two exact typed hot bodies, and retains six physical-profile summaries in
[observations](architectural-survey/observations.json). It also hashes the
inspected active source. It does not rerun the upstream profile recomputation;
that receipt remains [profile-analysis01](../../selfhost/build/phase192/profile-analysis01/report.json).
Fresh static objdump inspection independently confirmed the fold loop below.

Root's [nine-case development screen](../../selfhost/build/phase192/dev-summary01.md)
is 0.919493× baseline, with numeric256 0.514291×; it is not a new 44-case result.
The H-plan prototype, pure-expression/path-fact prototype, and shared-address
controls are active work owned by other lanes. This survey neither duplicates
their implementations nor treats unqualified prototypes as selected behavior.

## Five different hot-region questions, plus Map as a cross-check

| Actual region | Machine/IR observation | Dynamic evidence and implication |
|---|---|---|
| Fold, `$product.fold.loop` | Phase191 `0x4091f5` header and `0x409232..0x40927a` positive body: 23 executed instructions including header/backedge, no call or frame access. Explicit scale multiply, load through a temporary, accumulator copies, store. Diagnostic01 already has hoisted array tag/location/base/size/mask plus a version guard and original fallback. | Old retained row/loop evidence establishes the repeated worker; no new final-product fold sampling was captured here. Nine-case screen remains 2.428× C. This is a dependency/selection/loop-shape question, not evidence of stack spills or absent LICM. C's 15-instruction repeated region covers two elements; do not compare it with one x86 iteration. |
| Numeric, `$direct.p37.numeric` | Exact diagnostic definitions reuse `value` for F32 operation IDs 28,27,28, then U32 multiply, then F32 28, conversion58, U64 xor/self-copy. Phase192 emitted assembly retains three immediate XMM→GPR→XMM pairs after dispatch/staging removal. | Final Phase191 numeric1024 profile assigns 35.37% to runtime op58, 64.49% to recurrence; current numeric256 development timing halves. Those old shares cannot price the remaining MOVD pairs. The newly exposed problem is mixed-definition identity and bank lifetime, not generic runtime dispatch. |
| Tree, `warp` and continuations | Actual x86 warp has 596 static instructions, two jump/two return runtime sites; retained QBE region has 301 instructions and local descend/unwind control. Generic Boolean `warp_leaf.go` is a separate static witness. | Fresh x86 784.03 vs C 165.64 µs/repetition. Anonymous continuations 19.84%, explicit dispatch leaves 15.59%, ctor/take leaves 19.03%; `warp_leaf.go` has zero sampled PCs. Prioritize region/ownership boundaries over a visually dramatic cold Boolean cleanup. |
| Expression, `eval` | x86 public eval has 302 static instructions, three `rt_jump` and one `rt_return`; QBE's region core has 204 and no such core transitions. | Whole x86/C 5.790/2.189 µs; eval leaves 1.166/1.138 µs. Anonymous continuations 33.36%, explicit dispatch 14.43%, with further public-wrapper cost. A scalar allocator-only explanation of the whole deficit is contradicted by this attribution. |
| Lexer, generator and `step.at` | `$product.lex` classification has repeated cmp→Boolean-select→cmp; x86/QBE/C step.at totals are 652/270/315 static instructions. QBE also has a recursive generator region absent from current x86. | Whole x86/C 1967.53/385.77 µs. Classification-containing lex leaf only 8.61%; step.at leaf estimates 119.53/107.22 µs. Generator, wrappers, continuations and dispatch are the larger demonstrated boundary. Whole-symbol size would rank this incorrectly. |
| Map cross-check, borrowed bit and insertion | Bit traversal repeats tag25 after the successful outer check; arity/layout checks remain necessary. Large ins/seek/put bodies contain substantial frame traffic. | Final Map bit leaf 10.958%; ins+seek+put 13.466%; generated frame-memory PCs 3.823% of weighted samples. The latter is neither a stall counter nor a hard saving ceiling. There is no evidence that larger allocation alone is the dominant whole-Map mechanism. |

Exact region/source/ELF links and profile limitations are retained in
[parity-frontier](parity-frontier.md), [allocation-frontier](allocation-frontier.md),
[register-frontier](register-frontier.md), and
[final Phase191 profiles](../phase191/final-profile-assessment.md).
Tree/expression/lexer profiles have 2.06–4.79% unknown weight; Map has 1.84%.
They pass the maintained pooled comparator, not the older extra zero-unknown
rule. Leaf estimates use one clean observation per role and different inlining
boundaries. They identify where to investigate, not removable-time percentages.
No cache misses, branch misses, dependency stalls or memory bandwidth were
measured. The dispatch and continuation groups contain useful computation.

Two particularly useful negative controls survive this survey. Phase191 removed
1,071 argument snapshot sites and 7,036 static stack instructions for only about
0.56% geometric benefit, with Map worse. And Phase192's original shared-address
window of eight missed the real eleven-row fold chain despite finite controls
passing. Root widened that bound to16 with the same mutation certificate; this
does not establish the benefit of a new analysis. The remaining load/add miss
crosses an intervening U32 accumulator copy. A wider textual window and a
definition/use-based selector are competing solutions, not equivalent concepts.

## What primary compiler sources actually support

**LLVM:** machine instructions use virtual value definitions and explicit
register constraints before allocation; calls carry preserved-register masks.
Its separation of high-level machine operations and final MC encoding supports
a shared typed plan, but copying its entire infrastructure is unnecessary.
[Code generator](https://www.llvm.org/docs/CodeGenerator.html#machine-code-in-ssa-form).
GlobalISel selects by following use-def links and can fold producers across
blocks. This is the relevant mechanism for selection independent of adjacency;
it does not prove that Bend needs general cross-block folding first.
[InstructionSelect](https://llvm.org/docs/GlobalISel/InstructionSelect.html).
MemorySSA tracks memory versions and its clobber walker consults alias analysis;
scalar value IDs alone do not justify eliminating loads, stores or ownership
effects. [MemorySSA](https://llvm.org/docs/MemorySSA.html).

**QBE:** its published design deliberately combines a small SSA IL, copy/dead
instruction elimination, conditional constant propagation, small-stack-slot
registerization, loop-sensitive spilling, a separate linear allocator with
hinting, and amd64 addressing selection. It is not a graph-coloring-only design.
The stated performance/code-size ambition is a project aim, not a result for
this corpus. [QBE overview](https://c9x.me/compile/).
Crucially, its frontend accepts mutable temporary assignments and constructs SSA
itself; source IR need not become SSA everywhere at once. That makes an internal
bounded value-plan boundary plausible. [QBE IL, Phi](https://c9x.me/compile/doc/il-v1.0.html#Phi).
But our QBE route also consumes existing Bend recursive plans that x86 ignores.
Therefore the x86/QBE gap cannot be credited solely to QBE's allocator or SSA.

**Rust:** MIR is a typed CFG with statements, terminators and conceptual local
places, rather than a requirement that all source locals already be unique SSA
values. [MIR](https://rustc-dev-guide.rust-lang.org/mir/index.html).
MIR optimizations run after borrow checking, before code generation; generic
optimization can improve generated code and reduce later LLVM work.
[MIR optimization](https://rustc-dev-guide.rust-lang.org/mir/optimizations.html).
The transferable lesson is to preserve and consume language-level semantic
information at the stage where it is available. For Bend, the existing checked
H/ownership plans are stronger evidence than hoping machine passes reconstruct
the same semantic region after runtime calls have obscured it. This is an
inference from the architecture, not a Rust/Bend performance comparison.

**Zig:** its June 2025 x86 default announcement is explicitly for Debug and
reports compiler time, not optimized-runtime parity. The July 2025 AArch64
backend integrates reverse machine selection with its second liveness pass,
allowing folded producers to become unused and reducing deferred-value tracking.
That simplification is described for AArch64, not an already completed x86
rewrite. [Primary 2025 devlog](https://ziglang.org/devlog/2025/).
The useful design question is whether selection updates the liveness actually
allocated, instead of adding cleanup after homes are fixed. Parallel codegen and
incrementality address compiler latency; neither removes a target program's
continuation dispatch. These dated primary reports are used as design examples,
not assertions about every current Zig backend feature.

## Ranked competing hypotheses

Ranks are for this evidence and the next implementation decision. Costs below
are qualitative engineering judgments; no new compiler latency/RSS comparison
was collected. Breadth counts admitted candidate symbols, never dynamic coverage.

| Rank / mechanism | Novelty and supported breadth | Cost, complexity and verification | Simplification / future targets |
|---|---|---|---|
| 1. Consume checked recursive regions | Existing semantic capability missing from x86; QBE has nontrivial region workers in27/44 cases across14 families; fresh hot witnesses in expression/tree/lexer. Active H port tests this. | Medium port, existing planner admission reusable; exact stack/capture/snapshot/ABI/terminal semantics remain difficult. Added local state may initially increase scalar pressure. | Reuses shared plans; removes runtime boundary work rather than another peephole. Can establish a backend-neutral region-lowering contract. |
| 2. Definition identity plus selection before placement | Concrete repeated mutable `value`, predicate recomputation and fold copy boundaries. Broad potential, but measured removable budget still small/unknown outside F32. | Small local slice is medium; full dominance/phi/join/backedge system is high. New indexing consumes compiler memory; repeated list scans or renaming may worsen costs. Exact widths, aliasing of names, last uses and parallel moves must be explicit. | Can replace overlapping scalar alias/expression/predicate scans. Same facts can serve GPR/XMM/select/address consumers and later targets. Identity does not replace ownership/effects. |
| 3. Eliminate ownership/product boundaries before scalar lowering | C exposes constructor/take fast paths; profiles demonstrate real boundary cost across tree/Map. No one proven redundant hot producer/consumer pair selected yet. | Medium-to-high; must preserve reference counts, uniqueness, heap tags, failure and publication ordering. Earlier owned-take inlining regressed, so blanket helper expansion is disfavored. | Actual producer/consumer elimination may simplify multiple backends. Inlining alone can add code and compiler work. |
| 4. Lifetime splitting/spilling/coalescing | False same-name interference is established; nine-color joint and five-register regional fallback already exist. | Medium-to-high if loop/call splitting and publication added. Diagnose rejected hot definitions first; simply raising limits can increase graph cost and frame size. | Reuse value IDs, call masks and edge copies; do not grow a second independent mutable-name allocator. |
| 5. More alias/DSE/SROA | Private staging elimination already demonstrates value; post-conversion numeric has no such staging left. Broad heap alias mechanism has no selected new hot witness. | High general alias/effect burden; compile-time/RSS cost likely larger than bounded private-buffer contracts. | Preserve exact private-memory contracts; add memory versions only for a measured clobber-query bottleneck. Cannot subsume ownership legality. |
| 6. LICM/induction/unroll/vectorization | Fold already hoists representation facts; C folds/unrolls by two. Numeric has true recurrence; no independent SIMD opportunity shown. | LICM/trip/alias/overflow/FP legality and code growth make broad loops high complexity. Small unroll may be testable after selection; it competes with register pressure. | Some shared loop facts useful, but another pass before the selection issue is resolved obscures attribution. No evidence supporting a vectorizer project now. |
| 7. Scheduling/microarchitectural cost model | Instruction dependency chains remain in fold/numeric; no event data proves scheduling, port pressure or cache latency dominates. | CPU-specific models and robust measurements are expensive. Preserve simple legality first. Optional exact-block llvm-mca can test a narrow scheduling hypothesis, not heap/call behavior. | Target-specific cost hooks can remain small; no present justification for a general scheduler. |

The missing H route is visible at
`selfhost/src/back/x86/program.bend:x181_program_public`: it receives
`P134Context{ids,index,direct,ready,view,lookups,heap,mode}` but takes the generic
segment path. This is stronger direct evidence than a checklist of optimizations
industrial compilers happen to contain. Selection should not erase that semantic
opportunity before the machine plan exists.

## Smallest next decisive experiment beyond active work

After freezing and screening the active conversion/H/path/address changes,
test **definition-versioned closed F32 homes**, using the existing float plan.
This is a falsifier for the value-identity hypothesis, not its entire proposed
architecture. It needs no general dominance tree, phi insertion, memory SSA,
loop transformation or globally renamed IR. The existing path-fact prototype
already experiments with immutable IDs for pure expressions; reuse its identity
conventions where appropriate instead of authoring another general numbering
framework.

1. At the float-plan boundary, number each definition; resolve all operand reads
   against the old binding before rebinding a destination. Record bank/canonical
   word facts, exact consumers and rejection reason. Distinguish independent
   definitions of `value` without inflating the GPR allocator's32-name candidate
   set. Calls, unknown joins and Again remain publication boundaries initially.
2. Allocate only already closed F32 lifetimes by definition. Require the three
   immediate numeric MOVD roundtrips to disappear, preserving arithmetic order,
   conversion guards and every required full-word publication. Same-bank copies
   may remain. If no such values qualify, stop: do not relax canonical-word
   semantics or add loop XMM state merely to rescue the experiment.
3. Use independent numerical/word oracles and adversarial mixed U32/U64/F32
   overwrites, in-place operands, alias cycles, high-bit consumers, branches,
   calls, table/budget fallback, NaNs/infinities/signed zeros and deep loops.
   Existing conversion correctness cannot stand in for new placement correctness.
4. Compare identical post-active candidate off/on in root's controlled lane;
   numeric256/1024 and ray variants assess the intended coverage, with integer,
   Map, fold and continuation controls retained. Record compilation time, peak
   memory, source delta and fallback frequency separately. This isolated float
   experiment has no evidence-backed >2% suite forecast. Five explicit F32 cases
   out of44 need about16.3% mean improvement for a2% suite reduction.

The next *generalization*, only after a useful result, is to expose the same
definition/use data to the fold selector: follow its load through the intervening
canonical U32 copy, select the actual memory-add/accumulator home before
allocation, and preserve store order and both uses of the loaded value. Require
that actual hot chain to change; wider-window successes alone do not prove a
shared def-use architecture. Cross-block facts follow only when an observed
remaining consumer needs them.

No new prototype is authored in this survey: root already has three concurrent
bounded mechanisms to evaluate, and an additional unmeasured architecture would
complicate their attribution. The exact IR witness and falsifier above make the
next implementation reviewable without duplicating current work.

## Can one value plan remove overlapping passes?

Yes for scalar facts, conditionally; not for all analyses. The inspected
`function.bend:x186_function_memory` runs private-memory cleanup, predicate
normalization, local-width/copy facts, expression reuse, copy rewriting and
dead-write removal before choosing the float route. `expression-reuse.bend`
separately maintains result/operand-name expressions and aliases;
`x190_v_*` keeps another alias/zero32 environment. Branch selection carries
another predicate certificate. Float placement reuses transient scanning but
globally forbids a name with any noncanonical definition. These are concrete
overlaps and incompatible lifetime scopes, not merely many source files.

A bounded typed value plan can provide definition IDs, canonical widths,
pure-expression identity, uses, edge facts and effects to those consumers. First
replace `x186_e_*` and `x190_v_*` scalar fact reconstruction with the shared
environment; prove preservation of narrowing, source mutation and fallbacks.
Then let predicate and address selection consume it, with dead producers removed
before allocation. Do not delete offset verifier rows merely because addresses
are value-equivalent: they also carry capacity/provenance obligations.

Keep separate contracts for private-memory escape/liveness, ownership, backend
instruction legality, GPR/XMM physical constraints, encoding and the independent
post-placement verifier. The float/integer emitter split currently also loses
some general branch selection; a shared selected-control plan is a reasonable
later simplification, but value numbering alone will not repair it.

The simplification gate is **remove at least one old fact scan on the selected
route while preserving or improving actual code and measured compiler cost**.
Adding a value plan while retaining all old scans is an experiment, not a
maintainability win. On saturation choose the unchanged whole-function route;
never leave half-numbered homes. Branch-local scopes can be bounded; true global
SSA adds merge identities, loop equations and edge-copy placement which need
their own economic case.

Final acceptance remains independent source checking, exact output oracles,
balanced development, frozen held-out and complete44-case measurement, and the required
native acquisition/reproduction and backend/runtime gates. Preserve regressions,
failed experiments, unsupported paths and installed selections separately.
Moving2.736569× to1.5× needs about45.2% aggregate reduction, and parity about63.5%.
Even halving all27 region-covered cases would yield only about1.79× under the
deliberately aggressive assumption that all are hot and all other cases stay
fixed. The existing semantic port and subsequent value-plan cleanup can compose;
neither currently justifies promising the full target.
