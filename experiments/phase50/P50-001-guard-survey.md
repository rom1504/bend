# P50-001: do fresh entry checks dominate other programs?

Information-only survey requested after Phase49. No compiler changes, generated
program edits, guard bypasses, rebuilds or promotion. Current compiler is RNFA04.

Screen all 45 maintained points (23 sources), using exact retained RNFA04 outputs
and original complete-result oracles. Reuse `programs/profile.mjs`, which supports
string results as well as numbers. Each independent process warms for at least
1 second, then samples CPU for 800 ms. Root runs serially on CPU3 with the existing
1 GiB heap / 2 GiB tree RSS / 4 GiB memory-headroom guard and 64 MiB output limit.

Hypothesis: the RLE diagnosis generalizes to small public calls, but larger
computations amortize checks and expose different costs. Report exclusive named
guard self samples separately from guard-ancestor samples, GC, anonymous entry
frames and actual work. Samples are estimates, not exact timers or causal gains.
Keep Phase48 clean ratios historical; do not manufacture fresh speed ratios from
instrumented durations.

Adaptively profile allocation and inspect V8 opt/deopt/inlining traces for a few
non-guard-dominated points, comparing unchanged TS-generated modules where useful.
Use filtered optimizer graphs only if they resolve a remaining concrete question.
Preserve every failure. Aim for a brief investigation, not another optimization
campaign. Outcomes go in `implementation/phase50/README.md` and retained evidence.
