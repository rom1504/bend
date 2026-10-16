# Phase102 time accounting

The accounting reader measures the wall time covered by guarded process
receipts. It does not estimate time spent coding or infer CPU time from process
duration. The coordinator supplies the campaign start and an explicit cutoff
after the last selected qualification target; later archive, documentation and
Git work is outside that interval and must be reported separately.

The method is frozen at SHA256
`7f69066fb0ecdd0c997ceaaee259e055872d1e91d4a7b7469faba8b633bda4bb`.
Independent source review and synthetic checks pass for interval clipping and
union, failed attempts, pre-launch refusals, malformed/nonfinite numbers,
root deduplication, and inventory/byte changes. This review runs no campaign
targets and reads no experiment receipt tree.

The [data-only reader](../../selfhost/tools/performance/phase102/qualification/account-time.py)
reads `process.json` under explicitly named roots. It records every receipt's
identity and command, verifies finished epoch timestamps and return codes,
clips each interval to the requested window, then merges overlapping or nested
intervals. The merged union counts each elapsed second once. The unmerged sum
is retained for inspection and is not an elapsed-time total. Canonical paths
deduplicate repeated and nested input roots.

Failed attempts count. In particular, the first native B2 build's 420-second
Clang timeout remains part of the campaign. A guard's `complete: false` can
mean an expected nonzero exit or a stopped attempt; a valid finish timestamp
and integer return code normally determine whether its interval can be accounted.
The actual guard can stop before recording an exit code, for example on an
initial memory-headroom refusal or launcher error. A finished receipt with
`complete: false` and an explicit stop/error reason is included and separately
counted as having no exit code; it is not relabelled as a program execution.
Missing, malformed, nonfinite or reversed timestamps prevent a complete
account. The method rechecks all input bytes and the receipt inventory at the
end. It relies on the coordinator's explicit writer-closure declaration for a
final result; a successful scan alone does not establish closure. Symlink
directories are rejected rather than silently omitting a linked subtree, and
the output cannot create a new `process.json` inside the scanned scope.

`elapsedWallSeconds - guardedUnionSeconds` is **unclassified wall time**. It
can include review, orchestration, waits, unguarded tools and other work. It is
not evidence of an optimization, coding or idle-time category. The report also
groups intervals by their first directory beneath each selected root to make
individual experiment costs inspectable; those group unions may overlap and
must not be added. Commands and complete receipt identities support a later
explicit classification without guessing from directory names.

The root coordinator should run the following after closing target writers,
substituting the exact declared UTC boundaries and fresh output path:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase102/qualification/account-time.py \
  --root selfhost/build/phase102 \
  --start "$PHASE102_START_UTC" \
  --start-meaning 'Coordinator-declared campaign start; state its precision' \
  --cutoff "$PHASE102_TARGET_CUTOFF_UTC" \
  --cutoff-meaning 'Final selected target closure; later publication work excluded' \
  --final --writers-closed \
  --out implementation/phase102/evidence/time-account-final.json
```

Add `--root` for guarded campaign targets written elsewhere. The current
campaign has additional roots beneath `selfhost/build/phase99/`, including
`phase102-b1-screen02`, `phase102-b2-screen02`, `phase102-release02`,
`phase102-runtime-phase98-02` and `phase102-runtime-products02`. The final03
qualification/timing successors need their own roots when created. Preparatory
`phase102-final-plan01/02` directories may also be included explicitly; the
reader counts only actual guarded receipts within them.
Only pass roots that exist when accounting runs. The explicit root list is the
measured scope, not a claim to cover every process on the machine. A start
known only to the minute must be described at that precision;
the reader does not invent a more precise boundary. Completed receipts wholly
outside the window are listed and excluded; crossing intervals are clipped
and counted explicitly. Publication exclusion is temporal, not a claim about
what activity occurred in an uncovered interval. Omitting `--final` produces a
provisional snapshot with `complete: false` even if all scanned receipts have
finished. The completed final totals and exact scope follow.

## Final measured account

Targets closed at **2026-10-16 23:20:45 UTC** after the20:09 minute-precision
start: **3h11m45s** including the final regression diagnosis. Archival,
documentation and Git publication follow outside this interval.

`selfhost/build/phase102/time-account-final.json` is complete and stable:

| Measured category | Elapsed time |
|---|---:|
| Union of4,919 guarded target intervals |101m37.4s|
| Of that, native-b1/native-chain directories (all three attempts and their gates) |62m52.4s|
| Other guarded intervals |38m45.0s|
| Unclassified wall time outside guarded intervals |90m07.6s|

The unmerged interval sum equals the union: there was no overlap between these
recorded target jobs. The native-directory subtotal is the interval union of
receipts whose paths are under `phase102/native-b1-*` or `phase102/native-chain*`;
it includes image acquisition, construction, self requests and those directories'
semantic gates. It is not solely Clang time. The other-target row is the exact
difference from the total union. CPU time, agent token cost and the activity mix
of the unclassified time are not inferred.

All4,919 receipts intersect the window; none has a missing exit code. There
are54 nonzero outcomes, including intentional rejection/fault controls and real
failed attempts, and one guarded stop: the original420s build timeout. No
memory-limit stop or OOM is recorded. The report has zero accounting issues.

This campaign still spent too much of its target time rebuilding candidates
before every important runtime sentinel was in the fast screen. The total
native-chain subtree time makes that cost explicit. The late hint-only diagnosis
takes53.4s of guarded build/run time; it demonstrates why a short controlled
ablation is preferable to another immediate full bootstrap. Candidate04 stops
at checked source, exact emission and the focused application screen here.

## Improvements to the next campaign

Two expensive lessons are already visible before final accounting closes:

- Inspect the compiler-scale forced-inline dependency expansion before the
  first Clang image build. A local body-size limit did not bound composition;
  the failed420s build was avoidable with this earlier structural screen.
- Put a small list-construction runtime sentinel beside the application screen
  before native qualification. Candidate02 passed all semantic gates but its
  broad runtime survey found unnecessary cold-link sealing. Checking generated
  C from the testing API is sufficient for this discovery step; native B1/B2 C
  identity and release qualification still belong to the final winner.
- Freeze after these performance screens. The late projection win and cold-link
  repair justified another native chain, but it cost another acquisition/build/
  fixed-point cycle. Keep the initial image only when it resolves a decision
  that cheaper source/API/C probes cannot answer.
- Include the three fold points in that pre-image screen. Preserve dependency
  cost across allocation elimination so profitability decisions compose.
- Preserve exact-C product reuse with original build provenance. It avoids
  recompiling unchanged benchmark products while retaining fresh final-source
  emissions and fresh timings. The final acquisition receipt, not an estimate,
  determines how many builds were actually saved.

Actual final03 reuse saves **zero** builds: all45 C products change, and all45
are built fresh in106.82s. The reuse mechanism is useful infrastructure, but
this run supplies no measured build-time saving from it.

These are workflow conclusions, not fabricated allocations of uninstrumented
wall time. The final accounting reports the union of recorded target intervals;
its complement is unclassified and must not be labeled all coding or all idle.
