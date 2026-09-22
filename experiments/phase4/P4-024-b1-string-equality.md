# P4-024: Primitive equality in the disposable B1 development compiler

Status: bounded pilot, complete frontend preservation and one full-source exact-output gate passed. The following plan was recorded before execution. Owner: compact-index agent; full-source audit/archive: direct-calls agent. Canonical packaging verification takes priority; the absolute experiment stop was 20:00 UTC on 2026-09-22.

## Hypothesis and invariant

Final B1's generated `$String$eq$` calls ownership-preserving `String.cmp`, which reconstructs strings before the equality caller discards them. The real-core P4-022 profile attributes 16.58% exclusive samples to three comparison helpers, but that includes tags and other clients and is not an achievable speed estimate.

In an isolated copy of exact checked B1 `0653f21e…`, replace only the SHA-guarded `$String$eq$` body. If both arguments are primitive, well-formed JavaScript strings, return strict equality. Otherwise execute the exact original body. Equal well-formed scalar sequences have equal UTF-16 encodings. Malformed UTF-16, null and nonprimitive inputs remain on the original path, preserving its failures and demand order. Public H already has a distinct reviewed equality primitive; this tests the fastest B1 development lane, not a new H optimization.

No pinned upstream, Bend source, runtime, default API or bootstrap metadata is modified. The transformed API is explicitly an experimental JavaScript artifact derived from checked B1, not a newly checked bootstrap. Host requests remain ordinary file/mode data, with no arbitrary injected callback/proxy or mutated builtin contract.

## Falsifier and gates

First compare the actual internal original/transformed helper through test-only exports. Cover empty/equal/different strings, ASCII/non-ASCII, valid surrogate pairs, lone high/low surrogates, malformed inputs with an early difference, null/undefined/numeric/plain/boxed values and long common prefixes. Observe returned data or exact exception name/message. Do not claim observational equivalence for arbitrary JavaScript callback/getter inputs. Wrong source/body revisions must fail closed.

Only after semantic success, run two opposite-order fresh-process real-core pairs on one reserved physical core, 4 MiB stack, 3 GiB heap and a 180-second per-process timeout. Use the same frozen host/Base/runtime and source identities, separate API-specific validated Base caches primed before measurements. Capture process wall, request wall, peak RSS and every failed attempt. Require checked exact emitted output SHA `016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`.

Stop for any semantic/output mismatch or less than 5% consistent request reduction in both core pairs. A survivor receives the list-sort and retained negative checker control with exact observations, followed only if explicitly coordinated by a short broader frontend gate. A useful local result may justify an optional future development artifact; it does not establish a full-source gain or full conformance. Retain null or failed outcomes without broadening the transform to other String operations.

## Conditional integration gate, added before execution

If both core pairs and the selected positive/negative controls pass, perform one
full-source correctness observation with the derived image and a maximum
15-minute process deadline. Reconstruct the candidate from the original checked
B1 using the guarded transform, verify the original complete fixed-point proof,
and require actual output bytes equal to H `b33b38e3…`. Preserve its elapsed time
and memory as one workflow observation, without a paired full-source speed claim
or a new bootstrap label. The separate full frontend gate uses a new truthful
`experimental-derived-frontend` report; it must not rewrite checked-source
provenance to match the derived image. Coordinate CPU masks with the root and
start neither gate if it would overrun the 20:00 experiment stop.

## Selected result, 19:13 UTC

[The complete pilot](../../implementation/phase4/b1-native-equality.md) passes 909 helper controls and one wrong-image refusal. Two opposite-order core pairs improve request time 35.58% and 35.13%; the subsequent list and retained checker rejection pairs also improve and preserve exact results. All 12 observations and actual emitted bytes match, including core SHA `016a5ced…`. Experimental API is `e95e1198…`; original checked B1 stays unchanged.

The selected gate passes. Root separately authorized a complete frontend comparison and one bounded full-source exact-H emission; those are not yet part of this selected result. No new checked-bootstrap or whole-source speed claim is made.

## Complete frontend preservation

The derived four-worker gate completed all 2,756 observations with zero raw-result or verdict changes and 377 unchanged strict failures. The [independent audit](../../implementation/phase4/b1-native-equality-evidence/frontend-independent-review.json) confirms all 45 session histories/replay digests and identities without rerunning compiler probes. Selected pilot and frontend preservation are complete. The separate full-source result follows.


## Complete-source preservation

The [single full-source gate](../../implementation/phase4/b1-native-equality-full.md)
finished successfully and emitted 1,143,517 actual bytes exactly equal to both
original checked fixed-point stages, SHA `b33b38e3…`. An independent read-only
audit verified the exact candidate guards, original checked source/proof chain,
host/helpers, runtime, canonical Base and candidate-validated cache. The durable
archive retains and verifies all 255 member paths and bytes.

Process wall was 348.373 seconds, request wall 347.098 seconds, and peak RSS
2,841,452 KiB. These are one workflow observation, not a paired full-source gain.
The candidate remains an experimental derivative (`newBootstrap:false`);
ordinary B1, compiler Bend modules and public emitted output remain unchanged.
