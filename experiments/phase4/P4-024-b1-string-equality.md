# P4-024: Primitive equality in the disposable B1 development compiler

Status: planned, before execution. Owner: compact-index agent. Canonical packaging verification takes priority; execute only after the scheduling reservation ends, with an absolute experiment stop at 20:00 UTC on 2026-09-22.

## Hypothesis and invariant

Final B1's generated `$String$eq$` calls ownership-preserving `String.cmp`, which reconstructs strings before the equality caller discards them. The real-core P4-022 profile attributes 16.58% exclusive samples to three comparison helpers, but that includes tags and other clients and is not an achievable speed estimate.

In an isolated copy of exact checked B1 `0653f21e…`, replace only the SHA-guarded `$String$eq$` body. If both arguments are primitive, well-formed JavaScript strings, return strict equality. Otherwise execute the exact original body. Equal well-formed scalar sequences have equal UTF-16 encodings. Malformed UTF-16, null and nonprimitive inputs remain on the original path, preserving its failures and demand order. Public H already has a distinct reviewed equality primitive; this tests the fastest B1 development lane, not a new H optimization.

No pinned upstream, Bend source, runtime, default API or bootstrap metadata is modified. The transformed API is explicitly an experimental JavaScript artifact derived from checked B1, not a newly checked bootstrap. Host requests remain ordinary file/mode data, with no arbitrary injected callback/proxy or mutated builtin contract.

## Falsifier and gates

First compare the actual internal original/transformed helper through test-only exports. Cover empty/equal/different strings, ASCII/non-ASCII, valid surrogate pairs, lone high/low surrogates, malformed inputs with an early difference, null/undefined/numeric/plain/boxed values and long common prefixes. Observe returned data or exact exception name/message. Do not claim observational equivalence for arbitrary JavaScript callback/getter inputs. Wrong source/body revisions must fail closed.

Only after semantic success, run two opposite-order fresh-process real-core pairs on one reserved physical core, 4 MiB stack, 3 GiB heap and a 180-second per-process timeout. Use the same frozen host/Base/runtime and source identities, separate API-specific validated Base caches primed before measurements. Capture process wall, request wall, peak RSS and every failed attempt. Require checked exact emitted output SHA `016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`.

Stop for any semantic/output mismatch or less than 5% consistent request reduction in both core pairs. A survivor receives the list-sort and retained negative checker control with exact observations, followed only if explicitly coordinated by a short broader frontend gate. A useful local result may justify an optional future development artifact; it does not establish a full-source gain or full conformance. Retain null or failed outcomes without broadening the transform to other String operations.
