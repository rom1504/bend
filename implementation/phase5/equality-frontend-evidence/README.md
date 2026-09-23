# P5-015 evidence

`raw.tar.gz` preserves the four complete raw frontend reports, all persistent
worker histories, known failed probes and reproductions, process logs, exact
launch/audit tools, source snapshots, checked and derived APIs, original bootstrap
and separate derivation evidence, validated caches and consumed fixture bytes.
`manifest.json` records every actual archive member's bytes and SHA-256; the
archiver reads every compressed member back before marking it verified.

Run `python3 implementation/phase5/equality-frontend-evidence/archive.py` only
against the completed original workspace and a fresh archive destination. The
script refuses to replace an archive or accept changed consumed inputs. Extract
the archive at the repository root to recover its recorded relative paths.
Reports retain their original absolute paths. Exact replay additionally requires
the recorded Node/Linux tools and original clean pinned upstream Git checkout;
these external prerequisites are not fabricated by extracting source files.

See [the measured result](../equality-frontend.md). Complete observation coverage
retains374strict check failures per sweep and is not a conformance pass.
