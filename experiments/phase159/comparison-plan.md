# Phase159 retained-workload comparison plan

Read-only preparation, 2026-11-04. No workload, compiler, profiler capture,
restoration or deletion was run by this audit. Root owns the guarded target
lane. The initial profiler audit identified an explicit-argv0 requirement;
the narrowly authorized tooling change is recorded separately below.

**Recommendation:** reuse the three Phase157 executables, establish direct-ELF
launching with the existing complete oracle, then collect physical leaf profiles
at16 repetitions. Compare their setup/throughput shape at0/1/4/16 before proposing
another compiler image. No source compatibility or compiler rebuild is needed.

## Exact retained inputs and restoration

The common input is the normalized, independently checked
`selfhost/tests/phase157/workload-compatible.bend`,387,345bytes, SHA256
`a926e00c75df0bc2b5c49eaccdb8cd98eb21a4b461592891338e4178fe65cca1`.
It performs five actual owner computations through original lowering, scalar
optimization, independent verification, complete QBE rendering and checked file
writing. This is an extracted compiler pipeline, not a full request/self-build.

Its absolute captured input path is embedded in the executable:

`selfhost/build/phase154/book-fixtures01/compiler-verifier-slice.book.txt`

This2,979,167-byte book has SHA256
`15f41031b1f89fe4add47cadbb80badbe677798ebd4c42638f17efd42fa502d4`.
The independent full output is
`selfhost/build/phase154/native-plan03/0-expected.stdout`,173,582bytes, SHA256
`9c08e21b3f5eac0bf17c1be4fcb76fe1fda79f8faadbf99469dfb03c3399f82e`.
Source, book and oracle were all present during this audit. Do not substitute
another book or learn the oracle from a new timed run.

| Role under `selfhost/build/phase157/` | Program bytes | Program SHA256 | State during audit |
|---|---:|---|---|
| `upstream02/program` |3311688|`8699c527f157a36a4ee9039612c8aea64ecba6efa468212c47fd351d900433c0`|pruned, exactly restorable|
| `qbe02/program` |4017712|`2eb4dc254925ac36c652e4fe0d2af861433fa627c3a4d8bf645560ae0fafb743`|pruned, exactly restorable|
| `gc03/program` |1954840|`ad6061004d5239184c93ab0ec4acf0c1e6e32990fb251cb09479e2aecfe997a2`|retained hot|

Each matching `report.json` binds common source, generated product and binary.
The corresponding report hashes are upstream
`d19c1ea3dd33c787c02996862e17d863f74d395f3e912ae8a3d9bdd144f35431`,
QBE `29ad1d99480f748bd7aa39acb279cef5f9b2c128ad930457e651c5ef4a70493e`,
and GC `af160bbe58d68ee6428b590c28b9575d1b7c9b69e41134544b70eaf929070949`.

Minimal restoration is **only `program` and `report.json`** from each of the
upstream02/qbe02 plans, about7.03MiB total. Neither QBE assembly/object/IR nor
generated upstream C is needed for initial physical leaf sampling. Source-level
machine investigation can restore those individual members later if profiles
justify it.

Existing verified plans:

- `selfhost/build-retention/phase157/upstream02-guard-close/root-00/verified/plan.json`
- `selfhost/build-retention/phase157/qbe02-guard-close/root-00/verified/plan.json`

Example for root, **not executed by this audit**:

```sh
python3 selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase157/qbe02-guard-close/root-00/verified/plan.json \
  --member program --member report.json \
  --out selfhost/build-retention/phase159/restore-qbe02
```

Use an analogous fresh receipt for upstream02. The exact complete capsule is
`implementation/phase157/evidence/phase157.tar.gz` (19,776,416bytes, SHA256
`bd1cafa21d5f647fd1b4ac17413e979f9082ca0aa585f7e4cf08517b13499e81`);
`capsule.json` lists source/input/product/member identities. Prefer selective
existing-plan restoration over expanding the entire capsule. Do not restore
the failing RC image for performance measurement.

## Exact launch contract and independent gate

`experiments/phase157/tools/measure.py` records the already validated command:

```text
bash -c 'exec -a compiler-work "$@"' phase157 PROGRAM \
  --threads 1 --gpu off -- ROLE_ARGS
```

For upstream C and bendc GC, `ROLE_ARGS` is `oracle 1` or `bench N`.
For QBE, it is `compiler-work oracle 1` or `compiler-work bench N` because QBE's
`IO.args` omits argv0. The source's `p157w_args` explicitly requires the first
Bend argument to equal `compiler-work`; a direct absolute executable invocation
without the argv0 adjustment is not equivalent.

The general profiler must pin and directly execute the actual ELF. Its sampler
is an `LD_PRELOAD` constructor and opens its output with `O_EXCL`; applying it
to the shell wrapper would first instrument Bash and then conflict on exec.
Do not disguise the shell as the measured binary or weaken ELF identity checks.
The minimal host-side solution is an explicit optional argv0 override:
`Popen(["compiler-work", ...], executable=PINNED_ELF, ...)`, while the manifest
keeps `command[0]` and its binary hash equal to the real ELF. This changes neither
Bend source nor machine code. Retain actual argv0 in the process receipt.

Before and after diagnostic work, all three direct-launch oracle controls must
exit0 with empty stderr and exact173,582-byte stdout. The bench mode accepts
runtime counts0–65536 and writes every fresh result through checked `File.write`
to`/dev/null`; stdout and stderr must both remain empty. Its oracle mode only
allows count1. Do not treat empty benchmark output as the independent oracle.
Keep the original book/source/binary/report identities pinned throughout.

## Available profiler without rebuilding the workload

`selfhost/tools/profiler/{freeze,run,analyze,compare,timeline}.py` support physical
leaf sampling of arbitrary Linux x86-64 ELF programs, not only QBE. Retained
plain sampler:

`selfhost/build/phase140/sampler01/sampler.so`,17,984bytes, SHA256
`3b20f50994acd23ff3e25f112ca9976b68618b16ba4f02ee8f10aff5dffde558`.

The same directory retains its successful build report, `sample.c` and builder
snapshot. Its source hash agrees with current maintained `sample.c`:
`261de8f0941fd1cff9c8361faad0a6622754908685cd00ac2911bdef51377894`.
This plain sampler is available for main-thread workloads, without an unwind
table, dispatch instrumentation or runtime counters. Physical leaves resolve against the exact executable
and mapped libraries. No target object, debug rebuild or Clang run is required.

**Pilot correction:** root's subsequent exact-output historical bendc seed
capture records essentially zero main-thread computation against about4.5s
process CPU. The main-thread quality gate correctly rejects it. Selecting one
Bend worker does not move its computation onto the process main thread. Thus
the available main-only collector is insufficient for that executable; do not
infer absence of work or weaken the95% coverage gate.

The historical bounded thread collector is now copied byte-for-byte into
`selfhost/tools/profiler/sample-threads.c`:12,058bytes, SHA256
`08a18d72cdddce2edd7bd8bbbeba9266391c7e891483bae59a0461d898933f5f`.
Its original remains unchanged at
`selfhost/tools/performance/phase68/parity-survey/sample-preload-threads.c`.
The maintained builder's explicit `--all-threads` selects it; the default stays
main-thread sampling, and combining it with `--unwind-table` is refused before
construction. Root will build and qualify the collector with the exact seed
output before applying it to retained workloads. The agent ran no collector.

This collector intercepts `pthread_create` and samples the main thread plus
intercepted threads, with32 total lifetime slots and25,000 samples per slot.
It does not promise coverage of raw-clone or otherwise unobserved threads.
Require whole-process sampled-CPU coverage, no thread overflow, preserved signal
handler, sound clock/timer evidence, no loss and plausible delivery. Its output
concatenates each thread's PCs; **it is not global chronological sample order**.
Use aggregate physical attribution, not `timeline.py` stage ordering or a
main-thread ownership map. Root's runtime gate is distinct from the metadata
and configuration tests below.

The sampler measures the initial main thread's CPU. CPU3 affinity and one runtime
worker do not by themselves prove that all execution is on that thread. Require
the existing coverage/delivery/loss gates: at least95% main-thread and capture
coverage for full-process attribution, no lost samples and adequate compatible
sample counts. Failures or low coverage are diagnostic limitations, not fast
measurements. Custom runtime stacks do not supply general caller unwinding;
do not transfer QBE FID/owner mappings or its libc fixed-stack tables to C runtimes.
Active dispatch/events require separately qualified diagnostic runtime hooks.

The existing threshold is500 accepted samples for pooled cost attribution. Two
N16 captures at8ms and13ms should supply enough samples for the historical6–14s
runtimes; actual quality gates decide. N0/N1 captures are likely too short for
strong attribution. Preserve them as exploratory or pool genuinely equivalent
repetitions; do not pool different work counts to manufacture threshold passage.
No hardware instruction-counter capability was established in Phase157.

## Bounded comparisons

1. **Setup versus repeated work, about120s ceiling.** After the three full-output
   controls, use the same source and binaries for a small balanced fresh-process
   ladder atN=0,1,4,16. Historical one-block costs sum roughly38s across all
   three roles; a reverse block plus controls should fit this ceiling. Retain
   wall/CPU/RSS and all samples. N0 still loads/decodes the book and constructs
   contexts; cleanup/GC effects mean it is not an exact subtractable startup
   constant. Compare scaling and incremental slopes as exploratory evidence,
   while keeping unadjusted complete-process times as the result.
2. **Physical cost at identical repeated work, about150s ceiling.** One fresh
   clean N16 observation and two separate sampled captures at8ms/13ms for each
   role, plus full-output controls. All three perform the same80 owner
   computations. Inspect physical leaves, unknowns, CPU coverage and estimated
   absolute costs using matching clean CPU, not sampled wall time. The expected
   historical sum is around79s before analysis/controls; stop within the declared
   budget rather than building new images to rescue an unusable profile.
3. **One targeted follow-up, only if the profiles warrant it.** Compare N4 versus
   N16 GC/ownership/text costs or inspect a clear physical hotspot's existing
   generated C/QBE. Timeline analysis is only meaningful for chronologically
   ordered main-thread captures, not the thread collector's concatenated stream;
   even there inferred symbol changes are not precise stage boundaries. A separate `BEND_GC_STATS=1`
   capture can correlate collection counts/intervals, but Phase157 already
   measured135 collections and about1.078s collection intervals in13.818s total.
   Repeating that alone will not explain the entire runtime gap. Diagnostic
   intervals are not exclusive GC CPU, and C/QBE textual size is not executed work.

The useful first conclusion is whether QBE's slow captured-input preparation
and bendc GC's slower repeated body have different physical causes. Do not
interpret a transport fix as production compiler acceleration without transfer.
Use root's single CPU3 lane,2GiB RSS per process,16GiB host headroom and5GiB disk
reserve. Include selective restores, reports and sample logs in disk admission;
no nested guard or simultaneous performance target. Historical GC peak RSS was
about1.19GiB, but root must preserve the live limit rather than assume that peak.

## Narrow profiler launch extension

After root's active capture finished, optional validated `argv0` support was
implemented in maintained `freeze.py` and `run.py`, preserving direct-ELF pinning
and old manifests. The command retains the real executable; only `Popen` receives
the alternate argv0 and explicit executable path. Every process receipt records
the actual argv0. Invalid nonstrings, empty strings and NUL-containing strings
are rejected; explicit manifest null is rejected too. Neither compiler/runtime
behavior nor independent oracle was changed.

The separately authorized collector migration adds only the byte-exact source
and builder selection above. Twelve focused tests pass: freeze3, runner7 and
builder2. They cover unchanged default arguments, explicit override, invalid
values, unchanged executable identity, actual kernel argv0 in a tiny Python
child, exact collector source/snapshot pinning and incompatible thread/unwind
options. Builder tests mock compilation; no compiler, Bend workload, sampler
target or performance campaign was run by this agent. Root owns collector
construction and real output/coverage qualification.
