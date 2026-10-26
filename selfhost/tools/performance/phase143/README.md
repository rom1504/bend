# Phase143 cold compilation experiments and qualified checkpoint

The checker/erasure/occurrence modules implement the optimization in checked
Bend. Host scripts package source, observe, supervise and compare; they do not
implement compiler semantics. The exact source, ordinary native N2 and complete
qualification are pinned in [candidate.json](../../../../implementation/phase143/candidate.json).
No installation or selection changes occur. See the
[report](../../../../implementation/phase143/README.md) for measurements and limits.

## Reconstruct the selected source

Run from the repository root, with restored authenticated parent source and a
fresh output directory. This reproduces the source bytes, not path-dependent
manifest bytes:

```sh
python3 -B selfhost/tools/performance/phase143/prepare.py \
  --out selfhost/build/phase143/replay-source01 \
  --module selfhost/tools/performance/phase143/checker/schedule-v01.bend \
  --module selfhost/tools/performance/phase143/checker/publication-v01.bend \
  --module selfhost/tools/performance/phase143/checker/prepared-v02.bend \
  --module selfhost/tools/performance/phase143/checker/gate-v02.bend \
  --module selfhost/tools/performance/phase143/checker/override-v02.bend \
  --module selfhost/tools/performance/phase143/occurrences/range-v01.bend \
  --module selfhost/tools/performance/phase143/occurrences/override-v01.bend \
  --module selfhost/tools/performance/phase143/erasure/core-v01.bend \
  --module selfhost/tools/performance/phase143/erasure/override-v01.bend \
  --overrides p86_plan_loaded nd_comb_fresh nr_walk
```

Expected source SHA256:
`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
The preparer asserts exact parent identity and unchanged proof/final-verifier
declarations. It does not certify checking or native qualification by itself.

Source-check through `phase111/check-api.py`, exporting `p88_cache_prepare`,
`p86_plan`, `p134e_plan`, `p134e_begin`, `p134e_next`, `p143cg_enough` and
`p143cb_program`. Use the ordinary guard below with a64MiB output limit for
this API operation. The frozen acquisition commands are in each guard's
`process.json`; every output directory must be fresh.

## Native cold comparison and qualification

One execution lane: CPU3,3GiB process-tree RSS,16GiB available-memory floor.
Full compiler output needs192MiB file limits. This measured workload uses the
unchanged Phase142 source as input, independently from the compiler executable's
source. A new N2 reproduction of the timing comparison can use:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase143/replay-cold01-guard \
  --seconds 630 --rss-mib 3072 --available-mib 16384 --file-mib 192 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p143-integrated-n2/program \
  --source selfhost/build/phase142/indexed-source02/compiler.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --expected-qbe selfhost/build/phase130/p142-indexed-emit01/program.ssa \
  --out selfhost/build/phase130/p143-replay-cold01 --seconds 600
```

The recorded candidate timing used N1; N1/N2 have identical machine objects.
Use the exact Phase142 N1 baseline with a separate fresh output for the control.
Build each result with `phase123/build-aligned.py --source OUTPUT/program.ssa
--runtime selfhost/build/phase128/runtime-borrow01/runtime.o --out FRESH --seconds 90`,
under its own guard. Count machine construction, supervisor/authentication and
verification costs separately; do not confuse emission time with an executable.

Qualification uses independently qualified137N3 to compile the new checked
source, builds N1, has N1 compile its own source with the first complete product
as oracle, and builds N2. `phase141/native-gate.py --image IMAGE --out FRESH
--set focused19` runs on both generations, then `--set full45` on N2. Each is
guarded once. N1/N2 agreement supplements independent source/oracle checks.

The small-request pairing script creates its own guards; **do not nest one**:

```sh
python3 -B selfhost/tools/performance/phase143/compare-requests-v01.py \
  --baseline selfhost/build/phase111/p142-indexed-n1/program \
  --candidate selfhost/build/phase111/p143-integrated-n2/program \
  --out selfhost/build/phase143/replay-small01 --rounds 3
```

## Fast controls and observation

The [checker](checker/README.md) and [occurrence](occurrences/README.md) guides
preserve separate old/new oracles and rejected variants. Final controls are
`checker/controls-v03.bend`, `checker/prepared-controls-v05.bend`,
`occurrences/controls-v03.bend`, `occurrences/range-controls-v01.bend` and
`erasure/controls-v01.bend`. Their exact composition/method snapshots and commands
are archived. These are finite controls, not mathematical equivalence proofs.

Use [retained-object profiling](profile/README.md) and the
[milestone pilot](milestones/README.md) for attribution. Active Bend ownership
and physical sample percentages overlap. Neither diagnostic replaces clean
timing. The milestone probe has only a small-input validation, not full-source
stage clocks.

## Matched hosted observation

The [execution audit](../../../../research/phase143/execution-backend-comparison.md)
explains timing boundaries and the native-C option. Full hosted observation hit
the3GiB guard in this campaign. The following is a reproduction of that bounded
attempt, not a promise of a successful full hosted comparison.

Run under the existing single resource lane, with fresh outputs:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase143/current-hosted01-guard \
  --seconds 930 --rss-mib 3072 --available-mib 16384 --file-mib 192 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase143/hosted-request.py \
  --api-report selfhost/build/phase111/p142-indexed-api02/report.json \
  --compiler-source selfhost/build/phase142/indexed-source02/compiler.bend \
  --source selfhost/build/phase142/indexed-source02/compiler.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --expected-qbe selfhost/build/phase130/p142-indexed-emit01/program.ssa \
  --out selfhost/build/phase143/current-hosted01 --seconds 900
```

For the historical matched control, change only `--source` to
`selfhost/build/phase137/integrated-source03/compiler.bend`, `--expected-qbe` to
`selfhost/build/phase130/p137-reproduce01/program.ssa`, and both fresh output
names. Keep `--compiler-source` Phase142: it identifies the compiler executable
under study, not its input. Other inputs are supported with their own pinned
independent expected QBE; no fixture-specific behavior exists in the observer.

`report.json` records authenticated inputs, whole-child elapsed/user/system time,
peak RSS, exit/deadline status, actual output identity and full byte comparison.
`stages.json` records disjoint Base/frontend/backend/registry compiler calls,
per-piece rendering and separately charged encoding/write/hash work.
`renderLoopInclusiveSeconds` overlaps those rendering components. Do not add it
again or subtract digest work from child time as though this measured a different
program. API acquisition, preflight authentication, final byte verification and
QBE/as/link builds remain explicit separate costs.

The output is streamed to `program.ssa`, including precisely the newlines marked
by Bend's `legacy_end`. Whole source/Base/carrier strings and whole compiler IR
remain live according to the checked API; the observer never joins the complete
QBE text. Failures preserve partial output/evidence without a successful receipt.
The supervisor's deadline is independent of synchronous Bun calls; the outer
guard supplies memory limits. Do not substitute the old 64 MiB file guard for
the current approximately 116 MB product.

## Evidence and replay limits

`summarize-v01.py` authenticates the frozen reports and produces metrics,
qualification and candidate identities; `costs-v01.py` joins all guarded costs.
These scripts write only fresh destinations. `archive-v01.py` freezes receipts,
controls, source/method snapshots, profiler bindings and selected native images,
then verifies every archived byte against its inventory.

The [evidence inventory](../../../../implementation/phase143/evidence01/inventory.json)
lists exact inclusions/exclusions. Large generated APIs, QBE and assembly are
reproduced from pinned sources/toolchains rather than all retained. Restore
required parent artifacts and authenticate their existing receipts before replay.
Native binaries are Linux x86-64 checkpoints, not portable release packages.
Receipts contain original absolute paths: relocation requires explicit path
rebinding and renewed validation, never silently edited historical identities.
Keep failed attempts and use new method versions/output directories for changes.
