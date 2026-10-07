# State06 final qualification readiness

Static audit only; no compiler, generated program or qualification target was
executed for this note. The baseline remains installed Phase58 last01.

The actual selected attempt is
`selfhost/build/phase61/checked-state06/attempt.json` (`c803e731…`), API
`61761c0272092792bdb7c9bdb7a5abe07bddb79d5c807318cf0d2c9fb3b0b2b6`.
Its genuine B2 image pins are
`selfhost/build/phase61/bootstrap-state06/image-pins.json`; B2 SHA256
`f73ef8a5596e99d45108b0d31b4e6c3f49e008db000a428e27acd27d79bd6d1a`.
Source SHA256 is
`14af4de4b67de746cfa1d59458a0e27c1e03e02516583c6d2a621352b11e449e`.

## Source-shape compatibility

- The actual assembly contains **3,191 unique definitions**, all explicitly
  `@unsafe`. The existing self-check derives this count from that exact source
  and requires every name in the returned unsafe set; it does not assume an old
  definition count. Type acceptance and expected proof-trust failure remain
  separate.
- Actual exports are **86**. Setup, self-check and image provenance join the
  checked bootstrap's exact roots to the historical 77, the four Base/loader
  additions and the five explicitly pinned carrier additions. The selected
  frozen driver must equal admission01 (`569f17b1…`).
- `jd_definition` is absent; `jd_doc_definition` remains. The active final
  matrices contain no diagnostic hook to the removed String wrapper. The
  separately reviewed `validation/reach-controls-v1.mjs` targets the actual
  String/JDText implementation when root chooses that focused gate.
- The v5 bootstrap's exact library seams already admitted this source when
  creating the consumed state06 plan. Fixed-point reproduction calls retained
  exported APIs and the unsplit library emitter, without those removed wrappers.
- Both private checked-image staging and genuine-B2 staging recognize frame1
  and frame2 and use the actual selected driver's decoder. Version, API/Base,
  source path and canonical book checks remain.
- The unchanged semantic oracles retain source96, numeric34, composition18 and
  overapplication2; the explicit historical TypeScript defects remain failures
  on their reference side. The raw23/45 gate requires newly checked/emitted B1
  modules from the same selected image, then exact B2 bytes including the row
  observer. It does not assume equality to old Phase58 compiler output.

No new incompatible source-shape assertion was found in the active route.
Two **unused preserved copies** remain unsuitable for state06:
`methods-frame02/bootstrap/prepare-candidate.py` still requires the old driver
and 77 roots; `qualification/final-orchestration-v2.py` retains its old 77-root
route. Do not call them. The approved entrypoints are external
`validation/prepare-candidate-v5.py` and `validation/final-plan-frame02.py`.
The `81` in direct-census is the inherited case inventory, not an export count.

## Smallest fresh whole-source gate

Run the existing single-request self-check separately when needed, without
materializing or executing the full final matrix:

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 300 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase61/self-check-state06-early01-supervisor -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/build/phase61/methods-frame02/qualification/self-check.mjs \
  selfhost/build/phase61/bootstrap-state06/image-pins.json \
  selfhost/build/phase61/self-check-state06-early01
```

This starts a private empty Base cache and calls ordinary `D.inspect` with
`mode:check` on the exact complete source through the actual B2. It requires
`checked:true`, `typeAccepted:true` and the exact unsafe-verdict shape; parse or
type rejection cannot pass. There is no profiler, B3 generation or timing claim.
The 300-second bound is a ceiling, not a runtime estimate. Always use fresh paths.

## Final integration barriers

The maintained workflow must gain reviewed synchronous frame2 support before
final release. Its existing `development.test.mjs` expects synchronous
`validatedCache` and is outside the eight backend semantic suites; retain that
API and run its host-unit checks as part of canonical-tool integration.

If the canonical helper changes, the pilot bootstrap's input identities must
remain historical. Generate the final bootstrap once under the maintained
helper instead of relaxing pins. Existing checked-attempt verification checks
frozen source/tool copies, so this helper-only maintenance does not itself
require another checked compiler source build.

`phase47/qualify.py` requires live typed-driver/compiler-ABI/native-build/
node-resource-args/assemble/stage0-library and compiler manifest to match the
selected snapshot. Reconcile the selected host/source before final maintained8.
Source or driver changes require a new genuine checked attempt and matching
admission. The final planner's strict36 gate, fresh B2 gates and release barriers
remain mandatory; this audit is not a qualification or promotion result.
