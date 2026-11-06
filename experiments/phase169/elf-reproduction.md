# Phase169 native image reproduction

The N1 and N2 images reproduce identical QBE, assembly, object and runtime
inputs. Every executable section and every file-backed `PT_LOAD` byte is
identical. Their full ELF hashes differ by exactly **one byte**, at file offset
10,581,178: ASCII `1` versus `2` in the local absolute `STT_FILE` symbol 190.
Its name records the linker's input object path:

```
.../selfhost/build/phase169/single-native-n1/program.o
.../selfhost/build/phase169/single-native-n2/program.o
```

This string is in `.strtab` (flags zero), outside every loadable segment. The
ELF header, all program and section headers, executable sections `.init`,
`.plt`, `.text`, `.fini`, mapped read-only/writable data and zero-initialized
memory descriptors agree. Both images have GNU build ID
`f78350cb963dc64ad1a154989098752b4eebc253`.

[The compact receipt](elf-reproduction.json) pins both build receipts and
images, records the differing symbol/string and hashes every executable
section and loadable file range. This is executable-image reproduction with a
non-loaded build-path metadata difference; it is not whole-file hash identity
or an independent semantic qualification.

The audit executed no compiler or generated program. It compared both complete
ELF files byte by byte, decoded ELF64 little-endian headers, section tables,
program tables and symbol-table entries using Python `struct`, and checked GNU
notes with `readelf -W -n`. `readelf -W -S` and `readelf -W -s` identify the
section and symbol independently. The one-byte difference lies outside every
`PT_LOAD`, so matching executable bytes does not depend on interpreting or
normalizing disassembly.
