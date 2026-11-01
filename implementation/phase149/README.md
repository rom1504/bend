# Phase149 — Bend policy switches expose optimization value

The new experimental QBE entry can turn optional groups off before preparing
unused candidates. Policy selection, command parsing, streaming, timing and
controls are all Bend. No existing production pass or runtime was replaced.
The ordinary entry and installed selection retain their current behavior;
Phase147 remains the independently qualified native research compiler.

The bounded sweep shows a genuine build/runtime tradeoff, not a free compiler
speedup. On four small complete compiler requests, code11 takes20.61% less time
geometrically, but its three measured user programs take3.018× as long. Code4
saves2.07% and is byte-identical on those four inputs; an additional RLE input
already disproves universal output identity. Keep the switches as diagnostics;
these results alone do not justify a new default development policy.

## What changed

- `selfhost/src/back/qbe/optimization-policy.bend`: additive policy entry over
  the existing checked pipeline. The default delegates the original functions.
- `selfhost/src/back/qbe/region-policy.bend`: policy selection outside the
  existing cursor, reusing verified worker emission and generic fallbacks.
- `selfhost/src/driver/policy-native.bend`: canonical code parser, bounded input
  reads, exact stdout stream and optional separate coarse timing file.
- `selfhost/tests/phase149/`: finite Bend controls, including a malformed real
  direct function that must fail final verification and stream boundary checks.
- `qbe-policy` and `qbe-policy-test` source profiles; default profile remains QBE.

See [usage and exact flag semantics](../../docs/self_hosted/optimization-policies.md).
Code1 omits initial inlining **and scalar cleanup**. Code2 omits late optional
helper preparation, not all helpers or direct/SCC/array admission. Code4 keeps
complete direct workers, original H and generic/fused fallbacks; code8 keeps
complete direct plus generic/fused. Codes3 and11 compose the flags. Shared
registry/view preparation remains, so these do not expose every optional cost.

## Repeated small experiment

Ratios below1 mean less time. Reference is policy0 executed by the **same native
image**, not the upstream TypeScript compiler. Request and program columns use
four and three inputs respectively; they must not be combined as one score.

| Policy | Compiler request ratio | Generated-program runtime ratio |
| --- | ---: | ---: |
| 1 | 0.9191 | 1.3835 |
| 2 | 0.9053 | 1.3033 |
| 4 | 0.9793 | 0.9936 |
| 8 | 0.9669 | 1.5988 |
| 3 | 0.8292 | 1.8097 |
| 11 | 0.7939 | 3.0181 |

The compiler inputs are an extracted compiler/verifier workload, Map churn,
expression evaluation and Mandelbrot. User runtime covers the latter three,
with unchanged native45 wrappers, fixed workload parameters and independent
output oracles. The compiler slice is a compilation workload, not a timed
runtime stand-in for the full compiler.

One CPU3 lane, one thread, GPU off, same runtime/QBE/assets, fresh request
processes, prepared Base only. Three rotating rounds per role:84 compiler
requests and63 runtime observations. Seven-role order is not fully position
balanced in three rounds. This is a small screening campaign, without a
confidence interval, OS-cache flush, broad45 score or fresh upstream ratio.
All measured program samples are above the runner's low-resolution threshold.

Policy-specific QBE references establish repeatability, not correctness by
self-comparison. Policy0's complete QBE is also literally equal to freshly
emitted qualified Phase147 output on all four requests. User program outputs
are checked separately against the frozen catalog oracles. Duplicate identical
QBE products share one machine build;22 distinct products were built.

Important individual results:

- Omitting the inline/scalar group makes Mandelbrot compilation21.46% faster
  but its runtime2.676× slower. Map/expression runtime is approximately flat.
- Omitting late helper preparation makes Map runtime1.870× and expression1.184×;
  Mandelbrot runtime is approximately unchanged.
- Generic-region policy8 makes expression runtime4.108× slower while saving
  only about3.3% compiler time geometrically.
- Policy11 gives runtime2.371× Map,4.358× expression and2.661× Mandelbrot.
- Policy4 has identical QBE and objects on these three runtime cases. Its
  measured0.9936 runtime ratio is variation, not a generated-code improvement.

## Transfer and full-source build

Four alternating pairs on two additional frozen workloads reject policy4 as a
universally cheap win: RLE runtime is1.327× policy0, while tree-bitonic is1.018×
with byte-identical QBE. RLE's slightly smaller QBE still runs materially slower.
Both retain independent catalog output correctness. The tree difference is
variation on the identical executable, not a semantic work change.

The full-source pair holds the executing Phase149 image and the frozen Phase147
compiler source fixed (3,045,282 bytes, source SHA `0f3bd8a0…`). It performs fresh
requests using prepared Base, followed by separate fresh QBE/as/link builds.

| Measurement | Default0 | Reduced11 |
| --- | ---: | ---: |
| Complete compiler request, guarded wall | 239.089s | 188.443s |
| Separate machine build, guarded wall | 19.324s | 16.376s |
| Serial sum of those guarded intervals | 258.413s | 204.819s |
| Generated QBE bytes | 119,544,406 | 102,773,136 |
| Native executable bytes | 19,499,168 | 18,493,360 |

Thus the request falls21.18%, the staged serial total20.74%, QBE14.03% and ELF
5.16%. One observation per policy, no confidence interval. This serial sum is
**not** the previous overlapped streaming source-to-executable clock, and must
not be compared directly with Phase147's246.173s result. Machine-builder internal
clocks are18.405s and15.583s; the table consistently includes guard overhead.

Default0 reproduces the qualified119,544,406-byte full-source QBE exactly, SHA
`76eb1a7c…`; the reference bytes remain available. The reduced output is different
and is not assumed semantically correct merely because QBE accepts it. Both
resulting compilers receive independent request-output checks below.

## Does the cheaper build improve the research loop?

Both newly built executables contain the **same frozen ordinary compiler
source**. Only the policy used to build them differs. Their subsequent requests
run that source's ordinary optimizer; they do not keep policy11 enabled.
Four alternating pairs on each request pass exact independent parent QBE checks:

| Subsequent compiler request | Built by default0 | Built by reduced11 | Ratio |
| --- | ---: | ---: | ---: |
| Compiler/verifier slice | 3.242s | 5.813s | 1.793× |
| Map churn | 2.026s | 3.788s | 1.869× |

The two-case geometric slowdown is1.831×. The53.594s staged acquisition saving
is consumed after approximately21 compiler-slice requests or31 Map requests
(using median latency differences). These are workload-specific break-even
estimates, not full self-build predictions. They exclude any extra qualification
needed before trusting a changed compiler image, which further reduces the
advantage. This is direct evidence against using code11 as the default research
compiler. It can still be an explicit throwaway build for a very small test.

The native timing-output CLI and ordinary-command passthrough also reproduce the
expression QBE exactly. An actual invalid-code CLI call returns the expected2.
The separate timing file records15ms reading plus1014ms compilation/emission in
one observation; its successful output remains uncontaminated.

## Why this tradeoff occurs

The actual `$direct.mit` function in Mandelbrot falls from618 to238 QBE lines
when the inline/scalar group is omitted, but gains seven normal-path helper
call sites: three `asr8`, two `b2u` and two `sel`. The default hot body has none.
Both preserve the tail-loop jump; losing tail recursion is not the explanation.
Nested selection helpers add further work. Smaller IR is not automatically
faster machine execution.

`scalar-facts.bend` preserves `P113DCall` and clears the destination facts.
Therefore merely restoring scalar cleanup is not expected to recover the lost
cross-call computation. This is source/IR evidence and a plausible explanation,
not a dynamic call-count profile or isolated causal proof for every cycle.
A scalar-only rebuild was rejected for this campaign: it would add acquisition
cost without a credible expectation of recovering most of the runtime loss.

## Verification and limits

Independent upstream checking accepts the entire experimental source book;
only a tiny export is emitted to avoid acquiring an unnecessary JS compiler.
The qualified Phase147 native parent builds the experiment image. All60 native
Bend controls pass. New policy paths preserve runtime admission, source checking,
ownership/array obligations, namespace checks and final verification; no public
verifier, proof declaration or runtime was weakened.

A read-only semantic audit found and prompted repair of an early fallback that
could have re-enabled helpers on a rejected-open/final-accepted path. The final
`p149p_lowered` carries the policy through that fallback. No outstanding
high-severity issue was found in the final audit. Finite controls and source
checking are not an end-to-end theorem or an independent BendTT proof.

All twelve codes have parser/mapping controls; only seven have the main runtime
screen. No new N1/N2/full45, JS/C, incremental, GPU or parallel qualification is
claimed. The experimental image is not installed. The current manifest explicitly
marks new-source reacquisition unqualified; the historical Phase147 receipt
continues to identify the qualified image.

## Complexity, host-tool scope and negative results

New compiler/driver/entry code is401 physical Bend lines; finite test sources
add110. There are59 new named declarations in the source manifest, no new core
IR type and no changes to existing compiler algorithms. Manifest dependency/order
metadata accounts for additional diff lines. The final whitespace-only EOF fix
and manifest status label do not change the consumed assembled program.

No Python/JS tool source was added. Existing external assembly, source checking,
resource supervision, QBE/assembler/linker and independent benchmark tools remain.
No operational host tool was safely redundant in this change, so none was deleted;
rewriting those tools would not test the hypothesis. In particular, the new Bend
CLI/control runner avoids adding another host policy-selection/test interpreter.

Preserved negatives include two initial source-check failures (affine sharing),
one invalid benchmark budget rejected before target execution, and a lock-refused
retry while the original full-source job was still active in another process
namespace. No competing target was launched. The earlier partial process receipt
was active work, not a failed compiler run. Full-source results and campaign cost
are recorded below and in the evidence receipts.

## Reproduction

[Design](../../design/phase149/README.md) ·
[Hypothesis](../../experiments/phase149/P149-001-policy-cost.md) ·
[Metrics](metrics.json) · [Policy guide](../../docs/self_hosted/optimization-policies.md).

The evidence capsule preserves the source/manifest snapshots, independent check,
image binding, exact job argv, frozen benchmark recipes/manifests, raw process
samples, output identities, negative attempts and close receipts. The local
retention archives preserve full native/QBE/machine products. Compiler requests
use the Bend protocol; machine products and timing use maintained tools. Keep
qualified runtime/Base/toolchain inputs pinned when reproducing.

## Decision and next experiment

Keep the additive experimental policy interface; keep the default optimized
research compiler. Do not promote a generic "fast development" mode based on a
compiler-only timing column. This phase measures useful causality but introduces
no production throughput gain, broad runtime gain or recursive acceleration.

The best next experiment is narrower: identify an expensive optional preparation
that repeatedly reaches the same admitted result, and skip its **failed candidate
work** using an exact cheap prerequisite. Require complete default-QBE identity
on a compiler slice plus an unrelated workload before any full acquisition.
This preserves the runtime work that the current ablations show is valuable.
Measure the prerequisite's own traversal/allocation cost; do not infer a gain
from refusal counts alone.

A second experiment can separate the inline group's call expansion and scalar
cleanup, but the Mandelbrot witness already limits expectations: scalar cleanup
alone does not remove the remaining calls. A practical improvement would keep
cheap, high-value call elimination while avoiding repeated unsuccessful search.
Do not implement a policy search framework before one selective rule wins.

For much larger cold gains, the residual188s after these selected omissions
keeps shared checking/lowering/representation and rendering on the agenda.
It is not a lower bound for every possible fast compiler. Prior profile evidence
and Phase148's failed conversion-heavy adapter still favor removing complete
representation/traversal boundaries over adding another isolated adapter.

## Cost and retention

78 guarded jobs total1122.62s (18.71min), peak1.14GB sampled process-tree RSS.
Four nonzero exits total14.84s: two source-check failures, one rejected benchmark
budget and one **expected** invalid-policy CLI control. The lock-refused metadata
retry did not start a guarded target and is recorded separately. One native
experiment acquisition, two full-source emission observations, two subsequent
machine builds and the bounded sweeps account for the useful target work.

This is execution cost, not total agent/quota accounting. The first guarded
start through last finish spans27.25min, excluding earlier coding and later
archiving/reporting. Exact rows are in [cost.json](cost.json). Bounded agents
implemented/audited separate Bend modules; one coordinator owned all target runs.
No broad qualification was spent on a policy whose compiler-runtime tradeoff
already fails the intended research-loop objective.

All guarded runs are closed and their declared cold artifacts archive-verified;
no pruning or installed-selection change. Full native/QBE/machine products remain
locally hot and in verified restoration archives. The committed evidence capsule
contains compact methods, sources, raw measurements and output controls; local
archives are not an independent off-machine backup.
