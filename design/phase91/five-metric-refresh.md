# Phase91: refresh the five-metric scoreboard

The installed Phase90 compiler is the subject; no optimization or upstream
migration is planned. Follow the metric definitions in
[Phase66](../phase66/upstream-and-five-metrics.md), separating emitter target,
compiler host, generation and request/whole-process clocks. All ratios are our
time divided by the same-campaign pinned TypeScript reference time.

## Plan

1. Freeze the checked B1, genuine B2, installed release, source and upstream
   identities. Preserve unrelated work and all historical evidence. Reclaim only
   explicit obsolete raw duplicates verified against committed capsules if space
   requires it; keep restoration instructions and a receipt.
2. Emit the original 23 JS benchmark sources and 12 C benchmark sources with
   both current compiler roles. Compare complete JS modules with the qualified
   Phase66 output. For C, preserve the Phase78 baseline and check complete O3
   preprocessing under the same flags: Phase90 deliberately changed indentation
   and two runtime clauses. Byte equality is preferable; token equality supports
   unchanged compiled behavior under that precise configuration, not a fresh
   wall-clock speed claim or coverage of every backend configuration.
3. Run fresh balanced requests against pinned TypeScript using the original
   JS23 and C3 corpus and host policy. Record absolute samples, import and request
   clocks, role hashes and complete-output checks. Use three balanced rounds
   initially, and increase only if observed variation prevents a useful answer.
   B1 and B2 must both be independently measured. Do not substitute the recent
   six-source TS/Bun/native screen for these historical Node-hosted comparisons.
4. Refresh the manifest-only Bend/source and separate host/runtime/image census.
   Inventory current qualification and old conformance boundaries. Run bounded
   broad conformance checks where feasible; explicitly distinguish fresh tests,
   exact unchanged-source continuity and historical unrerun scopes.
5. Publish a single report and machine-readable scoreboard with current versus
   carried-forward versus unmeasured labels. Retain failures, summarize execution
   time and evidence recovery, commit and push. No PR comments.

## Execution policy

Root alone launches target processes, serially under the established execution
lock and resource guard. Three offline agents prepare continuity, timing and
conformance/census methods. CPU3; ordinary target tree limit 2 GiB RSS, at least
4 GiB available memory, bounded deadlines, no core dumps. Maintain at least
160 MiB disk reserve. Do not rebuild the compiler or repeat self-hosting unless
an actual identity or correctness failure requires it. Avoid redundant program
runtime campaigns when complete output identity already answers regression.

A timeout, mismatch or unsupported input remains in the denominator. If an
output changes beyond the documented formatting/runtime edits, inspect the
smallest differing case, run its correctness/runtime control, then decide the
necessary larger validation. The phase must not quietly turn into an optimization
or alter the installed compiler to improve a score.

## Completed outcome

[Report](../../implementation/phase91/README.md): all70 original-corpus output
comparisons and234 fresh timing checks pass. Current B2 request ratios are
1.306596× JS23 and1.230042× C3. Fresh native100 passes, while the full frontend
finds one exact diagnostic mismatch (3173/3174 agreements). Isolated controls
show the old and current B2 error-page printer exhaust the4MiB stack; current
B1 and TS print the full diagnostic. Invalid proof rejection agrees. Preserve
this qualification failure; no compiler or stack-setting workaround was made.
