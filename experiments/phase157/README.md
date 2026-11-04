# Phase157 — reproducible ecosystem comparison

[Design](../../design/phase157/README.md) ·
[Report](../../implementation/phase157/README.md) ·
[Raw summary](../../implementation/phase157/metrics.json).

The sole executed workload is `selfhost/tests/phase157/workload-compatible.bend`,
preserved in the [verified evidence capsule](../../implementation/phase157/evidence/capsule.json).
Extracted compiler source copies are evidence artifacts, not additional maintained
compiler versions at HEAD. Restore the capsule's exact source/input members before
replaying the scripts below.
[workload-notes.md](workload-notes.md) binds the original source, captured book,
five owners and full independent oracle. [normalization-final.json](normalization-final.json)
records the368 whitespace changes and completed emission-equality gate.
[bendc-method.md](bendc-method.md) pins the seed/runtime and explains the nine
legacy IO registrations. [measurement-method.md](measurement-method.md) describes
the runtime boundaries and unavailable counters. [code-shape.md](code-shape.md)
contains static machine evidence, not dynamic counts.

All exact build/measurement commands are in the16 guard`process.json`receipts
listed by[the cost report](../../implementation/phase157/cost.json). Run new
commands with fresh directories through`selfhost/tools/build-retention/guard.py`,
CPU3,2GiB RSS,16GiB available floor,5GiB free disk reserve and explicit budgets.
Do not overwrite historical runs. No installed compiler selection changes.

1. Restore the evidence capsule if local build files have been retired; verify
   its member hashes. It contains the new seed, header/license, generated
   products, raw results, input book/oracle and exact method revisions.
   Existing qualified Phase152 image and pinned asset/toolchain receipts are
   separate inputs; their earlier qualification remains required.
2. `tools/normalize.py` checks the audited source transformation without running
   a compiler. It pins exact input and output; it is not a general formatter.
3. `tools/acquire.py` emits/checks upstream C or bendc GC/RC and builds with the
   pinned C policy. It applies the strict nine-site legacy effect adapter only
   to bendc generated C. The maintained`selfhost/tools/build/native.py`builds
   QBE. Raw versus adapted C and acquisition costs remain explicit.
4. `tools/measure.py --out FRESH --roles upstream02 qbe02 gc03` repeats five-owner
   work after calibration and uses all six role permutations. These named
   artifacts must first be restored/authenticated. Add`--fixed-count 1`for the
   fresh single-batch boundary. Exact independent outputs bracket every timing
   block. RC is deliberately omitted after its recorded ordinary output failure.
5. `tools/gc-diagnostic.py --out FRESH` separately enables collection statistics
   for the successful GC image and the admitted16-batch count. Never combine
   its timings with the clean medians.

The qualification checkpoints are upstream01/original-source, upstream02/exact
C reuse, qbe02/exact original QBE, gc03/adapted GC and measure02/latency01 output
controls. Rejected attempts are gc01/parser, gc02/legacy IO ABI, pilot01/argv
contract and measure01/RC output. The unused smaller publication fallback is
documented in[publication-notes.md](publication-notes.md), with no execution claim.

Historical method versions are evidence artifacts, not alternative maintained
tools. Acquisition also needs the exact pinned upstream effects and qualified
toolchain/runtime assets. A capsule is reproducible evidence, not a bundled
portable installer or a substitute for those identities.
