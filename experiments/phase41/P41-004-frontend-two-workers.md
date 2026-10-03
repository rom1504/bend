# P41-004 — Two-worker frontend validation gate

- Status: fresh two-worker main and broader correctness gates pass on Phase41 checked01; final integration audit pending at this checkpoint.
- Baseline: frozen Phase40 frontend gate and existing reference acquisition; candidate comparison starts from the exact Phase41 checked image if compiler changes are promoted.
- Design: [validation latency proposal](../../design/phase41/validation.md). Current evidence: [validation implementation record](../../implementation/phase41/validation.md).

**Hypothesis.** Exactly two persistent candidate workers can reduce frontend correctness elapsed time while retaining all 3,026 main and 196 broader comparisons, the established observations, exact path/layout comparisons, worker health checks, and the frozen four-worker reference.

**Cheapest disproof.** Run main and broader serially with the reviewed successor and required aggregate resource bounds. Reject the scheduling change if counts, outcomes, health, or exact comparisons differ; if the run exceeds its bound or cannot stay within memory/CPU limits, preserve the failure and return to the unchanged one-worker gate. Do not drop cases or relax the oracle.

**Observed outcome.** Fresh Phase41 checked01 agrees exactly on3,026 main and196
broader rows with zero differences, two healthy candidate workers and the frozen
four-worker reference. Main preserves2,525 pass /497 observed /4 shared failures;
broader preserves195 pass /1 observed. Both enclosing supervisors complete with
return code0, no stop reason, no worker timeout/failure and no reported OOM.
Main takes413.647seconds at1,175,924,736bytes peak tree RSS; broader takes23.382seconds
at978,124,800bytes. Both remain within the3GiB aggregate ceiling and2GiB available
floor. The final audit remains separate and pending at this record.

Historical Phase40 final-plan02 enclosing wall was784.390seconds main and37.354seconds
broader. Main's observed reduction is47.265% (370.743seconds); broader37.405%
(13.972seconds). Serial total falls821.743→437.028seconds, saving384.715seconds
(46.817%). This compares different checked images, one worker/CPU3 versus two
workers/CPU3,4; it is a historical workflow comparison, not a controlled same-image
worker A/B experiment or evidence of a causal worker speedup. Program timings and
compiler costs are separate outcomes.

[Receipt-derived canonical statistics](../../implementation/phase41/validation.json)
include exact input hashes and both generations' reports. [Current main gate](../../selfhost/build/phase41/integration01/final-plan/frontend-main/report.json),
[main bounded execution](../../selfhost/build/phase41/integration01/final-plan/run-frontend-main/run.json),
[broader gate](../../selfhost/build/phase41/integration01/final-plan/frontend-broader/report.json)
and [broader bounded execution](../../selfhost/build/phase41/integration01/final-plan/run-frontend-broader/run.json)
remain preserved. Correctness supports retaining the reviewed two-worker workflow;
final audit/promotion still require their separate gates.
