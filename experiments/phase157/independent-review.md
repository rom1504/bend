# Phase157 independent comparison review

Read-only source/receipt audit, 2026-11-04. No compiler, generated program or
benchmark was executed by this reviewer. The source transport was prepared
earlier by this agent; this review independently checks root's acquisition,
compatibility, oracle, scheduling and reporting methods, not independent
authorship of the workload itself.

**No blocker was found in the admitted three-role comparison.** `measure02`
completed its whole balanced block, after-oracles and input verification: all 36
calls pass and the duration gate is resolved. Its resource guard completes with
exit zero. The RC role failed its output gate and supplies no performance
comparison.

## Same source, actual input and complete output

All admitted roles (`upstream02`, `qbe02`, `gc03`) bind the identical
387,345-byte compatible source, SHA256
`a926e00c75df0bc2b5c49eaccdb8cd98eb21a4b461592891338e4178fe65cca1`.
Their Base identities agree on 75,064 bytes, SHA256
`99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.
The measured captured book is the established 2,979,167-byte Phase154 input,
SHA256 `15f41031b1f89fe4add47cadbb80badbe677798ebd4c42638f17efd42fa502d4`.

Whitespace compatibility is supported by actual downstream evidence:

- Both upstream emission receipts independently report checked success and
  identical 7,250,618-byte C, SHA256
  `c94c12900e15fe34f5ff798da47478f232786176a3eb75c8d324fb56372412d8`.
  Reusing the original upstream executable after exact C equality is justified;
  it is not a fresh machine-construction timing.
- `qbe01` and `qbe02` report identical QBE, assembly and object bytes. Their ELF
  hashes differ; do not claim complete executable identity. The normalized
  `qbe02` executable is explicitly selected for measurement.

The exact 173,582-byte stdout oracle is pinned to SHA256
`9c08e21b3f5eac0bf17c1be4fcb76fe1fda79f8faadbf99469dfb03c3399f82e`.
It is the retained concatenation of five original admitted Phase154 compiler-owner
outputs. It is not a checksum-only expectation, nor a newly successful bendc
output adopted as the reference. All three admitted roles pass this complete
oracle in `measure01` and again before timing in `measure02`.

The five owners, captured metadata, original producer/scalar transform,
independent final verifier and complete renderer remain in the computation.
The source loop computes each result inside the iteration and immediately feeds
the complete string to error-checked `File.write` before proceeding. Runtime
repetition count is parsed from arguments; no lowered-output cache or embedded
QBE result exists in the transport. This is five retained legacy direct-helper
pipelines, not the selected compiler's whole source/check/lower/emission path.

## Backend policies, effect bridge and argument fairness

Upstream C and bendc C use the same pinned Clang and `-std=c11 -O3` construction
policy. Qualified QBE uses its own pinned assembler/linker/runtime route. These
are different complete backend/runtime bundles; the comparison cannot isolate
GC, instruction selection, representation or calling convention by itself. It
also does not establish the best possible bendc performance under every optional
compiler flag.

bendc GC emission explicitly uses `BEND_RC=0`, `BEND_AUTO_PAR=0`,
`BEND_NO_FREE=1`. The last setting disables early match freeing; it does not
disable tracing collection. RC emission uses `BEND_RC=1`, `BEND_AUTO_PAR=0`
without the no-free setting. Runtime execution clears `BEND_*`, `LD_PRELOAD`
and `LD_AUDIT`, so policy selection encoded into generated code must not be
confused with runtime environment toggles.

The experiment's ABI bridge is material and must stay visible. I compared the
original and adapted C for GC and RC: each differs by exactly nine additions of
the third argument `0` to registered `io_eff` calls, with no other C changes.
In the pinned runtime this means immediate callback dispatch; the old Base's
file callbacks themselves arrange their work through `io_work`. This is a
reasonable bounded compatibility bridge for the exercised file/argument effects,
supported by full successful GC output. It is not general compatibility proof
for all effects or a claim that unadapted bendc accepts this old Base.

The common `bash` wrapper replaces itself with the target using `exec -a
compiler-work`. Upstream/bendc receive the sentinel through argv[0]; QBE gets it
as an explicit program argument because its IO.args omits argv[0]. Exact oracle
success exercises the common argument parser and confirms the intended logical
arguments. All roles receive one runtime worker and GPU-off flags. The measured
parent affinity is `[3]`; runtime helper/IO threads may still exist on that CPU.

## Timing boundary and interpretation

`selfhost/tools/build/common.py:run` uses the same fresh-process launch, monotonic
whole-child elapsed boundary, wait4 user/system CPU and peak RSS for every role.
Output hashing/comparison occurs outside the child clock. Startup, complete input
decoding, authentic metadata setup, repeated owner work, writes and ordinary
process teardown are charged. Timing `/dev/null` writes still consumes the full
rendered string; empty timed stdout is not used as its correctness oracle.

Normal teardown does **not** mean every runtime is forced to collect every dead
object before exit. Each retains its ordinary GC/ownership policy and the OS
releases the exiting process. This is appropriate for whole-process comparison,
but it is not equalized final collection work or a leak-freedom result.

The three-role runner calibrates one common count, then uses all six role
permutations. Each role occupies each position twice. Before/after exact-output
controls and calibration are excluded from the timed median, but retained and
charged to campaign cost. Source/input/binary/receipt identities are reverified
before successful completion. Report the observed spread, not a confidence
interval or general compiler speedup.

**Work count changes the ranking.** Initial `measure02` controls take about
0.623s upstream, 0.968s GC and 1.295s QBE for one repetition. Zero-repeat setup
takes about 0.253s upstream, 0.476s GC and 1.019s QBE. Calibration at sixteen
repetitions takes about 6.600s upstream, 13.966s GC and 5.945s QBE. These are
controls/calibration, not the final balanced medians. Their reversal means the
final sixteen-repeat ranking describes repeated-owner throughput in a fresh
process, not cold one-request latency. Present both boundaries without subtracting
startup into a purported whole-process gain.

The completed six-order block at sixteen repetitions reports:

| Role | Median wall seconds | Median CPU seconds | Maximum child RSS (KiB) |
| --- | ---: | ---: | ---: |
| upstream C | 6.491450 | 6.490121 | 114252 |
| qualified QBE | 5.935447 | 5.934153 | 83372 |
| adapted bendc GC | 13.823576 | 13.821917 | 1214048 |

Wall and CPU medians agree closely; this supports a real difference in executed
work/policy for this workload rather than a large scheduling-delay explanation.
It does not attribute the cause to any one compiler pass or allocator. Whole
campaign elapsed is 203.678s; its guard observes 1,260,032,000 bytes of peak
process-tree RSS and a minimum 5,510,017,024 bytes of free disk. These are separate
from per-child RSS and executable acquisition costs.

## Retained failure and bounded method corrections

`measure01` fails at RC's first oracle: exit 1, empty stdout and
`bend: runtime fail-stop` on stderr. Preserve it as a rejected execution lane.
The new three-role campaign explicitly excludes it after this gate; it is not
a silently dropped slow observation. This does not locate the failure in RC
code generation versus the runtime/effect bridge, and does not establish that
all bendc RC programs fail. No GC-versus-RC speed ratio is supported.

The following are reporting or future-runner corrections, not findings that
invalidate current successful observations. Do not mutate a running pinned method.

- `measure.py` checks remaining campaign budget before each call but gives the
  child a fixed 30s deadline. A child may therefore overrun the campaign limit by
  up to 30s; the outer guard remains the hard bound. A successor should use the
  lesser of the child cap and remaining time, as the method document prescribes.
- The inline argument comment says other runtimes omit argv[0], whereas the
  actual branch distinguishes QBE from upstream/bendc. Correct the comment in a
  successor; the tested command routing is correct.
- `normalization.json` remains a preparation record with
  `upstreamCEqualityPending:true`. Cite the subsequent completed upstream and QBE
  receipts rather than presenting that preparation field as current status.
- Acquisition reports do not all enumerate every transitive method/header/effect
  file directly in their `inputs`. The final capsule must retain the pinned
  vendor manifest/header, relevant Base effects, source, generated/adapted C,
  method versions and acquisition receipts. The experiment's current artifact
  identities are explicit; do not claim a stronger per-build historical
  input-stability check than the acquisition runner actually performed.

The publication fallback remains unexecuted prepared evidence. No full compiler
bootstrap, installed selection change, general conformance or memory-safety
qualification follows from this experiment.
