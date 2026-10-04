# Current compiler: Phase44 checked04

Phase44 checked04 is installed. Release verification and all 42 ordinary/relocated
CLI checks pass. The [report](../implementation/phase44/README.md),
[IR guide](../selfhost/docs/JAVASCRIPT_IR.md),
[results](../implementation/phase44/results.md),
[diagnostics](../implementation/phase44/diagnostics.md) and
[portable guide](../selfhost/tools/performance/phase44/README.md) describe the
selected implementation and its measured limits. No PR comment is authorized.
Preserve the 103 unrelated starting files and closed historical evidence.

## What changed

Ordinary runtime expressions pass through typed lowering, lexical facts,
simplification and expression/statement emission. Bounded local alias propagation,
exact identity-binding removal, nine literal U32 folds and lexical statement
emission apply by operation and scope across programs. Fifteen obsolete helpers
are removed. Eight IR modules contain 524 lines; total production source grows
373 lines to 21,813 lines, 2,452 definitions and 78 modules.

The migration is partial: private layouts and deep factories retain `JIRLegacy`,
while guarded call selection retains `JIRCallPlan` and source facts during
printing. There is no general ownership/effect analysis or source-independent
private backend yet. Public descriptor mutation, erasure, parallel scope,
argument order and delayed constructor/matcher demand remain contracts.

Fresh qualification agrees on 3,026 main and 196 broader frontend observations,
plus all 81 backend observations (69 execution passes, eight not applicable,
four shared failures). Eight maintained suites and independent composition
controls pass. Historical Phase43 owner/postinstall campaigns are not new
Phase44 results. This remains a checked B1 derivative.

## Measured outcome

All 45 runtime points / 23 sources / 669 fresh role samples pass. Equal-point
slowdown is **6.1214× → 6.0832× pinned TypeScript time**, an effectively flat
1.0063× gain over freshly sampled Phase43. Equal-source slowdown is 8.3015×;
equal-family slowdown is 8.4340×. Twenty medians improve and 25 regress; two beat
TypeScript. This maintained corpus is not an untouched performance holdout.

All 36 compiler requests agree exactly. Map request time falls 15.61%, while
local-pair, lexer and closures regress 2.81–3.57%. These combined changes do not
isolate planner reuse or establish a general compiler-throughput gain.

[P44-002](phase44/P44-002-known-call-dispatch.md) is rejected: a saved-JavaScript
helper-based known-target experiment changes 1,465 static sites but produces no
broad benefit in its six-point screen. It is excluded from the selected compiler.
The preserved [evidence](../selfhost/tools/performance/phase44/evidence/selected-release.json)
includes failures and the negative result.

## Next architectural work

1. Lower call plans and private adapters into explicit runtime operations. Remove
   the replaced source/text paths as each part migrates; do not add another
   application recognizer or duplicate backend.
2. Establish conservative call-target, effect and escape facts that compose
   across calls, constructors, branches and local closures. Unknown calls and
   mutable public descriptors remain boundaries; arity alone is insufficient.
3. Use those facts to remove executed argument vectors, transient descriptors,
   field projections and redundant guards. Profiles show these remain substantial
   costs in Map and records; BST also spends heavily in its existing worker and
   guards. Each proposed transformation needs its own causal test.
4. Qualify mixed features and public mutation first. Then run the 20/60-second
   portable loop and compiler-cost probes. Require benefits on unrelated sources
   before another full 45-point comparison. Keep builds, timing and profiles
   serial and bounded.

The current ordinary IR creates a shared place for these transformations. Neither
its existence nor fewer wrappers proves a speedup; keep clean measurements and
rejected hypotheses visible.
