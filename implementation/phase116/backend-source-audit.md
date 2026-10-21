# Phase116 backend source audit

Read-only investigation at `e096a461fa4e9444443811530071ff4ac704f03b`.
No compiler or target program was executed for this note. Static counts below
are not runtime fractions. The root's separate timing/profile campaign owns
new dynamic evidence. The installed compiler and qualified QBE checkpoint are
unchanged.

## Main finding

Some important QBE deficits are **lost mature backend capabilities**, not a lack
of optimization-policy search. Both upstream C and our selected C compiler use
checked scalar-array layouts and direct access. QBE already computes the mature
whole-program scalar/unshared certificate, but deliberately keeps the generic
uniform64 runtime and additionally guards every operation. The missing step is
projecting those facts into a verified per-value representation contract and
coherent storage/access operations; it is not simply adding the existing
certificate again. Borrowed observers and destination-passing constructor loops
are further mature C capabilities that the selected QBE products do not use.

Other mechanisms are different: the recursive tree region still returns a
boxed four-scalar `Stat`, while ray's product workers already avoid `Hit`
boxing but repeatedly transport F32 values through integer words. One generic
"remove the trampoline" change cannot explain or repair all three.

## Exact comparison assets

The pinned upstream is commit
`059266225b77c8ca256ac6b25ee5c21449bab151`, under
`selfhost/.bootstrap/upstream-phase66/`. The current repository HEAD is a
different identity; this audit makes no claim about fresh upstream head.

The matching original45 source and oracle catalogue is
`selfhost/tools/performance/phase112/benchmark45/manifest01.json`. Its source
files are the Phase93 batch fixtures, including argument parsing, repeated
execution and independent output checks. Use those exact bytes for every
backend, including JavaScript.

| Role | Existing products and authoritative identity |
| --- | --- |
| Upstream C/Clang | Catalogue `cases[].upstream` pins source, C, ELF and build; usually `selfhost/build/phase93/broad01/NAME/upstream.1.c` and `upstream.program`; local-pair is under `phase93/pilot02/`. |
| Selected selfhost C | `selfhost/build/phase99/phase102-runtime-products04/report.json` pins producers, current/reused case products and continuity. Per-case `b1/output.1.c`, `b1/report.json`, `clang/process.json`, `candidate.program` exist for the inspected cases. Consult each report's product path because some cases reuse earlier products. |
| Qualified QBE runtime products | `selfhost/build/phase114/final45-plan02-reports.json` points to each emission/build receipt. The eight development cases use `phase111/p114-final-screen01-NAME-{emit,build}/`; remaining cases use `p114-final45-NAME-{emit,build}/`. QBE is `program.ssa`; build has `program.s`, `program.o`, `program`. |
| Installed selfhost JS | `selfhost/dist/typed-api.mjs`, 4,745,566 bytes, SHA256 `284f6e9b88614c4cbd60812a7641fb03d9b9c49892c9bb0d692b1b2c31b5bd30`. Invoke checked `typed-driver.mjs` with `mode:'compile', backend:'direct'` on the exact fixture. |
| Upstream JS | Import the pinned `bend.ts`/`comp.ts`, create/load/validate a fresh book with zero holes, then `C.js_book(book)`. This is the same checked upstream input boundary as the C reference. |

The installed JS Base and pinned upstream Base are byte-identical: 75,064 bytes,
SHA256 `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.
The inspected driver is 86,625 bytes, SHA256
`373eff6b484c0c1ede2b16ab6f3a8da385dacca65616d8321d026611bd62ba82`.
Upstream `comp.ts` is 185,124 bytes, SHA256
`2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c`.

Historical JS products in Phase37–41 are useful source-shape witnesses but use
different fixtures and wrappers. Their old times must not be mixed with the
Phase93 batch timings. Fresh JS emission is cheap compared with another native
self-hosting campaign. The persistent inspector supports only parse/check;
ordinary repeated `D.inspect` calls in one module are the supported compilation
interface. JS receives four program arguments directly, whereas native binaries
also receive `--threads 1 --gpu off --`.

## Three representative computations

### Array fold: a checked layout becomes repeated dynamic admission

In upstream local-fold C, `spin_7` at line 1368 obtains array location/index,
reads a `u32`, and calls `spin_3`, which writes a `u32` and returns array plus
accumulator. Upstream `comp.ts:1758` (`arr_op`) consumes the element `Lay`;
`arr_cells`/`arr_new` select scalar or boxed representation at emission time.
`arr_loc` also supports passing known array locations into private workers.

Our C local-fold and local-pair products both begin with
`NATIVE_SCALAR_ARRAYS 1` and `NATIVE_UNSHARED_ARRAYS 1`.
`native_array_get`/`set`/`swap` use direct locations and compile-time scalar
loads/stores, with no per-element scalar-tag admission on that selected path.
The C proof source is `selfhost/src/back/native/scalar-array.bend`: checked
reachable definitions, exact scalar element demands, conservative rejection of
unknown/proof-transport cases, authenticated effects, and a separate use-based
unshared certificate. Raw `nc_compile` cannot opt into it.

QBE's `phase113/array-fast/model.bend:p113a_certificate` already invokes mature
`ns_definitions` and `nr_unshared`. Its documented policy deliberately preserves
uniform64 storage, generic creation/clone/atomic/drop behavior, and additional
raw/dynamic/scalar guards. Thus this is an incomplete use of established facts,
not an absence of scalar-array admission. These guards cannot simply be deleted
without proving the stronger representation/location contract they currently
enforce.

The Phase114 QBE `$product.fold.loop` at line 1326 is already a
complete flat-result loop, so a missing pair box is **not** its issue. Its 247
QBE lines include repeated ARR-tag, dynamic-location and old-value scalar-tag
checks, mask/address reconstruction, 64-bit loads/stores, scratch/result buffers
and fallback joins. There are five static call sites including cold fallback
and failure paths; these are not five dynamic calls per iteration. The heap
base is already cached. Removing a second heap-base load or merely raising
inlining limits does not recover the missing element-layout invariant.

The old Phase68 integration is relevant prior evidence: typed/unshared scalar
arrays took its C array family to 0.995× upstream, but that historical six-family
result is neither a current QBE speedup nor a prediction for this experiment.

### Recursive tree/list: local control improves, value boundaries remain generic

The selected tree `$direct.scan` at QBE line 13386 is a 145-line closed local
recursive region. A checked `Leaf` match still calls generic `p111_rt_take`,
then `p111_rt_keep` twice for a scalar leaf, then `p111_rt_ctor` for four-field
`Stat`. Return/unwind transports one boxed Term, and a continuation eventually
calls the `stat_join` wrapper. The region removed general dispatcher work but
did not preserve the scalar product through its result and capture ABI.

Our C tree output has explicit `NATIVE_FIELD32` declarations for `Leaf.v` and
all four `St` fields, plus typed scalars, packed constructors and readonly
observers. These are useful established analysis inputs. They do not by
themselves prove that the result object can be removed across recursion.

The list pipeline computes `suma(dbl(keep_gt1(p37.list(...))),0)`. Its selected
QBE `$direct.dbl` at line 9194 has a local descend/unwind loop, but still takes
each cons generically, saves the computed scalar in a continuation, and builds
the output cons on return. Destination passing could remove pending rebuild
frames; producer/consumer fusion could remove intermediate lists. These are
different transformations with distinct strictness, sharing and allocation
ordering obligations. Counting source constructors alone cannot select between
them without dynamic allocation and hot-stack evidence.

Historical upstream JS `scan` is direct recursive property access and returns
an ordinary `St` object; the host optimizer can sometimes scalar-replace such
objects, but the generated JS source does not establish that it did so. Its
native-stack recursion also has a different depth-safety contract from our
explicit continuation stack. Copying that shape blindly would be a regression.

### Ray arithmetic: integer F32 transport survives flattening

Selected QBE `$direct.isect5` at line 1718 takes ten `l` arguments and returns
`l`, even though the checked source parameters/result are F32. Each arithmetic
operation re-enters the float-register representation and produces integer bits
again. The prior exact machine audit found 49 GPR/XMM moves. This is static
instruction evidence, not a measured cost fraction.

Upstream C also represents F32 as `u32` at its generated function boundary
(`lay_c` only emits `u32` or `Term`), so the meaningful difference is how much
Clang sees through inlined bitcasts/calls, versus the conversions and integer
ABI retained after QBE. Upstream JS uses native Number values with explicit
`Math.fround` at operations; its source has no manual integer bitcast after
each arithmetic step. Fresh same-source runtime/profile data is needed to
decide how much these facts matter.

The Phase114 local F32-lane experiment already removed some conversions and
improved active-ray by 12.77%, while retaining integer calling convention.
Its other two nominal numeric transfer programs used integer/fixed-point and
were byte-identical. The untested stronger opportunity is typed **call** and
result transport across a private closed F32 region. `Hit` product boxing is
already absent in the inspected nearest/trace route and should not be blamed.

## Three falsifiable next transformations

1. **Project existing checked scalar-array facts into stronger QBE operations.** Start with one
   scalar-array worker plus shared/static/unknown controls, use a checked layout
   and alias certificate already present, and preserve its consequences through
   complete loops. First separate
   guard elimination on the existing layout from changing to packed 32-bit
   storage; the latter needs creation/copy/clone/drop agreement across runtime
   boundaries. Require the admitted machine loop to lose the specified checks
   and redundant address work, then compare local-fold and local-pair/editdist.
   Highest priority if current profiles confirm array bodies are hot. Small
   proof-carrying loop projection is preferable to globally deleting guards.
2. **Flat scalar-product results across recursive regions.** Make a private
   region result/capture interface a typed bundle, with boxing only at generic
   boundaries. Pair it with typed owned extraction so known scalar fields do not
   call generic keep/take. Start with tree scan and an unrelated expression or
   compiler aggregate. Require no `Stat` allocation/take at internal edges and
   unchanged stack safety/ownership/output. If calls disappear but allocations
   or runtime barely change, stop before extending the region planner broadly.
3. **Keep F32 values typed across private calls.** Recover exact F32 signatures
   before width-only erasure, verify closed flow/joins, use `s` arguments/results
   inside the region and bitcast only at Term boundaries. Freeze NaN, signed-zero,
   infinity and rounding cases with no reassociation/contraction. Require both
   call-boundary move reduction and meaningful ray-family improvement. This is
   a larger follow-up to an already positive local-lane result, not a proposal
   to replace QBE or to erase correctness checks indiscriminately.

None of these static findings justifies promising a 5× whole-suite gain. The
array path is especially actionable because we can reuse a previously qualified
analysis and compare against our own C implementation on identical sources.
Parity should be decomposed into measured workload costs and recoverable
categories; 0.5× would additionally require work elimination or specialization
beyond what the faster upstream products currently achieve.

## Follow-up: matched execution makes reuse of mature optimizations compelling

The root subsequently completed `selfhost/build/phase116/clean01/report.json`:
eight exact Phase93 fixtures, five backend roles, three rounds, complete output
checks. This section reads those root-run data; this audit agent executed no
targets. Selected medians are milliseconds within the unchanged batch program:

| Case | Upstream C | Selfhost C | QBE | Upstream JS | Selfhost JS | QBE / selfhost C |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| list-pipeline128 | 199 | 138 | 1,152 | 594 | 608 | 8.35× |
| map-churn128 | 227 | 143 | 1,965 | 643 | 679 | 13.74× |
| local-fold128 | 201 | 201 | 2,364 | 3,900 | 4,314 | 11.76× |
| active-ray | 217 | 688 | 1,703 | 1,930 | 3,240 | 2.48× |

These compare identical program sources and workload/count contracts but
different compiler implementations/vintages: selected C Phase102 source
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`,
qualified QBE Phase114, installed JS API, and pinned upstream. They are useful
product comparisons, not a controlled ablation isolating a transformation or
machine backend. C's 0.69× and 0.63× upstream list/map times demonstrate that
beating upstream on real existing cases is possible. They do not demonstrate
that QBE will inherit all of that advantage from one change.

### List: destination-passing and reuse are already implemented in Bend

Actual selected C at `phase102-runtime-products04/coverage-list-pipeline-128/`
`b1/output.1.c:2987` emits `p37.list_trmc`; line 3180 emits `dbl_trmc`.
The latter calls `p102_trmc_keep_cell` on the cell returned by `ctr_take`, then
`p102_trmc_take_cell` for the next output cons. A private five-word destination
state carries root, pending field location, one reusable cell and class, and the
pending constructor's sealing policy. The loop publishes a fully initialized
result, frees unused spare storage, and cleans up on failure. It does not build
one continuation frame per reconstructed cons.

In the immutable selected compiler source, the structural admission is
`ntr_eligible`/`ntr_tail_eligible` at lines 39040/39047, with ordered field/argument
sequencing in `ntr_sequence`, destination transfer in `ntr_emitted`/`ntr_transfer`,
cell reuse in `ntr_cached_constructor`, and the corrected cold-parent policy in
`ntr_hole_policy`. Source recipes live under
`selfhost/tools/performance/phase102/fusion/` and `trmc-cold/`. The simple earlier
`trmc_helpers-v2.bend` is useful documentation but predates the selected cell and
sealing corrections; it must not be copied as if it were candidate04.

QBE's selected `dbl` instead saves the multiplied head, descends, unwinds, and
calls ordinary constructor machinery. A structured projection of the existing
TRMC plan could remove those frames and make the consumed cell available for
reuse. This is a stronger concrete opportunity than another isolated call
shortcut. The new times support prioritizing it; only an isolated matched
variant can attribute the measured advantage to TRMC rather than other C/runtime
optimizations.

### Map: borrowing plus worker routing survives in C, but not in QBE

Selected C map output at line 2025 contains `$observer.Map.bit.go`: it reads
String fields through `term_peek`, advances borrowed cursors and returns the
scalar result. At line 2198, `$observer.String.cmp` similarly compares borrowed
String cursors. Its ordinary `String.cmp` worker at line 4543 explicitly forwards
to the owning observer adapter; this matters because merely emitting an unused
observer does not help. The wrapper preserves roots while the observation runs.
The selected QBE program contains no observer-named private workers.

The reusable semantic analysis is `NO_Schema`/`NO_Analysis`, built by
`no_observer_plan` and `noa_analyze` in native `observer-{layout,analysis,plan}.bend`.
It proves return identity, demanded scalar work, permitted descendant cursors,
and closed borrowed traversal. The selected Phase102 `nfo_plan`/`nfo_aliases`/
`nfo_admit` preserve that route through ordinary worker composition.
`nfp_finish` further eliminates only proved pure projections of observer result
wrappers. Sharing and scalar field facts come from `sharing.bend` and typed
`NC_Binding`; they control when sealing/retaining is actually required.

These emitted paths are real capability differences, but no dynamic percentage
of map runtime or single-cause explanation follows from their presence. Inspect
hot stacks before choosing between borrowed comparison/bit observation, typed
tree ownership, and destination-passing String construction. The existing C
product is a useful attainable comparison point even while attribution remains
open.

## A general projection boundary rather than another backend

The proposed common boundary is a **checked semantic region plan before C text
or generic runtime calls**. Reuse existing analyses, but make their result
explicit structured data with original-source provenance:

```
RegionPlan {
  signature: [Word32 | F32Bits | Owned(layout) | Borrowed(layout, owner)],
  result: Scalar | FlatProduct | Owned(layout),
  effects: ordered effects and failure boundaries,
  facts: layout, sharing, return identity, initialized destinations,
  body: ReadField | TakeFields | BorrowLoop | ArrayAccess |
        OpenDestination | FillDestination | ReuseCell | Call | Branch | Return
}
```

This is a proposal, not an implemented new IR. Each operation needs a finite
contract: a borrowed cursor cannot escape its owner; a consumed cell supplies
one reuse credit; a hole cannot escape before sealing; array width/location
facts survive only certified transitions. Generic boundaries box/retain exactly
as before. No runtime primitive string should be the only remaining record of
these semantics.

Implement this incrementally: first extract **one existing** mature plan
(prefer the profiled borrowed observer or TRMC witness), give it a structured
result and lower that result to the existing verified QBE IR. Keep old C
emission as an independent comparison, then move C formatting behind the same
plan only after the first projection proves useful. This avoids porting the C
emitter or rebuilding a second optimizer. It can generalize from list/map user
programs to compiler String traversals and construction, while retaining the
explicit ownership and stack-safety constraints needed for self-hosting.
