# Native profile refresh: reuse the compiler object

The qualified Phase134 compiler can be profiled without another compiler
emission. Its retained `program.o` is relinked against the already authenticated
Phase131 diagnostic runtime. Both use the same Phase128 runtime source and
headers. The refreshed link and full-source capture completed successfully.
There was no new compiler emission or runtime compilation to acquire this
profile. The complete 107,059,385-byte QBE output matches the frozen independent
oracle exactly.

The prepared source/image identities are:

| Artifact | SHA256 prefix | Role |
|---|---|---|
| Phase134 compiler source | `a00019246b5181b2` | Independently checked, N1/N2 qualified source |
| Phase134 N2 | `9909f18fb9470e5d` | Clean qualified image; retained unchanged |
| N2 `program.o` | `ad4f223169e3ca61` | Exact generated program object reused for diagnostics |
| Clean Phase128 runtime | `9b3f57afb46b4db8` | Qualified runtime object |
| Existing diagnostic runtime | `8c582501c5e5c06e` | Reversible hooks on that exact runtime source/header |
| Existing sampler | `fa2897d38b6c2060` | Signal-based sampler with bounded libc CFI support |

The complete compiler source remains available in the
[qualified source archive](../../phase134/final/compiler.bend.gz).
[The preparation tool](../../../selfhost/tools/performance/phase136/profiling/prepare-v01.py)
authenticates the qualified source/image/QBE/object chain, old diagnostic build
commands and runtime source/header equality. It builds no compiler or runtime.
It regenerates the exact current owner map from retained QBE: 48,967 dispatch
FIDs, 3,734 valid lexical groups, no invalid groups. Attribution still checks
those FIDs against the actual linked image. Composite private helper provenance
and dynamic logical ancestry remain outside the map's claims.

## Refreshed result: ownership-heavy query work remains

[The exact refreshed analysis](refreshed.json) contains **11,569 samples at
32ms**, with zero reported loss/overrun, 99.678% main-thread CPU coverage and no
capture-quality rejection. The diagnostic request takes 371.773s wall and
371.555s CPU, with 974,784KiB peak RSS. This is one sampled request, with counters
disabled; it is not a paired clean speed comparison or an instrumentation
overhead estimate. The instrumented runtime still has dormant counter-hook
checks, so disabled counters do not imply zero diagnostic overhead.

| Physical leaf | Share of all samples |
|---|---:|
| `term_drop` | 17.43% |
| `span_fade` | 12.32% |
| Private borrowed string equality | 8.94% |
| `p125_rt_take2` | 4.24% |
| `p111_rt_sink` | 3.59% |
| `p111_rt_keep` | 2.90% |
| `ctr_take` | 2.84% |
| `p111_set_regs` | 2.01% |

The two drop/fade leaves total **29.74%**. This does not mean 29.74% is recoverable
allocation cost: they include reference transfer, decrements and actual frees.
The [generated-code audit](query-mechanics.md) proves recurring unnecessary
reference transfer on specific kept-row projection paths, without extrapolating
that proof to every destruction sample.

The physical view has 360 unknown-symbol samples (3.11%). Bounded libc CFI
recovers the actual caller of 352 of them: all are in libc with
`p111_set_regs` as caller. Thus direct transport plus those disjoint libc leaves
accounts for **5.05%**, rather than just its 2.01% named leaf. This is one physical
caller, not a reconstructed logical stack. Those unknown physical leaf symbols
remain unknown in the original denominator and tables; they are not silently
renamed. The [publication receipt](refreshed-receipt.json) retains these edges.

| Active query context | Share of all samples | Drop/fade within that context | Drop/fade share of all samples |
|---|---:|---:|---:|
| `nc_ctor_owned` | 7.90% | 53.17% | 4.20% |
| `lookup` | 5.15% | 49.33% | 2.54% |
| `f_find` | 5.11% | 48.22% | 2.46% |
| `p111v_get` | 4.02% | 47.96% | 1.93% |
| `index_remove` | 3.77% | 51.38% | 1.94% |
| `has_name` | 2.90% | 0.00% observed | 0.00% observed |

These intersections are subsets, **not additional costs to add to the context
shares**. The three inspected query contexts together cover 18.16% of samples.
By contrast, the already borrowed `has_name` context spends 74.93% of its samples
inside borrowed equality and none in drop/fade in this capture. That contrast
supports examining whole-query borrowing, while remaining an observation across
different algorithms and inputs rather than a controlled speedup.

The [refreshed CPU timeline](refreshed-timeline.md) reproduces the earlier shape:
`f_find` dominates early windows (36.5%, then 26.5%); `lookup` is 31.3% in the
60–90s window; `nc_ctor_owned` is 49.0% in 120–150s and recurs later. Final windows
show `String.append` at roughly 16–20.5%. CPU-window coordinates do not establish
wall-stage boundaries in the separately built stage-clock image.

The first experiment should reuse the already positive but unqualified
[Phase131 wider-reader ceiling](../../../research/phase131/wide-records.md) on
an actual current scalar name/kind consumer, preserving the held row and owning
fallback. This is overlooked composition/integration work, not a claim to invent
a new optimization. Compare against the exact original query, inspect admission
and machine calls, then measure events and native time before a full rebuild.
Indexing fewer visited rows is a separate factor. As a scale check, even halving
only the observed three contexts would remove about 9.1% of this request under
fixed-other-work assumptions; broader transfer must be demonstrated, not inferred
from the earlier 32–62% kernel wins.

## What the old evidence says

[Historical reanalysis](historical/historical.md) preserves a new compact,
reproducible view of the actual Phase131 full-source profile; it is not relabeled
as a Phase134/136 measurement.

| Active owner | All samples | Its samples in `term_drop`/`span_fade` |
|---|---:|---:|
| `nc_ctor_owned` | 7.48% | 52.99% |
| `lookup` | 5.43% | 48.76% |
| `f_find` | 5.20% | 50.97% |
| `p111v_get` | 4.43% | 41.90% |

These intersections are subsets of the owner samples. They must not be added to
owner shares as extra costs. Nor do they prove allocation sites or how much
reference work actually frees storage. The capture had 11,852 accepted samples,
zero reported loss and adequate main-thread CPU coverage, but only one sampling
period and no paired clean diagnostic-overhead measurement.

The temporal pattern strengthens the lookup hypothesis:

- In approximate sampled-CPU windows 0–30 and 30–60 seconds, `f_find` accounts
  for 37.0% and 28.7% respectively.
- In 60–90 seconds, `lookup` accounts for 31.3% and `index_remove` for 23.3%.
- In 120–150 seconds, `nc_ctor_owned` accounts for 46.2%; it also appears later
  during other computations. A late ownership table cannot be assumed to cover
  its earlier uses.

These are ordered CPU-sample windows, **not measured wall-clock phase boundaries**.
The source and generated code differ from the latest qualified image. They rank
hypotheses, not current absolute savings. Removing half the historical
`nc_ctor_owned` active computation would bound that local contribution near 3.7%
of the old full request; its 7.48% must not be called 7.48% of the new frontend.
Reducing related producer work could help outside this context, but that must be
measured separately.

## The 175-second label includes much more than checking

The selected source's `p86_plan` interval contains:

1. Source positions, header parsing and prefix/source completion.
2. `check_program_diagnostic_world`, diagnostic report preparation,
   `driver_emit_owned` and `j_compile_error`.
3. Context construction, reachability, owned annotation and `jl_checked_error`.
4. `nr_prepare_annotated`: merged definitions, maximum-bound scan, a fresh book
   index, reachable-definition erasure and closure construction.

Relevant frozen source locations are `p86_plan` at 38357, its check/report chain
at 38408–38444, annotation at 38451–38463, and `nr_prepare_annotated` at 36339.
`nc_ctor_owned` at 31097 scans the whole book and searches constructor children;
`lookup` at 5954 chooses an index only on a `BookCache`-headed book; `f_find` at
12879 remains a first-match linear scan. The proxy/source lane is auditing those
contracts independently. Do not change protected checking or infer that most
frontend time is simply a type checker.

The new native stage experiment has since separated that interval: the complete
exact-output request takes 354.331s in its diagnostic image, with 152.111s across
parse/import through erasure. Parse/import is 44.745s, checking 53.149s and
erasure 30.326s. The named **ownership-check stage is only 0.144s**; that is
distinct from runtime reference management throughout every stage, or the
backend's `nc_ctor_owned` constructor query. These are measured wall intervals
from another diagnostic image, not a speed comparison with either the historical
sample or the upcoming exact-object sample. Receipt:
`selfhost/build/phase136/staged-full01/report.json`, SHA256
`58a5f73efa48d55f034bbbcf5fcacbd003bbfe04294b45abba562094c83b566f`.

## Cheap-to-expensive measurement sequence

1. **Completed:** relink the exact retained N2 object, then sample one ordinary full A request
   at 32ms with counters disabled. This uses existing generic machinery rather
   than an instrumented compiler-source build. Expect roughly six minutes of
   target time and about 12,000 samples, not another six-minute acquisition.
2. **Completed:** attribute physical leaves, active owners, owner×leaf intersections and bounded
   libc callers in the same capture. Unknowns stay in every denominator. Record
   the timeline without inventing source phase boundaries.
3. Use the independent source/proxy lane to isolate the actual checked-book
   queries. Scale retained real definitions and query counts independently;
   preserve order, first matches, misses and `BookCache` behavior. Track actual
   comparisons/visits and scalar results before changing storage or caching.
4. Run diagnostic allocation/ownership counters on that compact native proxy or
   a small compiler request. Counts quantify events, not exclusive time, and
   generated inline operations may bypass hooks. Avoid a full event-counting
   self-build until its overhead is known.
5. Once one mechanism shows a decisive ceiling on native small work, measure one
   full same-source candidate. Keep compiler execution, backend build,
   qualification and agent work separately charged.

The broad source alone provides no count of identical repeated query keys.
Profiles also cannot say whether a caller's book head exposes an index or how
many definitions a failed lookup scanned. Those are the minimal facts the small
proxy should collect; another general profiling framework is unnecessary.

The [qualified generated-query inspection](query-mechanics.md) independently
confirms a second mechanism: existing local loops still project one field by
taking all nine owned KDef fields and sinking the other eight. It distinguishes
the resulting shared-reference churn from actual graph reclamation and from
Phase131's rejected borrowed-field-copy optimization. This is static mechanism
evidence, not a measured saving or a reason to weaken ownership admission.

## Frozen execution recipe

The root owns all target execution and resource scheduling. The following frozen
commands produced `selfhost/build/phase136/profile01`; they are retained for
reproduction. Use fresh output paths for a new campaign rather than overwriting
these consumed receipts. The link ran under the existing guard:

```sh
python3 -B selfhost/tools/profiler/build-runtime.py \
  --plan selfhost/build/phase136/profile01/runtime/plan.json \
  --out selfhost/build/phase136/profile01/build
python3 -B selfhost/tools/performance/phase136/profiling/prepare-v01.py seal \
  --out selfhost/build/phase136/profile01
```

Then execute the prepared `jobs.json` command under CPU3, 4GiB process-tree RSS,
16GiB available-memory floor and a 660-second outer deadline. The target's own
timeout is 600 seconds. It compiles the original Phase131 compiler A source,
with its exact historical source path and pre-existing 107,059,385-byte QBE
oracle. This is an ordinary cold request, not the two-revision framed session.

```sh
python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase136/profile01/manifest.json \
  --out selfhost/build/phase136/profile01/capture \
  --names compiler-self-source --modes sample --rounds 1 --periods-us 32000
python3 -B selfhost/tools/performance/phase136/profiling/analyze-v01.py \
  --profile selfhost/build/phase136/profile01 \
  --out selfhost/build/phase136/profile-analysis01
```

The sampler uses a process CPU timer and a reserved realtime signal; it does not
need privileged `perf` access. Its fixed capacity is 100,000 samples. Physical,
context and one-caller sidecars at the expected sample count are small; this
single qualification capture deliberately writes one complete 107MB stdout file.
Exact-output comparison streams hashes rather than loading it into Python.
The 30MB owner map is metadata, not another compiler output or a new runtime.
The existing profiler deduplicator may preserve a verified output as an immutable
hardlink afterward, but no file is modified during a capture.

No installed selection, runtime source, compiler semantics or correctness gate
is changed by this investigation. Diagnostic timing is not a clean speed result;
a separately qualified clean request is needed before claiming improvement.
