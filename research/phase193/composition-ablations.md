# Cheap composition ablations before another native reproduction

The composed candidate has reported full-source compiler-cost and image-size
regressions despite a generated-program runtime gain. The next decision is
whether public fusion, ready-tail transfer, or their combination pays for its
compiler work. Do not infer the answer from a helper-call count or the earlier
small compiler-helper kernel alone.

Two metadata-only extractions use frozen
`phase193/selected-source01/compiler.bend` (`6a3c990b…`) and the existing
`phase190/prepare-api.py` literal-constant transport:

| Role | Sole source override | Exact API source SHA256 |
|---|---|---|
| tail-only | `x193f_fusion_enabled=false`; tail remains true | `a86590ef770da9188aa2f00d18aa8880e7f219838d94a9965e4edb47f1d0069f` |
| fusion-only | `x193f_tail_enabled=false`; fusion remains true | `0332cc629877e5ba3ba3e2fafdec5cdbc829317134f340d1a8e5e8bd1ef14995` |

Both sources contain 1,797,084 bytes and 5,268 declarations, with the same seven
ordinary typed x86 exports. Reversing each recorded False→True literal edit
recovers identical 1,797,083-byte source, SHA256
`76a7ff90317f03a05c7a7f30eba50bec6346d20afedfa923afc5a72b9f01024d`.
No declaration replacement, maintained edit, or prior-receipt change was made.
Each fresh source directory contains its exact compiler source, manifest,
exports and prepared-Base binding.

Preparation commands (already executed, no targets):

```sh
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source selfhost/build/phase193/selected-source01/compiler.bend \
  --set x193f_fusion_enabled=false --assets selfhost/build/phase193/assets.json \
  --out selfhost/build/phase193/tail-only-api-source01
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source selfhost/build/phase193/selected-source01/compiler.bend \
  --set x193f_tail_enabled=false --assets selfhost/build/phase193/assets.json \
  --out selfhost/build/phase193/fusion-only-api-source01
```

[`composition-ablation-plan01/plan.json`](../../selfhost/build/phase193/composition-ablation-plan01/plan.json)
contains complete pinned source/binding/export identities and argv for four
root-owned jobs per role, in dependency order:

1. Independent `check-source.mjs` acceptance: 45s, 16MiB disk.
2. Checked `hosted.mjs acquire`: 60s, 64MiB disk, pinned Phase182 upstream/Bun.
3. Existing `emit-compiler-hot.mjs`: 60s, 32MiB disk, same unchanged 1,000-round
   ordinary user-source fixture and independent `2885372021\n` oracle.
4. Maintained `native.py` object link and independent stdout gate: 25s, 16MiB disk.

Each command uses the ordinary Phase193 guard wrapper and a fresh run root;
3072MiB RSS is allowed for source/API work. No nested guard, whole-compiler native
acquisition or N3 job is part of this plan. Inspect empty execution stderr as
well as the independent complete stdout gate. If admitted, compare the ablations
against the existing baseline and composed candidate with actual same-workload
timings; use the development requests to test transfer before paying for another
full native compiler. A faster kernel alone does not settle the full-build cost.

At handoff, all checking, API acquisition, emission, linking and runtime jobs
remain pending. Preparation performs source transport and metadata inspection
only; it does not inherit source checking or semantic qualification from the
unmodified candidate.

## Admitted ablation kernels and four-role timing

Root subsequently completed both ablation APIs, kernel emissions and linked
independent-output gates. `compiler-hot-ablation-plan.py` adapts the existing
kernel timing planner to `baseline`, `candidate`, `tail-only`, `fusion-only`.
All source/API/emission/native/oracle/runtime bindings remain pinned. The
prepared `ablation-timing-plan01` passes read-only preflight with 93 inputs.

```sh
python3 -B selfhost/tests/phase193/job.py ablation-timing01 25 16 \
  python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase193/ablation-timing-plan01/manifest.json \
  --out selfhost/build/phase193/ablation-timing01 --modes clean --rounds 20
```

The generic runner rotates roles over twenty clean rounds/eighty processes;
each role occupies every position five times. Every output must match the
same independent 1,000-round digest and empty stderr. This remains short-process
kernel timing, with no sampling or compiler-request claim. Preparation executes
no target. The outer 25s/16MiB guard includes report and hash overhead.

## Bounded-fusion composition source

`budget-api-source01` is prepared from the same frozen selected source, adding
`public-fusion-budget-experimental.bend` and replacing only `x193f_plan` via
`public-fusion-budget-hook.bend`. The hook is the exact original declaration
with one call changed from `x193f_candidate(...)` to `x193fb_candidate(...)`.
The existing planner still supplies the complete plan; the new profitability
consumer accepts at most `2 × original statements + 16` and otherwise gives
the original segment to the independent ready-tail path. This is a proposed
compile-time/code-size guard, not an established time saving.

```sh
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source selfhost/build/phase193/selected-source01/compiler.bend \
  --module selfhost/tests/phase193/public-fusion-budget-experimental.bend \
  --module selfhost/tests/phase193/public-fusion-budget-hook.bend \
  --replace x193f_plan --export x193fb_controls \
  --assets selfhost/build/phase193/assets.json \
  --out selfhost/build/phase193/budget-api-source01
```

`--export` appends to the seven ordinary defaults: the resulting eighth export
is exactly `x193fb_controls`. The manifest records one replacement and all
module/snapshot identities. Source size is 1,799,073 bytes/5,274 declarations,
SHA256 `b3dcb49121307971d12a88b1c5b64410aa22bc733cee1e50c2e0b07df8a2b586`.
The selected source still hashes to `6a3c990b…`; it was not edited.

This budget source requires its own source/API acceptance and finite controls
before ordinary kernel emission through the same existing adapter. Preparation
did not execute those gates or acquire an API. The seven results returned by
the exported budget control test the finite arithmetic boundary; they do not replace
machine/runtime checks of accepted and rejected fusion routes.
