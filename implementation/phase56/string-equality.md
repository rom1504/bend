# Definition-only native String equality

The direct compiler image repeatedly calls the Base chain
`String.eq → String.order → String.cmp`. The retained direct-image profile
identified String comparison as a major leaf cost. This candidate replaces only
the canonical native `String.eq` **function body** with strict JavaScript equality;
ordinary call sites retain their existing argument and partial-application
behavior. No new cache, runtime helper or private image rewrite is introduced.

The [frozen patch](../../selfhost/tools/performance/phase56/string-equality/candidate.patch)
and [source identities](../../selfhost/tools/performance/phase56/string-equality/source.json)
record exactly three edits:

1. Add `JDPrimitive{"String.eq", 2, "($0 === $1)"}` to the native table.
2. Make `jd_intrinsic` return no inline template for `String.eq` call sites.
3. Let `jd_definition_params` use `jd_primitive_candidate_emit` directly, so the
   admitted function definition still receives its native implementation.

The checked build, focused equality controls, full image generation, ordinary
driver comparison, exact B2→B3 reproduction and fresh type-check gate now pass
within the scopes below. The checked **B1 `string01` API is now installed**.
Its release passes installation, verification before and after smoke testing,
42 explicit legacy checks and 24 default direct checks. The separately qualified
direct B2/B3 images remain distinct from that installed checked API.

## Admission and semantic domain

The existing gate requires a native `Def`, zero templates, a non-foreign body,
matching intrinsic name and a bounded telescope with exactly two live arguments.
The actual verified Base cache from `checked-clean01` contains `String.eq` with
`native:true`, arity 2, templates 0, two live `Ref String` inputs and `Ref Bool`
result. Its SHA256 is
`78326c5209749d86b8f373b3936f3519a7956a104fe2b864db76e10b7f8cfbcd`;
the checked Base SHA256 is
`c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
This is a read-only cache observation, not an executed candidate-admission test.

Base loading sets the native flag through `f_path_defs`; ordinary source
definitions begin with `native:false`. Thus a same-named user definition cannot
qualify through name and arity alone. The focused gate demonstrates real Base
activation and a non-native same-named function over a user ADT in a separate
no-Base fixture. Defining `String.eq` again after importing Base is an invalid
duplicate declaration; that case remains an explicit frontend refusal.

The domain is the backend's native String representation: **primitive JavaScript
strings**. Strict equality compares their exact UTF-16 contents, with no Unicode
normalization. Under ordinary string operations this agrees with comparing the
decoded code-point sequences, including supplementary pairs, lone surrogates,
NUL and combining sequences. The current direct `Char.cmp` uses inverse views
and does not perform the legacy runtime's scalar reconstruction check; the legacy
runtime's malformed-character errors are therefore not the direct oracle.

Boxed strings, arbitrary objects and missing arguments are not native String
values. Their incidental old behavior is not a parity claim of this candidate.
The documented exclusion of arbitrary post-import builtin-hook identity also
continues to apply: equality need not replay `codePointAt`/`slice` implementation
hooks. Source callbacks and their evaluation/demand ordering remain in scope.

## Why retain the function boundary

A table-only inline addition would change the statement-prefix policy: ordinary
calls keep pending operands, whereas native calls hold computed operands before
returning their expression. In a tuple whose first field is
`String.eq(f(x), "")` and second field is `U32.add(g(x), 0)`, the existing emitter
runs the later numeric prefix (`g`) before evaluating the first pending call
(`f`). A generic equality inline would reverse those callbacks.

Definition-only admission avoids that change. `jd_call_plain` and its `JD_REF`
retain the named call; partial application continues to defer supplied expressions
until full application. At entry, evaluated function locals are compared once.
The native body cannot bounce, so existing native call-graph leaf treatment and
source-reach stopping remain valid. Other primitive inline templates are unchanged.

Independent static review passed the exact three-edit candidate. The focused
controls then exercised primitive Unicode cross-products, left/right callback
and throw order, the nested tuple prefix witness, deferred equality inside a
returned closure, non-native same-named definitions, duplicate rejection, and
actual native-definition versus ordinary-call shape witnesses.

## Executed results

All raw paths below are relative to `selfhost/build/phase56/`.

| Gate | Result | Retained report |
| --- | --- | --- |
| Checked candidate plus focused frontend | PASS, 36 probes, zero exact differences; 60.699 s supervised workflow | `checked-string01/validation-001/report.json`, `build-string01-supervisor/run.json` |
| String equality controls | PASS, 484 string pairs, eight order controls, two non-native-name observations, two duplicate refusals, three instrumented native entries | `string-controls02/report.json` |
| Checked B1 emits complete B2 compiler | PASS, 84.426 s; all 77 requested roots retained | `bootstrap-string01-plan/full/report.json` |
| Ordinary source/direct driver comparison | PASS, eight exact observations including emitted JS/C bytes | `bootstrap-string01-plan/driver-comparison.json` |
| B2 emits B3 through the ordinary unsplit API | PASS, 250.719 s, complete byte equality | `reproduce-string01/report.json` |
| B2 freshly checks its complete source | Type accepted; expected unsafe proof-trust refusal preserved; 29.681 s checking, 35.393 s total | `self-check-string01/report.json` |
| Installed checked B1 release | PASS, all five jobs: installation, both verifications, 42 legacy checks and 24 default checks | `release-execution-string01/report.json`, `release-string01/legacy42/launcher.json`, `release-string01/default24/report.json` |

The selected checked API is
`128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`.
The exact source assembly is
`5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244`.
B2 and B3 are both **3,896,951 bytes**, SHA256
`3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`.
Reproduction uses the inherited exact-source checking lane; fresh type-checking
is a separate execution. Its verdict still reports **3,012 unsafe or foreign
definitions**, `proofTrust: failed` and `kernelChecked: false`, with no additional
unsafe declarations. Neither exact reproduction nor the expected type-check
result establishes a mathematical correctness proof.

The original control attempt remains at `string-controls01/report.json`: its
parser import failed with `acorn.parse is not a function` before observations.
The corrected successor retains that failure rather than counting it as a
compiler rejection or successful test.

## Profile and timing interpretation

The old B2 reproduction exceeded its 300 s bound
(`reproduce-b2-01-supervisor/run.json`). Its separate fresh self-check accepted
the types in **55.839 s under V8 profiling**. The candidate's 29.681 s observation
was unprofiled and checks changed source, so these values are **not a controlled
speedup ratio**.

The failed full profile-processing attempt had already printed a flat table with
`String.cmp` at **15.7% of total ticks** and `String.cmp.rec` at **1.9%**
(`profile-process01-supervisor/stdout.log`). That offline processor subsequently
hit its isolated **512 MiB Node heap limit**; it was not a compiler or system OOM.
A separate summary-only processing run completed and parsed all **53,364 ticks**
(`profile-summary02-supervisor/stdout.log`). The flat hotspot supports the equality
hypothesis, but the failed processor is not presented as a complete call-profile
analysis or a quantitative attribution of the candidate's gain.

## Generated-program retention

`string01-performance/report.json` verifies that **44 of 45 benchmark point
modules retain exact bytes**, including the direct runtime. Only
`test-map-set-ops` changes. The unchanged points retain their dated timing evidence;
no new whole-corpus aggregate is inferred.

The changed point passed five fresh balanced rounds per role in
`string01-performance/timing-0/report.json`:

| Role | Median execution per call |
| --- | ---: |
| Previous host02 output | 20.8518 µs |
| String01 output | 17.5360 µs |
| Pinned TypeScript output | 20.5952 µs |

The same-run medians give **1.1891× old/candidate** and **0.8515× candidate/TS**
for this one point. All 15 samples passed their value checks. This is generated
program execution timing, separate from compiler generation and self-checking.

## Source cost

The equality candidate adds **2 physical / 2 code lines**, with no definitions,
types or modules added. Including the separately qualified seven-helper cleanup,
the maintained source has **26,246 physical / 21,585 code lines, 3,012 definitions,
100 types and 107 modules**. Relative to Phase55 host02 this is **40 fewer physical
lines, 32 fewer code lines and seven fewer definitions**. Runtime and ordered
expression sources are unchanged. The changed generated-program point was
measured separately as recorded above.
