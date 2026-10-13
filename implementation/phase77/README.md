# Phase77 native parity work

Completed and installed. [Design](../../design/phase77/native-parity.md). Phase76 is the immutable
comparison baseline. The user permits explicitly reported temporary program-speed
regressions; correctness remains mandatory. The selected release is genuine self-emitted B2 `35d7a606…`; cold compilation parity remains open.

## B2 deployment checkpoint

The first checkpoint installed unchanged Phase76 compiler12 B2 (`29da003b…`). The maintained
release tool now supports `--install-b2` and verifies the original checked B1,
equality derivation, self-emission, driver comparison, own-source check and exact
B3 reproduction from local inventoried files. The previous B1 release remains
preserved. No forged checked-B2 metadata or new mathematical proof is claimed.

13 package controls pass, including relocation, changed bytes, missing source
bindings, false fixed-point and failed own-source evidence. Installed/relocated
legacy42 and default24 pass. See `selfhost/build/phase77/package-controls02/` and
`release02/`; installation is `release01/job-install/`. Failed initial control
imports and the old legacy launcher's B1-only assertion are retained. The new
smoke derivative changes only that stage assertion and its runner path.

Existing paired Phase76 request ratios imply31% less default C-request time from
choosing B2 (2.752x B1 versus1.908x B2). This is not an algorithmic optimization
and not a new timing run. Compiler-source optimization follows this checkpoint.

## Selected source and installed release

Compiler01 composes retained scalar bit-pattern rows/reconstruction with checked
host-body omission. B1 `f058269d…`, genuine B2/B3 `35d7a606…`. Paired45 fresh
requests give **2.77248x→1.92036x B1** and **1.92566x→1.48173x B2** upstream:
30.74%/23.05% less time. Combining stage selection with the source change makes
the new B2 request take46.56% less time than the previous B1 default in this
same comparison. These three IO-wrapper sources are a fast loop, not a full
application-distribution claim. See [measurements](measurements.json).

The measured twelve-family runtime aggregate is1.05491x upstream and1.01792x
previous compiler. This phase accepts a temporary1.8% aggregate regression:
expression14.25%,Array.map5.04%,Tree3.10%,lexer2.03%; other families are within
about2.5%. All108 intervals pass independent checksums. These are new timings,
not an exact-output continuity claim. B2 emits the twelve B1 C artifacts exactly.

Checked frontend36,native100,raw31,new14,word10,threaded28,20,521 independent
pattern controls,genuine B2 driver8,own-source type acceptance and exact B3 pass.
The same seven reference failures and thirteen broader native API gaps remain.
The 2,992-function nonnative closure remains exact. No compiler proof is claimed.

## Further discriminators

Fresh profiles assign about0.49–0.67s to native emission,0.10–0.23s to source
completion,0.07s to annotation and0.055–0.076s to layout validation. Internal
instrumentation sees about0.09–0.17s in rendering and0.06–0.10s in erasure.
These are overlapping diagnostic clocks, not additive clean savings.

A derived B2 replacing four Base string functions passes128,524 independent
Unicode/code-point comparisons, including unpaired-surrogate boundaries, and
all nine fresh requests reproduce exact C. Median requests improve only about
2–3%; the derivative is not a released/self-emitted image. Defer the broader JS
backend change: its validation cost is not justified as the next large C gain.

The optional existing Base-annotation artifact is admitted on all nine native
prototype requests and preserves exact C. Its4.06s initial preparation warms the
compiler; that process's812ms first request cannot be called cold performance.
Later processes with existing artifacts give1089ms array/1376ms lexer, versus
987ms/1402ms in the earlier clean screen. This is no clear gain. Do not promote
it or claim reusable native machine-code products were implemented.

Warm ordinary B2 requests are0.825x upstream over the first five warm requests,
and0.897x over the last three, on three separate per-program processes. Extra
Base memoization gives0.815x/0.822x; these short windows are still warming and
do not establish steady state. The mixed-program and held-out results below narrow this optimistic observation. Cold1.482x remains
separate. The session keeps the existing compiler warm, re-reads and checks
source graphs, and does not cache generated programs.


## What changed and why it helped

The scalar-pattern pass stores low-bit constraints as compact private rows once,
following typed erasure/static preparation. It removes duplicated reconstructed
defaults using alpha-equivalence and keeps an original scalar value when a branch
would rebuild that same value. Later analyses traverse the retained row bodies;
an escaping Word tail is still materialized when required. The change is general
to admitted U32/F32 Word patterns, not keyed to benchmark names. Nonetheless the
three original compilation fixtures share IO argument-reading code, so their
large gain must not be extrapolated to all programs.

A checked, no-bang native request now retains its admitted worker plan. For an
admitted positive-arity host worker, emission omits the redundant generic direct
body. Raw API requests, bang/device paths, unsupported workers and error ordering
retain their fallbacks. This recovers two previously rejected experiments under
the user's newly authorized execution-speed tradeoff. It does not discard
parallel execution support globally. We did not run a new GPU performance study.

The default now loads B2 instead of upstream-generated B1. Both contain the same
Bend compiler algorithms. This deployment gain is separate from the source
optimization; the 46.56% default improvement combines them. The installed API is
`35d7a606552ed6a90089312eb61914207d0170cfc5e0f40bdedf8cbeabe83204`, generated by
checked B1 `f058269d…`. B2 freshly checks its own source and produces exact B3.
The release includes relocatable checked-parent and self-emission lineage;
previous B1 and intermediate B2 packages remain preserved.

| Fresh request, median ms | Old B1 | New B1 | Old B2 | New B2 | Upstream |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric | 1942 | 1307 | 1357 | 1006 | 680 |
| Array | 1973 | 1320 | 1343 | 987 | 703 |
| Lexer | 2377 | 1754 | 1675 | 1402 | 895 |

These are JS-hosted compiler requests that produce C, not native-executable
compiler timings or total CLI/Clang/build times. Each role has three fresh samples
per source in the rotated 45-request comparison. Imports and explicit Bend Base
preparation are outside the request; upstream checks Base inside its request.

## Broader scope and the usable warm loop

Two held-out non-IO sources compile and execute correctly with both compilers.
Three fresh samples per stage/source give:

| Held-out source | New B1 ms | New B2 ms | Upstream ms | B2 / upstream |
| --- | ---: | ---: | ---: | ---: |
| Small arithmetic | 329 | 325 | 306 | 1.063× |
| 65 user functions | 681 | 653 | 373 | 1.752× |

There is no paired previous-compiler timing for these two sources. They test the
scope of the ratio, not a claimed optimization gain. See [heldout.json](heldout.json).

The new [native session tool](../../docs/self_hosted/NATIVE_COMPILATION.md)
retains one ordinary compiler process and re-reads/checks each source graph. It
adds no user-program cache or compiler algorithm in JavaScript. The actual tool
was measured on all five sources, rotating their order over six rounds per role.
Every one of the 60 emitted C results matches its independently acquired oracle.
Both compilers reuse their process; upstream reloads/checks its book each time.

| Mixed-session window | Equal-source geometric B2/upstream ratio |
| --- | ---: |
| All six rounds | 1.100× |
| After the first round | 1.114× |
| Last three rounds | 1.098× |

In the final three rounds, individual ratios are numeric0.899×, array1.005×,
lexer0.906×, small1.146× and functions65 1.704×. The B2 time includes approximately
30ms/request of compiler/Base integrity hashing; this is excluded by neither a
favorable window nor a special source. The last three per-case B2 medians are
232/243/353/82/153ms. Maximum sampled RSS is332MiB B2 and336MiB upstream. These
are sampled process values, not a complete memory-peak measurement.

This is an exploratory one-process-pair comparison (upstream then B2), with JIT
and GC variability and short warm-up. It is useful evidence for the editing loop,
not universal or steady-state parity. No Clang or executable caching is included.
The full records and all windows are in [session.json](session.json).

## Correctness, execution cost and simplicity

[qualification.json](qualification.json) joins the original checked source,
installed API, exact C reproduction and completed receipts. Frontend36,
native100, raw31, new14, word10, 28 threaded executions, 20,521 independent pattern
comparisons, B2 driver8, own-source acceptance and exact B3 pass. Installed and
relocated legacy42/default24 pass again for the final image. The release verifies
against the live source and local lineage. Session library controls cover edited
sources, restoration, compiler/Base replacement, request limits and error
isolation; installed NDJSON controls additionally check output preservation and
source-alias refusal.

[runtime.json](runtime.json) records every family, not just the aggregate. This
release is **1.05491× upstream**, **1.01792× the previous release's exact C artifact
set**. The expression case is14.25% slower than before, Array.map5.04%, Tree3.10%
and lexer2.03%. Correctness passed, but those runtime costs remain follow-up work.
No alignment-based explanation is promoted as a proven cause.

The unchanged 2,992-function frontend/JS closure supports continuity of those
algorithms; their broad historical performance was not remeasured. Seven reference
native failures, thirteen broader native API gaps and previously documented
frontend/JS exceptions remain. This is neither complete conformance nor a
mathematical compiler proof.

The standalone native-test manifest also registers the already-qualified new
module; the measured production assembly uses `src/compiler.json` and is unchanged.

Manifest-listed production Bend is **32,317 physical /26,408 code lines in132
modules**: +299/+246/+1. See [simplicity.json](simplicity.json). This phase adds a
private representation and a host-plan admission fact; it does not achieve a
line-count reduction. It avoids a second general IR or a new persistent native
artifact format. Host additions are explicit B2 release packaging and a small
serial session tool; compiler algorithms remain in Bend.

## Decisions, effort and next work

One combined source candidate was built and broadly qualified. Fast discriminators
then checked string kernels, annotation reuse and warm execution without rebuilding
or requalifying a compiler for each idea. Failed setup attempts and derived-image
experiments remain archived. No agents or PR comments were used. Resource guards
retained one CPU3 target tree,2GiB aggregate RSS,4GiB available-memory floor and
Node1GiB heap/4MiB stack. Exact Codex quota was not available and is not inferred
from elapsed time.

The larger proposed shared-lowering/native-product rewrite is **deferred**, not
implemented. After compaction, profiles do not identify a single repeated lowering
cost that justifies its forecast gain; rendering, erasure, annotation, source
completion and runtime allocation all matter. An existing annotation-product
prototype did not demonstrate a useful cold gain. Full reusable native products
still require symbolic IDs, dependencies and static-image relocation. The cheap
prototype does not disprove them, but does not justify promising parity either.

The best next compilation investigation is the held-out functions65 gap: compare
per-node source/check/erasure/render work against upstream in both cold and warm
runs. A retained per-node plan must first remove measured duplicate work on that
fixture and the IO fixtures before expanding it. For immediate iteration speed,
use the shipped session. For runtime recovery, isolate expression and Array.map
against the preserved old C and profile their native code rather than guessing
alignment. Full cold parity requires about32.5% further B2 request-time reduction
on the original loop; the current phase does not claim it is achieved.

## Reproduction and evidence

[Methods and fast-loop instructions](../../selfhost/tools/performance/phase77/README.md)
identify the ordinary commands and one-shot historical controllers. Raw reports
refer to `selfhost/build/phase77/`; their absolute paths are provenance, not a
requirement for release verification. The content-addressed evidence capsule
preserves all Phase77 raw outputs, candidate snapshots, rejected variants and
method bytes. See its manifest, verification and restore instructions in the
methods directory. Older baselines, pinned upstream and toolchains remain
external dependencies. The final installed package is self-contained for its
local lineage verification.
