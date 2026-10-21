# P118-002: preserve the live register prefix

Status: focused positive result; broad and native qualification pending.

The Phase116/118 physical profiles show substantial runtime and libc work after
the ownership transformations. A libc sample alone does not identify copying or
clearing. This experiment changes those operations independently on authenticated
programs, then checks complete outputs and elapsed time.

The existing source factory emits one result and continuations with at most one
incoming result. Generic structural verification alone is insufficient to omit
register clearing: reflected IR can address state directly or read old inputs
after an outgoing transition. `transport-certificate-v2.bend` therefore adds a
necessary predicate after original verification. It checks every original
segment and final direct worker, rejects state aliases/raw access, restricts
runtime imports, and requires each transition to terminate its block. Final
templates retain their existing authenticated source contracts.

Capability4 enables two independently measured runtime changes:

1. `runtime-transport.py` omits clearing the inactive tail. Live prefix copies,
   initial initialization and builtin behavior remain intact.
2. `runtime-bank.py` lets builtins use the invocation's register bank directly.
   Exit snapshots/restores the explicit result count into separate storage.
   All builtin inputs are saved before overwriting slots. Legacy capabilities
   retain their old behavior. See `bank-audit.md` for alias/lifetime obligations.

Three rotated original-oracle rounds, median milliseconds:

| Case | Phase117 | Combined ownership | Dead-tail omission | In-place bank |
|---|---:|---:|---:|---:|
| map128 |433–438|209|182|183|
| lexer |334–339|250|219|218|
| tree-bitonic |332–336|265|243|239|
| closures256 |151|unmeasured|128|87|

These are separate screens, not matched confidence intervals. The first three
combined/transport emissions differ only in descriptor capability11→15; exact
line differences are retained in `transport-ablation-comparison01.json`.
The bank ablation uses identical QBE. Every screen uses the original full-output
oracle, sources, arguments and repetition counts. No broad45 aggregate or native
compiler gain follows from this table.

Receipts under `selfhost/build/phase118/`: `combined-screen01`,
`transport-screen01`, `bank-screen02`, `transport-finite01.json`.
The attempted `bank-screen01-guard` was rejected by the execution lock before
running a target; it overlapped a still-active inspection guard. Keep this
supervision mistake in the cost accounting.

The broader lesson is that a source-derived fact can authorize removal of an
entire transport operation. This is more general than a workload-specific
peephole, but it is not authority to erase arbitrary runtime checks or change
the physical register layout.
