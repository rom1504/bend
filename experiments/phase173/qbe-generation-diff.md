# Streaming generation-product comparison

`selfhost/tests/phase173/qbe-generation-diff.py` is a metadata reader, not a
compiler pass or a target runner. It has not been run by its author against the
large products. Run after the controlled native measurement lane is idle:

```sh
python3 selfhost/tests/phase173/qbe-generation-diff.py \
  --old-capsule selfhost/build-retention/phase169/p173-owned-native-n1-08 \
  --old-report selfhost/build/phase173/owned-native-n1-08/report.json \
  --new-report selfhost/build/phase173/owned-native-n2-08/report.json \
  --successor-report selfhost/build/phase173/owned-native-n3-08/report.json \
  --out selfhost/build/phase173/owned-generation-diff08
```

The archived N1 product is exactly member `program.ssa`,100,193,009 bytes,
SHA256 `aa7d731335ce38f51619b3a80978dbc64913e634cf58d21c4bbec9983d035614`.
Its capsule retains the producer-report pin and exact compressed/member pins.
The script validates those receipts, hashes the compressed archive, and streams
the member without extracting another SSA copy. It compares that product to the
hot N2 SSA authenticated by its successful build report. The corresponding
reports must identify identical compiler source, Base, carrier, preparation mode,
providers, output contract, linked runtime and machine-build settings.

Each generated function/data/type declaration is hashed from its first header
byte through its balanced closing brace. A quote/comment-aware streaming scan
retains at most128KiB input chunks and64KiB of declaration header; it never stores
a complete body or data table. Inter-declaration whitespace/comments have a
separate digest. Every input byte belongs to one declaration or that outside
region. Unsupported headers, truncated strings/bodies, duplicate declarations,
changed input identities and exceeded bounds fail closed. This is a parser for
the emitted QBE shape, not a replacement QBE verifier.

In-memory metadata scales with declaration count, capped at250,000 declarations
per product. It contains names, sizes, hashes and newline counts, not IR bodies.
The output is a small summary plus `changed-declarations.jsonl` (bounded64MiB),
listing exact symbols, changed/added/removed status, old/new sizes and hashes.
Unchanged declarations are counted without repeating all of their identities in
the report. Existing `FID_<decimal-codepoint>_...` names are decoded exactly using
the convention in `native/text.bend:nt_fid`; the compiler-family prefix is kept.
Other names remain opaque. No compact-ID map or source-owner relationship is
invented.

These are exact textual product differences, **not a count of admitted optimizer
sites**. One source rewrite may change multiple continuations, local fresh IDs,
references or data tables. Stable symbol identities localize inspection; they do
not prove that every changed body did less dynamic work.

The script separately authenticates N2/N3 ELF files and reads their ELF64 x86-64
program headers. It hashes every `PT_LOAD` file range in chunks and compares
entry point, type, machine, flags, addresses, file/memory sizes and alignments.
This distinguishes whole-file identity from identical load images while
preserving both exact binary pins. It does not execute either image, assume a
particular differing nonloaded section, or establish whole-compiler correctness.
N2/N3 QBE, assembly and object identities are also compared from their successful
receipts. Independent correctness and measured timing remain separate evidence.
