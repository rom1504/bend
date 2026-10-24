# Phase136 native profiling adapters

See [the investigation note](../../../../../implementation/phase136/profiling/README.md).

- `prepare-v01.py prepare|seal --out ...`: authenticate the qualified Phase134
  object and existing diagnostic runtime, prepare a link-only plan, then seal
  the manifest after the root executes that link. Preparation extracts metadata
  only; it never runs a target.
- `history-v01.py --out ...`: reproduce the retained Phase131 owner/leaf and
  timeline summary, clearly marked historical.
- `analyze-v01.py --profile ... --out ...`: authenticate one completed32ms capture
  and derive physical/context/caller intersections plus ordered CPU windows.
- `inspect-queries-v01.py --out implementation/phase136/profiling/queries01`:
  extract pinned qualified QBE query blocks and static ownership-call inventory;
  no target execution and no dynamic-count claim.

Use fresh paths. Root owns the controlled CPU3 lane and all target execution.
The generic profiler remains unchanged. Counters are disabled in the full sample;
ordinary source paths, prepared Base and complete QBE oracles stay frozen.
