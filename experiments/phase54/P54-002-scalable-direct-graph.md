# P54-002: compact SCC and bounce analysis

Hypothesis: replacing per-node transitive closure with indexed graph traversals
preserves all direct emitter facts while reducing asymptotic work and retained
storage enough for compiler-sized inputs.

Falsifiers: changed component ordering, missing recursive/unknown-tail facts,
different output on admitted baseline programs, lost refusal diagnostics, or
compiler-scale resource use outside the bounded execution policy.

[Design](../../design/phase54/backend-cleanup-and-direct-bootstrap.md).
Keep the old bound for initial parity controls; qualify larger inputs before
changing it. Graph scale, compiler-image ABI and self-reproduction are distinct
gates. Failure at one must not be relabeled as success at another.


## Outcome

The replacement is retained in selected graph02 source. It uses explicit-stack
Kosaraju traversal, reverse propagation from unknown-call seeds, and one ordered
member list per component. Public component/ID/bounce queries keep their results;
the typed source scanner is unchanged. No neutral graph module or runtime ABI
was added. The code increases 94 physical / 71 code lines in `calls.bend` rather
than claiming that asymptotic simplification reduces line count.

Graph01 checked build and 15 graph cases pass. Nine scale/boundary jobs include
sparse graphs through 3,004 vertices, a predecessor 128-chain comparison and expected
resource refusals. Observed 128-chain graph analysis falls from 226.907 to 38.245 ms;
3,004-node chain analysis takes 470.318 ms in a process peaking at 482.3 MB. These are single
observations after compiler import, not a warmed benchmark or compiler-wide
speedup estimate. The old per-closure 65,536 work counter is replaced with a total
4,194,304-edge budget; the accepted dense-graph domain can therefore widen even
while graph01 keeps 512 definitions.

After that evidence, graph02 changes the source-selection, graph-validation and
exact-emitted-reach definition budget together to 4,096. Other limits remain 8,192
tail nodes per definition, 4,194,304 total graph edges, 65,536 exact-reach queued
names and 2,097,152 emitted characters per definition. Graph02's fresh 15 graph and
10 boundary controls pass. Five actual checked source chains with 128/512/513/1,024/3,004
declared functions also emit and execute `bench(37)=37`, including first-call
oracles. Acquisition totals 92.635 seconds; the 3,004-function case takes 43.714 seconds and
peaks at623,955,968 bytes process-tree RSS. These bounded runs are not steady
compiler-throughput measurements. The first two source-fixture failures remain
preserved; version 3 fixes Base import/declaration order without changing the
chain or its oracle. The [scaling report](../../implementation/phase54/scaling.md)
binds exact source patches, checked images and all individual receipts. A final default-entry
check also correctly refuses 4,097 graph vertices without raising its budget
(`graph02-refusal4097`); the 3.619-second process peaks at 455,180,288 bytes.
This verifies the production graph boundary, not a 4,097-function source check.

The original source, graph01 replacement and graph02 capacity delta are preserved
separately under `selfhost/build/phase54/scalable-graph01` and `scalable-graph02`.
The full 77-export direct compiler-image attempt still timed out at 240 seconds
without OOM. That is a separate failed migration gate; graph correctness and
sparse-scale success do not establish compiler-image completion or a fixed point.
No further emitter optimization is selected in this phase.
