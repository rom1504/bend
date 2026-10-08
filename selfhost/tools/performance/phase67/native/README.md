# Native local-value lowering experiment

The unchanged native backend recognizes saturated leading-lambda calls, but
`nc_let` still creates a continuation segment for every argument—including
already evaluated variables and immediate words. Named scalar built-ins also
retain register jumps. Upstream `bend2/comp.ts::emit_let` instead binds
`emit_expr` directly into a local. This candidate adopts that local rule without
changing representation, reference-counting or the scheduler ABI.

Candidate artifacts are **unexecuted proposals**, not results. Root records
builds, source snapshots, differential controls and performance separately.

- `atoms-v1.patch`: rejected before execution; changed malformed-input error
  precedence for an unbound value.
- `atoms-v2.patch`: fixes that by retaining original cut fallback, but omitted
  the nonsequential `FID_EXIT` cancellation checkpoint.
- `atoms-v3.patch`: proposed atom ablation, preserving both boundaries. It
  bypasses `nc_cut` for `Var` and `NWord`, emits a local binding, then lowers the
  body with the same held environment and sharing/drop actions.
- `scalars-v1.patch`: unexecuted first scalar extension, superseded before use.
- `scalars-v2.patch`: includes atoms-v3; actual Base scalar primitive calls with
  exact saturation and no bang use the same intrinsic C expression locally.
  Argument evaluation remains left-to-right in explicit lets. Array operations,
  F32 read/show, partial applications, overrides and Foreign definitions retain
  their original path. Scalar comparison results retain packed ordering tags.

Each JSON file binds candidate and production input hashes. Complete candidate
source copies make the exact proposal inspectable without modifying production.
`focused-controls-v1.json` records source identities, goldens and invariants.

First discriminate on numeric, mutable array and closures before expanding to
recursive trees, Map and Lexer. Record emission time, generated C bytes,
continuation/closure/heap syntax counts, Clang build time, exact runtime outputs
and sustained execution separately. A reduction in static syntax is explanatory
evidence, not a runtime result. Atom and scalar extensions should be measured
separately before combination is selected.

## Root execution commands

Production integration is separate from candidate preparation. After preserving
and closing the unchanged baseline, root may run `git apply --check` and apply
`atoms-v3.patch`. The first guarded checked build (repo root as cwd) is:

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 240 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase67/checked-atoms01-supervisor -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/tools/performance/phase67/native/build-config.json \
  selfhost/build/phase67/checked-atoms01
```

The workflow owns its CPU3 worker placement; keep its orchestration unrestricted.
Use a fresh output directory for every attempted build. The scalar patch is
relative to the original Phase66 source, not to the applied atom patch; either
apply its separately inspected incremental difference or restore the known
original bytes before applying it. Do not discard unrelated edits.

Once a checked attempt exists, prepare focused commands without targets:

```sh
python3 -B selfhost/tools/performance/phase67/native/prepare-focused.py \
  --attempt selfhost/build/phase67/checked-atoms01 \
  --toolchain-recipe selfhost/build/phase67/native-baseline02-recipe.json \
  --out selfhost/build/phase67/atoms-focused01 --stage atoms
```

Run the two exact commands from `plan.json` serially. The first uses the existing
checked workflow's independent TypeScript/native pair on three ownership,
parallel and closure fixtures. The second reuses the maintained native fixture
runner with only import/root/output substitutions, and checks explicit one/four
thread execution. The `scalars` stage adds total division, floating operations,
Nat overflow and bang-boundary controls. Existing paired smoke points, primitive
override controls and actual malformed/cancellation controls remain separate
admission requirements; this small selected gate does not silently claim them.
