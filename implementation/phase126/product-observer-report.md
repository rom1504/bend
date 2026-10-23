# Product routing: bounded Phase126 result and remaining experiment

The useful change is composition of existing capabilities: a certified borrowed
observer can expose its residual fields through the existing flat product ABI;
its callers can then become ordinary private functions; and an authenticated
native operation can produce those fields without creating a temporary Tuple.
The pure controls alone did not establish this chain. Source27 passed checking
but emitted exactly the old five-program QBE because its shape rule ran too
late. Source32 recognizes the native App before the binding commits to boxing.

The root-run three-round screen of source32 passed all45 output checks. These
are executable internal elapsed-time medians for identical inputs, one CPU
thread, GPU off, with rotating role order:

| Program | Phase125 ms | Source32 ms | Upstream ms | Time reduction vs125 |32/upstream |
|---|---:|---:|---:|---:|---:|
| Record aggregation |684|567|200|17.1%|2.84×|
| Evening |1382|1292|211|6.5%|6.12×|
| Map churn |712|653|200|8.3%|3.27×|
| RLE |1145|1130|202|1.3%|5.59×|
| Lexer |521|504|192|3.3%|2.63×|

Evidence: `selfhost/build/phase126/observer32-screen/report.json` and the pinned
summary `selfhost/tools/performance/phase126/product-primitive/source32-33-inventory.json`.
This is a focused screen, not native self-hosting qualification or a45-program
result. Source32 contains the earlier Phase126 changes, observer closure, SCC
fusion and divmod projection; these numbers cannot isolate their individual
contributions. In particular the disappearance of source26's lexer regression
is a measured property of the later combination, not proof that divmod alone
fixed it. The1.3% RLE difference is too small to present as a robust win from this
screen alone.

## Verified emitted mechanism

`product-primitive/evidence32/` retains exact parent/candidate source products,
function identities, call sites and decoded Map bodies. Three routing programs
contain four calls each to `p126_rt_nat_divmod`; lexer and RLE contain two each.
These are static site counts, not frequency or cost shares.

The active Map path now is:

- `Map.bit` computes full-width quotient/remainder into two scalar words.
- It calls the product ABI of `Map.bit.at`, rather than giving an owning Tuple
  to the boxed adapter and immediately taking it apart.
- The product observer returns its owned root and borrowed observation exactly
  once through the already verified residual field arrangement.
- The boxed public result still constructs its final owning Tuple. The flat
  product version returns the fields directly.

Original input verification, borrowed-layout eligibility, source ownership,
argument evaluation order and final candidate verification remain in force.
The extra runtime helper is additive to the exact qualified Phase125 runtime.
There is no generic cell credit, shared C shape change or global unchecked ABI.

## Exact source32 versus33 experiment

The two authenticated source files differ in one existing declaration,
`p126bp_close`, and five new `p126bo_*` helpers:36 physical source lines net.
Every other declaration is identical ignoring whitespace/comments; the
inventory records both full source hashes. Source33 builds an immutable table
using the existing hygiene/profitability rules, applies existing
`p113i_function` only to names newly admitted by late closure, and preserves
all prior original/borrowed functions. That function already includes the
established scalar/range simplification. Full final verification remains; a
rejected transformed catalogue falls back to the original closed catalogue.

Source33 therefore tests a missing pass-order composition, not a new
optimization policy. Its actual emitted changes and matched runtime/compiler
cost must decide retention. Source32 remains an independent candidate if this
extra work or generated code is worse.

## Ordinary fixture failures are not compiler regressions

The original test attempted to duplicate `Nat & Nat`. Base defines the `&`
notation through `Pair`, which is `Sigma<&1,&1,...>` and has kind Type, so that
shared use was ill-typed. Fixture05 explicitly consumes the linear result into
`Sigma<&2,&2,Nat,_=>Nat>` before observing the reusable Tuple twice. This follows
the existing checked Phase63 shared-Sigma control. Earlier parser, literal and
manifest failures are retained; the independent36-line arithmetic oracle is
unchanged. The fixture checks valid zero divisors, high Nat values, escaping
results and genuine shared product consumption without malformed runtime inputs.

## Next hypothesis, not implemented

The additive helper removes heap allocation but retains a call, a16-byte stack
result buffer and two loads. Its actual runtime-object assembly uses one
hardware unsigned division to obtain both quotient and remainder. A later
verified emission projection could keep the same checked structured helper
contract while computing scalar outputs directly, retaining an explicit zero
branch and full64-bit semantics.

A naive pair of QBE `udiv` and `urem` operations may cause two hardware divisions
and regress. The smallest falsifier must first inspect that machine code; one
quotient division with `r = a - q*b` is an exact unsigned alternative on the
nonzero path. Constant-divisor code quality is another question: hiding33 behind
a runtime ABI prevents caller-side strength reduction, but exposing it does not
guarantee QBE performs that transformation. Benchmark a general ordinary
constant/variable-divisor set, count divisions and call/buffer traffic, and
measure compiler cost before adding this projection. No speed prediction is
justified by the static counts alone.

## Source33 ablation, observed later

Actual emitted catalogue sizes stay unchanged. The existing pass rewrites nine
private bodies in records and eight each in evening/map churn. Map.bit inlines
the product Map.bit.at body, replacing that call with a call directly to product
Map.bit.go. The final owning result constructor is unchanged. String.cmp.fin
inlines two helpers and grows from155 to252 QBE lines; its increased static
constructor/take site count includes code formerly in callees, and is not proof
of increased dynamic allocation.

Lexer and RLE QBE files are byte-identical between32 and33. Their timing
variation therefore cannot be attributed to this pass. Source33's root-run
medians were records567ms, evening1267ms, map643ms, RLE1134ms and lexer508ms;
all45 checks passed. These are separate three-round screens, not a directly
interleaved32-versus33 experiment. The modest evening/map differences do not
yet justify a strong independent speed claim. Retention should consider paired
compiler cost and final validation; source32 is the simpler option if the
small difference is not reproducible.

Reproducible static evidence is in `product-primitive/evidence33/`; the separate
`source33-screen-summary.json` records whole-QBE equality and measured medians.
No new feature was implemented after this ablation.
