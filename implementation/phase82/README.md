# Phase82: fixed native request work

Status: compiler04 selected; integration qualification in progress. Phase78 is
still installed until those gates complete. No parity claim.

[Design](../../design/phase82/fixed-work-and-native-products.md) ·
[measurements](measurements.json) · [template producer](runtime-template.json)

## Result measured so far

The paired three-source comparison reduces fresh C request time **5.10% in B1**
and **6.15% in B2**. B2 is **1.328× TypeScript**, versus **1.415×** for the
unchanged Phase78 compiler measured alongside it. The older qualified Phase78
ratio was 1.382×; comparing against the simultaneous baseline avoids attributing
machine/run variation to this change.

| Source | B1 before → after, ms | B2 before → after, ms | TS, ms | B2/TS |
|---|---:|---:|---:|---:|
| Numeric | 1147.5 → 1094.0 | 1022.0 → 964.9 | 695.8 | 1.387× |
| Array | 1221.1 → 1128.1 | 920.9 → 860.5 | 702.7 | 1.225× |
| Lexer | 1664.8 → 1615.3 | 1282.7 → 1201.8 | 870.8 | 1.380× |
| Small, held out | 318.2 → 254.6 | 316.9 → 251.3 | 304.2 | 0.826× |
| 65 functions, held out | 659.1 → 599.7 | 648.8 → 551.0 | 371.5 | 1.483× |

The held-outs improve more: **20.7%/15.1% less B2 time**, respectively. Their
two-case geometric mean improves17.94%; keep that separate from the established
three-source loop. These are medians of three rotated fresh-process requests per
role/source, 75 intervals in the final paired comparison. The request includes
checking, ordinary reporting and C emission. Imports, explicit prepared Bend
Base, Clang and program execution remain separate. Every request reads and
verifies the new template asset inside its clock. No additional per-process
preparation is hidden outside that clock.

All **159 clean requests** across the six prototype/selection screens retain
complete C bytes and exact public observations after excluding file inventories.
The inventories intentionally include the canonical template when selected.
These finite screens establish compilation behavior, not universal conformance.

## What changed

1. **Prepare invariant runtime text once.** The existing Bend scanner produces
   five chunks from the canonical runtime. A small regeneration tool transports
   that result to JSON and records the checked producer. The host verifies the
   pinned artifact and runtime digests, then passes the parts to Bend. Macro
   prefixes change the first part. Bend still renders all sections and retains
   sequential substitution when prefixes or payloads contain suspicious markers.
   Custom/missing/modified assets and injected APIs retain the ordinary path.
   This avoids the measured43–66ms runtime scan, without adding a cached library
   graph or moving parsing/typechecking/lowering into JavaScript.
2. **Carry the source bound with its exact request.** The owned annotation
   merge already computes the maximum source binder ID. Its new index contains
   only those same definitions. Carry that bound into native validation instead
   of walking both index and declaration list again. Raw preparation has no
   bound certificate and still scans. Source ownership, main validity and layout
   checks retain their order; erased/generated facts do not supply this bound.

Maintained Bend source grows **69 physical /53 code lines**, from32,471/26,523
to32,540/26,576, still132 modules. The change adds a private runtime sum and
extends the existing request product; no new optimization framework or module.
The generated template duplicates runtime data, but is not handwritten source.

## Experiments and rejected work

- compiler01: checked build/frontend36 and Bend template generation pass.
- compiler02: template-only B1 screen saves1.87% overall, with Numeric unchanged,
  Array3.9% and Lexer2.4% faster. Small improves17.7%, functions65 5.2%.
- compiler03: checked build rejects a multiply consumed affine `prefix` binder.
  Preserve its diagnostic; no measurement or successful build is claimed.
- compiler04: correct binder usage and layout-check ordering; add exact bound
  reuse. Checked B1/frontend36 and genuine B2/driver8 pass. Selected candidate.
- compiler05: private erasure consumes already normalized annotation heads and
  stored constructor-field quantities. Both compiler stages produce precisely
  the same prepared bodies as ordinary erasure on three sources each. However,
  isolated request savings are only **1.68% B1 /1.38% B2** over compiler04.
  **Defer** the duplicate consumer and restore compiler04. Both patches, checked
  images, genuine B2 images and results remain preserved. This is not the larger
  fused per-function representation; that architectural proposal remains open.

Template-only and private-erasure screens use separate comparisons; their
percentages must not be added to the final paired gain. The small erasure result
shows that eliminating repeated normalization/field reconstruction alone is
insufficient to justify duplicating the consumer.

Two data-only qualification preparations exposed historical mutable driver pins.
The revised toolchain pins the selected snapshot. Historical C evidence verifies
its old driver against the exact immutable Phase78 snapshot, rather than the
changed checkout. All runtime/effect bytes remain mandatory equality checks;
the audited driver/asset transport changes are explicit exceptions to host-file
identity, and complete emitted C remains the executable-output gate.

## Qualification and remaining work

B1 and B2 each pass125 renderer controls, including malformed templates,
Unicode, injected markers and prefix fallback. Five driver transport controls
cover canonical, absent, corrupt, changed-runtime and injected-API paths.
Raw31/new14/word10/heldout2 are complete; native100, complete12-family C identity,
JS continuity, self-check/B3 and installed/relocated checks are being completed.

The three-source ratio still needs **24.7% less B2 request time** for parity;
B1 needs40.2%. A0.5× goal needs62.4% less B2 time. This phase does not demonstrate
such a large reduction. Its useful result is removing fixed work cheaply,
particularly for small editing-loop inputs. A larger native representation should
replace multiple traversals and intermediate graphs together; the rejected
consumer is evidence against expecting large gains from removing just one.

Raw evidence: `selfhost/build/phase82`. Methods and preserved prototype patches
are under `selfhost/tools/performance/phase82` and `experiments/phase82`.
One CPU3 target tree,2GiB RSS ceiling,4GiB available floor and1GiB Node heap.
No agents, PR comments or parallel target jobs. Detailed qualification and release
receipts will replace the pending status before this phase is complete.
