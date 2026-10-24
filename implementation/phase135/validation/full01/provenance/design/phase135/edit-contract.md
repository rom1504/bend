# Phase135 real compiler edit and evaluation contract

Starting point: `17a9e43`, with the qualified Phase134 core and separately tested
Phase134 native session. This document selects an experiment, not a production
compiler edit. The coordinator owns native execution and resource allocation.

## Use the existing real edit before acquiring another full oracle

The first full-size pair is the exact Phase132 edit of the Phase131 compiler:
change both local output spellings in `p111q_main` from `%result` to `%answer`.
Every other source byte, declaration and total source length is preserved.
This changes the compiler's actual emitted main-wrapper text while preserving
the wrapper's intended behavior. It is not an implementation of a faster
compiler, an upstream migration, or a reason to change the selected compiler.

The choice is useful because the expensive independently checked full products
already exist, and the edit is known to stress nonlocal binding rather than
only primitive arithmetic:

- A: `phase131/combined-literals-source01/compiler.bend`, SHA
  `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
- B: `phase132/source-edit01/compiler.bend`, SHA
  `3ebf67c2ad9664dacee53a3a00ec590a91487a3f16ec1f3eb29161a7e0f3e7fa`.
- Independent A QBE: 107,059,385 bytes, SHA
  `f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e`.
- Independent B QBE: 107,059,557 bytes, SHA
  `c48ad08b501f646aa8e253ca325bdb78cdee5ddac47a9e4598eac57813d8a784`.

Phase132 found 476 changed generated functions and two changed data declarations,
despite changing only one source declaration. Of those functions, 377 differed
only in recognized numeric copy operands, all shifted by 12. This implicates
static-pool relocation but does not prove all remaining differences harmless.
The exact products, not normalized names or interpreted relocations, remain the
oracle. See [Phase132](../../implementation/phase132/incremental.md).

The frozen plan verifies the historical emission command's **actual source
path** for A and B. The session receives those very paths. It does not copy the
files into a new semantic namespace or feed B's text under A's path. The current
session compiler is a different fixed producer from the historical reference;
this is an explicit differential experiment. A mismatch is a failure to explain,
not permission to silently replace or normalize the oracle.

The input compiler is Phase131, not the latest Phase134 source. It is a full-scale
compiler workload with a valuable retained oracle, not a claim to have made the
newest compiler incrementally self-host. After seeing its results it also ceases
to be an untouched statistical holdout for later policies.

## Fast source-derived slice

Do not replace the full-size question with `p111q_main` alone: that is one tiny
constant-producing declaration and could reward precisely the cheap-primitive
cache rejected in Phase134.

The source-only extractor instead copies the dependency closure of
`p111q_text` from the actual compiler, preserving declaration order and bodies.
It includes `p111q_chunks_indexed`, the edited `p111q_main`, descriptor/data and
segment rendering, identifier/index support, constructor layouts, lists and
String construction. The initial packaged slice has **406 declarations,
3,256 lines and 136,293 bytes**, plus a tiny wrapper that renders an IR value
as data. Both revisions carry the same full-compiler edit.

Artifacts: `selfhost/build/phase135/emitter-slice01/{a,b}.bend` and its report;
producer: `selfhost/tools/performance/phase135/validation/extract-emitter-v01.py`.
This packaging is **not source-checked yet**. Its lexical dependency closure is
a conservative extraction aid, never a cache key or proof of invalidation.
Check it before execution and derive complete independent A/B QBE through the
qualified compiler. The generated synthetic IR string is data; do not execute
it as machine code merely to test caching.

This slice preserves meaningful compiler dependency interactions but cannot
establish the full-image ceiling, memory cost or broad invalidation rate.
Keep the full compiler experiment separate. Use the existing 20 cache mutation
controls for unchanged/changed complete callees, absence→presence, nested calls,
reordered units and fallback behavior. Add a second unrelated compiler subsystem
only after this slice shows that the proposed cache avoids expensive work.

## First full native observation

`validation/full-session-v01.py` prepares an immutable plan and then, only under
the coordinator's guard, executes one A→B warm session using the already built
experimental native image. A acquires the cache; B reuses its returned state.
All source/runtime/producer/carrier identities are verified before and after.
The original final verifier remains in the compiler. Both complete output files
must match their historical independent QBE bytes exactly.

The initial plan is `selfhost/build/phase135/full-session-plan01/plan.json`.
Resource contract: CPU3, 1,200-second deadline, 4 GiB process-tree RSS ceiling,
16 GiB available-memory floor, 256 MiB per-file ceiling, two fresh real output
paths. Existing successful session/negative gates bind the experimental image;
do not repeat its acquisition or pretend it is fully self-host qualified.

Record preparation/A/B internal monotonic milliseconds, process wall/user/system
CPU and peak RSS, all hit/miss counters, exact output identities, failures and
guard actions. Native A's zero prior hits is a consistency check. B zero hits,
a slowdown, memory refusal or byte mismatch is useful negative evidence.

**A versus B is not a speedup measurement:** their source differs, A constructs
cache state, B inherits Base, and only one order is observed. This first run
answers whether full compiler reuse executes correctly, fits memory and skips
actual units. It does not establish a warm/cold, no-cache or upstream ratio.

## Equal-image ordinary baseline

After that run, compile actual B once through the **ordinary entry of the same
experimental executable**, using the existing `phase130/native-request.py` and
the same independent B QBE oracle. No mode or native rebuild is added.

`validation/ordinary-baseline-v01.py` verifies that every original qualified-core
declaration is unchanged except `p111_native_args`; its six-argument ordinary
arm and original failure branch are identical. The session/cache helpers are
additional declarations, not part of the ordinary entry's route. This fixes the
machine image, layout, runtime and producer while comparing the actual uncached
compiler path with the cache-enabled path.

Frozen plan: `selfhost/build/phase135/ordinary-baseline-plan01/plan.json`.
Use the same CPU/memory/file limits, a 650-second inner deadline and a 700-second
outer deadline. This remains one scoped observation, not a stable benchmark.

The ordinary process includes startup, Base preparation and teardown; B's session
interval excludes shared preparation and starts after A closes. Report both raw
numbers with those boundaries. The session's measured preparation is useful
context, not an exact authorization to subtract all preparation from another
process. Do not claim one-process equal-preparation cache speed from these
different clocks. A future exact one-process no-cache mode requires a separately
qualified change and is warranted only if the current evidence is positive.

## End-to-end clocks and decisions

Keep these costs distinct:

1. **Source/API acquisition and compiler image build:** all checking, native
   source-to-QBE, QBE, assembly, linking and any failed attempts. Existing session
   acquisition cost is already recorded in Phase134; do not charge it as zero
   merely because it is reused for this experiment.
2. **Cold cache acquisition:** process preparation plus A compilation, cache
   construction, final verification, complete output writing and closing.
3. **Warm edit request:** B read/check/prepare, dependency validation and misses,
   transformation, final verification, complete output writing and closing.
4. **Ordinary B baseline:** complete same-image uncached B process, including its
   own preparation; preserve the clock-boundary difference noted above.
5. **Usable edited executable:** warm B request plus incremental machine-build
   lookup, rebuilt objects and linking. No machine work is skipped or credited
   until a real same-input build is performed and independently compared.
6. **Validated experiment:** all above work actually paid, output checks,
   semantic gates, failures and agent effort. Do not call increased cache hits
   recursive research acceleration.

Rank candidate caches by measured transformation time avoided after paying
dependency checks, state retention and destruction. Phase134 Map's 34/34 hits
saved much less time than Lexer's 26/31; primitive-only generic-owner memoization
was rejected entirely. A new cache must skip an expensive admitted computation
before doing it, not hash finished output or index cheap helpers for a large hit
count. Exact shared-IR equality can cost as much as a refused transformation.

Full compiler IDs, continuation counters, pool offsets and order-sensitive
admission are consumed facts. Either include them conservatively in keys, or
prove that a reused named result can be rebound under the current context.
Unchanged source signatures alone are insufficient. Preserve negative facts and
full callee bodies when the optimizer consumes them, and retain independent final
verification. Report static-key churn separately from real semantic invalidation.

The strongest result would be a large reduction of complete B time at bounded
memory, with exact outputs and useful reuse across another unrelated compiler
edit. If hit counts are high but time barely falls, the next unit belongs earlier
in expensive preparation; adding more policy search or another cache layer would
not answer the measured bottleneck.
