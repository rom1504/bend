# Current QBE N2 profiler preparation

Preparation completed offline on CPU0. No compiler, native workload, sampler,
GCC, QBE or Lean target was run by the preparation agent. Root owns guarded CPU3
execution. The current compiler and production runtime are unchanged.

## Exact executable and representation

`selfhost/build/phase147/profile-prep01/ready.json` authenticates selected N2
`367b639915c0…` from `selfhost/manifests/current.json`. Its image source remains
`96c40c9dd273…`; current canonical source is `00940ed508e7…`, related by the
qualified whole-QBE identity `dceae94a7659…`. These source identities are kept
separate.

Explicit retained **data**, acquired under `profile-prep01/inputs/`:

- N2 program object: 25,437,152 bytes, SHA256 `04575430f750d2ee7ef69e1192ec1d8a8102814f0c0fac912029ded60f2aaf19`.
- Matched QBE: 117,232,528 bytes, SHA256 `dceae94a7659ad1ff58395ed34914971422ff9e5841668e910cd95e6b0914010`.
- Image source and original successful N2 build receipt. The receipt authenticates
  N2 input IR against the retained N1 QBE, despite N2's streaming build not
  retaining its own duplicate IR.

Maintained `owners.py` parses that QBE. Maintained `attribute.bind_owners`
checks all **55,111 FID table pointers and 71,854 function symbols** against the
actual selected ELF. Required data/function symbol roles remain separate. Later
stage FIDs changed from the former Phase144 image: for example
`p128raw_plan_finish` is now 30,768, not 30,703. The new spec derives every FID from
exact decoded names and verifies direct-dispatch roles; it does not transfer
old FID integers.

The stage *labels/order/interval descriptions* derive from the retained spec,
with exact current FIDs. Source pins document the emitter ownership assumption;
they do not turn lexical ownership into a logical call stack or prove arbitrary
QBE provenance. The complete successful build/product identity supplies a
separate representation connection.

Runtime source is maintained `selfhost/src/runtime/qbe/`, matching the selected
serial-RFC object. Runtime compile flags remain `-O2 -std=gnu11
-ffp-contract=off -DP144_SINGLE_MUTATOR_RFC=1`, one Bend mutator, `--threads 1
--gpu off`. Generic context instrumentation and staged_v1 are reversible; the
generated program object is unchanged. No historical Python implementation is
imported. Phase directories in acquisition receipts identify retained data only.

## Sampling decision

The consolidation smoke used a 250µs main-thread CPU timer. Its retained portable
quality evidence reports 608 delivered samples, 9,072 overruns and roughly
2.422 seconds of main-thread CPU: delivered/expected = **6.276%**. Main-thread
CPU coverage was 99.51%, so the evidence points to timer delivery/coalescing,
not missing worker CPU. `sample.c` uses `CLOCK_THREAD_CPUTIME_ID` with
`SIGEV_THREAD_ID`; the observed effective cadence was approximately 4ms. This
suggests kernel CPU-timer accounting granularity, but the kernel mechanism was
not independently measured. No unsupported claim about exact kernel HZ is made.

Use **32,000µs** for the first full capture, following previous successful full
captures. A ~250s request supplies thousands of samples. Root can request a
fresh 13,000µs capture if a specific stage needs finer attribution. Do not relax
zero-overrun, delivery, CPU-coverage or minimum-sample gates. A small request at
32ms checks exact output, FID/order/address binding and stage clocks; its sample
distributions will usually remain descriptive below500 samples.

## Root execution

All output roots below must be fresh. Commands use one maintained outer guard;
the controller does not acquire another guard. `build` compiles only the small
sampler/runtime and relinks the exact object. Budget90s/2GiB/128MiB disk;
expected5–15s. The controller and preparation files are frozen before execution.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase147/profile-build01-guard \
  --run-root selfhost/build/phase147/profile-build01 \
  --seconds 90 --disk-mib 128 --rss-mib 2048 --available-mib 8192 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/build/phase147/profile-method01/controller.py build \
  --prep selfhost/build/phase147/profile-prep01 \
  --out selfhost/build/phase147/profile-build01
```

The pilot first runs the ordinary selected compiler, then runs the diagnostic
image against its complete QBE/stdout and stderr. This is an instrumentation
neutrality control, not an independent compiler-correctness oracle. The input is
the maintained self-contained Lexer fixture. Prepared Base mode matches the
full process-cold request. Budget60s/2GiB/64MiB; expected3–8s plus offline binding.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase147/profile-pilot01-guard \
  --run-root selfhost/build/phase147/profile-pilot01 \
  --seconds 60 --disk-mib 64 --rss-mib 2048 --available-mib 8192 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/build/phase147/profile-method01/controller.py pilot \
  --prep selfhost/build/phase147/profile-prep01 \
  --build selfhost/build/phase147/profile-build01 \
  --source selfhost/tests/consolidation/native-broad/lexer.bend \
  --out selfhost/build/phase147/profile-pilot01
```

Only after the small gate passes, bind the full canonical source and the
completed clean baseline product. The controller rejects absent/empty oracle
files, so wait for `cold-baseline01` to finish. Budget480s/6GiB/768MiB; expected
250–330s including diagnostic overhead. Root should check actual free-memory
conditions and baseline peak RSS before launch.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase147/profile-full01-guard \
  --run-root selfhost/build/phase147/profile-full01 \
  --seconds 480 --disk-mib 768 --rss-mib 6144 --available-mib 12288 \
  --file-mib 256 --cpu 3 -- \
  python3 -B selfhost/build/phase147/profile-method01/controller.py full \
  --prep selfhost/build/phase147/profile-prep01 \
  --build selfhost/build/phase147/profile-build01 \
  --source selfhost/build/phase147/baseline-source/compiler.bend \
  --oracle selfhost/build/phase147/cold-baseline01/program.ssa \
  --out selfhost/build/phase147/profile-full01
```

Each capture retains the ordinary profiler manifest, exact full-output checks,
quality analysis, stage sidecar and authenticated `stages.json`. `summary.json`
contains all exclusive stage intervals, sample counts, and top physical leaves
and active lowered owners **within each stage**. Adjacent interval boundaries
exclude one sample at each edge; prelude/exit gaps remain unassigned. The optional
nested final-verifier interval is excluded from the exclusive total. These are
sample counts, not runtime event counts; events are disabled for this timing
capture. Diagnostic times must not be reported as clean compiler gains.

The prior smoke's failed quality result is preserved; the new period is a fresh
experiment. No result is claimed for these root commands until receipts exist.


## First pilot failure and exact boundary correction

Root built diagnostic01 successfully in6.84s. Pilot01 emitted the exact complete
577,601-byte Lexer QBE (`7020b75d…`) but correctly **failed** stage validation.
All required entries appeared once except `p128raw_lowered` (zero); the clock
error flag was false. The retained context-preserving compiler routes
`p128raw_session_finish → p146c_finish → p146c_closed → p146c_verify →
p128raw_verified`. The old `p128raw_lowered` entry is now only the fallback.

`profile-method02/controller.py` and `profile-prep02` replace that required
boundary with exact `p146c_closed`, FID31,504. It remains mandatory **once**, in
the same order; no validator or quality gate changes. The boundary remains
post-original-close/finish and pre-independent-verification. Exact source bodies,
lines and failure pins are in `profile-prep02/boundary-repair.json`.

Use the commands above with **method02, prep02, build02, pilot02, full02**.
All01 artifacts remain immutable, including the failed stage report. Rebuild
is necessary because the spec hash and map are compiled into the diagnostic
runtime. No result is claimed for02 until a fresh small output/stage gate passes.


The durable current replay method is
`experiments/phase147/tools/profile-controller.py`. It differs from frozen
method02 only by locating the repository root relative to its own path;
`profile-controller.derivation.json` records both hashes and the exact delta.
It uses the same maintained implementations and previously frozen preparation.
For later root commands, replace `selfhost/build/phase147/profile-method02/controller.py`
with this durable path. Consumed method snapshots remain in raw evidence.


Pilot01 also provides a successful **timer-delivery** observation independent of
its failed stage contract:32ms delivered39 samples versus39.593 expected
(98.50%), zero dropped samples/overruns and98.99%main-thread CPU coverage.
Only the minimum500-sample quality gate fails, as expected for a small request.
This supports retaining32ms for the full capture; it does not rehabilitate the
failed01 stage mapping.


## Corrected pilot qualification

Root's pilot02 passed the complete577,601-byte output contract and all current
stage-entry/address/order checks. `p146c_closed` appeared exactly once; all23
required markers met their contracts, and the optional final-verifier marker
remained absent. The diagnostic process took1.237s versus1.142s for its separate
ordinary clean request (one pair, approximately8.3% overhead).

Sampling delivered37 samples,97.03%of expected periods, with zero drops/overruns
and98.96%main-thread CPU coverage. Distributions remain descriptive below500.
The longest small-input stage clocks were optimizer0.330s, prepared Base0.235s,
render/output0.194s wall, and first verifier0.121s. These are observations on the
Lexer request, not estimates for full compiler compilation.

The durable offline summarizer `experiments/phase147/tools/profile-summary.py`
was exercised against this capture. `profile-pilot02-analysis/` retains the full
ranked stage table and within-stage owner/leaf evidence. It can be applied to
`profile-full02` after completion without target execution. A full clean machine
build includes QBE/as/link and pipe backpressure; its time must not be used as
the denominator of standalone diagnostic compiler overhead.

## Full current-source capture

Root's full02 capture passed exact117,232,528-byte QBE equality. The **child**
request took251.358s wall (250.889s process CPU), distinct from260.9999s of outer
guard time that also includes metadata work. Its7,794 samples had zero loss,
99.9937%timer delivery and99.4596%main-thread CPU coverage. Stage attribution
covers249.365s thread CPU and7,750 samples after edge exclusions;44 samples remain
at boundaries or outside stage intervals. The seven largest stage distributions
individually meet the500-sample gate.

| Exclusive stage | Thread CPU seconds | Staged CPU share |
|---|---:|---:|
| Render/output/teardown until milestone exit |47.469|19.0%|
| Raw generic/private lowering |36.937|14.8%|
| Parse/load |32.292|12.9%|
| Checking/publication |31.546|12.7%|
| Initial optimizer |28.861|11.6%|
| Observer composition and selected final admission |20.064|8.0%|
| Registry preparation |16.879|6.8%|
| First independent verifier |8.323|3.3%|

The strongest actionable observations are:

1. **Text construction remains the largest interval.** In render/output,
   `String.append` accounts for16.3%of active-owner samples; `p144e_body_tail`
   and`p111q_memory` add9.7%and9.1%. Physical leaves concentrate in take2,
   extend/destination-fill and reclamation. This supports testing structural text
   assembly and avoiding intermediate term/list transport. Active-owner shares
   include private callees; they are not direct function self time.
2. **Lowering repeatedly traverses terms and environments.** `nc_uses_term/list`,
   `lookup`, `nq_layout_subst` and`p111_op_id` are prominent. Equality and dropping
   terms are prominent physical leaves. Fewer traversals and retained immutable
   indices are plausible mechanisms; this profile alone does not prove which
   reuse is legal or predict its speedup.
3. **The frontend is material:25.6%combined parse/check CPU.** Parser owners
   include`f_eq`, growth, pattern substitution and constructor lookup. Checking
   includes`p131i_insert`, `book_final_seen`, `index_remove`, `book_final_scan` and
   lookup. Shared identity/index improvements could affect more than one pass.
4. **Symbol/string work crosses optimization, verification and registration.**
   `p111v_get` is17.7%of initial-optimizer owner samples. Registry preparation has
  18.5%`String.eq` and12.0%`String.append` owner samples. Across the whole capture,
   distinct equality/hash/compare leaf sites total9.58%; their caller,
   continuation and reclamation work is additional and must not be guessed.
5. **Ownership traffic is larger than allocation calls.** Whole-capture physical
   groups show16.74%reclamation plus19.94%ownership/products, versus1.71%allocator
   sites. These groups are disjoint classifications. Removing materialized
   intermediates and unnecessary ownership/transport operations has broader
   potential than allocator-only tuning. Unknown leaves remain4.05%of samples.

First verification costs8.323s. The optional final verification appears on the
full request and costs9.324s, **nested inside** the20.064s composition interval;
never add it to that parent. Each verifier has fewer than500 samples, so its
within-stage distribution is descriptive although its clock interval is valid.
Even the unrealistic removal of both entire intervals would remove only about
7.1%of staged CPU. Prepared Base decoding is0.238s/0.1%on this full request.
Neither is the principal remaining source of a large speedup.

Full ranked results and exact within-stage owner/leaf observations are retained
at `selfhost/build/phase147/profile-full02-analysis/{summary.json,report.md}`.
These are one diagnostic capture, not clean speedup measurements or call counts.
The small-pilot ranking did not predict the full ranking, reinforcing the need
for both a fast mechanism loop and occasional representative full captures.
