# Phase175 ELF audit: one nonloaded filename byte

The actual `full-native-n1/program` and `full-native-n2/program` executables
have **exactly identical loaded bytes and executable code/data**. Their whole-file
SHA256 values differ because a single nonloaded string-table byte records the
different object filename.

The [bounded static audit](elf-audit.json) uses the existing Phase174 ELF parser
through a new [exact-pair method](../../selfhost/tests/phase175/elf-audit.py).
It reads files only: neither compiler was executed or modified. The old method
was not changed. No byte masks or mapped-byte exceptions are admitted.

| Property | Result |
| --- | --- |
| N1 and N2 ELF size | 16,140,352 bytes each |
| ELF, program and section headers | Byte-identical |
| Every `PT_LOAD` segment and zero-fill layout | Identical |
| Every allocatable section, including GNU build-id | Identical |
| Raw symbol table | All 62,073 records byte-identical |
| Inter-section gaps and padding | Identical |
| Whole ELF | Exactly one byte differs |

At file offset **12,414,840**, `.strtab` changes ASCII `1` (`49`) to `2` (`50`):

```text
/home/ai/bend2/build/publish/bend/selfhost/build/phase175/full-native-n1/program.o
/home/ai/bend2/build/publish/bend/selfhost/build/phase175/full-native-n2/program.o
```

This is the name referenced by `STT_FILE` symbol record 190. Both names occupy
82 bytes before their terminating NUL, so string offsets, symbol records,
section offsets and file size do not change. Every other string-table byte is
identical. The GNU build-id is identical:
`17d251bcb4a5145a69042573f58636c08f7e58cd`.

N1 SHA256: `cd78bd5d4000fbeecc907cd65b33502ee5cd5fcb1fef898bcf947d67cf3d6dda`.
N2 SHA256: `88be8d8627ed84f5cf4ebb84bafa96c890b074fa49803056d6fd8a52fd8aaa02`.

The truthful fields for **this pair** are `wholeELFEqual: false`,
`loadedSegmentsEqual: true`, `allocatedSectionsEqual: true`, and
`compiledCodeDataEqual: true`. This is stronger than Phase174's narrow
loaded-metadata equivalence: do not inherit that phase's exceptions or false
raw-loaded-equality fields. Ordinary loading sees identical images; executable
file/symbol-table introspection can distinguish the filenames. This is not a
universal observational-equivalence theorem.

The first static attempt conservatively expected Phase174-style build-id changes
and rejected this pair because only `.strtab` changed. Inspection established
build-id equality; the final method instead **requires exact equality** of every
mapped byte and all headers. No failed target execution or compiler rebuild was
needed.

Reproduce to a fresh output path:

```sh
python3 -B selfhost/tests/phase175/elf-audit.py --out /tmp/phase175-elf-audit.json
```

The native build receipts separately establish matching QBE, assembly and object
products. This audit establishes the exact final ELF distinction; it does not
substitute for independent semantic/output qualification.
