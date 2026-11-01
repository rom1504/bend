# Phase147 evidence checkpoints

`checkpoint.py` is a data-only reader/exporter. It never invokes a compiler,
program, guard close, archive creation, or pruning. Run from the repository root,
using a fresh destination:

```sh
taskset -c 0 python3 -B experiments/phase147/tools/retention/checkpoint.py \
  --out implementation/phase147/evidence/checkpoint01
```

The optional `--cutoff UNIX_SECONDS` makes the completed-guard boundary explicit.
Finished outer disk guards contribute their wall intervals once. Nested process
receipts remain exact evidence but are not added to elapsed cost. Interval union
handles overlap; the uncovered span remains unclassified. These are acquisition,
build, harness, and measurement costs, not CPU billing or clean benchmark ratios.

The report proposes `completed` for a successful outer command and `failed` for
other finished commands. Neither implies semantic qualification or a promotion
decision. Its `close.py` argument lists are review material only, preserve every
declared root using `--keep-root`, and are not executed. Existing selectors,
N1/N2 images, the complete baseline, profiler images/maps/samples, all other raw
roots, and the shared execution lock remain hot. A later root-approved close must
explicitly decide which roots are cold and then use the maintained archive and
verification workflow before any optional pruning.

The export retains exact JSON up to 2 MiB, logs up to 1 MiB, and source/method
fragments up to 256 KiB, once per SHA-256 in `objects/`. Original-path mappings
and original receipt bytes preserve provenance. Full compiler copies, large
owner maps, generated programs, and binary images are listed as omitted hot
dependencies; **this checkpoint is not a restorable compiler/profiler archive**.
Original declared pins remain in `references.json`; a missing export match may
be a hot dependency, historical prerequisite, or deliberately invalid test pin.
No claim is made that every unmatched reference is a missing required input.

Historical command input identities are resolved by their exact content, including
retained method-history snapshots. A changed current file is never substituted as
the historical method. The renderer-method capsule is independently re-opened;
its exact archived members are indexed without duplicating the five removed
methods. Current unguarded method/test files are stable-read snapshots only,
not a claim that their owners have finished work. Active guards/artifact roots
known at the snapshot boundary are excluded from completed evidence.

`objects/<sha256>` contains the unmodified original bytes. To restore a small
evidence file, select its original `file` row in `report.json`, copy the named
object into separate scratch, and verify its declared size and SHA-256. Preserve
the original basename for executable methods. No target can be reproduced solely
from this checkpoint until its explicitly retained hot dependencies are supplied.

Do not commit the loose `objects/` export. Add exact referenced small method bytes,
then package both exports into one compressed capsule and a small index/summary:

```sh
taskset -c 0 python3 -B experiments/phase147/tools/retention/dependencies.py \
  --checkpoint implementation/phase147/evidence/checkpoint01 \
  --out implementation/phase147/evidence/checkpoint01-method-dependencies
taskset -c 0 python3 -B experiments/phase147/tools/retention/pack.py \
  --checkpoint implementation/phase147/evidence/checkpoint01 \
  --supplement implementation/phase147/evidence/checkpoint01-method-dependencies \
  --out implementation/phase147/evidence/checkpoint01-capsule --compact
```

The packer verifies every tar member's full bytes and SHA-256, then rechecks every
loose source before optional compaction. `--compact` removes only these freshly
exported checkpoint directories under `implementation/phase147/evidence`; it
cannot accept raw build roots or method-history evidence. The archive retains
the original checkpoint reports and mappings, exact payloads, supplement, and
an internal member index. Its external `index.json` records the archive identity
and verification; `summary.json` remains directly readable. Restore into separate
scratch when needed. At final close, choose fresh `checkpoint02` names and repeat
this sequence after the root owner declares the appropriate evidence boundary.

Phase147 final closure used `close-plan-v2.py` with the explicit final
qualification receipt, then the root-authorized `close-approved.py` archive-only
batch. The selected plan keeps all current metrics dependencies, final compiler
roots, corpus references, and complete profiler bundles hot. The earlier planner
and draft plan are preserved in checkpoint02's capsule. No raw pruning was
performed. Final checkpoint discovery also includes the small Phase147
implementation and close receipts; archived payloads themselves remain external
and are identified by those receipts. Missing or unfinished lifecycle records do
not count as a sealed campaign.
