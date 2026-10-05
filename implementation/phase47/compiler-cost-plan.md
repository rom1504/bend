# Phase 47 compiler request cost and size comparison

Prepared, not executed. The initial binding below uses checked array03 against selected Phase 45 worker23
and the pinned TypeScript compiler. This measures **compilation requests**,
separately from execution of generated programs. It does not compile the compiler
or perform self-emission.

Execution remains blocked on root's final candidate choice: array04 acquisition
is pending. If it becomes selected, use its exact attempt/preparation and a fresh
array04 output directory; array03 identities below are historical preparation
context, not permission to measure it as the selected result.

Default: **local-fold and lexer**, three rotated rounds,18 fresh requests. Fold
exercises the changed region; lexer is an ordinary nearby compiler workload whose
generated-output equality must be checked before calling it unchanged. Optional
`local-pair` adds local-row source coverage, bringing the screen to27 requests.
No closure/Map request is necessary for this bounded Array-only comparison.

## Reused protocol and bounded successor

Reuse [Phase39's parameterized planner](../../selfhost/tools/performance/phase39/compiler-cost-plan.py),
[Phase35's attempt/cache binder](../../selfhost/tools/performance/phase35/compiler-cost-bindings.mjs)
and the **unchanged** [Phase30 cost worker](../../selfhost/tools/performance/phase30/library-cost-worker.mjs).
Worker SHA256 is `f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42`.
The new [serial runner](../../selfhost/tools/performance/phase47/compiler-cost-run.py)
is a small successor to the Phase 35 runner because that runner hardcodes a
2048 MiB available-memory floor. It retains every per-request input/attempt/cache
verification, fresh process, independent expected-output hash and timing boundary.

The successor uses CPU3, Node24.18.0, stack4096, heap1024 MiB, RSS2048 MiB,
available4096 MiB, at most60s per child and 240s for the measurement campaign.
It owns the sole `ExecutionGuard`; do not wrap it in a second lock-taking guard.
Interrupted or incomplete campaigns retain their rows and cannot claim a complete
comparison. The wall budget includes runner verification and child startup;
preparation/priming is separate and must be reported separately.

Phase 45's old four-source run spent95.30s in requests but309.60s in its runner.
Full verification is a material cost. Two sources should fit roughly two minutes;
three may approach the 240s bound. These are scheduling estimates, not
measured Phase 47 results. Prefer18 complete requests over a partial27-request run.

## Exact inputs and acquisition

```bash
P47_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P47_COST_ROOT=/home/ai/bend2/build/publish/bend/selfhost/build/phase47/compiler-cost-array03
P47_COST_CASES=local-fold,lexer
P47_COST_ATTEMPT=selfhost/build/phase47/checked-array03
P47_COST_BASELINE=selfhost/build/phase45/checked-worker23
P47_COST_BASELINE_BUNDLE=selfhost/build/phase47/compiler-cost-baseline23/manifest.json
P47_COST_CATALOG=selfhost/tools/performance/phase37/catalog.json
```

The expected array03 API is
`f9cfc861081f70e1f9ee6054b938cc3ebbec060e7451c16f3a8d47d66fc9f5a4`,
runtime `82781f5c8cecb14df370112a210974f55d52e32fa34cd71bfb03caec5e4c1fc5`.
Worker23 API is `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c`,
runtime `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.
Both use upstream `018751270e800bc222a93dad7f257083ee53a5f7`.
If the winner changes, create a newly named comparison and explicitly bind it;
do not silently replace these identities.

The existing array03-fast bundle lacks lexer. Acquire a fresh selected subset
unless a later complete array03 preparation already supplies all requested cases:

```bash
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog "$P47_COST_CATALOG" --cases "$P47_COST_CASES" \
  --role candidate --attempt "$P47_COST_ATTEMPT" --node "$P47_NODE" \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 \
  --out "$P47_COST_ROOT/candidate"
```

For the baseline, either use a fresh **baseline-role** preparation with the same
command and worker23 attempt, or materialize exact saved worker23 outputs from
`selfhost/build/phase45/full-preparation-worker23/manifest.json`. The latter is
data-only: copy the selected module and adjacent emission receipt unchanged,
preserve the original manifest/preparation, record source and destination hashes,
and derive a new manifest whose sole role/module key is `baseline` instead of
`candidate`. Label it explicitly as old candidate acquisition reused as a new
baseline. The planner then verifies its exact old attempt/API/runtime/Base/driver
and expected output; do not relabel the historical receipt itself.

This data-only binding is now prepared at `$P47_COST_BASELINE_BUNDLE`, covering
all three optional sources. Manifest SHA256:
`666acb837fbe7431979dd0882e2d45876f619dc6f5a7b03b0ec80400974b5a3a`;
derivation receipt SHA256:
`a8033310174fde9b0a663d6a4b49e3ee4a77d9ea3e4c775130ac58524f4bfd4a`.
Eight files preserve the original manifest/preparation, three modules and three
emission receipts byte-for-byte. No compiler or generated program was executed.

The straightforward fresh-acquisition command, if a verified data-only binding is
not already available, is:

```bash
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog "$P47_COST_CATALOG" --cases "$P47_COST_CASES" \
  --role baseline --attempt "$P47_COST_BASELINE" --node "$P47_NODE" \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 \
  --out "$P47_COST_ROOT/baseline"
```

Reuse `selfhost/build/phase37/typescript01/manifest.json` for independently acquired
expected TypeScript bytes. The planner checks exact compiler/source/output pins.
Do not pass the archived Phase 47 baseline to the unchanged planner: its retained
archive reader expects Phase 39-specific provenance. Loose checked acquisitions
avoid that historical format restriction.

## Planner resource adaptation, then measurement

The existing planner performs read-only attempt/cache verification in two Node
children; it does not compile a program. Its own2048 MiB headroom constant also
needs a separately preserved policy derivative. Before running it, save a fresh
copy under the new cost directory with these exact changes:

- Preserve `HERE` as the original absolute `selfhost/tools/performance/phase39`
  directory, so unchanged relative worker/binder/catalog dependencies resolve.
- Change its single `ExecutionGuard(...available_mib=2048)` to4096 and its single
  config `availableMiB=2048` to4096. Do not change sampling, worker, bindings,
  validation or request boundaries.
- Pin the original planner and derivative hashes in a small derivation receipt;
  retain the derivative in the plan's consumed tools. Describe these resource/path
  changes explicitly. Inherited Phase 39/37 descriptive labels identify the method,
  while the exact bound attempt/API/runtime identities identify this comparison.

The following data-only preparation makes those substitutions, also pins the
unchanged parent planner, and records truthful derivative metadata. It does not
run verification, compilation or timing:

```bash
P47_PLAN_TOOL="$P47_COST_ROOT/plan-policy4096.py"
python3 - "$P47_PLAN_TOOL" <<'PY'
from pathlib import Path
import hashlib,json,re,sys
parent=Path('selfhost/tools/performance/phase39/compiler-cost-plan.py').resolve()
out=Path(sys.argv[1]).resolve(); assert not out.exists()
text=parent.read_text()
changes=[("HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];PROGRAMS=HERE.parent/'programs'",
          "HERE=Path("+repr(str(parent.parent))+");ROOT=HERE.parents[3];PROGRAMS=HERE.parent/'programs'"),
         ('available_mib=2048','available_mib=4096'),('availableMiB=2048','availableMiB=4096'),
         ("parent=old_identity(HERE.parent/'phase37/compiler-cost-plan.py')","parent=old_identity(HERE/'compiler-cost-plan.py')"),
         ('files=[Path(__file__),','files=[Path(__file__),HERE/\'compiler-cost-plan.py\',')]
for old,new in changes:
    assert text.count(old)==1,old
    text=text.replace(old,new)
text,n=re.subn(r"changes='[^']*'", "changes='Phase47 policy derivative: original dependency directory, 4096MiB headroom, explicit parent pin; worker, verification and timing unchanged.'",text,count=1)
assert n==1; out.parent.mkdir(parents=True,exist_ok=True); out.write_text(text)
ident=lambda p:dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
Path(str(out)+'.derivation.json').write_text(json.dumps(dict(complete=True,executed=False,parent=ident(parent),derived=ident(out)),indent=2)+'\n')
PY
```

Then run the preserved planner derivative and unchanged-worker measurement:

```bash
python3 "$P47_PLAN_TOOL" \
  "$P47_COST_ATTEMPT" "$P47_COST_ROOT/candidate/manifest.json" "$P47_COST_ROOT/plan" \
  --baseline-preparation "$P47_COST_BASELINE_BUNDLE" \
  --baseline-attempt "$P47_COST_BASELINE" \
  --typescript-preparation selfhost/build/phase37/typescript01/manifest.json \
  --catalog "$P47_COST_CATALOG" --cases "$P47_COST_CASES"
python3 selfhost/tools/performance/phase47/compiler-cost-run.py \
  "$P47_COST_ROOT/plan/config.json" "$P47_COST_ROOT/measurement"
```

The binder **requires an already validated API-specific disk Base cache**. It
does not prime it. The checked build/acquisitions normally create it before this
step. Missing cache is a preparation failure: prime through the normal typed
driver in a separate bounded job, preserve that receipt, regenerate the plan,
then start measurement. Never include the priming request in the reported rounds.
Normal loading/validation of the existing cache remains inside `inspect`, exactly
as in Phase 45. This is not a persistent in-memory compiler-service experiment.

For each source, order is TS/baseline/candidate, then baseline/candidate/TS, then
candidate/TS/baseline. Report medians and all three observations/ranges for
`requestMs`, host import, process wall, RSS and output bytes. Source discovery is
required to be exactly the selected source plus pinned Base. The worker freezes
the emitted output, compares its hash with the prior checked acquisition, and
revalidates the attempt/cache and all inputs after each request.

## Static source complexity and generated-size accounting

Use the unchanged configurable [Phase13 counter](../../selfhost/tools/performance/phase13/measure-complexity.py)
for physical/nonblank lines and bytes. Generate its explicit file-list config
from **each attempt's own frozen `src/compiler.json`**, not one shared module
list: a new module must count. Put manifest-listed Bend files in `active`, runtime
source files in `shared`, changed host support in a separate declared category,
and test/experiment infrastructure in `tests`/`experimental`. Do not double-count
the assembled runtime alongside all its source fragments.

```text
python3 selfhost/tools/performance/phase13/measure-complexity.py FRESH_COMPLEXITY_CONFIG.json FRESH_COMPLEXITY_REPORT.json
```

The Phase 32 counter is hardcoded to old commits/attempt names, so reuse its **count
definition**, not its command: UTF-8 `splitlines()` for physical/nonblank counts,
and anchored `^def\b`, `^law\b`, `^type\b` matches for top-level Bend declarations.
Add those three counts per explicit frozen file, sum by surface and rehash inputs.
Concept counts remain an explicit explanation of new obligations, not a regex
score or a count of new function names.

For each compared generated module, report full checked-library bytes and hash
for all three roles; give candidate minus worker23 bytes and percent. Also record
API image bytes and runtime bytes separately. Runtime-prefix differences can
inflate full-module deltas independently of emitted program code. If a program-only
split is wanted, reuse the existing checked generated-code analyzer and its exact
runtime/export boundary rules; do not subtract guessed prefixes or compare source
lines across minified and pretty-printed emitters.

The report should pair any runtime gain with compiler request change and generated
code growth. No full-corpus compilation-speed claim follows from two or three
sources, and no Phase 45 numbers should be used as fresh timing denominators.
