# Portable Phase190 evidence

`receipts.tar.gz` is a metadata-only snapshot through `runtime06`,
`development-summary06`, `final-build01`, `final-controls01`, and `final-emit01`.
`inventory.json` records SHA-256 and size for the compressed archive and every
member, plus each original repository-relative path and original-file digest.
The 1,035-member archive is about 1.29 MB; archive plus inventory and helper is
under 2 MB. No target execution occurred while creating this capsule.

Verify the portable bytes without the original build directory:

```sh
python3 -B implementation/phase190/evidence/pack.py --verify
```

Extract metadata to a fresh directory if desired; member paths are repository
relative, and verification rejects absolute paths and parent traversal:

```sh
mkdir /tmp/phase190-evidence
tar -xzf implementation/phase190/evidence/receipts.tar.gz -C /tmp/phase190-evidence
```

Recreate the exact archive from retained original evidence, rejecting any
changed original receipt or changed derived facts:

```sh
python3 -B implementation/phase190/evidence/pack.py \
  --root "$PWD" \
  --selection implementation/phase190/evidence/inventory.json \
  --out /tmp/phase190-evidence-repacked
```

Tar ordering, timestamps, ownership, permissions, gzip timestamp, and gzip
filename are deterministic. Compare the recreated archive digest with the
inventory. Initial discovery without `--selection` may include newly completed
work and is not an exact replay of this snapshot.

The bundle retains control and acquisition reports, failed checker/emission
receipts and diagnostics, guarded process/resource metadata, all six development
runtime reports and summaries, program manifests, source/API identities and
policy overrides, static inspection reports/disassembly, general-profiler raw
captures/analyses, exact capture output streams, and independent within-role
profile aggregation. The original combined profiler-comparator refusal remains
in the within-role analysis receipt; no raw report was edited to bypass it.

Source-preparation manifests are explicitly transformed into compact identity
and switch facts. Their original digest, retained fields, and omitted field
names are recorded. Declaration inventories and maps are omitted; the retained
source/tool hashes do not manufacture missing source bytes. The archive contains
no executable, object, API module, compiler-source copy, or profiler collector.
Per-observation runtime transport files are omitted where root reports already
retain command, process metrics, status, and stream hashes. These omissions
prevent fully revalidating all historical stdout hashes from this capsule alone.

Absolute paths inside original receipts remain unchanged as provenance. Portable
archive verification establishes the included bytes, not the continuing presence
or validity of external referenced artifacts. Replaying compiler builds, controls,
or timings needs the separately retained exact products, sources, tools, and
ordinary resource guards. Source acceptance, finite independent machine checks,
static instruction counts, sampled physical attribution, clean timings, and
native bootstrap qualification remain distinct evidence categories.

The final static loop audit is included: 27 instructions / zero frame references
for one positive iteration, versus joint 39/2 and baseline 66/21. C's 15-instruction
hot body performs two element updates. Existing profiles cover baseline,
operands, and retained C, not the final compiler bundle. Development results do
not establish held-out transfer or native self-reproduction. Later selected-source
checks and any subsequent final reports belong in a separately inventoried
supplement; this snapshot does not claim their outcome.
