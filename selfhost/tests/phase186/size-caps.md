# Continuation size-cap falsifier

This isolated overlay changes two literals: `p114h_plan` owner-node limit
512→2048, and `p112f_cont_result` continuation-suffix limit128→1024. See
`size-caps.json` for exact replacement symbols and original declaration hashes.
No maintained module or manifest changes. No target jobs have run.

Both limits bound compiler work and output growth. They do not determine frame
layout, ownership, register bank transport, the8 capture/case limit, scratch
capacity, argument arity, lexical hygiene, or the allowed-call graph. Those
checks remain byte-for-byte unchanged. The shared continuation parser also
serves ordinary fusion, so the128 change can affect more than H plans. Retain
original verification and semantic controls; source inspection is not a proof.

For a checked diagnostic API, append `size-caps-probe.bend` and optionally
`size-caps-controls.bend`. Export `p186hc_probe` and `p186hc_controls` alongside
`p88_cache_prepare`, `p86_plan`, and `p169np_plan`. The probe signature is
`p186hc_probe(cursor: P134Cursor, names: List<&2,String>) -> List<&2,String>`.
Use the actual verified `P169Prepared.cursor`, not a reconstructed host graph.
An unchanged baseline API needs no replacement definitions. The candidate API
replaces only the two declarations listed in the spec with `size-caps.bend`.

Query record256 names:

```
$direct.Map.seek.go,$direct.Map.get.go,$direct.Map.put.go,$direct.Map.ins.go,$direct.Map.seek,$direct.Map.get,$direct.Map.set,$direct.p37.aggregate,$direct.p37.aggregate.put,$direct.Map.to_list.go
```

Rows distinguish exact owner-node counts and old/new size predicates from
`current-H` admission. A separate scan/closure row tests the original prelude,
body scan and8-case closure under the API's actual callable view. Continuation
rows use a diagnostic copy of the existing prefix/safety parser with only its
size test removed; successful rows report the exact suffix-node count used by
the old128 test. These diagnostic values never enter a compiler plan. A
`non-size-refusal` is not a size rejection. Syntactic frame inventory includes
failure-only branches and is bounded to32 distinct names per owner, with an
explicit truncation row. Do not interpret that inventory as the H case count.

`p186hc_controls(False{})` for baseline and `p186hc_controls(True{})` for the
overlay each require eleven rows ending`=1`. They verify exact512/513/2048/2049
owner and128/129/1024/1025 continuation boundaries, plus original IR validity.
The synthetic owner is an intentional infinite loop used only for planning;
do not execute it. Existing stacked controls still test actual machine behavior,
including exact frame order, aliases, deep descent and the unchanged8/9-case
boundary. Re-run those on any candidate used for execution.

The first falsifier is whether at least one hot Map helper becomes a complete
H plan with the unchanged8-case and callable constraints. Size-fit alone is
not progress. If it does, emit record256 once, confirm actual private admission
and the frozen output oracle, then measure the complete computation against
the identical parent. Static node counts do not provide a runtime ceiling.

An additional callable-H registry is deliberately not implemented. Its smallest
safe form would freeze already-admitted H plans against an immutable prior
callable view, then publish their exact arity and `p114r_symbol` to later ranks.
Each new rank may call only earlier ranks; no new machine recursion/SCC enters.
Store or otherwise bind the admission view used for each emitted plan:
rechecking it against a registry containing itself triggers `p114h_plan`'s
already-known refusal. Pure tail wrappers also need a separate terminal-helper
path because H admission requires at least one pending frame. Thus registry
publication alone does not unlock `Map.to_list`, let alone the get/set chain.
