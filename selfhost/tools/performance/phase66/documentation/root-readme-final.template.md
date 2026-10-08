## Compiler written in Bend

This fork ships the Bend2 compiler in [`selfhost/`](selfhost/README.md), targeting
upstream **`0592662` (Bend 2.0.36)**. Ordinary compilation runs Bend algorithms
without a TypeScript fallback.

**Phase66 attempt07 is installed and verified.** The installed package is checked
B1 `bb6c6e2a…`; independently emitted B2 `0067736c…` checks its own source and
reproduces B3 exactly. Direct JavaScript is the default; legacy JS and native C
retain explicitly documented limits.

Across 23 sources, B1/B2 compilation takes **1.402× / 1.321× TypeScript's time**;
including imports/API loading gives **0.983× / 0.990×**. These are fresh-process,
prepared-cache compiler clocks. {{PROGRAM_RUNTIME_SENTENCE}}

Frontend outcomes agree on all **3,174 observations**. Combined Node and scoped
Bun evidence has **1,045 distinct golden passes**, with 123 unprintable-main
exemptions, one shared process failure and one graphics deferral; there is no
TypeScript-passing candidate JS failure. Thirteen native API gaps and legacy effect limits
remain explicit. Type acceptance and self-reproduction do not establish proof
validity. Maintained Bend source is **28,490 physical lines in 115 modules**
(+0.331% versus the prior phase); host/runtime costs are counted separately.

Read the [five-axis report](implementation/phase66/README.md),
[installed-release evidence](implementation/phase66/evidence/installed-release07.json)
and [compiler guide](docs/BEND-IN-BEND.md). From `selfhost/`, run
`npm run verify:release`, then `node cli.mjs FILE --run`. The
[conformance record](selfhost/CONFORMANCE.md), [architecture](selfhost/docs/ARCHITECTURE.md)
and [experiment frontier](experiments/STEERING.md) document scope and next work.

