# Streaming QBE census

This metadata-only tool reads the qualified Phase131 N2 QBE, source, existing
lexical-owner map and ELF. It neither executes Bend nor changes generated code.
The main pass streams QBE lines, retaining counters, hashes and small function
records; it never splits or retains another full QBE file.

From the repository root, use a fresh output path:

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase132/census/census.py \
  --qbe selfhost/build/phase130/p131-final-self01/program.ssa \
  --source selfhost/build/phase131/combined-literals-source01/compiler.bend \
  --base selfhost/.bootstrap/upstream-phase66/bend2/base.bend \
  --binary selfhost/build/phase111/p131-final-native01-n2/program \
  --owners selfhost/build/phase131/final-context01/owners.json \
  --out implementation/phase132/census-FRESH.json
```

`audit.py` separately joins the census to exact emission/build receipts, rehashes
its inputs, checks all byte/count partitions, and compares declaration counts
with the independent compact-symbol scanner. See the invocation in the report.
`machine-v02.py --census REPORT --out FRESH` attributes exact ELF `.text`
`STT_FUNC` sizes to the same disjoint categories. The earlier `machine.py` and
machine01 report remain as evidence; v02 excludes `_init`/`_fini` entries outside
`.text` and avoids unnecessary string-table copying. QBE code byte totals agree.

The observed syntax has no quoted strings or comments. The tokenizer nevertheless
treats both as opaque, separates `$globals`, `%locals`, `@labels`, whitespace and
other syntax, and checks that these account for every byte. Data initializers
use observed scalar numeric/relocation cells; the linked ELF independently
confirms the allocation scale. Storage compression uses Python `zlib` and
`zstandard`; compressed streams are counted/hashed, not retained.

Duplicate hashes preserve signatures, constants and external/global names.
The first only erases the definition name; the second also erases insignificant
whitespace and consistently alpha-renames local variables and block labels,
including repeated non-SSA names. Neither is permission to merge functions:
linkage, dispatch identity, source attribution and address observation remain
separate obligations. No dead-code claim is made.

All output files refuse overwriting. Main execution was CPU1, 158.34 seconds,
323,512 KiB peak RSS, with a 2 GiB address-space cap. This is a one-time metadata
survey, not a compiler timing. Zstd level 19 alone took 46.16 seconds; omit that
codec in a newly versioned method when only routine syntax counts are needed.
