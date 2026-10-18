# Native successor image comparison

The [data-only comparison receipt](../../selfhost/build/phase111/native-self02/image-comparison/report.json)
qualifies a precise load-image fixed point between `full-native03/program` (N1)
and `native-self02/build/program` (N2), with the GNU build-id descriptor excluded.
The complete executable files are **not byte-identical**: their SHA-256 values
are respectively `284797e08ea6c754e6f0a8508e3f2d3bc18b18722ba27616229fee7403897872`
and `f040f0be44522581811d6b0ed7a3067143ad733e8d703e584283d55d7896bcf3`.

| Artifact compared directly | Bytes | Result |
| --- | ---: | --- |
| Checked API QBE / N1-emitted QBE | 50,664,292 | Exact bytes |
| Original / successor QBE assembly | 68,809,177 | Exact bytes |
| Original / successor compiler object | 25,163,016 | Exact bytes |
| Cached runtime object used by both links | 94,392 | Exact bytes |

Both ELF64 headers and complete program-header tables match, including entry
address 4,212,144. The four `PT_LOAD` segments have identical layout, permissions,
file sizes and memory sizes. Their file bytes match after masking only the
20-byte GNU build-id descriptor at file offsets `[724,744)`. The parser locates
that note independently in both ELF section and program metadata and requires
identical note layout; it does not mask headers, note names, other note payloads,
code or general data. Normalization occurs only in comparison buffers.

All 25 allocated sections have matching metadata and contents under that same
exception. This includes the `.bss` NOBITS address, 1,148,424-byte size and
128-byte alignment; no nonexistent file bytes are substituted for that check.
The GNU build-id changes from `4b67c6f46652486ed47691a5df5cfc493fcdc1e3` to
`c5dc9a1c7a4bbd319708acf1954fbfc471e0608d`.

Decoding the complete static symbol tables yields exactly one semantic change:
symbol 165 is an `STT_FILE` entry whose absolute object path changes from
`.../full-native02/program.o` to `.../native-self02/build/program.o`. These are
the different input paths recorded by the two link receipts. The latter adds
six bytes to `.strtab`; raw `.symtab` string offsets consequently differ, and
the `.shstrtab` file offset advances six bytes while its contents stay equal.
This explains the path-bearing symbol difference directly. The changed build
ID is consistent with linking different metadata, without requiring a new link
experiment to establish its generation mechanism.

The useful claim is identical generated machine code, matching runtime data
and zero-fill layout, and matching loader-visible bytes **apart from the
explicit GNU build-id descriptor**. It is not raw ELF reproducibility or a
proof of identical behavior for a program or debugger that inspects the
build-id, symbols or executable file itself. No new semantic execution is
performed by this comparison; successor execution controls remain separate.

[`compare-images.py`](../../selfhost/tools/performance/phase111/compare-images.py)
authenticates the referenced build receipts and products, compares file bytes
directly, records hashes, and rechecks inputs before writing fresh evidence.
The receipt directory retains an exact method copy and summary. The comparison
took 3.347 seconds; neither native image was executed, stripped, relinked or
modified, and no existing receipt was rewritten.
