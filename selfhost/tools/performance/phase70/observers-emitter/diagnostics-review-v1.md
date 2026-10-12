# Independent six-diagnostic review

Source/data review of `observer-diagnostics-plan01/plan.json`,
`prepare-active-path-v1.py`, `prepare-error-diagnostic-v2.py`,
`emission-audit-v2.py`, and `run-diagnostics-v1.py`. No compiler or native target
was executed by this reviewer. Result: ready for root execution, no blocker.

All 61 plan input pins matched current bytes. For each of the six jobs, removing
the recorded helpers and reversing its recorded function/macro edits recovered
the original emitted C byte for byte. Each derivation's source/output pins also
match its execution job. This qualifies the derivations, not their executions.

The three active-path probes insert only a flushed, once-per-process adapter
entry marker and an exit-time missing-entry failure. Their oracle retains the
exact original stdout, stderr and return code after removing that one marker.
Thus the two demanded Nat failures must actually enter the selected adapter;
the original runtime fail-stop remains intact. The shared-root success probe
retains the original result and requires adapter entry before normal exit.

The three shared-error probes intentionally emulate error visibility on the
host and force `seq=false`. They retain the generated observer and adapter
branches. Counters reject success after injection, missing entry, premature
observer entry, missed return, or reaching wrapper construction. Loop mode
starts the unchanged modulo-4096 poll counter at 4092 and injects before the
fourth `nf_again` poll; the oracle requires three real prior transitions, one
observer entry, four visits and a failure return. Each probe stops at the
adapter's failure receipt before wrapper allocation.

The controller runs six serial compile/execute pairs in one `ExecutionGuard`,
pins the compiler/support/source inputs, uses CPU3, 2 GiB RSS and 4 GiB minimum
available memory, and supplies 90-second compile and 20-second execution
deadlines. Expected native status 1 is accepted only when the guard did not
stop or error, both process and child receipts report 1, and exact output
matches. A guard timeout, missing child receipt or changed executable fails.

Scope limits: `pre-entry` means the owned adapter's entry check; it is not a
direct test of scheduler `WL_OPEN`. Shared-error visibility is deliberately
emulated and instrumented failure returns terminate the diagnostic process.
These are neither production-host cancellation nor physical GPU tests, and
they establish no memory-leak or performance result. The source token audit
supports the inspected generated bodies; it is not a universal C verifier.
