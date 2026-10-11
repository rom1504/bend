# P69-001 — Reachable runtime definitions determine native bang facts

Owner: root. Status at registration: proposed; no Phase69 compiler measurement.
[Design](../../design/phase69/native-parity.md) ·
[Report](../../implementation/phase69/README.md).

Compiler23 `nc_bangs_book` scans every original definition. Dead imported mains
therefore mark live helper functions as bang targets and force nonsequential
runtime mode. The same oversized fact domain also rejects otherwise eligible
ordinary workers. P68-023 proves the mode-only cost on saved C.

Change the collector to scan erased definitions in the existing main-reachable
runtime closure. Keep lookup semantics for cached/foreign definitions. Traverse
all referenced closure bodies and argument expressions; unknown indirect calls
retain their scheduler behavior. Reuse the already available live-name list in
worker preparation rather than traversing reachability again there.

Controls: adding/removing an unreachable bang-bearing def must preserve BANGS0;
making a bang reachable must preserve positive BANGS and one/four-thread output.
Include a bang inside a referenced lambda, an imported dead main, ordinary
references to the same target, and raw source demand/first-error controls.
Check tree/lexer actual emitted flags and workers, independent native digests,
and paired same-work runtime. Measure compiler cost separately: the extra
reachable traversal is not free and should be shared with later preparation.
