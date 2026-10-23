# Phase128: faster native compilation through borrowed queries

**Native compiler request time falls 21.16% against qualified Phase126.**
Generated programs also improve 4.72% geometrically. The final compiler is
native-qualified through hosted → N1 → N2, with exact 102,187,679-byte QBE
reproduction and independent correctness gates. This does **not** reach parity
on compiler execution alone: requests remain approximately 2× upstream.

[Design](../../design/phase128/README.md) · [Compiler guide](../../docs/self_hosted/borrowed-native-queries.md) ·
[Candidate](candidate.json) · [Native results](native-results.json) ·
[Native checkpoint](native-checkpoint.md) · [Reproduction](../../selfhost/tools/performance/phase128/native/MEASURE.md) ·
[Research](../../research/compilers_architecture_and_techniques/phase128-fast-compilers.md).

## The metrics

All native requests use the frozen lexer, closures and Map inputs, CPU 3, three
rotated rounds and pinned upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
The TypeScript upstream runs on Bun 1.4.3. Ratios are within each block; separate
blocks are not pooled.

| Metric | Result |
|---|---|
| N1 source-to-QBE versus Phase126 N1 | **0.78836× time: 21.16% less** |
| Same block, compiler execution versus upstream | Phase126 2.55439× → Phase128 2.01378× |
| Separate qualified-generation block versus upstream | N1 **1.93696×**, N2 **1.91912×** |
| Request + machine-build child-stage sum versus upstream | N1/N2 **0.95712× / 0.94890×**; separate Phase126 comparison 0.98783× |
| Generated-program runtime, paired original 44 timed cases | **1.73444× → 1.65258× upstream; 4.72% less time** |
| Native correctness | Focused 19 on each image; ordinary 45 on N2; 405 correct runtime observations |
| New finite/ABI controls | 100 checked predicates; 545 independent late-field ABI checks |
| Compiler source size versus Phase126 | 55,285 → 56,904 physical lines (**+1,619, +2.93%**), including controls |

The ready-executable clock adds QBE/assembler/linker or C/Clang child stages,
excluding harness and generated execution. Native uses prepared Base and a
cached runtime; upstream compiles source Base and its C runtime. That established
comparison reaches approximate parity, but it is a different metric from the
still 2× compiler-request deficit. Hosted checked-API acquisition on Node is
another distinct cost, not the handwritten TypeScript upstream or native N1.

The broad runtime deficit also remains substantial: mean positive log-slowdown
falls 0.808172 → 0.759829; **40/44** cases still exceed 1.1× upstream and **21** exceed 2×.
Equal-family ratio improves 1.82890 → 1.72666×. Fixed-batch medians sum 22.100 → 20.660s
(6.52% less); positive excess falls 14.020 → 12.580s (10.27% less).
Twenty-five cases improve, 13 tie and 6 are slower. The largest slowdown is
1.34% on a ray variant. Morning improves 21.39%, tree-bitonic 10.96%; the main ray
case is unchanged. The historical metric and independent oracles are unchanged.

## What removed work

1. **Borrowed scalar queries.** Keep the owning roots alive once while a checked
   reader traverses fields. Initial counters on the unchanged compiler-name
   proxy show 91.74% fewer takes and 65.90% fewer destruction entries, with the
   same 63,613 allocations/frees and 187 dispatches. These are proxy counters,
   not whole-compiler percentages.
2. **Composition across helpers and inlining.** Readers call verified readers;
   concrete nested layouts preserve borrowed cursors. An exact thin-wrapper
   equation restores a useful call boundary that earlier inlining had erased.
   Merely admitting the nested reader had produced almost no gain because the
   hot caller bypassed it. No benchmark names select the transformation.
3. **Expose verified field loads to QBE.** The late template preserves tag/CID,
   RFC, scratch/status, aliases and fallback behavior. Its valid path avoids
   opaque helper calls. Static reader instruction counts actually increase;
   retained fallback code makes static totals misleading.
4. **Reuse immutable preparation.** Initial/late closure share the raw candidate
   list, retaining rejected candidates and original SCC treatment. One observer
   scan supplies workers, summaries and retry plans. Reachability filtering
   builds the existing exact-name membership index once.
5. **Propagate the Phase127 transport repair.** The qualified compiler now
   carries the corrected runtime-helper capability admission. Descriptor
   inspection finds the live-bank bit restored in 44/45 generated cases. Broad
   gains belong to the composition, not borrowing alone; isolated clearing
   evidence remains in Phase127.

Five clean paired kernel rounds give 1.490729s parent, 0.531184s after composition,
and 0.368798s with the field template: **4.04× faster overall**, still 3.61× upstream
on that computation. This justified full acquisition; it did not predict a
4× compiler speedup. The final compiler takes 10.52% less request time than the
already-repaired Phase127 image in a separate controlled block.

## Negative results, costs and simplicity

Skipping only ready flat candidates preserved QBE but showed an inconclusive
1.42% hosted request change. It is excluded. Sharing complete raw preparation
instead reduced the same-request Map integrated stage 11.31%, with exact complete
QBE on Map, RLE and tree; that measurement excludes frontend/preparation.

The constructor-provenance index proposal was stopped: existing index/search
precedence differs, and older short-request profiles put its cost below 1%.
Malformed early transfer/control fixtures failed before execution and remain
archived. Both upstream and self-hosted checking rejected the original transfer
fixture; correcting its explicit affine-list quantity fixed the fixture.

Source complexity increased. The reusable additions are checked borrowed-call
and concrete-layout facts, exact wrapper equations and a narrow late ABI template.
No universal IR, new machine backend or cross-request cache was added. The 10×
ambition was pursued through composition; the 100× representation rewrite was
not justified by this experiment.

At the final measurement checkpoint, elapsed research time was 152.84min, with
**50.26min in 90 guarded jobs**, 13 unsuccessful attempts included. Four bounded
agent investigations covered implementation, independent semantic review,
preparation/measurement bindings and compiler research; the root owned one
serial target lane. Outside-guard time includes investigation, editing,
documentation, hashing, commits and orchestration, not just waiting. Exact
token/quota usage is unavailable and is not inferred.

Final hosted emission took 512.39s, native self-emission 421.79 guarded seconds;
the [native checkpoint](native-checkpoint.md) separates remaining costs. Two
full hosted images and one native self-emission were acquired, rather than a
full build per small hypothesis. Peak guarded process-tree RSS was 3.44GiB,
below the 6GiB limit. Completed exact duplicates were hardlinked only after
comparison to recover disk space. No installed selection was changed.

## What we learned and what should come next

The useful lesson from Lean is ownership as a call contract. Zig and Go reinforce
resolving/preparing once and reusing bounded immutable facts. Our result shows
that optimizer composition and a missing capability certificate can matter
more than a different machine backend.

The next high-value step is a fresh profile of this **qualified** N1, then a
bounded test of removing repeated AST usage queries or checked-Base decoding.
Old profiles put decimal decoding at roughly 32% of the closures request and
`nq_uses` near 8% of Map; those are stale exposures, not current gain predictions.
For a larger change, test ownership-preserving AST queries across recursive
boundaries on an extracted compiler workload before redesigning representations.

There is no demonstrated recursive acceleration: faster source-authored
compilers are useful, but acquisition, qualification and research effort must
be amortized. Unchanged self-compilation reaches equivalent code; it is not
an optimization search. Preserve the cheap proxy/oracle loop and measure total
research cost when selecting the next architectural experiment.

Raw evidence is preserved in the [final capsule](evidence/final01/index.json),
the two earlier checkpoint archives and source-bound receipts. The archive
records original absolute paths as provenance; fresh relocated acquisitions
must bind their own local tool/source paths. See [checkpoint1](checkpoint01.md),
[checkpoint2](checkpoint02.md), [checkpoint3](checkpoint03.md) and the independent
audits for intermediate and rejected results.
