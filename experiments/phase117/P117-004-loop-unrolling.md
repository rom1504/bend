# P117-004 — bounded two-iteration expansion

Phase116 observed upstream unrolling the fold kernel twice. Phase117 versioning
now exposes a call-free hot loop, making this a cheap next experiment. Test a
small general structured unroll2, solely on versioned loops with one static
backedge,≤16 parameters,≤256 transfer-expanded nodes and no calls except the
unchanged pattern-match failure helper. No workload names or source rewrite.

Snapshot every carried actual before assigning formals. Execute a second copy of
the original body; retain its original backedge/exit checks and remove only its
already-hoisted duplicate allocations. Reject growth above2×. Preserve the exact
original fallback and failure behavior; use only ordinary valid inputs.

Qualify source and inspect actual activation before measuring. Compare the same
frozen fold inputs and edit-distance control with Phase114/upstream, then compare
against selected version-source03. A useful result needs general transfer and
ordinary zero/one/odd-count checks. Otherwise defer it without changing selection.

## Outcome

Source/API check,36 initial observations,60 longer matched observations and ordinary0/1/3/17 counts pass. Direct extra speedups are1.0604×/1.1126×/1.1115× on three folds,1.0×editdist. Retain optional prototype; exclude from selected source because broad contribution is limited.

[Complete report](../../implementation/phase117/README.md) retains exact receipts and limits.
