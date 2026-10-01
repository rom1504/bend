# Phase37 normal checked-compilation cost

The final checked03 candidate completes all **27 checked emissions**, with
byte-for-byte agreement against independently prepared output from the same
compiler identities. Relative to Phase36, its normal request medians increase
by **2.47% for the local-row source, 6.40% for tree-bitonic and 1.06% for numeric
recurrence**. The first two increases have disjoint sample ranges and all three
paired requests are slower. This phase improves selected generated programs
while accepting additional compiler and output cost; it does not improve
compiler throughput in this experiment.

The selected compiler's request medians remain **5.06–5.61× TypeScript** for
these three sources. Including the separately timed host import yields different
ratios, 2.76–3.29×, because the normal import/loading boundaries differ. Neither
range is a whole-compiler or representative-language estimate.

## Scope and timing boundaries

Root executed `compiler-cost02` using the unchanged Phase30 library-cost worker
and Phase35 serial runner, with the Phase37 plan binding new sources and final
checked03 artifacts. There are three sources, three roles and three fresh
processes per source/role. Role order rotates in each round. All processes use
CPU 3, Node 24.18.0, a 1024 MiB heap, a 2048 MiB process-tree RSS ceiling and a
2048 MiB available-memory floor. Every selected source imports only its own
source and pinned Base in the Bend role.

The request boundary is the normal checked-library interface:

- Bend calls the frozen driver's `inspect(source, {mode: 'library'})`. Its lazy
  API loading and normal Base-cache handling remain inside this request.
- TypeScript loads and validates the book, checks for holes and calls
  `js_lib(book, true)` inside the request.
- Host module import is timed before the request. Attempt verification,
  provenance checks, result-file writes and exact output-hash checks are outside
  the request. The outer process timer includes these activities and startup.

Both Bend roles use their validated existing Base cache, bound to their API
and Base identities. This is a fresh-process normal request with that cache,
not a cold-cache rebuild, warmed compiler server or isolated backend emission.
The TypeScript role's preflight also verifies the historical attempt context;
its actual timed compilation executes the pinned TypeScript implementation.
Process RSS therefore includes the verification machinery and cannot be read as
isolated compiler memory usage.

The catalog ID `local-pair` selects the complete `local-row.bend` source. The
numeric ID includes `1024` because that point selects its source; no benchmark
entry is executed, and a compiler-cost sample does not perform 1024 recurrence
iterations. All three roles emit the complete checked library with the same
source bytes. Generated-program execution is measured
[separately](execution/report.md).

## Same-run request measurements

Each cell gives median milliseconds followed by observed minimum–maximum in
parentheses. Ranges contain three samples; they are not confidence intervals.
Ratios use medians from this same run.

| Source | Phase36 request ms | Checked03 request ms | TypeScript request ms | Candidate change | Checked03 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Local row | 1700.878 (1700.671–1702.319) | 1742.898 (1726.674–1752.692) | 310.736 (309.270–313.633) | +2.47% | 5.609× |
| Tree bitonic | 1515.185 (1509.306–1566.392) | 1612.191 (1601.527–1632.222) | 291.213 (288.833–316.759) | +6.40% | 5.536× |
| Numeric recurrence | 1306.120 (1304.775–1315.406) | 1319.924 (1303.622–1396.666) | 260.876 (259.949–261.588) | +1.06% | 5.060× |

Local-row paired request changes are +2.47%, +1.43% and +3.06%; tree changes
are +4.20%, +5.70% and +6.82%. These are consistent measured costs, not merely
uncertainty around unchanged throughput. The median absolute additions are
42.019 ms and 97.005 ms respectively.

Numeric recurrence has overlapping ranges and paired changes of −0.90%, +1.16%
and +6.93%. Its 13.804 ms median increase is smaller, but the 1396.666 ms final
candidate sample is retained. Three samples do not establish a stable one-percent
penalty, nor is that slower sample discarded as an outlier. No averaged compiler
speed ratio is reported across these heterogeneous sources.

## Host import and complete process cost

The following table separates the host import, the worker's directly measured
import-plus-request sum, and outer process duration. Medians of different
columns need not add because they can come from different samples. Host import
and process columns include observed minimum–maximum values.

| Source / role | Host import ms | Import + request median ms | Outer process ms |
| --- | ---: | ---: | ---: |
| Local / Phase36 | 13.135 (13.068–13.366) | 1714.245 | 6079.660 (6079.445–6084.676) |
| Local / checked03 | 3.716 (3.685–13.108) | 1746.583 | 6127.746 (6061.901–6147.819) |
| Local / TypeScript | 220.177 (219.326–220.384) | 531.121 | 4691.665 (4691.382–4694.740) |
| Tree / Phase36 | 13.170 (13.035–13.836) | 1528.221 | 5880.511 (5857.401–6246.844) |
| Tree / checked03 | 3.719 (3.648–3.819) | 1615.909 | 5978.142 (5936.409–5992.584) |
| Tree / TypeScript | 221.497 (217.978–239.886) | 512.710 | 4683.215 (4629.821–5137.129) |
| Numeric / Phase36 | 13.215 (13.186–13.389) | 1319.509 | 5652.936 (5651.911–5653.241) |
| Numeric / checked03 | 3.722 (3.663–13.120) | 1323.646 | 5754.294 (5653.441–6037.440) |
| Numeric / TypeScript | 218.796 (218.241–219.789) | 479.829 | 4631.294 (4610.166–4660.395) |

Checked03's import-plus-request ratios to TypeScript are 3.288× local, 3.152×
tree and 2.759× numeric. These ratios include each interface's loading boundary;
the smaller host import is not evidence that finite selectors made compiler
startup faster. The worker's preflight verification alone takes roughly
1.54–1.85 seconds across these observations, with further input and attempt
verification after compilation. Subtracting the request from total process time
does not isolate ordinary user-facing startup.

All 27 child process durations sum to **149.306 seconds**. The runner completes
in **178.866 seconds**, including its own repeated input verification and
bookkeeping between processes. These are reproducibility workflow costs, not
compiler-request throughput denominators. Maximum measured process-tree RSS is
544,374,784 bytes (519.16 MiB) across the run, well below the enforced ceiling;
the candidate maximum is 540,303,360 bytes (515.27 MiB). The test did not measure
large-module or memory-capacity limits.

## Emitted bytes and production size

Every sample for a role/source produces the same expected checked bytes. These
are complete emitted libraries, including their runtime and generic paths, not
an estimate of executed code or compressed distribution size.

| Source | Phase36 bytes | Checked03 bytes | TypeScript bytes | Candidate increase | Checked03 / TS bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Local row | 123,547 | 124,739 | 12,457 | +1,192 (+0.96%) | 10.014× |
| Tree bitonic | 86,112 | 91,332 | 10,593 | +5,220 (+6.06%) | 8.622× |
| Numeric recurrence | 78,764 | 79,384 | 4,699 | +620 (+0.79%) | 16.894× |

The separate [production-size count](source-size-final.json) records +184
physical Bend lines, +21 definitions and one new module, with no new types or
laws. The assembled runtime grows 652 bytes; the generated compiler API grows
16,972 bytes. These are explicit costs. Reusing existing proof structures avoids
a new optimizer IR, but does not make this a source-reduction result.

## Admission and limitations

This compiler-cost gate passes checked-output equality, completeness and resource
controls. It reveals bounded additional cost on the tested requests, with the
largest consistent median increase being **6.40% / 97.005 ms for tree-bitonic**.
That is a tradeoff to weigh against its separately measured generated-program
gain, not grounds to claim cost-free optimization. Repeated finite readiness and
whole-graph checks remain plausible contributors, but this experiment does not
time individual compiler passes or attribute the increase to a specific helper.

The measurements support considering the candidate with these explicit costs;
they do not independently authorize promotion. Final semantic release gates,
all forty-five execution points and their holdout penalties, source audit and
installation remain separate obligations. No unrecorded numerical acceptance
threshold is inferred from three selected sources. Whole-compiler compilation,
long-running compiler-service throughput and cold-cache behavior are unmeasured.
The earlier checked02 cost report remains preserved and is not used as a
denominator for final checked03 claims.

## Exact evidence identities

Raw paths below are relative to `selfhost/build/phase37` and resolve after
restoring the phase evidence capsule. The report contains every source, checked
receipt, cache, generated module and process identity; the config contains the
exact independent output hashes required from all samples.

| Evidence | SHA256 |
| --- | --- |
| [`compiler-cost02/report.json`](../../selfhost/build/phase37/compiler-cost02/report.json) | `9e9b1262dc17bc21e64b85b886d1b5853680cee6d22983c5134046f6743d85a7` |
| [`compiler-cost-plan02/config.json`](../../selfhost/build/phase37/compiler-cost-plan02/config.json) | `680afaf0c2988514337a306d4e10186f85e4ed324b0dbf45e70d470735b7b7d1` |
| `compiler-cost-plan02/preparation.json` | `f0a774ef52293547cb6b63dd3c92d1120554303b98782ea8b3d7ad1f138204cc` |
| Selected checked03 attempt | `7ae878dda1b75dce1655c62d8e7238e184319da1fa04a8a12a189f37badc8f85` |
| Selected checked03 API | `ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1` |
| Selected checked03 runtime | `51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49` |
| Phase36 comparison API | `93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75` |
| Common Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| Maintained request worker | `f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42` |
| Consumed serial runner | `546248ca8eb8eae88c5ddf45f084fc0f08dd7630aa0617c2c39bb400d7335c1d` |
| Phase37 preparation tool | `ad23d89730293ed97a8e39f9603255fe9d04d10822cd47d670b30fa0dcc51e04` |

The TypeScript pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.
This document analyzes root-executed evidence read-only; it executes no compiler,
generated program, profile or test.
