# Native occurrence summaries

The Templates05 profiles expose repeated whole-term occurrence queries as the
largest remaining native compiler cost. B2 `nc_occurs_list` has 528/543/672 ms
self samples for Numeric/Array/Lexer; B1 Numeric has 1,322 ms inclusive occurrence
time in a 3,125 ms diagnostic request. The clean one-sample B1 requests regress
from 2,137/2,018/2,569 ms in Phase67 to 2,627/2,676/3,353 ms, while B2 improves
from 1,921/1,845/2,300 to 1,570/1,582/2,086 ms. These different campaigns and
intervening native changes do not isolate a template gain. Worker06's separate
B1 acquisition clocks are roughly 3.00/3.16/3.93 seconds.

`nc_lower_to` asks both `nc_drop_dead(env,t)` and `nc_live_env(env,t)` to scan the
same term for every environment binding. Other lowering paths repeat these
queries and use `nc_share_env` to scan two bodies for each binding. A term with
T nodes and E environment rows costs O(E×T) per operation before recursive
lowering revisits its subterms. Fusing only two traversals would retain this
algorithmic problem.

## Change

Walk the term once to collect occurrence IDs, then use indexed membership for
environment decisions. Reuse the existing compressed persistent `KDef` index:
pass the complete U32 ID as the explicit index hash and store the same fixed,
nonempty name in every bucket. `index_find` checks the entire stored hash before
the bucket name, so every U32, including 0 and 4,294,967,295, remains distinct.
No stringification, new hash function, new set implementation, public export or
persistent cache format is needed. One shared marker definition is created per
collection, rather than one per variable occurrence.

The collection has exactly the old `nc_occurs` policy: a `Var` contributes its
own ID and is a leaf even if a malformed raw term has children. Every other
term visits all `ks` children, including annotation/metadata children. Binder
IDs on non-Var terms do not count and do not shadow child IDs. Compact literals
contribute no children. This is occurrence membership, not a free-variable
analysis with scope subtraction.

`nc_live_env`, `nc_drop_dead` and `nc_share_env` retain their names and output
contracts but query one summary per input term. An internal ordered partition
returns live rows and sink text together for `nc_lower_to`, sharing one summary
and one membership decision per environment row. Environment order, duplicate
IDs and duplicate words are preserved; summaries do not deduplicate output rows.
Empty environments return immediately without touching the term. Sharing first
filters bindings occurring in the first term; it scans the second term only if
that filtered environment is nonempty.

Expected cost becomes O(T×log V + E×log V), bounded by 32 hash bits, where V is
the number of distinct occurrence IDs. Repeated recursive lowering can still
collect overlapping subterms; this prototype removes the environment multiplier
without introducing a request-wide term-identity cache or changing native IR.
The old `nc_occurs` remains for raw differential controls and the parallel-use
consumer. `NC_Code`, target forwarding, ownership operations and emitted call
products remain unchanged.

## Validation and stopping rule

Register [P68-009](../../experiments/phase68/P68-009-occurrence-summary.md) before
production integration. First check source, then actual strict B1. Compare
old occurrence/live/drop/share results against the candidate summary and ordered
partition for ordinary and malformed finite terms, all U32 boundary bits,
duplicate IDs/words, absent IDs, literals, metadata and Var children. Include
empty-env non-demand and interleaved reuse to detect state mutation.

Then require complete C equality against the exact pre-change selected image
on the native families and existing ownership/error controls. The transformation
changes compiler analysis only; changed C is a failure. Run the short native
request screen for both B1 and actual B2, keeping profiles separate. Inspect
remaining occurrence time and summary allocation before broad qualification.
Keep or revise based on real request gains and resource costs, not an assumed
recovery of all inclusive profile time. Source changes remain isolated until
root selects and integrates them alongside the separate product lane.
