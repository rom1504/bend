# Cold shared-input correction, version2

`ownership-api01` accepted the original Bend fixture. `ownership-controls01`
passed hot/direct and hot/assembly, each with360 observations, then failed at
cold/direct with `bend: runtime fail-stop`. Preserve that report, all streams,
the original observer and driver unchanged.

The defect is in the C input construction. Capability8 plus cold OLeaf/ONode
permits raw owned children in a unique parent. The original shared test directly
called `p111_rt_keep` on that cold parent. Runtime `term_keep` wraps the parent;
it does not seal its children. Consuming this count>1 parent reaches
`ctr_take → span_fade`; `span_fade` explicitly posts ERR_RFCS for a nontrivial
raw field. The baseline therefore cannot consume this manually shared graph.
In the test's deterministic ordering, the first such case is baseline depth0,
shared nonempty leaf, query0. The sparse failure stream does not identify its
exact instruction; this diagnosis is source/runtime analysis, not a new probe.

The original claims that all C-built shared/cold inputs were valid were wrong.
This does not establish a candidate algorithm error: the same inadmissible input
already violates the baseline runtime contract. Do not retry it with added
failure-runtime instrumentation.

`observer-v2.c` keeps all360 observations and all alias/lifetime assertions. For
shared cold trees only, construction now publishes each child before storing it:
`keep(owned)` returns an RFC word owning two references; sinking one temporary
reference leaves one owned RFC word replacing the consumed raw word in the
new parent. Publication recurses through the tree during input construction,
outside the measured loop. An independent `shareable_tree` scan confirms every
nontrivial child word is RFC before any parent is shared. Failure of this
precondition fails the oracle instead of invoking runtime with an invalid graph.

Unique cold inputs retain raw payload children and still require candidate
fallback on first hits. Shared cold inputs now have RFC payloads and must use
the fast route. This changes the expected route to match valid publication,
not the expected logical tree, hit/miss or post-root payload contents. Hot
construction and the checked Bend algorithms are unchanged.

`driver-v2.mjs` changes only observer identity and report version. Reuse the
accepted API; no API rebuild or increased resource budget is needed:

```sh
python3 -B selfhost/tests/phase195/job.py ownership-controls02 120 48 \
  selfhost/.assets/bin/bun selfhost/tests/phase195/ownership/driver-v2.mjs \
  --api selfhost/build/phase195/ownership-api01/report.json \
  --assets selfhost/build/phase194/assets.json \
  --out selfhost/build/phase195/ownership-controls02 --seconds 110
```

Only after that report passes should timing.py consume it. In cold/shared
timing, publication happens before timing starts and fast-route counts should
remain explicit. Cold/unique repeated lookup can gradually publish visited
payloads through baseline fallback; that distinction is preserved.
