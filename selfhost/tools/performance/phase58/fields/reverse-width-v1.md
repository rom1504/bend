# Narrow computed-field diagnostic

This is an isolated saved-image test of a width hypothesis. It is not a selected source rule or a threshold search. The earlier full reversal remains frozen in `reverse-v1.mjs` and `fields-reverse01`; root reported worse lexer and Evening compiler-request latency for that reversal.

`reverse-width-v1.mjs` derives from the reviewed full-reversal producer, with its exact edits in `reverse-width-v1-derivation.json`. It admits only tagged constructor objects whose complete remaining fields are ordinary constant string-key properties. Width excludes `$` but includes preexisting computed and `__proto__` fields. At width at most four it restores computed syntax for quoted keys. Wider constructors and spread marshalling objects of unknown complete width stay unchanged. Existing computed keys and `__proto__` syntax stay unchanged at every width.

The complete runtime prefix, export map, member accesses, key order, values and all printer string literals are untouched. Full normalized AST comparison permits only the admitted `computed` flag changes; exact inversion recovers the complete parent bytes. This changes the compiler image's own constructor syntax, not the syntax it emits for benchmark programs. The same-source output oracle remains required by the existing latency runner.

The parent is actual shared01 B2 `b7c5752d66ae4eaa8619e06b5a12655b370fba9d745d223660fbbb73da68fec8` (3,815,480 bytes). CPU0 data-only derivation passed and produced `d442e555db1468fda0cbbe687f378bd4cfbbe115568560698a32bf8de67ac27d` (3,826,312 bytes), with 5,416 reversed keys, 1,454 retained wide keys, three retained marshal keys and 3,038 untouched export keys. Receipt: `selfhost/build/phase58/fields-width01/derivation.json`, SHA `675ccb07d927e9a947cd1c135c4818c4697238e2295aaac820c99669a18873e7`.

The inventory counts static expressions, including cold paths and cloned/inlined bodies. It says nothing about execution frequency, physical allocations, escape behavior or object-shape stability.

| Ordinary fields | Constructor sites | Field sites | Diagnostic choice |
|---:|---:|---:|---|
| 0 | 1531 | 0 | unchanged (empty) |
| 1 | 92 | 92 | computed diagnostic |
| 2 | 1847 | 3694 | computed diagnostic |
| 3 | 362 | 1086 | computed diagnostic |
| 4 | 136 | 544 | computed diagnostic |
| 5 | 47 | 235 | literal retained |
| 6 | 20 | 120 | literal retained |
| 7 | 25 | 175 | literal retained |
| 8 | 29 | 232 | literal retained |
| 9 | 68 | 612 | literal retained |
| 10 | 8 | 80 | literal retained |

`KTerm` has width 8 at 15 sites; `KDef` width 9 at 68 sites; `KLiteral` width 5 at 13 sites. These remain literal. The receipt contains every constructor tag/width row. A production rule would require independent controls spanning widths, immediate use, loop-carried state, escaping values and numeric/mixed fields: width currently covaries with those properties.

Root-owned execution, using the unchanged method06 runner and its resource guard:

```sh
python3 -B selfhost/build/phase58/latency-method06/run.py   selfhost/build/phase58/fields-width-latency01   --bindings selfhost/tools/performance/phase58/fields/reverse-width-bindings-v1.json   --cases lexer,test-evening-program --roles baseline,candidate   --rounds 3 --warm-requests 3 --mode clean --seconds 240
```

No compiler, benchmark or generated target was executed while preparing this diagnostic. No production source was changed.
