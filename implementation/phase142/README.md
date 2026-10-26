# Phase142: incremental work proportional to the edit

Execution of the [committed plan](../../design/phase142/README.md), starting
2026-10-26 01:34UTC from `e093c3b`. This is an intermediate research checkpoint;
the freshening experiment is still being evaluated. Qualified Phase137 N3 and
the installed selection remain unchanged. No new native compiler was acquired.

## First result: a cache hit is not a useful-work saving estimate

Two checked Bend prototypes preserve complete Lexer/Map edited QBE and failure
recovery, but neither has established the plan's complete-request performance
gate. The first removes many equality comparisons; the second transports a
successful judgment through an unchanged representation. Both are retained as
experiments, not selected speed improvements.

| Experiment | Actual work removed | Measurement and disposition |
|---|---|---|
| Raw-owner witness |183/265 Lexer and641/666 Map first-boundary segment comparisons|Separate hosted APIs showed+6.56%/+3.70% median paired latency; an unchanged-path A/A control itself showed+5.56%. Causal attribution is unsafe.|
| Same-request raw/static judgment |Second raw-body scan and static-image validation after an unchanged original bundle|Shared-API screen: Lexer+3.63%, Map−2.57% median paired complete latency; order effects and inconsistent latency summaries remain. No broad win.|
| Completed-prefix freshening probe |Renaming and reconstruction of the retained prefix|On literal compiler prefixes, guarded freshening takes about0.68×/0.49×/0.34× at128/512/1024 declarations. Complete loader products and final counters match. Source02 and61 finite controls pass; integrated request evaluation pending.|

The same-request Map **ratio of median latencies** is slower, despite the lower
median paired ratio. Retain every pair; do not choose the favorable statistic or
subtract the A/A bias. All these measurements are hosted screens, not native
compiler performance or new full-build speed ratios.

## Implementations and correctness scope

The [witness](../../selfhost/tools/performance/phase142/witness/README.md) is
append-only and binds raw and verifier caches to one committed successful
revision. Diagnostic admission checks every retained claim with the original
comparator.25 new controls and25 original verifier controls pass. The original
second raw verifier remains; the final projected-worker verifier alone does not
independently check every raw body.

The [same-request prototype](../../selfhost/tools/performance/phase142/same-request/README.md)
changes only `p140b_lowered`. The original first verifier supplies the retained
raw/static bundle and metadata; that exact bundle reaches both the second check
and emission. Direct-function, array/transport namespace and final verification
remain.26 new controls and25 original controls pass. Do not silently compose
this with the first witness: their independent-check obligations differ.

Both complete screens compare fresh A, substantive B, warm B and reverted A;
parse/type errors preserve the previous successful session and recover exactly.
Existing proof declarations are byte-preserved. These are source checks,
construction arguments and finite differential tests, not a new equivalence
theorem or native qualification.

## Attribution and the next boundary

On the two hosted edited requests, the first complete verifier takes about
0.039/0.108s in diagnostic replay. The independent final projected verifier
takes0.367/0.132s. These overlap actual stage work and cannot be summed with it.
They do not establish the exclusive native floor in the historical40-second
optimization/verification stage. Immutable Base completion is only about9ms in
its own replay: a new cache for that alone is not justified.

The frontend still materializes and freshens the entire user prefix after a
parser hit. [The source audit](../../research/phase142/freshening-prefix-audit.md)
shows why parser identity alone is insufficient: relative foreign paths change
under a different logical source directory. The conservative prototype retains
normal completion/validation and guards the exact completed prefix plus the
actual starting fresh counter. Its full-request payoff remains to be measured.

The [larger completion audit](../../research/phase142/completed-prefix-reuse-audit.md)
identifies an earlier boundary: completion is elementwise under a genuinely
fixed parser/completion context. Acceptance, duplicate-name checks and dependent
checking can still depend on the suffix. A future producer-owned prefix could
avoid materialization while retaining those gates; the present experiment does
not claim to implement that capability.

## Evidence and reproducibility

The methods live under [phase142](../../selfhost/tools/performance/phase142/).
[Checkpoint evidence](evidence01/inventory.json) freezes the receipts and small
reproducer inputs in a byte-verified archive. Each run records exact source/API/tool/input hashes, complete outputs or output
digests, setup costs and guard receipts. One CPU3 lane,3GiB process-tree caps
and16GiB available-memory floors were used. Failed source annotations and an
incorrect first API-export request are preserved. The initial attribution
observer's Bool-ABI reporting bug is corrected in `attribution-v02.mjs`; do not
interpret v01's false/zero diagnostic fields as compiler refusals.

No changed default, new upstream comparison,10× build result or recursive
research acceleration follows from this checkpoint. The historical full-edit
baseline remains346.960s fresh versus124.679s inclusive warm,2.783×, from Phase140.
