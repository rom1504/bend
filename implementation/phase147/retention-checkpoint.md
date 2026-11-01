# Phase147 interim evidence retention

The [compact checkpoint summary](evidence/checkpoint01-capsule/summary.json)
records **50 finished guarded commands: 45 succeeded and 5 failed**. Their
non-overlapping outer intervals total **929.415 seconds (15.49 minutes)**.
The original 45-command frontier requested for this audit accounted for
907.513 seconds and four failures; five further commands had finished before the
checkpoint cutoff. Nested child process times are retained as evidence and are
not added to the elapsed total. The span between the first and last recorded
finished commands was 2,148.530 seconds; the remaining 1,219.116 seconds is
unclassified wall time, not an estimate of agent work or CPU billing.

| Guard category | Finished commands | Interval union |
| --- | ---: | ---: |
| Full baseline | 1 | 262.907 s |
| Profiler build/capture/analysis | 6 | 317.356 s |
| Focused native builds | 11 | 212.046 s |
| Focused measurements | 9 | 54.353 s |
| Checked API acquisition | 11 | 44.635 s |
| Focused controls/capture | 12 | 38.117 s |

The five failed attempts remain evidence:

- `profile-pilot01`: the stage observer rejected order/count/clocks after capture.
- `verifier-baseline01/api`: source extraction omitted `f_lex_scanned`.
- `verifier-candidate01/api`: a computed match scrutinee failed Bend grammar.
- `verifier-real01`: screen input handling passed a non-path to `readFileSync`.
- `integrated-plan03/source-check`: the requested output directory was absent.

These are recorded diagnostics, not five compiler semantic failures. The
then-active `integrated-plan04/image-guard` was excluded. This is an **interim
checkpoint**, not the final Phase147 outcome, a qualified compiler, or a sealed
campaign.

The [capsule index](evidence/checkpoint01-capsule/index.json) authenticates a
2,637,374-byte compressed capsule with **605 verified members**. It preserves
1,316 original-path mappings to exact small JSON/log/method bytes, the full
reference index, and a supplement containing 59 unique exact method/provider
objects. Shared byte content appears once. Every member was reopened and hashed;
only the newly exported loose copies were removed afterward. The existing
[renderer method capsule](evidence/method-history/inventory.json) was also reopened
and its five exact member identities were resolved without restoring duplicate
methods at HEAD.

Selected N1/N2 images, the full baseline, all profiler images/maps/samples, full
compiler source snapshots, generated products, and all raw Phase147 roots remain
hot and unchanged. The shared execution lock is untouched. Large bytes are not
silently represented as archived by hashes: the capsule is **not a complete
restorable compiler or profiler bundle**. Five small historical method references
still depend on the repository's earlier retained history; their exact paths and
pins remain explicitly unresolved in the summary. All direct small method pins
for the five failures, including the profiler child methods, were retained.

The [data-only method](../../experiments/phase147/tools/retention/README.md)
provides a fresh-checkpoint and compact-package recipe for final close. Its
`close.py` argument lists are unexecuted proposals that retain every declared
root. No raw artifact was archived, pruned, or reclassified by this work. Root
review must decide qualified/completed/rejected/failed status and any cold roots
after all dependent work finishes.
