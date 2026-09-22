# Earlier rejection of duplicate constructors

P5-010 moves local constructor-name collisions to the frontend, before parsing
the second constructor's fields. Five upstream fixtures now fail in the same
phase as TypeScript. Exact parser formatting remains different; this change
resolves **no exact diagnostic comparisons** and makes no strict-suite pass claim.

The one-function patch checks the current family's earlier constructors and
constructors in prior local families. Definition and family names retain their
separate namespace. Imports require different loader context and remain deferred.
Only `selfhost/src/front/declarations.bend` was promoted, after an original-hash
check: `eb5d0837…` → `62ff74044f68fda43baa61c7c935bee21e2d38647a162e763e62508ef955de40`.

## Evidence

The final checked candidate is the exact first integrated Phase5 source plus
that single file change. API `5d6b1251e583d5eebbf8c2219ec12f26cce945ab1114525505fcf814ee8b67fe`,
source `a9da826eb671cedbbf4ed67fdd50cb332a2d4453cca61984826e3a9dba32130e`.
The audit verifies all module hashes, checked bootstrap provenance and unchanged
live reference observations.

There are 52 selected parse/check pairs per variant (26 fixtures), retaining all
known failures. Four local duplicate/order witnesses and five upstream duplicate
fixtures now report the intended reason before later malformed fields/bodies.
Four local positives and three imported namespace positives remain exact.
Earlier malformed fields still win; constructors may share a spelling with a
definition or family, and valid law fills remain accepted.

- 14 acceptance/phase differences resolve: two local cases and five upstream
  fixtures, each with parse and check observations.
- 0 exact text differences resolve;0 new exact differences appear.
- 10 acceptance/phase differences remain: five imported collisions, each in both
  lanes. 38 exact differences remain across the full selected 52 observations.

The missing-opening-brace witness remains unchanged: the current frontend only
recognizes a constructor with an indented name followed by `{`, while upstream
checks its name before requiring that brace. That broader grammar issue is not
claimed fixed. The first namespace supplement used invalid authored imports;
its failed observations and original files are preserved, and only corrected
`.bend` paths count as positive controls. A startup import-path mistake in the
supplement runner is also retained. An initial candidate included already
promoted unrelated source changes; the final causal gate rebuilt from the exact
baseline, retaining the initial attempt separately.

Compact independently reviewed the lazy branch ordering, separate namespaces,
and missing-brace boundary. No independent compiler rerun was needed. Parent
approved promotion after the final audit. All runs were concurrent correctness
work on CPU 3; no performance measurement is claimed.

## Reproduction and preservation

The [experiment](../../experiments/phase5/P5-010-declaration-freshness.md),
[fixtures](../../selfhost/tests/frontend/phase5-freshness/cases.json), and
[auditor](../../selfhost/tests/frontend/phase5-freshness-audit.py) are tracked.
[Archive manifest](declaration-freshness-evidence/manifest.json) indexes exact
sources, genuine APIs/proofs, both candidates, frozen harnesses, all raw reports,
commands/logs, invalid fixtures, and the original integrated baseline. Every
compressed member was read back and checked against its path, size and SHA.

Restore archive members at the recorded repository layout. The pinned upstream
checkout and recorded Node binary remain external prerequisites. From selfhost:

```sh
node tools/development/workflow.mjs run \
  build/phase5/declaration-freshness/candidate-exact-config.json NEW_ATTEMPT
python3 tests/frontend/phase5-freshness-audit.py NEW_AUDIT.json
```

The first command requires the restored isolated source snapshot; it builds a
new genuine bootstrap. The second audits the preserved recorded runs without
rerunning compilers. A fresh experiment must update its configured report paths;
it must not overwrite preserved evidence or relabel old checking provenance.
