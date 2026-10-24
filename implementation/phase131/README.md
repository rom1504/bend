# Phase131 — laws, reusable analyses and complete borrowed computations

The integrated compiler is native-qualified. Across the three frozen compiler
requests it takes **20.92% less time than Phase130**, reducing the same-block
upstream ratio from **1.8248× to 1.4430×**. A separate same-source comparison
finds that the executable produced by the improved code generator takes
**10.64% less compiler-request time**. Broad generated-program runtime is approximately preserved:
**1.6627× upstream versus 1.6668×** for the contemporaneous baseline.

This is useful progress, not request or generated-program parity. The 1×/10×/
100× ambition levels in the [design](../../design/phase131/README.md) describe
research scope, not measured speedups. Parent commit: `9f7ab43`. Work began at
22:00:45 UTC on 2026-10-23; the requested minimum campaign duration is three
hours. Installed CLI selection and the previous qualified images are preserved.

[Qualified final candidate](final/README.md) · [Native measurements](native-results.md) ·
[Program measurements](program-runtime.md) · [Cost accounting](cost-results.md) ·
[Diagnostic archive](diagnostics/README.md) · [Proofs](../../research/phase131/laws.md) ·
[User guide](../../docs/self_hosted/analysis-and-proof-boundaries.md).

## What changed and why it helps

The common problem was useful facts disappearing between operations. We retained
them across complete queries rather than adding a new backend or universal IR.

1. **Reusable use summaries.** Two actual consumers share a sparse min/max-use
   summary for an immutable body instead of traversing the body again for each
   identifier. Sequence, alternatives and `NWPattern` keep their distinct rules.
   A proved first-order merge/lookup implementation avoids closure construction
   and repeated reconstruction of list heads.
2. **Complete index and catalogue loops.** Patricia insertion follows one path;
   closed index reads and catalogue traversals preserve state through their
   loops. Existing first-match payloads and unsupported behavior remain intact.
3. **Static constructors.** Closed `missing()` and literal atom constructors are
   exposed to the existing immutable pool. This removes repeated creation and
   destruction of compiler constants; it is not a new mutable global cache.
4. **Composed borrowed computations.** Verified shallow records, virtual helper
   results and scalar product projections now compose with actual retained
   worker candidates. Held roots, field origins and the owning fallback survive
   the helper boundary. The first eligible-but-unused plan was rejected after
   complete emitted QBE showed that it did no work.
5. **General selector admission.** Small literal selectors can remain in the
   verified worker path. This makes safe, ordinary Bend source economical without
   weakening the independent final verifier or changing the runtime.

The final source is SHA256 `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
It uses the unchanged Phase128 runtime and explicit Phase130 compact prepared
Base carrier. The compiler implementation and its optimization algorithms remain
in Bend. Host scripts assemble exact source variants, run independent checks and
record experiments; they do not implement a replacement compiler.

## Measurements and their boundaries

| Measurement | Result | Interpretation |
|---|---:|---|
| Final N2 / Phase130 N1, compiler request | 0.79079× | 20.92% less time; source and generated compiler both changed |
| Final N2 / upstream, same block | 1.44305× | Still 44.3% more time; needs another 30.7% reduction for parity |
| Final N2 / final N1, separate block | 0.89365× | Same compiler source; benefit from improved generated code |
| Final N2 / upstream, same-source block | 1.42683× | Separate observation block; do not pool with the previous ratio |
| Request + machine-build children / upstream | 0.71498× | Prepared Base/cached native runtime versus upstream C/Clang workflow |
| Generated runtime, candidate / contemporaneous baseline | 0.99754× | Approximately unchanged, not a broad speedup claim |
| Generated runtime, candidate / upstream | 1.66268× | 44 timed cases within the historical 45-program set |

The request clock includes startup, input/Base preparation, output and exit.
Native requests emit QBE, upstream emits C. The ready-executable child sum includes
machine building and uses the established distinct runtime preparation policies;
it must not be presented as compiler-request parity. Each compiler block rotates
three roles over three repetitions and three sources. This is a fast latency
screen, not a full-language throughput survey or confidence interval.

All three final request ranges lie below their Phase130 ranges. Map improves
30.46%, lexer 19.23%, closures 11.97%. The same-source N1/N2 comparison likewise
improves all three requests. This establishes self-optimization of a compiler
executable; it does **not** establish accelerating discovery of new optimizations.

For generated programs, all 405 observations pass independent outputs. The actual
N2 compiler reproduces all 45 measured QBE wrappers byte-for-byte, connecting the
hosted acquisition to native behavior. Mean positive log-slowdown falls only
0.769020→0.767276; 40/44 cases still exceed 1.1×, and 21 exceed 2×. Fixed-batch
runtime falls 0.44%, positive excess runtime 0.71%. A five-round follow-up finds
BST32 about 1.56% slower, RLE 0.43% slower, grid unchanged and tree9 1.25% faster.
Small regressions remain visible; fewer instructions or allocations are not
treated as sufficient evidence of faster execution.

## Native qualification

The qualified Phase130 native compiler emits Q1 from independently checked final
source. N1 emits Q2, and N2 emits **byte-identical Q3**: 107,059,385 bytes,
SHA256 `f3ff63b0…4b576e`. Q1 differs because it was generated by the older policy;
this is expected and recorded. N2 and N3 pass focused19; N3 passes ordinary45.
The frozen admission binds 98 finite predicates, exact proof-source bridges,
16 real Base-body comparisons, paired complete-QBE observations, transfer outputs,
source composition, retained independent verifiers and runtime identity.

Full-source guarded emission times were 490.76s for acquisition, 394.71s for N1
self-emission and 381.59s for N2 reproduction. These are single observations,
not an interleaved benchmark; acquisition also overlapped a separate correctness
lane. Native builds took about 15s each. Peak full-source process-tree RSS was
about 2.92GB. No ELF-byte fixed point is claimed. See the final capsule for exact
source, producer, runtime, carrier, gate and artifact identities.

An earlier [FAST checkpoint](fast/README.md) independently qualified and reduced
request time 6.11%. It remains a reproducible fallback. Its measurements occurred
in a different block and are not a controlled final-versus-FAST comparison.

## What the laws contributed

Fifty-seven distinct laws were independently accepted by the retained BendTT
kernel with actual proof bodies and zero opaque definitions. Exact source bridges
connect the selected arithmetic, absent-side behavior and first-order algorithms
to their proof inputs. Two type-correct wrong algorithms pass without laws and
fail the unchanged theorems. Proofs therefore constrain real implementation work.

The first safe closure-based summary was **2.564× slower** than the fast summary
on the extracted workload. We did not accept that cost merely because it was
proved. A first-order algorithm, proved equivalent for all finite input lists,
recovered performance to **1.026×** the fast version. Separately, the general
selector improvement reduced the unchanged closure-based source runtime by **59.36%**.
These are distinct experiments, not additive gains.

The laws also exposed a missing premise: arbitrary count 3 is preserved by an
empty-side identity, whereas a saturating combiner turns it into 2. The intended
summary contract therefore needs bounded 0/1/many counts. Full different-key map
correctness, KTerm traversal correctness and backend/runtime ownership correctness
remain separate obligations. A helper proof is not whole-compiler correctness.
Ten later laws establish both count-field bounds through the exact merge for
arbitrary differing-key maps. They do not prove ordering, `low ≤ high` or whole
analyzer semantics, and do not retroactively change the frozen admission.
Three new string-reflexivity laws support a later identity-shortcut experiment;
that experimental shortcut is not part of the qualified source. Two further
laws prove the exact scalar bucket-fusion equation for all finite KDef lists
and keys, including empty-key index-node matches. Its native experiment remains
separate from the selected compiler and the full-tree proof remains open.

## Small experiments that determined the composition

| Experiment | Measured result | Decision |
|---|---|---|
| Reused usage summary, 64 queried IDs | 27.4× faster extracted computation | Integrate; count construction and cleanup |
| Static missing value, mixed index queries | 9.81% less time | Integrate exact closed constants |
| Closed index read loop | 24.38% less time | Integrate after exact-output controls |
| Borrowed scalar product, short string/list | 48.3% / 44.8% less time than parent | Integrate composition; incremental projection gain about 10–11% |
| Actual `nq_uses` through shallow records | 19.42% less time | Integrate verified helper composition |
| Late preparation/reordering variant | Large proxy gains but duplicated preparation/code growth | Exclude |
| Mask unused borrowed fields | 745→635 machine instructions, runtime unchanged | Exclude; retain negative evidence |
| Private string identity shortcut | 0.28% proxy difference | Inconclusive; exclude |
| Owning string identity shortcut | 20.01% less proxy time; 2.93% less whole-request time | Unqualified two-adapter QBE ceiling; keep separate from selected source |
| Generic closed constructor factory | 17 controls and exact KTerm graph match | Promising coherence prototype, no production speed claim |
| Wider borrowed records | 32.48% / 41.03% less time on KDef / unrelated record queries | Four audited bounds; experimental, no whole-compiler gain claim |
| Proved scalar bucket fusion alone | 6.26% less time on one-entry leaf; collision stress approximately neutral | Mostly moves ownership work |
| Same fused source + wider borrowed layouts | 50.65% / 61.95% less time on one-entry / 64-collision cases | Existing capabilities compose; unqualified kernel result, QBE +4.40% |

The factory experiment can potentially replace 419 literal expansions with a
small existing-walk transformation. It needs an aggregate work/result budget:
per-callee size and recursion fuel alone do not bound duplication amplification.
It is not silently included in the selected source.

## Complexity, cost and next direction

Selected compiler source grows from 57,018 to **57,842 physical lines** (+824,
1.45%); code lines grow from 41,219 to **41,855** (+636, 1.54%). Proof modules,
experimental harnesses and raw machine evidence are excluded from these counts;
selected reference/control functions are included. The 419 constant exposures add
17,179 bytes but no declarations or physical lines. This is a concrete cleanup
opportunity, not a claim that source complexity fell.

The campaign uses eight bounded agents and one serial CPU3 measurement lane.
Proof/correctness lanes are resource-capped and labeled separately. We reused
the kernel, runtime, frozen oracles and profiler instead of rebuilding them.
Exact duplicate sharing recovered 838,934,528 bytes without deleting unique
evidence; unrelated later external disk recovery is not credited to this work.
Detailed cost and [refreshed-profile receipts](profile-results.md) accompany the
final report. Fresh absolute counters show23–23.4% fewer requested allocation
words and36–40% fewer register-copy words on lexer/Map. These describe actual
runtime hook traffic; they are not extra speedups to add to request timings.

The [fresh profile analysis](../../research/phase131/final-profiles.md) now
prioritizes verifier lookup/representation, transient Base-decoder state and
instruction-text construction. It rejects a large bang-analysis cache as a
priority: that family occupies only0.1–0.4% of current active-owner samples.
The owning-identity ceiling reduces three-request time2.93%, with no Map gain;
it remains unqualified and is not the missing30.7% needed for request parity. A separate [full-source profile](full-profile-results.md) shows a different
balance: reclamation29.4%, borrowed string equality10.0% and hashing1.73%.
Its107MB output matches the frozen oracle. The sampled360s is not a new clean
speed comparison. A separate [full context capture](full-context-results.md)
identifies repeated constructor-ownership scans: `nc_ctor_owned` occupies7.48%
of active samples, `lookup`5.43% and `f_find`5.20%. Its book scan plus nested
lookups is a concrete target for a version-bound ownership summary. These
contexts and physical fractions overlap; they must not be added.
General closed-constructor evaluation is the most attractive coherence cleanup. A universal IR, another backend, or a
large autonomous search framework is not justified by these results.

Research links: [initial profiles](../../research/phase131/profiles.md),
[usage](../../research/phase131/usage-audit.md),
[private regions](../../research/phase131/private-regions.md),
[projection](../../selfhost/tools/performance/phase131/projection/RESULTS.md),
[identity](../../research/phase131/reader-identity.md),
[field-mask negative result](../../research/phase131/field-mask.md),
[rendering audit](../../research/phase131/rendering-audit.md).


## Campaign close and next architectural direction

All planned target executions are closed. At the final target cutoff,372 guarded
jobs account for109.13 summed minutes and89.01 minutes of occupied wall-time
union across lanes. CPU3 accounts for71.72 minutes; full-source acquisition/
emission/reproduction costs35.92 minutes and the two full profiles12.45 minutes.
The snapshot spans175.68 elapsed minutes; later documentation, evidence sealing
and commits bring the complete campaign past the requested three hours.
Twenty-one nonzero jobs are explicitly labeled negative controls;32 other
unsuccessful/incomplete jobs remain visible. These are process-duration accounts,
not agent token/quota charges or a claim that time outside guards was idle.

The late composition result is especially informative: the proved source fusion
alone mostly moved ownership operations, while combining that same source with
wider borrowed layouts removed destructive takes inside the query. All twelve
paired output observations pass, with50.65% and61.95% less time in the two
extractions. The64-entry bucket deliberately stresses collisions; the one-entry
case transfers the mechanism beyond that stress. No whole-compiler gain is
inferred, and the independently qualified final source remains unchanged.

The user's next direction is saved in
[Phase132: incremental native development](../../design/phase132/incremental-native-development.md).
It calls for a precise QBE census, compact-symbol ceiling, native-first workflow
audit and a small sound incremental-build experiment before a broader architecture.
This phase did not implement an incremental compiler or a new backend. The new
full-source profiles and immutable semantic summaries provide concrete starting
points for that investigation.
