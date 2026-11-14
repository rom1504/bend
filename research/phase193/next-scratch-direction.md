# Next scratch direction: require a surviving private-cell witness first

**Do not add a broad scratch-promotion pass on the evidence inspected here.**
General promotion can remove memory traffic for genuinely nonescaping fixed
cells, including across calls which cannot reach their addresses. But the actual
Phase193 compiler owner traced below has no clone scratch buffer meeting the
current whole-buffer noescape condition. Its large frame is not evidence of
removable dynamic traffic. Definition identity for captured values is already
part of fusion. The promising missing cases overlap the bounded value-identity
work proposed in `next-opportunities.md`; they are not a new measured frontier.

This five-minute investigation read maintained sources and disassembled one
existing kernel owner. No target/compiler job, timing, source change or new
prototype was performed.

## What current passes already cover

- `scratch-forward.bend:x185_sf_body` forwards exact-width fixed cells within a
  straight-line region, preserving stores/allocas. It kills a fact when its
  source local is reassigned, clears calls except the exact inline-F32 summary,
  and clears branches/joins/backedges. At most 16 facts are retained. The
  overwrite rule preserves snapshots without introducing hidden version locals.
- `private-memory.bend:x186_m_scan` classifies complete buffer uses, including
  setup and both branch arms. A pointer used outside direct bounded loads/stores
  or the inline-F32 summary excludes the entire buffer. It deletes globally
  unread stores and unused body allocations, not observable cells or required
  read/write transport.
- `frame-forward.bend` forwards only an adjacent typed RBP store/load pair and
  keeps the store. It has no cross-call, branch or lifetime proof.
- Canonical fusion `fused-regions.bend:p112f_fused` already snapshots captures
  and helper arguments into uniquely prefixed `capture_N`/`arg_N` locals before
  the call. `p112f_inline` creates the separately named 2048-byte clone scratch
  allocation and binds captures/results. Merely adding definition identity
  again does not eliminate those values' genuine live ranges across calls.

## Actual owner: public p111v_put in the compiler helper kernel

Product: `selfhost/build/phase193/compiler-hot-candidate-machine01/program`,
public `p111_FID_$direct.p111v_put` at 0x4145a8. This is the authenticated kernel
candidate documented by `composition-machine.md`, not a claim about a later
budget-policy image. Its frame is 0x1980 (6528) bytes versus 2384 in the baseline.
The candidate directly calls atom twice and index_hash once.

| Storage | Actual machine consumers | What is removable under existing proofs? |
| --- | --- | --- |
| Clone buffer based at RBP−0x10c0, offsets 0..64 | Nine stores at 0x414652..0x4146e4; address passed in RDX to `p111_rt_ctor` at 0x41470c, count 9 | None of these field stores: the helper reads them. Buffer is address-exposed and current private-memory scan correctly refuses it. |
| Clone buffer based at RBP−0x18d0, offsets 0,8,16,24 | Four stores at 0x414732..0x414770; fast policy arm loads all four at 0x414795..0x4147bc; fallback passes address to `p111_rt_jump` at 0x414829, count 4 | Whole-buffer noescape promotion refuses. Fast-arm reloads are potentially forwardable, but stores remain necessary for fallback. |
| Scalar home RBP−0x8b8 | First atom result stored at 0x414634, survives second atom call 0x41464a, loaded as constructor field at 0x414690 | Ordinary across-call scalar spill; not an addressable scratch cell. Saved-register pressure/lifetime allocation determines whether it can stay in a register. |
| Scalar home RBP−0x8b0 | Retained capture stored 0x414619, reloaded as index_hash argument 0x414717 | Another scalar live range across real calls, already captured under fusion's unique names. |

There is consequently **no certified nonescaping clone scratch slot to promote
in this owner** using the present global buffer certificate. Calling a helper
“ready” establishes its selected scalar ABI/readiness, not a universal memory
purity or noescape summary. A helper receiving the buffer address must be modeled
explicitly; helper readiness alone cannot authorize dropping its stores.

The four reloads in the fast policy arm are a more concrete residual witness
than the 4096 extra reserved bytes. They are four LEA/load pairs; forwarding
would remove some or all eight instructions on that arm, depending on physical
homes. It would not remove the four argument stores, constructor fields, helper
calls, state-register publication or fallback. No new profile establishes the
owner's dynamic frequency or this arm's cost. Do not turn eight static
instructions into a percentage of compiler time.

## Smallest genuinely new experiment, if a broader witness appears

First collect only existing typed IR/assembly evidence for: a fixed cell whose
address never escapes anywhere; a store; an unrelated scalar ready call receiving
no address; and a later load that survives current forwarding. The whole-buffer
scan can supply the escape refusal. Snapshot the stored value under a definition
identity before later source writes. An unrelated call can then preserve that
cell's value fact while physical allocation still honors caller clobbers. If no
such surviving real hot chain is found, stop. Synthetic success alone does not
justify a compiler-wide pass.

A second, distinct experiment could carry incoming facts into a branch for a
known buffer while retaining both arms' stores and conservatively meeting facts
at the join. The p111v_put policy arm above is its cheapest machine falsifier.
It is branch forwarding, not full scalar promotion. Reuse/extend the existing
scratch traversal and bounded value identity rather than add another overlapping
walk. Whole-function SSA, arbitrary pointer aliases and MemorySSA are unnecessary
for that first check.

Refuse overlapping/mixed-width accesses unless modeled byte-exactly; reject
escaping or copied/derived addresses, uninitialized paths and buffer redefinition;
preserve stored-value snapshots, call clobbers, effect order, terminal returns,
branch joins and Again/reentry state. Never delete a terminal scratch store merely
because its immediately following argument snapshot was forwarded: later loop or
case entries can read old cells before an overwrite. Existing H tail-suffix
analysis in `region-control-frontier.md` already records that missing proof.

## Economic boundary and prior negative evidence

Phase192 scoped H-frame work widened known-buffer lowering to expand runtime
frame helpers. It was not general private-cell promotion. Six helper sites
vanished, yet the screen was mixed (tree/expression improved, lexer regressed)
and the additional compiler traversal cost remained. Reintroducing that expansion
under a “scratch” label would repeat the rejected experiment. Likewise shrinking
2048-byte reservations alone does not prove fewer executed loads/stores.

The first falsifier is structural: show a real call-crossing private-cell pair
or remove the named fast-arm reloads without new spills, publication work or
extra passes. Only then run a bounded off/on kernel and compiler-request screen.
There is **no measured gain or credible numeric whole-suite/compiler ceiling**
for this direction here; zero or regression is plausible. The owner-level upper
limit is smaller than eliminating the owner itself, whose post-composition
complete-request share is not established. Existing value-identity research
covers the general direction; no separate implementation is recommended now.

### Bounded scalar-lifetime follow-up

The machine mapping distinguishes two cases. Across the second atom call, RBX
holds the retained value, R13/R14/R15 hold three constructor fields still needed
at 0x414666/0x414674/0x414682, and the first atom result must also survive. That
is five live scalar values competing for the four ordinary saved homes, with
R12 reserved for state. The first-atom spill at −0x8b8 therefore has real pressure;
these parameter homes are not dead at that call.

Later, after the constructor-field stores, R13/R14/R15 have no further value
reads in this complete machine owner (only epilogue restoration). The retained
value still in RBX could in principle move to a freed saved register before the
constructor call at 0x41470c, whose result replaces RBX. Its subsequent
index_hash argument at 0x414717 currently reloads −0x8b0. That is a concrete
candidate for lifetime splitting: replace the earlier snapshot store/later load
with a register transfer at the newly free interval, subject to checked IR
reaching definitions and allocator admission. It is not scratch-cell promotion.

The legacy allocator documents one global saved home per name; current joint
liveness is already available under its 256-statement and other gates. This
inspection did not establish which gate rejects this owner or whether a
particular interference/coloring decision creates the observed spill. A future
diagnostic should distinguish admission failure, genuine interference and
whole-name lifetime merging before changing the allocator. The local mapping
supports that diagnostic, not a promised gain or another independent pass.
