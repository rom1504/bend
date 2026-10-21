# What the new evidence changes

Phase122's first hypothesis was correct: preserve an actual comparison through
Boolean representation changes. Its1.2–1.8× planning range became a1.54× focused
predicate result; exposing scaled addresses then brought the combined editdist
speedup to1.69×. The changed-address form was identified in QBE's selector source,
not inferred from instruction count alone. More precise information and target
recognizability were more useful than a larger optimization search.

The RLE state-shell hypothesis gave the lower end of its forecast: roughly1.11–1.16×
changed-source speedup. Both variants remove both shells, and the automatic narrow
layout rule does not activate. Defer that rule. A global type/layout normalizer
would add complexity before demonstrating a sufficiently valuable gain.

The next directions below are hypotheses, not new measured improvements. Gains
are for affected workloads and overlap; none can be multiplied into a corpus forecast.

| Priority | Small decisive experiment | Potential / cost | Stop condition |
|---|---|---|---|
|1|Unify the authenticated P112/P113 callable view and add an explicit local call/resume node. Start with original RLE plus a renamed heap-owning walker; compare terminal bridging alone with local resume.|Phase122's1.2–1.8× on control-heavy families remains an unproved estimate; allow45–90min for an honest prototype,2–4h for general qualification. Actual RLE has two admission barriers, so an8-minute planner patch is inappropriate.|No selected region, ownership/stack ambiguity, or removal of dispatch without useful runtime reduction.|
|2|Preserve consumed tree cells through reconstruction with exact ownership/layout facts, avoiding the rejected generic credit protocol. Trace the two-consumed/three-created Node witness and require BST transfer.|Plausibly1.3–2× on constructor-heavy cases;1h diagnostic then2–4h implementation.51.3% BST take/constructor leaf share gives a2.05× idealized helper-removal ceiling, not a prediction.|Any required assumption about uniqueness/sharing is absent, or constructor traffic remains after the transformation.|
|3|Preserve F32 lanes across calls and backedges, with explicit adapters only at actual escapes. Compare typed ABI only against a persistent typed region.|Ambitious1.5–3× on active ray-like cases;45–90min diagnostic,3–6h general work. Mature C is itself3.41× upstream on active ray, so matching its representation alone cannot establish parity.|NaN/signed-zero/rounding mismatch, larger hot frame, or more copies without measured gain.|
|4|Finish the compact editdist loop only if a cheap exact experiment explains the remaining gap: Boolean cost materialization and loop-carried address-state pressure.|The current1.26× upstream ratio bounds the simple parity opportunity to about21% remaining time in that case.30–45min bounded trial; aggregate impact is small.|Static shrink without runtime improvement, or another expensive global fact pass.|

The first experiment should reuse the exact full-word argument snapshots,
original continuation captures and explicit stack. Complete workers and legacy
ready workers have distinct symbols/contracts; a shared view must preserve those
contracts rather than treating every reflected function record as callable proof.
The [offline audit](../../selfhost/tools/performance/phase123/ready-call/audit.md)
contains the concrete interface and refusal gates.

Do not spend another broad campaign on every microchange. Use checked-hosted API
acquisition, finite law-like controls, one or two frozen products and independently
verified outputs. After a stable candidate transfers, perform one original45 gate.
Native compiler acquisition follows only a separately justified integration
checkpoint with enough disk; it is not necessary to measure a generated-program
kernel. Improving research throughput is useful, but this cycle does not demonstrate
recursive self-improvement or native compiler-throughput gains.
