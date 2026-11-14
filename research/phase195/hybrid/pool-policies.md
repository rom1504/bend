# Register-pool profitability variants

The measured machine-code mechanism is specific: spilling canonical state adds
12, 28 and19 repeated frame loads in the inspected ray-nearest, tree-warp and
lexer-gen components, respectively. Edit's actual loop adds none. The new
variants change color construction only; they preserve all eleven-color
legality checks and the forced-R12 machine controls.

Use exactly one mechanically assembled allocator module with the unchanged
physical hooks. The usual seven original declarations are replaced; no newly
introduced helper is passed as a source-parent replacement:

- `allocator-rcx-v3.bend` constructs colors0..9 in eleven group slots. Color10
  remains legal for forced controls but is not chosen. Setting
  `x195_pc_r12_enabled()` to True restores eleven-color construction.
- `allocator-adaptive-v3.bend` first constructs eleven colors. When color10 is
  unused, it immediately retains that result. Otherwise it constructs ten
  colors and compares estimated costs. Setting `x195_ap_enabled()` to False
  bypasses the extra recoloring/cost walks and restores the original pool.

`assemble-policy.py` generated both from frozen allocator-v2, common color
helpers and a policy file. Adjacent `.inputs.json` receipts pin every input,
the assembly method and the output. Do not append the source helper files again
when preparing these flattened modules. Earlier allocator versions remain
unchanged.

## Adaptive count model

The gain mask contains names homed by eleven colors but spilled by ten; the
loss mask contains the opposite. Counting only the names placed directly in
R12 would miss indirect register reassignment, so the comparison uses both
complete assignments. Reads and writes of these masks estimate frame accesses
removed and introduced. All state reads/writes estimate the extra cost of its
new canonical Stack home, including the incoming state store.

The structured cost walker uses the original x191 reaches/falls equations:
paths leading to Again have weight8, setup and exit-only paths have weight1.
Both branch arms are included. Parameters count their incoming writes once.
Again's nonidentity transports count source reads and parameter writes;
identity transports count zero. Real product calls add their implicit state
argument; scalar calls use explicit arguments. Inline F32 uses its existing
buffer/destination effect contract, so its syntactic state argument is not
mistaken for an executed state load. Sums and multiplication saturate.

Eleven colors are chosen only when estimated gain is strictly greater than
estimated loss plus state cost. Ties choose ten colors. There are no benchmark
names, symbols or case-specific thresholds. This is an interpretable syntactic
estimate, not exact machine-access accounting: selected-away operations and
unreachable branches can still affect profitability. The unchanged independent
checker and state-slot transaction authorize the chosen result.

Thirteen additional `p195ap_controls` rows test construction limits, strict
margin, saturation, loop/setup/branch weights, identity transport, implicit
state calls, inline F32 and imports. Original structural and independent machine
observers remain applicable. Source/ownership audits were performed while
authoring; root owns checked acquisition and all target execution.

## Compiler overhead

RCX-only construction keeps the same candidate graph and greedy-color bound.
Adaptive construction adds one greedy32-node recoloring and a linear structured
cost walk only in functions whose eleven-color construction actually uses R12.
It adds no fixed-point or interference-graph solve. The original pool's bounded
shift-liveness walk remains unchanged.

Measured incremental compiler overhead is pending root emission reports.
`pool-dev-emit01/report.json` supplies the original pool's per-case
`prepareSeconds`, `selectSeconds`, `renderSeconds` and `objectSeconds`; matching
RCX/adaptive reports can supply like-stage acquisition comparisons with the same
input sources. These sequential hosted acquisitions are diagnostic observations,
not randomized compiler-speed confidence intervals or native cold-build gains.
No target or timing job was run by this agent.
