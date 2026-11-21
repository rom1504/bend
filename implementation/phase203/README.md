# Where the native x86 compiler spends a cold build

**The native compiler took 292.71s to build itself.** The previous compiler took 316.19s on exactly the same trial source, runtime and prepared Base. Ranking register candidates once saved **23.48s (7.43%)**. Each full-build role ran once. The candidate reproduced its own 32,659,344-byte object and linked ELF exactly. This is a research image, with the installed release still available. [Fixed-point comparison](self.json) · [Native measurements](native.json.gz)

| Ordinary direct-object producer | Cold verifier, two runs | Full build of the same trial source | Link included in full time |
| --- | ---: | ---: | ---: |
| Phase202 | 8.019s, 8.053s | 316.187s | 0.274s |
| Rank once | 7.470s, 7.566s | 292.706s | 0.276s |

The verifier ran in baseline/candidate/candidate/baseline order and took 6.44% less time on average. Each run produced the same reference object, linked ELF and output. On 12 additional native45 cases, including the lexer, edit distance, tree, Map, closure and numeric workloads, all objects matched the frozen independent references and all executions passed their own oracles. Exact object identity preserves the generated machine code on these cases. We did not time their runtime anew or run a full release qualification. The trial adds five Bend definitions (42 source lines) and replaces two call sites. [Resource receipts](resources.json.gz)

We traced the Phase202 direct-x86 producer from source planning through writing its final object. The real compiler input was 44,896 lines, 1,973,225 bytes. Its output had to reproduce the complete 32,661,488-byte reference object. A smaller compiler-derived verifier supplied fast repetitions and an independent execution result of 768. [Phase202 baseline](../phase202/README.md) · [Reproduction](reproduce.md)

## Elapsed time and dynamic work

| Disjoint interval | Wall seconds | Borrowed hash calls | Register-selector lookups |
| --- | ---: | ---: | ---: |
| Request and Base | 0.240 | 0 | 0 |
| Source plan | 54.723 | 4,123,949 | 0 |
| Shared native preparation | 78.488 | 11,705,227 | 0 |
| X86 cursor and forward index | 0.037 | 4,111 | 0 |
| Private bodies | 18.161 | 9,530,842 | 1,570,066 |
| Public bodies and tables | 148.444 | 82,241,524 | 23,503,672 |
| ELF finish to output open | 12.386 | 1,156,758 | 0 |
| Output and teardown | 1.365 | 0 | 0 |

The hook-to-hook intervals sum to 313.843s. Startup outside the hooks brings compiler-process wall time to 313.899s. Linking took another 0.337s. The fully counted producer took 345.369s including link, so the stage timings use the separate timestamp-only producer. Both diagnostics emitted the exact frozen object. Their producers were assembled from the same listing with GNU as. Phase202's original ordinary direct-object self-build took 318.24s. This is one full observation per diagnostic variant. [Stage definitions and totals](stages.json) · [Timestamp trace](p203fullmarks01.json.gz) · [Counter trace](p203fullcounts01.json.gz) · [Probe definitions](instrumentation.json.gz)

On the verifier, the two counter runs agreed on all ending counter values. The two timestamp-only runs took 8.126s and 8.097s including link. The uninstrumented GNU-as producer took 8.140s and 10.493s. All six requests produced the same object and stdout. The workload mix shifts with size. Public emission and tables ran for 3.31s on the verifier and 148.44s on the full compiler. [Verifier runs](p203verifier01.json.gz)

## What happens at the handoff

Shared native preparation constructs QBE forwarder strings for an interface shared with x86. The x86 consumer then builds its own index from the structured functions and readiness table. On the full request, the first traversal examined 2,759 private functions and rendered 1,352 forwarders. The entire interval for this text construction took 0.094s on the full request and 0.0023s on the verifier. In contrast, 66.65s passed between entry to shared request lowering and receipt of the seeded program, followed by 11.12s to the registered stage. Those intervals cover multiple operations. They are measured boundaries for a narrower follow-up. The full x86 forwarding index consumed another 0.024s. Skipping both constructions would recover roughly a tenth of a second on this source. [Shared cursor](../../selfhost/src/back/qbe/early-emission.bend) · [x86 consumer](../../selfhost/src/back/x86/program.bend)

One borrowed hashing worker ran 108,762,411 times, with 1,566,212,472 visits to its string loop, including the terminal visit. Of the hash invocations, 92,933,235 happened after the shared cursor became available. On this request a direct call site inside the register selector alone invoked the name-table getter 25,073,738 times, 23,503,672 during public emission. These counts come from execution. An adapter and its implementation can both appear in a stack, so we count one specific machine entry or direct call edge for each reported quantity. Another 27,958,839 entries went through the counted table-update wrapper and 142,197,979 through its recursive insertion worker. Those insertion entries include descending the trie, so they are not distinct tables or allocations. Each name lookup can itself hash, walk a trie and extract a field. The counts give dimensions of work and cannot be added to obtain elapsed time.

The selector rescans names for the next highest-scoring stack slot, up to 32 times. Every scan looks up both the score and the slot for every name. The ordinary small-register allocator also calls this selector. Our experimental alternative covers the two 32-choice callers and keeps the small-register path intact. It computes the hash once per distinct name, preserves encounter order for ties, retains the 32 largest eligible positive scores and assigns exactly the original bit sequence. Its bounded, sorted list still costs up to 32 comparisons per name. That cost, allocation and the remaining callers make the elapsed-time result an empirical question. [Original selector](../../selfhost/src/back/x86/regalloc.bend) · [Callers](../../selfhost/src/back/x86/loop-liveness.bend) · [Bend trial](../../research/phase203/rank.bend)

## Legality of ranking once

The caller records each distinct name on its first read. With fixed scores and an unchanged slot map, repeatedly choosing the highest strictly greater score and clearing it is equivalent to taking the first 32 eligible names in stable descending score order. Zero reads never win. The new code uses the same hash function, starting value, key-equality check, slot predicate and bit assignment as the existing code. The maximum recursion depth for sorted insertion is 32. Encounter order, including for ties at the cutoff, is observable through register placement. Both algorithms operate on the original complete names. A hash collision still goes through the existing key comparison.

The upstream checker accepted the trial compiler with zero unresolved holes. The independent sorted-array oracle and the previous Bend selector agreed with the trial across 40 input sets and 606 selected positions. Cases included widths on both sides of 32, ties, maximum unsigned scores, missing or ineligible slots, zero scores and Unicode names. The comparator checked the complete output tree and individual bit masks. This is a bounded differential and a source check. A machine-checked universal equivalence theorem is still open. [Control receipts](controls.json.gz)

## Interpreting the comparison with bendc

A previous controlled experiment put the historical bendc checked build at 68.78s, of which 8.49s took it from source through C emission. Clang then did the machine compilation. The two compilers compiled different source and generated different intermediate products. Another experiment stripped 45% of our source bytes and saved 14% of one older QBE request. Together with these new execution counts, those results put the strongest case for simplification inside the algorithms that handle each emitted function. Reducing source lines can save frontend work, but it leaves most backend name-table accesses in place if the emitted functions stay the same. [Comparable build boundaries](../phase179/README.md) · [Source-pruning experiment](../phase161/README.md)

The machine sampler identified string and ownership operations before this experiment. Function-boundary timings and call counts located one source of those operations. Hardware simulation could inform a later comparison between two hot instruction sequences. It would need the number and distribution of actual inputs to explain why the compiler invokes an entire selector millions of times.

## What remains worth investigating

1. **Use a function-local identity throughout copy propagation and liveness.** Phase202's copy-name, copy-write and liveness-bit call sites together made 17.21 million direct name lookups. They are separate from the register selector measured here. Try resolving names once at entry to one public body, retain spelling for diagnostic and equality checks, and reuse the identity across those three consumers. Use this same verifier, the exact full object and a fresh stage profile of the faster candidate. The 17.21 million figure is a work count on the baseline. The seconds it could save remain unknown.
2. **Determine which continuations really need a public entry.** The 47,133 public dispatch slots included 39,744 anonymous continuations. There were 1,352 public identities with a separate private machine implementation, including 1,287 direct segments. The existing profiler's contiguous factory rule could validate only 2,298 of 3,085 groups, and none of the valid groups established a private direct worker coexisting with anonymous segments of that same owner. This leaves the important overlap unresolved. Carry the owner and fallback reason through initial lowering on the verifier and count actual required table edges before attempting deletion. [Assembly census and rejected attribution](overlap.json)
3. **For 37s, change both sides of the handoff.** Public emission and tables consumed 148.44s on the baseline diagnostic. Even eliminating that entire interval leaves about 165s. Source planning alone took 54.72s. The candidate gets us to 7.91× the target. A route that skips repeated body construction, together with cheaper semantic preparation, merits a bounded experiment. The current counts cannot justify a 7.91× forecast.

The full stage profile and operation counts describe Phase202. The 292.71s value comes from the ordinary successor with no hooks. The number of hash calls the successor itself eliminates has not yet been counted.
