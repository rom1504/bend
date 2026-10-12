# P70-006: make repeated occurrence insertion a no-op

The next recommended compact experiment is a ten-line specialization of native
occurrence-set insertion. It avoids rebuilding an unchanged persistent index
when a variable occurs again. It does not add an IR, cache, count representation
or new ownership rule. Source and method review pass; no target or speed result
is claimed by this source-only handoff.

[Registration](../../experiments/phase70/P70-006-occurrence-set-insertion.md) ·
[Patch](../../selfhost/tools/performance/phase70/compiler-work/occurrence-set-v1.patch) ·
[Exact source manifest](../../selfhost/tools/performance/phase70/compiler-work/occurrence-set-v1.json).

## Why this is the next small experiment

`nc_uses` starts with `missing()` and visits variables using the complete U32 ID
as the index key. It inserts the same immutable `$native.occurrence` marker for
every variable. Generic `index_set`, however, always calls `index_insert` after
finding the tip. An existing ID causes a new identical leaf and reconstructed
ancestor path even though the result is a set and its contents did not change.

The proposal preserves the empty-index route and computes the existing tip and
split mask once. A zero mask means the complete ID is already present, so it
returns the old index. A nonzero mask uses the exact existing `index_insert`.
This avoids the common trap of performing a membership lookup and then repeating
the search to insert each genuinely new ID. The global general-purpose index
functions remain unchanged: ordinary indexes must replace changing values.

The source patch changes only `bridge.bend`: two small helpers and the collector's
single insertion call, +10 physical lines. It is **not** the Uses08 change again:
Uses08 removed the environment multiplier, Reuse11 reused same-body summaries,
and Facts23 changed native facts/calls. This patch leaves traversal and summary
requests unchanged and removes redundant rebuilding inside each collection.

## Profile budget and uncertainty

The [reproducible reduction](../../selfhost/tools/performance/phase70/compiler-work/uses-profile-v2.json)
reopens the four unchanged Phase69 profiles against their recorded hashes.
Its [Python producer](../../selfhost/tools/performance/phase70/compiler-work/profile-uses.py)
ran on CPU0 and executed no compiler. An exploratory v1 reduction is preserved.

| Sampled union, ms | Numeric B2 | Array B2 | Lexer B2 | Numeric B1 |
| --- | ---: | ---: | ---: | ---: |
| `nc_uses` / term/list collector | 133.159 | 120.708 | 135.031 | 343.348 |
| Index functions inside collector | 80.900 | 52.747 | 68.504 | 6.133 recovered |
| `index_insert` inside collector | 69.635 | 45.541 | 55.283 | 4.121 recovered |
| `index_join` inside collector | 33.804 | 24.362 | 28.968 | not recovered |

These are sampled stack unions, not clean times, counts, or additive rows. The
broader 138–151 ms B2 /395.5 ms B1 `nc_uses*` family also includes membership-only
work; that whole budget cannot be credited to this patch. B1 trampolining hides
most descendants, so its tiny recovered index number is not its true index cost.

Novel-key insertion and `index_join` remain necessary. The duplicate fraction is
not measured by these profiles. A plausible initial screening estimate is
**1–3% lower complete B2 C request time**, including possible reduced allocation;
the direct recovered insertion budget suggests the lower part of that range.
There is no reliable numerical B1 estimate beyond its larger observed collector
budget. Zero improvement or regression remains possible because every novel
key incurs a new mask check/helper call. Do not spend a broad campaign on this
patch before a small paired screen establishes value.

## Audit of other caller opportunities

The principal collector callers remain generic `nc_lower_to` partitions,
`nc_let_atom` body summaries, `nf_bind_boxed` body summaries and let suffix
lowering. The saved B2 sampled caller paths attribute approximately 18–35 ms to
atom-body collection and 22–27 ms to boxed worker binds. These paths already
contain Reuse11's `bodyUses` reuse; repeating that edit would do nothing.

`nq_bind` still repeats some collection, but its substituted body has a different
occurrence set. Reusing the original body's index there would be unsound. The
value-environment reuse portion is smaller and does not attack the dominant
common collector cost. Parallel child lowering also rechecks an already filtered
environment, but the saved profiles do not show material parallel work.

Combining maximum/minimum product counts would add a new result representation
and must be reassessed after compiler01's lazy demand gate. A summary tree or let
suffix plan could remove overlapping scans more broadly, but it requires carrying
new state through substitutions and generated temporary terms. These remain
larger follow-ups; the proposed set insertion is the strongest compact step
identified by this audit.

## Correctness argument and reviewed controls

The independent reviewer verified that `nc_uses_term`/`nc_uses_list` are mutually
called and entered through `nc_uses`; no production caller provides a legacy or
arbitrary use index. Every key has exactly the same singleton marker bucket.
Thus generic replacement of a duplicate produces a structurally identical tree,
and returning the old tree preserves even complete summary equality. Exact U32
keys avoid hash collisions. Raw malformed Var nodes remain leaves, and all
environment order/duplicates, drop/share strings, errors and fresh IDs are intact.
This invariant does not cover direct forged calls to internal helpers with a
different marker or imported index; no such new public contract is claimed.

The reviewed [paired controller](../../selfhost/tools/performance/phase70/compiler-work/run-occurrence-set-controls-v1.mjs)
uses [38 terms, 67 IDs and six environments](../../selfhost/tools/performance/phase70/compiler-work/occurrence-set-controls-v1.mjs).
It compares complete summary indexes and all ordered partition/share results
across actual checked B1 images, with an independent membership/string oracle.
It covers full-bit prefixes, zero/MAX, unique and duplicate-heavy terms, two
matcher branches, lambda variants, metadata, malformed Var children and deep
syntax. Poison inputs check empty-environment and unused-second-share non-demand.

Append-only observation wrappers count calls to the unchanged original index
closures immediately around `nc_uses`. They require unchanged `index_tip` counts,
no extra leaf/insertion work, strict duplicate improvement, and identical work
on all-unique keys. The 64-copy single-ID witness should require zero replacement
inserts in the candidate. Instrumented clocks earn no speed credit.

The reviewer found no source or method blocker. Root still binds the selected
images to their checked build receipts and runs the controller under its guard:

```sh
node selfhost/tools/performance/phase70/compiler-work/run-occurrence-set-controls-v1.mjs \
  BASELINE_B1_API CANDIDATE_B1_API selfhost/build/phase70/FRESH_OCCURRENCE_SET_CONTROLS
```

Next gates are a checked build, these helper controls, complete-C equality and a
small balanced B1 screen against compiler01. Only a surviving result warrants
fresh B2 clocks. This lane made no production edits, imports, target runs or
commits; root owns integration and execution.
