# Exact process-local registry planning reuse

The selected experimental module is `registry-v02.bend`, with
`registry-controls-v02.bend`. The v01 files preserve the first source refusal;
v02 replaces an illegal match on an earlier binder after matching a later binder
with ordinary continuation helpers. It also avoids matching after local
statements. No production declaration is overridden.

Interface:

```text
p140g_prepare(plan, P140GCache{[]})
  -> P140GPrepared{cursor, cache, hits, misses}
```

Retain the returned typed cache for the next plan under the same compiler,
runtime and policy epoch. Drain `cursor` with the original renderer or the
separate validated rendered-unit cache. Cache contents are trusted process-local
results; this is not an untrusted serialization or forged-certificate interface.
`p140g_index(segments,index,cache)` exposes the registry stage for diagnostics.

## Work reused and work retained

The original `p112c_index_with` filters candidates, then runs at most six passes.
Within each pass, `old` ready and symbols are immutable; only the next registry
accumulates. The new code mirrors this boundary:

1. Run the unchanged `p112c_candidates` predicate and preserve candidate order.
2. Compare the exact old ready/symbols views and rank once for the pass.
3. For a not-already-ready candidate, compare its exact segment and the complete
   bounded closure of frame-target index results. The audited render dependency
   rule covers `p112c_scan` too. Missing results are dependencies; budget overflow
   creates a non-reusable key.
4. On a miss, run the unchanged `p112c_scan` and `p112c_plan`. Retain their
   transformed segment, worker plan and site count, including refused plans.
5. On either a hit or a miss, call unchanged `p112c_freeze` against the **current**
   registry. Do not copy an old registry or old accumulated entry list.
6. Preserve original already-ready skips, entry order, rank, worker/fusion
   counters, fixed-point detection and six-round bound.

The same immutable pass views make a cached negative plan reusable. Later
passes have their own keys; admission in a new earlier pass changes the view and
can invalidate later cached planning. A changed continuation can invalidate a
candidate even when its own segment is byte-for-byte unchanged.

`p140g_prepare` mirrors every `p134e_begin` success route. It still computes IDs,
fusion index, global tables, descriptor capabilities, direct signatures and
other contexts using the original functions. The only replacement in
`p134e_prepare` is registry construction. Original checking, admission and final
verification happen before this prepared sealed emission boundary and are not
weakened here. Candidate prefilter caching was deliberately omitted.

## Evidence so far

The isolated source is
`selfhost/build/phase140/registry-source02/compiler.bend`, SHA-256
`d822e506359ea1d536d1b24ed12f40a94eb0fec92a3808c261ea58650cb5c54a`.
It combines the render reuse v02, its controls, registry v02 and its controls on
the qualified Phase137 source. No installed compiler selection changed.

- Checked API: `selfhost/build/phase111/p140-registry-api02/report.json`.
  Independent upstream check/acquisition passed; guarded wall time 15.24s,
  sampled process-tree peak 2.19GB.
- Finite controls: `selfhost/build/phase128/p140-registry-finite02/report.json`.
  All **70 rows passed**: 21 registry, 25 original render and 24 extended render
  controls. Guarded wall time 1.92s, sampled peak 167MB.
- Both ran under the existing Phase131 CPU5 usage guard with a 3GiB process-tree
  limit and 16GiB available-memory floor. An earlier standard-lock attempt was
  refused before a target ran; it did not bypass the active execution lane.

Registry controls compare complete registries against the unchanged
`p112c_index`, including ready/symbols, entry order and all worker-plan fields,
worker/fusion counts. They cover later-pass caller admission, candidate body and
order edits, ready-view changes, continuation edits/addition/removal, cold and
warm runs, and exact raw/static/direct preparation text. An eight-level call
chain independently asserts that only six workers are admitted in the six
allowed passes. The zero-pass base case is also checked.

This is finite correctness evidence, not a speed result or a full native
qualification. Next compare complete fresh/cached outputs and end-to-end
preparation time on actual edited programs. Exact comparison and retaining six
pass views/typed plans have costs; record those costs and retained memory. A
high hit count alone is insufficient. Global metadata preparation and candidate
filtering still run, so no claim is made that all rendering preparation work has
been eliminated.
