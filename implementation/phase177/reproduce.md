# Reproduce Phase177

The selected experiment combines core substitution and exact declaration-lookup
reuse: `subst`, `subst_node`, and `p140p_def_header`. The extracted full frontend
falls 56.186→54.0595 seconds across two balanced rounds (3.78% less). The explicit
native N1 passes native64 and preserves all 45 timed QBE products. These are
separate observations; no N2/self-reproduction, installed promotion, JS/C image
qualification or new generated-program timing is established here.

Run from the repository root. All targets use the coordinating CPU3 lane and
[`job.py`](../../selfhost/tests/phase177/job.py), which supplies one aggregate
process/disk guard and retention closure. Use fresh output names; never overwrite
retained reports or nest guards. Parallel batches are software screens on their
recorded disjoint cores, not isolated final timings.

## Source identities and preparation

The experimental preparation tools require the exact maintained Phase175 parent:
3,163,584 bytes, SHA256
`a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`.
After maintained integration, their refusal of a changed parent is expected;
use the retained source or a checkout of the pre-integration parent. Do not
silently repin or apply these overlays twice.

The complete selected source is
[`full-source01/compiler.bend`](../../selfhost/build/phase177/full-source01/compiler.bend):
3,174,925 bytes, SHA256
`1a359a4c94c8293fec12b8722793a5beafae1896dc2a8307bf5359a7f367532f`.
Its [composition receipt](../../selfhost/build/phase177/full-source01/report.json)
retains every original declaration and main, protects all 112 declarations,
and records exact inverse reconstruction. On the unchanged parent, prepare a
fresh copy with:

```sh
python3 -B selfhost/tests/phase177/full-prepare.py \
  --prelude selfhost/tests/phase177/substitution/single-prelude.bend \
  --prelude selfhost/tests/phase177/parser/decl-reuse-prelude.bend \
  --module selfhost/tests/phase177/substitution/selected.bend \
  --module selfhost/tests/phase177/parser/decl-reuse.bend \
  --replace subst --replace subst_node --replace p140p_def_header \
  --out selfhost/build/phase177/full-source-recheck01
```

`substitution/selected.bend` preserves the original `subst_node` binder name
`id0`; the extracted experiment's `single.bend` used `id`. Full preparation
checks original signature tokens and therefore uses the selected module.

The extracted frontend uses `prepare.py`, the same substitution/declaration
preludes and replacements, plus Phase175's `frontend-plan.bend`,
`frontend-digest.bend`, and `frontend-native.bend`. It keeps only the conservative
dependency closure of its explicit exports and native main. These two roots
are deliberately different:

| Retained source | Purpose | Exports beyond native main |
|---|---|---|
| [`front-combined-source01`](../../selfhost/build/phase177/front-combined-source01/manifest.json), 659,096 bytes | Checked complete-value API | `p88_cache_prepare`, `p175fp_plan`, `p175fd_value`, `p175fp_reference` |
| [`front-combined-source02`](../../selfhost/build/phase177/front-combined-source02/manifest.json), 653,442 bytes | Native timed service | First three exports only |

[`front-combined-api01`](../../selfhost/build/phase177/front-combined-api01/report.json)
was acquired from source01;
[`front-combined-native01`](../../selfhost/build/phase177/front-combined-native01/report.json)
was built from source02 through explicit Phase175 native N2. Do not interchange
their source receipts or describe the API's extra reference closure as timed.
The baseline native service is
[`front-base-native01`](../../selfhost/build/phase177/front-base-native01/report.json),
bound to [`front-base-source01`](../../selfhost/build/phase177/front-base-source01/manifest.json).

## Values, screens and the full frontend

Selected complete-value receipts are
[`subst-values01`](../../selfhost/build/phase177/subst-values01/report.json)
(264 observations),
[`decl-values01`](../../selfhost/build/phase177/decl-values01/report.json)
(565 observations), and
[`combined-values01`](../../selfhost/build/phase177/combined-values01/report.json)
(14 complete source cases, parse/request modes). Their reference values come
from independently checked unchanged Bend; native digests supplement those
comparisons rather than replacing them. Forward `law` declarations are type
signatures, not equivalence proofs.

The small/medium batches are
[`screen-batch01`](../../selfhost/build/phase177/screen-batch01/report.json),
[`02`](../../selfhost/build/phase177/screen-batch02/report.json),
[`03`](../../selfhost/build/phase177/screen-batch03/report.json), and
[`04`](../../selfhost/build/phase177/screen-batch04/report.json).
Their payloads run the same full request mode over the retained Phase175
parser and frontend source inputs. Their commands, CPU assignments, per-job
limits, failures and result receipts remain in the reports. Reuse Phase176's
batch runner with the corresponding Phase177 manifest; do not substitute
parallel batch wall time for an isolated compiler-speed measurement.

The decisive isolated component receipt is
[`combined-full01`](../../selfhost/build/phase177/combined-full01/report.json).
It uses the unchanged Phase170 full input, 3,150,535 bytes, SHA256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Whole-process medians are 64.5502→62.4243 seconds; the frontend clocks exclude
roughly 8.06 seconds of complete structural observation. Repeat with:

```sh
python3 -B selfhost/tests/phase177/job.py combined-full-recheck01 360 30 \
  python3 -B selfhost/tests/phase175/native-frontend.py \
  --baseline selfhost/build/phase177/front-base-native01/report.json \
  --candidate selfhost/build/phase177/front-combined-native01/report.json \
  --binding selfhost/build/phase177/front-base-source01/base-binding.json \
  --source selfhost/build/phase170/source-final/compiler.bend \
  --mode request --rounds 2 --seconds 90 \
  --out selfhost/build/phase177/combined-full-recheck01
```

## Full source, explicit N1 and finite qualification

[`full-source-check01`](../../selfhost/build/phase177/full-source-check01/report.json)
passes unmodified upstream `book_load`, `book_valid`, and zero unresolved holes.
It explicitly does not assess proof safety or run the BendTT kernel. Recheck the
retained source independently with:

```sh
python3 -B selfhost/tests/phase177/job.py full-source-check-recheck01 60 50 \
  selfhost/.assets/bin/bun selfhost/tests/phase177/full-check.mjs \
  --source selfhost/build/phase177/full-source01/compiler.bend \
  --out selfhost/build/phase177/full-source-check-recheck01
```

[`full-native-n1/report.json`](../../selfhost/build/phase177/full-native-n1/report.json)
records 181.314 seconds to build that selected source through explicit Phase175
native N2, including QBE and machine construction. This is an acquisition cost,
not a fixed-input old/new cold comparison. Its original command omitted
`--output-stage`; the successful receipt remains immutable. Root's metadata-only
[`bind-native.py`](../../selfhost/tests/phase177/bind-native.py) created
[`image-binding.json`](../../selfhost/build/phase177/full-native-n1/image-binding.json),
pinning the successful build, source composition, independent check, binary,
runtime and producer. It declares native N1 / `qbe-source-v1` / QBE only.
The binding itself claims built/source-checked, not semantic qualification.
All candidate requests must explicitly use that standalone binding.

[`native64-n1`](../../selfhost/build/phase177/native64-n1/report.json) passes
64/64 with no unsupported rows;
[`timed-products45-n1`](../../selfhost/build/phase177/timed-products45-n1/report.json)
preserves every full timed-wrapper QBE against Phase169's original six/remaining
receipts; and
[`timed-products45-v175`](../../selfhost/build/phase177/timed-products45-v175/report.json)
independently compares those retained bytes with Phase175. The latter executes
no compiler. Exact products retain prior runtime evidence, not a new runtime
benchmark. The [qualification recipes](../../selfhost/tests/phase177/qualification/README.md)
contain the unchanged maintained commands, explicit image/binding and budgets.
Their original output names already exist: use fresh matching job/output names
for a repeat. JS/C are unsupported by this image; Phase175's separate hosted API
is not a Phase177 cross-backend qualification.

## Rejected attempts and completed closeout

Keep all negatives. The first material summary and single-owner sources are
retained as `parser/material-summary-rejected-v1.bend` and
`material-single/single-rejected-v1.bend`; their failed acquisition batches
precede successful retry batches. Earlier `front-*-values01` comparisons failed
because the chosen API lacked the semantic-control export; the corrected
`values02` runs must not erase them. Publication `remove-values01/02` failed
on host Char ABI construction, with the old adapter retained. `api-batch01` and
the initial profile attempt also remain evidence, not passes. Materialization,
freshening, reachability and index-removal experiments are not part of the
selected full source merely because some finite controls passed.

The fixed-input cold pair completed in `cold-candidate01` and `cold-baseline01`:
176.8633s versus 178.7954s (1.08% less). Use
[`cold-pair.sh`](../../selfhost/tests/phase177/qualification/cold-pair.sh) for the
exact command and change both output/job names for a repeat. This is one
candidate-first pair with exact QBE, assembly and object identity, not a confidence
interval or a new upstream comparison.

[`integration-applied01`](../../selfhost/build/phase177/integration-applied01/report.json)
records the actual three-file integration and exact assembled selected source.
The earlier `integration-proposal01` remains an unapplied proposal. Preparation
recipes tied to the old parent must run at their recorded Phase175/c5d95e1 tree,
not silently against the now-modified maintained source. No new N2 reproduction
or installed selector change is claimed.

Raw reports, source/method snapshots and failed receipts are preserved in
[`evidence.tar.gz`](evidence.tar.gz), with per-member hashes and retained machine
artifact paths in [`evidence-index.json`](evidence-index.json). Restore into a
separate empty directory, never over the working compiler or immutable aliases:

```sh
mkdir -p /tmp/phase177-evidence
tar -xzf implementation/phase177/evidence.tar.gz -C /tmp/phase177-evidence
```

`seal-evidence.py` byte-verifies every member. Build products remain local;
their exact identities are in the original receipts. `summarize.py` derives the
checked metrics from completed receipts and refuses changed selected modules.
