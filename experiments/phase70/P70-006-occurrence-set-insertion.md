# P70-006: do not rebuild occurrence-set entries already present

Registered before proposal construction or target execution. Owner:
`/root/phase69_closures`; independent reviewer: `/root/phase69_review`.
Compiler01 (`ee8463a`) is the current checked checkpoint. Production is untouched
by this source lane. Parent investigation: P70-003.

## Falsifiable claim

`nc_uses` collects variable IDs into a set with one constant KDef payload.
Its current generic `index_set` reconstructs a persistent trie path even when
the same complete U32 ID has already been inserted. Specialize this private
insertion: compute the existing tip/split bit once, return the old set on exact
ID equality, otherwise use the unchanged `index_insert` path. Do not add a
separate membership lookup followed by another full lookup on novel IDs.

Invariant: the collector begins at `missing()` and only inserts its same
`$native.occurrence` marker. Every summary node is produced by the existing
index helpers; no caller imports an arbitrary use-index payload into `nc_uses`.
Full U32 bits are keys, not a lossy hash, and there are no marker-name collisions.
Replacing an entry with the same payload changes neither the exact summary
value nor any ordered live/drop/share output. Traversal, Var-as-leaf behavior,
environment order/duplicates, raw-term handling and fresh/error order remain.

This is different from P68-009 Uses08 (one summary instead of per-environment
term scans), P68-012 Reuse11 (reuse a summary across same-body consumers), and
Facts23 (native fact/admission fallback). It changes neither which term is
scanned nor how often a caller asks for a summary. The global `index_set` remains
unchanged because ordinary indexes must replace varying payloads.

## Budget and fastest disproof

The saved Phase69 B2 profiles attribute 120.7/133.2/135.0 ms to collector stacks
and 52.7–80.9 ms within those stacks to index work. These are overlapping sampled
unions, not clean clocks. The broader methods census includes membership queries
and therefore has a larger 138–151 ms `nc_uses*` budget. B1 attribution is obscured
by trampolines; observed collector stacks are 343.3 ms, not a reliable split of
that time into insertion versus traversal.

If a material fraction of inserted variable occurrences repeats existing IDs,
the expected screen is roughly 1–3% less complete B2 C request time, with no
claim of a larger B1 gain until measured. Duplicate fraction is unmeasured.
Reject this direction if actual insertion counters show few duplicate entries,
the guard costs more on unique-ID trees, or a balanced request screen regresses.

## Gates

1. Independent source review of constant-payload and exact-tip invariants.
2. Checked B1 helper comparison of **entire summary indexes**, all queried IDs,
   ordered partitions and sharing strings. Include repeated/all-unique IDs,
   all U32 boundaries, deep tries, duplicate environments, malformed Var kids,
   branch-heavy terms, unused binders and empty environments. Record actual
   baseline/candidate insert calls separately from uninstrumented clocks.
3. Exact complete C for numeric/array/held-out lexer; preserve diagnostic and
   raw error gates. Existing generated-program evidence can be inherited only
   when all C bytes agree.
4. Root-owned paired checked B1 request screen, then genuine B2 only after a
   surviving small screen. Counter instrumentation earns no speed credit.

Proposal and data-only profile census go under
`selfhost/tools/performance/phase70/compiler-work/`. No new cache, IR, persistent
format, host compiler algorithm or generated-program policy is introduced.
