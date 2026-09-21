# Phase 2 implementation report

Work began on 2026-09-21 at 14:10 UTC, with a 17:10 UTC cutoff. This is a
progressive report; later sections record completed validation rather than
assuming every design objective has passed. The
[design](../../design/phase2/fast_conformance_loop.md) was committed and pushed
as `9e7a56d` before implementation.

## Starting baseline

The historical frozen phase 1 corpus has completed all 6,019 probes across 1,378
fixtures. Its `coverageComplete` is true and its conformance `complete` is false.
The [compact archived summary](evidence/phase1-completed-corpus-summary.json)
records the exact compiler, runtime and host identities and hashes the complete
local report. This is the older H4 compiler, not a phase 2 candidate.

All 919 positive check probes accept. The strict check lane reports 1,001 passes
and 377 failures; many failures concern diagnostic or rejection-phase differences,
so this is not a count of 377 invalid acceptances. All 459 negative check
observations retain the earlier behavior. Seven observations changed: three
native timeouts, two borrowed-list JS/IO interpreter failures, one native stack
fault with missing output, and one diagnostic presentation change. GPU probes
remain hardware-gated.

## Runtime host corrections

Fresh probes reproduced the borrowed-list and native stack-fault failures with
the phase 1 checked B1 compiler (`37ebe8ae…`). They have distinct causes:

* The conformance worker had an explicit 4 MiB Node stack, while its generated
  JavaScript child used Node's smaller default. The identical emitted
  `reg/borrow_fork_hold.bend` program prints the required `2003000` when launched
  with the worker's 4 MiB setting. The typed driver now propagates only explicit
  stack and old-space limits, and records them in runtime results. It does not
  forward evaluation, loader or debugger options. This is a host resource-policy
  correction, not a compiler optimization or a general elimination of stack
  limits.
* The native SIGSEGV/SIGBUS handler called `err_post`, then buffered stdio through
  `err_fail`. Replacing those operations with a fixed `write` and `_exit` makes
  the overflow print the required diagnostic and exit 1. The handler now uses
  only async-signal-safe operations. This removes a demonstrated failure path;
  it does not prove every possible signal delivery scenario on every platform.

The two unchanged pinned fixtures pass all six fresh interpreter, JS and native
probes after the changes. In particular, the extreme-depth fixture still fails
loudly with its required message and exit status; giving JS the declared stack
does not turn that negative execution into success. Dedicated subprocess tests
also verify resource-option propagation and exclusion of execution options.

## Frontend investigation

Fresh differential witnesses were run against the pinned TypeScript APIs
and explicit checked Bend APIs. One initial hypothesis was falsified:
although the frontend accepts an explicit arrow in a law fill, the downstream
signature guard rejects a changed return type. There is no demonstrated type
signature override. A redundant same-type arrow is still an invalid acceptance
relative to upstream syntax and is now rejected.

The three frontend modules now enforce four existing upstream rules:

* A definition filling a law uses plain parameters followed by `:`, with no new
  return annotation.
* Template `~` law clauses form a leading prefix, before ordinary or erased
  clauses.
* Local assignment patterns pass the same constructor/binder validation as
  match patterns, including braces and field counts.
* Imports precede declarations and cannot follow an `@unsafe` decorator. The
  current top-level grammar only adds declarations to its initially empty book;
  this invariant makes the empty-book test an exact import-region boundary.

The [before](evidence/frontend-before.json) and
[after](evidence/frontend-after.json) reports retain 21 live differential cases:
12 negative witnesses and nine valid controls. Nine invalid acceptances are
closed, two rejections move from checking to the required frontend phase, and
one existing frontend rejection is preserved. All nine valid controls continue
to accept. Exact diagnostic text remains a separate obligation. The changed-type
law example belongs to the phase corrections, not the invalid acceptances.

The final focused matrix took 9.064 seconds with a reused API and warm Base cache:
6.854 seconds in candidate calls and 1.965 in reference calls. The before matrix
took 28.488 seconds, partly because invalid syntax reached later expensive gates;
that difference is not a general compiler speedup. Initial witness authoring
also exposed two invalid positive controls; those were corrected rather than
weakening the language rules, and the earlier local attempt is retained.

The [checked bootstrap](evidence/frontend-bootstrap.json) identifies API
`8ae7a4cebb236c2bf83863417d433093b858f2831b6a32d8823ebf52f271eff1`
and assembled source
`2f0b4956987479763c0d2a4d06dfc5a17dd96dac5126ad72266b7347e8feb635`.
The independent [component verification](evidence/components.json) passes all
19 groups, including the dependent checker, diagnostics, index, loader, prefix
cache, freshening, specialization and primitive runtime. Its checked build and
all tests took 34.596 seconds on CPU 1; this is a single observed development
cycle, not a repeated benchmark median.

A frozen full checked self-emission/fixed-point run has started on CPU 1. It is
independent of the targeted loop and is not counted as passed until both emitted
stages finish and their hashes agree.

Targeted harness, native graph hosting, broader validation and final timings will
be recorded below as they complete. No whole-suite conformance or native
self-hosting claim is made by this interim report.
