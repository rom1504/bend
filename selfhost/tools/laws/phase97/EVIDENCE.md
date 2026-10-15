# Collecting Phase97 evidence

`collect.py` is an offline collector. It executes no compiler, test, benchmark,
kernel, or shell subprocess. Run it only after campaign targets have finished,
using a new destination:

```sh
python3 -B selfhost/tools/laws/phase97/collect.py \
  --out selfhost/tools/laws/phase97/evidence01 \
  --projection-timing selfhost/build/phase97/projection-timing02/report.json \
  --accepted-report formal-challenge=selfhost/build/phase97/formal-challenge01/report.json
```

The timing argument is optional. Its presence requires a completed, authenticated
timing receipt and correct samples/scaling controls; it imposes no speedup
threshold. Without it, timing attempts are still archived but are not selected
as accepted performance evidence. Repeat `--accepted-report LABEL=PATH` for a
later completed scope. Recognized proof-negative and production-campaign schemas
receive the same semantic checks as the built-in scopes. An unknown later schema
is labeled only as an authenticated completed receipt, not silently promoted to
an independent proof or a performance conclusion.

The native compiler screen has a dedicated validator. It follows the pinned
Phase92 authentication routine's explicit current input boundary, authenticates
the comparator/derivation and candidate acquisition/build/source identities,
and checks all 48 raw C/diagnostic pairs. The pinned, separately reviewed
comparator remains responsible for exact patch replay, matched flags, balanced
order and timing arithmetic; the collector does not repeat that implementation.
It requires no speedup. The embedded role admissions retain historical comparison
provenance; reclaimed files in those historical subtrees are not current screen
inputs. Their pins remain in the historical/external inventories with `missing`
status. Any missing current input still fails authentication.

`collect-v1.py` preserves the first collector run's method. That run stopped
before creating its output directory because generic recursive authentication
treated a reclaimed historical Phase90 C product as an active screen input.
The root controller retains the raw traceback separately; no target was launched
by this collector failure. The revision applies the scope distinction above,
not a general exception for missing pins.

## Accepted scopes and all attempts

The collector requires and authenticates these retained reports:

- `challenge-check01`: the unchanged corpus baseline, initial detections,
  escaped mutations, valid controls, and challenges outside the extracted closure.
- `challenge-followups01`: targeted finite witnesses and full native output.
- `ownership-proof02`: seven actual laws, nonopaque inventory, independent
  kernel acceptance and unequal-label kernel rejection.
- `ownership-negatives01`: law-free helper admissions followed by semantic
  rejection against unchanged laws.
- `ownership-boundary01`: exact generated-C mutation replay, successful C
  compilation, correct baseline oracle, then the intended runtime rejection.
- `projection-contracts02`: complete baseline/candidate values, native stdout,
  and discriminating mutant witnesses.

Authentication follows pinned Phase97 JSON dependencies and verifies their
recorded bytes. Mutation `before` identities are replay descriptions, not claims
that the already-mutated path still contains those original bytes. Historical
pin claims found in other attempts are retained with current status; missing or
changed historical claims cannot be confused with the authenticated accepted
closure. The optional formal challenge counts its unchanged-law baseline apart
from its actual law-free helper admission, even though the runner's aggregate
field calls both positive checks `helperAdmissions`.

Every file under `selfhost/build/phase97` is either archived or explicitly
excluded by identity. Failed acquisitions, earlier methods, calibration failures,
and controller-only failures remain included. Sources, patches, current Phase97
methods and documentation supplement frozen raw copies. Pinned text dependencies
are included so the capsule contains the sources needed to inspect the recorded
transformations; external binary installations are not duplicated.

## Capsule contents

| File | Meaning |
| --- | --- |
| `summary.json` | Selected scopes, archive identity, observed target/resource accounting and limitations |
| `raw-evidence.zip` | Compressed sources, patches, methods, reports, raw output and retained failures |
| `archive-members.json` | Each ZIP member's path, original identity, bytes and SHA-256 |
| `execution-ledger.json` | Every Phase97 `process.json`, chronological order, classification and full guard statistics |
| `excluded-files.json` | Exact identities and reasons for omitted executables, toolchains, compiled artifacts and prior archives |
| `external-dependencies.json` | Recorded dependency identities outside raw Phase97, their referencing documents, and current verification status |
| `recorded-pin-claims.json` | All discovered historical pin claims, including before-images and mutable origins |

The collector reads every ZIP member back, verifies its size/hash and verifies
its source again. It also checks that no raw files appeared during collection.
It refuses overlapping target intervals: the serial claim is established from
all retained process receipts, not inferred from the runner's intended behavior.

Expected semantic, frontend-proof, kernel and runtime rejections are classified
separately from other nonzero target failures. A guard's `stoppedFor` takes
precedence and is always a resource stop. Historical resource stops remain in
the capsule and accounting; they are not semantic detections. Guard `complete`
is false for a normal expected exit 1, so that field alone does not identify an
infrastructure failure. A controller argument error that never launched a
guarded target is raw evidence, not another guarded job.

Native executables are excluded by binary content, even if small; executable
source scripts remain included. Compiled Lean artifacts, toolchain installations,
large external generated compiler images, caches and prior archive files are
listed rather than copied. These exclusions mean the ZIP is self-contained for
source/evidence inspection, not a standalone toolchain installation.

Restore into an empty staging tree and verify every member against the inventory.
Repository members use repository-relative paths; text dependencies outside the
repository use the `external-source/` namespace. Original reports retain their
original absolute paths. A replay at a different root needs authenticated
dependencies and fresh receipts; do not rewrite the old evidence to resemble a
new run. No collector result by itself proves the native runtime or establishes
an end-to-end compiler speedup.
