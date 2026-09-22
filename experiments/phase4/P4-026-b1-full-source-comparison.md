# P4-026: controlled complete-source B1 equality comparison

Status: plan recorded before execution, 2026-09-22 around 19:31 UTC.

P4-024 passes 909 helper controls, twelve selected compilation observations,
the complete 2,756-observation frontend gate, and one exact full-source H emission.
Its two core request pairs improve 35.58% and 35.13%. The full-source observation
takes 348.373 seconds, but the earlier checked B1 emission used a different run
history. A causal whole-source gain must use a fresh comparison.

Hypothesis: the same guarded native string-equality change materially reduces
complete compiler-source compilation time while preserving actual emitted H.
This remains an experiment on the exact checked B1 artifact, not a newly checked
bootstrap, generic transformation for future source revisions, or default API.

Freeze original B1 `0653f21e…`, derived B1 `e95e1198…`, final source `34c6ef63…`,
runtime `26f5eee2…`, canonical pinned Base and the original frozen host/worker.
Reconstruct the candidate from the original and require its complete/body guards.
Reuse the selected pilot's separate validated Base caches, verifying their
decoded payload equality and immutable bytes. Capture every consumed input,
tool, command, affinity, process result, output and memory observation.

Run fresh processes on physical CPU2 in control/candidate then candidate/control
order, each with Node 24.18.0, a 4 MiB stack and 12 GiB heap limit. Each request
has a 15-minute deadline; the entire comparison must stop by **20:09 UTC** to
allow archival and final review within the authorized six-hour campaign. Do not
start until the P4-025 timed core comparison releases the machine. No other
intentional compiler workload may overlap these samples. Modest documentation,
archive and review activity on other cores is permitted and recorded; this is
not operating-system isolation. OS caches are not flushed.

Every completed row must check successfully, preserve exact result fields and
actual H bytes `b33b38e3…`, and pass before/after input checks. Record complete
process wall, request wall and maximum child RSS separately. Retain every run,
including failures and deadline stops. Report the two pairs and full distribution
before a mean/median; do not use only survivors or combine these samples with
the earlier single correctness observation.

The performance hypothesis passes only if both opposite-order request and
process reductions exceed 5%, without a correctness mismatch. A valid null or
regression is still a completed experiment. A deadline leaves an incomplete
comparison and permits only descriptive completed-row reporting. No deployment
follows automatically: the exact-artifact scope remains explicit even after a
positive result. No source, upstream compiler, ordinary API or public runtime
changes are authorized by this experiment.
