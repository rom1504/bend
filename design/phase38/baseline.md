# Baseline for mining compiler research

All measurements below are inherited from Phase37; this research performs no
new compiler or generated-program timing. The installed compiler is checked03,
API `ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.

## Runtime and diagnostic evidence

| Workload | Remaining Phase37 / TypeScript time | Concrete diagnostic signal |
| --- | ---: | --- |
| Numeric recurrence | 3.338–7.382× | Private loop remains; BigInt countdown; entry guards |
| Tree bitonic | 57.117–64.794× | Generic recursive calls; about 23.08 MB allocated/call versus 1.37 MB TS at depth 8 |
| List pipeline | About 44–49× | `apply`, `force`, `invokeExact`, `callOwned`: 51.21% sampled self CPU at 512 |
| Active ray variants | About 71.6–87.7× | Host/scalar guards: 42.02% sampled self CPU at 256 |
| Map churn | About 91–106× | Earlier map profile suggests wrapper and allocation pressure; attribution needs a fresh focused probe |
| Lexer | About 81–91× | Generic recursive/string/word paths; missing mechanism isolation |
| BST | About 152–209× | Newly exposed gap; no Phase37 tuning profile |
| Expression / record families | About 42× / 60–72× | Newly exposed opportunities, not validated transfer cases |

Sources: [execution table](../../implementation/phase37/execution/report.md),
[profiles](../../implementation/phase37/profile-findings.md),
[opportunities and coverage limits](../../implementation/phase37/next-opportunities.md).
Ratios describe particular input points, not average Bend performance. Do not
average these ranges to describe the language.

At numeric 1024, estimated allocation is 51,441 bytes/call versus 125 TS;
list 512 is 2,783,284 versus 94,207; active ray 256 is 86,957,957 versus 1,057,393.
These are sampling estimates including collected objects, not live heap.
Numeric's new direct cast already gave 5.165× over Phase36 on that point.
Tree's installed improvement is only 1.165–1.270× over Phase36.

The earlier handwritten full-tree component was 2.604–3.559× faster than
Phase36. Its same-experiment advantage over finite-only output was
1.963–2.688×. Neither is an incremental measurement against installed checked03;
the latter is the closest existing support for our 1.5–2.5× tree planning range.
Transfer to maps/BST/lexer is unproved.

## Compilation and iteration speed

Normal checked requests for local row, tree and numeric take median
1742.898 / 1612.191 / 1319.924 ms. Their TS ratios are
5.609 / 5.536 / 5.060×. Phase37 increased request medians
2.47% / 6.40% / 1.06% over Phase36; the first two have disjoint sample ranges.
Import, cache behavior and verification overhead have separate boundaries.
[Exact method and samples](../../implementation/phase37/compiler-cost.md).

Checked build plus 36 focused probes took 42.175 seconds, peak about 1.14 GB.
The complete 45-point execution evidence took 1,056.32 seconds across four
runs and 669 samples. Existing modules make the inner execution loop much
cheaper: select cases under 20/60-second ceilings, acquire once after source
edits, and reserve full coverage for integration.

## Size and complexity

Production Bend source: **18,358 physical / 15,709 nonblank lines**, 70 modules,
2,045 definitions, 71 types and 640 laws. The JS backend directory alone has
16 Bend modules and 4,345 physical lines, counted read-only for this research.
The assembled runtime is 53,346 bytes; the selected generated compiler API is
1,181,753 bytes. Phase37 added 184 physical lines and 21 definitions.
[Production count](../../implementation/phase37/source-size-final.json).

Pinned upstream `comp.ts` has 6,468 physical lines, including C, GPU and JS
emitters/runtimes and shared compiler analysis. Its JS section starts at 3042,
with `js_sat` at 3055, `js_lib` at 3374 and `js_book` at 3405. The small section
is not a standalone compiler: shared spine, arity, type, graph and native
operation logic matters. The 3,869-line `bend.ts` supplies language frontend
and checking. Comparing only the small JS section to all selfhost code would
be misleading.

The useful complexity inventory is the number of representations and independent
proofs a change must understand: typed source, generic descriptors, exact entry,
private plans, purity graph, host dependencies and fallback. One new abstraction
is beneficial only if it replaces duplicated reasoning and allows old code to
be deleted. No external source establishes a 50% reduction target for us.

## Semantic baseline

Frontend retained observations agree exactly: 3,026 main plus 196 broader.
Backend outcomes are 69 pass, 8 not applicable and 4 shared failures. These
are separate scopes, not a single full-conformance fraction. Current release
is a checked B1 derivative, not a new self-emitted fixed point. Independent
proof-kernel validity and full native/GPU conformance remain unestablished.

Existing public behavior includes mutable function descriptors, host hooks,
partial/overapplied/raw calls, evaluation order, aliasing and tail stack bounds.
The pinned TS implementation is a same-language output/performance reference;
its private internals are not a replacement specification for our richer
descriptor compatibility surface.

The [local input identity manifest](../../implementation/phase38/local-source-identities.json)
records exact inspected source and selected generated-module bytes. Ignored
Phase37 paths are durably preserved by its [evidence capsule](../../implementation/phase37/evidence/README.md).
