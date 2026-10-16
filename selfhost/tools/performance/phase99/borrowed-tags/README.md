# Borrowed tag projection investigation

This directory contains source-only evidence and a bounded design, not a compiler
candidate. The [report](../../../../../implementation/phase99/borrowed-tags.md)
explains the schema, interprocedural call and virtual-literal boundaries.

Reproduce the exact audit with a fresh receipt path:

```sh
python3 selfhost/tools/performance/phase99/borrowed-tags/audit.py \
  --out selfhost/build/phase99/borrowed-tags-audit02/report.json
```

The method authenticates complete Phase98 source and generated C files, records
exact spans, and runs 18 static assertions. It executes no compiler or generated
program and cannot mutate Phase98 inputs. The first receipt is
`selfhost/build/phase99/borrowed-tags-audit01/report.json`.

`controls.json` is a future validation specification. Its cases are unexecuted;
they do not represent passing runtime tests. No executable patch recipe is
provided because admitting production tags requires coordinated proof plumbing
across several backend modules. Phase98, canonical modules and selected assets
remain unchanged.
