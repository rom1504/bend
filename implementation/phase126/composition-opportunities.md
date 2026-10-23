# Remaining evening and record composition gaps

Offline follow-up after the Phase126 numeric/local-resume work. No compiler,
target, benchmark or profiler was executed. Retained evidence is under
`selfhost/tools/performance/phase126/machine/composition/`. Its JSON pins current
Phase125 QBE, upstream source/binaries and the historical Phase122 profiles.
The requested 6.76× evening and approximately 3.4× record scores describe the
parent frontier; the profiles below are older and must not be represented as
fresh attribution after the Phase125 helper changes or Phase126 experiments.

## What the samples establish

Across the two retained QBE captures, evening has 1,113 leaf-PC samples and
record256 has 1,118. Evening attributes 23.0% to `work_loop`, `p111_rt_jump`,
`p111_set_regs` and `p111_rt_return` together. Record has a similarly material
control/transport component, plus 6.35% in borrowed field reads, 5.90% each in
take2 and ctor2, 4.65% in ctor3 and 3.94% in take3. These runtime shares are
categories, not per-caller costs. The libc mapping has no symbol attribution;
do not relabel its 8.8–9.5% as memcpy or allocation without evidence.

The earlier primitive-PC audit finds Nat.divmod and checked Nat arithmetic in
map/evening. It does not establish that one primitive accounts for the whole
gap: evening's total generic-op share is 5.93%. Upstream's profiles put a much
larger *fraction* in actual ownership/string/map work after its transport is
cheaper: for example record Map.bit.go and its continuation total 24.95%.
Fractions across differently timed binaries cannot be subtracted to derive
absolute costs. Current runtime helper improvements make that caution stronger.

## 1. A useful observer is trapped behind a boxed primitive result

Current record QBE has an optimized borrowed `Map.bit.go` worker, yet its two
callers remain public scheduler segments:

1. `Map.bit` at QBE line 26893 stores `(pos,33)` into scratch, invokes generic
   opcode70, then jumps through the scheduler to `Map.bit.at`.
2. `Map.bit.at` at line 26795 checks the resulting Tuple, calls `p125_rt_take2`,
   stores its two fields and the key to scratch, then scheduler-jumps to
   `Map.bit.go`.
3. The public `Map.bit.go` wrapper enters the private borrowed observer. Its
   owning adapter at line 266 constructs a `(key,observation)` Tuple afterward.

The actual Phase125 machines retain those calls; see `qbe-map-bit.asm` and
`qbe-map-bit-at.asm`. This is not just verbose intermediate text. Upstream's
`WL_CASE(FID_MAP_BIT)` at `upstream.1.c:5776` carries quotient and remainder as
separate locals with no pair allocation/take, then jumps directly to
`MAP_BIT_GO`. The matching native function starts with a constant reciprocal
multiply by `0x0f83e0f83e0f83e1`, a shift and subtraction to obtain both results.
The ordinary sequential path jumps directly to the routing worker. Its separate
parallel/task path remains in the full disassembly and must not be mistaken for
an unconditional allocation.

This has transfer to records, map churn, evening, number formatting and other
users of primitive product results. It is a narrower opportunity than designing
a new general map observer: the immutable String traversal already exists.

### Exact source barriers, not yet a complete dynamic refusal trace

In the selected assembled source:

- `nq_value_shape` around line 33993 recognizes primitive pairs through
  `nq_pair_primitive`. That predicate includes array/atomic pairs, not
  `nat_divmod`, so a let-bound quotient/remainder does not become an NQBundle.
- `p113p_primitive` around line 45706 accepts only array pairs in a known Tuple
  destination. A forced known pair otherwise returns
  `primitive product shape unsupported`.
- Original `p111v_operator` and `p111q_binop` have no division/remainder operator.
  Inserting raw `N111Bin("udiv")` is not a legal small patch. The existing U32
  division is a post-verification renderer projection with its own zero guard.
- `p113d_pass_function` admits a worker only after all direct dependencies are
  ready. `p118b_compose` inserts borrowed observer workers *after* that closure,
  immediately before final emission. Therefore a late observer does not cause
  its earlier rejected callers to be replanned automatically.

The last point is an observed pipeline ordering, not a claim that it is the only
refusal in Map.bit.at. Product signatures may refer to `$product.Map.bit.go`,
while the borrowed adapter supplies `$direct.Map.bit.go` with one boxed result.
Simply seeding the existing dependency index with that different signature is
not valid. An exact candidate diagnostic is needed to distinguish lowering
errors from missing ordinary/product callees before implementation.

### Smallest decisive experiment and bounded implementation sketch

First use existing `p113pl_inspect_request` to report candidate error, calls,
result count and parameter count for the routing chain and an ordinary renamed
`divmod -> consume-two-scalars` control. This is pure compiler analysis, not a
full native compiler campaign. Add an independently compiled control using
zero/nonzero variable divisors, values around 2^32 and the 48-bit Nat maximum,
with both escaping-pair and immediate-consumption paths.

The minimal representation prototype should extend only QBE's shape decision
and `p113p_primitive` for the verified two-argument `nat_divmod` and exact
`Tuple/Nat×Nat` destination. Reuse existing NQBundle and two-result lowering;
retain `(0,a)` on a zero divisor and the full Nat width. Keep the old boxed path
for escaping/shared/unknown shape. Do **not** globally broaden
`nq_pair_primitive`: mature C's `nq_array_pair` treats its final fallback as an
array operation, so that shared-predicate edit would be wrong.

A total guarded division projection or an explicit exact two-result helper
contract is required; preserve original-source verification and independently
check the derived calls/body. No new general IR or unchecked arithmetic is
necessary, but this is more than adding an opcode to a string list. Start with
the independent immediate-consumer control before adding observer reclosure.

If the routing chain remains unadmitted, the next bounded capability is a
verified flat-result adapter for an already-qualified observer, followed by a
small dependency retry seeded with exactly those new signatures. It must keep
the existing owning root and reconstruct a box at true escape. Do not mutate
the original plan's result count or pretend an owning boxed result is two words.
A generic multi-result local-resume extension is larger and is not needed for
the first falsifier.

Success requires eliminated Tuple allocation/take and one fewer scheduler
transition in the real routing chain, exact complete outputs, and a paired
records/map timing benefit. If only generic division dispatch disappears,
expectation must stay within the small measured arithmetic category. Reject a
larger framework if the independent tuple/control ceiling does not pay.

## 2. Mutual tail helpers prevent a simple digit loop

Current record QBE `U32.show.go` at line 31957 and `U32.show.fin` at line 31767
remain separate scheduler segments. `go` decrements fuel and computes a Boolean,
then jumps to `fin`; `fin` consumes that Boolean, computes div/mod, constructs
one String cell, and jumps back to `go`. The current Nat-take experiment removes
one helper call but does not remove these two per-digit transport boundaries.

The actual QBE `fin` machine has two hardware divisions, plus Char constructor,
SCon constructor and scheduler calls. Upstream `U32_SHOW_GO` source at line 7819
contains the Boolean helper body inside one `WL_SPIN` loop. Its native body has
one multiplication by `0xcccccccd` and a shift, using the quotient to compute
remainder, then a local backward branch. String-cell allocation is still real;
upstream does not magically constant-fold the formatting workload.

A general tail-only strongly connected region is the larger opportunity:
recognize a small closed group of verified tail helpers, map each entry to a
local label, snapshot all outgoing argument words before assigning destination
formals, and preserve all original scalar/ownership operations. No call stack
is needed because every internal edge is a tail transfer. Unknown edges,
continuations/effects and arity mismatches must refuse. A small ordinary
alternating-helper formatter/control plus real U32.show is the fast falsifier;
compare unchanged output and removed register-bank transitions before expanding
to non-tail SCCs. This is broader work than a one-helper patch.

A cheaper independent arithmetic ablation is explicit constant div/rem sharing
inside an already-proved scalar region; preserve zero behavior and width.
It cannot on its own remove the dominant scheduler/composition category.

## 3. One genuinely tiny missing helper projection

The same digit code still calls `p111_rt_special_ctor(kind5,count1)` for `Chr`.
In the pinned runtime this case returns `args[0]` unchanged. A post-verification
load of that exact word, with the original buffer/arity proof and ordered
assignment, is legal without narrowing to32 bits. This is analogous in size to
the current Nat-take projection and transfers to text construction. The matching
kind5 special-take stores the unchanged word and returns1. U32/F32 constructor
cases instead call `term_word`, so they must not be copied into this identity
rule. No timing claim follows from the presence of these calls.

## Recommendation

Prefer the primitive-product/late-adapter diagnostic before a broader map
rewrite. It joins capabilities that already exist, and it exposes an exact
upstream difference in current machine code. Keep the small Char identity as a
cheap separate ablation if useful. Reserve tail-SCC regions for the next larger
control-flow step; do not disguise that work as an inlining-threshold tweak.
Neither the historical profiles nor the static traces justify claiming a
single patch will remove the entire evening or record deficit.
