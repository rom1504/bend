# Phase54 validation: preserved code and bounded graph facts

The baseline is the installed Phase53 ordered02 image, represented by its frozen
checked attempt and saved outputs. Its API SHA256 is
`3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`;
direct runtime is `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.
The installed receipt is `../phase53/evidence/installed-release.json`.
Use frozen artifacts when live source moves; do not reclassify changed live files
as historical inputs.

Root owns all compilation, generated execution and hardware slots. Every target
has CPU3, Node 24.18.0, 1 GiB heap, 2 GiB process-tree RSS and 4 GiB available-memory
floor. One existing supervisor owns the shared lock. Data-only producers may use
CPU0. Executable acquisition parents remain unpinned so their children can select
CPU3. Historical tools and raw evidence remain unchanged.

## First gate: helper separation

The checked helper-only build completed with an API hash exactly equal to
Phase53. This is stronger than a limited runtime sample: the complete compiled
compiler API is byte-identical. Preserve that identity and the source-movement
inventory, rather than attributing a new speed result to a file relocation.
Root already acquired the existing core8 with this image. The semantic owner
owns the exact emitted-byte comparator, including representative native output;
this plan does not create another competing comparator.

## Independent SCC facts

`graph-controls.mjs` appends diagnostic exports to a separately saved checked
API. It does not edit that API or change the production ABI. The original API,
derivative, parser, Node, checked attempt and focused gate are pinned. Its default
14 cases cover empty/isolated/self/mutual graphs, one-way propagation of unknown
tails, shared successors, duplicate edges, disconnected unknown tails, Unicode
names, two definition-order permutations, and missing targets. All small pairs
are checked for same-component agreement. Membership order, leader-derived IDs,
bounce flags and absent-name behavior have independent expectations.

The small oracle uses separate per-vertex reachability, deliberately distinct
from the implementation's iterative Kosaraju traversal and reverse propagation.
Candidate-only duplicate-name refusal adds a fifteenth malformed-input control;
it is stricter robustness coverage, not a claim about source programs accepted
by the old compiler. The baseline 14 control passed before candidate execution.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 60 --rss-mib 2048 --available-mib 4096 NEW_SUPERVISOR \
  -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase54/graph-controls.mjs ATTEMPT NEW_OUT
```

The consumed v1 remains unchanged. `graph-controls-v2.mjs --boundaries` is a
separate ten-case candidate gate for exact and insufficient vertex/edge budgets,
including empty 0/0 and raw duplicate-edge occurrences. It pins v1, preserves the
original small cases when that option is absent, and records each case's limits.
These boundary checks use the same independent reachability oracle plus explicit
vertex/raw-edge counts; they do not infer the production worklist algorithm.

The initial graph01 production scanner retained its 512-definition bound. Its graph entry
`jd_calls_context_bounded(book, rows, vertices, edges)` permits separately scoped
scale experiments without widening that production bound. Its default entry
`jd_calls_context_rows` delegated to 512 vertices and 4,194,304 edges. Neither a
synthetic bounded-graph pass nor a generated identity-chain result implies a
production limit increase.

These initial graph01 commands are retained for historical reproduction. The
selected graph02 has the separately qualified 4,096-definition bound described
below; its default entry must not be expected to refuse 513 rows. Run each large
shape as a fresh bounded job, importing only one compiler image. The original
options were:

| Purpose | Options | Expected result |
|---|---|---|
| Historical/new sparse comparison | `--scale 128 --shape chain` | Same facts |
| Graph01 production ceiling | `--scale 512 --shape chain` | Valid |
| Graph01 production refusal boundary | `--scale 513 --shape chain --expect-refusal` | Graph01 invalid |
| Explicit diagnostic capacity | `--scale 513 --shape chain --vertices 513 --edges 512` | Valid |
| Larger acyclic graph | `--scale 1024 --shape chain --vertices 1024 --edges 1023` | Valid |
| Compiler-sized graph | `--scale 3004 --shape components --vertices 3004 --edges 3004` | Valid |
| Insufficient edge budget | `--scale 128 --shape chain --vertices 128 --edges 126 --expect-refusal` | Invalid |
| Insufficient vertex budget | `--scale 128 --shape chain --vertices 127 --edges 127 --expect-refusal` | Invalid |
| Edge-free graph | `--scale 1 --shape isolated --vertices 1 --edges 0` | Valid |

Sparse scale oracles use explicit shape formulas and linear space. Chain tails
all reach the final unknown seed; disconnected four-node cycles only inherit
their own seeds. Result facts stay linear-sized. The controller times the one
graph invocation separately from API import and fact queries; those cold
diagnostic timings are not a robust throughput benchmark. Request-cost evidence
must say whether loading, checking and emission are included.

## Initial checked source-scaling plan

The original `make-scale-catalog.py` is data-only. It pins the frozen Phase53 module inventory
and counts its 103 modules / 3004 column-zero `def` declarations. It generates
128, 512, 513, 1024 and 3004-function acyclic identity chains. Each file has one
independent scalar oracle: `bench(37) == 37`. There are no primitive or foreign
calls. These counts describe source declarations, not an assumption that a
lowered graph has exactly the same number of vertices. The commands below
preserve the initial plan; its missing Base import caused the retained fixture
failure. Use the completed v3 method and receipts below for the corrected source.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase54/make-scale-catalog.py \
  --out selfhost/build/phase54/scale-sources01

python3 -B selfhost/tools/performance/phase53/acquire.py \
  --attempt ATTEMPT --catalog selfhost/build/phase54/scale-sources01/catalog.json \
  --cases call-chain-128 --backend direct --role candidate \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out NEW_ACQUISITION
```

Use separate fresh outputs for each image and scale. Start with 128; stop after
any unexpected rejection, wrong output, deadline or memory failure. Source
generation is explicitly unqualified until checked acquisition succeeds. Test
512/513 next to verify the real scanner/fallback boundary. Larger scales are
bounded diagnostic checks, not permission to raise memory limits. Avoid
repeatedly compiling an unchanged source merely to produce more timing rows.

## Integration and release scope

1. Checked B1 and its strict focused gate establish a checked compiler image.
2. Graph facts and source-scale checks establish the new analysis's membership,
   order, bounce propagation, bounds and refusal behavior.
3. Fresh direct emissions join each source/oracle to the new attempt. Compare
   full output bytes with saved Phase53 modules. The same applies to selected
   legacy/native outputs; no whitespace normalization or omitted runtime prefix.
4. Run maintained8 and the existing direct26 census once after live source
   reconciliation. Shared helper/native concerns need representative native
   qualification, but this does not justify repeating unchanged frontend 3026.
5. Root installs and runs the established release/routing smoke, preserving the
   exact selected source/API/runtime identity and all previous protected files.

Whole-module byte equality, including runtime/foreign support, supports reuse
of the historical execution observations **for those exact emitted artifacts**.
It is not a fresh benchmark or proof for all programs. If any module differs,
retain the mismatch and inspect it before deciding whether new runtime or
semantic execution is necessary. Do not spend another 18-minute 45/669 runtime
campaign on byte-identical programs.

Planning estimates: small graph controls seconds; bounded sparse graph scales
seconds to a minute each until measured; core8 acquisition roughly 45 seconds;
full 23-source acquisition roughly 2–3 minutes if needed; maintained8/direct26
roughly 1–2 minutes each. Native tooling may require an authorized unsandboxed
Clang run. These are estimates and required scopes, not completed results or
authorization to run targets.

## Retained fixture repair and production-limit successor

The first 128-function scale acquisition failed in 2.76 seconds because the
original generated file omitted `import Base`: `U32` was undefined at `bench`.
This was a fixture failure during checking, before emission, not evidence of an
SCC/compiler regression. The consumed v1 producer, `scale-sources01`, and
`prepared-scale-graph02` remain unchanged. Reviewed
`make-scale-catalog-v2.py` adds only the ordinary explicit Base import and pins
its predecessor. Data-only `scale-sources02` preserves all declaration counts,
identity edges and expected 37. Removing the one inserted import line/blank line
restores each old source byte-for-byte. The exact mapping and failure receipts
are in `build/phase54/scale-source-correction02.json`. Fresh acquisition is still
required; generation is not a source-acceptance result.

After the initial 512-bound design and graph01 evidence, root separately
approved a production limit of 4096, shared by source scan, graph admission and
exact emitted-reference reachability. The old 513-refusal observation remains
historical evidence for graph01; it is not an expected refusal for the successor.
Use 4096 acceptance / 4097 refusal for its production boundary. Keep the explicit
bounded diagnostic tests distinct from this newly authorized production change.

## Completed source-scale qualification

The v2 fixture exposed a second source-construction error: its entry appeared
before the helpers it called. The checker rejected the 128-definition file
because `renamed_hop_00001` was not yet filled. Its failed acquisition remains
at `build/phase54/prepared-scale-graph02-v2`; it emitted no target module.
Reviewed `make-scale-catalog-v3.py` reverses declaration order only. Every
definition block is byte-identical to v2, the terminal helper appears first,
and `bench` appears last. A separate static check verifies every callee is
already declared. The Base import and independent output oracle remain intact.

All five v3 sources passed checked acquisition with `checked-graph02`, followed
by the unchanged Phase52 smoke runner:

| Declared functions | Checked acquisition wall time | Exact output |
|---:|---:|---:|
| 128 | 6.921 s | 37 |
| 512 | 11.932 s | 37 |
| 513 | 11.744 s | 37 |
| 1024 | 18.324 s | 37 |
| 3004 | 43.714 s | 37 |

The five guarded acquisition processes total 92.635 seconds and peak at
623,955,968 bytes of process-tree RSS. These figures include compiler loading,
checking and emission; they are diagnostic request costs, not steady-state
throughput measurements. The smoke processes total 0.463 seconds, peak at
65,900,544 bytes, and use the default target Node stack. Each case performs
three calls according to the unchanged smoke protocol. All fifteen calls
passed their exact scalar oracle. No generated-program speed claim follows.

The fresh source catalog is `build/phase54/scale-sources03/catalog.json`;
acquisition evidence is `build/phase54/prepared-scale-graph02-v3/`; execution
evidence is `build/phase54/smoke-scale-graph02-v3/report.json`. The data-only
join `build/phase54/scale-source-correction03.json` preserves the v2 failure,
pins both producers and all five before/after source mappings, and joins the
checked modules to successful smoke observations. Its SHA-256 is
`cc0316c702ba37ac0bd11579890aca293cc0612cabdb1120a496c74f9d5df0c3`.

These controls establish acceptance and correct execution of five typed
identity chains up to the frozen Phase53 compiler's declaration count. They
do not equate source declarations with admitted graph vertices or prove general
self-emission. Root subsequently completed a separate production-boundary
diagnostic: the default `jd_calls_context_rows` entry rejects a validly formed
chain containing 4,097 vertices and 4,096 edges. The complete passing report is
`build/phase54/graph02-refusal4097/report.json`, SHA-256
`86ab6e13e57e3924d919d46eaf73beaed7172c149948182205f44abcc7d835ab`.
This establishes refusal at the graph-row entry; it is not a checked
4,097-definition source compilation.
