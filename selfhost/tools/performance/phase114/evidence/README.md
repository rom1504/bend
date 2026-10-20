# Phase114 evidence adapter

`seal.py` imports the exact SHA-pinned Phase112 `seal-evidence.py` from
`gate-binding01.json`. The original file is not edited or copied. The adapter
changes only data scope/output location, adds current Phase114 code/config
identity pins, and checks that the scoped file inventory stays frozen.

The archive destination is `implementation/phase114/evidence`. Build scopes are
all of `selfhost/build/phase114`, plus only directories named `p114-*` immediately
under `selfhost/build/phase111`, `phase112`, and `phase113`. Other historical build
directories are not scanned. The original gate's two current-source directory
arguments are redirected from Phase112 to Phase114. Its evidence-directory
exclusion prevents prior capsules from recursively becoming payloads.

The adapter and original gate keep their own pins. The archive index records
`adapter.kind = phase114-evidence-scope-adapter`, actual roots, source redirects,
inventory, method binding and exact file identities. The original plan/capsule/
summary `kind` strings and log-excerpt marker still say Phase112 because their
serialization belongs to the unchanged gate. Those legacy labels do not change
the explicit Phase114 scope or imply Phase112 evidence was acquired again.

The original checks remain authoritative: regular repository files only, no
symlink traversal, exact JSON up to16MiB each, logs up to64KiB or explicit
head/tail excerpts,64MiB unique raw payload cap and8MiB compressed archive cap.
Source/API/code text and machine/IR/assembly files are identity-only or excluded;
they never become archive payloads. JSON configuration files under current
Phase114 tool/document roots are added as hash-only entries. No classification,
limit, capture or archive-verification implementation is replaced.

Run only after root confirms targets and source/report edits have finished.
Both commands hold the target execution lock and refuse active guards. They run
outside a target guard and execute no compiler, generated program or benchmark:

```sh
python3 -B selfhost/tools/performance/phase114/evidence/seal.py plan \
  --out implementation/phase114/evidence/plan01.json

# Inspect roots, adapter provenance, failures, exclusions and excerpts first.
python3 -B selfhost/tools/performance/phase114/evidence/seal.py seal \
  --plan implementation/phase114/evidence/plan01.json \
  --out implementation/phase114/evidence/receipts01.tar.gz
```

All output names must be fresh. If source, receipt or scope inventory changes,
prepare a new plan. Keep failed attempts and partial archives. The gate reopens
the written archive and verifies every member before promotion; companions are
`receipts01.tar.gz.manifest.json` and `receipts01.tar.gz.summary.json`.

The compressed-size limit applies to the archive, not the separate plan or
manifest. Hash-only entries and excerpts cannot justify deleting originals.
Large compiler/API/native products remain external dependencies; the receipt
pins identify their actual producer versions. Summary clocks may overlap and
must not be added together without an independent accounting rule.
