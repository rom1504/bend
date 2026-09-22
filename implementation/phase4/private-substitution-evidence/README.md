# P4-025 evidence objects

`manifest.json` maps 142 readable labels to 70 gzip objects. Every object records its compressed and uncompressed SHA-256 and size; the archiver checked decompressed bytes before publication. Repeated original/candidate images and exact emitted outputs share objects.

The labels preserve controls1/2/3, the complete comparison, consumed input/helper files, per-request configs and requests, original historical test sources, and current reproduction tools. Historical test inputs whose original path now contains a later revision resolve to the retained hash-matching source, identified by `consumedOriginalPath`. No historical report was rewritten.

To inspect a file, find its label in `files`, then decompress its `object` with `gzip -dc`. Restore files into a fresh directory and verify the raw SHA before use. Configurations contain the original absolute paths; restoring a different physical layout requires explicit configuration/provenance regeneration, not pretending those identities are unchanged.

The Node executable is an external prerequisite recorded by exact path/hash/version. The candidate is a disposable private image and is **rejected for insufficient opposite-order performance**, not a new checked bootstrap or default compiler. See [the implementation report](../private-substitution-workers.md) for scope and commands.
