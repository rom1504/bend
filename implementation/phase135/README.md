# Phase135 — A real compiler edit with incremental machine construction

[Design](../../design/phase135/README.md) ·
[Edit and measurement contract](../../design/phase135/edit-contract.md) ·
[Recomputed metrics](metrics.json) ·
[Evidence capsule](machine-evidence/README.md) ·
[Full-source baseline evidence](validation/README.md) ·
[Machine protocol and commands](../../selfhost/tools/performance/phase135/machine/README.md).

**A real one-function compiler edit now rebuilds through compiler-announced QBE
units and reuses 56 of 66 objects. Correctness and machine identity checks pass.
This is working incremental machine construction, but not yet faster complete
compiler development.** The late semantic cache shows no adoption benefit on
this full compiler. Most remaining time is earlier in preparation and lowering.

The qualified Phase134 core and installed selection remain unchanged. The new
framed image is a separately checked experimental tool, not a new N1/N2-qualified
release. No PR comments were posted.

## What was implemented

The Bend emitter wraps its existing sealed cursor with complete-bundle boundaries.
It announces grouped functions, current data and main through a reserved comment
protocol. Groups contain at most 1,000 complete bundles; a bundle may contain
multiple QBE functions. The host transports and hashes one group, reuses or builds
its object, and links current ordered objects. It never discovers unit boundaries
by rescanning the complete QBE.

Exact payload bytes, fixed producer, QBE/assembler/linker/runtime, flags and
visibility policy govern admission. Internal generated symbols are made visible
between objects by `objcopy` for this closed executable only. Every globalization
checks allocated bytes, relocation meaning and the allowed symbol-binding change.
The surrounding supervisor requires successful native producer exit, complete
current machine receipts and exact independent QBE before accepting the result.

A cached object cannot excuse a stale source product: the current compiler still
checks, lowers, verifies and renders the entire current program. This distinction
is both the prototype's safety boundary and its performance limitation.

## Full compiler edit and the semantic-cache result

Use the existing independently checked Phase131/132 source pair: change two local
spellings in `p111q_main` from `%result` to `%answer`, preserving every other source
byte. The actual historical source paths and complete independent QBE products
remain fixed. This is a full compiler workload with retained oracles, not an
incremental self-build of the newest source.

| Same executable, original session experiment | Seconds |
|---|---:|
| A: compile and acquire semantic cache | 362.510 |
| B: compile the edit using retained cache | 374.922 |
| B: ordinary entry, no semantic cache | 364.183 |

B hits 1,387 of 1,507 private inline and prior-range entries. Nevertheless its
interval is **2.95% longer** than ordinary B in this single observation. Ordinary
B includes startup/Base/teardown while warm B excludes shared preparation. These
are not balanced causal measurements, but they establish no net adoption win.
A versus B is not a cache speed comparison. All complete products are exact.

This prevents a misleading inference: 92% of these optimizer entries is not 92%
of compilation. Initial lowering, expensive preparation, final checks, rendering
and cache validation still run. The raw-candidate audit also rules out a cheap
body-only or Ref-only key: signatures, constructor ownership/layout, normalization,
readiness, negative facts and other bodies can affect its result.

## Actual native object reuse

The instrumented source is `391a6f2d…9091c`; qualified Phase134 N2 acquired its
native image `4dd47566…20b79c` through the existing supervised QBE pipe. Acquisition
cost 382.758 guarded seconds, emitted 108,870,736 bytes without a QBE spool, and
peaked at 1.031 GB process-tree RSS. The actual native FIFO smoke passed before
the full source experiment.

The full A→B run took **766.584 guarded seconds**, including both compiler requests,
all current machine work, hashing and reporting. Both 107 MB payloads match their
independent references exactly. A built 66 groups. B reused **56** and rebuilt
**10**: 72,702,508 payload bytes reusable and 34,357,049 rebuilt. Unit hit rate is
84.8%; reusable byte share is 67.9%. Neither is a compiler-time percentage.

To measure machine savings without producer waits, replay the same current B
units against an A-only cache and a separate empty cache. The A-only view contains
only authenticated A entries, even though the original cache already contains
B's misses. Its observed hit mask must exactly match the actual native edit.
Both replay processes and consumers must succeed. Snapshot construction costs
about two seconds and is a separately charged qualification operation.

| Machine-only replay of identical current B | A-only cache | Empty cache |
|---|---:|---:|
| Complete replay including input authentication | 15.979 s | 38.906 s |
| QBE / assembly / globalization / link subprocesses | 4.846 s | 17.918 s |
| Reused / rebuilt groups | 56 / 10 | 0 / 66 |

This is **58.93% less replay time** than the prototype's own cold grouped path,
from one matched pair. Cached native B and cached replay B both have exactly the
same loaded ELF sections and headers as the independently cold current build.

**The conventional monolithic machine build is still faster:** its complete
guard took 14.699 s, versus 16.064 s for cached replay and 39.034 s for cold replay.
Cached replay was 9.3% longer than monolithic in these observations.
Grouped invocation, ELF checks and cache bookkeeping consume the saved work. Do
not advertise the 59% number as a gain over monolithic compilation or a complete
edit-loop gain. The source-to-machine pipeline, child-tool and replay clocks
have different boundaries and must not be added as independent intervals.

## Where the full request spends time

The new Bend orchestration uses the existing computations and final verifiers,
with monotonic clocks at evaluated data boundaries. Its pure route was compared
against the old route on two real edits, including entire caches/statistics,
independent complete QBE and three refusal cases.

| Native request stage | A | B | B share |
|---|---:|---:|---:|
| Parse/check, ownership, annotation, reachability and erasure | 153.539 s | 175.080 s | 46.3% |
| Admission, static/constructor preparation, generic/raw private lowering | 59.651 s | 62.179 s | 16.4% |
| Remaining optimization, cache checks, verification and emission planning | 77.613 s | 68.360 s | 18.1% |
| Rendering, framing, writing and machine backpressure | 90.517 s | 72.677 s | 19.2% |
| Total request interval | 381.320 s | 378.296 s | 100% |

These are wall-time intervals, not exclusive algorithm CPU profiles. Destruction,
new orchestration and shared-CPU machine work can affect them. In particular B's
frontend can overlap the end of A's machine build. Rendering includes downstream
backpressure. The newer instrumented image is not the image used for the earlier
same-executable ordinary/cache comparison. Do not infer causal A/B cache gains
from these stage differences.

The decisive finding is the boundary: **62.7% of B's observed interval precedes
the current optimization cache.** Even eliminating its whole optimization stage
would leave most work. The next experiment must isolate frontend substages and
reuse costly prepared definitions before initial lowering.

## Correctness, speed, memory and simplicity

- Independent source checking and 121 surrounding finite controls pass. A first
  host bridge expected tagged Booleans instead of JS Booleans; that failure and
  the corrected adapter are retained. No compiler semantic rule was weakened.
- Both full compiler QBE products are exact. Native success is joined separately
  from consumer success. Empty-cache/current-cache ELF equality passes twice.
- **18 complete compiler-output gates and six ordinary program outputs pass**
  across Lexer, closures and Map. Two rounds reverse case and compiler order.
  Partitioned compiler request time is 0.99305× monolithic geometrically; per-case
  ratios are 0.98777× Lexer, 1.00491× closures and 0.98656× Map. Treat this small
  screen as essentially flat, not a demonstrated new compiler speedup.
- Generated QBE is preserved for those checks under fixed downstream tools. This
  preserves their generated-code quality; ordinary smoke runs are not fresh
  program-runtime benchmarks. No new broad45 or N1/N2 qualification is claimed.
- Full framed-session sampled process-tree peak is **1.248 GB**. Ordinary operation
  retains one current grouped IR file, at most **18,152,461 bytes** in this workload,
  plus cached objects. This qualification intentionally retained all B text for
  independent replay. The 107 MB serialization and whole semantic IR still exist;
  neither 1 MB total IR nor a ten-second compiler rebuild is achieved.
- Selected compiler source is unchanged. The experimental framed/timed source adds
  **353 lines** to the prior session prototype (59,127→59,480). Relative to the
  qualified core it includes that older session machinery too. Host tools provide
  transport, mechanical object checks, orchestration and evidence, not another
  semantic compiler. This phase adds infrastructure rather than simplifying the
  selected compiler.

A separate prepared constructor-ownership fact passes source checking, 29 finite
controls and 18 complete hosted QBE comparisons. Its small timing screen is mixed
and it misses earlier ownership queries. It remains isolated and unselected;
see [preparation audit](../../selfhost/tools/performance/phase135/preparation/README.md).
Correct answers alone do not justify adding a global lookup wrapper.

## Costs, failures and recommendation

The two full A/B campaigns cost 12.36 and 12.78 guarded minutes; the ordinary B
baseline 6.16 minutes; new image acquisition 6.38 minutes. The matched machine
replays together cost 55.10 s, conventional machine reference 14.70 s and final
24-job gate 36.03 s. Source/API checks, bounded bridges, ownership experiments,
metadata audits and agent work are additional costs. The [complete guard inventory](costs.json)
records20 jobs totaling42.89 guarded minutes, including17.36 seconds of overlap
between independent API/finite checks. This is not elapsed session time or a
billing/quota measurement. Metadata work and agent effort remain separate.
No full45 requalification or another native generation was run unnecessarily.

One early attempt to launch the cold replay was refused by the execution lock
while cached replay was still finishing; no competing target started. It was
retried in a fresh guard after completion. Preserve this orchestration failure
alongside the failed Boolean-adapter bridge, rather than omitting failed work.

Keep Phase134 as the qualified tool. Retain framed object reuse as a tested
experimental boundary; do not make it the default based on the isolated 59%.
Priorities for the next cycle:

1. Split the 175-second frontend interval into checking, annotation and erasure,
   then test reuse of one costly unchanged prepared definition or recursive group.
   Initially retain whole-book source checking and independent final verification.
   Measure before designing a general dependency/cache framework.
2. Carry exact consumed semantic facts through that boundary: types, reducible
   bodies, ownership/layout, imports, absence and ordering. Reuse must precede the
   expensive computation. Unknown dependencies rebuild; source-body hashes alone
   are not enough for this dependent language.
3. Keep the now-working machine boundary, but lower its verification/bookkeeping
   overhead before claiming a faster edit loop. Cold grouped construction is
   substantially slower than monolithic construction. Stable literal/function
   binding could reduce the remaining ten misses; it cannot remove the 237 seconds
   already spent before optimization.
4. Only after earlier reuse saves meaningful time, connect it to cached rendered
   units so unchanged 72.7 MB need not be regenerated. Keep fixed producer epochs,
   deterministic linking and cached/fresh independent products.

This is infrastructure and information for faster research, not evidence of
recursive self-improvement. The experiment identifies what work still needs to
be eliminated and prevents confusing cache hits with accelerating research.
