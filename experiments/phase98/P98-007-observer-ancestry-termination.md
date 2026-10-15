# P98-007: terminate observer ancestry refusal

Status: minimal fix source-admitted; full native qualification pending.

The broader observer permission exposed a pre-existing refusal-path bug.
`noa_below(origin,want)` used eager Bool `&&` to combine an `OField` tag test with
recursive descent. When two origins differ and the first is not an `OField`,
the runtime still evaluates `noa_below(kid(origin,0),want)`. Missing children
produce `Absent`, whose missing child is again `Absent`: recursion never ends.

The complete59b36a1c self requests hit2GiB at83s and4GiB at101s. Controlled
75s/90s prefix captures use the existing watchdog and unchanged ownership sampler,
ending intentionally with77. They are incomplete compilations, never correctness
passes. The90s capture has5,626 samples and2.57GiB peak RSS. In75–90s, structural
comparison, field projections and their cleanup replace the earlier membership
work; physical `NOA_BELOW` callers are visible. Generated C independently confirms
that recursion precedes the tag test, retaining continuations on every iteration.

Replace the conjunction with a deferred `nt_choose`: recurse only for `OField`,
otherwise return `False`. This adds one line and38 bytes to59b36a1c. The source is
`selfhost/build/phase98/origin-guard-source01/compiler.bend`, SHA
2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051.
Its full upstream acquisition passes with no holes in34.33 seconds. No schema
cache or worker-redirect optimization is bundled into this candidate.

This changes a previously nonterminating operational path; do not describe it as
unconditional equivalence to the old executable. Source equations alone may not
establish the strict native evaluation/termination property. Qualify the concrete
nonmatching-origin helper and a valid two-root swapping program, then full native
self-emission, B1/B2 agreement and the unchanged independent semantic oracles.

Evidence and source/C mapping:
`selfhost/tools/performance/phase98/comparison/ownership-prefix-attribution02.json`.
The cache/redirect alternatives from P98-006 remain separately preserved; their
passing value controls do not make them a fix for this nontermination.
