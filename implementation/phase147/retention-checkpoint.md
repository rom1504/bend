# Phase147 evidence closure

All **76 guarded commands are sealed**: 68 completed, six failed, and two
qualified compiler-image builds. Qualification uses the separate
[native qualification receipt](qualification.json); it does not change the
installed compiler or establish a universal semantic proof.

The [final checkpoint summary](evidence/checkpoint02-capsule/summary.json)
records **3,216.355 seconds (53.61 minutes)** of finished outer-guard intervals.
No intervals overlap, and nested child times are not added. The guards span
5,266.870 seconds; the remaining 2,050.514 seconds is unclassified wall time,
not an estimate of agent work or CPU billing. The subsequent archive-only close
batch took 33.962 seconds, outside this guarded-target total.

The [closure summary](evidence/closure-summary.json) records **50 verified raw
archives: 891 files, 13,505,100 compressed bytes**. Each archive's complete
members were verified by the maintained close tool, and all compressed streams
were independently rehashed afterward. Twenty-five declared roots remain hot;
one failed run had an absent/empty output root. **No raw files were pruned.**

The final [compact evidence capsule](evidence/checkpoint02-capsule/index.json)
is **4,876,163 bytes with 1,588 verified members**. It contains exact small
JSON/log/method bytes, original-path mappings, declared reference identities,
the final metrics/qualification/candidate/corpus receipts, closure receipts,
and the input/source method versions needed to interpret the failures. Every
member was reopened and hashed before removing only the newly exported loose
copies. The earlier [checkpoint01](evidence/checkpoint01-capsule/index.json)
remains a distinct interim record.

The six failed attempts remain accessible:

- `profile-pilot01`: the stage observer rejected order/count/clocks after capture.
- `verifier-baseline01/api`: source extraction omitted `f_lex_scanned`.
- `verifier-candidate01/api`: a computed match scrutinee failed Bend grammar.
- `verifier-real01`: screen input handling passed a non-path to `readFileSync`.
- `integrated-plan03/source-check`: the requested output directory was absent.
- `runtime-classifier-plan04/api`: rejected checked-API acquisition, preserved
  with its exact diagnostics in the classifier history and final capsule.

These are failed attempts, not six established compiler semantic gaps. The
capsule preserves historical consumed methods rather than substituting changed
current files. Fourteen classifier-method path misses correspond to seven exact
versions in the existing classifier capsule; the supplemental resolution receipt
rehashed those members. Five earlier historical method dependencies remain
explicitly external to these Phase147 compact exports.

Final source03, N1 plan05, N2 sequel02, the full baseline, all current cold-build
and corpus comparison inputs, and the complete profiler images/maps/samples stay
hot. Unguarded preparation roots, toolchains, installed selections, unrelated
working changes, and the shared execution lock are untouched. The compact
checkpoint is not a full restorable compiler/profiler bundle: required large
artifacts remain available at their recorded paths, while the additional cold
archives provide exact recovery for their declared roots.

The [retention method](../../experiments/phase147/tools/retention/README.md)
now includes final implementation and closure receipts in checkpoint discovery,
and the packer distinguishes sealed final guards from interim checkpoints.
Both previously consumed methods were preserved by exact hash before these
changes. A final reporting-only guard makes absent/unfinished retention records
yield `false`; missing, finished, sealed, pending, and empty fixture cases passed.
No compiler or benchmark was rerun for retention. The superseded planner and
draft plan were removed from HEAD only after exact capsule-byte verification;
the selected planner remains `close-plan-v2.py`.
