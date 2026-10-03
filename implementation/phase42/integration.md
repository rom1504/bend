# Phase42 integration and correctness

The selected image is checked16, API
`63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`.
It is a checked B1 derivative. This campaign does not claim a new self-emitted
fixed point or complete conformance across every upstream backend.

The final integration uses `selfhost/build/phase42/integration03`. Its broad
results are fresh for this exact image:

| Scope | Result |
| --- | --- |
| Main frontend | 3,026 observations; zero differences from pinned upstream |
| Broader frontend | 196 observations; zero differences |
| Backend pilot | 81 matching outcomes: 69 execution passes, four shared check failures, eight not applicable |
| Expanded applications | 154/154 observations pass |
| Phase35 semantic owners | 15 groups pass |
| Phase36 semantic owners | Seven groups pass |
| Phase37 semantic owners | Three groups pass |

The four shared frontend/check failures remain visible. Agreement means the
candidate agrees with the reference on the tested observations; it does not
turn shared failures into successful programs. GPU execution and an independent
proof of language conformance are outside this evidence.

The focused gates check actual emitted code, ordinary exported entry, complete
values, activation, refusal, aliases, order, public descriptor mutation, host
hooks, errors, reentry and deep-stack fallback. They are distinct from the
benchmark's fixed-result observations. In particular, tree checks preserve
30,000-depth behavior; native List/product admission has 43 positive and negative
observations; the unchanged vector gate retains 35 value oracles and five
mutation boundaries. The wrapper gate retains 84 value oracles and two mutation
boundaries, with explicit global diagnostic and lexical ordinary-entry counters.

The late vector admission failure was a compiler regression. A strict native
product equality predicate had inadvertently narrowed the older local-region
comparison policy. Checked16 restores that older policy and keeps the strict
native proof in its own callers. The original failure, five-line repair and
unchanged passing vector gate are retained in [checkpoint07](checkpoint07.md).

Several other failures were in instrumentation or evidence collection. Private
flat graphs introduce lexical worker declarations alongside diagnostic global
workers. Old global-only counters and global-uniqueness assertions could no
longer identify ordinary execution correctly. Versioned successors resolve the
actual scopes while preserving the existing behavioral assertions and adding
scope-specific activation requirements. Runtime provenance is checked against
each role's own frozen attempt. See [integration corrections](integration-corrections.md)
and [failure lessons](failure-lessons.md). Failed receipts are retained.

The raytracer precedence check now compares all five protected generated
definitions exactly, including their private scalar helpers, guards and fallback
bodies. Whole-module identity would be false because of separately qualified
Nat metadata and guarded helper additions elsewhere. The report records those
differences explicitly and retains the original Nat-worker refusal requirements.

Installation and composite evidence collection are pending at the time of this
draft. The final release record and exact closure links will be added after those
gates complete. No prior image's broad pass is transferred to checked16 by label.
