# Host engines: controlled source comparison

**Bun improves upstream TypeScript's cold process time, but Node remains the
better host for our frozen B2 on this screen.** Native B1 wins five of six cold
cases against either TypeScript host. Map remains a large exception, especially
after repeated requests. Changing the comparison engine changes the denominator;
it is not a compiler optimization.

The [cold report](../../selfhost/build/phase89/engines-cold01/report.json),
[repeated-call report](../../selfhost/build/phase89/engines-warm01/report.json)
and [derived summary](engines-summary.json) retain exact inputs and calculations.
There are60 cold jobs (six sources × five roles × two rounds) and30 repeated
jobs (six × five × one process, with five calls). All90 jobs and all210 C-output
checks pass their assigned oracle: handwritten TS for TS roles; frozen B2 for
B2 and native roles. This does not claim TS and B2 emit byte-identical C.

## What was controlled

`phase89/measure.py` uses the identical `phase86/reference.mjs` source worker for
Node and Bun. TS roles load the same pinned `bend.ts`/`comp.ts`, build a fresh
book, load/check it and call `compile_book`. B2 roles load the same genuine
Phase82 B2 image and frozen typed driver, then call ordinary
`inspect(input,{mode:'native',withReport:true})`. Native uses the separately
qualified Phase88 native02 B1 and authenticated prepared Base, runtime chunks
and three effects. It is a native compiler written in Bend; it is not native B2.

Within each TS or B2 pair, the host executable is the deliberate change. Node
uses its established1GiB heap/4MiB stack flags; Bun uses defaults. Native includes
the later ownership/string changes and its narrower entry, so comparisons with
it are complete implementation/host comparisons, not isolated engine effects.
Role order rotates by source and reverses in cold round2. All jobs are serial
on CPU3 under the existing RSS/time guard. Two cold samples are a useful screen,
not a confidence interval; the repeated campaign has only one process per cell.

"Cold" means a fresh process, with existing prepared-cache files and ordinary
OS caches. Process wall includes imports, preparation, compilation and output
writing, but excludes Python preflight/authentication, Clang, and execution of
generated programs. Request clocks exclude imports and output-file writing.
Their preparation boundaries differ: TS loads/checks Base through the ordinary
fresh-book path; B2 uses its prepared-cache driver; native Base decoding occurs
before its request clock. Native also consumes the complete Bend result before
the end clock. These request ratios are not equal-work backend-only measurements.

## Fresh-process results

Per-source median process milliseconds across two runs; lower is better.

| Source | TS Bun | TS Node | B2 Bun | B2 Node | Native B1 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Small | 513.5 | 718.3 | 707.5 | 492.6 | 145.9 |
| Numeric | 615.4 | 800.7 | 911.2 | 676.1 | 207.0 |
| Lexer | 781.9 | 914.3 | 1,711.6 | 1,178.4 | 552.4 |
| Map | 1,115.9 | 1,179.5 | 2,631.4 | 1,707.9 | 2,190.1 |
| Functions65 | 678.4 | 799.4 | 1,186.8 | 880.4 | 308.8 |
| Unicode | 493.1 | 717.4 | 697.1 | 493.5 | 156.2 |

Ratios below are equal-source geometric means of per-source median-time ratios,
including Map. They describe the ratio of times, not the arithmetic mean of
percentage improvements.

| Comparison | Process ratio | First-request ratio |
| --- | ---: | ---: |
| TS Bun / TS Node | 0.7985× | 1.3821× |
| B2 Bun / B2 Node | 1.4215× | 1.2893× |
| Native / TS Bun | 0.5170× | 0.3482× |
| Native / TS Node | 0.4129× | 0.4812× |
| B2 Node / TS Node | 0.9672× | 1.2312× |
| B2 Node / TS Bun | 1.2112× | 0.8908× |

Bun's TS process time is20.2% lower despite a38.2% larger first-request time
ratio. The source worker's median import interval is25.1ms in Bun versus263.4ms
in Node. That measured startup difference explains why the two clocks favor
different engines; no more specific JIT/transpiler mechanism is established.
For the B2 image, Bun import is353.0ms versus141.7ms in Node, and Bun's request
is also slower. Node wins all six cold B2 cases on both clocks.

Native is faster in five cold cases, but Map process time is**1.963× TS Bun**
and**1.857× TS Node**. Its Map request is2,091ms versus1,049ms/791ms respectively,
or1.992×/2.644×. Keep that exception visible. The small-source wins and aggregate
0.517× do not establish universal compilation parity. Native prepared Base takes
a median58.5ms before its request clock in these runs.

The denominator effect is large: unchanged B2 Node looks slightly faster than
TS Node in cold process time (0.967×), but slower than TS Bun (1.211×). Conversely,
its first-request ratio changes from1.231× to0.891×. Neither change is a newly
achieved compiler gain, and neither should replace an earlier phase's metric
without explicitly changing the baseline and clock.

## Fifth requests: no steady-state claim

These are the fifth ordinary requests in one process, in milliseconds. Five
calls do not prove JIT/GC or allocator steady state; retain all five raw values.

| Source | TS Bun | TS Node | B2 Bun | B2 Node | Native B1 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Small | 174.4 | 188.3 | 87.5 | 94.0 | 57 |
| Numeric | 196.7 | 179.7 | 192.6 | 120.1 | 100 |
| Lexer | 222.7 | 256.1 | 526.2 | 289.6 | 536 |
| Map | 511.8 | 401.8 | 964.0 | 559.9 | 2,792 |
| Functions65 | 211.3 | 168.7 | 260.4 | 290.8 | 239 |
| Unicode | 177.8 | 190.6 | 90.8 | 59.0 | 55 |

Native Map grows2,103→2,792ms (+32.8%), while Node TS improves784→402ms.
The resulting fifth-call Map ratio is**6.949× Node TS**, or**5.455× Bun TS**.
Native Lexer also grows464→536ms, reaching2.093× Node TS /2.407× Bun TS;
Functions65 is1.417× Node TS /1.131× Bun TS. Native wins the other three cases.
An equal-source fifth-call native/Node-TS geometric mean is1.0003×, but presenting
that as parity would obscure these severe case differences.

The B2 Bun/Node fifth-call geometric ratio is1.3641×; Bun wins Small and
Functions65 in this single sample, while Node wins the other four. There is no
evidence for globally switching our compiler to Bun. Whole five-call processes
favor TS Bun over TS Node by0.8726× and favor B2 Node over B2 Bun (Bun/Node1.3708×),
but these mix startup with the five changing requests. The separate ownership
profile and [work-counter diagnostic](counts.md) address native repeat growth;
the engine screen does not establish an allocator or leak cause.

## Source pins and upstream executable probe

Full paths, byte counts, SHA256 hashes and six source hashes are in
`engines-summary.json`. Principal identities are:

- Upstream source pin059266225b77c8ca256ac6b25ee5c21449bab151;
  `bend.ts`1d133151… and `comp.ts`2b13224b…; common Base99ac43f2….
- Genuine Phase82 B2 API098320e8…; frozen driver8af64866… and runtime913b6a85….
- Native B1 binary5babec07…; checked Bend snapshot08ea6591… and C8a636bf1….
- Node24.18.0 binary41a74efb…; Bun1.4.3 revision`1.4.3+c6da4a4d3`, binary7ce7d6b6….
- Measurement script3d68ad8c… and worker174f07bc….

The separate [official release installation receipt](../../selfhost/build/phase89/upstream-install.json)
records Bend2.0.36 at target commit ae1101ca…, not the pinned source comparison.
Its Linux x64 binary b2b183bd… fails `--version` with SIGILL, confirmed by the
[guarded process receipt](../../selfhost/build/phase89/upstream-release-version-guard/process.json)
(`returncode=-4`,23ms). The embedded-Bun revision probe also failed. This host
does not advertise AVX2, making an instruction-set incompatibility plausible,
but no faulting instruction has been identified. Do not present that hypothesis
as the established cause or treat the failure as a source-compiler regression.
No released-executable performance claim is possible here; the successful
comparison uses the pinned source under independently installed Node/Bun.

The90 timed jobs occupy124.15s of guarded process wall time; peak process-tree
RSS is396.9MiB. Installation and analysis are outside that sum. All90 timing
jobs pass; the separate official-release probe failure remains explicit. No
additional targets, production changes or benchmark reruns were performed for
this offline analysis.
