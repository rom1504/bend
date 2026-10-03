# Phase41 installed: guarded acyclic wrappers

Authorization covers compiler work, design/report and commit/push to
`rom1504/bend`, branch `selfhost/bootstrap`. No PR comment without an explicit
new request. All 103 unrelated starting files and old closed evidence remain
unchanged. No persistent Goal is active.

## Current release and measured scope

Phase41 checked01 is installed. Release verification, all 42 ordinary/relocated
CLI checks and 15 final audit groups pass; all 227 canonical sources match.
API `9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`.
Pin `018751270e800bc222a93dad7f257083ee53a5f7` is unchanged. This is a checked
B1 derivative, not a new self-emitted fixed point. Phase40 remains in history.

[Report](../implementation/phase41/README.md) ·
[Admission](../implementation/phase41/performance-admission.md) ·
[Integration](../implementation/phase41/integration.md) ·
[Profiles](../implementation/phase41/profile-findings.md) ·
[Portable loop](../selfhost/tools/performance/phase41/README.md)

Three tree points improve 1.506–1.592× over fresh Phase40 comparisons, all five
pairs faster with disjoint ranges. Remaining TS gaps are 9.33–12.18×. The other
42/45 module outputs are byte-identical; three unchanged controls were retimed.
Do not call this a fresh 45-point timing or typical-program result. Raw within-
process drift remains explicit. Sampled allocation per tree call falls ~23.5%;
this is not exact object counting. Generic apply remains visible but smaller.

All 36 normal checked requests reproduce expected bytes. Tree compilation costs
9.46% more (about 213 ms) in median, slower in all three pairs. This is an
explicit admitted cost tradeoff, not neutral cost or compiler throughput gain.
Source grows 35 physical lines / four definitions to 18,898 lines / 2,108 defs;
70 modules, 71 types, 640 laws and runtime bytes remain unchanged.

## Retained decisions

The narrow nonrecursive ADT-first wrapper admission reuses the full typed graph,
no-backedge proof, dependency guards and existing structural workers. It keeps
fallbacks, aliases, fresh tagged intermediates, evaluation order and deep-stack
behavior. It adds no runtime or IR. Scalar/Nat/List wrapper admission is unchanged.

Private transfer tuple scalarization was rejected: corrected controls pass, but
0.23–0.40% shifts are smaller than noise. Lexer String admission was deferred
because native hooks bypass the numeric-host guard. Preserve all failed tools,
fixture oracles and host counterexamples; no unproved lexer change is installed.

## Next experiments, ranked

1. Profile a normal tree compilation request to locate repeated planner graph
   work. Test query-local fact reuse with exact source/definition identity before
   persistent caching. Reverse the measured compilation increase if practical.
2. Use the fresh tree profile to distinguish invokeExact/warp_leaf dispatch from
   intrinsic tree allocation. Test one exact saved-output ablation, complete
   values and hostile boundaries, before a checked source change.
3. Extend to String/Char/Sigma only with complete native hook, Unicode and
   demand/error-order obligations. The old ~2× lexer prototype is not installed.
4. Consolidate stable semantic owners when it can remove work without weakening
   assertions or provenance. Avoid another renamed phase-specific framework.

The fast-five portable run takes 17 s; actual checked build through first screen
was 3m23s. Root serializes heavy jobs under memory/deadline bounds. The two-worker
frontend produced the same 3222 observations in 7m17s versus a historical13m42s;
that is not a same-image worker A/B. Reuse 20/60/300/600-second presets. Run broad
semantic gates once after freezing a survivor. The closed campaign raw phase
lasted78m16s, with34m03s recorded process intervals; residual time is unclassified,
not measured model latency. See [accounting](../implementation/phase41/accounting.md).

## Correctness and preservation

Frontend retains 3026 main +196 broader exact agreements, including four shared
main failures. Backend pilot retains69 pass /8 not applicable /4 shared failures.
Expanded154 observations, inherited owners and new wrapper/deep/mutation controls
pass; counts overlap. Full backend/GPU and independent proof validity remain
unestablished. Closed evidence preserves every Phase41 attempt, including failures.
No PR comment was posted.
