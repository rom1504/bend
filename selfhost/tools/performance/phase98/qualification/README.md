# Phase98 private native qualification

These methods accept explicit candidate source/image/build receipts. They do not
edit the Phase90 public launcher, its admission manifest, or the historical D04
source. Source/emitter/build authentication is separate from semantic gates.
Only the root runs target commands, serially under the existing resource guard.

First run data-only `freeze.py --out selfhost/build/phase98/qualification-methods01`
from the repository root (using this script's full path), then execute all methods
from `qualification-methods01/methods/`. That immutable snapshot keeps evidence
valid if the development tools change later. Each run additionally snapshots its
method inputs. Never replace an existing snapshot or result path.

`bind.py` records a B1 built from the checked upstream acquisition or a B2 built
from the candidate B1's independently compared self-emission. The guarded Clang
input must be the exact unpatched emitted C and use matched `-O2` flags. New
source hashes are allowed. The existing `p86_*` transport definitions must remain
byte-identical so the authenticated Base/runtime/nine-provider/cache tuple and
the B1/B2 argv conventions can be reused privately.

The basic sequence (replace uppercase placeholders with concrete paths) is:

```
python3 bind.py --stage b1 --binary B1 --source SOURCE \
  --emission-receipt ACQUIRE/report.json --build-guard BUILD_GUARD --out B1.json
python3 gates.py --stage b1 --binary B1 --source SOURCE \
  --build-receipt B1.json --suite controls --out CONTROLS_B1
python3 request.py --baseline b2 --source SOURCE --purpose reference --out REF
python3 request.py --stage b1 --binary B1 --compiler-source SOURCE \
  --build-receipt B1.json --source SOURCE --purpose compare \
  --oracle-report REF/report.json --out SELF_B1
python3 build.py --emission-receipt SELF_B1/report.json --binary B2 --out BUILD_B2
python3 bind.py --stage b2 --binary B2 --source SOURCE \
  --emission-receipt SELF_B1/report.json --build-guard BUILD_B2 --out B2.json
python3 request.py --stage b2 --binary B2 --compiler-source SOURCE \
  --build-receipt B2.json --source SOURCE --purpose compare \
  --oracle-report REF/report.json --out SELF_B2
python3 gates.py --stage b2 --binary B2 --source SOURCE \
  --build-receipt B2.json --suite controls --out CONTROLS_B2
```

Run from this directory or use full script paths. Every output is fresh. The
reference is the actual admitted baseline native B2 compiling the **candidate**
source with identical request assets; D04 self-C is not used as the oracle for a
changed source. Exact candidate B1 and B2 self-C against this independent product
establishes backend fixed-point evidence, not ELF identity or a universal proof.
The `reference` purpose is explicitly not a semantic qualification claim.
Self sources legitimately report `SOME PROOFS FAIL` for their unsafe/foreign
dependencies. Reference creation accepts only that complete counted protocol or
the exact all-safe diagnostic, freezes every diagnostic byte, and records the
unsafe count. Candidate B1/B2 comparisons require exact equality with the
independent reference diagnostic and C, never an assumed all-safe result.

`gates.py --suite controls` runs four original sources live and cached, requiring
full C hash/size equality and exact diagnostics, followed by three historical
rejections with exact diagnostics and no C. `--suite broad45` compiles the exact
45 Phase92 catalog sources once each against their retained full-C identities.
Archived oracle files need not be materialized: their complete hash/size is bound
by the immutable successful historical receipt. No generated programs run in
these exact-output gates. Source-level compiler changes with unchanged generated
C can reuse the historical product behavior evidence; changed C fails this gate.

`conformance.py --b1-build B1.json --b2-build B2.json --out CONFORMANCE` is data-only.
It creates a plan and three root-only commands reusing the unchanged Phase92
adapter, golden judge, 69 eligible fixtures, 31 explicit exclusions and three
rejections per image. The plan keeps that adapter's historical schema name for
compatibility and explicitly records Phase98 candidate producers. Execute the
three commands in order, then use the unchanged Phase92 `conformance/collect.py`
with the new plan to check all observed golden outputs. No native100/100 or full
frontend/JS/GPU claim follows. The separate Phase98 six-source compiler screen
continues to own balanced timing comparisons.

Full Clang defaults to a420s deadline,6GiB RSS cap,16GiB available-memory
floor and CPU2,3. A larger allowance requires separate reviewed evidence after
an actual bounded failure; this method does not grant it. Ordinary
requests use 2GiB RSS, 4GiB available-memory floor, CPU3 and a 64MiB file cap.
This directory has been prepared offline; no target validation is implied until
the parent runner records successful observations.

Version note: immutable `qualification-methods01` retained the older10GiB build
default. Use `qualification-methods02/methods/build.py` (or an explicit6GiB guard)
for builds; snapshot01's existing binding evidence remains untouched. Historical
exact-C gates apply to source changes that preserve generated C. An intentional
emitter/permission change requires separately frozen independent output oracles
and actual generated-program execution; these scripts must not relabel a failed
historical-C comparison as a pass. No such backend gate is prepared here yet.
