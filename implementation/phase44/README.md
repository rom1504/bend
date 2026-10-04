# Phase44: composable JavaScript backend

Status: implementation and qualification in progress. Design is
[here](../../design/phase44/README.md). The installed Phase43 checked14 remains
the reference until the selected candidate qualifies. No PR comment is posted.

## Controlled architecture baseline

The first frozen compiler, `selfhost/build/phase44/checked01`, builds in 45.15s
under the serial CPU3/1GiB Node heap/2GiB process-tree policy. It routes ordinary
applications, lambdas, matches and parallel bindings through typed runtime IR.
Seven previous KTerm-to-text helpers were retired. This first snapshot does not
activate simplification or statement emission.

All 45 maintained benchmark points (23 sources) have **byte-identical emitted
modules** to the frozen Phase43 release. This is artifact-specific equivalence,
not a proof for arbitrary programs. Acquisition took 153.73s and is excluded
from execution timing. The independently authored composition fixture also has
identical output. Its 35 shared scalar oracles agree with pinned TypeScript;
11 public-runtime boundary controls and 26 higher-order observations pass
against the preceding Bend compiler. Existing synthetic backend tests pass all
15 cases, including 14 emission byte comparisons, and the new lexical-scope
controls pass against this unoptimized snapshot.

## Implementation being qualified

The next snapshot makes ordinary construction, compact literals, proven primitive
operations and Boolean choices explicit. Independent passes perform bounded copy
propagation, exact identity-binding elimination and nine safe literal-only U32
folds. Statement emission removes return-position binding/branch IIFEs while
preserving parallel RHS scope, delay, erasure and tail-message demand.

Repeated instance-body rewriting and one identical planner proof are shared.
Literal admission uses semantic provenance rather than rendered text where
possible. No new workload-family recognizer or public runtime relaxation is used.

Selected results, performance and release status will be recorded after the
actual candidate passes the required checks; no speedup is claimed yet.

## Focused optimized snapshot

`checked03` builds and passes the strict focused workflow in 46.05s, peak
process-tree RSS 1,390,063,616 bytes. All 37 IR functional controls pass,
including actual statement and nine-operation constant-fold activation. The
optimized composition fixture passes the 35 scalar oracles, 11 boundary and
26 higher-order observations, plus four delayed mixed-feature points. The
15 maintained basic backend execution cases also pass. Broad qualification and
controlled timing are still pending.

`checked02` is a retained failed bootstrap (4.11s): constructing the original
primitive node before matching its operand violated the source language's binder
rule. Passing it to a fresh-parameter helper fixes the source; no admission or
semantic rule changed.
