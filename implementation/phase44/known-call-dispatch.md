# Known-call dispatch experiment

**The prototype showed no broad execution gain and was rejected for production.**
The six-point geometric ratio of unchanged checked04 execution time to prototype
time was **0.991918×**, effectively flat with a small slowdown in this screen.
No production compiler or runtime change was selected from this experiment.

The [design](../../experiments/phase44/P44-002-known-call-dispatch.md) tested whether
giving known generated callees separate JavaScript invocation sites would help
V8 specialize calls. The saved-JavaScript rewrite captured eligible function code
at its original allocation site and passed a per-callee invoker through existing
runtime dispatch. It retained argument evaluation, descriptor checks, `.call`
before environment access, mutable-code fallback, exact-entry permission,
partial application, oversaturation and forcing. It did not remove the generic
runtime protocol or generate a direct-call backend.

The derivation receipt (`selfhost/build/phase44/known-call-derive04/derive.json`)
covers **45 points, 24 module artifacts and 1,465 rewritten static call sites**.
These counts do not establish executed-call coverage, hot-path coverage or
captured-code branch activation. Matchers and `exactCode` wrappers were outside
the intervention. Additional JavaScript frames and changed generated function
text remain diagnostic limitations. The
derived bundle (`selfhost/build/phase44/known-call-prototype04/manifest.json`)
is explicitly an **unchecked prototype**.

Raw receipt paths below are relative to the repository and are intended for
inspection after extracting the campaign evidence. The
[closed evidence archive index](../../selfhost/tools/performance/phase44/evidence/raw/archive.json)
binds the published, reopened archive, including the rejected prototype and its
raw measurement receipts.

## Same-run results

The control binding (`selfhost/build/phase44/prototype-control04/derivation.json`)
relabels exact saved checked04 modules as the baseline and retains the same
pinned TypeScript modules. It performs no new compilation. The
execution report (`selfhost/build/phase44/known-call-screen04/report.json`)
records six points, three fresh rounds per role and **54 successful samples** in
**46.166911 seconds**, within the 60-second budget. Execution used Node 24.18.0,
CPU 3, a 1 GiB heap and the existing benchmark protocol. Both Bend variants and
TypeScript ran in the same measurement; historical timings are not denominators.

| Point | Checked04 / prototype time | Checked04 / TypeScript time | Prototype / TypeScript time |
|---|---:|---:|---:|
| Lexer | 0.9719× | 7.3762× | 7.5895× |
| Map128 | 0.9601× | 28.3625× | 29.5398× |
| BST64 | 0.9916× | 2.3480× | 2.3679× |
| List512 | 0.9972× | 0.5357× | 0.5372× |
| Records256 | 0.9528× | 81.1360× | 85.1565× |
| Closures256 | 1.0834× | 0.4927× | 0.4548× |

A ratio above one in the first column favors the prototype. Five medians were
slower and one was faster. This short screen does not establish statistical
significance or steady-state performance across the full 45-point corpus.
Execution includes the harness's result validation and checksum work; import and
first-call measurements are recorded separately.

## Interpretation and decision

The proposed specialization benefit is unsupported by this screen. Additional
helper dispatch may cost as much as the specialization saves, or the selected
sites may account for too little of execution; neither explanation was isolated
by counters or attribution measurements. A general direct-call lowering that
removes dispatch work would be a different experiment.

The original decision rule required useful benefit across different sources.
The isolated closure improvement does not meet it. Stop this direction for the
present phase, preserve the derivative and measurements, and perform no further
qualification or production promotion. This is evidence against this particular
intervention, not proof that devirtualization is universally ineffective.
