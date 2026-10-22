# Phase125 native qualification and compiler cost

Source06 is native-qualified through direct QBE. Hosted and N1 self-emitted QBE
match in all **93049182 bytes**, SHA256
`99455b794924680cee0e8ed5f25e82010f4e7a0557151d24be913db23dfa5b81`.
N1/N2 each pass16 ordinary focused executions and3 expected refusals. N2 passes
all45 original one-shot programs. These one-shot wrappers are distinct from the
hosted-produced batch runtime benchmark; neither gate substitutes for the other.

[Exact results](native-results.json) · [Candidate](candidate.json) ·
[Standalone selected source](source06/compiler.bend.gz) ·
[Source identity](source06/manifest.json) ·
[Native reproduction](../../selfhost/tools/performance/phase125/native/README.md).

The actual experimental images are
`selfhost/build/phase111/p125-native06-n1/program` and
`selfhost/build/phase111/p125-native06-self/build/program`.
Both are source/runtime-bound by the qualification receipt. Their ELF hashes
differ; the result is raw-QBE reproduction, not an ELF fixed point or N2→N3 test.
Installed JS/native selections remain unchanged. There is no GPU/parallel claim.

## Ordinary compilation

Two sequential CPU3 blocks compare Phase125 and qualified Phase118, each with
the same frozen three sources, three rotated rounds and unchanged full outputs.
All54 observations pass. Legacy role names `phase111`/`phase112` mean N1/N2.

| Source | N1 request s | N2 request s | Upstream request s | N1 ready s | N2 ready s | Upstream ready s |
|---|---:|---:|---:|---:|---:|---:|
| lexer |2.225|2.226|0.702|2.311|2.314|1.423|
| closures256 |0.601|0.610|0.549|0.643|0.652|1.113|
| map-churn128 |3.253|3.110|1.160|3.450|3.290|3.006|

Three-source geometric request ratios are **2.13489× /2.11464× upstream** for
N1/N2. Ready-executable stage-sum ratios are **1.02516× /1.01421×**. The configured
native workflow uses prepared Base and a cached runtime; upstream loads/checks
source Base, emits C and recompiles its runtime with Clang. Ready stage sums add
machine build to the request, excluding harness overhead and execution. These
are useful workflow comparisons, not identical-work backend throughput.

The contemporaneous Phase118 block measures requests2.11564×/2.11078× and
ready1.01709×/1.01543× upstream. Directly comparing block medians, current N1/N2
requests take3.35%/2.60% more time and ready stages3.37%/2.43% more. Upstream itself
drifts2.41%/2.55%. The current map request has visible sample spread, while the
old block is steadier. This small sequential screen does not demonstrate a
compiler throughput improvement or isolate a causal slowdown from code generation.

## Acquisition, storage and resource cost

Successful qualification takes **1353.097s (22.55min)**, with peak process-tree
RSS5538947072bytes (**5.159GiB**) under the6GiB guard. Available memory never falls
below21238329344bytes (19.78GiB). No OOM or deadline failure occurs.

The hosted job takes742.68s, including276.69s checking and462.01s integrated
lowering/verification/optimization/rendering. N1 QBE/as/link takes12.94s.
N1's self-request takes425.04s; its request plus N2 build job takes438.70s.
Those clocks are nested inside the qualification guard and must not be added
again. The old Phase118 successful qualification was1286.04s, with a701.26s
hosted job and406.61s self-request. Sources and optimization work have changed;
this is acquisition history, not a same-source compiler speed comparison.

Full-compiler QBE grows85831654→93049182bytes (+8.41%) across the accumulated
Phase118→125 changes. This differs from the small45-program QBE reduction versus
Phase124. A source-size increase and a code-size increase are different costs.

After byte equality, three generated QBE/assembly/object duplicate pairs are
hardlinked, preserving every path, byte and mode. The receipt records182033801
bytes recovered. A separate earlier dedup of old Phase118 artifacts recovered
167753448bytes; these are different groups, not two claims on the same savings.
No evidence or selected executable was deleted. The selected full Bend source is
also preserved separately as447242bytes of deterministic gzip data.

## Research-loop interpretation

This consolidates several generated-code improvements into an actual qualified
native compiler, but does not demonstrate recursive acceleration. The measured
ordinary compiler cost is roughly unchanged, and qualification has an acquisition
cost. A future feedback experiment must measure whether adopting this tool lowers
the total cost of validated subsequent experiments, including failed candidates,
qualification and agent effort. Repeated equivalent self-compilation is not that
experiment.
