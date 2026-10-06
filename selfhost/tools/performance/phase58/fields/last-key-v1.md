# Last constructor-key diagnostic

This is the final bounded saved-JavaScript key-placement hypothesis. The full reversal and width-at-most-four variants remain preserved negative experiments; no source rule is selected by this diagnostic.

`last-key-v1.mjs` derives from frozen `reverse-v1.mjs`, with all six exact edits recorded in `last-key-v1-derivation.json`. A post-runtime object must start with its ordinary `$` tag and a literal string tag value. Only its final property may change, and only when it is an ordinary quoted string init key. Earlier fields, methods, shorthand, `__proto__`, already-computed keys, unknown spread-clone shapes, exports and the exact runtime prefix remain unchanged. There is no constructor-name or field-count policy. Values, order, member accesses and printer string literals remain byte-identical.

Every output passes complete normalized AST equality allowing only the admitted `computed` flags, exact byte inversion and final input rehash. No compiler or generated program is imported by this producer. These checks establish a syntax derivative, not runtime performance or production qualification.

All parents are the genuine checked-shared01 outputs. CPU0 data-only materialization produced:

| Image | Changed last keys | Output SHA-256 |
|---|---:|---|
| Full B2 compiler | 2,634 | `1155e61db66ab02da68f91644c515a5f18aa89672d801d5713b34ca3a4fa00b1` |
| Map/Set | 375 | `f74c6e124909154375f07b0ba1c208adce0480f2c1f198ee0668296d051bf5cd` |
| Edit distance | 4 | `dc730e3490703480f841c7152f9de7731be6cf9285b951ccfd85946895396e90` |
| Morning | 302 | `2162dd8313581c4ebadeaadb237f48acc3c38485f3dd2869d2fc8e2289634412` |

B2 retains 4,236 preceding constructor keys, three marshal keys and 3,038 export keys. Its output is 3,820,748 bytes. Its receipt is `selfhost/build/phase58/fields-last01/derivation.json`, SHA `b229f48d88164d518eff5bc385110d58b4c3e30e3754d794bcfde414d3374219`. Program receipts and outputs are under `selfhost/build/phase58/fields-last-programs01/{test-map-set-ops,editdist,test-morning-program}/`.

The B2 binding is `last-key-bindings-v1.json`, SHA `2d1dc9bf7d49c722047963dd5099df051f029ada78d68e8046096a5e6049b42d`. It uses the existing method06 `syntax` role with genuine parent emission provenance. B2 printer strings are unchanged, so its benchmark emissions remain subject to the same-source output oracle. The separately transformed program modules directly test key placement in those programs.

Root-owned compiler-request comparison:

```sh
python3 -B selfhost/build/phase58/latency-method06/run.py \
  selfhost/build/phase58/fields-last-latency01 \
  --bindings selfhost/tools/performance/phase58/fields/last-key-bindings-v1.json \
  --cases lexer,test-evening-program --roles baseline,candidate \
  --rounds 3 --warm-requests 3 --mode clean --seconds 240
```

The validation owner supplies the separate three-point program bundle and existing-runner recipe. No production source is changed, and this preparation makes no target-performance claim.
