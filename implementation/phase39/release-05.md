# Installed Phase39 checked05

Checked05 is installed and verified. All **42 ordinary/relocated CLI checks** and
all **15 post-install audit groups** pass; **227 canonical files** match the
selected checked snapshot. The [release record](release-05.json) binds the
installed manifest/API, exact gates, owner closures, execution and compiler-cost
reports. [Final gates](final-conformance/gates.md) retain each assertion and scope.

- API: `04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
- Runtime: `51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49`, unchanged.
- Target: `018751270e800bc222a93dad7f257083ee53a5f7`, unchanged.
- Prior installed Phase37 API is preserved at
  `selfhost/dist/release-history/ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.

The image is a derivative of a genuinely checked B1 bootstrap. Installation
does not create a new self-emitted fixed point or establish full backend/GPU or
independent proof-kernel conformance. Existing shared failures remain visible.

## Exact sequence and preserved environment failure

`selfhost/build/phase39/postinstall-launch01` successfully installs and verifies
the release. Its smoke step fails six native CPU builds because the sandbox
denies spawning the pinned Clang executable (`EPERM`). The remaining ordinary
and relocated checks complete, and the original 36-row report, all logs and
failed launcher are retained.

Root reruns the **unchanged** frozen smoke launcher and runner under the same
CPU3, 1 GiB heap and 2 GiB process-tree limit, with native subprocess execution
enabled. `release-smoke-retry01/checks/report.json` passes all 42 checks;
`release-smoke-retry-run01/run.json` records **41.797 seconds** and peak RSS
**602,902,528 bytes**. The extra six rows execute the successfully built native
binaries. No compiler change or assertion relaxation is made for this retry.

The independently reviewed Phase39 audit successor accepts an explicit retry
report. It retains the original 42 CLI assertions and verifies the original
plan's exact launcher/runner, final API/Node, consumed sources, successful inner
and outer commands, resource limits and preserved failure logs. Its
`postinstall-audit-run01` passes all 15 groups in 10.751 seconds.

## Admission and reproducibility

[Performance admission](performance-admission.md) retains four guarded emission
rules with explicit generic-row, compilation and source-size costs. All 45
primary execution points, separate canaries, 154 application executions and
15 + 7 + 3 + 4 semantic owner groups refer to this same checked image.
The [portable benchmark guide](../../selfhost/tools/performance/phase39/README.md)
provides previous/current/TypeScript output bundles; its five-point fast smoke
passes in 17.444 seconds without rebuilding the compiler.

From `selfhost/`, use `npm run verify:release`, then `node cli.mjs FILE --run`.
The [compiler guide](../../docs/BEND-IN-BEND.md) documents ordinary usage and the
[checked workflow](../../docs/PHASE5_DEVELOPMENT.md) documents rebuilding.
The [evidence capsule](evidence/README.md) preserves raw successes, failures,
modules, receipts and profiles after [writer closure](raw-closure.json).
