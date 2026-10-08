# Phase66 bootstrap migration

The new upstream reference is `059266225b77c8ca256ac6b25ee5c21449bab151`.
The bootstrap compatibility proposal is recorded in
[`compatibility.patch`](../../selfhost/tools/performance/phase66/bootstrap/compatibility.patch)
and its exact before/after identities in
[`candidate.json`](../../selfhost/tools/performance/phase66/bootstrap/candidate.json).
Source inspection and independent peer review established the following changes.
Bootstrap/adapter, self-hosting and semantic controls have passed. Final native
and installed-release gates remain separately recorded in the phase report.

The upstream emitter no longer exports `io_base`. The replacement bootstrap
query uses public weak-head normalization and application decomposition, with a
prototype overlay that makes canonical Base `IO` opaque. It matches the upstream
private query and preserves exclusion of every IO-headed result type, including
zero/multiple arguments and aliases. Existing foreign, Base, template, missing,
and unfilled export refusals remain unchanged. The complete checked book remains
available while `order` limits the public roots. The emitter initializes its own
private `FL`; the bootstrap does not access that mutable context.

Active checked workflow and component-tool defaults select the new reference.
The release verifier admits the new exact pin's 35 JavaScript effects while
retaining its historical 37-file expectation for older pins. The Base/effect
lane separately binds the exact providers and preserves custom-Base resolution.
Historical untyped bootstrap recipes and old reference checkouts are untouched.

The initial B1 acquisition uses the unmodified checked upstream output, keeping
its genuine bootstrap separate from any adapter. Upstream now uses unary
closure messages (`r.f(r.x)`), whereas the old leaf-choice adapter emits array
arguments for a spreading runtime. The previous adapter cannot be migrated by
updating hashes alone. Profiles 1–6 remain unchanged and replayable; the new
profile 7 retains primitive equality and literal choices but excludes the old
leaf-tail transformation.

[`io-controls.mjs`](../../selfhost/tools/performance/phase66/bootstrap/io-controls.mjs)
binds exact upstream and candidate source, compares the complete local query
against the private upstream query, and checks independent semantic cases plus
unchanged original IO/book identity. Argument expectations force upstream
sharing cells; this is an oracle correction from source review, not a change in
production behavior. These synthetic term-book controls do not claim full
parsing or checking coverage.

The [build and B2 recipes](../../selfhost/tools/performance/phase66/bootstrap/build/README.md)
are exact recorded successors of the Phase65 factories. They retain all 99
State10 exports and their relative order, require the new upstream/Base lineage,
and reserve actual capture for the root's explicit source freeze. Python AST
and exact source-derivation replay were checked without running compiler or Node
targets. B2 keeps the existing source-backed split emission proof and tiny
complete-byte equality checks; a changed generated interface must fail closed.
Actual build, conformance, output, and timing results belong to the final phase
report after root-supervised acquisition.

## First acquisition

The preserved first attempt,
[`checked-b1-01/build.json`](../../selfhost/build/phase66/checked-b1-01/build.json),
failed during source parsing before producing an API. The new compiler rejected
a computed `match String.split(name, ':'):` scrutinee in the native backend's
`nc_foreign_namespace_name` helper. Its bootstrap child exited normally with code 1
after 5.153 s; this is an early failed-build duration, not compiler throughput.
The native backend lane split that computation into a separately matched
helper; the corrected successor subsequently produced the checked API below.
No equality profile or generated-image performance decision follows from this
failed acquisition.

## Checked image and diagnosed overflow

Attempt 02 produced genuine checked B1 `abccec43…671ab`: 1,954,796 bytes,
46,990 lines, 3,312 generated functions, and 99 identity-marshaled exports.
The [read-only source census](evidence/bootstrap-inspection02.json) binds the
actual image and complete bootstrap receipt. Every protected String equality,
ordering, character, comparison, and pair helper body is identical to profile 6;
the relevant runtime changes are `run_loop` and `run_tail`. These are source
observations, not measured speed improvements.

Its initial focused validation failed because the harness clone omitted
`base-cache-graph.mjs`; that failure is separate from the successful bootstrap
and was assigned to the harness lane. Raw B1 then passed 13 host/runtime controls
but overflowed while loading the upstream `marshal_array_depth.bend` fixture.
The bounded [boundary trace](../../selfhost/build/phase66/raw-load-trace01/report.json)
retained the original `RangeError` under `f_prefix_complete_ready_seed`, with
repeated `String.cmp` / `String.cmp.fin` frames. This directly localizes the stack
failure to recursive string comparison rather than the emitted program runtime.
The source seed path calls full-text comparison; a shortcut therefore requires
preserving exact string equality, not weakening the seed identity check.

## Profile 7 qualification

The new [guarded proposal](../../selfhost/tools/performance/phase66/bootstrap/profile7/profile7.patch)
binds the new upstream files, runtime prefix, checked bootstrap recipe, protected
bodies, and exact public wrappers. It inserts the previously reviewed primitive
string equality guard and transforms literal choices while retaining `run_tail`.
It never runs the older array-argument leaf-tail pass. The untouched raw parent
and a separate explicit derivation remain available.

[Actual-image controls](../../selfhost/build/phase66/profile7-controls01/report.json)
passed 151,084 primitive string pairs (including surrogate cases), nine fallback
inputs, 42 actual choice cases, 19 refusal controls, and exact replay of all six
historical profiles. The root-supervised run took 14.64 s; that is control-suite
cost, not a compiler benchmark. All recorded input identities and derivation
joins were independently rechecked after closure. The derivative
`758d9d3c…6808d` changes 3,594 literal-choice sites, retains runtime/export bytes,
and occupies 1,974,185 bytes (19,389 bytes more than the raw parent).

The successor [host controls](../../selfhost/build/phase66/host-runtime-controls02/report.json)
passed all 16 cases, including the fixture whose raw load overflowed. Combined
with the original stack and unchanged comparison bodies, this supports the
primitive equality shortcut as the remedy for that failure. Broad conformance,
ordinary speed measurements, fresh self-check, and B2 qualification are separate
remaining gates; these controls do not establish their results.

The [profile-selecting factory successor](../../selfhost/tools/performance/phase66/bootstrap/build/make-build-v2.py)
keeps `checked` as its default and accepts explicit `--profile equality` only
after the new profile is installed. The previously consumed factory is unchanged.
The active release helper already defaults to `equality`; the routine workflow
still defaults to `checked`, so current development examples select `equality`
explicitly. Later attempts preserve their genuine raw B1 plus proved derivative.

## Final qualification methods

Attempt 03 completed strict 36-case validation with derived API
`1ed7decc…23094`. The final host freeze is a separate attempt: newly qualified
Base annotation permission changes the driver even when API bytes stay equal.
Its export admission and genuine B2 plan must bind that exact driver. The old
admission correctly rejected the new host during data-only B2 preparation; that
failed preparation and the unexecuted earlier plan remain preserved.

The [qualification methods](../../selfhost/tools/performance/phase66/bootstrap/qualification/README.md)
were materialized as 16 exact derivatives in
[`qualification-method01/methods.json`](../../selfhost/build/phase66/qualification-method01/methods.json).
Independent source review replayed every parent/edit/output hash. The checked
and B2 planners also passed independent source review. These are preparation
results, not claims that the targets have passed.

The checked plan retains source 96, numeric 34, composition 18 and overapplication
2 independent observations, the eight maintained custom suites, 45 runtime
smokes from 23 sources, and three native programs. All TypeScript semantic
artifacts are acquired afresh at the new pin. The historical signaling-NaN
exception remains an exact conditional on a fresh observed failure; reference
pass counts are measured again. Native staging verifies each compiler with its
own frozen workflow. Both sides must satisfy all three original stdout goldens;
different correct C bytes across the changed upstream ABI are descriptive.

The genuine B2 plan separately requires fresh own-source type acceptance,
complete B2/B3 fixed-point equality, the same semantic matrix, and exact B1/B2
emitted bytes for all 23 runtime sources and 45 points. The expected unsafe
proof-trust refusal remains visible. Compiler timing and generated-program
timing stay separate from all these qualification checks.

The previous direct 26-case selection cannot be reported unchanged at the new
pin: upstream deleted `printer/let_in_argument_typ.bend`. The conformance lane
will identify the retained 25 cases within the new full direct-JavaScript corpus
and report the separately covered `parse/let_in_argument.bend` replacement.

## Closed final04 self-hosting and semantics

The genuine B2 image is `9ded6e94…96944`, recorded in
[`bootstrap-b2-04b/image-pins.json`](../../selfhost/build/phase66/bootstrap-b2-04b/image-pins.json).
The completed generation includes the tiny complete-output controls, all 99
public exports and eight exact source-B1/direct-B2 driver observations. Its
[fresh own-source check](../../selfhost/build/phase66/selfhosting04/self-check/report.json)
accepted all 3,278 explicitly unsafe definitions while retaining the expected
proof-trust failure. The separate
[fixed-point check](../../selfhost/build/phase66/selfhosting04/fixed-point/report.json)
produced B3 byte-identical to B2. Their complete controller durations were
17.27 s and 29.00 s; these are qualification costs, not comparative compiler
latency measurements.

The [program equality gate](../../selfhost/build/phase66/b2-04-program-equality/report.json)
freshly checked and emitted all 23 runtime sources with B2. Every complete raw
module and all 45 point modules, including the full row observer, equal the
separately qualified checked-B1 outputs. This transfers those exact program
oracles and does not invent a new runtime timing result.

The [semantic audit](evidence/semantic-qualification04.json) verified both closed
command plans, actual images and all recorded inputs. Checked B1 and genuine B2
each passed source 96/96, numeric 34/34, composition 18/18 and overapplication
2/2; the eight maintained custom suites passed too. Counts overlap. The
[fresh HEAD reference audit](evidence/reference-oracles.json) records TypeScript
95/96, 28/34, 18/18 and 2/2. The source NaN table returned 1 against expected 40;
all six cold original/renamed table probes returned `[1, 0, 0]` against 40 on
every call. These newly measured upstream oracle failures remain failures.

The final05 snapshot was rebuilt and strictly validated after eight native C
runtime/provider changes. The independently reviewed
[closure comparison](../../selfhost/build/phase66/reuse04-to05.json) verified
all 313 frozen paths: 305 are unchanged and the other eight match the exact
reviewed native candidates. Every Bend module, assembled source, raw and derived
API, JavaScript provider, host tool, Base and Node identity remains identical.
This permits an explicit join of the completed JavaScript evidence to final05;
it transfers no native qualification and creates no replacement B2 provenance.

## Selected 07 qualification

The later full JavaScript survey exposed seven candidate gaps in the 04/05
image: two missing `Min` cases, three wide-field analysis refusals, and two
shared-type printability timeouts. The selected 07 source incorporates the
reviewed fixes. Attempt 06's rejected local-match syntax is preserved; attempt 07
completed its fresh checked build and exact 36 validation.

The selected B1 is `bb6c6e2a…81a6`, from source `1b29d5c4…e8a3e`. Genuine B2
`0067736c…ed7f` was emitted from that actual B1, with the unchanged 99 public
roots, tiny split/unsplit/ordinary-path equality, and eight driver observations.
It freshly typechecked its own 3282 explicitly unsafe definitions and retained
the expected proof-trust refusal. A fresh B3 matches its 4,069,154 bytes exactly.
This is type acceptance and a fixed point, not a mathematical proof claim.

Both selected generations pass source 96, numeric 34, composition 18, and
overapplication 2 independent candidate oracles; the fresh TypeScript reference
still passes 95, 28, 18, and 2 respectively. Maintained 8 also passes. The exact selected
B1 program artifacts cover 23 sources and 45 points; B2 emits identical complete
raw modules and observer modules, permitting those same program oracles to
transfer. Compiler latency and generated-program runtime remain separately
measured campaigns.

The compact closed receipts are
[`semantic-qualification07.json`](evidence/semantic-qualification07.json) and
[`selfhosting07.json`](evidence/selfhosting07.json). The final
[compiler qualification](evidence/compiler-qualification07.json) now joins all
11 required roles and revalidates 11,601 input identities. This includes the
selected 07 full JavaScript survey, explicit native admission, four owned/custom
Base controls and the complete performance campaigns. The earlier
`qualification07/final-gates-plan-v2.json` remains its unchanged pending inventory;
the separate completed receipt establishes the result.

The [performance receipt](evidence/selected-performance07.json) records 207
exact-output compiler samples for each selected generation. Across 23 sources,
B1 compilation is 1.402× and genuine B2 1.321× the new TypeScript compiler's time.
Generated programs are measured separately: 45 workload points and 669 samples
all satisfy their output oracles, with an equal-point runtime ratio of 1.049×
TypeScript (1.047× when each source receives equal weight). The changes against
the prior self-hosted version are small: B1 compilation 1.005×, B2 0.998×, and
program runtime 1.0004× by equal point. These are suite aggregates, not universal
speed guarantees or evidence of a material migration speedup.

The [installed-release audit](evidence/installed-release07.json) now passes too.
All five release jobs completed: installation, verification, legacy 42 checks,
default 24 checks and final verification. Five graph-helper integrity controls
also passed. The audit rehashes 594 input identities, all seven installed files,
all 48 frozen native files, the seven predecessor files in both release history
and raw copies, and 110 inherited protected files. Installed B1/API and source
match selected 07; no compiler bootstrap was run during installation. Checkout
files covered by the checked snapshot match it; `cli.mjs` is outside that
snapshot and is bound by the installed inventory and completed release tests.
