# Phase195 ray: consume the existing certified table capability first

The current ray gap has a measured representation cause larger than another local float move: four constant selectors remain ordinary calls in x86, while QBE lowers them to table loads. The qualified Phase194 active-ray64/2440 image takes281.928µs per invocation in the fresh profile's clean observation, versus109.284µs C and103.513µs QBE. Physical samples assign64.214µs/invocation (22.78%) to sx/sy/sz/sr themselves. This excludes their call setup, caller spills, reloads and optimization barriers in nearest/trace.

The profile agent reports641 admitted pooled samples, zero unknown/lost samples. Its exact-PC analysis lives in `research/phase195/profiles`. These are descriptive sampled CPU allocations, not a causal instruction-cost decomposition. All machine inputs for this audit are pinned in [ray-baseline-machine.json](ray-baseline-machine.json).

## Actual obstruction

Qualified x86 `direct.nearest.t` calls sx,sy,sz,sr at0x40b2a0,0x40b2b4,0x40b2c8,0x40b2dc, then reloads their results for the quadratic. Each selector is69 static instructions, has eight equality tests and reserves2288 bytes; the stack reservation is not a claim that2288 bytes are touched. QBE's same region uses four clamped indexed loads from `p126s_table_*`, without those calls. The tables have nine entries and a default-last rule.

| Recurrent physical function | x86 instructions / explicit stack operands | QBE instructions / explicit stack operands |
|---|---:|---:|
| direct.nearest.t |594 /128|262 /22|
| product.nearest |767 /201|315 /49|
| product.trace |1978 /690|497 /76|
| direct.pixel |1594 /456|353 /50|

These static totals contain alternate paths and are not dynamic execution counts. Profile shares put product.nearest at38.30%, direct.nearest.t13.32%, product.trace10.55%; those caller shares cannot be added wholesale to the removable table cost.

Other losses remain: FloatNodes bypass richer integer branch selection; F32 values cross ordinary-operation/backedge boundaries; rt_op accounts for29.289µs (10.39%). Sampled runtime PCs include actual SQRTSS arithmetic and its shared result path, so calling all of that dispatch overhead would be wrong. The observed nearest opcodes include36(sqrt) and25. Table capability is prioritized because its canonical certificate already exists, it removes four recurring calls and their allocator barriers, and its arithmetic semantics are solely unsigned indexing and exact raw-word loads. Loop-carried F32 placement and sqrt are deferred until this is priced.

## Experimental candidate

`selfhost/tests/phase195/float/table-calls.bend` consumes the original `P134Context.lookups` catalogue, which the frontend derives with `p126i_catalogue`. It reuses `p126s_cells` and `p126s_data`: exact total decision trees with4–64 zero-extended U32 entries, including arbitrary F32 bit patterns. No new source evaluator, float folding, reassociation, or heuristic function naming is introduced.

`table-hook.bend` overrides only `x181_program_private`. In mode2 with the off switch enabled, single-result/single-argument calls to certified tables become unsigned clamp + address + U64 load before all existing allocation/selection. Table bytes are emitted once alongside the original private function. Original function entries and public forwarders remain. Ordinary calls and all effects retain their original order.

Four temporary names are reused sequentially. A complete parameter/local read/write prefix audit rejects collisions; functions at least4096 rows are unchanged. Input operands are read before publishing the destination, including destination==input. U64 comparisons preserve high input bits; indices outside the range use the last element. Canonical data is validated against catalogue length before emission. Output refusal remains whole-output failure. This transport operates below the unchanged frontend admission boundary; a fabricated P134Context is not independently a proof.

The data is compiler-owned constant table storage emitted through the existing typed table interface. No new load/store or call ABI is added. Since the transform performs no FP operation, NaNs, negative zero and arbitrary raw words are copied bit-exactly, and MXCSR should be unchanged.

## Cheap falsifier and honest ceiling

First run the17 structural controls and2080 independent machine observations per direct/rendered route. Then emit active-ray64, numeric and a nonnumeric control. The causal witness is removal of all four selector calls from recurrent nearest/trace code, with table loads present and caller allocation seeing no such calls. Count new loads/branches, stack traffic, spills and table bytes. Reject if only the table helper body changes while hot calls persist, or if the hook loses other selected renderer capabilities.

Then use balanced paired whole-program timing and compiler-request cost. Removing100% of the measured selector leaf time alone would be an unrealistically favorable22.78% ray reduction, about1.295× speedup; real table loads still cost time. Caller savings could exceed that leaf-only estimate, so it is not a complete transformation ceiling. Even a30% reduction confined to all three ray-family cases would improve a44-case equal-case geometric mean only about2.4%. Broad parity requires other mechanisms/workloads; no suite gain is claimed before measurement.

No compiler, target or timing job was run by this author. C observer syntax and source-local ordering/delimiter audits passed; root-owned checked API and machine gates remain required.
