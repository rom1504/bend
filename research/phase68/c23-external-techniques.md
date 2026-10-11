# Compiler23: mechanisms worth transferring for native runtime parity

Research date: 2026-10-11. Read-only investigation of production source at
`4e0d8c6498b233ba5ef4f053a41c16438f58220b`, containing source candidate23.
The C comparison reference is pinned upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. This lane read compiler source and
primary literature; it ran no Bend, Node, Clang or native benchmark and changed
no production code. New profiles and syntactic counts belong to the companion
investigation, not this research note.

**Recommendation:** recover ownership and representation facts across native
boundaries, then use those facts to avoid work. Upstream already supplies an
especially relevant model: borrowed roots, per-word layouts, local direct
calls and compatible-node reuse cooperate. Our current workers and products
cover pieces of that model, but the generic environment forgets most of it.
Another collection of isolated C spelling changes is unlikely to close the
remaining gap.

The six-family compiler23 result is 1.724× upstream elapsed time, with numeric
and arrays near parity and tree/lexer/closures/Map still slower. These finite
results are recorded in the [current report](../../implementation/phase68/native-facts-and-calls.md).
They do not establish the cost of each missing mechanism. No speedup from an
external compiler is presented as a Bend forecast.

## What this adds to the existing research

This extends [Phase68 world compilers](world-compilers.md), the
[Lean source study](../compilers_architecture_and_techniques/lean.md), and the
[array machine-code investigation](array-after-products15.md). Arity recovery,
ordinary C workers, local joins, product arguments/results and scalar-array
layouts are already implemented; they are not new recommendations.

The additions are a concrete upstream borrow-provenance comparison, a way to
specialize loop state without weakening raw entry demand checks, the
space-safety limitation of indiscriminate borrowing/reuse, and a distinction
between closing the gap and doing less work than upstream.

The web sources below are primary papers, compiler code or official manuals.
OCaml is the versioned 5.5 manual; the GHC 9.15 development source browser and
LLVM/Koka development pages are floating explanatory references, not build
pins. Lean's historical exact source pin remains in the prior study; the fresh
borrow documentation is generated from a moving Lean checkout. Two exact-pin
Lean raw URLs and one GHC 9.4.3 source fetch failed; no new claim depends on
those failures. No external compiler was built or benchmarked.

## The source-level gap is more specific than “missing optimizations”

Paths in this table are relative to the repository. Upstream line numbers refer
to `selfhost/.bootstrap/upstream-phase66/bend2/comp.ts` at the pin above.

| Fact/control mechanism | Pinned upstream | Compiler23 |
| --- | --- | --- |
| Per-word representation | `Val` retains a `Lay`; `lay_c` and `val_owned` distinguish scalar words from owned boxes. | `bridge.bend::NC_Binding` contains only binder ID and C word; `nc_params` makes all generic parameters `N_W64`. Product fields remain ordinary `Term` words. |
| Borrowed-root provenance | `emit_open` lines2179–2190 associates borrowed boxed words with formal roots. `node_fields` lines1583–1617 propagates those roots into projected boxed children. | `nc_keep_uses` emits generic keeps for bindings used on both sides; constructor matching normally consumes through `ctr_take`. There is no borrowed-root field in `NC_Binding`. |
| Interprocedural ownership | `val_own` lines1640–1652 records ownership/lend requirements. `compile_book` lines2777–2816 closes lend edges and repeats until own/hot/static facts stabilize. | Worker admission closes call dependencies, but it does not infer a corresponding parameter-borrow ABI. Checked scalar-array sharing analysis is a separate restricted whole-program proof. |
| Known worker calls from ordinary code | `emit_fuse` lines2149–2174 selects direct native calls at the call site and transports layout-aware results. | `nc_let_cut` creates scheduler continuation frames; `nf_wrap_segments` later replaces admitted entry bodies with host adapters. Replacing an entry does not remove a frame already emitted by its caller. |
| Product state | Upstream carries layout words through values, arguments, results and control joins. | `NQBundle`/`NQShape` handle selected fixed shells. `nq_candidate` refuses a flattened parameter unless `nq_entry_demand` succeeds on every represented prefix path. |
| Reuse | `node_fields` can retain compatible dead-node storage in `Scope.spares`; constructor allocation selects a spare. | Normal matching immediately calls `spare_free` on consumed parent storage; ordinary constructor emission calls `heap_alloc`. The prior narrow spare experiment did not show a large gain. |

The most consequential upstream detail is **ordering and provenance**, not
merely fewer calls named `term_keep`. `emit_args` first evaluates nested
arguments, then removes owned arguments, then reads borrowed ones. A projected
child retains the root that keeps it alive. Copying only its generated fast
loads would omit the legality argument.

## 1. Borrow-aware values and per-word ownership: the broad parity path

Lean's borrow inference starts with borrowed parameters and propagates reasons
that require ownership. A borrower does not decrement its argument, so a caller
that still needs the argument need not retain it before the call. Tail calls
and reset/reuse impose ownership constraints; constructor storage and callees'
requirements also affect the inferred ABI.
[Lean InferBorrow documentation](https://leanprover-community.github.io/mathlib4_docs/Lean/Compiler/LCNF/InferBorrow.html).

**Transfer.** Introduce one native value fact containing layout/kind and an
ownership state: immediate, owned box, or borrow rooted in a live owner. Use it
at argument transfer, projection, branch joins and cleanup. Start with an
admitted ordinary worker whose borrowed arguments are read-only and whose
result contains no escaping borrowed child. Keep public/scheduler fallback
entries. The upstream fixed-point approach is evidence of the necessary
dependencies, not a requirement to repeatedly emit all C in Bend: a compact
worklist could compute the same restricted facts before emission.

**What is already present:** ordered environments, liveness/use summaries,
parent ownership in generic matching, and array-specific width/sharing proofs.
**What is missing:** general provenance through calls/projections and the
distinction between a scalar word and a box at generic keep/drop sites.

**Cheapest discriminator:** choose one current tree or Map hot helper that
reads a value while its caller retains a live owning root. Make a saved-C
borrowed variant with the original consuming entry retained. Separately test
(a) scalar keep/drop removal and (b) boxed borrow propagation; count retained
wrappers, parent takes and allocations, then time unchanged work. These are
different interventions. Reject a candidate whose only change is fewer static
calls that Clang already removes.

**Legality:** borrowed children cannot escape their live root; calls that
capture/store/consume them need ownership; branches must agree on provenance;
parallel/foreign boundaries require explicit contracts. Do not introduce a
cleanup after a tail transfer. Retaining a root longer can increase memory:
measure peak live words and reclamation timing, not just allocator calls.

**Hypothesis:** 1.3–2.2× faster on a genuinely ownership-dominated family,
0–small gain elsewhere. Saved-C proof 2–4 hours; a restricted integrated pass
1–3 days. Confidence is high that coverage differs, medium that borrowing alone
supplies this speedup. Sharing facts and transport elimination overlap with it.

## 2. Constructor-proven loop specialization, without trusting a raw annotation

GHC's SpecConstr specializes calls according to constructor arguments, allowing
an inner recursive path to transport the fields instead of reconstructing and
matching the constructor each iteration. Its source also documents runaway
recursive specialization and bounds on variants/iterations.
[GHC SpecConstr source](https://ghc.gitlab.haskell.org/ghc/doc/libraries/ghc-9.15-inplace/src/GHC.Core.Opt.SpecConstr.html).

**Transfer.** Distinguish a generic entry from an internal loop entry reached
only after the original matcher has consumed a constructor, or from a call
whose fully evaluated constructor fields are compiler-visible. Carry fields
around that loop, materializing a parent only on an opaque/escaping edge.
Initially allow only scalar fields or fields with a separately demonstrated
ownership transition. This is more precise than deciding the whole function
has a flattened ABI based on its declared argument type.

**Concrete opportunity:** compiler23 admits ordinary `lex` after the optional
product worker fails, but that does not make loop-carried products unboxed.
`nq_entry_demand` deliberately includes raw matcher miss paths and refuses
early parent destruction. Preserve that generic path. A constructor-proven
internal specialization can have a narrower valid domain without declaring
all String tags exhaustive or changing when an unrelated parent is dropped.
Whether enough state transitions meet that domain is an experiment, not yet a
proved coverage claim.

**Cheapest discriminator:** rewrite one saved lex loop so its generic entry
performs the original checks and only its validated recurring state travels as
local fields. Compare against both the original and a “direct call only” arm.
Require a per-iteration allocation reduction; then test renamed loop/state
types and a second product-state program before generalizing.

**Legality:** maintain field evaluation order and the original demand point;
do not swap parent destruction for child destruction on an unconsumed path.
Retain invalid-tag, early-drop, shared/array-field and error-polling controls.
Bound variants by constructor shape, not input values, and cap expansion.

**Hypothesis:** 1.3–2.5× on loops whose transient state is a major allocation
source. Saved-C proof 2–4 hours; integration 1–3 days. High semantic risk if
implemented as a relaxed global demand rule; materially lower risk with a
checked internal entry and preserved generic wrapper.

## 3. Direct regions inside scheduler functions

Join-point research makes local control transfers explicit so they need not
allocate closures or duplicate the continuation. Its useful lesson is that
control-flow identity should survive optimization, rather than being recovered
after heap/call lowering.
[Compiling without Continuations, PLDI2017](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/11/join-points-pldi17.pdf).

**Transfer.** Build and validate the ordinary-worker plan before lowering the
scheduler callers. Thread that plan through the existing `NC_Target` context.
For an exact saturated call to an admitted ordinary worker, emit the local
call/result followed by the existing continuation in the current segment.
Keep the fallback segment for device execution where needed. This does not
require converting recursive tree traversals to unbounded C recursion.

**Already present:** local destinations/joins, direct calls between admitted
workers, self-tail jumps, acyclic dependency admission. **Missing:** the
call-site fast path in callers that themselves must remain scheduler functions.
This is the smallest likely integration slice among the broad mechanisms.

**Cheapest discriminator:** take one measured recursive scheduler caller and
splice its existing admitted worker call plus continuation locally in saved C.
Do not alter representation/RC initially. Count the exact frame entries removed
and inspect the resulting assembly. If scheduler samples shrink but runtime
does not, do not expand a context-threading refactor on the basis of counts.

**Legality:** preserve ordered argument evaluation, live owned values, failure
propagation and polling. Admit only existing bounded worker dependencies;
unknown calls, foreign calls, bangs and forks retain the scheduler. Emit a
shared continuation once rather than duplicating a large suffix per branch.

**Hypothesis:** 1.1–1.7× on call-boundary-heavy paths, with little gain if
allocation remains dominant. Saved-C proof 1–2 hours; restricted integration
4–12 hours. It composes with the first two proposals but their gains cannot be
multiplied without measuring combined variants.

## 4. Known closure target plus explicit capture arguments

OCaml Flambda can replace closure variables with extra arguments. Its direct
call surrogate preserves an ordinary indirect-call version while providing a
specialized path for known callers. It also unboxes invariant argument products
and limits transformations that excessively grow captures or compromise tail
calls; additional wrappers can otherwise make indirect calls slower.
[OCaml5.5 Flambda, sections24.9.1–24.9.3](https://ocaml.org/manual/5.5/flambda.html).

**Transfer.** Preserve a local closure's known target and evaluated captures
through simple let bindings and helper return/argument transport. A saturated
known call then uses a private worker signature; allocate a closure only where
it escapes to an unknown consumer. Start with single known targets. Keep
specialization keyed by target, layout and ownership signature, with a bounded
variant budget. A large whole-program points-to analysis is not the first step.

**Already present:** leading/match-aware arity, native lambda lowering and
ordinary workers. These do not prove that a function-valued local has one
target, and workers with unsupported closure paths can still fail admission.

**Cheapest discriminator:** a saved-C explicit-capture version of the closure
benchmark's hot factory/compose path, retaining the original indirect version.
Add two different captures and both escaping/partial uses as controls. Measure
both dynamic apply entries and closure allocations; halving dispatch entries
does not establish a twofold elapsed-time gain.

**Legality:** capture ownership is independent of function identity; preserve
factory prefix evaluation, partial application demand and capture lifetime.
Refuse heterogeneous target joins at first. Count generated machine-code size
and C build time, since indiscriminate duplication undermines simplicity.

**Hypothesis:** 1.2–1.8× on the remaining closure gap; 1–3 hour prototype,
1–2 days for bounded interprocedural support. Conditional gain confidence is
medium; integration risk is medium to high.

## 5. Drop-guided reuse with unchanged-field specialization

Perceus first makes ownership-based drops precise, then specializes drops and
reuse to constructor knowledge. On a unique node it can combine operations so
unchanged fields avoid redundant reference-count traffic and stores.
[Perceus, PLDI2021](https://xnning.github.io/papers/perceus.pdf).
The inspected Koka C pass checks whether fields match the consumed constructor
and applies reuse specialization only when enough assignments are saved; its
fallback still allocates when no reusable node is available.
[Koka ParcReuseSpec.hs](https://raw.githubusercontent.com/koka-lang/koka/dev/src/Backend/C/ParcReuseSpec.hs).

**Transfer.** After ownership/layout facts are available, retain a token for a
dead compatible parent, and reuse it at a reconstruction. In the unique case,
preserve unchanged fields in place rather than extracting, retaining, storing
and dropping them. Map/tree update paths are plausible targets. A reuse token
must carry class/layout and whether the parent was shared; do not reuse a raw
location merely because two constructors have the same number of fields.

**What differs from the earlier experiment:** narrow lexical spare reuse alone
gave small gains. This proposal also exposes which fields are unchanged and
removes their ownership/store round trip. It is lower priority until the new
profiles find that reconstruction pattern dynamically frequent.

**Cheapest discriminator:** one saved-C Map/tree reconstruction with two arms:
spare-only and spare-plus-unchanged-fields. Require correct behavior on shared
input and a demonstrable reduction in dynamic writes/RC, not just heap calls.

**Space constraint:** unrestricted borrow/reuse analyses can keep arbitrarily
large dead structures alive. Drop-guided reuse can bound extra retained storage
by evaluation-frame depth. Keep tokens local and bounded; include deep and
shared structures in peak-memory tests.
[Reference Counting with Frame Limited Reuse](https://www.microsoft.com/en-us/research/wp-content/uploads/2021/11/flreuse-tr-v1.pdf).

**Hypothesis:** 1.1–1.6× on update-heavy paths; 2–4 hour proof, 1–3 days for
restricted integration. Low confidence before a new pattern count. The prior
negative result is a reason to demand stronger evidence, not to rename it a win.

## 6. Producer/consumer elimination: the credible route beyond upstream

Shortcut deforestation removes an intermediate structure by composing its
producer with the consumer. The classic fold/build rule depends on the
producer's restricted polymorphic shape; it is not valid for arbitrary code.
[A Short Cut to Deforestation](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/07/deforestation-short-cut.pdf).

**Transfer.** Look for an entire fresh intermediate list/tree/product whose
only purpose is traversal by a following known consumer. First inline a small
producer into its consumer and simplify constructor/matcher pairs using local
joins; then consider bounded recursive fusion. Preserve the public functions
and apply a general producer-use predicate, never benchmark-name selection.

**Already present:** product-shell forwarding. Eliminating a whole recursive
intermediate is a different transformation. This is promising for beating
upstream only where the upstream-generated program still materializes it;
first inspect that actual C path. No such campaign-wide opportunity has been
established by this research lane.

**Cheapest discriminator:** inventory dynamic allocation sites surviving in
both outputs; choose a single-use producer/consumer witness and eliminate only
that intermediate in a saved-C semantic prototype. Test a second unrelated
producer/consumer and a shared-intermediate fallback before building a pass.

**Legality:** source purity alone does not permit changing error order, bangs,
foreign observations, short-circuit demand or reclamation arbitrarily. Start
with total scalar leaves and explicitly validated sequential traversal order.
Bound code expansion and prevent nested specialization from multiplying work.

**Hypothesis:** 1.5–3× on an allocation/traversal-dominated eligible pipeline,
zero elsewhere. 3–6 hour feasibility proof; several days for a robust general
pass. High risk and low coverage confidence. This is a stretch research path,
not the fastest initial parity fix.

## Why Clang or a new backend will not automatically repair the gap

LLVM's SROA promotes eligible pieces of local aggregate allocations to scalar
values and treats pointer escape as an analysis boundary.
[LLVM SROA implementation](https://llvm.org/doxygen/SROA_8cpp.html).
That supports emitting local C product variables that Clang can optimize.
It does not establish that Clang can reconstruct a Bend constructor's unique
ownership after the frontend has encoded it as indexed writes into a shared
runtime heap, generic keeps, and scheduler transfers. This last statement is
an inference about our lowering, to be checked against actual optimized IR.

A native value-fact layer is useful whether the final syntax is C or LLVM IR.
Switching target syntax before recovering these facts risks preserving the
same excess semantic work in a more complicated backend.

## A small architectural change with several consumers

Prefer augmenting the existing native lowering with three cooperating products:

1. **Worker plan:** admitted direct targets, their private signatures and stack/
   effect constraints, available before scheduler callers are emitted.
2. **Value facts:** representation words, constructor/target identity where
   known, and ownership/root provenance, preserved at local joins.
3. **Bounded specialization key:** function plus proven constructor/closure
   facts; unknown callers retain the ordinary entry.

Do not introduce six independent global passes or another general IR merely
because six techniques are listed. Each fact should have at least two concrete
consumers where useful, and each addition should replace repeated queries or
ad hoc emission logic. A native join must remain a local control transfer until
the backend genuinely requires a scheduler frame.

The first implementation choice should follow the current native profile:
prove one direct-call boundary, one borrow transition and one loop-state
transport in separate saved-C variants. Integration follows a strong result;
it must not precede the evidence in the hope that an architectural rewrite
eventually pays off. A useful threshold is a reproducible ≥1.5× affected-family
gain or a clearly complementary substantial gain across two unrelated
families, with independent outputs and no memory growth.

Parity means deleting excess work visible relative to upstream. A 0.5× overall
result means doing substantially less work than upstream as well. With two of
six families already at 1×, leaving them unchanged would require the other
four to average about 0.354× upstream to achieve a six-family 0.5× geometric
mean. That is why the stretch target needs validated fusion/specialization or
other advantages, not simply optimistic multiplication of parity estimates.

The ranges above apply to affected workloads and exclude full release
qualification. Record native runtime, peak memory, C size/build time,
B1/B2 emission time, raw/checked conformance and source complexity separately.
The strongest immediate research question is **which current ownership or
transport boundary can we remove completely**, not how many additional
optimizations we can name.
