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
qualification queue writes three such roots beneath `selfhost/build/phase99/`:
`phase102-b1-screen02`, `phase102-b2-screen02` and
`phase102-runtime-products02`; later timing output needs its own root too.
Only pass roots that exist when accounting runs. The explicit root list is the
measured scope, not a claim to cover every process on the machine. A start
known only to the minute must be described at that precision;
the reader does not invent a more precise boundary. Completed receipts wholly
outside the window are listed and excluded; crossing intervals are clipped
and counted explicitly. Publication exclusion is temporal, not a claim about
what activity occurred in an uncovered interval. Omitting `--final` produces a
provisional snapshot with `complete: false` even if all scanned receipts have
finished. No final totals have been computed yet.
