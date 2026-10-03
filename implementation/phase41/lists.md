# Phase41 list next-argument allocation investigation

Final decision: **reject source integration**. The saved-JS ablation passes its
selected semantic controls but has no useful execution signal against Phase40
direct unfused. Source proposals remain unapplied and unchecked; no allocation
measurement or allocation reduction is claimed.

2026-10-03 pre-execution checkpoint. Correctness **unchecked**, measurement
**not run**, decision **investigate**. No shared compiler source, installed
artifact, historical evidence or unrelated dirty file was edited. No build,
benchmark, profile or derivation execution was performed by this owner.

Read AGENTS, experiment workflow/frontier/steering, Phase40 list design/report,
Phase39 callback rejection and actual checked06 List/Chain worker output.
The minimal candidate removes only the private next-argument literal tuple;
frame arrays and complete tagged producer/filter/map outputs remain.

Files under `selfhost/tools/performance/phase41/lists/`:

- `next-tuples.mjs`: AST-checked manual emission ablation. Inputs are the
  Phase40 `list-actual-derived06` directory, clean checked06 benchmark module,
  and a fresh output directory. The fixture and benchmark identities are
  explicitly pinned to checked06 bytes. It verifies historical diagnostic
  derivation inputs, preserves baseline copies and freezes its consumed script.
  The report labels saved-JS output unchecked/uncertified and records every
  changed worker/site with arity.
- `controls.mjs`: successor of Phase40 `list-actual-controls.mjs`; the
  manifest/report schema and prototype label change. All existing complete-stage
  oracles, admission, boundary, alias and deep traversal assertions remain.
  Both roles now start from direct unfused Phase40 diagnostic output. All
  three 30000-depth tests now cover both roles. Added two independent synthetic
  transfer witnesses require both RHSs to see the original state and preserve a
  second-RHS exception after first-RHS evaluation; their execution is pending.
- `tree-next-tuples-proposal.bend`, `tree-next-tuples.patch`,
  `source-proposal.json`: isolated source proposal and parent hash. Three tuple
  creation sites use a fresh `j_component_next` emitter; matching state reads
  use scalar temporaries. Incomplete/empty argument spines retain the exact old
  array/index path, addressing an independent reviewer's binary continuation
  caveat. Dependent telescope/erasure handling mirrors the
  existing argument emitter. This proposal is not applied or checked.

Pinned Node24 `--check` exits0 for both JavaScript scripts. This is syntax
validation only. Root and independent reviewer have been given the paths;
runtime gates and review outcomes remain pending. No speed or allocation claim.

Root execution recipe (fresh paths; root applies its serial resource wrapper):

```sh
node selfhost/tools/performance/phase41/lists/next-tuples.mjs \
  selfhost/build/phase40/list-actual-derived06 \
  selfhost/build/phase40/cost-run06/coverage-list-pipeline-512-0-candidate.mjs \
  selfhost/build/phase41/lists-next-tuples01
node selfhost/tools/performance/phase41/lists/controls.mjs \
  selfhost/build/phase41/lists-next-tuples01 \
  selfhost/build/phase41/lists-next-controls01
```

The benchmark parent should hash to
`d623912da283c60a135535e25c724bc704582bde31fdf1241e55d5a6aa6556ad`;
fixture clean parent to
`8f4f3f62b6d7bd7c2c924b1c794d5fffc60b32eb946564714dc80caffcd879b0`.
Outputs `benchmark.original.mjs` and `benchmark.component.mjs` are suitable
clean paired roles; the derived manifest does not yet define a timing protocol.
Timing and performance admission remain root decisions.


2026-10-03 v2 correction: root's derive01 succeeds, but controls01 fails before
the first oracle in the independent transfer witness. Acorn's SequenceExpression
source range excludes grouping parentheses; v1 emitted its comma expression as
a declaration list and parsing reported a duplicate `$s1`. The consumed v1
derivation, tools and failed receipt are preserved. `next-tuples-v2.mjs` wraps
every extracted RHS in parentheses and requires one matched tuple per lexical
block; `controls-v2.mjs` imports/binds that successor without relaxing assertions.
`v2-successor.json` binds parents, successors and the failed report. Both v2 tools
pass Node --check, and parser-only transformation of the exact synthetic witness
now produces valid grouped RHSs; no witness or program execution by this owner.
The isolated source proposal also has a versioned grouped-RHS successor
`tree-next-tuples-v2.patch`. Root runtime rerun remains pending.


Root's [derive02 manifest](../../selfhost/build/phase41/lists-next-tuples02/derive.json)
completes. [Controls02](../../selfhost/build/phase41/lists-controls02/report.json)
passes **55 oracle rows, 106 boundary rows, one ordinary admission row and two
independent transfer witnesses**. The 55 oracle rows comprise 49 complete
List/Chain stage and ordinary export size/seed combinations plus three
30000-depth traversal checks for each of the unchanged-direct and scalar-temp
roles. Every prior assertion remains; the v1 witness parser failure stays in
[controls01](../../selfhost/build/phase41/lists-controls01/report.json).
The v2 grouping repair changes emitted expression syntax, not the tested
parallel-state or exception-order requirement.

The root-owned [screen01 report](../../selfhost/build/phase41/lists-screen01/report.json)
completes/pass in 20.103 seconds: three fresh rotating rounds, four roles
(original, identical-byte noise, scalar-temp and pinned TypeScript), CPU3,
Node24.18, 350ms warmup and 150ms target per role. These are selected
generated-program execution observations, not compiler throughput.

| Point | Original ms median (min–max) | Identical noise ms median (min–max) | Scalar-temp ms median (min–max) | TS ms median (min–max) | Noise/scalar |
| --- | --- | --- | --- | --- | --- |
|128/17|0.046704 (0.045774–0.048368)|0.046419 (0.046407–0.047957)|0.046313 (0.045994–0.046510)|0.007311 (0.006791–0.007383)|1.00228×|
|512/123|0.131126 (0.127410–0.134230)|0.129411 (0.128156–0.138198)|0.128895 (0.127700–0.132592)|0.029600 (0.029459–0.030141)|1.00400×|

Exact per-round execution rows are under
[128](../../selfhost/build/phase41/lists-screen01/coverage-list-pipeline-128/) and
[512](../../selfhost/build/phase41/lists-screen01/coverage-list-pipeline-512/),
with all raw samples also embedded in the report. Noise/scalar round pairs are
1.03548/0.99803/1.00897 at128 and1.00357/0.97601/1.07217 at512. Their
median shifts of0.228%/0.400% have overlapping ranges; the two identical-byte
baseline roles differ by0.613%/1.325% in median. Thus the apparent scalarization
benefit is smaller than baseline variation and does not establish useful speed.

No allocation profile was acquired for this ablation. V8 elimination of some
private tuples remains a hypothesis, not an observed explanation. The isolated
source proposal adds emitter helpers and preserves incomplete-transfer handling;
that complexity has no measured benefit here. Under the frozen falsifier, root
rejects source integration and stops expensive follow-up. The installed Phase40
compiler stays the direct-unfused denominator; fusion and compact-frame
representation remain separate untested hypotheses.
