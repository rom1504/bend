# Phase55 constructor-query admission plan

This plan schedules no targets and changes no Phase54 artifact. Root owns CPU3 and every compiler invocation. Baseline is the frozen Phase54 `checked-graph02` B1 API (`d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`), not a newly rebuilt old source.

The exact old `j_find_ctor` contract is one level of child lookup per owner, in owner order. It returns the first child lookup result whose kind is not `Absent`, without requiring `Ctr`. Child lookup uses the first exact matching name, except a leading `BookCache` makes its index authoritative. Root definitions themselves and grandchildren are not constructor-query candidates. A matching `Absent` child shadows later children in that owner but lets the next owner win. A plain `Missing` child is not `Absent` and wins. Preserve complete KDef values, binder/type metadata, and immutable input; a name-only comparison is insufficient.

The Phase22 parser constructor-index corpus is useful prior evidence but cannot be substituted: `f_ctor_lookup` recurses through nested definitions and uses a different missing sentinel. Its generic BookCache descendant test deliberately has different semantics. Reuse its full-hash collision names `costarring` and `liquid` only after asserting the hash collision, not its expected winner rules.

A small independent query gate should freeze these cases before any candidate execution:

| Case | Independent expectation |
| --- | --- |
| Empty book | Exact `missing()` KDef |
| Owners with no children | Exact `missing()` KDef |
| One immediate child hit | Complete original child value |
| Top-level name matches only | Missing; no top-level constructor match |
| Grandchild name matches only | Missing; no recursive descent |
| Duplicate child names in one owner | First matching child |
| Duplicate child names across owners | First non-Absent child result from earliest owner |
| Duplicate owner names | Both owners still searched in list order |
| Absent owner with ordinary children | Children still searched; owner kind does not filter |
| Matching Absent child then same-name child | Second child hidden; next owner may win |
| Matching Missing-kind child | That child wins; do not treat all missing-looking kinds as Absent |
| Matching non-Ctr child | That child wins |
| Empty constructor name | Exact-name behavior preserved |
| Unicode names | Exact String equality preserved |
| Full hash collision | Both exact names return their own original full values |
| Reversed owner order | Winner reverses exactly with source order |
| Real `book_cached(book, bound)` | Candidate equals baseline query of this actual cached book |
| `book_context(book)` and reuse | Full lookup equality; context remains unchanged after queries |
| Recontextualize an existing context | Same metadata/idempotent shape; preserve maximum binder bound |
| Different immutable books queried alternately | No cross-book cache reuse or stale winner |

Run fixed cases against both role-specific checked API images using a saved diagnostic export that calls the actual private `j_find_ctor`. Never replace its body with a JS implementation. A baseline B1 wrapper may use its existing `run_loop`; a direct-image wrapper must call the actual direct function and must not import the baseline trampoline. Pin each original API, exact appended suffix, parsed private symbol, selected attempt, Node, queries source, and result report; record that the export derivative is diagnostic and does not change production ABI. An independent JS oracle implements the old one-level scan and exact Absent rule. Compare complete returned values and input snapshots, plus repeated context queries. Plain input identity is a useful witness; do not promise host getter-demand equivalence for a newly eager immutable context index.

Fast admission order after a candidate image is generated:

1. Run the small query gate above against graph02 and candidate, preserving every mismatch.
2. Run the eight maintained ordinary-driver suites against that actual image, using the existing explicit legacy selectors. This checks image loading, checking and ordinary backend behavior, rather than only a synthetic lookup.
3. Reuse Phase54 fixed source acquisition/strict methods unchanged in fresh Phase55 paths: source96, numeric34, composition18 and genuine overapplication2. Phase54 source/oracles are frozen. The census needs a new root-only derivative of its preserved Phase54 method because it restricts output paths to Phase54; no test or expectation changes.
4. Acquire the fixed production45 through unchanged `phase53/acquire.py` with explicit `--node`, CPU3, heap1024/RSS2048/floor4096. Compare to `build/phase54/semantic-final02-completion01/production-js45/manifest.json`, joining checked output/source/API/runtime/driver receipts and exact complete-row observer. Phase54 comparator hard-pins allowed old baselines; create a Phase55 baseline-policy successor, preserving its exact byte and receipt checks. Do not relabel the old tool as accepting graph02 when it does not.
5. Native retention keeps the same three Phase54 sources and CPU goldens (63; 8; 690/1), compares complete emitted C against graph02, and builds/runs both roles with the maintained Clang16 CC/CPATH/LIBRARY_PATH/LD_LIBRARY_PATH. The inherited Phase54 native controller hard-pins Phase53 release provenance; it needs a narrowly derived Phase55 baseline-policy successor. No arbitrary normalization of changed output.

Do not repeat runtime669 samples if all fixed outputs are byte-identical and source/runtime identities are preserved. Compiler image generation completion, actual image/ordinary-driver checks and the timed-out direct generation fix are separate mandatory outcomes; a query microgate alone does not establish them. Keep the existing 103 unrelated protected files unchanged. Root decides release/install only after exact-image evidence is complete.
