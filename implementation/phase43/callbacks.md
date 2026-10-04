# P43-004 implementation status

Correctness: all four tools pass Node24 syntax checks; target controls pending root execution.
Measurement: not run by callback owner. Decision: investigate; no production
source change and no admission expansion.

Read Phase39 callback rejection before authoring. Its exactCode and per-edge
coverage costs explain a concrete difference from the current proposed boundary;
they do not establish the size of the recovery. Current tools preserve original,
same-admission generic, direct-unfused and TypeScript comparator roles.

Tools are in `selfhost/tools/performance/phase43/callbacks/`:

- `derive.mjs`: checked three-list fixture; explicit capture/value scalar worker,
  unchanged list construction and traversal, one default scalar wrapper admission.
- `controls.mjs`: inherited demand/host/error controls plus complete three-stage
  values, fresh capture arrays, and Error-hook alien callback invocation.
- `closure-derive.mjs`: actual checked scalar composition-chain ablation with
  complete chain materialization; no list/chain fusion or closed-form sum.
- `closure-controls.mjs`: complete captures, fresh descriptors/bound vectors,
  retained chain aliases, changed-code errors, entry/dependency/host controls.
- `SOURCE_PATCH.md`: generic source module/function proposal and proof grammar;
  no source-name allowlist or unconditional JPure function admission.

Independent reviewer found an active-flag proof-suspension gap before target
execution. The first draft could specialize an alien callback while `bad()`
suspended regionProof around Error construction. Repaired with exact nonnull
proof-token equality and added an Error-hook callback-map witness returning999
through its own code. Preserve this rejected boundary; it is not a source bug.

Root execution recipes (NODE is absolute Node24 path; fresh output dirs):

```sh
$NODE selfhost/tools/performance/phase43/callbacks/derive.mjs \
 selfhost/build/phase39/callback-baseline02/modules/callback-fixture-v2.mjs \
 selfhost/build/phase39/callback-typescript02/modules/callback-fixture-v2.mjs \
 selfhost/tools/performance/phase39/callback-catalog-v2.json \
 selfhost/build/phase43/callback-direct01
$NODE selfhost/tools/performance/phase43/callbacks/controls.mjs \
 selfhost/build/phase43/callback-direct01 selfhost/build/phase43/callback-controls01
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase43/callback-direct01/compare.json \
 selfhost/build/phase43/callback-screen01 --node "$NODE" --cpu 3 --budget 60
```

Derivation expected under1s; controls1–3s; three-round fixture screen around21s
(previous matching role screen20.586s). No new compiler acquisition required.

Actual closure recipe uses Phase42 checked16 full-preparation module and the
frozen Phase37 TypeScript module supplied by root:

```sh
$NODE selfhost/tools/performance/phase43/callbacks/closure-derive.mjs \
 selfhost/build/phase42/integration03/full-preparation/modules/closures.mjs \
 "$TS_CLOSURES" selfhost/tools/performance/phase37/catalog.json bench \
 selfhost/build/phase43/closure-direct01
```

Derivation is a static rewrite. Run `closure-controls.mjs DERIVED NEW_CONTROLS`
before clean timing. Expected
screen under20s; shared comparison budget60s. Broader source specialization only
follows a surviving actual-family result and source proof review.

## Actual materialized-chain result and next discriminant

Root reports `closures-controls01`PASS. `closures-screen01` clean medians in
milliseconds/call:

| Size | Original | Scoped | Direct | TS |
| --- | ---: | ---: | ---: | ---: |
| 64 | .0499174 | .0606455 | .0463065 | .00571189 |
| 256 | .191414 | .197006 | .157432 | .0227036 |

Direct application wins1.08/1.22×original, leaving about8.11/6.93×TS. This
supports a stronger construction discriminator, not parity or source promotion.
Original/scoped/direct tools and raw evidence stay frozen.

`environment-derive.mjs PREVIOUS_DERIVED NEW_OUT` creates a fourth role with
private first-order identity/scalar/composition objects. It preserves descending
fresh scalar capture construction, materializes base identity, then materializes
composition nodes in original ascending unwind order before invoking any scalar
callback. No closed-form sum, capture caching or fusion removes the chain.
Original generic construction machinery and fn/bound arrays disappear from this
private graph. Diagnostic counters separately count leaves, identities and
compositions. Full environments are exposed only in diagnostic modules.

```sh
$NODE selfhost/tools/performance/phase43/callbacks/environment-derive.mjs \
 selfhost/build/phase43/closures01 selfhost/build/phase43/closures-environment01
$NODE selfhost/tools/performance/phase43/callbacks/environment-controls.mjs \
 selfhost/build/phase43/closures-environment01 \
 selfhost/build/phase43/closures-environment-controls01
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase43/closures-environment01/compare.json \
 selfhost/build/phase43/closures-environment-screen01 \
 --node "$NODE" --cpu 3 --budget 60
```

New tool versions pass Node24 syntax checks. Target controls/timing pending root;
expected derive<1s, controls2–4s and five-role screen20–30s. Environment controls
include full captures/node shape, fresh objects, retained alias references,
repeated invocation, root activation/construction counts and actual environment
Error-hook proof suspension. Shared controls retain descriptor/host/raw/staged/
extra fallback and early/late generic callback errors.
