# Native compiler execution owners

The profiler now connects physical instruction samples and runtime event counts
to exact native dispatch IDs and conditional lowered-definition owners. This
provides materially more information than naming `term_drop`, `memcpy` or a
large generated segment.

The six counter captures and 24 context captures were analyzed offline. Every
owner join checks the native descriptor and **every linked segment-table
pointer** against the QBE owner map: 44,615 FIDs for Phase125 and 46,991 for
Phase126. Each event's reported segment address also matches that table. All
six event captures are complete, with no counter overflow or invalid context.
All 24 sample captures have zero loss. Unknown contexts remain in denominators.

The compact [summary and artifact identities](owner-survey-summary.json) point
to full per-capture reports under `selfhost/build/phase127/owner-survey01/`.
The batch script and exact tooling snapshots are preserved there. Ordered sample
vectors remain in the original captures; this survey does not duplicate them.

## What the sampled contexts establish

Shares below weight samples by their actual sampling period. They describe the
diagnostic executable, not clean production timing. Closures has only 305 pooled
Phase126 samples, so its precise percentages remain exploratory.

| Phase126 request | Samples with known lowered owner | Main active-owner families |
| --- | ---: | --- |
| lexer | 1,035 / 1,071 | index 21.98%; Base decoder `p88_*` 17.41%; verifier `p111v_*` 15.21%; String 11.47% |
| Map churn | 1,628 / 1,695 | String 17.81%; Base decoder 10.36%; `nq_uses*` 10.06%; index 9.54% |
| closures | 290 / 305 | Base decoder 54.74%; index 7.05%; String 6.62% |

The grouping is an execution context, not an inclusive call tree. Synchronous
private calls retain their outer dispatch ID; separately dispatched callees
replace it. A parent pass can therefore be expensive even when almost no samples
retain the parent's own name.

### A fixed Base-decoding cost appears in every request

In all three Phase126 event captures:

- `p88_digits` has exactly **3,376,728 dispatches** and **80,603,485 requested
  register-clear words**.
- `p88_number` has exactly **1,620,345 allocation calls** and **4,536,966
  requested allocation words**.
- All `p88_*` execution contexts together have exactly **4,501,746 allocation
  calls** per request.

This is consistent with the shared carrier supplied to every command. The
[Base decoder](../../selfhost/tools/performance/phase88/base/decoder.bend)
reads canonical decimal integers from linked strings and reconstructs cursor,
number and state products. The
[cache-entry construction](../../selfhost/tools/performance/phase88/base/make-entry.mjs)
places carrier loading, decoding and seed construction inside preparation.

The next experiment should extract that exact decoder request, retaining all
malformed-input and carrier-authentication conditions. Test whether scalar
cursor/state preservation or a better authenticated carrier representation
removes the repeated product and dispatch work. Warm prepared-state reuse would
be a separate experiment with its own identity/invalidation contract; it must
not silently replace the frozen cold-request metric.

### Reclamation is concentrated in inspectable computations

For lexer, `index_bucket` has **7,498,341 term_drop entries** (20.62% of all
drop-entry events), `p111v_get` 4,312,191 (11.86%), and `index_find` 3,135,117
(8.62%). Sampled `term_drop` and `span_fade` leaves corroborate these owners:
`index_bucket` accounts for 3.83% of all weighted samples in those two helpers,
and `p111v_get` 3.15%.

[Verifier lookups](../../selfhost/tools/performance/phase111/segment/verify.bend)
hash linked names and call the shared persistent
[index](../../selfhost/src/core/index.bend). The measured question is whether
borrowed traversal/results or stable identifier summaries can avoid repeated
retain/drop and string/hash work. This is more specific than optimizing
`term_drop` globally, but no such transformation has been implemented here.

For Map, `nq_uses*` contexts have **zero allocation calls**, **8,939,038 drop
entries**, and **3,122,413 dispatches**. `nq_uses` alone appears with
`span_fade`/`term_drop` for 2.83% of all weighted samples. Its
[source](../../selfhost/src/back/native/product.bend) recursively counts variable
uses, saturating list sums at two, while eagerly traversing the remaining list.
A cheap next hypothesis is early exit after saturation, followed by reuse of
verified use summaries if repeated queries dominate. Preserve the different
branch semantics of maximum-use and minimum-use queries; this report is not a
legality proof or a speedup claim.

### String work is large, but allocation counts are not CPU shares

`String.append` and `String.order` jointly account for **42.69% of lexer
allocation calls** and **50.63% of Map allocation calls**. Map `String.order`
has 10.50% of weighted sampled contexts and 23.58% of reclamation calls.
String comparison, name representation and emitted-text construction are
therefore plausible cross-cutting opportunities. Their caller chains are not
fully recovered by active dispatch; use a small source/phase-specific experiment
before deciding which representation to change.

## Why clearing is not the whole Phase126 regression

| Event category, Phase126 relative to Phase125 | lexer | closures | Map churn |
| --- | ---: | ---: | ---: |
| Allocation calls | +2.48% | +2.72% | +18.09% |
| Requested allocation words | +2.07% | +2.52% | +17.27% |
| Drop-entry calls | +1.94% | +9.75% | +23.24% |
| Dispatches | −1.95% | −0.48% | +10.61% |
| Requested register-copy words | −3.23% | −1.08% | +7.58% |

Phase125 requests zero register-clear words. Phase126 requests 614,487,605 for
lexer, 236,753,496 for closures and 954,732,702 for Map. The separate
[physical caller audit](physical-caller-audit.md) locates the fill instructions.

Map also adds **3,248,550 String.order allocations**, **799,884
p118t_original_done allocations**, and **477,826 U32.show allocations**.
Its String.eq and String.order dispatch counts increase by 1,626,782 and
813,391 respectively. Restoring safe live-register-bank admission should be
measured as a distinct repair; it cannot be assumed to remove this additional
work.

The direct `p126bp_*` and `p113pl_*` sampled contexts are small. This does **not**
disprove repeated candidate preparation: their dispatched descendants are
attributed to those descendants. To measure whole-pass duplication, preserve a
separate, bounded phase context around preparation and compare invocation/work
counts, or use an exact-output ablation. Do not call the current owner table an
inclusive pass profile.

## Reproduction and remaining limitations

The generic event mode is:

```sh
python3 selfhost/tools/profiler/attribute.py \
  --events selfhost/build/phase127/events01/001-events-lexer-phase126-diagnostic/events.json \
  --binary selfhost/build/phase127/phase126-runtime01/program \
  --owners selfhost/build/phase127/phase126-owners01.json \
  --out /tmp/bend-owner-events-fresh
```

For samples, use `--analysis`, `--callers`, `--table`, and optionally `--contexts`
and `--owners`. The report includes leaf/caller matrices, dispatch/leaf matrices,
exact artifact bindings and original quality restrictions. Ten synthetic tests
cover malformed sidecars, wrong CFI intervals, changed table identity, linked
pointer order, receipt mismatches, invalid event vectors and unknown-count
denominators.

Runtime event counters change execution cost, can miss inlined operations, and
count requested work rather than CPU cycles. Drop entries are not traversed-node
counts. Allocation execution context is not allocation creation ancestry.
No optimization, production compiler change, or new target execution was made
by this offline survey.
