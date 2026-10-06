# Single own-source check CPU diagnostic

Producer: `selfhost/tools/performance/phase57/check-profile.mjs`.
Static syntax checking passed; the pipeline/oracle and final profile-v2 helper
have independent static clearance. Final dependency-switch review passed, and
all three root-supervised own-source checks subsequently passed. See
[profile results](profiles.md) and the archived
`selfhost/build/phase57/check-profile-analysis01/report.json`. The helper is pinned to
`f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6`.
The completed joined report has three rows and no failures, SHA-256
`5599d37e36cdb25a585ed174de2cae987c35c34be2504563885a8ad34b9b4759`.
Each retained the full type-acceptance/3,012-unsafe-definition oracle. Inspector
request durations were 16.265 s for derived B1, 32.961 s for direct B2 and
54.373 s for raw B1; these are diagnostic intervals, not clean latency ratios.
The `kt` hotspot constructs KTerm records; it is not a tag-access operation.

The original helper rejected tiny negative V8 sample deltas; v2 preserves raw
data and explicit accounting, falling back to count-only views if weighted
accounting is refused. That does not waive any source correctness assertion.
This does not emit the compiler, install an image or create staging copies.

It reuses an already qualified Phase57 latency-preparation private project for
`raw`, `source` or `direct`. The four arguments are image-pins JSON, the complete
preparation report (or its exact role result), role, and fresh Phase57 output.
The pinned source is the complete Phase56 string01 assembly. Before and after
execution it verifies source/B1/direct-image lineage, checked attempt, private
copied tools, runtimes, Base and immutable cache files. It rejects absent or
changed caches rather than priming them. No environment trace instrumentation is
installed; inherited `BEND_*` values are cleared before binding the private driver.

Import and `D.loadApi()` are timed outside the inspector. There is no lexer warmup
and no earlier whole-source request in this process. The capture therefore includes
first-request JIT work with the previously prepared Base cache. It is not a clean
benchmark or the Phase56 empty-cache self-check. One whole ordinary
`D.inspect(exactCompilerSource, {mode:'check'})` runs inside the reviewed CPU helper,
with `targetMs:100`, `maxRequests:1` and 1 ms sampling. The target cannot truncate
a request; an external process-tree supervisor must enforce wall/RSS limits.

The exact Phase56 `self-check-v2.mjs` oracle is pinned by hash: all 3,012 unique
source definitions are explicitly unsafe; type acceptance and checked=true must
hold, while status=error, verdict phase, proofTrust=failed, exitCode=1 and
kernelChecked=false must remain. Every source name must occur once in the result's
unsafe list; any additional Base names are recorded. Diagnostic text is reconstructed
from that complete list and compared exactly. This is an expected trust failure,
not a mathematical proof or an oracle waiver. Oracle work is inside the sampling
boundary, including file identity checks for returned source files.

Root-supervised command, for each role, with a separately fresh output:

```sh
taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase57/check-profile.mjs \
  selfhost/build/phase56/bootstrap-string01-plan/image-pins.json \
  selfhost/build/phase57/latency-preparation01/report.json direct \
  selfhost/build/phase57/check-direct-cpu01
```

Use `raw`/`source` and corresponding fresh output names for the other images.
Root chooses 120–180 s external wall bounds, CPU3, and an explicit RSS ceiling;
this producer supplies no substitute for that supervisor. Successful output has
`report.json`, `cpu/report.json`, `cpu/profile.cpuprofile`, and `cpu/summary.json`.
A failed request retains its report/profile receipt. Rehashing and summary writing
follow inspector stop. Inclusive frame weights must not be added together.

Handwritten TS is intentionally not implemented here: its book loader/validator
can be profiled separately on the same source, but its acceptance/trust reporting
is a different oracle. No equivalence of proof verdicts would follow from such a
comparison. This diagnostic only tests the three ordinary Bend-image routes.
