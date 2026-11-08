# Phase179 — comparable complete checked self-builds

The fresh complete-build comparison is **175.66s for ours/QBE versus68.78s for
historical bendc/C:2.55×**, not the apparent180s/10s comparison. However, the
compiler-to-IR gap remains large: **150.92s versus8.49s, approximately17.77×**,
on their different own-source workloads and different output abstractions.
Correcting the measurement boundary does not explain away our compiler cost.

[Design](../../design/phase179/README.md) · [Metrics](metrics.json) ·
[Reproduce](reproduce.md) · [Exact evidence index](evidence-index.json).

## Measured complete operation

Each existing native compiler checks its own source and produces a fresh complete
native executable. Both use reusable runtime objects, one worker, GPU off and
CPU3 on the same Intel Xeon E3-1245 V2 host. Every program IR and machine object
is rebuilt. Processes are fresh; filesystem caches are not flushed.

| Complete checked source-to-executable | First | Second | Median |
|---|---:|---:|---:|
| Historical bendc, C/Clang-O2 | 69.470s | 68.098s | **68.784s** |
| Our Phase177 N1, direct QBE | 173.690s | 177.634s | **175.662s** |

Order is bendc/ours/ours/bendc. Two observations per route provide a practical
recheck, not a confidence interval. This is a fresh comparison, not an
optimization claim against earlier176.9s results, which used a different frozen
source input.

## Where the time goes

bendc's actual checked `-o` CLI spends8.500/8.487s getting through source loading,
checking and C emission to the measured CC invocation. Clang compilation/linking
takes60.944/59.585s. Thus machine construction is about88% of its full-build
median. The separately acquired cached runtime took0.967s; it is not charged to
each subsequent build. No program-specific C/object cache is used.

Our maintained pipeline streams QBE while QBE constructs assembly. Its combined
compiler/QBE intervals are167.730/171.622s; these are overlapping process
intervals, not pure compiler times. A separate serial source-to-QBE request with
the same N1, source, Base and full output oracle takes **150.921s**
(150.810s child CPU). This directly measures compiler work rather than deriving
it by subtracting unrelated timings.

The serial machine-only replay takes **13.937s**, including8.097s QBE,
4.657s assembly and0.243s linking, with normal bookkeeping/hash overhead.
These times must not be added to a component of the streaming runs or treated as
a third complete-build observation. The serial diagnostic sum is164.858s,
below the175.662s streaming median. That is a useful scheduling/transport
follow-up, not a demonstrated6% improvement: it is one separately staged run,
with different materialization and execution scheduling, not a paired policy
experiment. Do not attribute the difference to QBE optimization itself.

The headline ~9s historical bendc measurement was checked **C emission**. It did
not include Clang. We now measure the actual complete CLI instead of estimating
its cost by adding an old seed-acquisition time. This does not reproduce or
disprove bendc's separate few-second AArch64 direct-native build claim: this
machine and experiment use x86 C/Clang.

## Identity and comparability

Historical bendc is exactly `9c54842eb5756803af599583ca49870d1e09186a`, with the
same pinned Base2.0.32 and original seed from Phase158. The actual CLI's
`Main.run4`, lines19522–19530 in that source, calls `Main.check` before emission
and `Cc.end`; this is not `--no-check`. A transport-only CC wrapper captures the
temporary C before deletion and measures the actual pinned Clang command.
Its startup/copy overhead is included in full CLI time; the2.8MB copy itself
takes about2ms. Seed and historical runtime inputs remain unchanged.

Ours executes Phase177 N1 on its exact own Phase177 source. The current Phase178
source cleanup has no new acquired executable and is not silently substituted.
Our prepared Base is reused; bendc checks Base live. This setup-work difference
favors ours. Both rebuild the complete user source. The pinned compiler sources
are3,174,925B for ours versus1,173,696B across bendc's six loaded modules,
excluding Base. These are different programs, language revisions, optimizers
and runtime policies. Source bytes are not a justified linear normalization.

Our output is98,163,162B QBE versus2,802,777B C from bendc. These are different
abstraction levels; the35× textual size ratio is neither an instruction count
nor an established causal explanation. Our executable is16,129,616B versus
3,169,648B for the newly built bendc executable, without an equal-feature or
equal-generated-runtime-quality claim.

The maintained our-builder clock includes normal pipeline bookkeeping and
post-build identity checks after preflight; bendc's CLI clock excludes the
harness's later oracle check. All exact scopes are retained. These small harness
differences do not justify claiming a perfectly equal-work throughput benchmark.

## Independent evidence and limits

Both bendc builds emit exactly the independent committed seed C. Both our
builds emit the complete exact QBE independently generated earlier by Phase175
N2, including its98MB digest. Repeated assembly and object products also agree.
Whole ELF hashes differ; no whole-ELF reproducibility claim is made.

After the timed builds, the newly built bendc checks/re-emits its entire own C
and must match the committed seed. Our newly derived N2 compiles the frozen
`focused/nt-reverse` input, matches its prior QBE oracle, and builds/runs the
result against the prior exact stdout. These bounded executable checks validate
the measured products; they do not replace a broad qualification campaign.
Source acceptance, independent semantic tests, reproduction and mathematical
proof remain different properties. Installed Phase171 and the qualified
research references are unchanged.

## What this teaches us

The full-build gap is materially smaller than the original comparison implied.
QBE machine construction is not what makes our **compiler process** take151s.
bendc hands more machine-level work to Clang after quick C emission; our compiler
has already done extensive lowering/optimization and emitted a lower-level
program. Different source complexity and generated execution models remain
confounded with compiler algorithms and runtime overhead.

The useful next question is still which work our compiler performs that bendc
avoids. Today's measurements establish its magnitude, not a new causal
decomposition. Reuse the same-source execution-engine controls from Phase160
and the source/work audits from Phases161–166; do not interpret the17.77× as a
universal throughput multiplier or divide it mechanically by source size.
A high-value next experiment would measure equivalent retained semantic work
on a common supported source, then test elimination of a whole representation
or traversal category with exact outputs. Another full image build without
such a discriminator would add little information.

Nine guarded jobs took673.412s of target-lane wall time (11.22minutes), with no
failed jobs. Four complete builds dominate that cost. One bounded read-only
agent audited the bendc CLI/cache method; the root owned all target execution.
The verified1.34MB archive contains94 evidence files. These counts exclude
agent reasoning, metadata inspection and documentation time.

No compiler source, target policy or installed selection changed. The new Python
code only transports existing tool invocations, records clocks and summarizes
receipts; it does not implement compiler transformations. The evidence archive
retains failures and guard/retention closures; its cost census separates target
execution from agent effort, which is not available as a quota measurement.
