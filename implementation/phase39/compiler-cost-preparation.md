# Phase39 checked compiler-cost preparation

The new `selfhost/tools/performance/phase39/compiler-cost-plan.py` is a
prospective successor of the immutable Phase37 planner. It performs the existing
read-only attempt/cache verification and writes a cost plan; it does not run
the measured compilation requests. Root alone executes either stage.

Parent SHA256:
`ad23d89730293ed97a8e39f9603255fe9d04d10822cd47d670b30fa0dcc51e04`.
Successor SHA256:
`43ebb0a6bab827f7ddc872a1db90fb9591c51d40e7409b9910f00248f9c29cde`.
The successor asserts the parent identity. Its Python syntax was inspected with
`ast.parse`; execution is pending.

The old planner assumed the only supported archived baseline was
`programs/baseline/manifest.json`. Phase39 instead retained the exact checked
Phase37 `checked03` acquisition in `phase39/baseline/manifest.json`. Its new
`baseline` label maps to the original acquisition's **`candidate`** role. The
nested earlier reference also contains an older baseline, which must never be
used as the Phase39 compiler-cost denominator.

The successor follows that mapping explicitly. It verifies the portable archive,
original acquisition manifest, preparation receipt, selected point/source/module
identity and original checked emission receipt. For the new baseline, the
receipt's attempt hash and API/runtime/Base/driver hashes must match the verified
checked03 attempt. For TypeScript it follows the retained nested reference and
its original `typescript` acquisition, then compares the pinned source hashes
against the live pinned checkout. Original role labels and receipt bytes remain
unchanged and are copied into the new plan's retained evidence directory.

Both paths bind source and expected output hashes, catalog and upstream pin.
The ordinary fresh candidate receipt must also match its role's complete compiler
identity. Safe archive-member checks bound names, file sizes, total expansion
and duplicate members. The output includes explicit `retainedLineage` records.

The Phase30 worker, Phase35 bindings and runner, three rotated fresh-process
samples, CPU3, 1 GiB Node heap, 2 GiB RSS ceiling/free-memory floor and separate
import/request/process metrics remain unchanged. Worker SHA256 stays
`f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42`.
No changed measurement formula or historical timing enters the denominator.

Root invocation, using new output directories and the final candidate:

```sh
python3 selfhost/tools/performance/phase39/compiler-cost-plan.py \
  selfhost/build/phase39/FINAL_CHECKED \
  selfhost/build/phase39/FINAL_PREPARATION/manifest.json \
  selfhost/build/phase39/compiler-cost-plan01 \
  --baseline-attempt selfhost/build/phase37/checked03 \
  --baseline-preparation selfhost/tools/performance/phase39/baseline/manifest.json
python3 selfhost/tools/performance/phase35/compiler-cost-run.py \
  selfhost/build/phase39/compiler-cost-plan01/config.json \
  selfhost/build/phase39/compiler-cost01
```

The planner defaults to the Phase37 catalog and three unchanged, unadapted source
cases: `local-pair`, `tree-bitonic`, `coverage-numeric-recurrence-1024`.
`--cases` can choose other catalog points; adapted output is refused because the
unchanged compiler-cost worker emits ordinary libraries. Both commands own the
resource lock; do not nest them inside another lock-owning supervisor.
