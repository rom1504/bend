# Phase155 — twenty compilation-speed hypotheses

The parallel screen found **12 local wins, two neutral results, three losses and
three source-level rejections**. These are component experiments, not a new cold
compiler score. Production source and the qualified Phase152 image remain unchanged.

[Design](../../design/phase155/README.md) · [Metrics](metrics.json) · [Costs](cost.json) ·
[Independent audit](../../research/phase155/independent-screen-audit.md) ·
[Transfer receipts](transfer.json).

## All twenty outcomes

New/old is elapsed time for equal work in the same native executable. Lower is
better. Three alternating paired rounds; startup, setup, complete observation and
cleanup included. No percentage gains are added together.

| ID | Idea | New/old | Outcome |
| --- | --- | ---: | --- |
| [01](../../experiments/phase155/P155-001.md) | Return scalar width from fact lookup | 0.881× | win-screen |
| [02](../../experiments/phase155/P155-002.md) | Fuse width and version reads | 0.766× | win-screen |
| [03](../../experiments/phase155/P155-003.md) | Keep a computed hash through reads and update | 0.939× | win-screen |
| [04](../../experiments/phase155/P155-004.md) | Publish comparison fact and predicate once | 0.747× | win-screen |
| [05](../../experiments/phase155/P155-005.md) | Skip repeated canonicalization when private publication state is already canonical | 0.302× | win-screen |
| [06](../../experiments/phase155/P155-006.md) | Batch initial declaration installation with the existing exact overlay helper | 0.977× | neutral-screen |
| [07](../../experiments/phase155/P155-007.md) | Reuse constructor membership metadata across append-only successful declaration history | 0.268× | win-screen |
| [08](../../experiments/phase155/P155-008.md) | Observe width inside indexed fact lookup | 0.953× | neutral-screen |
| [09](../../experiments/phase155/P155-009.md) | Observe held descendant without escaping it | 0.705× | win-screen |
| [10](../../experiments/phase155/P155-010.md) | Reuse located constructor across metadata consumers | 0.392× | win-screen |
| [11](../../experiments/phase155/P155-011.md) | Fuse UTF-8 name-table traversal and QBE rendering | 1.108× | loss-screen |
| [12](../../experiments/phase155/P155-012.md) | Pre-size/chunk/destination output | — | rejected-static |
| [13](../../experiments/phase155/P155-013.md) | Render repeated local spellings once per owner | 1.665× | loss-screen |
| [14](../../experiments/phase155/P155-014.md) | Skip ready candidates before expensive lowering | — | rejected-static |
| [15](../../experiments/phase155/P155-015.md) | Share one flat-binding use summary across keep/live consumers | 0.569× | win-screen |
| [16](../../experiments/phase155/P155-016.md) | Fuse inline cleanliness, node-count and stack summaries | 0.775× | win-screen |
| [17](../../experiments/phase155/P155-017.md) | Replace the eager token list with a one-way fused lexer/parser cursor | — | rejected-static |
| [18](../../experiments/phase155/P155-018.md) | Fuse identifier syntax and exact reserved-word classification into one scalar scan | 0.362× | win-screen |
| [19](../../experiments/phase155/P155-019.md) | Direct dense scalar fact storage versus persistent numeric trie | 0.166× | win-screen |
| [20](../../experiments/phase155/P155-020.md) | Sorted sparse flat facts and bulk merge versus repeated trie insertion | 1.657× | loss-screen |

## Scope of the evidence

- **01–04:** unselected Phase154 facts representation, with exact supplementary
  structural checks. These do not optimize the current production fact engine.
- **05/07:** full publication/constructor-history results, with deliberately
  bounded provenance assumptions. Actual source-order transfer is separate.
- **08/09:** original KDef/KTerm lookup and immediate scalar consumers.
- **10:** a three-consumer composition ceiling, not a demonstrated hot caller.
- **11/13:** authentic captured names/operands; fused rendering and spelling
  caching lose. The already bounded renderer made12 redundant.
- **15:** a real duplicated use-set at the active flat-binding boundary,
  tested with a complete keep/live consumer but constructed input terms.
- **16:** ungated clean/size/stack tuple analysis; large calibrated bodies would
  be rejected early by actual inlining admission. Discount the apparent win.
- **18:** real lexer plus name validation of every token. The actual parser
  calls the predicate less often, so complete-parser transfer matters.
- **19/20:** linear mutable storage with invariant metadata and no persistent
  snapshots. The actual shared native image has capabilities5 (scalar-array
  flag with mask2 absent), matching the general Term-slot array boundary. Branch copying,
  escapes and full optimizer metadata remain outside this experiment.
- **14/17:** the active path already avoids14; naive lazy lexing17 breaks
  parser rewind/context/checkpoint contracts. Neither is a timing result.

## Correctness and cost

Shared source checking passed for42 API exports. Hosted controls passed121 paired
points and20 supplementary checks; the native run repeated those controls and
passed20 native supplementary checks. Timed outputs agree exactly. Independent
literal expectations and exact fact-table/publication observations complement
rolling timing checksums; these finite gates are not mathematical equivalence
proofs or whole-compiler qualification.

One 194,512-byte shared source produced a 2,963,584-byte native executable in
33.41 guarded seconds. First-pass timing/calibration/control work took63.31s;
a17.62s successor raised only the repetition cap for08/09/19, whose initial
runs were too short. The first insufficient-signal results are preserved.
The completed twenty-way screen consumed128.05 guarded seconds including source
checks, integration errors and controls. Follow-up costs are listed separately
below and in the final cost receipt. Agent effort and documentation are extra.

Seven agents prepared disjoint prototypes concurrently; one independent reviewer
challenged their assumptions. Root owned the sole CPU3 execution lane and shared
checking/build/measurement tools. No full self-hosting or broad45-program campaign
was run for these private screens.

## Transfer follow-ups

**Publication05/07: exact transfer passes.** A fresh checked API loads the real
37,696-byte compiler-verifier source and unchanged Map source, with pinned Base.
It preserves original source order, law/fill scheduling, event guards and
last-same-name publication. Both candidate replays match the entire reference
book/index/history/error/count/admission at limits0,32,all:603/504 events in the
complete cases. Seven additional admission/failure controls pass. The guarded
transfer took12.99s. Hosted clocks are diagnostics, not native gain estimates.
This is publication replay, not dependent checking with template/fresh-ID/world
mutations; clean-state provenance still needs a production invariant.

**Parser18: transfer stopped at the harness gate.** The first fixture representation
exceeded the upstream host's call stack; balanced256-character literal chunks
fixed source checking. Next, exact old/new results agreed but independent success
controls correctly rejected both: empty parsing scope lacked Base constructors.
The final557,308-byte source uses the real loader and pinned Base and passes
source checking. Nonzero controls then hit the hosted stack limit in `dg_width`
while traversing the full source. This is a harness limitation before successful
complete observation, not an observed candidate semantic failure. Stop here:
all failed attempts remain, no native transfer image was built, and18 remains
only a lexer-plus-classification screen. See the
[transfer notes](../../experiments/phase155/parser-transfer/README.md).

## What to do next

The strongest practical finding is that **removing object lifetimes and repeated
analysis can win, whereas reorganizing text or introducing a sparse cache can
lose**. Changing a representation name is insufficient:19 directly changes the
storage and update work, unlike the modest numeric-identity result in Phase154.

| Priority | Candidate | Evidence | Next cheap discriminator |
| --- | --- | --- | --- |
| 1 |05/07 publication provenance and constructor metadata |3.32×/3.74× local; complete actual603/504-event replay agrees | Instrument the real checker mutation boundaries; prove or falsify when canonical state remains valid, then measure the complete checking region |
| 2 |19 dense fact storage |6.02× complete mutable kernel, general Term-slot runtime | Replace storage in the retained Phase154 actual-owner producer; include full metadata, branch snapshots, joins, original verifier and whole-output equality |
| 3 |15 shared use-set |1.76× consumer kernel; active duplicated analysis | Extract actual flat-binding occurrences, including small/early-exit bodies; require byte-identical QBE and complete lowering-region benefit |
| 4 |09/02/04 lifetime and related-query fusion |1.42×/1.31×/1.34× local | Apply only inside a measured hot consumer; inspect native ownership/scheduler work and charge whole-consumer cost |
| 5 |18 identifier classification |2.76× lexer-plus-all-token validation | Use a stack-safe actual-parser fixture/observation; reject if real call frequency makes the complete gain negligible |

These are ranked experiments, not promised cold-build gains.05 and07 overlap;
19 may subsume01–04; do not multiply or add their improvements. The Phase153
33.57s checking/publication interval is a ceiling on that region's removable
cost, not a measured opportunity of33.57s. Likewise the101.45s backend region
contains many operations beyond fact access. Even a6× kernel win cannot justify
a6× whole-build claim without measuring its dynamic share.

Do not widen11/13/20: complete setup and cleanup turn those appealing ideas into
losses.06/08 offer no useful resolved win here.12/14 duplicate existing work.
17 needs a different parser protocol, so it is not a cheap implementation.
Discount16 until actual inlining admission is included. No architectural rewrite
or full qualification campaign is justified solely by this table.

## Final cost, reproducibility and decision

All 19 guarded jobs total **159.16s**: the main20-way screen128.05s and bounded
transfer follow-ups31.11s. This breaks down into33.41s native acquisition,80.93s
native screens,27.45s source checks, and17.37s controls/publication replay. Peak
process-tree RSS0.540GiB. One small native build,
no full self-build, broad benchmark suite, installed compiler change or production
source change. Guarded time includes failed source checks, controls and timed
execution; it excludes agent implementation, review, offline analysis, reporting
and retention. Seven preparation agents and one independent reviewer contributed;
there is no billing/quota telemetry, so these seconds are not total research cost.

All runs are classified and sealed through maintained retention, without pruning.
The [retention summary](retention.json) and [cost receipt](cost.json) preserve the
failed source checks, insufficient-duration screens and rejected parser controls.
The [evidence capsule](evidence/capsule.json) preserves exact input, generated-code,
executable and output bytes with deduplicated payloads and per-path hashes.
It requires the pinned external qualified compiler/toolchain to rerun; it is not
a standalone compiler distribution.

Reproduce the original shared screen with `experiments/phase155/prepare.py
--families facts,queries,publication,render,pipeline,frontend,storage --out FRESH`.
Execute its checked-source job first, then `controls.mjs` with that manifest and
a fresh output. Only passing families merit the native job and `bench.py`;
the frozen `bench-wide.py` successor changes only the count cap for08/09/19.
Use the same guard budgets and pinned assets as the receipts. Follow-up preparation
and complete limitations are in the publication/parser transfer READMEs.

**Retain all candidates privately; promote none yet.** The qualified Phase152 N2
and maintained source are unchanged. We now have a much broader, cheaper basis
for choosing the next optimization. There is no new whole-cold, upstream runtime,
general generated-program, mathematical proof or recursive-acceleration result.
