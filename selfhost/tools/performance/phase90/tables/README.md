# Linear native table builders: isolated candidate

`tables.bend` changes five growing-prefix String builders. Existing public `_go`
functions retain their signatures and seed a reversed chunk list with the exact
initial accumulator. Each new helper prepends one complete row; `nt_text_finish`
copies each row onto the final suffix once. Names, iteration order, U32 index
updates, frame arithmetic, fork membership, whitespace and terminal rows are
unchanged. No canonical module was edited by this lane.

Root's V2 tiny gate now passes: all108 String observations /5,338 codepoint words
match the independent oracle, with identical22,071-byte JS/native stdout. See
[`tables-control02/comparison.json`](../../../../build/phase90/tables-control02/comparison.json).
The checked acquisition took2.125 s and Clang1.723 s. These correctness clocks
are not an optimization speed result; full native/JS gates remain separate.

The candidate SHA256 is
`a61b8716723d683f470bb95ec8b209bf2af1b6e109f16f484530f78385e02d12`.
`baseline.bend`, `candidate.patch` and `derivation.json` retain its source boundary.
This is a native-host candidate with bounded controls passed, pending clean timing and ordinary
JS verification. The late profile that motivated it failed its outer input gate;
it is an exploratory lead, not a qualified performance result.

## Fast actual-function controls

Use **`controls-v2.bend`** and **`controls-v2.json`**. The original `controls.bend`
is retained: its first acquisition at `phase90/tables-control01` failed because
the extracted actual `nc_ctor_codes(name)` implementation fills a law and the
fixture omitted that law. V2 inserts the exact original declaration from
`identity.bend`; all function bodies, 108 observations and independent codepoint
oracles remain unchanged. It is a fixture repair, not a compiler fix.

The fixture contains the actual five original builders under `old_` names and
the actual candidate workers/wrappers, their small dependencies and native IR.
Six cases cover empty and nonempty input, arbitrary prefix including Unicode and
newlines, zero/nonzero/wrapping indices, empty/Unicode/duplicate names, parameter
and frame arities, fork/bang branches and retained inputs. All output Strings
become length-prefixed Unicode-codepoint lists: no digest substitutes for exact
bytes. Original, candidate and public wrapper outputs are checked against a
separate Python oracle. Prefix and input lengths are observed after repeated use.

Root executes serially under the existing resource guard:

```sh
node selfhost/tools/performance/phase88/component.mjs \
  selfhost/tools/performance/phase90/tables/controls-v2.bend NEW_ACQUISITION
# Run emitted JS, build emitted C with pinned Clang -O2 -lm -pthread,
# then run native with --threads 1 --gpu off; retain each guarded process.
python3 -B selfhost/tools/performance/phase90/tables/compare.py \
  selfhost/tools/performance/phase90/tables/controls-v2.json \
  JS_STDOUT NATIVE_STDOUT FRESH_COMPARISON.json
```

The expected vector contains5,338 codepoint/length words for108 complete String
observations. `compare.py` requires complete JS/native stdout identity, the exact
independent vector, unchanged source and dependency pins. A correctness fixture's
runtime is not a scaling benchmark. `make-controls.py` retains the original
fixture generator; V2's metadata records its one exact law insertion.

## Frozen native derivatives

`make-source.py FROZEN_S NEW_S` starts only from exact native89 source4584… and
replaces the five `_go` definitions plus their chunk helpers. It proves reversal
to the original whole source, preserving all other bytes, including native-only
`p88_string_eq` and Phase89 owned/chunk work. It never replaces a whole module.
The retained tables-only output is `compiler-native-tables01.bend`, SHA0431ecd5….

`combine-stackfixes.py TABLES_ONLY_S NEW_S` adds only the five current canonical
tail-loop repairs and their `_rev` helpers: `ns_image_words`, `ns_image_terms`,
`nf_wrap_segments`, `no_entry_defs` and `no_wrap_registered`. It snapshots the
three source modules and transports only exact `String.eq` identifier tokens in
the inserted functions to the existing native helper; literals/comments are
unchanged. There are two such tokens. All ten exact old/new replacements replay
against original4584… S and reverse byte-for-byte.

The combined output is `compiler-native-tables-stack01.bend`, SHA
`74b390d3ba7ada2c001dbdc6f63b0eb63b2231d129279114b1d5d55fa39d7052`.
The original `.derivation.json` remains frozen. The acquirer uses the additional
`compiler-native-tables-stack01.assembly.json`, SHA209d3dfa…; it normalizes the
transport kind to `phase90-native-source-assembly` and adds flattened input pins
without changing source/replacements. Offline independent replay/inverse/input
verification passed. Every resulting source still needs full upstream checking
before C emission/build; source assembly is not compiler qualification.

No compiler, generated program or profiler target was executed by this lane.
