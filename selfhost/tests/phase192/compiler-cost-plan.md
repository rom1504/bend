# Paired native compiler request cost

Prepare and run **after Phase192 native qualification**. This separates compiler
execution cost from generated-program runtime. It does not isolate an individual
optimization pass: the Phase191/192 compiler images and implemented capabilities
both differ. Report that limitation explicitly.

The existing maintained `tools/bench/bench.py` compiler runner already supplies
fresh-process clocks, paired role rotation, exact complete binary output checks,
CPU/RSS measurements and a total deadline. `compiler-cost-plan.py` only prepares
its metadata; it calls the maintained `request.py` planner and never executes a
compiler or reimplements compiler logic.

Use the fixed development sources numeric256, expression32 and tree-bitonic.
Two rounds run baseline/candidate then candidate/baseline for each case: twelve
requests total. No linking, assembler, generated-program execution, warmup or
source-specific output reuse occurs. Base remains prepared/cache mode for both.
Cold means a fresh process; OS caches are not flushed. Each role's raw ELF stdout
must exactly match its own frozen native45 object, and stderr must remain empty.
Different Phase191/192 object hashes are expected; cross-role object equality is
not required.

The helper authenticates complete native acquisitions and per-case oracle/build
receipts; rebuilds each exact argv with `request.py`; requires N2/native/x86
bindings to the respective selected compiler source; and requires equal fixture,
Base, carrier, stamp and linked runtime across roles. It pins both qualification
receipts but does not interpret them as an independent qualification proof.
The caller must finish and review native qualification before preparing this run.

Prepare using the actual final Phase192 acquisition/qualification paths:

```sh
python3 -B selfhost/tests/phase192/compiler-cost-plan.py \
  --candidate-build selfhost/build/phase192/NATIVE45_FINAL \
  --candidate-qualification selfhost/build/phase192/QUALIFICATION_FINAL/report.json \
  --out selfhost/build/phase192/compiler-cost-plan01
```

Baseline defaults are frozen Phase191 `native45-02` and
`implementation/phase191/evidence.json`. The candidate paths above are deliberate
placeholders until final native qualification; do not substitute checked hosted
API products. Preparation writes a recipe, frozen manifest and a `targetsRun:
false` receipt. No target lane execution is involved in preparation.

After lane admission, the existing guard/runner command is:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase192/compiler-cost01-guard \
  --run-root selfhost/build/phase192/compiler-cost01 --disk-mib 128 \
  --seconds 70 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/bench/bench.py run \
    --manifest selfhost/build/phase192/compiler-cost-plan01/manifest.json \
    --set full --rounds 2 --budget 60 --cpu 3 --guarded \
    --out selfhost/build/phase192/compiler-cost01
```

The target request budget is sixty seconds; the outer seventy-second guard
leaves report/cleanup slack. The original Phase191 requests took respectively
1.306, 1.417 and 1.830 seconds in native45-02. Repeating both roles at that cost
would require about eighteen seconds of compiler children; this is planning
evidence, not a prediction or fresh timing result. If the budget expires, keep
the incomplete report and do not replace the twelve-request plan with a favorable
partial score or automatically rerun it.

Report each role's two wall samples, paired median ratio, raw CPU seconds and
peak RSS. State the three-case geometric ratio only as this fixed compiler-cost
screen, never a native45 program-runtime or whole-compiler throughput result.
`bench.py` excludes complete-output comparison from each child clock; process
startup, source/Base reads, preparation/checking/lowering/emission and object
writes are included. Pin/hash preflight is outside child clocks. Two rounds
establish position balance and a small screen, not robust confidence intervals.

Authoring validation parsed the Python syntax and reviewed the maintained
runner/planner interfaces. The helper and experiment have not been executed;
candidate native qualification/products are pending. No new execution harness,
compiler pass or production source change was introduced.
