# Phase58 reproduction guide

Selected candidate: **`selfhost/build/phase58/checked-last01`**, superseding
`checked-shared01` with the general last-live-constructor-key policy. Its checked
build and all 14 B1 integration jobs pass. Final bootstrap/B2 qualification and
selected measurements are in progress; installation and archive publication are
pending. Shared01's completed self-check/fixed point and measurements remain
historical evidence and are not transferred automatically to last01.
The [canonical report](../../../../implementation/phase58/README.md) owns final
status and identities. [Hypothesis records](../../../../experiments/phase58/)
index each change; their retrospective indexing is explicit.

Run from the repository root. Root is the sole execution owner and serializes
compiler/program targets. Use **one resource guard**, never nested supervisors.
Recipes identify whether their runner owns the guard or requires an outer one.
Prepared APIs, source, drivers, runtimes and Base caches are private copies under
Phase58. Reproduction must not write closed Phase54–57 trees, reuse output
directories, edit historical receipts or fabricate checked-image metadata.

## Mechanisms and focused evidence

| Tool directory | Changed factor / recipe |
| --- | --- |
| [fields](fields/README-v3.md) | Last live constructor field computed; preceding ordinary keys literal; exact `__proto__` always computed. Host-clone ordinary keys stay literal. See [source policy](fields/last-source01/README.md), controls-v5 and independent last-live supplement-v2; original all-literal evidence remains historical. |
| [lookup](lookup/) | Intermediate miss allocation and checked-owner query shortcut. `controls02.mjs` verifies actual selected exact agreement while honestly retaining early `strictExact:false` pilots. |
| [scalar](scalar/README.md) | Exact single-origin U32 residual reconstruction; alias/callback/F32 refusal controls. |
| [choices](choices/README.md) | Proved literal Bool/Unit continuations with ordered prefixes and tail facts. |
| [qualification/reach-controls.mjs](qualification/reach-controls.mjs) | Per-rendered-definition edge dedup; validates every marker and retains all resource constants. |
| [choices/shared-scc01](choices/shared-scc01/controls.md) | One private dispatcher per mutual-tail SCC, unchanged entry ABI and per-call state. |
| [allocation](allocation/README.md) | Deferred local ADT-key reuse proposal; excluded from the six-change selection. |

Use the owner recipes for commands, immutable source overlays and expected
positive/refusal boundaries. Untimed counter/AST derivatives establish mechanism
activation; they are not checked compiler releases or clean timing samples.

## Key-placement selection and diagnostic limits

The all-literal rule helped compiler requests but regressed three generated
programs. Whole computed-key rollback restored those programs while costing
roughly 50–68% on the B2 compiler-request diagnostic. The saved last-key derivative
restored the three points near their prior baseline with a smaller 13–17%
compiler-request cost relative to all-literal. These are bounded saved-JavaScript
observations, not the final checked-last01 performance result. The
[diagnostic recipe](fields/last-key-v1.md),
[program analysis](../../../build/phase58/last-key-program-analysis01/report.json)
and [compiler analysis](../../../build/phase58/fields-last-latency-analysis01/)
preserve that tradeoff. No width threshold is selected; the synthetic width grid
remains unexecuted. Actual [17-group field controls](../../../build/phase58/last-fields-controls01/report.json)
and [last-live supplement](../../../build/phase58/last-live-controls01/report.json)
pass on the newly checked source, including trailing erasure and empty/all-erased
constructors. Final selected B2/program/measurement receipts are still required.

## Genuine compiler images and final correctness

[bootstrap/prepare-candidate.py](bootstrap/prepare-candidate.py) derives a fresh
bootstrap plan from a genuine checked attempt. [bootstrap/reproduce.mjs](bootstrap/reproduce.mjs)
and [bootstrap/setup.mjs](bootstrap/setup.mjs) reuse the frozen ordinary compiler
pipeline and bind subject source separately from the generator image.
The current selected materialization is `build/phase58/final-last01`;
`final-shared01` retains the previous complete checkpoint.

[qualification/final-orchestration-v2.py](qualification/final-orchestration-v2.py)
prepares the existing checked/semantic/native/program/B2 and release commands;
it launches no targets and grants no installation admission. Completed receipts
in `final-last01` are the authority for last01; an unfinished job is not a pass. Earlier choice/reach
success does not automatically qualify a successor. Source, numeric, composition,
overapplication, maintained suites, native retention and generated-program
oracles have distinct scopes; retain the explicitly known pinned-reference NaN
defects without waiving new candidate failures.

## Compiler requests, allocation and emission

The [latency guide](latency/README.md) specifies bindings, private preparation,
cache priming, Node flags, CPU/RSS/deadline limits and measurement boundaries.
Existing materialized methods are:

- `build/phase58/latency-method03`: fixed-source field syntax derivative.
- `build/phase58/latency-method04`: genuine checked/changed-source comparisons,
  including explicitly recorded early non-strict pilots.
- `build/phase58/latency-method06`: exact saved-image SCC-sharing derivative.
- `build/phase58/emission-method02`: full own-source clean/CPU/allocation emission
  with genuine direct-image bindings and mandatory B2/B3 equality.

They have different admissions and cannot be pooled as one experiment. Consumed
failed methods and narrow successors remain intact; derivation manifests record
why each successor exists. In particular, controller flag/schema refusals,
choice01's old edge-budget refusal, cross-realm AST comparisons and sandbox
child-launch failures retain their original status.

After the last01 full-bootstrap report completes and passes, generate a fresh
final comparison recipe without launching targets:

```sh
python3 selfhost/tools/performance/phase58/latency/make-comparison.py \
  selfhost/build/phase58/comparison-replay01 \
  --attempt selfhost/build/phase58/checked-last01 \
  --emission selfhost/build/phase58/final-last01/bootstrap/full/report.json
python3 selfhost/tools/performance/phase58/latency/make-final-matrix.py \
  selfhost/build/phase58/comparison-replay01/report.json \
  selfhost/build/phase58/comparison-replay01/final-matrix.json
```

The preserved shared01 recipe is `build/phase58/comparison-shared01`:
`final-matrix.json/.txt` specifies clean request and profile commands;
`emission-diagnostics.json/.txt` specifies separate whole-source profiles.
[make-emission-diagnostics.py](latency/make-emission-diagnostics.py) derives the
latter from the former. Execute those exact command arrays serially with their
specified guard ownership. First/import, later requests, emission-stage clocks,
complete process wall and peak RSS are distinct. Profiles include collected
objects and run in separate processes; they never enter clean timing statistics.

## Full generated-program campaign

[performance/compare.py](performance/compare.py) verifies actual acquisitions,
records changed versus identical modules and generates fresh timing commands.
Previous shared01 evidence is `build/phase58/program-performance-shared01/report.json`
and its `timing-commands.json`. The campaign keeps **23 sources, 45 points and
669 samples**, all original oracles/round counts, and three disjoint 15-point
batches. Byte equality is not a timing result. Even identical points retain the
full-corpus timing contract when aggregating a full campaign.

[performance/aggregate.py](performance/aggregate.py) consumes completed smoke,
comparison, acquisition and all three timing reports. It preserves the inherited
median/point/source weighting, every regression, drift/spread flags and SVG;
its `--comparison` binding verifies the actual batch order. Use the saved timing
commands and aggregator invocation from the final recipe, not an improvised
subset or a renamed old result. Aggregate only after all required reports pass.

## Release, preservation and replay elsewhere

[publication/README.md](publication/README.md) owns the final seven-file release
preservation, protected103 audit, writer closure and streaming archive procedure.
Its earlier candidate examples are historical; bind **checked-last01** in a
fresh selected release plan. Root admits installation only after final gates.
Release42/default24 validation and final preservation are separate from compiler
and program performance. Finish reporting and stop every raw writer before
archiving; publication writes outside the closed raw tree.

When an archive is published, restore its raw members at the documented root and
verify the archive/member manifest before replay. Current absolute historical
plans contain machine paths and content identities: regenerate and rebind fresh
plans/private staging with the existing producers after relocation. Never edit
saved receipts to make paths or hashes appear valid. Retain prerequisite pinned
upstream inputs, Node/tool identities, baseline release and derivation manifests;
a local ignored raw path or checksum alone is not durable publication.
