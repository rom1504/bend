# Final artifact frontend evidence

`raw.tar.gz` preserves the actual completed public-H and equality-derived frontend runs, launch configuration and wrapper snapshot, genuine lineage records, copied host/harness, validated caches, retained failures, all worker histories and canonical input bytes. `manifest.json` records each regular member’s SHA-256 and length, the archive identity and external prerequisites. The archive is reopened and every member verified; all source bytes and consumed identities are checked again afterward.

Both artifacts exactly match all 2,756 final B1 observations. Their 318 strict check failures remain failures; this is artifact equivalence, not full-language conformance. No fabricated bootstrap metadata or compiler rerun is involved.

The reproducible `archive.py` requires the completed historical run and a new archive destination. It preserves absolute paths without rewriting proof or replay records. Node/Linux executables and upstream Git metadata remain external; extracting preserved files alone does not provide a relocatable worker protocol or establish a new checked build.

Verified archive: **5,175,824 bytes**, **5,034 regular members** (60,109,477 uncompressed bytes), SHA-256 `1f4e44802d0ea134a72a81628e554310b20c29a4e95f5f6debce12fb8a6289d1`. The archive process exited zero. Its output logs are retained at `selfhost/build/phase5/final-artifact-frontend-launch/archive.stdout` and `archive.stderr`; archival itself performs no compiler execution.
