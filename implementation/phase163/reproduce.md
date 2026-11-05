# Reproducing Phase163

All semantic compiler changes, observers, controls and native request handling
are in `selfhost/tests/phase163/*.bend`. Python/JS tools only extract declarations,
transport exact artifacts, schedule existing compilers, time processes and compare
outputs. They do not implement an alternative compiler.

The experiment uses the exact maintained Phase152 parent and pinned Phase66 Base,
upstream checker, QBE, assembler, linker and ordinary serial runtime. Use explicit
asset/receipt arguments from retained `process.json`; do not substitute an installed
image or follow the newest-looking phase path. Commands require this workspace's
pinned operational assets, or their authenticated restoration.

## Source recipes and controls

`experiments/phase163/tools/prepare.py` extracts a conservative declaration closure
from the exact qualified assembly plus explicit Bend modules. It refuses protected
declaration replacements and records source/method identities. Same-name laws remain
when a definition is replaced. Explicit experimental additive replacement is used
only to select the optimized private native entry.

Key prepared-source manifests are retained in the evidence capsule:

* `direct-api-source04`: original closed direct route and structural controls.
* `direct-opt-api-source01`: all four direct policies and 22 controls.
* `direct-generic-api-source01`: exact-policy generic-materialization control.
* `direct-native-optimized-source01`: private native CLI using mode 3.
* `frontend-native-baseline-source01` / `frontend-native-compact-source01`: actual
  compiler frontend plus streaming complete-result observer.

Acquire pure APIs with the existing `hosted.mjs acquire`, using that recipe's
`compiler.bend` and `exports.json`. Native acquisition uses existing `native.py`,
qualified Phase152 N2 and explicit cached Base mode. Keep ordinary compiler jobs
inside `build-retention/guard.py`; copy the recorded budget and use fresh output
roots. Do not nest guards. The revised optimized acquisition uses 128MiB disk and
does not retain its large intermediate QBE file.

## Small reproduction order

1. `check-workloads.mjs` and `check-rows.mjs`: complete source-helper oracles and
   compact structural controls. `direct-pilot.mjs` runs direct/adapter controls.
2. `direct-modes.mjs`: four policies on the two frozen 10,000-repeat workloads;
   mode 0 must reproduce the first direct output exactly.
3. `native-pilot.py`: build admitted QBE with unchanged runtime/toolchain and
   require complete output equality. `runtime-oracle.py` provides independent
   expected record counts/checksums for the four scaling controls.
4. `runtime-pairs.py`: four reversed fresh-process pairs per generated policy.
5. `native-requests.py --mode 3 --candidate .../direct-native-optimized01/report.json`:
   complete source→QBE latency against qualified N2. Both products must match the
   independently hosted compiler route modulo blank serialization lines. No other
   normalization is allowed. The original v1 method is retained under `methods/`.
6. `generic-matched.mjs`: genuine original generic construction/verification with
   exactly the same final policy and QBE bytes. Do not replace its real generic
   program with placeholder bodies.
7. `prepare-transfer.py` / `native-transfer.py`: eight preselected frozen-value
   computations. This is admission/output transfer, never a benchmark timing ratio.
8. `frontend-pilot.mjs` / `frontend-native.py`: full canonical observations; native
   stage clocks separate parser/checker work from observation/write. The compact
   candidate did not earn a larger campaign.

The optimized native CLI accepts the ordinary six-string source/Base/live-or-cache
protocol. It intentionally supports pure closed direct main computations only;
it rejects batch/session commands, unsupported direct graphs and IO mains. It is
not the public compiler selection and cannot currently reproduce its own IO entry.

## Evidence and restoration

`evidence/capsule.zip` contains exact source snapshots, receipts, raw timing data
and diagnostics; its inventory identifies original paths and hashes. Bulk machine
products remain in explicitly hot research roots or the verified archives named
by `retention.json`. Restore archived roots before rerunning a method that reads
their exact paths. The retention receipts authenticate archive members; a source
hash alone is not a replacement for those bytes.

Historical `prepare.py` and `native-requests.py` versions are preserved in
`experiments/phase163/methods/` because later transport-only refinements changed
their current paths. Their hashes match the corresponding original receipts.
No failed acquisition, unsupported transfer, expected unsafe proof verdict or
resource-guard stop is converted into a passing result.
