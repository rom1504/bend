# Phase118 first checkpoint — ownership survives into QBE

Research started2026-10-21 09:47UTC; this is an interim checkpoint, not the
completed three-hour phase. Parent is Phase117 `c6a0564`; installed selections
and the Phase114 native-qualified compiler remain unchanged.

The first combined source is checked Bend, SHA
`c27f33103b97971fee08e2706459582b78ff50fb8960985d8b2f780a792f61e3`.
It combines four general transformations, with no benchmark-name decisions:

1. Constant-size constructor/Take calls preserve checks while exposing literal
   field counts to the cached runtime compiler.
2. Structured tail recursion modulo a final constructor removes reconstruction
   continuations through private destination passing. This version still allocates.
3. Root-preserving borrowed observers reuse the mature checked NO analysis and
   independently check the new direct workers' machine structure.
4. Whole-program sharing facts preserve cold constructor metadata. The runtime
   avoids sealing fields of certified cold parents, including deferred TRMC tails.

The important correction is that an RFC wrapper does **not** prove actual
sharing: eagerly sealed uniquely owned children can have count-one wrappers.
The QBE route was generating that work after discarding information already used
by the C backend. Cold metadata removes wrapper allocation/indirection/release;
it does not permit treating a genuinely shared node as unique.

## Focused results, not the original45 aggregate

Original sources, arguments, full-output oracle and50ms upstream repetition
profile; three rotated serial CPU3 rounds. Median elapsed milliseconds:

| Program | Phase117 | Combined | Upstream C | Speedup over Phase117 |
|---|---:|---:|---:|---:|
| list128 |291|197|50|1.477×|
| map128 |433|209|50|2.072×|
| tree-bitonic |332|265|50|1.253×|
| lexer |339|250|47|1.356×|

All36 observations pass. Receipt:
`selfhost/build/phase118/combined-screen01/report.json`.
Separate ablations retain sized-call, runtime-only, borrowing, cold-metadata and
destination-only results. Do not multiply their independently measured gains.
Cold-only lexer regresses about2.7%; the combined lexer result improves.

The ordinary deep/shared construction, nonfinal/multiple/mutual recursion
fallback, mixed-arity destination and duplicated-result controls pass
(`combined-controls-run01`). Transitive-container sharing, generic constructor
instantiations and root-preserving observers also pass (`cold-controls-run01`).
One newly authored observer fixture initially used unsupported computed-value
destructuring; its corrected helper preserves the independent literal oracle.
All failed source/API preparations and the original fixture remain retained.

## Boundaries and next experiments

The diagnostic API rechecks and rederives too much. A request-bound Bend entry
now checks successfully and is being tested for byte-exact equivalence. It
reuses analyses within one authenticated request; it is not a cross-request cache.
Consumed-cell reuse is a separately checked prototype, not included in the table.
The original generic IR verifier remains unchanged; direct destination helpers
have explicit additive contracts. Structural verification is not an ownership
proof, and the hot metadata requires checked-source provenance.

No full45 result, native compiler throughput gain, N1/N2 qualification or
recursive-research acceleration is claimed at this checkpoint. Those require
their own measurements. Exact duplicate coalescing has recovered about2.69GB
across three receipts while preserving every frozen path, byte and mode.
