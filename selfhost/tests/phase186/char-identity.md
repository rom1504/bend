# Exact Char identity lowering

Candidate module: `selfhost/src/back/qbe/char-identity.bend`.
Hook: `p185cc_previous(stmt,ids,code) = p186ch_stmt(stmt,ids,code)`;
its refused path is `p186rt_stmt`, which preserves the prior emitter chain.
The transport agent owns that hook. The existing Phase126 Nat expansion and its
Char-refusal controls remain unchanged.

ABI11102 `runtime/qbe/runtime.c` defines Char kind5, arity1: construction returns
the complete input word; taking writes the complete word then returns1. Neither
operation checks Unicode range or changes ownership. The candidate requires the
exact import, return/argument types, canonical state argument, literal kind/count
and local buffer. Original verification still establishes accessible memory and
source legality. State-as-buffer is conservatively refused. No new temporary or
counter reservation is needed. Memory access precedes destination assignment,
including input/destination and buffer/destination aliases.

Append `char-controls.bend` to the checked API and export:

- `p186chc_controls`: all22 metadata rows must end `=1`.
- `p186chc_oracle_module`: QBE for six full-word/alias observers.

Pass the resulting QBE through the authenticated QBE/assembler/linker assets and
link `char-controls.c` as the observer. Its exact stdout is
`phase186 char controls pass: 60\n`. No runtime helper should remain in that
module; this control uses no replacement runtime or compiler semantics in C.
It checks zero, Unicode boundaries, values beyond Unicode, 2^32, bit63 and
UINT64_MAX, result status, canaries and unchanged state.

Actual Phase185 final N2 products retain static Char take/constructor sites:
record aggregation and morning11/10, Unicode6/6, lexer8/9. These site counts
establish reach only, not dynamic time. Screen current text/record workloads
before expanding claims. No target runs were performed while preparing this
candidate.
