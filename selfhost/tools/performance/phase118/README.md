# Ownership-aware direct-QBE experiments

[Design](../../../../design/phase118/ownership-and-construction.md) ·
[Report](../../../../implementation/phase118/README.md) ·
[Exact source recipe](../../../../implementation/phase118/source-recipe.json).

The selected candidate is `float-source01`, checked by `p118-float-api01`, using
`runtime-extend01`. The name records the final small projection, not the scope
of the combined optimizer. Cursor/reuse/scalar-observer alternatives are separate
experiments; do not select the highest numbered or most recently written file.

Compiler analyses, transformations and QBE rendering are Bend code. Host tooling
composes exact declarations, transports files, authenticates identities and
supervises experiments. The C additions implement explicit runtime helper ABIs.
There is no host-language semantic lowering or per-program C/cproc generation.

## Recompose the selected Bend source

`implementation/phase118/source-recipe.json` pins the19 ordered modules and exact
overrides. The parent is the selected Phase117 source. This command only composes
source, does not execute a compiler, and requires a fresh output directory:

```sh
python3 -B - <<'PY'
import hashlib, json, subprocess
from pathlib import Path
recipe = json.loads(Path('implementation/phase118/source-recipe.json').read_text())
command = ['python3', '-B', 'selfhost/tools/performance/phase118/prepare-v4.py',
           '--out', 'selfhost/build/phase118/FRESH_SOURCE']
for module in recipe['modules']:
    path = Path(module['file'])
    assert hashlib.sha256(path.read_bytes()).hexdigest() == module['sha256']
    command += ['--module', str(path)]
command += ['--overrides', *recipe['overrides'],
            '--module-overrides', *recipe['moduleOverrides']]
subprocess.run(command, check=True)
PY
```

The historical recipe records absolute paths from this checkout. Relocate paths
explicitly while preserving bytes on another machine; do not silently accept a
different parent, runtime, Base or toolchain. A composed manifest's `checked:false`
is intentional: the separate `phase111/check-api.py` receipt establishes checking.

Acquire a checked API under the serial root guard. Required integrated exports:
`p88_cache_prepare p86_plan p111_runtime_admission p111_emit_admitted`.
Diagnostics additionally use `p113a_lower_request p113a_verify`, transport/extend
finite controls, and optional observer-permission export. Keep exact checked
source/API provenance. Existing `p118-float-api01/report.json` is reusable after
authentication; there is no need to rebuild it for runtime-only experiments.

The selected cached runtime is the authenticated chain:
`runtime01 → runtime-cold01 → runtime-transport01 → runtime-bank01 →
runtime-u32-01 → runtime-extend01`.
Each report pins its exact parent, headers, compiler and command. Reuse the final
object on this checkout. Its capability-gated live transport and cold sealing
must match the generated descriptor; an arbitrary old runtime is not equivalent.

## Fast loops

Every target/compiler execution uses `phase111/guard.py`: one CPU3 lane,
2GiB RSS,16GiB available-memory floor,64MiB file ceiling, fresh output names.
No concurrent target runs. A guarded whole-native campaign has a separately
documented6GiB ceiling after a measured4.86GiB peak in the first acquisition;
the16GiB available-memory floor remains.
Frozen files may share hardlinked inodes; never modify them.

For a small semantic/compiler change, wrap the following commands in separate
guards. Use Node for these small hosted API requests; the full compiler request
uses Bun to avoid Node's host-stack limit.

```sh
P118_RUNTIME_REPORT=selfhost/build/phase118/runtime-extend01/report.json \
node selfhost/tools/performance/phase118/emit-integrated.mjs \
  selfhost/build/phase111/p118-float-api01/report.json \
  selfhost/build/phase118/float-source01/manifest.json \
  selfhost/build/phase118/FRESH_EMISSION \
  coverage-list-pipeline-128 lexer coverage-map-churn-128

python3 -B selfhost/tools/performance/phase118/screen.py \
  --emission selfhost/build/phase118/FRESH_EMISSION/report.json \
  --out selfhost/build/phase118/FRESH_SCREEN --label FRESH_LABEL
```

`screen.py` builds the candidate, then runs the original frozen candidate/parent/
upstream corpus definitions in rotated order. Complete outputs and iteration
counts use the unchanged Phase112 oracle. Three rounds are a screen; use longer
paired runs for tiny or ambiguous effects. The zero-work sentinel is not timed.

For runtime-only changes, `runtime-binding.py` authenticates existing QBE and
binds a new explicit runtime receipt; emission need not repeat. For unchanged
executables, `recheck.py` runs longer timings/profiles. `recheck-v2.py` optionally
accepts `--baseline-screen` to compare against another authenticated candidate
binary instead of Phase117. The report records that distinction. Profiles are
diagnostics; use clean runs for speed claims.

Ordinary semantic controls use `P118_CASE_MANIFEST=.../all-controls03.json`, the
same integrated emitter, then `functional-v2.py`. The19 cases include U32/F32
boundary outputs. `finite.mjs` invokes checked finite analysis controls; those
are separate from generated-code behavior and are not formal proofs.

## Cost, native qualification and limitations

[Matched hosted cost](cost.md) compares complete prepared requests under the same
Bun process, using a fresh same-source Phase117 API that actually exports the
same entry. `p118-parent-entry-api01` already provides it. Retain warmups, rotate
order, separate frontend/admission/entry/serialization clocks, and connect output
hashes to independent frozen emission. It is not native B1/B2 or upstream timing.

[Native qualification](native-qualification.md) pins the complete source/API/
runtime/toolchain and integrated-entry contract. The root executes the generated
plan, obtains N1, checks ordinary semantics, self-emits the compiler, builds N2,
compares raw hosted/native QBE, and runs N2 focused/full45 outputs. It is a justified
integration gate after broad benefits, not the ordinary iteration loop. No ELF
fixed-point, N2-to-N3 or production-install claim follows automatically.

The original program benchmark, native compiler-request benchmark, whole image
acquisition and hosted optimization-cost benchmark answer different questions.
Keep them separate in summaries. Three-round equality/outputs do not establish
formal equivalence or universal performance. No CPU-parallel/GPU qualification
or recursive research acceleration is claimed.

## Larger-source traversal repair and negative scalar experiment

`native-stack-safe-v2.bend` plus `native-pack-stack.bend` form safe-source03.
The latter fixes the captured eager-OR recursion in `nc_pack_foreign` with an
explicit complete DFS worklist. `stack-controls-v2.mjs` invokes40 checked
analysis controls, including32768-element cases. These do not deliberately
fail an old host or execute malformed native input. Read
[native-stack-diagnosis.md](native-stack-diagnosis.md) before treating ordinary
source recursion as a stack hazard: generated `nt_choose` tail calls trampoline.

The selected runtime remains runtime-extend01. The runtime-timed float-source01
and traversal-repaired source have separate immutable identities and composition
recipes. A byte-exact emitted-program bridge can transfer those program artifacts;
it does not relabel old compiler-cost measurements or prove native acquisition.

`dead-scalars-v3.bend` is an excluded experiment. Its24 finite checks pass, but
[the machine audit](dead-scalars-machine.md) shows that two newly exposed Boolean
selections grow the hot loop and regress the longer paired runtime by8.05%.
Keep its earlier failed host Bool driver and corrected driver distinct.

[The cost audit](hosted-cost-audit.md) identifies a new isolated
`eligible-staged.bend` candidate: lazily stop after observer admission is false,
retaining every acceptance gate. `cost-v2.mjs` permits an explicit authenticated
baseline selection; measurement order, warmups and output checks are unchanged.
This source is separate from the running safe03 qualification. Do not infer it
is in that native image.

[Time accounting](time-accounting.md) snapshots complete, failed and ongoing guard
receipts without launching targets. It unions intervals rather than adding
nested clocks, and does not infer model cost or quota. `plot-results.py` renders
all44 timed points from frozen JSON without new executions.
