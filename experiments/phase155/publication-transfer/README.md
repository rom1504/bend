# Actual publication transfer: 05t and 07t

Prepare only (does not launch targets):

```
python3 -B experiments/phase155/publication-transfer/prepare.py --out selfhost/build/phase155/publication-transfer01
```

The generated `jobs.json` contains separate guarded checked-API acquisition and
transfer jobs for the root to run serially. Defaults are the freshly extracted
37KB original compiler-verifier source and the unrelated current Map workload.
Both load the actual pinned Base source. `--full-source` is an explicit later
option, not enabled by default. No native image acquisition is requested.

The arguments are the unchanged `FLoadTrace.result.book` and a maximum event
count. The initial declaration book and suffix schedule use the entire stream,
even when replay stops after a prefix. Separate law/fill events, source order,
original duplicate/constructor/law guards, and the rule that only the last
same-name event publishes are retained. This removes the synthetic grouping of
ADTs from the first screen.

05t changes only the canonical-state bit at publication. 07t changes only the
constructor-membership query for an unseen ADT owner. Both retain all mixed
Def/ADT events in the original `seen` book. The auxiliary constructor index is
updated only after success. Duplicate ADTs fail before replacement; law/fill
Def replacement is allowed only because admitted non-ADTs have no constructors.
Unsupported cache/index events or childful non-ADTs return `admitted=False`;
the runner treats this as failure rather than a fast result.

Each raw result contains full publication book and index, full event history,
first error, processed count and admission. The runner compares these complete
objects with standard deep equality, retaining generic graph captures of the
entire input and reference output. It does not prune or reconstruct KDefs.
The String entries provide an alternative complete all-field consumer for a
later native harness. Existing finite failure-prefix controls run first.

This is a fresh checker-shaped publication replay, not dependent checking and
not the ordinary prepared-Base context. Type errors, template instantiation,
specialization and fresh-ID state are not simulated. The original verifier is
unchanged. Hosted acquisition/replay clocks are diagnostics only; native speed
claims remain confined to the original synthetic screen until a separately
charged native transfer is run.

Preparing agent performed Python/JSON syntax parsing only. A requested JS
syntax-only check could not run because `node` is unavailable; the root's checked
workflow will exercise the runner with the pinned Bun executable. No targets ran.

## Executed result

Root's `publication-transfer-prepare02` source check and transfer passed. At
prefixes0,32,all, original and both candidates agree on every raw result field
for603 actual compiler-verifier events and504 Map events, with the original
Base loader. Seven admission/failure controls pass. Guarded execution12.985s;
peak process-tree RSS462,176,256bytes. Diagnostic hosted timings are not paired
native performance. Preparation01's ordinary match-order typecheck failure is
retained. No full-source or native-transfer campaign was run.
