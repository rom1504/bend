# Remaining native runtime opportunities: bounded inspection

This is source/machine inspection only. No target, compiler, profile or benchmark
was executed. The coordinator prioritized completing broad evidence over adding
another speculative pass in Phase185.

## Small QBE hypothesis to retain for later

The cheapest concrete omission is scalar lowering for **Nat.sub (primitive63)
and Nat.is_lt (primitive67)**. Their runtime semantics are simply full-width
unsigned saturating subtraction and unsigned comparison. Unlike Nat.add/mul,
they need no `nat_chk` overflow/failure behavior. They can reuse the existing
structured scalar-intrinsic entry, with two snapshotted full64-bit operands,
exact arity, reserved-temporary hygiene and unchanged refusal behavior. Nat.sub
must return0 when `a < b`; Nat.is_lt must return raw0/1. Truncating operands to
U32 or treating subtraction as wrapping would be wrong.

Evidence from actual emitted products:

- Current [Bool/facts map QBE](../../selfhost/build/phase185/bf-qbe-emit01/coverage-map-churn-128/program.ssa) retains6 primitive63 sites and15 primitive67 sites; the constructor candidate retains the same counts. These are static sites, not invocation counts.
- Primitive63 at line1167 is inside the borrowed `Map.bit.go` body, whose baseline physical sample share is12.0%. The retained machine code stores31 and the decremented position in its2048-byte scratch, sets up the generic operation ID/count/buffer, calls `p111_rt_op`, then shifts by the returned result.
- The [same-source C output](../../selfhost/build/phase184/bend-products01/coverage-map-churn-128/bend-c/emission/program.c) expresses this operation directly at line2065: unsigned saturating `31 - position`, followed immediately by the guarded shift. Thus the omission has a concrete C counterpart without changing the map algorithm.
- The current tree product retains only2 Nat.sub and1 Nat.is_lt sites, chiefly wrapper/harness work. Its previous Bool.xor/Bool.or calls are gone. The baseline6.11% tree `p111_rt_op` share must **not** be presented as an available Nat-arithmetic opportunity after Boolean lowering.

The entire baseline map `p111_rt_op` physical share is2.85%. Removing all of it
would yield about1.029× under a deletion-only, unchanged-everything-else model.
The selected Nat operations cover only part of that helper; caller setup/spills
can also change, but were not measured separately. This is a small map-focused
hypothesis, not a route to closing the roughly3.5× QBE/C map gap. No new pass was
implemented. If revisited, edge controls must include0,1,2^32,2^63,UINT64_MAX,
underflow/equality/order reversal, and temporary-name/input aliases.

Another visible constant-divisor opportunity is `p126_rt_nat_divmod` (map
physical share2.84%), including division by33 in `Map.bit`. Its current product
ABI returns through a16-byte output buffer. Exposing constant division and the
two results would require a separate exact full-width/zero-divisor contract and
machine inspection; it was not bundled into the small Nat hypothesis.

## Assembly: the major gap is still within the fast machine loop

The completed [combined-x86 screen](../../selfhost/build/phase185/combined-x86-runtime01/report.json)
has three rotated rounds per role,7 timed points and one correctness-only
zero-work control. Ratios below use its simultaneously measured C denominator;
this selected screen is not the full45 corpus.

| Case | Retained QBE/C | Combined x86/C |
|---|---:|---:|
| local-pair | 1.25× | 25.53× |
| local-fold | 2.02× | 33.18× |
| scalar-region-8192 | 1.72× | 17.92× |
| complete-generic-row32 | 3.72× | 5.80× |
| tree-bitonic | 3.41× | 7.61× |
| map-churn-128 | 3.50× | 7.26× |
| raytrace | 1.14× | 11.83× |

For `p113d_FID_$product.fold.loop`, the positive-iteration path in
[combined x86 assembly](../../selfhost/build/phase185/combined-x86-emit01/local-fold/program.s)
has **156 static instructions,82 explicitly referencing `%rbp`/`%rsp`**. The
corresponding loop in the retained
[QBE machine assembly](../../selfhost/build/phase184/bend-products01/local-fold/bend-qbe/machine/program.s)
has **17 instructions and no stack-register references**. Neither positive
iteration path calls a helper. These are static counts, not dynamic instruction
events or predicted speed factors; address-forming instructions are included in
the stack-reference count.

The x86 body still writes array operation arguments into scratch, reloads them
into individual temporary slots, writes a two-word result tuple, reloads its
scalar field, materializes arithmetic temporaries, and copies loop-carried
values through another scratch block. QBE reduces the same array operation to
indexed32-bit load/store and register arithmetic. The explicit array fast-path
representation is present in both; no source algorithm change is needed to
explain this machine-quality difference.

The preceding array-only profile placed99.844% of sampled CPU in this fast
symbol and none in its `p117v` fallback, with841 accepted samples and full
quality gates. That capture is a different earlier image, so it is not a new
profile of the combined image. Combined assembly independently shows the same
kind of residual scratch/stack traffic. Together these support a future,
separately scoped investigation of **post-expansion stack forwarding and
register allocation**, rather than attributing the scalar gap to fallback,
constructor allocation or generic primitive dispatch. This is larger than a
safe final half-hour patch; the current broad correctness/performance evidence
should finish first.

## Final assembly: fewer direct spills, tuple traffic remains

The completed [final x86 emission](../../selfhost/build/phase185/final-x86-emit01/report.json)
binds its local-fold product to `final-api02`. Its assembly SHA256 is
`0bfe00995af5d2caf3b738ba8047a9b4aa83efeaaaf7d8d6005ebd603143aa6e`.
Static inspection of the same positive-iteration path now finds **150 instructions
and 33 explicit frame-register references**, versus combined156/82 and QBE17/0.
The entire final function has290 instructions and85 frame references; those
whole-function totals include setup, returns and fallback/error branches.

The33 positive-path frame references comprise21 scratch-address `leaq`
instructions,8 direct frame loads and4 direct frame stores. In addition, there
are **10 indirect scratch loads and11 indirect scratch stores** through those
addresses; counting only literal `%rbp`/`%rsp` references would miss them. The
four remaining buffers are:

| Frame base | Contents | Stores / loads per positive iteration |
|---|---|---:|
| `-2408(%rbp)` | Array-get arguments: array, index | 2 / 2 |
| `-2424(%rbp)` | Array-get result pair: array, value | 2 / 1 |
| `-2496(%rbp)` | Array-set arguments: array, index, value | 3 / 3 |
| `-2240(%rbp)` | Next iteration: remaining, index, array, sum | 4 / 4 |

Actual array memory still consists of exactly one32-bit load and one32-bit
store, with no helper calls along the positive path. The array-set expansion
loads its array field into `%r8` and immediately overwrites that register with
the index field. The array-get argument's array field only supplies the
unread field0 of its result pair. These are concrete opportunities for local
scratch forwarding followed by dead-code removal. The loop-state snapshot
requires preserving simultaneous-update semantics; it cannot be removed by
blind sequential substitution.

This inspection supports the assembly agent's separate bounded investigation;
it supplies no new runtime/profile measurement or predicted speedup. The
earlier fast/fallback sample proportions do not become measurements of this
final image.

## Register candidate: four forwarded loads and shorter register arithmetic

The later [register emission](../../selfhost/build/phase185/register-x86-emit01/report.json)
contains local-fold assembly with SHA256
`c54b2aa52ead5fd8790bc25f68e9a1636405c22f82688e60a28077b7de5762d0`.
Its positive iteration falls from150 to**123 static instructions**. This exact
27-instruction difference comprises4 fewer scratch-address `leaq` operations,
4 fewer indirect scratch loads and19 fewer register-move instructions. No
arithmetic, array-memory operation or helper call is removed from this path.

| Positive-iteration count | Final x86 | Register x86 |
|---|---:|---:|
| Instructions | 150 | 123 |
| Explicit frame-register references | 33 | 29 |
| Scratch-address `leaq` | 21 | 17 |
| Direct frame loads / stores | 8 / 4 | 8 / 4 |
| Indirect scratch loads / stores | 10 / 11 | 6 / 11 |
| All stack memory operations | 33 | 29 |
| Native array32-bit loads / stores | 1 / 1 | 1 / 1 |
| Helper calls | 0 | 0 |

The result-pair scalar load and all three array-set argument loads disappear.
The get-argument pair still incurs2 stores and2 loads. The result-pair buffer
at`-2424(%rbp)` still receives2 stores despite having no reads, and the set-args
buffer at`-2488(%rbp)` still receives3 stores despite having no reads. The
four-value loop snapshot retains4 stores and4 loads. Thus forwarding has exposed
five dead tuple stores, while their stores/address calculations remain in the
actual assembly. The whole function changes from290 instructions/85 explicit
frame references to263/81. These counts remain static evidence, not runtime
speed estimates; the full45 measurements below predate this register candidate.

## Full45 runtime: derived breadth and common-work totals

The retained [full45 report](../../selfhost/build/phase185/full45-runtime01/report.json)
is complete with four position-balanced rounds,44 timed cases and the
correctness-only scalar-region-0 control. The separate
[derived metadata](full45-runtime01-analysis.json) pins the source report,
records every calculation and case, and includes the assembly identities/counts
above. All720 retained sample output identities and exact value/count oracles
were checked; the stored summaries and aggregate were independently recomputed.
No new program execution occurred, and the measurement report was unchanged.

Ratios use simultaneously measured C. Equal-family GM gives each of22 families
equal weight after taking its within-family mean log ratio; it differs from
the maintained equal-source metric over23 source groups. Positive log is the
mean of`max(0, ln(role/C))`, so unusually large speedups cannot cancel slow cases.

| Metric | Retained QBE | Candidate QBE | Candidate x86 |
|---|---:|---:|---:|
| Case GM / C | 1.55570 | 1.49599 | 5.98203 |
| Equal-family GM / C | 1.65571 | 1.60318 | 5.73536 |
| Mean positive log slowdown | 0.64152 | 0.61972 | 1.82733 |
| Cases above1.1× C | 34 / 44 | 32 / 44 | 42 / 44 |
| Cases above2× C | 22 / 44 | 21 / 44 | 40 / 44 |
| Projected fixed-batch sum, seconds | 19.5815 | 18.6109 | 76.3169 |
| Net fixed-batch excess over C, seconds | 9.4227 | 8.4521 | 66.1581 |
| Positive-only fixed-batch excess, seconds | 9.9046 | 9.1776 | 66.2277 |

The common fixed workload uses each frozen catalog repetition count multiplied
by the observed median milliseconds per invocation; C totals10.1588 seconds.
These are projections for equal work across roles, not sums of the differently
calibrated measured batch durations or end-to-end campaign wall time.

Candidate QBE improves the case GM by3.84% and the projected fixed-batch total
by4.96% relative to retained QBE. It is faster on25 cases, slower on18 and equal
on1. The largest observed regressions are editdist-3-123(+4.85%), closures-64
(+4.04%), local-fold-128-0(+2.83%) and local-fold(+2.57%); none exceeds5% in
this run. These descriptive medians have no statistical confidence claim.
The largest improvements include expression-128(-20.70%), expression-32
(-19.91%), active-ray256(-14.94%) and bst-32(-14.10%).

The remaining worst QBE/C ratios are complete-generic-row32(3.75×),
evening-program(3.62×), map-churn32(3.61×) and map-churn128(3.44×). The assembly
candidate remains farthest behind on local-fold variants(16.10–18.60×) and
editdist-3-123(15.14×). This full45 report measures `final-qbe-programs01` and
`final-x86-programs01`; it cannot establish full45 performance of the later
register candidate.

## A composition gap exposed by the new F32 lowering

Source observation: `x185_float_probe` recognizes binary F32 calls and emits SSE,
but this happens in the final scalar renderer. Earlier `x185_t_scalar` still
sees `N111Call` and conservatively ends the transient-register region and blocks
call operands/destinations. Likewise local stack forwarding treats it as a call
barrier. The optimizer therefore forgets that the eventual instruction sequence
has no machine call and does not write its input buffer. This is not evidence
that removing these boundaries is automatically safe or faster.

A high-value next experiment is one shared, exact inline-operation/effect summary
used by admission, register lifetime analysis, scratch analysis and emission.
The summary must describe buffer reads, written result, scratch register use,
width/NaN contracts, and the original fallback. It must become unavailable when
the emitter cannot promise the inline path. Unknown calls retain every current
barrier. Preserve executed FP operations and observable ordering; do not infer
arbitrary call purity from names.

Test an extracted ray/numeric loop and an unrelated numeric recurrence, using
the existing95 numeric controls plus values live across the inline operation.
Compare actual loads/stores and clean runtime. This could remove an entire class
of artificial register boundaries without a new universal IR. Its runtime gain
has not been measured. The current release candidate is frozen; this is a next
experiment, not an implemented or qualified Phase185 optimization.

The other bounded assembly experiment is parallel-move resolution on `Again`.
The inspected fold retains four stack snapshot writes and four reads to preserve
simultaneous loop-argument assignment. Identical source/destination homes and
acyclic moves can potentially avoid those transfers; cycles need an explicit
scratch rule and the existing path remains the fallback. Test permutations,
cycles, stack/register mixtures, repeated source values, setup invariants and
full-width words before enabling it. This is standard machine lowering, not a
claim of a new compiler-theory result. Neither it nor dead scratch-store removal
is implemented in Phase185.
