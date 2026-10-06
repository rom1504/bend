# Current compiler: Phase54 graph02

**Graph02 is installed and verified.** Direct JavaScript remains the default for
program/library emission and compiled runs. Legacy descriptor output and native
C remain supported. The user authorized backend cleanup after the Phase53 change.
[Design](../design/phase54/backend-cleanup-and-direct-bootstrap.md),
[report](../implementation/phase54/README.md),
[backend boundaries](../docs/self_hosted/backend-boundaries.md),
[publication](../selfhost/tools/performance/phase54/publication.json).
No PR comments are authorized.

Selected checked attempt: `selfhost/build/phase54/checked-graph02`.
API: `d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`.
Source: `32cddcf1a970a9726a9785b30269cdd8a0047f917f769a964995fa6a0633de84`.
Direct runtime: `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.
Legacy runtime: `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Upstream pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.

## Retained behavior and measured scope

Source 96, numeric 34, composition 18, overapplication 2, direct census 26 and eight
maintained compatibility suites pass. Three native representatives retain exact
C bytes and pass six CPU executions. Installed release passes 42 legacy + 24 default
checks, integrity, relocation and tamper restoration. Counts overlap. The prior
Phase53 release's seven history files remain exact. No new fixed point or broad
native/GPU/proof claim follows.

All 45 benchmark point modules from 23 checked sources are byte-identical to
Phase53. Its **dated** 669-sample result, 1.069599× TypeScript equal-point time and
1.078076× equal-source, is retained for those exact bytes; Phase54 did not rerun
runtime timing or establish compiler-throughput parity. See Phase53's
[results](../implementation/phase53/results.md) for regressions and timing flags.

## Implemented cleanup

34 helpers moved without body changes: 27 shared semantic queries and 7 JS text
helpers. Two maintained compiler-image commands explicitly select legacy.
Direct no longer obtains those helpers from legacy-emitter modules. All 17 native
modules, both runtimes and the host driver remain unchanged. Preserve the shared
checked/specialized/annotated core, erasure, ownership/effects and numeric facts
for future targets; do not introduce an unused universal IR.

Call analysis now uses iterative forward/reverse traversal, source-order SCC
members and reverse unknown-tail propagation. Graph visits/storage are linear;
index and source-scanning costs remain separate. The shared definition budget is
4,096. Fifteen fact cases, ten exact-budget controls, five checked source chains
through 3,004 functions and their 15 output observations pass. Default graph-entry
refusal at 4,097 also passes; this is not a 4,097-source compilation. New total-edge
admission changes the old refusal policy explicitly.

Source: 26,259 physical / 21,598 code lines, 3,015 definitions, 100 types, 107 modules.
Delta: +108 physical / +75 code (+0.35%), with 95 original modules exact. This is a
dependency/algorithm improvement, not a line-count reduction. Legacy modules
remain required by real compiler-image/private-transform clients.

## Next bounded investigation, not yet implemented

Restricted direct compiler-image transport passes 11-root ABI/data controls,
including a 20,000-node frozen list. Full 77-root generation times out at 240s below
864 MB RSS. A 90s diagnostic completes emitted reachability in 55.9s, then enters
library emission. No complete full image, fresh self-check or fixed point exists.

The sampled V8 profile identifies whole-book constructor lookup during arity
recovery: j_find_ctor 26.5% of sampled ticks; missing 11.2%, mostly beneath that
search; 80.3% of j_find_ctor samples beneath jd_raise_head. Top-level book lookup
cannot replace constructor lookup: constructors live in owner dc lists. First
try known normalized ADT-owner lookup, threading the telescope where required.
Otherwise test an indexed constructor context with precedence/invalidation
controls. Record exact emitted bytes and end-to-end request cost before promotion.
Do not start by changing SCC body dispatch or deleting the working bootstrap.

## Workflow and preservation

Use small checked builds/falsifiers before broad gates; skip runtime timing when
executable bytes are exact. Use explicit Node selection for acquisition and the
retained Clang 16 environment for native checks. Sandbox Clang EPERM needs an
unchanged authorized environment retry, not compiler edits or oracle changes.
Keep failed attempts and consumed producers immutable. Detailed Phase54 raw paths
resolve within its single closed archive. Preserve all 103 inherited unrelated
files. Heavy targets stay serial on CPU3, with 1 GiB heap, 2 GiB RSS and a 4 GiB available-memory floor;
root controls target ownership, installation and publication.
