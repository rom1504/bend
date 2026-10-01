# New Phase37 owner closure

`selfhost/tools/performance/phase37/owner-close-v2.py` audits existing evidence.
It runs no compiler, controls, profiling, timing or installation jobs. Local Git
blob reads verify pinned provenance when the sparse checkout omits a source.

```text
python3 selfhost/tools/performance/phase37/owner-close-v2.py \
  FINAL_ATTEMPT CAST_DERIVE_DIRECTORY FINITE_COHORT_DIRECTORY \
  MAPPING_JSON NEW_REPORT_JSON
```

The mapping must contain exactly `cast`, `dataview` and `finite`. Each value is
an object with `report` pointing to the completed control `report.json` and
`execution` pointing to its successful bounded supervisor `run.json`. Paths
may be absolute or relative to the repository root. Every output must be new;
failed audits are retained.

The closer binds the selected checked B1 derivative, API, runtime, Base, driver,
frozen snapshot and original checked emission receipts. Historical attempts
verify their frozen files; changed historical live source paths are not silently
reinterpreted as their old snapshots. All identity edges are recursively checked,
then every observed file is rehashed at the end.

The cast controls must consume the counter modules from the actual-output
adapter. Clean module hashes must equal their original checked emissions;
counter parents and receipt hashes must lead to those clean files. The adapter
must contain seven actual private native call sites for the frozen cast fixture
and zero in the Phase36 comparison. The pinned TypeScript receipt must compile
the same source. The owner reports require 44 oracles, 57 boundaries and seven
admission records for cast, plus all 22 passing DataView observations. The
general control producer is the tightened v5 tool, which intentionally retains
the older v4 JSON kind label.

The finite cohort must be the corrected v5 fixture/acquirer. Earlier fixture
versions failed checked acquisition and cannot substitute. All three module
receipts must compile the same frozen source; the candidate must belong to the
same selected compiler as the cast cohort. Its control diagnostic parent must
be that actual candidate emission and all three original modules must be listed
as consumed inputs. The v2 control producer requires 154 oracle observations,
nine admission records and 76 boundaries, including two 30,000-step tail cycles.
Root completed these groups successfully in `finite-controls02` against the
checked03 module acquired in `finite-cohort05`. The expected counts and v5/v2
source/tool identities are now frozen. Root also reacquired and reran the cast
controls on the same final checked03 API in `cast-actual-controls02` and
`cast-actual-dataview02` before closing the combined owner audit.

The Phase36 compiler receipt must bind its own verified historical attempt's
API, runtime, Base and driver, in addition to the pinned baseline API hash. The
TypeScript cast receipt receives the same complete/checked/status/pin/source
checks as the finite receipt. The audit tool and consumed control copies are
also included in the final identity recheck.

Each supervisor command must use the checked attempt's Node binary, the exact
control producer and the output directory containing the report. Consumed tool
copies must match producer bytes. This explicit closure supplements the
inherited Phase35/36 owners, full conformance gates, canonical-source audit,
performance admission and installation gates; it does not replace them.

The preserved first audit, `new-owner-close01.json`, failed before any owner was
closed: its generic recursion interpreted the catalog-relative
`fixtures/mandelbrot.bend` as a repository-root path. This was an audit path bug,
not a compiler or control failure. Its producer and result remain unchanged.

The v2 auditor uses explicit identity namespaces. Catalog, bundle and preparation
paths are relative to their document directory; application-proposal paths use
the Phase37 catalog directory; `selfhost/...` paths are repository-relative.
Pinned upstream provenance is a commit/path namespace, verified from local Git
objects including SHA256, size and Git blob ID when supplied. Those bytes are
rechecked at the end. Unknown relative namespaces fail; no identity edge is
silently discarded. The cast's TS receipt is selected by its exact source hash
because the expanded catalog's transitive closure also includes ray-oracle TS
receipts.

Root executed v2 successfully in `new-owner-close02.json`: all three owner
groups passed, with 710 verified file identities and 15 verified pinned Git
provenance blobs. The bounded supervisor recorded 2.513 seconds and exit zero.
The [final scope/owner report](final-scope-owner-report.md) records exact final
compiler and evidence hashes. The original failed producer remains recorded
in `selfhost/tools/performance/phase37/owner-close.freeze-v1.json`.
Any changed fixture/tool/count contract requires a new
closer version and preserved prior outcome, rather than weakening a failed
audit in place.
