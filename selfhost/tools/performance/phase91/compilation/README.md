# Phase91: comparable current compiler latency

These methods refresh the installed Phase90 compiler's **JavaScript-hosted B1
and genuine B2** against the same pinned TypeScript compiler under Node. They
do not time the native compiler host or execute generated programs. Preparation
and measurement are root-only, serial guarded jobs; creating a plan is offline.

```sh
python3 -B selfhost/tools/performance/phase91/compilation/prepare.py \
  --out selfhost/build/phase91/compilation01 --check-only
python3 -B selfhost/tools/performance/phase91/compilation/prepare.py \
  --out selfhost/build/phase91/compilation01
python3 -B selfhost/tools/performance/phase91/compilation/run.py \
  --plan selfhost/build/phase91/compilation01/plan.json --target js --group prepare
python3 -B selfhost/tools/performance/phase91/compilation/run.py \
  --plan selfhost/build/phase91/compilation01/plan.json --target js --group clean
python3 -B selfhost/tools/performance/phase91/compilation/run.py \
  --plan selfhost/build/phase91/compilation01/plan.json --target c --group prepare
python3 -B selfhost/tools/performance/phase91/compilation/run.py \
  --plan selfhost/build/phase91/compilation01/plan.json --target c --group clean
```

`run.py` already acquires `ExecutionGuard`; do not nest another guard. Each
target uses CPU3, Node24.18.0, `--stack-size=4096`, a1024MiB V8 heap,2048MiB
process-tree RSS ceiling,4096MiB available-memory floor and90s child deadline.
Before each job the controller requires160MiB free disk. Inherited resource
limits disable core dumps and cap individual output files at64MiB.
The first failure stops its campaign. Preserve its plan and reports; use a fresh
directory for retries. A single-source smoke may invoke `worker.mjs` under the
ordinary guard after successful preparation: arguments are `PLAN js b2 sample
numeric-recurrence FRESH_OUTPUT`, with the plan's Node flags and CPU3 affinity.

## Historical controls retained

| Target | Sources and historical method | Ordinary request |
| --- | --- | --- |
| JS | Phase66 final07,23 exact source files from Phase60 catalog | Bend `D.inspect(file,{mode:'library',backend:'direct'})`; TS `book_load`, `book_valid`, `js_lib(book,true)` |
| C | Phase82 paired04, three Phase46 Numeric/Array/Lexer batch sources | Bend `D.inspect(file,{mode:'native',withReport:true})`; TS `book_load`, `book_valid`, `compile_book` |

Both use three rotated fresh-process rounds with no warm requests, compiler
profiles or diagnostics. The C batch programs are different from Phase90's
closed six-source screen. TypeScript uses upstream059266 under the exact
Node24 binary SHA41a74efb…, not Bun. The old results remain historical references:
Phase66 JS B1/B2 compilation1.402065×/1.321100× TS, and Phase82 C
1.67299×/1.32836× TS. A fresh ratio against TS is comparable in workload and
host; a difference between old and new separate campaigns is not a paired
causal improvement estimate.

`hostImportMs`, `apiLoadMs`, `firstRequestMs` and their sum remain separate.
The first-request clock encloses the ordinary request. Output hashes, file
writes, byte comparisons and observation checks happen afterward. Historical
JS workers included a few success assertions within that clock; this small
instrumentation difference is explicit. Import timing includes the same
compiler/host import; ordinary `D.loadApi()` is separately timed. Worker/process
startup and input verification are excluded from these clocks. No summed-clock
ratio should be relabelled as whole-process startup.

Base preparation occurs outside timing, as before. The JS project prepares
the eligible mandatory cache and optional annotation product. The separate C
project prepares only the mandatory cache. This prevents JS preparation from
changing the historical C product policy. Only976,940 bytes of frozen host
files are copied; compiler APIs, source corpus and historical oracles stay in
place. API-specific cache inventories must remain exact across measured calls.

## Identity and output gates

The creator verifies compiler07 checked-B1/equality derivation and actual B2
emission identities, frozen snapshot inputs, frontend36, driver8, source,
exports, API/runtime/Base and upstream source pins. It uses B1`6bf8e093…`,
B2`284f6e9b…`, source`4ffae2a3…`. It never labels the raw upstream-produced API
`cc481763…` as the selected derived B1. Historical compiler images are not
re-executed or averaged into the new roles.

Untimed setup emits every source separately for each role. JS must match the
retained Phase66 independently executed output for that role; TS C must match
the historical full C. Before any clean campaign, B1/B2 setup outputs must be
byte-identical. Current C intentionally differs from historical C, so setup
equality is a compilation-output gate, not new C execution qualification. The
separate Phase91 continuity/runtime lane supplies that evidence. Every timed
sample compares complete bytes to its setup output. Unique setup outputs are
retained; successful timed calls retain hashes and observations, avoiding234
duplicated artifacts. A mismatch writes its entire output before failing.

Full input SHA verification surrounds each campaign; workers verify selected
API/host/runtime/source/oracle/cache bytes. The plan retains provenance pins
without reserializing the entire provenance tree in every result. These are
finite benchmark results, not full conformance or general parity claims.

## Cost and method provenance

There are six setup jobs and234 clean jobs:207 for JS23 and27 for C3. Based on
the old campaigns, expect roughly3–4minutes for the JS clean lane and40–60s
for C, plus setup. These are estimates, not observed Phase91 times. Host/cache,
unique outputs and compact result/guard receipts should use well below30MiB.

The implementation extracts the ordinary call shapes and clock boundaries
from these immutable parents; it is a compact successor, not a byte-identical
copy of their large historical admission frameworks:

- Phase66 `selfhost/build/phase66/latency-method05/worker.mjs`, SHA
  `9bc11a1ac2919bbe1cda2cd3022645e0f04bbaf231ff25bd4b00bda27d2726ac`;
  runner SHA`1a2c707cc1cd4d331b2974c01e9fc467522c47ea24fc3d9a7d29061837204936`.
- Phase82 `selfhost/tools/performance/phase82/worker-v2.mjs`, SHA
  `045ce19ca51598d28295aa827d091c29cdf74a1f5549eb504342e58b4a81eb88`;
  runner SHA`2a091584c4c03f13b42e4ed6f7be45fcf37b1c147ab67f4278bb69ad5c9a050a`.

Offline actual-input preflight and Python/Node syntax checks passed. No compiler
or benchmark was run by the preparation agent. The initial offline preflight
found the historical semantic receipt uses `passed`, not `pass`; its explicit
schema assertion was corrected before any plan was written or target executed.
