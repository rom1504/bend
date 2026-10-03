# Checkpoint 05: bounded recursion in actual compiler output

The checked14 candidate emits budgeted native recursion inside an already
admitted private flat graph. Its budget is 16; budget zero delegates to the
unchanged iterative worker before evaluating any source prefix. Intercomponent
cycles are already excluded by the original full dependency proof, so resetting
the budget across components cannot create input-dependent native stack depth.
The implementation adds 56 net physical lines, reusing the typed structural
emitter and original fallback body. Public workers remain unchanged.

Actual checked13 versus actual checked14 output, three balanced short-screen
rounds, milliseconds per invocation:

| Tree depth, seed | checked13 | checked14 | Pinned TypeScript | Incremental speedup | Candidate / TS |
|---|---:|---:|---:|---:|---:|
| 8, 0 | 0.647930 | 0.442217 | 0.316952 | 1.47× | 1.40× |
| 6, 17 | 0.105213 | 0.076815 | 0.038534 | 1.37× | 1.99× |
| 9, 123 | 1.350673 | 0.838008 | 0.685509 | 1.61× | 1.22× |

These are actual compiler outputs, distinct from the earlier manually derived
hybrid experiment. The additional hybrid controls pass complete Tree/Stat and
asymmetric/alias checks; the 30,000-depth witness records exhausted-budget entry
to the iterative fallback. All four fallback bodies are byte-identical to the
previous iterative bodies. The separate full flat-layout suite also passes its
20 complete values, 98 owned observations, 68 boundaries, and two deep controls.
See [prototype-summary06.json](prototype-summary06.json) for exact receipts,
samples and ranges. Final broad admission remains pending; Phase41 is installed.

The actual native-Nat suite passes ten independent values and nine boundary
families: exact limits and overflow, binding/code/getter/metadata changes,
post-import primitive replacement, and Error callback reentry. TypeScript's
string exception ABI is recorded separately from our existing Error ABI.

A controlled compiler-cost screen on checked13 has mixed results. Tree request
median drops from 2492.64 to 2242.56 ms (10.03%); list rises from 2000.80 to
2241.45 ms (12.03%). All 18 fresh requests produce the independently acquired
exact outputs. This measures the combined candidate, not causal attribution to
the cache alone. The final selected compiler still requires the four-case cost
gate; the list increase is an explicit cost to assess alongside generated speed.
