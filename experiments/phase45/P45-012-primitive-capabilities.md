# P45-012 — Exact graph primitive dependency fence

Status: **REJECT production promotion under the preserved guard contract.**
The superseding [independent rejection](../../selfhost/build/phase45/primitive-capabilities-static-review03.json)
records the pre-import hook counterexample and binds the earlier static review.
[Fresh checked controller12-v2](../../selfhost/build/phase45/primitive-controls12-v2/report.json)
passes40 observations, but only post-import primitive mutations were covered;
this does not qualify the hostile-import guard domain. Root retains the in-flight
isolated timing as experiment evidence only. No maintained fence change follows;
nullary remains reverted while root continues11+13.

## Hypothesis and intervention

The contextual wrapper currently fences all 54 U32/F32 primitives regardless
of its successful graph. Nullary07 RLE has 67 dependencies but uses only four
primitive names; its all-family fence adds 50 irrelevant checks. Static RLE
metadata read counts are approximately626→176 if this fence narrows; that is
an operation estimate, not a measured gain. Keep full numeric and String host
inventories in this first causal experiment.

The [helper](../../selfhost/tools/performance/phase45/primitive-capabilities-helper-v1.bend)
collects every recognized primitive name from two complete sources: all original
contextual source bodies retained in exact instance rows, and every definition
in the successful JPure graph. It walks every KTerm child/arm under one aggregate
131072-node budget, deduplicates names in first-observed order and prints the
existing primitive descriptor fences. Collection is deliberately conservative:
annotations, erased/type references and any recognized name irrespective of
outer node tag can retain a guard. This prevents a private rewrite, literal
fold or eliminated operation from losing original primitive provenance.

The collector does not infer dependencies from emitted JS, runtime traces,
benchmark names, a single branch or host method names. Invalid/empty pure proof
or exhausted traversal keeps all54. No native/source guard or host/protocol
check changes; contextual row identities remain exact and replayed. Existing
private capture rewrites do not introduce G primitive calls absent from source;
source captures and constructor fields are children traversed by the collector.

The isolated [frozen07 patch](../../selfhost/tools/performance/phase45/primitive-capabilities-frozen07-v1.patch)
changes only the primitive fence expression and adds the small helper to jpure.
It applies to selfhost/build/phase45/source-worker07 (nullary admission +05),
with static git apply --check PASS. It does not restore nullary admission in the
maintained tree or mix the experiment with Nat11 representation changes.

## Independent controls and execution handoff

[Renamed fixture](../../selfhost/tools/performance/phase45/fixtures/primitive-capabilities-v1.bend)
uses two nullary scalar roots with recursive all-branch arithmetic. One ordinary
root never takes the xor/sub branch, yet those primitives must still be fenced.
The other takes that branch. Required primitive set is U32.add, mul, sub, xor,
is_zero. Independent integer recurrence results are38272 and73.

The [catalog](../../selfhost/tools/performance/phase45/primitive-capabilities-catalog-v1.json)
is for standard checked emission. The [controller](../../selfhost/tools/performance/phase45/primitive-capabilities-controls-v2.mjs)
requires actual checked emission/receipt/source/catalog/compiler joins and full
host guards, then instruments genuine contextual root markers. Its40 observations
include ordinary/restored activation, getter and replacement mutations for every
used primitive (refuse activation even in the untaken branch), and four unused
primitives (retain activation, no hook events, complete values unchanged). This
Used primitive mutation tests conservatively refuse admission; ordinary primitive
lowering itself inlines arithmetic and does not observe those public G hooks.
The expected empty hook event trace is therefore deliberate. V1 one-line root
scanner is preserved unconsumed; v2 uses complete Acorn assignment ranges and
strengthened identity joins/final input rehash. The controller
specifically permits irrelevant G primitive mutation; host mutation remains
subject to the unchanged full guard. Native descriptor identity/prototype,
Error reentry and complete maintained controls still apply independently.

Root commands, after creating an isolated checked candidate:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
$NODE selfhost/tools/performance/programs/emit-worker.mjs ATTEMPT \
  selfhost/tools/performance/phase45/fixtures/primitive-capabilities-v1.bend \
  NEW_MODULE.mjs selfhost/tools/performance/phase45/primitive-capabilities-catalog-v1.json
$NODE selfhost/tools/performance/phase45/primitive-capabilities-controls-v2.mjs \
  NEW_MODULE.mjs NEW_CONTROLS_OUT
```

Emission parent must already exist; output directories must be fresh. Expected
controller cost is under3seconds; compiler build/emission cost is not estimated
by this unexecuted prototype. Use maintained serial bounded supervision. First
measure unchanged frozen07 versus fence-only candidate on RLE and an unrelated
small nullary fixture, then Map-set if qualification passes. A null, regression
or incomplete collection ends the hypothesis without widening host capability.


## Subsequent safety audit — imported guard hooks

P45-007's broader import contract also blocks unconditional P45-012 promotion.
A pre-import Array.every shim can log and delegate to the original native every.
Module initialization captures that shim in regionProtocolDescriptors[3], and
full regionHostGuard accepts its unchanged descriptor. scalarGuard invokes
[a,c,e,b].every once per dependency; pruning RLE67→17 drops50 observable shim
invocations even though the omitted source primitives never execute. A shim
that throws or changes G/metadata after a chosen call can also change results,
error order or private admission. Pre-import reflection shims create analogous
read-count/order obligations. This is a static counterexample construction;
no target was executed for this audit.

The typed graph proof establishes which **source operations** are needed. It
cannot establish that validation operations themselves are inert. Keeping full
host guards does not close this gap because those guards compare against
imported snapshots, which may already contain the shim. The independent static
review receipt primitive-capabilities-static-review02.json must therefore be
read within its standard-import domain, not as hostile-import qualification.
Post-import used/unused mutation controls40 do not cover the missing premise.

An actual trusted-host capability could select the exact fence only when guard
intrinsics were independently proved native/inert, and retain the original54
otherwise. No such capability currently exists; merely comparing to snapshots,
checking function source text, or observing one successful guard is insufficient.
Without new trusted host provenance or an explicit user contract restriction,
the safe choice is the original all54 fence universally. Root has been advised
to reject promotion, and agreed. Source patch and unexecuted/fresh evidence remain
preserved; this audit does not authorize modifying or relabeling consumed inputs.
