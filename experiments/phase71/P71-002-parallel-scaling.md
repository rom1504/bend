# P71-002: does the native target preserve useful balanced parallelism?

Prospective hypothesis: whole-workload parallel throughput has not been measured
by prior CPU3/threads1 campaigns. Generate a deterministic balanced fork-join
numeric workload from final checked B1 and pinned upstream, independent Python
arithmetic oracle. Compile with identical Clang flags. Compare1/2/4physical
cores, same work per role; report end-to-end binary time and1→p speedup.
Pin topology and actual affinity, not merely --threads. Use sufficiently large
leaf work to separate scheduling overhead from startup; preserve all trials.
Inspect generated C forks and private leaf routing before interpreting scaling.
No changes to installed compiler, no GPU extrapolation and no universal speedup
claim from one balanced workload. If hardware quota/host noise prevents scaling,
record that limitation rather than changing the denominator.

Result: corrected source with4000000steps/leaf passes18/18qualified intervals
in parallel02. Candidate547/278/146ms matches upstream546/277/146ms on1/2/4cores;
3.75×four-core scaling. Initial short parallel01 retained as calibration, not a
qualified result. Allocation-heavy/GPU/imbalanced workloads remain untested.
