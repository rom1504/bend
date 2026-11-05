# Frozen mixed-route and imports-only findings

[mixed-metrics.json](mixed-metrics.json) consolidates the pinned JSON receipts.
No compiler, benchmark or archive operations were run for this consolidation.
The separate index-reconstruction experiment is outside this note. All ratios
below are candidate/baseline; lower is faster.

The conservative mixed route passes independent outputs on ten original IO
fixtures. Its clearest runtime gains are Mandelbrot and Unicode. The smaller
imports-only ablation reproduces those gains while retaining generic-body
construction, so skipped generic construction cannot receive credit for them.
The native compiler-request results are modest and mixed; these experiments do
not establish a large full-compiler speedup.

| Conservative runtime fixture | Median baseline → candidate, ms | Ratio |
| --- | --- | --- |
| local-fold | 337 → 337.5 | 1.0015 |
| closures-64 | 4.5 → 4.5 | 1.0000, unresolved |
| editdist | 253 → 252.5 | 0.9980 |
| lexer | 505.5 → 498.5 | 0.9862 |
| tree-bitonic | 914 → 922 | 1.0088 |
| mandelbrot | 701.5 → 605.5 | 0.8632 |
| unicode-text-16 | 271 → 239.5 | 0.8838 |
| record-aggregation-64 | 490 → 483 | 0.9857 |
| rle-roundtrip | 1021.5 → 999.5 | 0.9785 |
| map-set-ops | 811.5 → 776 | 0.9563 |

Each row has two pairs. The closures case is below useful timer resolution;
the table is a bounded screen, not a broad benchmark score. Machine/source
inspection finds existing direct workers reached through fewer dispatcher
boundaries, with unchanged inspected arithmetic/String workers and additional
forwarding wrappers. See
[runtime-mechanism.md](../../experiments/phase164/runtime-mechanism.md).

The broad-discovery and retained-original variants reproduce the conservative
candidate's exact QBE on local-fold, tree-bitonic and Map/Set. Both baseline and
candidate streams also match between broad and retained variants. Broad passes
28 finite controls; retained passes all 35. This bridges those three fixtures;
it does not rerun the ten runtime cases under every source revision.

| Complete native compiler request | N1 ratio | N2 ratio |
| --- | --- | --- |
| local-fold | 0.9767 | 0.9466 |
| tree-bitonic | 0.9880 | 0.9482 |
| Map/Set | 0.9888 | 1.0555 |

These are fresh-process source-to-QBE requests, two pairs each, with the same
source/Base/authenticated carrier and runtime. Every stream matches its own
independent hosted oracle and stderr is empty. Baseline/candidate QBE is
intentionally different. Cache mode retains the authenticated Base carrier;
fresh process does not mean rebuilding Base from source. Machine construction is
excluded. N2's Map/Set regression prevents a general gain claim.

The qualified compiler acquires the private N1 image in **201.931 s**; N1 acquires
N2 in **201.271 s**, on the **same 1,556,351-byte source**, hash
`77326516581c469a60cd5c8c0dd55a17615a2f4db4fc3863a284249b33391f91`.
These are single complete emission/QBE/assembly/link observations, a ratio of
0.9967. Historical qualified acquisition of **249.222 s** uses a different
**3,085,157-byte** source: it is context only, not a speedup baseline.

N2 then emits its own source in **179.548 s**, including output and teardown,
excluding QBE/assembly/linking. Its 104,739,601-byte QBE stream exactly matches
the predecessor-produced stream, hash
`adafabb40174a111aecf910d4e0725f3f6b203d5c1225b21a1f00bd05881488a`.
That is one exact self-reproduction observation, not semantic proof or a full
promotion qualification.

| Imports-only fixture | Runtime baseline → candidate, ms | Runtime ratio | Hosted backend ratio |
| --- | --- | --- | --- |
| Mandelbrot | 708 → 601.5 | 0.8496 | 0.8778 |
| Unicode | 270 → 236.5 | 0.8759 | 1.0092 |
| Edit distance | 252.5 → 252.5 | 1.0000 | 0.9781 |

Imports-only passes all 18 controls and all three independent native outputs.
Runtime has two pairs per case; hosted backend/render has one observation per
role. Its QBE grows: 908→948, 689→729 and 927→983 emitted functions respectively.
No imports-only native compiler acquisition was performed. It isolates a useful
composition interface without establishing compiler-build economics.

Frozen source manifests report 4,513 declarations for the conservative API,
4,539 for retained API, 4,603 for native mixed, and 4,494 for imports-only API;
all record protected declarations unchanged. The native N1→N2 static assembly
census counts `p111` segments 51,960→47,360, `p112w` workers 13,223→14,360,
`p113d` workers 2,096→2,096 and `p114r` workers 86→84. Linked images shrink
17,378,632→16,483,424 bytes. These counts describe emitted structure, not hotness
or attribution. The maintained compiler remains unchanged by these candidates.
