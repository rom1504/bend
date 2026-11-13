# Reproducible Phase192 evidence

The [qualification receipt](evidence.json) pins the selected source, qualified
native N2, fixed-point object, independent source and runtime gates, exact
cross-host/cross-generation products, and profiles. The paired compiler-cost
screen has its separate [summary](compiler-cost-summary.json). The
[execution plan](qualification-plan.json) and [execution receipt](qualification-execution.json)
record the exact serial jobs; use fresh destinations when reproducing them.

[receipts.tar.gz](evidence-capsule/receipts.tar.gz) preserves 7,411 byte-exact JSON
receipts and bounded diagnostic streams. The
[inventory](evidence-capsule/inventory.json) supplies every member's digest and
[verification](evidence-capsule/verification.json) records complete archive and
member validation. Compressed size is 10,499,089 bytes. The bundle is metadata
and logs, not a complete binary backup: executable/object stdout, compiler
sources, assembly, raw sampling files and IR dumps are omitted. Their identities
remain in the receipts; qualified native products and complete original evidence
remain hot under `selfhost/build/phase192` with retention closure records.

Verify without executing any target:

```sh
python3 -B selfhost/tests/phase192/pack-evidence.py \
  --out implementation/phase192/evidence-capsule --verify
```

The capsule captures report text at packaging time and does not contain itself
or this later navigation file. Generated-code algorithms stay in maintained
Bend modules; host scripts transport, authenticate, observe and summarize.
