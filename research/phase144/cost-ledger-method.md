# Phase144 cost ledger

`selfhost/tools/performance/phase144/costs-v03.py` reads metadata only. The v01
method and its interim receipts remain intact. It finds
every `process.json` below `selfhost/build/phase144`, including `guard01`, nested
guards and arbitrarily named receipt directories. It also searches all immediate
`p144`-tagged directories below `phase111` and `phase131`; this includes all four
chooser-law guards. It does not add the same process embedded in a parent
`report.json` a second time or recursively scan unrelated historical artifacts.

For the final snapshot, after all root jobs close:

```sh
python3 selfhost/tools/performance/phase144/costs-v03.py \
  --out implementation/phase144/costs-final02.json \
  --markdown implementation/phase144/costs-final02.md --require-closed
```

Both destinations must be fresh. If a receipt is still open or unreadable, the
tool writes an explicitly incomplete snapshot and returns nonzero with
`--require-closed`. A later attempt needs a new destination. Without that option,
an interim snapshot succeeds while still declaring pending work and unknown
duration. A receipt changing during the read also prevents complete status.

The six synthetic checks in `test_costs_v01.py` cover nested/parallel interval
denominators, pending durations, expected rejection, explicit unknown category
and suffix-independent classification. They execute no compiler or workload.

The [interim snapshot](costs-interim01.json) contains 137 closed receipts as of
its embedded timestamp: 80.37 minutes summed guarded wall and 80.37 minutes
covered interval union. Those happen to be equal because these guards did not
overlap; the method does not assume serial execution. Unexpected command
failures account for 8.30 minutes. A further 0.310 seconds is the independently
confirmed expected negative kernel check. Two Clang builds account for 207.77
seconds stopped by process-tree RSS limits. That is explicit resource-limited
failure, **not evidence of a kernel OOM**. The final N1 acquisition had closed
by this snapshot; subsequent qualification and measurements must be included
by a fresh final run.

Primary categories describe inclusive guarded actions: profiling, artifact/API
acquisition, checks, measurement and native qualification. Unknown stays visible.
Each row contains the actual command and classification rule. A machine build
that also checks output remains one acquisition cost; the ledger does not invent
an internal split. Category interval unions may overlap and cannot generally
be added. Separate per-guard peak RSS values also cannot be added.

Time outside the guard union is merely unobserved by these receipts. It includes
unguarded metadata tools, edits, communication and scheduling, among other
possibilities. **It measures neither agent reasoning nor idle time nor quota.**
The process receipts do not provide agent token/compute usage, and summed guarded
wall is not summed CPU time. Failures may be harness defects, refused candidates,
deadlines or resource stops; their costs remain visible without claiming every
nonzero command is a compiler semantic failure.

## Final-campaign classification update

Version02 preserves discovery, timing denominators, failed-work accounting and
all six original controls. Four additional controls classify native host/IO
smokes as native qualification and generated-program measurement, resumption
and rechecks as measurement; program acquisition remains acquisition. All ten
metadata-only tests pass. The ledger pins both method versions.

The original version already **counted** these new receipts, but classified
several as unknown. In particular, the400.076-second deadline-stopped program
campaign is failed measurement work, and its13.778-second successful resume
is additional measurement work. Reusing its completed observations does not
erase the earlier cost. A failed host smoke is retained whether its eventual
explanation is a harness defect or a compiler error. The final snapshot must
still wait for every scoped guard to close; this update did not run it.

## Closed final snapshot

Version03 explicitly classifies the remaining11 unknown actions: two full Q3
self-reproductions, two range-policy latency experiments, constructor-existence
consumer timing, a transport timing experiment, concat diagnostic observation,
three packaged-native exact-output checks and small-product acquisition. These
are explicit command/path rules, not a blanket default for unknown work. All14
synthetic tests pass. The v02 method and first final snapshot remain untouched.

The [second final snapshot](../../implementation/phase144/costs-final02.json)
contains the same199 receipt identities, durations and statuses as the first:
9,766.158 seconds of guarded work,22 failed guards totaling920.403 seconds,
one expected negative check of0.310 seconds, and no overlapping guard intervals.
Only category labels/bases differ. Before collection, all scoped receipts were
closed and no live repository target or native check guard was found. This
verification and the ledger itself ran metadata only.

The [human-readable totals](../../implementation/phase144/costs-final02.md)
separate acquisition64.79 min, measurement48.16 min, native qualification22.58
min, profiling22.34 min and checks4.91 min. Categories remain inclusive actions,
not exclusive inner stages; failed work is included in these totals. The
172.07 min outside the guarded interval union is unobserved by this mechanism
and cannot be labeled reasoning, waiting or quota consumption. Both final
output paths now exist; reproduction must choose fresh destinations.
