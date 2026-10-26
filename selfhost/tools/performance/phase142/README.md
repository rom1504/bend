# Phase142 experiments

See the [report](../../../../implementation/phase142/README.md),
[design](../../../../design/phase142/README.md) and
[experiment records](../../../../experiments/phase142/). These tools do not
change the installed compiler. Semantic implementations are checked Bend;
JavaScript observes exported results and Python packages/supervises artifacts.

## Reproduce a prototype

`prepare.py` composes explicit modules on the exact Phase141 source recorded in
`implementation/phase141/candidate.json`. It preserves protected verifier and
proof declarations and refuses undeclared overrides. Use a new output directory
for every attempt; old sources and failures remain immutable.

For conservative freshening reuse:

```sh
python3 -B selfhost/tools/performance/phase142/prepare.py \
  --out selfhost/build/phase142/my-fresh-source \
  --module selfhost/tools/performance/phase142/freshening/core-v02.bend \
  --module selfhost/tools/performance/phase142/freshening/loader-v02.bend \
  --module selfhost/tools/performance/phase142/freshening/session-v02.bend \
  --module selfhost/tools/performance/phase142/freshening/controls-v01.bend \
  --module selfhost/tools/performance/phase142/freshening/direct-controls-v01.bend
```

Acquire a checked API using `phase111/check-api.py` under `phase111/guard.py`.
The successful exact export list and command are in
`selfhost/build/phase111/p142-freshening-candidate-api02/report.json`, also in the
evidence archive. Change only the source/output paths for a new acquisition.
The ordinary scope requires CPU3,3GiB tree RSS,16GiB available-memory floor and
a90-second acquisition timeout. Do not run these measurement jobs concurrently.

Use `controls.mjs API_REPORT FRESH_OUT ROOT:COUNT...` with
`p142ft_controls:24 p142ffd_controls:12 p140vt_controls:25`. The first two test
the new contract; the last retains the old verifier controls. A source check
and finite controls do not establish native qualification or a theorem.

`freshening/loader-screen-v01.mjs API_REPORT OUT GUARD_RECEIPT` compares18 whole
loader results, including path changes, fresh IDs, Unicode spans, errors and
fallback. `freshening/session-paired-v01.mjs API_REPORT OUT ORACLE_REPORT
GUARD_RECEIPT` compares full compiler requests and checks transaction recovery.
Use the authenticated completed `same-request-screen01/report.json` as the
oracle report; its actual fresh-B products must still match their recorded hashes.
All referenced fixtures/tool identities are checked before and after execution.

`witness/assembly-v02.json` and `same-request/assembly-v01.json` specify the other
two independent prototypes. Do not combine them automatically: the first keeps
the independent second raw verifier; the second transports the original first
judgment through the audited unchanged representation.

## Timing interpretation

`screen.mjs` and `screen-v02.mjs` retain the initial separate-API experiments.
The unchanged-path control demonstrated that those comparisons can be biased.
Use a shared API and independent immutable A snapshots for small changes:
`same-api-timing.mjs` provides exact-original renamed reference wrappers for the
single caller override. The freshening screen needs no renamed wrappers because
every original declaration is unchanged.

Every timed request includes compilation, registry work, rendering, complete
text construction, hashing and writing. Machine construction is not included.
Seeding, warmup, API acquisition and independent-oracle acquisition are separate.
Keep every pair, ratio of medians, median paired ratio and order sensitivity.
Neither a high hit count nor an isolated component ratio is a native build gain.

`attribution-v02.mjs` reports disjoint request stages plus overlapping diagnostic
replays. Never add replays to stage totals. `attribution.mjs` is the preserved
first observer with a Bool-ABI reporting defect; its affected false/zero fields
are not compiler rejection evidence. `freshening-probe.mjs` uses actual pre-fresh
inputs; literal compiler-prefix fixtures are not executable compiler variants.

## One native warm-edit profile

`profile/prepare-context-v01.py` authenticates the retained Phase141 N2 object,
the exact runtime instrumentation lineage, sampler and independent full-output
oracles, then writes relink/capture commands. It does not compile the compiler.
Only the coordinator should execute its guarded jobs. The runtime counts are
disabled; the sidecar records the current dispatcher owner with physical samples.

Run the offline `analyze-context-v01.py` command only after the capture and both
complete QBE comparisons pass. Its conservative stage interiors account for
unknown wall time and unsampled CPU gaps. These are approximate CPU windows,
not exact stage timestamps, full Bend call stacks or clean performance results.

## Preserve evidence and cost

`archive-v02.py` stores completed receipts, checked source/module inputs and methods
with a verified archive roundtrip. Generated APIs/QBE and ordinary binaries remain identified
by receipts rather than committed wholesale. The native context executable and
owner map are explicitly retained for offline profile reanalysis. `costs-v02.py`
includes nested native-profile guards and sums completed guards
and their union, keeping failures visible without adding nested timers twice.
Neither tool measures unavailable agent tokens or quota consumption.

The versioned filenames are evidence identities. Fix a used method in a new
version rather than editing it and invalidating old receipts.

## Indexed traversal and native comparison

The [indexed traversal modules](layout-seen/README.md) are the only prototype
acquired as a new native image in this campaign. Their production overlay has
no control fixtures and changes only `jl_checked_error` and `kr_visit`.
Use `reach-seen/override-v02.bend`; v01 incorrectly repeated a type signature
on a definition with an existing law and is retained as a failed source check.

`layout-seen/component-screen-v03.mjs` executes54 independent controls and
compares complete ordered layout/reach results in the pre-override checked API.
Its bounded synthetic sizes are128/512; the earlier2048 run hit its total
75-second guard and remains explicitly incomplete.

The integrated `screen-v02.mjs ... 1 --ordinary-candidate` checks full fresh and
warm Lexer/Map QBE plus reversion/error recovery. Its separate-API times are
not a clean causal comparison. The native acceptance/refusal commands and
observer are in [native-controls](layout-seen/native-controls/README.md).

[Native comparison instructions](NATIVE_COMPARISON.md) authenticate the frozen
real compiler edit, both complete output oracles and the clean runtime.
`compare-native-v02.py` separates request stages, output materialization,
shared process/host costs and an optional once-measured identical machine
product. It performs observation only; no compiler decisions run in the host.
