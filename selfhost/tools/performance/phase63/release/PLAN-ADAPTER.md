# Release plan adapter

`prepare-plan.py` derives the pinned Phase53 release planner in memory. Its only
admission change replaces exact snapshot/live equality of `release.mjs` with
the reviewed `closure-patch.json` transformation, while adding the graph helper
to exact snapshot/live checks. Every patch edit must match once; retained before
and after files, the selected snapshot and the live packager must agree.

The helper must also be a unique `host-tool` input in the genuine checked
bootstrap provenance. Compiler source, checked/derived API, Base, driver and
runtime checks remain in force. The five original target commands remain
install, verify-before, legacy42, default24 and verify-after. The generated plan
pins the adapter, parent, patch, before/after files and helper. It executes none
of those commands and does not alter a historical method or snapshot.

After root reviews and applies the exact packager delta, prepare a fresh plan:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/release/prepare-plan.py selfhost/build/phase63/checked-state09 selfhost/build/phase63/SELECTED_RELEASE_OUTPUT --packager-patch selfhost/tools/performance/phase63/release/closure-patch.json --plan selfhost/build/phase63/SELECTED_RELEASE_PLAN.json
```

The existing final-plan `release-commands` mode can convert this same-schema
plan into root launch commands. Root still admits installation separately after
qualification and preservation. Do not run the consumed final orchestration's
old `release-prepare` command: it deliberately retains the old planner and would
reject the changed packager. Execute this fresh adapter instead and retain both
method identities.

At preparation time only Python syntax and exact transformation anchors have
been checked. No plan, installed compiler or release target has been created by
the adapter's author.
