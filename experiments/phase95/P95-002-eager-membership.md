# P95-002: avoid traversing an entire list after a membership hit

Status: tested; mechanism confirmed, not promoted.

`nb_contains` in native/tables.bend computes String equality OR a recursive
membership result. Ordinary Bool arguments are eager, so the tail is evaluated
even after a matching head. The existing core `has_name` dispatches on the first
comparison before recursing. Reusing it could remove avoidable traversal/string
ownership traffic without changing the order or contents of any compiler list.
`nr_walk` uses this membership for every dependency name, among other callers.

First establish current native physical cost and test exact extracted helpers
on head/middle/tail hits, misses, duplicates, empty and Unicode input, with varying
list size and retained roots. A head hit should scale differently if the proposed
mechanism is real. Require full result checks; do not infer whole-compiler benefit
from a synthetic head-hit workload. Misses may not improve.

Candidate: replace only `nb_contains`'s body with the existing `has_name` helper.
Keep indexed reachability as a separate possible follow-up. The proof obligation
is finite ordered-list membership equivalence with the same pure equality, not
an assertion about String sharing or C reference counting.

Twenty exact control output lines pass. Final extracted native measurements:
head hits improve7.7–857× across sizes8–1024; the128-entry middle hit improves2×;
miss and tail become5.9% and2.7% slower. Independent per-role calibration,
consumed expected checksums and first-case doubled-count controls pass. Frozen
source failures and incomplete initial calibration remain excluded and retained.

The full checked B1 candidate removes two lines/81bytes and no concept. Actual
six-source compilation is neutral:0.996642× request /0.999952× process,24 pairs.
Full D04 input takes138.029s baseline versus136.418s candidate in one pair:
0.9883285×, too small to justify a new native/JS release on this evidence.
Complete generated C and the existing unsafe-trust diagnostic remain identical.
All45 original benchmark C products are also exact;95 complete comparisons pass
across the screen, full pair and broad gate. No new generated-program timings.
No formal proof of the existing unsafe mutually recursive helper is claimed.
The [report](../../implementation/phase95/README.md) documents scope and evidence.
