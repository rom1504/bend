# Controlled B1 full-source comparison archive

`audit.json` distinguishes successful archival/audit (`complete`) from the experiment completing all four observations (`observations.experimentComplete`). `comparison.json` preserves the original report. Incomplete or failed attempts remain recorded; no survivor-only performance conclusion is implied.

Each `files` row maps its historical absolute path to a content-addressed gzip object. Every object was decompressed and compared with its original bytes. Node is an identified external prerequisite. Source, actual APIs/H outputs, runtime, Base caches, commands and consumed tools are preserved. Restoring bytes does not rewrite historical paths, create a new bootstrap, or make the old proof relocatable.
