# Phase49: what V8 retained in the RLE worker

The aggregate candidate removes temporary tuple allocation sites that V8 still
retains in the baseline. However, its shared scalar-return convention also
survives as context loads/stores, initialization checks and a write-barrier path.
The final candidate function has fewer graph nodes but slightly more machine
code and one more stack slot. This is evidence about the generated mechanism,
not evidence that the candidate is faster.

This analysis reads completed graph JSON and disassembly on CPU 0. It executes
no generated programs and changes no compiler or raw artifacts. The candidate
is the preserved scalar aggregate-transport experiment, not a newly installed
compiler. The public workload is the unchanged six-element RLE test,
`default['main.out']()` returning `11`.

## Bound artifacts

Paths below are relative to `selfhost/build/phase49/`. They name retained raw
files, not tracked GitHub downloads.

| Role | Graph path | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| Baseline | `graphs01/01-baseline/dumps/turbo-$native10-49.json` | 5,322,609 | `8affb43fcc3ae5247c13085b03290949b69dd06b56774dd58633d31cb132816b` |
| Candidate | `graphs01/02-candidate/dumps/turbo-$native10-50.json` | 4,551,284 | `c3fed7ea1ca32c73be5103c8eb4aca2149f322eb787c1d7c9467c6d4215ce2aa` |
| TypeScript | `graphs-ts02/00-typescript/dumps/turbo-$rle$-24.json` | 4,046,745 | `3e77b7115f07ab2f7ab5170dd88ad9239d8f7a1581eb9576663b16017569b59a` |

The graphs' `function.sourceName` fields identify the exact files below under
`selfhost/tools/performance/phase49/inputs/`, with the absolute checkout prefix
`file:///home/ai/bend2/build/publish/bend/`.

| Role | Module / SHA-256 | Function | Source offsets |
| --- | --- | --- | --- |
| Baseline | `baseline.mjs` / `d62ccfa7e27ef5124877c736b6ed4d39ee507b049b4a86e10b03c0c6b8530c4a` | `$native10` | 111252–111974 |
| Candidate | `candidate.mjs` / `f59106924fdc8022725ea8d722e600bd7d291a4aeb3f10525ea7b11505dfa835` | `$native10` | 111703–112697 |
| TypeScript | `typescript.mjs` / `f21a8eb4239ff0db7fbfda6121f24b04b48c5478fe6de5798660ca5b417c80a8` | `$rle$` | 5055–5829 |

All three target function records have `sourceId: -1`. Function names alone
are insufficient identities: names can repeat in different lexical regions.
These source positions, module identities and graph hashes bind the comparison.

The first TypeScript dump,
`graphs01/00-typescript/dumps/turbo-$rle$-24.json`, is **invalid JSON**, not a
usable partial optimization result: 3,975,818 bytes, SHA-256
`51ed43b643c9742a9045cd796eee655d9ca95568e2f2bda0548ed456399a20af`.
Python reports `Expecting value: line 31169 column 1 (char 3895053)`. Its exact
failure is preserved. The fresh `graphs-ts02` run completed with longer warmup
and call counts and no forced optimization. Process ending during concurrent
compilation is a possible explanation for the first file, not an established
cause. No counts below come from that invalid dump.

## Allocation sites before and after V8 passes

These are **static graph-node counts**, including both branches and inlined
helpers. They are not allocations per invocation or samples of a hot path.

| Phase / operation | Baseline | Candidate | TypeScript |
| --- | ---: | ---: | ---: |
| `V8.TFInlining`: `JSCreateLiteralArray` | 6 | 2 | 0 |
| `V8.TFInlining`: `JSCreateLiteralObject` | 4 | 4 | 10 |
| `V8.TFLoadElimination`: `Allocate` | 16 | 8 | 11 |
| `V8.TFEscapeAnalysis`: `Allocate` | 16 | 8 | 11 |
| `V8.TFTurboshaftBuildGraph`: `Allocate` | 16 | 8 | 10 |
| `V8.TFTurboshaftSpecialRPOScheduling`: `Allocate` | 0 | 0 | 0 |

The final zeros mean allocation operations have been lowered to bump-pointer
memory operations and allocation slow paths. They do **not** mean allocations
were eliminated. Every disassembly retains an `AllocateInYoungGeneration`
target, and the final graphs retain allocation-descriptor calls.

Both Bend graphs inline the same step helper, source/inlining ID `2`, named
`$R_36_105_110_115_116_97_110_99_101_46_55$tree`. At Turboshaft graph construction,
that helper contributes **11 baseline allocation nodes versus three candidate
nodes**. The remaining sources contribute the same counts in both graphs:
three at the main function, one at inlined helper ID `0`, and one at ID `3`.

The baseline step's false branch constructs a persistent pair and `Con`, then
two transient state tuples; its true branch constructs two transient state
tuples. The candidate retains the persistent pair and `Con` and returns state
through scalar storage. The four removed tuple sites each account for an
`Allocate[Array, Young]` shell and an `Allocate[OtherInternal, Young]` backing
store with the same source offset. Thus eight allocation nodes disappear from
the step. Escape analysis did not remove those baseline sites before machine
lowering. This rules out the explanation that V8 had already erased this
particular source-level difference completely.

The TypeScript compiler uses named-field objects for these tuples. Its inlined
`$rle$step$`, source/inlining ID `1`, retains six allocation nodes at Turboshaft
graph construction. Its whole-function count changes from 11 to ten between
escape analysis and Turboshaft construction; that alone does not identify an
executed allocation saving. The compared functions have different surrounding
graphs and compilation histories, so totals are not a like-for-like cost model.

## Scalar return storage remains observable to the optimizer

At `V8.TFLoadElimination` and `V8.TFEscapeAnalysis`, the candidate contains six
`LoadField` and six `StoreField` nodes explicitly labeled `ContextSlot`; the
baseline has none. All twelve survive into the final Turboshaft graph as
`Load`/`Store` nodes at the corresponding source positions:

- Four loads and four stores belong to the two step branches. The loads include
  lexical initialization checks before assigning `$workerValue1/2`.
- Two loads capture the returned values in the caller; two stores clear them.
- Stores of the list value use pointer/full write barriers. Numeric and clearing
  stores use `NoWriteBarrier` in the displayed graph.

In particular, candidate node `204` is a pointer-barrier store to context offset
40, and node `263` is a full-barrier store to that offset. The caller's clearing
stores are nodes `298` and `301`, at offsets 32 and 40. These IDs refer only to
the pinned final graph, not stable compiler API identifiers.

The captured variables have not become exclusively register/SSA transport.
The candidate disassembly materializes `FunctionContext[30]` and includes a
`RecordWriteSaveFP` slow-path target absent from the baseline disassembly.
Neither its presence nor static barrier-node counts show how often that slow
path executes. A stored pointer may avoid the slow path at runtime.

## Final graph and machine-code costs

The final graph phase is `V8.TFTurboshaftSpecialRPOScheduling`; code metrics come
from the `disassembly` phase's `Instructions` and `Safepoints` headers.

| Static property | Baseline | Candidate | TypeScript |
| --- | ---: | ---: | ---: |
| Final graph nodes | 493 | 398 | 376 |
| `Load` nodes | 43 | 27 | 39 |
| `Store` nodes | 99 | 58 | 75 |
| `Call` nodes | 7 | 12 | 8 |
| Of those, allocation-descriptor calls | 4 | 3 | 4 |
| Of those, uninitialized-variable throw calls | 0 | 6 | 0 |
| Machine instruction bytes | 2,448 | 2,516 | 2,180 |
| Safepoint stack slots | 16 | 17 | 15 |
| Safepoint entries | 7 | 12 | 7 |

The candidate's six extra throw-call nodes are
`ThrowAccessedUninitializedVariable` paths introduced around captured lexical
storage; they are not six calls necessarily executed by the workload. Other
calls include stack/interrupt checks. Counts include cold and merged control
paths. Candidate code grows by 68 bytes (2.78%) despite the smaller graph, and
its stack reservation increases from `subq rsp,0x58` to `subq rsp,0x60`.

These findings support a narrower diagnosis than “V8 erased the baseline
tuples”: the candidate removes allocation sites but trades some of that work
for captured-state transport and checks. The graphs do not prove those costs
cause a measured regression, establish actual heap bytes saved, quantify
ordinary public-entry guard cost, or represent fallback-machine/deoptimization
frequency. The separate CPU/allocation samples and clean repetitions are needed
for those questions. No source allocation count is substituted for a physical
heap-allocation measurement.

## Recomputing the counts

For each bound JSON, select a phase by exact name. For `graph` nodes count
`node['opcode']`; for `turboshaft_graph` nodes count `node['title']`. Count context
fields only when `ContextSlot` occurs in the full `title`. The custom-data
`Properties` phase immediately following a Turboshaft graph maps node `key` to
its detailed operation string; this distinguishes allocation and throw call
descriptors and barrier types. Resolve `sourcePosition.inliningId` through the
top-level `inlinings` map, then `sources`, rather than guessing from names.

The essential data-only count operation is:

```python
phase = next(p for p in graph['phases'] if p['name'] == phase_name)
counts = Counter(n.get('opcode', n.get('title')) for n in phase['data']['nodes'])
```

The source-position and disassembly checks above supplement those counts.
No optimizer behavior is inferred from a missing high-level operation after
that operation has been lowered into other instructions.
