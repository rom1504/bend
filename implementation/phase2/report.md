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

Fresh differential witnesses are being run against the pinned TypeScript APIs
and explicit checked Bend APIs. One initial hypothesis is already falsified:
although the frontend accepts an explicit arrow in a law fill, the downstream
signature guard rejects a changed return type. There is no demonstrated type
signature override. A redundant same-type arrow is still an invalid acceptance
relative to upstream syntax and merits a compatibility fix.

Targeted harness, native graph hosting, broader validation and final timings will
be recorded below as they complete. No whole-suite conformance or native
self-hosting claim is made by this interim report.
