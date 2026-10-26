# Phase144 cost ledger

`selfhost/tools/performance/phase144/costs-v01.py` reads metadata only. It finds
every `process.json` below `selfhost/build/phase144`, including `guard01`, nested
guards and arbitrarily named receipt directories. It also searches all immediate
`p144`-tagged directories below `phase111` and `phase131`; this includes all four
chooser-law guards. It does not add the same process embedded in a parent
`report.json` a second time or recursively scan unrelated historical artifacts.

For the final snapshot, after all root jobs close:

```sh
python3 selfhost/tools/performance/phase144/costs-v01.py \
  --out implementation/phase144/costs-final.json \
  --markdown implementation/phase144/costs-final.md --require-closed
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
