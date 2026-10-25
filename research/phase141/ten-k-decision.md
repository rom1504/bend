# Phase141: deciding whether 10k is a credible next target

**The evidence supports further bounded consolidation, not a demonstrated path
from 46k code lines to 10k.** Phase141 has removed 828 physical/606 code lines
from the Phase140 prototype. Of those, 530 are production algorithm lines and
76 are redundant test-helper lines. This retires two actual duplicate mechanisms;
it does not justify extrapolating their reduction factor to the whole compiler.

The current integrated source is
`selfhost/build/phase141/integrated-source02/compiler.bend`, SHA256
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
Its qualification is the coordinator's separate campaign. This note uses the
existing `census04` (preserved in the [evidence capsule](../../implementation/phase141/evidence/inventory.json)), selected
Phase137 declarations and the bounded backend/checked-output audits. No targets
or new implementation ran for this decision.

## Three actual active budgets

These are code lines, including required type/law declarations but excluding
blank/comment-only lines. Original-module responsibility is assigned by exact
`kind + declaration name`, then counted in the **actual qualified Phase137
source**, retaining overridden bodies. “Active” means the conservative closure
of 108 published driver roots, selected APIs, protected verifiers and proofs;
it is not a measured hot-code footprint. No budget below is a phase-prefix count.

| Mechanism group | Actual active code lines | Supported replacement conclusion |
|---|---:|---|
| Parsing/loading plus core/checking | **9,910**: 4,643 frontend/loading + 5,267 core/checking | Most is distinct grammar, elaboration, normalization, dependent/affine checking, indexing and world state. The duplicated parser was real and is now consolidated. No evidence identifies another thousand-line duplicate here. |
| JS optimization and emission interfaces | **10,244**: 6,352 shared/legacy facilities + 1,245 JS IR + 2,647 direct JS | Large, but both direct and legacy interfaces remain published. At least 1,139 lines in the shared/legacy group are also reachable from native `main`; deleting “JS code” would remove native optimization knowledge. No checked compatibility replacement has established a multi-thousand-line retirement budget. |
| Native/shared C-oriented lowering | **4,778**, of which 2,540 are reachable from native `main` | These are layouts, products, patterns, ownership, observers, static facts and C-oriented emission; they are not a disposable C printer. Later direct-QBE machinery adds more. Existing audits find a small shared recognizer, not a replacement for this whole group. |

Another **11,883 active code lines** belong to later source extensions outside
the original module-name inventory. That is an accounting remainder covering
several native optimization, verification, emission and prepared-input mechanisms,
**not one coherent subsystem** and not a deletion opportunity by itself. The
remaining original-module diagnostics/driver/common helpers account for 1,231
active lines. Together these reconcile to the qualified census's 38,046 active
code lines. Phase140 adds incremental mechanisms on top; it must not be confused
with the qualified Phase137 baseline.

A correction to the earlier prose inventory: `selfhost/src/compiler.json` lists
**132** modules, not 135. There are additional Bend files outside that list.
The census's 26,702 maintained-module code-line total was already computed over
the correct 132 entries; the mistaken prose module count does not alter the
source or active-budget numbers above.

## What the detailed audits actually permit

The [backend audit](backend-consolidation-audit.md) inventories the live local
recursive-region mechanism, rather than proposing a generic new IR. The complete
R/G/H implementation occupies **863 code lines**. Its demonstrably overlapping
recognition/admission/hygiene slice is **215 code lines** (283 physical), while
its three emitters and admission policies differ materially. A roughly twofold
reduction of that slice is plausible, so the credible next deletion is around
100 code lines—not half the full 863-line subsystem. Preserve the actual
H → R → G → H-with-extended-view → fallback selection order and compare complete
admitted/refused plans. No current profile supplies a compiler-speed ceiling.

The [checked-output audit](checked-output-audit.md) finds only **170 annotation
implementation lines**, plus 156 signature-law lines and a two-line type. Erasure
adds 56 implementation lines plus 13 laws. The checker already retains checked
children and specialized instances. Publishing final annotation at those sites
could remove repeated work, but doing so still requires quantity/layout metadata,
check-only policy, prepared-Base and raw-book API behavior. There is no inspected
replacement within an 85-line implementation budget for a twofold annotator
reduction. This cannot explain away thousands of lines.

The [static traversal experiment](static-traversal.md) provides the more useful
positive principle: closed `~` arguments can share source algorithms without
runtime callbacks. Phase141 applied it to a complete comparison family. It does
not establish that substitution, freshening, erasure and match traversal have the
same scope/reconstruction semantics. A new family needs its own exact retired
set, compatible interfaces, checked specialization and native-cost evidence.

## Decision

Do **not** launch a wholesale IR rewrite or promise a 10k compiler based on these
counts. No inspected candidate currently retires a coherent 1,000–3,000-line
active mechanism while preserving all public features. The largest measured
redundancies in this cycle have already been removed; the next audited backend
slice is smaller.

The next worthwhile simplification experiment is a bounded static, first-order
consolidation of the R/G/H recognizer, with a short stop rule: preserve complete
plans and chosen rendering, remove the old scanners, count every replacement
policy/helper, and abandon the large-gain claim if it cannot approximately halve
the 215-code-line slice. This is a modest cleanup, not a route to 10k by itself.

Before spending a larger campaign on a claimed thousand-line replacement, require:

1. An exact list of existing declarations and laws to retire, with public callers,
   failure/fallback behavior and unrelated workload coverage.
2. A bounded semantic correspondence showing those mechanisms express the same
   operation—not merely that they both walk a `KTerm` or emit QBE.
3. A complete replacement-size budget including adapters, output policy and
   validation, followed by actual source checking and generated-code cost.

If that evidence does not emerge cheaply, prioritize measured compiler-speed
work over an arbitrary 10k line target. Keep reducing the context needed for a
single task through a clear active module composition, but report navigation,
formatting and test separation separately from elimination of compiler concepts.
