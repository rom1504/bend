# Direct backend graph scaling audit

This is a read-only source audit of the selected Phase52 direct06 architecture,
before Phase53 changes. No compiler or generated program was executed. The
current bounds are a material acceptance limit for large programs; they are not
runtime iteration limits or evidence that small admitted programs are wrong.

Making direct JavaScript the default is reasonable for the qualified domain if
the explicit legacy option remains available and refusal diagnostics explain
that option. It does not establish support for compiler-sized direct emission.
There should be no automatic fallback: a library would otherwise silently change
its public calling and data contract.

## What the limit actually counts

The [driver](../../selfhost/tools/typed-driver.mjs) first checks the full source,
selects a conservative dependency closure, and annotates that closure. It then
calls [jd_reach_selected](../../selfhost/src/back/js/direct/reach.bend), which
builds tail-call facts **before** pruning exact emitted dependencies.

[jd_calls_rows](../../selfhost/src/back/js/direct/calls.bend) allows 512 eligible
runtime definitions: non-template `Def` entries with a body or known native
implementation. Types and constructors do not consume this counter. Base/native
definitions retained in the conservative closure do consume it. A 513th eligible
definition rejects the plan even if some would disappear after dead-let,
erased-argument or intrinsic lowering. Thus “512 selected emitted definitions”
in the existing guide understates the conservative pre-pruning restriction.

Programs root `main`; library mode roots every eligible non-Base, non-foreign,
non-IO definition. A large library therefore encounters the bound even when its
individual exported functions are small. A small `main` can also encounter it
through its dependency closure. Check-only mode returns before backend analysis.

The subsequent exact-reach traversal separately permits 512 visited definitions,
65,536 queued names and 2,097,152 scanned output characters per definition. The
tail scan permits 8192 visited nodes per definition and a 64-slot field telescope.
These are distinct bounds: increasing only the first 512 does not remove the
others or improve the algorithm.

## What current evidence covers

The [Phase52 full comparison](../phase52/results.md) qualifies 45 points from
23 sources. A static count of the saved, hash-verified direct06 modules finds
6–103 top-level generated `$jd$` functions per module. There are 24 module files
because the generic-row observation adapter is separate; the maximum is MapSet,
followed by Evening at 97. These are **post-pruning emitted-function counts**, not
measurements of the initial eligible graph. They show that the benchmark corpus
does not exercise the 512-definition boundary.

The compiler itself has [2957 source definitions in 101 modules](../phase52/accounting.md).
That source count is not an exact runtime closure count for a restricted compiler
API. Nevertheless, unrestricted library emission of the assembled compiler is
well outside the current intended scale. No direct self-emission or fixed-point
result exists. The successful checked compiler builds use the established
bootstrap/development workflow; changing the ordinary output default does not
retroactively make those builds direct self-compilation.

This audit found no additional semantic failure for the already admitted graph
domain. It did identify the earlier-than-advertised refusal above. Source reading
cannot establish how often ordinary projects exceed the bound; no such prevalence
measurement was performed. The default switch should describe this as an explicit
large-program regression relative to an uncapped legacy path, not dismiss it as
merely a documentation detail.

## Present cost

Let `V` be eligible definitions, `E` the recorded tail-edge occurrences and `T`
the visited typed tail syntax. The scanner processes source tails once. It then
runs graph reachability independently from **every** definition and retains every
closure, including an indexed membership set. SCC membership is determined by
checking both reachability directions for every pair of definitions.

Ignoring type normalization, name hashing and map representation constants, the
graph work is `O(T + V(V + E))` time and `O(V² + E)` worst-case retained data.
The separate member scan is `O(V²)`, and bounce discovery scans reachable names
again. The existing persistent 32-bit name index makes individual lookups bounded
by trie depth plus collision work; it does not make all-pairs reachability linear.

Further costs remain outside that graph bound:

- The selected context is overlaid with `book_put`; replacing existing names
  filters declaration lists. That can add quadratic list work independently of
  SCC analysis.
- Exact reachability emits bodies to discover `JD_REF` metadata, then final
  emission builds facts and emits again. This preserves real demand pruning but
  repeats work.
- Each entry into a mutual-tail component emits the component body, matching
  the pinned implementation's strategy. A component with `k` members and total
  body size `B` can contribute `O(kB)` generated text and repeated scan work.

Raising 512 to a few thousand without measuring these costs risks replacing a
clean refusal with high memory use or long compilation. It is not the recommended
first fix.

## Smallest scalable follow-on

Keep the existing typed tail scanner, emitted numeric row plans and public fact
queries. Replace only the all-pairs graph closure:

1. Assign stable dense IDs in selected-definition order; build forward and
   reverse adjacency once. Validate targets before graph analysis.
2. Compute SCCs with an explicit-stack Tarjan traversal, or two iterative DFS
   passes over the forward/reverse graph. Reuse the existing indexed maps if that
   is simpler in Bend; do not assume list indexing is constant time. With bounded
   map operations this uses `O(V + E)` graph visits and storage. Pinned upstream's
   `loop_of` already uses Tarjan-style SCC discovery; its `stack.indexOf` is not
   itself a strict constant-time membership implementation to copy blindly.
3. Build each ordered member list once. A second pass through the original
   definition order gives stable component IDs/member positions without changing
   generated transfer order or requiring all-pairs queries.
4. Mark unknown-tail-call seed definitions, then walk **reverse** edges once to
   compute all possible bouncers. Do not mark every cycle as bouncing: native SCC
   transfers already loop, while unknown closure tails retain selective forcing.
5. Install compact facts: component identity, member position and may-bounce bit.
   Store component lists once and reference them, rather than retaining every
   transitive closure. Preserve explicit invalid-target/budget refusal.

This is a replacement for existing analysis, not another optimizer. Its graph
result can be compared with the current implementation on small inputs before
changing generated behavior. After it survives, replace the fixed vertex cap
with separately accounted node/edge/work budgets suitable for larger inputs.

Keep exact emitted reachability for this first change. Replacing `JD_REF` scans
with a structured `{code, references}` result may save another emission, but
requires references to follow dead-let, erasure, row pruning and constructor
folding exactly. A conservative source-reference walk would reintroduce the
already-fixed dead-foreign-initializer bug. That work should be a separate step.

## Qualification order

First compare old/new graph facts and output on small acyclic, self-recursive,
mutual and unknown-closure-tail cases. Include missing erased formals, differing
live arities, parallel argument transfers, captured closures, dead foreign lets
and native numeric row pruning. Preserve deterministic component ordering.

Then use independently generated checked sources at 128, 512, 513, 1024 and
compiler-scale definitions: chains, broad DAGs, disconnected library roots,
duplicate edges and one large SCC. Include a conservative closure exceeding512
whose exact emitted closure is small. Record analysis time, whole request time,
peak RSS, output bytes and refusal phase separately. No timing target is claimed
here; the graph complexity improvement is a source-level expectation.

Only after those gates should a restricted compiler API and then full direct
self-emission be attempted under the existing memory supervisor. Large mutually
recursive code size, host-marshalling type-work budgets and the driver's compiler
ABI adapter may still block that milestone after SCC scaling is fixed. A fixed
point and compiler-request throughput are separate qualifications from generated
program speed.
