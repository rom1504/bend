# Wave 2 can emit the old Map.del behavior for a changed Base

At `b4245701`, the direct x86 backend accepted a checked Base with a changed `Map.del` body and compiled a map-churn program that still deleted the original key. This matters whenever the compiler accepts an updated or caller-supplied Base. The frozen benchmark uses the original Base and its speed result stands.

## Reproducer

1. Copy `selfhost/dist/base.bend`. Change just the body of `Map.del` in the copy.

   ```diff
   -  Map.del.fin(a, V, Map.pop(a, V, m, key))
   +  Map.del.fin(a, V, Map.pop(a, V, m, "absent" ++ key))
   ```

2. Use the [map-churn fixture](../../selfhost/tools/bench/catalogs/native45/fixtures/coverage-map-churn-32.bend) unchanged. In the [object emission driver](../../research/agy/emit_obj.mjs), replace cached Base preparation with the Wave 2 hosted API's `p86_prepare(copyPath, copyText)`. Fresh preparation matters because the ordinary benchmark carrier contains the original Base. Feed that seed to each backend's `p86_plan`, then emit and link as usual. The reference used the Phase205 API and `runtime-live-scan.o`. Wave 2 used the unified API and `runtime-agy.o`.
3. Run each executable with arguments `1 0 32 17` and compare the first output line, the map digest. The fixture inserts keys starting with `key`, so every prefixed deletion should miss. The later success-count lines in this particular fixture compare against the original digest.
4. For an independent oracle, use stock upstream Base and apply the equivalent change at the fixture's sole `Map.del` call: pass `"absent" ++ p37.map.key(i)`. Run the fixture through the upstream CLI with a main that prints `U32.show(bench(32, 17))`.

| Evaluation | Digest for size 32, seed 17 |
|---|---:|
| Upstream with equivalent call-site change | 1962642045 |
| Phase205 compiling the modified Base | 1962642045 |
| Wave 2 compiling the modified Base | 2930913555 |
| Frozen expected output with original Base | 2930913555 |

A second input, size 31 and seed 17, also separated the two backends. Phase205 returned `2992498260` and Wave 2 returned `3758749986`. The independent upstream check covered the first input.

## Cause and regression gate

[`agy_map_book_ok`](../../research/agy/wave2c_map/apply_map_fast.py) checks constructor layout and function metadata. Both versions of `Map.del` satisfy those checks. The resulting `AgyMapDel` marker enables a wrapper implementing the original deletion algorithm. Runtime ownership and layout guards cannot distinguish the two source bodies.

Bind admission to the exact validated Base implementation, including helper definitions on which the fast path relies. An authenticated Base identity would suffice for the pinned-library route. Fall back to ordinary lowering for any other identity. Keep two regression cases: the original Base should produce the original digest and select the fast path; the one-line variant should produce the upstream digest through fallback. This experiment establishes a failure for `Map.del`; the other library substitutions deserve their own checks.

## Resolution (repaired on `selfhost/agy`)

- **Fix**: Added Step 14 (`AGY-W2-BASEPIN`, [apply_base_pin.py](../../research/agy/apply_base_pin.py)) in [compose_wave2.py](../../research/agy/compose_wave2.py), computing 64-bit dual-seed `Ann`-stripped structural AST fingerprints over the full `Map.*`/`String.{eq,cmp*}` closure (`(1678702329, 992788723)`) and `Array.to_list*` closure (`(707040475, 668870049)`), verified identical across both `live` (`p86_prepare`) and `cache` (`base.p130`) modes, and gating all three Base-library fast paths (`wave2c_map`, `wave2c_recagg`, `AGY-W2C-ARRLIST`).
- **Permanent regression gate**: Added [test_base_pin_regression.py](../../research/agy/test_base_pin_regression.py) ([receipt](receipts/wave2-basepin-regression.json)):
  - Stock Base `Map.del`: `2930913555` (32/17), `3758749986` (31/17), fast path selected, **bit-identical** `.o` to pre-pin.
  - Modified Base `Map.del` (`"absent" ++ key`): `1962642045` (32/17), `2992498260` (31/17) matching Phase 205 & upstream via fallback.
  - Modified Base `Map.set` (`"extra" ++ key`): `3982402709` (32/17) matching Phase 205 & upstream via fallback.
  - Modified Base `Map.get` and `Array.to_list.go` (`(ys, xs)` swap): exact match with Phase 205 via fallback.
  - Stock Base zero-regression: `coverage-map-churn-32`, `coverage-record-aggregation-256`, and `complete-generic-row32` emit bit-identical `.o` files to `b4245701`.
- **Note**: The earlier Wave 2 native self-build at `b4245701` predates `AGY-W2-BASEPIN` and can be refreshed to include this guard in `N2`.
