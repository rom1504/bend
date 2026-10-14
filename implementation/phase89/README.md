# Phase89: faster native compiler, engine comparison and self-hosting limits

**Outcome:** a usable, separately qualified native B1 with owned result
composition, ordered body chunks and nine audited IO providers. Map compilation
uses28.0% less cold request time and33.7% less fifth-request time in the paired
native comparison. The final image passes eight live/cache gates,45 broader
exact-C points and ten launcher controls. No PR comment was posted.

Canonical production remains32,591 physical Bend lines in132 modules, unchanged
from the Phase89 start. Installed Phase82 JS B2 (`098320e8…`) also remains intact.
The native profile adds93 physical compiler-module lines; it is deliberately
separate because the same source changes regress ordinary JS B1. Native B2 is
**not** established: full self-emission reached its600-second deadline without C.

## Measured results and decisions

| Goal | Result | Decision |
| --- | --- | --- |
| Native compilation speed | Map cold/fifth request reductions28.0%/33.7%; other sources mostly small changes | Keep owned composition and deferred body text in native profile |
| Host engine | Upstream Bun cold process time20.2% lower than Node; our JS B2 is slower on Bun | Compare upstream on Bun; keep Node for our JS B2 |
| Final native versus upstream Bun | Five of six cold-process wins; Map1.385×; equal-source geomean0.4924× | A small workflow screen, not general parity |
| Repeated native requests | Fifth Map3.625×, Lexer2.152×, Numeric0.548× upstream Bun | Warm throughput remains a separate gap |
| Compiled-program speed | Exact previously qualified C on all45 broader points;81 final timing outputs also match their role-specific oracles | Existing code identity preserved; no fresh program-execution speed claim |
| Conformance | New actual-image file IO gates, tiny argv/decoder controls, all45 broad C points and launcher refusals pass | Native host still one source importing Base; no full-language or native-B2 claim |
| JS compiler speed | Combined native patch slows ordinary JS B1 request geomean4.11%; owned-only1.15% | Reject canonical source promotion; installed JS unchanged |
| Simplicity | One ordered text representation at eight String boundaries;10 affected frozen modules; production LOC unchanged | Keep profile/derivation explicit; do not add a second general backend |

Ratios mean time divided by reference time; lower is better. Native uses
prepared Base while TS loads its own source/state. Cold process clocks include
compiler startup/output and exclude outer authentication, Clang and program
execution. Five calls are not steady state. The [final six-source table and
request arrays](qualified-screen.md) show every case, including Map.

## What changed and what we learned

1. **Consume child results once.** Destructuring `NC_Code` before lowering its
   sibling removes retained projections and unnecessary drops. The isolated
  14-line change improves Map cold/fifth requests19.6%/26.4%, preserving eager
   work, first error, fresh names, segment/call order and complete text.
   [Mechanism and controls](composition.md).
2. **Compose text before materializing it.** Ordered empty/leaf/join nodes replace
   repeated nested body-string concatenation. Flattening happens at existing
   String consumers. The combined candidate cuts Map character append work39.8%,
   allocation calls29.4%, allocated words22.7% and dropped fields44.8%. These are
   operation counts, not peak memory or independently additive speed gains.
   [Body-chunk experiments](body-chunks-feasibility.md), [counters](counts.md).
3. **Separate native and JS costs.** Both ordinary JS builds pass frontend36 and
   all paired C checks, but the combined version regresses Numeric/Lexer/Functions
   requests7–11%. Owned-only also provides no JS gain. Keeping the native
   profile separate avoids shipping that regression. [Ablations](js-integration.md).
4. **Do not infer a leak from repeated slowdown.** All31 stable counters are
   identical on Map calls2–5 while clocks grow; allocations and frees balance at
   completion. More work is not the explanation for those counters. Locality,
   ownership layout and allocator effects need independent tests.
5. **Large self-compilation has a different profile.** The captured first minute
   spends71.2% of physical samples in drop/fade ownership code; about30.4% of
   all samples are cleanup called from shared-string equality and9.4% from
   definition-name projection. Append has only two leaf samples. The capture
   has one timer overrun and is explicitly exploratory, with the strict failed
   status retained. [Self-source investigation](native-self-prefix.md).

The original chunk variant failed its control; the corrected variant passes
114 independent standalone assertions plus nine complete lowering products.
The final narrow equality experiment was rejected by the upstream match-order
rule in less than one second. No checker or ownership rule was weakened, and
no full compiler was rebuilt for that rejected idea.

## Usable compiler and boundaries

Follow the [native usage guide](../../docs/self_hosted/NATIVE_HOST.md) or the
[fast-loop commands](../../selfhost/tools/performance/phase89/README.md).
`phase89/native.py` authenticates the exact source/C/image/build, prepared Base,
nine effect providers and qualification proofs before and after compilation.
It reuses the earlier guarded launcher and atomically publishes successful C.
Python performs supervision and transport; compilation executes in native Bend.

The final upstream-built native B1 is `8bacae268296d6fe16d02ce50a7a2189bd587506c074532c6e5d74e622716e45`,
from Bend source `4584cf08…` and checked C `b1560234…`. It supports args, print,
clock, stderr and the five file providers. File effects retain conservative
optimization permission. Unknown effects/imports, a different image/cache,
altered admission metadata and existing public output paths are refused.
The new image's own45-point gate is separate from the earlier chunk prototype.

Self-emission used600.022s, peaked at1,079,590,912bytes RSS and emitted no C.
This was a deadline, not OOM. Tiny argv, decoder and file-IO execution controls
pass, and the upstream/retained-runtime argv difference is documented, but they
cannot replace the missing full native B1→B2→B3 chain.
[Native B2 feasibility](native-b2-feasibility.md) records those distinctions.

**Installed release bookkeeping:** the16 installed Phase82 artifacts still match
and the ordinary CLI smoke test prints42. Explicit `verify:release` fails on
three compiler-source files committed in Phase88. This was inherited at the
Phase89 start, not introduced here; the verifier and old manifest are unchanged.
See [exact mismatches and history](release-status.md). Current-source release
verification must not be advertised as passing.

## Evidence, cost and next work

[Design](../../design/phase89/bun-and-native-output.md),
[host comparison](engines.md), [runtime choice](../../docs/self_hosted/host-runtimes.md),
[experiment registrations](../../experiments/phase89/),
[guard accounting](resource-account.json).
Root ran targets serially, with three bounded agents preparing/auditing source,
methods and reports offline. No agent ran a competing compiler target. Normal
jobs use CPU3/2GiB RSS/4GiB available-memory floor; full Clang alone uses the
separate6GiB ceiling/16GiB headroom rule. Peak observed RSS was4.30GB in Clang.
The one resource stop was the deliberate600s full-self deadline; no OOM occurred.
461 unique guarded records occupy2,591.2s (43.2min), including447 successful
records and14 retained refusals/failures/stops. Guarded occupancy excludes
reasoning, source audits, network and artifact work;
no quota-usage percentage is claimed.

The immutable [first](evidence01.json), [second](evidence02.json) and
[final delta](evidence03.json) capsules preserve completed and failed attempts,
methods, raw outputs and compiler images. Intermediate duplicate raw products
were deleted only after byte-for-byte archive verification; exact members are
listed in the prune receipts. [Native assets](native-assets.json) select the
minimal restoration dependencies. All12 selected assets verify, and a deliberately
missing native executable was restored with exact bytes, permissions and unchanged
admission ([receipt](restoration.json)). Restore at the recorded canonical paths;
relocation needs separate qualification.

**Next priority:** shared-data observation and repeated name lookup on a tiny
scaling benchmark, before another long self-emission attempt. Distinguish a
borrowed-read lowering experiment from a Bend-source change that the current
upstream-built B1 can actually use. Name equality/projection ownership is a
measured lead; it is not a promised30–40% speedup. Separately reconcile the
current source and installed JS release through the normal checked/self-hosting
workflow. Avoid another output-builder rewrite or a speculative allocator tweak
based solely on the old Map profile.
