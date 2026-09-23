# Closed broad-backend preparations

This archive contains three completed **metadata preparations**, not compiler executions: snapshot01 uses three workers; snapshot02 changes only to four workers/cores0–3; snapshot03 adds the reviewed completion/progress reporting guards. It also retains the actual three passing pure test groups, stdout/stderr, unchanged test source and the prospective validation plan. Broad-run evidence will be archived separately after execution.

`manifest.json` lists all files and hashes and records two historical tool-path substitutions. Snapshots01/02 still name the original mutable tool path and their original hashes; matching `.source` copies retain those exact bytes. Restore the corresponding historical tool when inspecting or replaying an old preparation. Old reports were not rewritten to identify the newer tool.

Every compressed member was read back and verified. Extract under a fresh repository root, preserving repository-relative paths. Absolute source paths in reports remain historical identities. The archive includes directly recorded preparation inputs; it is **not** the entire genuine attempt's bootstrap/source lineage or a hermetic toolchain. Use the separately preserved final compiler/attempt evidence and recorded Node/pinned checkout prerequisites before a new execution. Extraction does not fabricate checking or authorize execution during another reserved workload.

The test source hash is recorded at archival time; no claim is made that a separate pre-execution hash file existed. The actual test log reports3tests,3passes,0failures, and no compiler was invoked by those pure guard tests.
