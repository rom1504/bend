# Phase87: make native compiler work measurable and repairable

The user selects native compiler execution as a worthwhile optimization target.
Phase86 established a current checked native B1 but exposed a Map sharing
fail-stop, Lexer request growth, costly Base preparation and a 259-second image
build. Investigate mechanisms with cheap experiments before integrating changes.

## Questions and discriminators

1. **Map correctness.** Minimize the observer continuation's `rfc_wrap` failure.
   Compare typed/untyped forwarding and eager closure construction versus direct
   branching. Check every source with pinned upstream; preserve successful and
   failing C/JS executions. Never disable runtime ownership checks. Distinguish
   our unsafe source behavior from a demonstrated upstream compiler bug.
2. **Native cost and request growth.** Reuse the existing Phase68 CPU sampler on
   the exact Phase86 executable. Require thread/process CPU coverage and exact
   C output. Separate Base preparation, first request and later requests wherever
   supported by the profiler. Symbol-only samples are sufficient to nominate
   functions; no invented inline attribution without debug information.
3. **Representations and fast fixes.** Inspect measured native string, sharing,
   allocation and generated-code paths. Use small inputs or reversible saved-C
   diagnostic derivatives to falsify causes. A faster diagnostic derivative is
   evidence for a source change, not a production compiler or correctness proof.
4. **Native-first development.** Measure which checks can run in seconds, then
   reserve a full checked native compiler build for a candidate with a concrete
   mechanism and successful small controls. Prepare a ranked native roadmap,
   including Base loading, complete host behavior and eventual native B2.

## Method

Keep the Phase86 native B1 and ordinary Phase82 B2 as immutable controls. Pin the
upstream checkout at0592662 and authenticate libraries, compiler images, sources
and generated output. Record whole commands, failures, CPU affinity, time and
memory. Separate clean timings from sampled/instrumented runs. No single-family
gain or successful-only average establishes broad native parity.

Root alone runs targets, serially. Reuse the Phase86 guard: runtime2GiB RSS with
4GiB available-memory floor; Node1GiB heap/4MiB stack. Full optimized Clang builds
may use the measured6GiB cap only with16GiB headroom. Check disk before generated
images (initial484MiB free); never unpack or regenerate historical corpora.
Two bounded agents inspect Map/source costs; they do not run targets.

Use Phase87 files for new hypotheses/evidence and retain rejected attempts.
Production modules, upstream sources and installed images remain controls during
this investigation. A source-level candidate may be built in an isolated assembly.
Conclude with demonstrated fixes/opportunities, uncertainty, expected gains and
implementation effort. Commit/push design, methods and report under the standing
authorization; no PR comments.
