# Worker11: remaining CPU and allocation costs

The next measured question should be a saved-output budget ablation, followed by
**direct emission of proved native constructors**. The profiles show live machine
fallback in records and substantial constructor cost in both programs. They do
not support blaming the whole remaining gap on either one.

This is read-only analysis of existing receipts; no target jobs were run for this
report. `diagnose-worker11/report.json` completed all 12 CPU/allocation profiles in
19.751676 seconds. Its SHA-256 is
`95db98b9c5f9b34ea9e7f3ff93e352f0adff42d0bd1932dfa95b8c6239a83e20`.
The predecessor diagnosis is `diagnose-worker05/report.json`, SHA-256
`c8044c5117ff2c815ea9e397e2503348443ceff5fd8016ffb8cf4249eb3d1638`.
Both paths are under `selfhost/build/phase45/` and are preserved raw evidence.

Worker11 API is
`319d06fd039a2ed51881ad824d5371c29ad3b41d332f4bb4906e256ce7c65bf2`;
the runtime remains
`e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb`.
The diagnostic protocol uses Node24.18.0, CPU3, 1GiB heap/2GiB RSS limit,
150ms warmup and 600ms sampled loops, 1ms CPU and 32KiB allocation intervals.
CPU and allocation runs are separate. Inspector/harness work is included in their
reported totals; profile execution times are not throughput benchmarks.

## Measured allocation change

Numbers are sampled allocation estimates divided by validated calls, **not**
retained heap or exact allocation counts. Worker05 and worker11 are separate runs
and multiple compiler changes separate them; this table does not isolate Nat.

| Point | Worker05 bytes/call | Worker11 bytes/call | Fresh TS bytes/call in11 | Worker11 / TS |
| --- | ---: | ---: | ---: | ---: |
| Map128 | 12,869,522 | 3,856,260 | 2,172,371 | 1.775× |
| Records256 | 16,226,734 | 5,520,397 | 2,712,430 | 2.035× |

Allocation profiles validated 172 worker11 Map calls and 106 records calls;
fresh TypeScript profiles validated 450 and 310. Sample/tree accounting warnings
remain in the receipts. The profiler retains both estimates and attributes by
sample weights; neither interpretation erases those warnings.

CPU samples weighted by their time deltas:

| Point | Worker05 GC share | Worker11 GC share | Fresh TS GC share in11 | Worker11 ctor self share |
| --- | ---: | ---: | ---: | ---: |
| Map128 | 10.519% | 9.212% | 8.380% | 11.032% |
| Records256 | 10.093% | 6.073% | 13.301% | 15.079% |

There were 498 Map and 516 records worker11 CPU samples. Different repetition
counts and JIT/sampling behavior prevent interpreting lower GC percentage as a
precise reduction in GC seconds per call. Eliminating GC entirely would not by
itself explain the remaining roughly 2.5–3× clean-timing gap.

## V8 and live components

Scanning every raw CPU-profile node found **no nonempty deoptReason** for either
candidate or TypeScript in worker05 or worker11 (eight profiles total). In
particular, the earlier worker02 oversized-function reason is absent. This is an
absence in the captured profile metadata, not proof that all functions optimized
or that no deoptimization occurred outside the sample window.

| Worker11 hot function / component | Map self CPU | Records self CPU |
| --- | ---: | ---: |
| Runtime ctor | 11.032% | 15.079% |
| Map.bit.go private budgeted wrapper | 12.039% | 6.102% |
| Map.bit.go native component | 3.723% | 4.566% |
| Map.bit.go.rec acyclic helper | 8.825% | 3.889% |
| String.cmp/fin native component | 4.235% | 7.437% |
| Map.seek.go native component | 3.828% | — |
| Char.cmp acyclic helper | 4.099% | — |
| U32.show.fin/go explicit machine | no named sample | 2.888% |

Component names are recovered from generated instance indices and the emitted
source-identity guard rows, not the diagnostic's broad `bench` ownership label.
Map.bit.go is instance23 in Map and19 in records; String.cmp/fin components are11
and7 respectively. The functions are shared library operations reached by these
programs; their names are explanations, not proposed compiler selectors.

Guard functions together account for 6.628% Map and 4.163% records self CPU
(local/scalar/region/string guard functions and string descriptor comparison).
This exclusive sum excludes separately attributed reflection builtins. Guards
matter more for tiny inputs, but these two large points do not justify making
risky guard elimination the main remaining performance project.

## Constructors versus continuation storage

The allocation profile attributes 39.255% of Map allocation and 21.098% of records
allocation to the Map.bit.go wrapper. The wrapper contains the shared-budget check,
then calls its native component; it also creates an argument vector on fallback.
**That attribution cannot distinguish these causes.** V8 may attribute allocations
from inlined native/helper code to the wrapper. A large wrapper allocation share
is not proof of budget exhaustion.

The named explicit-machine evidence is narrower and real:

| Worker11 function | Self allocation share | Estimated bytes/call |
| --- | ---: | ---: |
| Map: all named explicit machines | no attributed samples | 0 attributed |
| Records: U32.show.fin/go machine24 | 11.468% | 633,091 |
| Records: p37.records machine0 | 2.873% | 158,581 |
| Records: named-machine total | 14.341% | 791,672 |

These are whole function self allocations, including constructors executed in
those functions; they are **not a measured frame-only total**. Machine24 contains
allocating tail vectors as well as Chr/SCon construction. Machine0 suspends
non-tail list construction. Map's missing named frames do not prove absence of
fallback, because inlining and sampling can obscure it.

Runtime ctor itself owns 282,476 sampled bytes/call in Map and 330,933 in records.
Its argument arrays can instead be attributed to callers. Representative worker11
private code still does:

```js
const text = ctor("SCon", [char, tail]);
const pair = ctor("Tuple", [text, flag]);
```

Pinned TypeScript emits direct character concatenation and a direct tuple object
for the equivalent source. The selfhost character is usually a Unicode scalar
Number, whereas TypeScript carries a one-character String, so a later Char
representation experiment would be distinct from merely removing ctor dispatch.
The current private declaration region has 112 Tuple constructor sites in each
module, 19/20 SCon sites, seven Chr sites and 12/14 SNil sites. These counts include
both native and fallback code and establish shape prevalence, not execution count.

## Smallest useful next experiments

1. **Budget ablation, without promoting a larger limit.** Produce saved-module
   variants whose sole semantic edit is the private initial budget 32→64/96/128.
   Use a separate derivative to count each fallback entry and native maximum
   nesting on existing exact inputs. Keep those counters out of timed modules.
   Then use the same short rotated Map/records screen and allocation profiles.
   The current evidence predicts a clearer records effect than Map, but does not
   guarantee one. Larger budgets need default-stack deep/non-tail/error/reentry
   qualification before any source promotion; the benchmark's 4096KiB stack is
   not a default-stack safety proof.

2. **Direct typed native constructors.** Consume existing JWConstruct.layout:
   Bool and SNil literals need no argument arrays; an exact binary tuple can use
   its native array representation directly; Chr must retain checkedChar; SCon
   must preserve its existing character/string conversion and concatenation
   behavior. Nat already has typed lowering. Keep constructor ownership, error
   order, source demand and host guards unchanged. This removes generic ctor
   dispatch and some short-lived arrays for any admitted program using those
   layouts, without recognizing Map or records. Review the hostile-import/host
   contract before replacing observable conversion calls. A short independent
   Unicode/tuple/Boolean fixture plus existing boundaries and a 60-second screen
   should test the first slice.

3. **Only after attribution, scalar replacement across private calls.** The
   repeated tuple construction/projection chain suggests a general unboxed
   result or constructor-projection pass. It needs explicit ownership/escape and
   multi-result calling conventions across branches, not a Map-specific rewrite.
   It could remove actual pair allocations that direct ctor emission leaves.
   This is a larger change; profile the simpler constructor pass first.

The shared budget may also charge tail-only SCCs that cannot add recursive native
frames: U32.show.fin/go's native component is already a scalar tail loop. A general
proof that every intra-SCC edge is tail could permit a budget-free native entry
for that component while retaining the global budget on non-tail SCCs. This is a
separate bounded-stack proof and could avoid fallback without raising the global
limit. It is a candidate to investigate if counters show nested tail-only work
falling back frequently.
