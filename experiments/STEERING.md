# Current compiler: Phase45 worker23

The [Phase46 JS/C investigation](../implementation/phase46/README.md) is complete
without changing this release. Six common batch workloads pass72 timing samples;
our C is1.28–5.03× slower than our JS on five and roughly tied on closures.
Upstream C is faster, but our allocation/continuation transport defeats that
potential. Keep JS primary and prioritize shared ownership/use/effect facts;
the next cheap consumer is proven-private array-view hoisting. Known-call and
aggregate elimination remain especially important for native lowering.
Native IO.args omits the program name; its reproduced mismatch remains unfixed.
The new batch ratios do not replace the45-point JS-library score below.

Worker23 is installed. Release verification and all 42 ordinary/relocated CLI
checks pass. The [report](../implementation/phase45/README.md),
[IR guide](../selfhost/docs/JAVASCRIPT_IR.md),
[results](../implementation/phase45/results.md),
[compiler costs](../implementation/phase45/compiler-cost.md) and
[portable guide](../selfhost/tools/performance/phase45/README.md) describe the
selected implementation. Preserve the 103 unrelated starting files and closed
historical evidence. No PR comment is authorized.

## Selected mechanisms

A typed private worker IR complements the ordinary runtime IR. Whole first-order
graph proofs support explicit calls, branches, projections and returns; exact
recursive components keep emitted functions small. Native recursion uses a shared
32-call budget and a continuation machine at exhaustion. Tail calls use loops;
components containing only tail recursion omit the unused machine. Named private
fields, native constructors, immutable String results and exact Number Nats remove
substantial allocation and dispatch overhead. Public scalar boundaries retain
BigInt where required. Unknown, effectful, escaping or unproved graphs fall back.

Typed root ranking preserves stronger existing plans. Acyclic public aliases stay
on the old path after two measured regressions; private acyclic helpers remain
eligible. A complete conservative source scan limits primitive fences to actually
used operations under the existing standard-at-initialization host contract.
Nullary entry preserves demand and public function metadata. Canonical Unit
extends private Map coverage. Runtime entry bookkeeping captures intrinsics to
repair six reproduced post-import hook observations; it does not prove universal
host equivalence. The inherited dynamic exactCodes.add hook remains a separately
documented, unexecuted audit proposal.

This is not one fully unified backend: historical specialized paths and opaque
compatibility adapters remain. The manifest lists 23,007 physical / 18,983 code
Bend lines, 2,594 definitions, 87 types and 85 modules. Physical source grows 1,194
lines (5.47%) over Phase44; no line-count simplification gain is claimed.

## Qualification and measured outcome

Fresh qualification agrees exactly on 3,026 main and 196 broader frontend
observations, including four existing shared main failures. All 81 backend
observations agree: 69 execution passes, eight not applicable and four shared
failures. Eight maintained suites, mixed composition, seven freshly acquired
mechanism families/twelve controls and separate nullary/Unit/host-hook controls
pass. The standalone Number-Nat diagnostic probe still fails strict comparison
on two parse-diagnostic differences; it receives no passing qualification credit.
This remains a checked B1 derivative, not a newly self-emitted fixed point.

All 45 runtime points / 23 sources / 669 fresh role samples pass. Equal-point
slowdown falls **6.0867× → 3.0787× pinned TypeScript time**, a **1.9771× gain**.
Equal-source slowdown falls 8.2713× → 4.1467×; equal-family 8.4316× → 4.7340×.
Thirty-two medians improve and 13 regress (largest observed regression 4.93%);
two points beat TypeScript. Records improve 41–43× and Map 128 improves 15× over
Phase44. This maintained corpus informed optimization; it is not an untouched
holdout and does not establish universal program speed or parity.

All 36 checked compiler-cost requests agree, but all four request medians increase:
local-pair 8.62%, lexer 28.55%, Map 1.32%, closures 1.20%. Faster generated execution
has a compilation-cost tradeoff. Twelve selected CPU/allocation profiles and
three-role generated-JavaScript analyses are separate from clean timing.
The promoted portable bundle passes 27 fresh smoke samples in 10.21 seconds.

Worker23 API is e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c;
runtime is 4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26.
Worker22 shares the API but not the runtime: require both identities and the
exact checked attempt. Rejected 17b is retained separately, including its stopped
long run and original portable bundle. The raw campaign is closed: all 55,014 files are preserved in a verified
173,957,843-byte capsule published as five parts. All 103 protected files remain
unchanged and unstaged. Both native String.eq experiments remain uninstalled;
they do not change the selected runtime result.

## Next investigations

1. Retain the [native String.eq experiments](phase45/P45-025-string-equality-number-nat.md)
   as unselected prototypes. Admission plus Number-Nat compatibility improves
   Map/Set 1.378× in a five-round comparison, with remaining drift and 56.4%
   more emitted JavaScript. Number-Nat alone has no useful short-screen gain.
   Revisit shared private components and proof facts before promoting this
   narrow benefit through another complete qualification campaign.
2. Extend shared call-target and escape facts for private function values and
   closures. Morning and other higher-order graphs remain important gaps. Keep
   mutable public descriptors and public results as explicit boundaries.
3. Investigate typed Array/effect transport and public result adapters separately;
   unsupported coverage explains some large residuals, but is not a measured gain
   estimate. Do not add source-name recognizers to the backend.
4. Use fresh profiles to prioritize residual private allocation, guards and host
   string operations. Short public calls need a distinct profitability model;
   scalar-zero overhead is not evidence about long-running arithmetic.
5. Investigate shared per-definition/SCC proof facts to contain compiler cost and
   consolidate overlapping backend paths. Source growth and the four measured
   compile regressions remain explicit costs. Validate each causal hypothesis
   before another whole-corpus campaign.

Root serializes builds, target execution and profiles on one CPU with a 1 GiB
Node heap, 2 GiB process-tree RSS limit and memory floor. Agents may prepare code,
independent fixtures, reviews and data-only reports in parallel. Run the five
canaries before feature screens; preserve failures and reuse only evidence with
explicit unchanged-byte/provenance proofs.
