# Residual register transport: small copies, not a wide-bank regression

The current final03 compiler has **26 transport words, one result word and
capability5**. The sampled integrated predecessor has those same descriptor
values. Neither uses the historical214-word transport behavior. With the live
bank bit4, `p111_set_regs` copies exactly the outgoing argument count and skips
trailing zeroing. Runtime `WL_READ_STATE` and `WL_WRITE_STATE` also skip their
whole-bank copies. There is no unused full-bank copy to remove in this path.

This is a source/machine audit with no new compiler or native-program execution.
[Streaming census](../../selfhost/tools/performance/phase144/emission/transport/static-v02.json),
[method](../../selfhost/tools/performance/phase144/emission/transport/static-v02.py)
and [machine identities](../../selfhost/tools/performance/phase144/emission/transport/machine-inputs.json)
pin the actual profiled and final03 artifacts. The preliminary v01 census applied
old context-symbol weights to the new image as well; those new-image weights are
not valid because generated continuation names change. V02 uses profile weights
only for the exact profiled image and reports final03 static counts separately.

## The actual cost and mechanism

The existing integrated capture has612 transport samples out of9,158:201 inside
`p111_set_regs`,411 in selected libc leaves whose recovered immediate caller is
that helper. This6.68% belongs to the older integrated N1 diagnostic engine,
not to a fresh final03 or serial-runtime profile. It overlaps active source
contexts and is not additive to source or destruction fractions.

Final03's actual helper still saves three registers, checks the bound and source,
and calls dynamic `memmove@plt` for even a single word. Its return entry calls
that helper after checking result width. Thus a scalar result is stored to a
small generated stack buffer, passed to a runtime helper, and copied through a
second helper plus libc before continuation dispatch. The actual 8-byte movement
is necessary under this ABI; the generic libc dispatch is not.

| Static final03 call shape | Sites |
|---|---:|
| Return1 |27,453|
| Jump1 |5,056|
| Jump2 |11,053|
| Jump3 |3,314|
| Closure apply2 |9,828|

All return sites are scalar; jump counts range1–16. Static frequency is not
execution frequency. Of the612 captured transport samples,240 have an active
public context whose only explicit transition shape is return1,95 jump2 and25
jump1. These are conditional context associations, not recovered dynamic call
arguments. The remaining contexts may contain several transfer shapes. The
largest active owner groups are Patricia insertion46, constructor_exists26,
verifier name scanning26 and parser equality19; transport is distributed.

Relevant unchanged implementation boundaries are runtime.c3932–3973
(frame/set_regs/jump/return/apply), runtime.c418–432 (live-bank macros), and
runtime.h12–20/53–60 (state layout and ABI assertions). The compiler source's
`p111_return`/`p111_jump` at39257–39264 builds explicit scratch transfers;
`p118z_scalar` around51242 rejects arbitrary state-pointer alias/load/store and
requires terminating transitions. Directly writing the register bank in emitted
QBE would require a new independently verified operation; merely bypassing those
restrictions is not a safe optimization.

## Small falsifier with unchanged ABI

The bounded candidate changes only the implementation of `p111_set_regs`:

- Count1 copies8 source bytes into a local `uint64_t`, then writes regs0.
- Count2 copies16 source bytes into a local two-word array before either write.
- All other counts retain the existing `memmove`.
- Admission, NULL/count0 behavior, tail clearing when bit4 is absent, state
  layout, ownership effects, serial RFC mode and compute-worker refusal remain
  unchanged.

Constant-size `memcpy` into local snapshots avoids potentially unaligned typed
loads and preserves overlapping-source behavior. The intended machine effect is
inlined load/store instructions instead of a libc call. This must be inspected
after compilation; source spelling alone does not prove what GCC emits.

`small-transfer02/manifest.json` prepares two modes from the same serial-runtime
source. Mode0 must reproduce the parent runtime object exactly; mode1 enables
the copy specialization. Both relink the identical final03 N2 program object,
so no full compiler acquisition is needed. Each mode runs8,614 independent
byte-snapshot checks over widths2/26/256, every admitted count, capability4 on/off,
aligned/byte-offset external sources, overlapping state sources, NULL/count0 and
exact-read-extent guard pages. Separate NULL1/NULL2/oversize and serial-worker
refusals check the original failure behavior. These checks exercise the actual
included runtime helper, not a copied candidate implementation. The first
prepared manifest's missing `bend:` error prefix was corrected in v02 before
any target execution; the earlier prepared-only evidence remains.

The root-only
[commands](../../selfhost/tools/performance/phase144/emission/transport/copy-commands-v01.sh)
then run three alternating real Lexer compilation pairs, requiring complete
byte-identical QBE from the independent checked final03 producer. No timing
microbenchmark substitutes for this real request. Proceed to the frozen full
compiler source only if the small complete-request result is meaningful.

A plausible exploratory gain is1–3%, with low confidence; the older whole
6.68% category is an upper ceiling even if every transport instruction vanished,
which this change does not achieve. New branches could lose on larger counts.
A negative real-request result should stop this experiment rather than motivate
a new register ABI or a general backend rewrite. More ambitious elimination of
scheduler transitions still requires composition of verified private calls and
continuations; this audit does not establish a cheap universal transformation.

The candidate is prepared, unqualified and unselected until the root-owned
execution receipts and independent source review establish otherwise.

## Executed controls and first real request

Root completed both modes with8,614 full-state comparisons each, exact guard-page
extent checks and all four refusals. Independent libc/source review found no
blocker under the existing x86-64 ABI; the byte-offset cases are an empirical
extension beyond compiler-admitted aligned buffers, not a portable C alignment
proof. Mode0's runtime object **and complete compiler binary** reproduce the
existing final03 serial products byte-for-byte.

[Actual machine audit](../../selfhost/tools/performance/phase144/emission/transport/copy-machine-v01.json)
shows count1 as one8-byte load/store, count2 as two8-byte loads **before either
store**, and all larger counts retaining memmove. Neither small path overreads or
calls libc. The helper keeps its starting address, but subsequent runtime
jump/return/apply symbols move48bytes; layout effects remain a measurement caveat.

Three real Lexer pairs all produced exact independently checked QBE. Baseline
seconds were1.33334,1.45749,1.45729; candidate1.41540,1.39579,1.39559. Median ratio
is0.95780, but paired ratios are1.06155,0.95767,0.95766. The first pair contradicts
a uniform gain; the three-pair geometric ratio is approximately0.9911. This is a
reason to measure the larger real request, not to claim an established4% gain.
The low-level controls and machine evidence establish correctness/mechanism;
request timings establish profitability separately.

The prepared full-source plan is
`selfhost/build/phase144/small-transfer-full-plan01/plan.json`. It uses the same
final03 N2 object, frozen Phase142 input and exact115,966,145-byte final03 reference
`ac29be09…abd36`, against the retained251.861s serial baseline. The baseline
established that new output and did not itself carry a byte-equality flag; the
candidate must byte-match it completely. V01 plan preparation incorrectly
required such a baseline flag and stopped before creating an output; v02 models
that reference-establishment boundary explicitly. No new compiler image
acquisition is needed. A single later candidate is not a paired statistical
campaign; a2% threshold only selects whether further qualification is worthwhile.

[Independent source review](small-register-copy-review.md) pins the actual
candidate and control fixture, with no reviewer target executions. Its requested
machine-extent and baseline-identity checks are separately recorded in the
later machine/build receipts above; the review is not substituted for those
execution gates.
