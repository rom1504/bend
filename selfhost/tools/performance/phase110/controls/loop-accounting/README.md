This version adds clocks to the exact prepared `selfhost/build/phase110/train01`
harness. The original eleven fixtures, ABI header and expected observations are
copied byte for byte. The seven original search training workloads are listed
in the manifest; invoke each by its existing CLI name and repetition argument.
No graph caching, reuse, sharing, reduced observation or changed lifetime gate
is introduced. No compiler or target was run during preparation.

The original `double begin = now()` and `worker_seconds += now() - begin`
statements and worker call remain unchanged. Each stderr JSON retains `name`,
`repetitions`, `workerSeconds` and `maxBumpWords`, adding one versioned accounting
record. Its integer-nanosecond phases cover context open; graph and alias setup;
the worker envelope; scratch-pending check; result and post-release alias
observations; result/alias releases; bump/live accounting plus context close;
and repetition checks, loop overhead and first-result stdout formatting.

The worker envelope includes the original two clock calls and adjacent clock
bookkeeping. The original workerSeconds is the narrower measured quantity.
Alias observations and drops remain interleaved exactly as before, so clocks
sum those disjoint intervals. Phase-boundary accounting overhead is charged to
the following phase. This diagnostic can perturb timing, especially tiny
operations; it is not a replacement policy-ranking measurement.

A continuous phase ledger must equal the independently subtracted first/last
partition marks exactly. Separate outer marks surround that interval and expose
entry/exit residual. Both identities are required by the C harness and checked
again from saved JSON by `check.py`. The outer clock stops before final stderr
formatting and does not include process startup, main's case selection, final
stdio flushing or teardown. Supply independently measured child-process wall
time to `check.py --process-seconds` to expose those costs separately; do not
attribute the full process-minus-worker difference to graph setup.

Root links the prepared harness with the same cached worker/runtime objects
and records their identities in the execution receipt. After collecting the
seven stdout and stderr records (one per case), run `check.py --prepared DIR
--stdout STDOUT --stderr STDERR --out FRESH_REPORT`; use repeatable `--case`
arguments for a subset. This checker only reads saved outputs. Source provenance
and the full instrumentation delta are pinned in `manifest.json` and
`harness.patch`.
