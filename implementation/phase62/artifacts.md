# Phase62 evidence and reproduction

The [raw capsule](../../selfhost/tools/performance/phase62/artifacts/raw-campaign.tar.gz)
contains the complete closed `selfhost/build/phase62/` tree, including derived
methods, private staged images/caches, complete generated outputs, signed raw
CPU/allocation profiles, clocks, counters, scaling inputs/oracles and analysis.
The [manifest](../../selfhost/tools/performance/phase62/artifacts/manifest.json)
records every member's size/hash, verifies the reopened archive member-by-member,
and verifies that the input inventory and bytes did not change while publishing.
No failed attempt is removed. The initial data-only plotting failure and its
successful successor remain separate; compiler target jobs all passed.

Small audited summaries and diagrams are tracked under `evidence/`, `figures/`
and `figures-scaling/`. Collector/reader sources are in
[`selfhost/tools/performance/phase62/`](../../selfhost/tools/performance/phase62/).
External research is linked from the phase report with inspected upstream pins.

## Restore and replay

Check the archive SHA256 against the manifest before extraction. Its member names
are repository-relative and all refer to regular files below
`selfhost/build/phase62/`. Restore into a fresh directory; do not overwrite live
or historical evidence. From that fresh directory:

```sh
tar -xzf /path/to/raw-campaign.tar.gz
```

The JSON receipts preserve original absolute workspace paths. Existing receipt
replay therefore assumes the recorded layout; they are not silently rewritten
for another machine. To collect new observations, create new destinations and
use the factory to bind the locally restored prerequisites. Original evidence
stays unchanged. The Node pin is 24.18.0; target CPU3 and resource limits are
explicit in each collector.

Historical Phase61 raw prerequisites remain in the previously published
[Phase61 capsule](../../selfhost/tools/performance/phase61/artifacts/README.md).
They include `latency-method06`, state08 checked-B1 lineage and genuine B2.
The pinned upstream checkout and earlier catalog/oracle evidence are additional
prerequisites identified by consumed paths and hashes; follow the historical
restoration guides. Phase62 stages private copies but does not claim that its
capsule alone contains the upstream checkout or entire repository history.

Start a new collection with the data-only factory (CPU0):

```sh
taskset -c 0 python3 selfhost/tools/performance/phase62/generations/prepare.py \
  selfhost/build/phase62/NEW-INVESTIGATION
```

Its `commands.txt` and `recipe.json` give preparation, balanced clean36, CPU46
and allocation46 commands. The runner owns the guard; do not nest another
supervisor. See [generation method](generations-method.md),
[stage method](stages-method.md), [counter protocol](../../selfhost/tools/performance/phase62/work-counts/README.md)
and [scaling protocol](../../selfhost/tools/performance/phase62/scaling/README.md)
for the remaining jobs. Reader scripts run on CPU0 and never execute a compiler.

The [accounting receipt](evidence/accounting-preservation.json) sums ten serial
collection workflows: 401.903 seconds, including preparation, preflight and
validation. It verifies 110 inherited unrelated files and seven installed files
unchanged. Research, tool development, review, analysis and publication are not
included; uncovered session time is not labeled waiting. Compiler source has
no diff. No new release, self-reproduction or whole-language conformance claim
follows from these measurement checks.
