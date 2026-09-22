# Final private profile versus B1, public H and TypeScript

The final private image passes all **72 exact observations** across two complete
three-round comparisons. On the repeat with exclusive CPU0, private H reduces
successful request time by 35.0% for tree and 36.9% for list sort versus public H.
Checked B1 remains faster. The exact rejected bytes case remains a rejection.

The image is `4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3`,
with the corrected lexical-scope transformation and the named Boolean/stability
profile. All Bend compilers consume the final checked source and shared runtime.
Their exact identities and genuine checked/fixed-point/private provenance are in
[the evidence](private-final-small-evidence/manifest.json).

Median complete request time, seconds, from the confirmation comparison:

| Workload | Checked B1 | Public H | Private profile | Pinned TypeScript |
| --- | ---: | ---: | ---: | ---: |
| Tree, checked emission | 1.649 | 3.203 | 2.083 | 0.405 |
| List sort, checked emission | 2.835 | 5.823 | 3.673 | 0.456 |
| Bytes operations, exact rejection | 0.826 | 2.378 | 1.599 | 0.373 |

The successful private requests remain **5.14× and 8.05×** the TypeScript request
times. Complete child-process medians are 3.423/5.016 seconds for private H,
2.935/4.108 for B1, 4.515/7.152 for public H and 1.953/2.016 for TypeScript.
The corresponding private/TypeScript process ratios are 1.75×/2.49×; startup and
identity verification explain why these ratios differ from request-only ratios.
These child processes use the benchmark's data-only request boundary; they do
not include a separate canonical private CLI supervisor.

Each round uses fresh processes, and the variant order reverses in the second
round. Node v24.18.0 uses a 4 MiB stack and 4 GiB heap. Each Bend compiler has its
own validated Base cache, prepared before timing. TypeScript loads/checks Base
within each request because it has no equivalent serialized cache. All variants
use the same canonical Base. OS caches are not flushed. Other physical cores
are active, so this is not an otherwise idle-machine measurement.

The first complete comparison passed 36/36 observations, but two independent
profile-package guard checks briefly overlapped CPU0. Their conservative bounds
and filesystem evidence are [retained](private-final-small-evidence/contention.json).
Instead of removing selected samples, the entire unchanged 36-observation matrix
was repeated with exclusive CPU0. Both reports and all timings remain available.
Initial private medians were 2.091/3.540/1.577 seconds; the repeat's values above
show ordinary run variation, especially on list sort. No compiler or measurement
configuration changed between the two comparisons.

Every row preserves status, phase, checked flag, diagnostic and expected exit
code. Every successful program executes with its expected output. All emitted
Bend bytes are equal across B1/public H/private H, independently compared from
the actual files in addition to the harness's hashes. TypeScript emits its own
representation and is compared by observations and execution. This experiment
does not establish faster generated user programs: the optimized compiler emits
the same Bend JavaScript bytes. Full-source and full frontend gates are recorded
separately.

To repeat from `selfhost/`, use a new output directory and the archived absolute
configuration after verifying its prerequisites:

```sh
node tools/performance/phase4/compiler-compare.mjs \
  build/phase4/private-final-small-config.json build/phase4/private-final-small-NEW
```

The archive retains both complete comparisons, configuration, provenance,
consumed benchmark/host tools, fixtures, representative emitted programs and
independent input/output verification. See its [summary](private-final-small-evidence/summary.json).
