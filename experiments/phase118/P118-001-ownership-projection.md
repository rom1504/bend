# P118-001 — preserve existing ownership plans in structured QBE

Status: positive focused evidence; broad/native qualification pending.

Hypothesis: the QBE runtime deficit includes discarded semantic information,
not merely QBE instruction selection. Projecting mature C construction and
observer plans plus checked sharing metadata will remove continuations, wrapper
allocations and ownership transfers across unrelated ordinary programs.

Parent/source identities and design:
[design](../../design/phase118/ownership-and-construction.md),
[checkpoint](../../implementation/phase118/checkpoint01.md).

Frozen ablations under `selfhost/build/phase118/`:

- `sized-screen01`: literal1–4-field helper calls.
- `runtime-only-screen01`: unchanged parent QBE, new runtime only; distinguishes
  code-layout effects from changed compiler decisions.
- `borrow-screen01`: root-preserving borrowed observers.
- `trmc-screen01`: allocation-only destination passing.
- `cold-screen01`: conservative whole-program constructor sharing facts.
- `combined-screen01`: all four transformations,36 passing observations.

Keep cold-only lexer's small regression and all failed declaration/affine
preparations. Constructor coldness must be transitive through duplicated outer
containers; sharing a child does not make its unduplicated parent hot. Deferred
tail sealing follows the previous parent's CID. Root liveness, private holes,
static storage and effect-provider identity remain separate obligations.

Next falsifier: cell reuse plus the unchanged original45, ordinary alias/deep
controls and whole-request compiler cost. A focused gain alone does not establish
general runtime parity or a cheaper research loop.
