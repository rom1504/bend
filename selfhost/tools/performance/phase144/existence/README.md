# Exact immutable constructor-existence batch

Read [the semantic and cost audit](../../../../../research/phase144/constructor-existence.md).

`core-v01.bend` adds a separate existence fact and two complete batch consumers.
Ownership positives are insufficient, and the full future source cannot be
used as the checker's prior-event prefix. Existing original functions remain
the independent oracles; there are no overrides or cache/runtime changes.

`prepare-v01.py` already prepared the unselected source and serial root-only
jobs in `selfhost/build/phase144/existence-source01/`. The jobs source-check
once, run27 explicit semantic controls, then screen actual parsed compiler
prefix consumer replays in `screen-v01.mjs`. Only root may run those targets.

The event screen includes publication into the seen book; the disjoint screen
includes the complete recursive query batch. Candidate index construction and
host GC are charged. Prepared Base and parsing costs are reported separately.
This is a falsifier for a small general transformation, not evidence of native
compiler speedup or permission to replace a correctness gate.
