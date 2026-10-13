# Active frontier: Phase77 B2 default and compact native lowering

Installed genuine B2`35d7a606…`, checked B1 parent`f058269d…`.
[Report](../implementation/phase77/README.md), [qualification](../implementation/phase77/qualification.json),
[session guide](../docs/self_hosted/NATIVE_COMPILATION.md).
Paired fresh45 requests: oldB1 2.77248×→newB1 1.92036×,oldB2 1.92566×→newB2
1.48173× upstream;30.74%/23.05% less time. Default stage selection plus source
changes cut46.56% versus the old B1. JS-hosted Bend-to-C request clocks exclude
imports, explicit Bend Base, Clang and execution; upstream checks Base inside.

The user explicitly authorized temporary generated-program regressions. This
supersedes the historical runtime veto below: selected compact scalar rows,
alpha-equivalent default/reconstruction elimination and admitted host-body omission
now ship. Twelve-family runtime is1.05491× upstream/1.01792× previous;
expression14.25%,Array.map5.04%,Tree3.10%,lexer2.03% regress. All108 intervals
pass. These costs remain visible follow-up work. Raw/bang/device fallbacks remain.

The real native-session tool measures about1.10× upstream over five mixed sources,
including identity hashing, with both processes reused. Short windows and individual
ratios0.90–1.70× do not prove universal parity. Cold non-IO held-outs measure
1.063×/1.752× B2. Source graphs are re-read; no program-output cache is introduced.

All selected native/raw/frontend/threaded/B2/self-check/B3/installed gates pass;
JS closure2992 stays exact. Seven reference failures/thirteen broader API gaps
remain. Production32,317 physical/26,408 code lines in132 Bend modules (+299/+246/+1).

Defer the string-kernel image (only2–3%) and annotation-product prototype (no clear
cold gain). The larger reusable native-product/retained-node-plan rewrite is not
implemented; require a discriminator showing eliminated work on functions65 as
well as the shared IO fixtures. Profiles now distribute cost among native
rendering, erasure, source completion, annotation and GC. Do not multiply their
inclusive clocks or infer native product value from Base-name overlap.

Use fresh phase paths after sealing. One guarded CPU3 tree,2GiB RSS/4GiB available,
Node1GiB heap/4MiB stack. No agents were used. No PR comments without explicit
request. Preserve unrelated work and sealed evidence.

## Historical Phase76 frontier

Installed compiler12: checked B1`98134f59…`, genuine B2/B3`29da003b…`.
[Report](../implementation/phase76/README.md) and [qualification](../implementation/phase76/qualification.json).
The interleaved45 comparison gives B1 **2.93623x→2.75191x** upstream and B2
**1.94374x→1.90803x**:6.28%/1.84% less request time. The B2 difference is small
at this sampling precision. Fresh JS-hosted Bend-to-C requests exclude imports,
explicit Bend Base, Clang and execution; TS checks Base in its request.

Retain lazy native-definition/call admission and representation certificates.
The four-module change adds34 physical/22 code lines;131 modules now contain
32,018 physical/26,162 code lines. All twelve C files and binaries remain exact
Phase75/73, preserving the prior runtime artifact set (historical1.05060x aggregate).
All selected native/raw/selfhosting/installed gates pass. Seven reference failures
and thirteen broader API gaps remain. Source algorithms stay in Bend.

Reject the scalar-pattern prototype for default promotion despite a substantial
compilation gain: candidate08 reaches1.99078x B1/1.51774x B2 (32.25%/22.20% less
time) but Tree/Array.map executables regress3.66%/4.93%. Candidate10 reconstruction
elimination and alignment/placement variants fail to recover both. Complete
prototype source, controls and failures remain in experiments/phase76/prototypes
and the evidence capsule. Changed addresses/layout are plausible, not proven
hardware causes. Do not keep guessing alignment without hardware counters.

Next large discriminator: retain per-node lowering facts/relocatable products
while requiring exact existing C before committing to a bigger native IR. A
root-only memo remains weak (97% distinct roots). Reusable Base products need
explicit dependency/static-image/ID relocation and separate cold/warm metrics.
Shared benchmark argument-reading code limits extrapolation of pattern savings.
Parity remains unachieved. Do not present rejected prototype speed as the release.

Use fresh phase/output paths after sealing. One guarded CPU3 target tree,2GiB
RSS/4GiB available floor,Node1GiB heap/4MiB stack. No agents were used; no PR
comments without explicit request. Preserve inherited work and sealed history.

## Historical Phase75 frontier

Installed selected compiler14: checked B1`7f05ac96…`, genuine B2/B3`0444d283…`.
[Report](../implementation/phase75/README.md) and [qualification](../implementation/phase75/qualification.json).
The interleaved45-request comparison gives B1 3.55981×→2.91581× TS and B2
2.33580×→1.92053×,18.09%/17.78% less time. These are fresh checked JS-hosted
Bend-to-C requests, excluding imports, explicit Bend Base, Clang and execution;
TS checks Base within its request. No parity or native-executable compiler claim.
All twelve generated C files and binaries are identical to Phase73, preserving
its1.05060× twelve-family execution artifact set. JS closure2992 is unchanged.

Retain single native request/report products, checked context/erasure/arity reuse,
selective worker retry, constructor indexing and compact U32 occurrence sets.
Native100/raw31/new14/threads28,166 report graphs,1,066 constructor comparisons,
199,400 set controls,B2 own-source acceptance/B3 and installed42/24/5 pass.
Seven reference failures and thirteen broader native API gaps remain unchanged.
Source31,984 physical/26,140 code lines in131 modules (+254physical,+201code,+2).

Do not reintroduce host-body omission as an accepted optimization: it reached
1.683× B2 but regressed tree/Array.map about5%. Unchanged worker text/function
sizes do not prove unchanged runtime cost. All tested layout variants failed to
recover both; the path was removed. Bitmap occurrence leaves added code without
a gain and were rejected. Exact compiler14 code/production artifacts are selected.

Next larger experiments: typed native IR with retained per-node facts shared
between lowerings, or reusable Base backend products with explicit dependency,
static-image and temporary-ID relocation. Demand an exact-output fast prototype;
do not promise their gain before measurement. A simple root-identity memo is
still weak (97% unique root calls in Phase74). Warm service is a different metric.
Use fresh phase/output paths after Phase75 sealing. One guarded target tree,
CPU3,2GiB RSS/4GiB available floor,Node1GiB heap/4MiB stack. No PR comments
without explicit request. Preserve inherited unrelated work and sealed history.

## Historical Phase73/74 frontier

**Latest investigation: [Phase74 compilation parity](../implementation/phase74/README.md).**
Production remains Phase73. Counter-only exact-C diagnostics find six native
reachability calls, repeated worker lowering and no final generic-segment
pruning; an identity-only occurrence cache has few exact repeats. Next priority
is a prepared native route plan with shared facts and reusable Base products.
Warm B2 improves the edit loop but is a separate metric. See the report for
conditional estimates, falsifiers and the unchanged release boundary.

[Design](../design/phase73/native-parity.md) ·
[Report](../implementation/phase73/README.md) ·
[Measurements](../implementation/phase73/measurements.json) ·
[Qualification](../implementation/phase73/qualification.json).

Selected production source `a6ca26d`; installed checked B1 `c2705793…`, genuine
B2/B3 `25d4ca2e…`, flattened source `cf12e529…`; upstream0592662. Compiler
algorithms remain Bend. No subagents; no PR comments without explicit request.

## Result and tradeoff

General constructor sharing, borrowed scalar observers and scalar facts retained
through continuations reduce the fixed twelve-family C execution mean
**1.36903×→1.05060× upstream**, **23.26% less time** against paired Phase72.
Original/additional six means are1.00924×/1.09365×. Tape/list/BST speedups are
3.36×/1.98×/1.64×. Tree,lexer,AST,Array.map still take1.37–1.53× upstream time.
All216 final intervals qualify. This is near aggregate parity, not universal parity.

Compilation pays for the analysis: old/new B1 ratios3.35025×/3.59582×; B2
2.16089×/2.29667×. Request time grows7.33%/6.28%. Forty-five clean requests
validate exact C. Additional old/new B2 profiles show roughly71–85ms added native
emission work; sharing/field functions appear in44–53ms inclusive CPU samples.
Instrumented clocks and clean samples remain separate. Prepared Bend Base is
outside requests, upstream Base checking inside; imports/Clang/execution separate.

Frontend36,candidate native100,raw31,twelve new controls,24 threaded executions,
exact2992 non-native functions,B2 driver8,own-source acceptance,exactB3 and
installed42/24/5 pass. B2 emits all twelve timed C files exactly. The reference
retains the same seven failures; broader thirteen native API gaps remain.
Seven old release files are preserved. Production adds273 physical/211 code
lines and one module:31,730 physical/25,939 code in129 modules. No runtime rewrite.

## Next discriminating experiments

1. Recover compilation overhead with one occurrence index per prepared body
   instead of repeated `nq_uses` scans, and reuse specialized field facts. Require
   exact emitted C before retiming execution; use the three-source B2 fast loop.
2. Target remaining runtime gaps. Candidate08 tree counters still show434k
   allocations versus231k upstream: test general unique-node reuse or fusion in
   retained C before implementing a Bend rule. Array.map already has allocation
   parity in counters but remains1.53× slower; inspect keep/drop and segment/code
   costs there. AST has equal allocations and excess generated/scheduler work.
3. Validate any runtime mechanism on several families. Do not optimize the
   already faster Tape/Map solely to make the aggregate score cross1.0×.

Do not repeat unrestricted non-tail C recursion (all three initial families got
slower and deep-stack safety was absent), Nat narrowing (AST regression), or
blanket inline-policy changes (conflicting family results) without a new reason.
Field masks alone did little; they paid only when composed with capture kinds.

Phase73 target writers close after sealing. Future work uses fresh phase/output
paths; historical baselines are immutable. Preserve inherited unrelated changes.
One guarded CPU3 tree,2GiB RSS/4GiB available floor,Node1GiB heap/4MiB stack.
The phase used no agents and observed three account-quota percentage points;
those account events are not exact task billing. Slow gates belong after a
selected candidate demonstrates gains, not in every small iteration.
