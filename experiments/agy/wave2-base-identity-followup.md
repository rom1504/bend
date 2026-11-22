# Base identity follow-up — Map.set and Array.to_list.go

Two additional Wave 2 substitutions produced wrong results for a changed Base at `ee5a0038`. These observations apply to the compiler reviewed before the in-progress Base pin. They provide two regression cases for that fix, alongside the [Map.del case](wave2-map-del-base-identity.md).

| Fixture | Change in Base | Phase205 and independent upstream oracle | Wave 2 x86 |
|---|---|---|---|
| `coverage-map-churn-32` | Prefix the key passed to `Map.seek` inside `Map.set` | Digest `3982402709` | Original digest `2930913555` |
| `complete-generic-row32` | Swap subtree visitation order in `Array.to_list.go` | Each serialized array is reversed | Original array order |

## Reproduction

The measured run used one private copy of `selfhost/dist/base.bend` with both substitutions below. Use fresh `p86_prepare(copyPath, copyText)` and compile each original fixture with the resulting seed, as in the [earlier audit](wave2-map-del-base-identity.md). Run each executable with arguments `1 0 32 17` and compare its entire first output line. A smaller standalone probe produced the expected answers on both compilers, so use the named fixtures to exercise the affected paths.

```diff
-  Map.set.go(a, V, x, Map.seek(a, V, m, key))
+  Map.set.go(a, V, x, Map.seek(a, V, m, "extra" ++ key))

-      Array.to_list.go(~T, xs, Array.to_list.go(~T, ys, acc))
+      Array.to_list.go(~T, ys, Array.to_list.go(~T, xs, acc))
```

The upstream oracle used stock Base. For map churn, prefix the key at both fixture calls to `Map.set` and print `bench(32, 17)`. For row32, replace the serializer’s `Array.to_list(U32, a)` with `List.reverse(&1, U32, Array.to_list(U32, a))` and print `p88_row_output(row.probe(32, 17))`. Both oracle outputs matched Phase205 in full.

## Regression scope

With the pinned Base, Wave 2 and mature Bend C agreed on four additional input pairs for each of the 45 benchmark programs (180/180). For the Base-pin regression suite, run the changed-Base fixtures through the public compilation entry point and assert their outputs against the oracles above. Also verify that the original pinned Base still selects the fast paths. The relevant substitutions are in the [radix-trie Map emitter](../../research/agy/wave2c_map/apply_map_fast.py), [record-aggregation Map emitter](../../research/agy/wave2c_recagg/apply_map_fast.py), and [array-to-list emitter](../../research/agy/wave2c_recagg/apply_list_arr.py).

The retained local evidence is under `/home/ai/bend2/build/publish/bend/selfhost/build/phase201/`. The `agyw2base05/` directory contains both compilers’ full outputs, `agyw2oracles04/` contains the independent oracle sources and results, and `agyw2panel01/panel.json` records the pinned-Base comparisons.

## Resolution (repaired on `selfhost/agy`)

Both `Map.set` (`"extra" ++ key` → `3982402709`) and `Array.to_list.go` (`(ys, xs)` swap on `complete-generic-row32`) are now gated by `AGY-W2-BASEPIN` ([apply_base_pin.py](../../research/agy/apply_base_pin.py)) and permanently verified in [test_base_pin_regression.py](../../research/agy/test_base_pin_regression.py) ([receipt](receipts/wave2-basepin-regression.json)), with all 3 stock-Base fixtures emitting bit-identical `.o` files to `b4245701`.
