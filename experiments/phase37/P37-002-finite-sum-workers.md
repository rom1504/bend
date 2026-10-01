# P37-002: direct private finite-sum operation

Status: prospective; investigate. Measurement: not yet run.

Hypothesis: a guarded direct private tree operation eliminates enough generic
application/closure work to materially improve tree-bitonic across several fixed
sizes. First compare guard-only and direct-operation saved-output ablations against
complete-tree oracles, then consider a small general compiler implementation.

Reject on demand/error-order/sharing/public-mutation mismatch, absent actual entry,
no reproducible gain, excessive compiler cost or inability to express the rule
without workload-specific knowledge. Preserve rejected outputs and controls.

Design: [direct workers](../../design/phase37/direct-workers.md).
Report: [Phase37](../../implementation/phase37/README.md).
