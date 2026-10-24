# Phase134: a real native edit-reuse experiment

Retaining exact private-function optimization results made the second Lexer
request take **21.3% less time** and the complete two-revision session **9.1% less time**.
Map improved **6.1%** for its second request and **2.6%** for the complete session,
with appreciably more variation. Both families emitted byte-identical QBE to
independent fresh compilation through the qualified core compiler.

This is a small native experiment, not full-compiler incremental compilation.
The experimental session image has not reproduced itself and is not the installed
or qualified core selection. No-cache adoption overhead remains unmeasured.

## What actually skips work

The cache and session are written in Bend. A first checked request returns typed
private-function state; B may reuse it only within the same producer/runtime and
process. Inline results are keyed by the exact original function and the complete
transformed callee, or its absence, for each original call dependency. Range
results use exact input functions. Every hit republishes the result through the
same ordered table protocol. Changed inputs fall back to the original passes.

The interface skips actual inline/range work before running it. Both revisions
still parse/check, prepare their backend, verify the result, render QBE and close
their output files. Both modes prepare Base once. There is no externally supplied
or serialized cache, persistent daemon, or machine-object reuse.

## Native evidence

[Frozen plan](evidence/native/plan.json),
[complete native results](evidence/native/report.json), and
[resource guard](evidence/native/guard/process.json) bind exact source, image,
runtime, carrier, fixtures, output identities and commands. The supervisor ran
two pairs per family, reversing warm/cold order and family order in the second
round. Warm retains A's cache; cold discards it before B. Every run starts a new
process. All target execution used the coordinator's quiet CPU3 lane.

| Family | Cold B, median | Warm B, median | B warm/cold, paired geometric ratio | Complete session ratio |
|---|---:|---:|---:|---:|
| Lexer, shift amount 13→12 | 1,226.5 ms | 965 ms | **0.7868×** | **0.9092×** |
| Map, key multiplier 31→29 | 1,935.5 ms | 1,818.5 ms | **0.9388×** | **0.9738×** |

Lexer B ratios were 0.7872 and 0.7864. Map ratios were 0.9747 and 0.9042;
the small sample does not support a precise universal Map benefit. Native process
CPU ratios were 0.9093 and 0.9689 respectively, close to complete wall ratios.
Complete-session median wall times were 2.651→2.411 seconds for Lexer and
4.073→3.967 seconds for Map. Peak child RSS stayed near 42.6/44.7 MiB; this
small-workload observation does not establish full-compiler cache memory cost.

Lexer reused 26 of 31 inline units and 26 prior range results. Map reused all
34 inline units and 34 prior range results. Map's much smaller runtime benefit
despite a higher hit rate is important: **hit counts are not avoided-time
measurements**. The remaining preparation/analysis dominates that workload.

The native session uses distinct actual A/B file paths. The qualified core N2
independently compiled all four actual paths through its ordinary uncached entry;
the supervisor did not borrow the hosted experiment's same-path edited oracle.
Both historical A products also matched their frozen earlier outputs. All 16
session files matched complete independent QBE, and each real edit changed QBE.
The archive keeps all product hashes and sizes, not the large QBE files.

Five native controls passed: relative output, duplicate output and output/input
collision refusals; invalid A before creating output; and invalid B after a
complete correct A, without creating B. A sacrificial input copy stayed unchanged.
All A requests and cold B requests reported zero prior cache hits. Fresh real
output paths, alias checks and scratch directories belong to the host supervisor;
the Bend argument guard checks literal paths. The checked source also passed
[109 finite controls](evidence/checks/finite.json) and the
[independent raw-plan bridge](evidence/checks/bridge.json).

## Acquisition, failures and cost

The qualified core N2 streamed **108,111,638 bytes of QBE** directly to QBE's
stdin without retaining a compiler `.ssa` file. Emission and QBE together took
399.72 seconds. The first wrapper stopped after successful assembly because it
rejected all stderr, including four existing split-immediate warnings. Its
[incomplete receipt](evidence/native/acquisition.json) remains unchanged.

The [separate warning review](evidence/native/warning-review.json) traced each
low-word truncation to the immediately following high-word store and compared
the same pattern in the qualified parent. A separate finish reran only assembly
and linking, reproduced the retained object and diagnostics exactly, and produced
the experimental image. It did not rerun the compiler/QBE or rewrite the failed
receipt. See the [finish receipt](evidence/native/build.json).

Guarded acquisition cost was **405.82 + 7.30 = 413.12 seconds**. Source checking,
109 controls and the tiny raw bridge cost another 14.13, 2.08 and 4.25 seconds.
The successful native comparison took 35.90 seconds inside the supervisor,
36.94 seconds guarded. These are separate costs, not hidden in warm B timing.

One earlier supervisor attempt cost **8.90 seconds**: its four real-program
oracles passed, then its invented tiny fixture correctly failed because it lacked
the pilot's required `import Base`. V04 reuses the already checked raw-bridge
fixture and adds the import before the intentionally malformed negative fixture.
The compiler image did not change. The
[failed attempt](evidence/prior-attempt/report.json) and its exact inputs/logs
are retained rather than removed from the experiment cost.

The complete experimental source has 59,127 lines versus the qualified core's
58,392: **+735 lines**, including the isolated cache/range orchestration, session
entry and additional controls. It is a separate experiment, not an automatic
addition to the production optimizer. The exact source04 gzip in the
[evidence archive](evidence/archive.json) round-trips to the checked source hash.

## What this establishes and what comes next

The hosted Lexer result transfers to native execution: retained semantic units
can accelerate a real checked source edit without changing its generated program.
The hosted Map result had reversed with order; native pairs show only a modest,
variable benefit. This supports selecting cache units by measured transformation
cost rather than by hit count or a favorable single run.

Warm/cold reset isolates retention benefit, but **both modes construct cache
state for A**, and cold B constructs it again. The experiment does not measure
net adoption versus an equally prepared one-process compiler with no cache, nor
does it establish that acquisition/qualification pays back in a real research
campaign. There is no demonstrated recursive acceleration.

The next useful step is one larger measured unit that removes expensive shared
preparation while preserving exact consumed semantic dependencies, followed by
an equal-preparation no-cache baseline. Carry the independently checked output
and failure controls forward. A large persistent cache, broader framework or
promotion of this session image is not justified by these two cases alone.
