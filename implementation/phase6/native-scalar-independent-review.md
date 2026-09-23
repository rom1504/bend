# Independent native scalar review

Root reviewed the P6-005 source patch and native lowering dependency chain on
2026-09-23. The isolated change is suitable for integration after its owner
freezes the remaining focused execution evidence.

`nc_compact` is the sole source of internal `NWord` nodes in this path. It creates
them only for recognized literal scalar constructors. Existing lowering already
returns the identical `name + "ull"` word without allocation, evaluation or an
ownership action. Retaining that literal directly in `NCtr` fields therefore
removes only a continuation and its temporary binding. The sequence counter still
advances for every field, preserving IDs for later nonliteral fields. All other
fields retain their existing `nc_mklet` path. The optimization excludes `NCall`,
so it does not reorder argument evaluation or generalize tail-jump behavior.

`nc_values` now accepts the internal literal in addition to its existing variable
form; its nonliteral branch remains unchanged. This is deliberately narrower than
skipping arbitrary constructor expressions. Dynamic scalar expressions, overflow
and boxed values retain their evaluation paths. Compiler and generated-program
performance remain separate: the measured 95.31% C size reduction is established,
but a controlled wall-time improvement has not yet been measured.

The owner reports checked build/default21 gates, actual paired JS/native outputs,
255 acceptance and 256 rejection, worker-count replay and unused-field overflow
gates. This review reads their design and patch; it does not describe those
executions as independently rerun. Final integration needs affected backend gates.
