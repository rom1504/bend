# Complete parser fallback

Prepared, not executed: `selfhost/build/phase160/parser-prepare01/manifest.json`.
The normalized source is311,357bytes/1,055 declarations, SHA256
`8a633982c446c1115285ab1f93b70e83e9df3347a98d36be89705de7f2f6fee6`.
Six expression-lambda layout edits preserve the lexical payload. An independent
parser/source-check gate is still required before calling it a valid program.

```sh
python3 -B experiments/phase160/tools/prepare-parser.py \
  --out selfhost/build/phase160/parser-prepare02
```

The script transports the exact maintained `f_load_graph_trace` dependency
closure, unchanged Phase155 `p155p_def`/`p155p_terms` full serializers and the
private [harness](../../selfhost/tests/phase160/parser.bend). It performs no Bend
execution. It pins two runtime inputs: the original qualified3,085,157-byte
compiler source and the independent Map churn program, plus the selected75,064-
byte Base. Actual source is read from those files at runtime, not embedded.

The parser sees identical located paths `/phase160/Base.bend` and
`/phase160/Main.bend`, with full UTF-16 ranges. Both Base and input are freshly
parsed. This is a complete parser/loader computation, but its live Base work
differs from the prepared-Base boundary in the Phase153 full request. It includes
no type checking, ownership lowering, optimizer, verifier or backend emission.

The output file contains the **complete FResult**:

```
"R" + p155p_defs(book) + "E" + p155p_string(error) + "I" + p155p_terms(imports)
```

Every KDef/KTerm constructor and field is represented, including source spans,
removed-name lists, lambda flags, literal payloads, quantities, nested
constructors, native/unsafe flags and index tree payloads. String fields have
length prefixes. No hash replaces equality. The native writer emits one
definition at a time using the original `p155p_def`; list punctuation and final
error/import fields exactly reproduce the existing whole-value serializer.
This avoids retaining a second complete text representation of the whole book,
though a single definition can still be large. Outer FLoadTrace bookkeeping
(`done`, supplied sources) is discarded consistently; it is not claimed as part
of this FResult oracle.

Success requires empty parser error and a `main` declaration. Failed parsing
cannot count as a successful fast result. File errors propagate and close the
handle. The runtime output path must differ from both inputs; the supervisor
must also supply a fresh output file so a failed run cannot inherit old bytes.

The optional hosted exports `p160p_parse` and `p160p_text` permit an independent
upstream-compiled full-value oracle. At minimum, acquire the same normalized
source with qualified N2 and compare every output byte against that program
before timing the bendc image. Retain the complete output, not merely a printed
checksum. This tests backend preservation of the unchanged algorithm; it is not
an independent proof that the parser implements every language rule.

CLI user arguments:

- C: executable argv0 must be `phase160-parser`, followed by absolute INPUT,
  BASE and OUTPUT paths; the C runtime exposes argv0 to Bend.
- QBE: pass explicit `phase160-parser INPUT BASE OUTPUT` after the runtime
  `--threads 1 --gpu off --` options; its IO.args excludes executable argv0.

All roles use the same Base and normalized source, input paths/bytes, serial
policy and output protocol. `IO.now` barriers separately report `read_ms`,
`parse_ms`, and `observe_write_ms` on stderr. The observation interval includes
the success check, complete serialization, file writing and close. Whole-child
clean timing must still include process startup and final cleanup; do not
substitute these millisecond diagnostic clocks for paired clean observations.

Preparation itself took less than a second. Prior Phase150355KB parser-image
acquisition took45.6seconds; that is only a planning reference for a similarly
sized closure, not a bound or measurement of this image. bendc acquisition cost,
full output size, peak RSS and execution performance remain unknown. Root owns
all guarded source checks, builds, outputs and comparisons.
