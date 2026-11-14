# Research economics: transfer must pay for its validation

The current evidence favors first completing a shared generated-code capability,
then measuring its compiler benefit. It does not yet justify a compiler-specific
algorithm rewrite or a claim that optimization research accelerates itself.
Phase193's selected source is frozen separately; the N1 acquisition/cost gate is
pending at this note's evidence cutoff.

## What is measured

The identical Phase192 map/set compiler request costs 4.120591s under QBE-produced
N1 versus 5.684283s under x86-produced N2: a 1.37948× wall ratio despite identical
compiler source, input, Base and output. Admitted physical profiles expose both
string-reader machine work and dispatch/continuation costs. This establishes a
generated-implementation opportunity, not 1.56369s of guaranteed removable work.
Runtime helper shares can change because the backends consume different plans;
shared runtime bytes do not imply equal dynamic call counts.
See [exact request/profile evidence](compiler-profile.md).

The candidate's real compiler-helper kernel improves 49.3172→45.5090ms in twenty
balanced fresh-process pairs (0.922783× wall; 0.921858× CPU). All forty outputs
match the independent full-field digest. The kernel uses unchanged compiler
index/string helpers, but is not a compiler request. Startup and its digest
consumer remain included. The four-case development runtime screen gives
candidate/baseline ratios 0.801869 for map-churn32, 0.950492 for expression32,
0.982128 for tree-bitonic and 0.972507 for lexer: geometric 0.923694×. These are
selected development cases, not held-out or whole-corpus evidence.
[Kernel raw observations](../../selfhost/build/phase193/compiler-hot-timing01/report.json),
[development screen](../../selfhost/build/phase193/dev-runtime01/report.json).

Missing consumption of an already checked public-fusion/ready-tail plan can
benefit both compiler helpers and user programs without a new language-specific
lookup recognizer. That makes a shared consumer a plausible economical first
experiment. It still needs exact fallback, ownership and ABI controls. A
compiler-specific rewrite remains appropriate if a later actual compiler profile
identifies dominant algorithmic work that this machine-code improvement misses.

## Conservative, explicitly conditional break-even

Phase192 recorded 2,785.51s of guarded lane time across 61 jobs, including
387.72s in failed jobs. Its complete self-reproduction observation was 354.521s;
the actual three-request compiler screen improved only 2.83% while full-source
size and historical self-build time increased. Generated-program wins therefore
cannot simply be assigned to compiler throughput.
[Cost ledger](../../implementation/phase192/cost-final.json),
[compiler-cost and build boundary](../../implementation/phase192/README.md#native-qualification-and-compiler-cost).

For planning, charge **3,600s of additional lane work** to a successful research
cycle. This is a round scenario above the previous measured guard total, not a
measured Phase193 total or an estimate of human/agent effort. Count failures,
acquisition, independent checks and reproduction in the eventual actual cost.
Let `g` be a *verified net* compiler-time reduction, and conservatively suppose
only `f = 25%` of future lane demand benefits. Break-even baseline demand is
`C / (f × g)`:

| Hypothetical verified reduction g | Baseline lane demand to repay 3,600s |
|---|---:|
| 1% | 400 hours |
| 2% | 200 hours |
| 5% | 80 hours |

If all demand were instead repetitions of the historical 354.521s self-build
and all benefited (`f = 1`), those scenarios require respectively 1,016, 508 or
204 builds, rounded up. These are sensitivity calculations, **not forecasts**:
neither the gains nor the 25% eligible fraction are established. A nonpositive
net gain has no finite runtime-only payback. Extra maintenance and validation
costs increase the threshold; unmeasured engineering/agent cost is not zero.

The measured kernel alone saves 3.808ms per 1,000-round process at the medians.
Repaying the illustrative hour would require 945,345 such processes. Even the
positive contrast between baseline minimum and candidate maximum is only
0.929ms (3,875,823 processes per hour repaid); that range contrast is not a
confidence bound. This prevents a fast microkernel from being mistaken for
meaningful research-cycle amortization.

## Admission decision

Use the bounded [four-request N1 gate](compiler-cost-plan.md) first: the same QBE
producer/toolchain tests the new compiler source before another expensive N2
build. Only an admitted result plus transferable runtime evidence justifies the
N2 gate, which measures the combined compiler algorithms and new generated
implementation. Keep source/output qualification separate from timing, retain
all cases and failures, and report the fixed-screen scope even after a pass.

The actual research bottleneck may instead be reasoning, fixture repair, source
checking, qualification or storage. Faster target code need not reduce any of
those. No measured discovery-rate increase, shorter complete research cycle,
recursive acceleration, or monetary/token return is claimed here.
