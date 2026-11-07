# Phase174 ELF audit: identical compiler products, distinct linker metadata

The original reproduction gate correctly rejected **raw loaded-image identity**.
N1 and N2 have byte-identical QBE, assembly and object products, but their final
ELF files and the first `PT_LOAD` segment are not byte-identical. Rebuilding the
compiler is unnecessary to understand this discrepancy.

The bounded read-only [audit](elf-audit.json) was produced by
[`elf-audit.py`](../../selfhost/tests/phase174/elf-audit.py). It reads the actual
N1/N2 executables, parses every section and symbol, compares all program headers
and loaded bytes, and accounts for the file regions outside sections. It does not
run or modify either compiler. The complete audit took less than one second.

| Property | Result |
| --- | --- |
| N1 ELF size | 16,122,336 bytes |
| N2 ELF size | 16,122,328 bytes |
| Program headers, entry point and loading parameters | Exactly identical |
| Executable, read-only-data and writable-data load segments | Exactly identical |
| First read-only load segment | 21 differing bytes, all listed in the audit |
| Allocatable sections | 24 identical; GNU build-id note differs |
| Decoded symbol records | 62,011 identical; one `STT_FILE` pathname differs |
| N1/N2 QBE, assembly and object | Exactly identical, independently checked by reproduction gate |

## Exact differences

1. ELF header `e_shoff`, the offset of the nonloaded section-header table, changes
   from 16,120,416 to 16,120,408. Only file byte 40 differs (`0x60` → `0x58`),
   within its eight-byte field `[40,48)`. The program-header table is unchanged.
2. The parsed GNU build-id note has the same type, flags, position and size. Its
   header is `namesz=4, descsz=20, type=3`, with name `GNU\0`. Its descriptor at
   `[724,744)` changes from `cfb81dc4587a822315dbd4fd342adf64d9f02d9c` to
   `b3c57a4eb086f8db376345c34abe1683238bb128`. These 20 bytes are loaded metadata;
   they must not be described as a nonloaded-only difference.
3. Nonloaded `.strtab` contains exactly one string replacement:
   `selfhost/build/phase171/native-candidate01/program.o` becomes
   `selfhost/build/phase174/native-n2/program.o`, with the same absolute repository
   prefix. Including its terminator, this string shrinks from 87 to 78 bytes.
   Every other string-table byte is preserved by that one exact splice.
4. The corresponding nonloaded `.symtab` changes 61,818 name offsets by `-9`.
   All symbol values, sizes, types, visibility and section indices match. All
   decoded names match except `STT_FILE` record 190, which contains that exact
   object pathname. There are 64,023 raw differing bytes in this metadata table;
   counting them as generated-code changes would be misleading.
5. `.shstrtab` contents are identical but its offset moves by `-9`. Padding before
   the aligned section-header table changes from four to five zero bytes. The
   section table changes only `.strtab` size and `.shstrtab` offset. Every other
   inter-section gap is identical; there is no unexplained trailer.

The shorter object filename fully explains the string-table, symbol-pointer and
section-table changes. The build-id also changes. The audit does not need or
claim a reconstruction of the linker's build-id hashing algorithm.

## Narrow acceptance and truthful fields

The original [reproduction helper](../../selfhost/tests/phase174/reproduction.py)
and its failed receipt remain intact. An `e_shoff`-only exception is insufficient:
the first attempt at this stricter audit rejected the changed GNU build-id note.

The separate [v2 helper](../../selfhost/tests/phase174/reproduction-v2.py) accepts
only this audited pair and explicitly reports:

- `wholeELFEqual: false`
- `loadedSegmentsEqual: false`
- `allocatedSectionsEqual: false`
- `compiledCodeDataEqual: true`
- `loaderRelevantHeadersEqual: true`
- `runtimeImageEquivalent: true`, with the exact two metadata ranges and every
  differing mapped byte included in the report.

Here `runtimeImageEquivalent` means identical executable code, runtime data,
dynamic-linking metadata, loading parameters and zero-fill layout under ordinary
ELF loading. It excludes file/header/build-id introspection. This is not a claim
that all mapped bytes or every conceivable observable behavior are identical.
The standalone compiler's independent output/conformance gates remain separate.

V2 recomputes the complete audit against the actual executable files and requires
exact agreement with the retained audit. It does not replace bytes in either
file, apply a broad metadata mask, accept arbitrary section changes, or relax the
exact QBE/assembly/object comparison. An unexpected changed symbol value, load
header, code/data byte, note header, string, nonloaded section or gap rejects the
comparison.

Reproduction:

```sh
python3 -B selfhost/tests/phase174/elf-audit.py --out /tmp/phase174-elf-audit-fresh.json
python3 -B selfhost/tests/phase174/reproduction-v2.py --out selfhost/build/phase174/reproduction-v2
```

Both outputs must be fresh. The first command only scans metadata and bytes;
the second authenticates existing generation evidence without compiling or
executing targets.
