# Phase144 — cold compilation through measured native stages

The integrated compiler is independently source-checked and native-qualified.
On the unchanged full compiler input, its clean request takes **251.861s** versus
a fresh **304.534s** parent observation: **17.30% less time**. QBE, assembly and
linking add **15.469s**, giving **267.330s** of target work. These are single
observations in separate time windows, not confidence intervals. The **50s goal
is not achieved**.

[Design](../../design/phase144/README.md) · [candidate](candidate.json) ·
[qualification](qualification.json) · [profiler findings](profiler-and-cost-findings.md) ·
[profiler guide](../../selfhost/tools/profiler/STAGES.md).

## What the measurements mean

The frozen input is Phase142 source `15f5cada…dac1`, 2,946,225 bytes. Each cold
request starts a new native process with the same immutable prepared Base,
CPU3 affinity and command protocol. It reuses no source-specific semantic state
or generated objects. OS caches are not flushed. Compiler acquisition is charged
separately. Machine construction is fresh; the combined figure sums those stages.

| Experiment | Compiler request | Product relationship |
| --- | ---: | --- |
| Fresh qualified Phase143 N2 | 304.534s | Frozen original QBE |
| Source01, original runtime | 266.862s | Complete original QBE equality |
| Same Source01 object, serial runtime | 249.679s | Complete original QBE equality |
| Final03 N2, serial runtime | 251.861s | New code-generation policy and product |

Source01 saves 12.37% in that pair. Changing only its runtime saves another
6.44%; the combined observation is 18.01% below the parent. The final append and
predicate composition does **not** demonstrate an additional full-compiler win
against that intermediate observation. Kernel gains are not added to full-request
results. Final03's self-source request is a different input, recorded at250.296s.

## Changes and their mechanisms

- An exact parser-prior index preserves first-prior and shadowing behavior while
  avoiding repeated scans. The extracted actual native parser falls from44.572s
  to31.175s, with complete graph/checksum agreement. This is not a30% whole-build win.
- Request-local constructor ownership facts survive preparation and actual
  erasure. Multiple consumers stop rescanning the same immutable declarations.
- Body/footer flattening shares the final traversal, removing intermediate
  String construction without changing emitted bytes.
- A guarded runtime uses ordinary reference-count word updates under an explicit
  one-Bend-heap-mutator contract. Overflow, final-owner and reclamation behavior
  remain; incompatible compute workers, GPU and entry modes are refused.
  Detached host IO workers still exist. Arbitrary concurrent foreign embedding
  is outside this contract.
- Source-backed String append composes with the existing checked concatenation
  helper and live-register transport. Literal-lambda Boolean branches use a
  positive predicate and swapped arms, removing an unnecessary continuation.
  Semantic admission and fallbacks remain independent of benchmark names.

An unobserved rollback capture is removed from the native session adapter; the
original generic transactional rollback implementation remains unchanged.

## The profiler was improved and used

The reusable native profiler now associates samples with exact stage entries,
monotonic timestamps and sample ordinals. Once/first/optional markers support
real conditional stages. Missing or duplicate required markers invalidate
attribution. Source, retained object, linked runtime, dispatch identities and
full output are authenticated. Ten contract tests and a fresh native Lexer gate pass.

The parent and first integrated profiles have zero lost samples and over99.5%
CPU coverage. Their diagnostic stage comparison identifies the work removed:

| Diagnostic interval | Parent | Source01 |
| --- | ---: | ---: |
| Parsing | 47.95s | 35.91s |
| Checking | 37.33s | 37.67s |
| Erasure | 15.78s | 5.90s |
| Raw lowering | 44.63s | 38.69s |
| Optimization plus first verification | 64.03s | 64.43s |
| Observer composition | 28.43s | 25.15s |
| Rendering/output tail | 51.85s | 47.83s |

`f_find` falls from480 to27 active samples; `nc_ctor_owned` from610 to zero.
Physical destruction samples overlap source-owner and stage attribution; they
are not independent savings to add. Diagnostic clocks are not clean timings.
A final03 profile is being collected with its actual serial runtime and new QBE oracle.

## Correctness and self-hosting

Final source `31e1b13a…e3ea2` passes independent source checking and127 finite
controls. Predicate/index experiments additionally compare336 complete trees
and11,088 payload queries. All101 protected declarations, including independent
final verifiers and11 inherited proof declarations, remain byte-identical.

Qualified Phase143 N2 builds N1, N1 builds N2, and N2 reproduces complete
117,151,119-byte Q2 as Q3. Q1 legitimately differs because code generation changed.
Both native generations pass focused19; N2 passes all45 ordinary stdout oracles.
NativeHost path, publication, existing-file refusal, Unicode readback, batch and
A/B session checks pass. The final receipt rechecks all actual artifact identities.

Three chooser laws are independently accepted by BendTT/Lean, with a false law
rejected. They establish total Boolean value equalities. The production body
bridge, evaluation order and literal-lambda restrictions are separate obligations;
this is not an end-to-end compiler theorem.

One smoke incorrectly expected `IO.pure(U32,1)` to set process exit status. The
fixture correctly returned EEXIST17 and preserved the file, but ordinary IO
completion exits zero; `IO.die` controls process status. Independent source
review justified the harness correction. The failed receipt is retained; no
compiler/runtime behavior was changed to pass that test.

## Simplicity, failures and resource cost

The compiler grows63,983→64,587 physical lines: **604 lines**,66 definitions,
and the same683 laws, including new controls. The native-only source profile is
packaging, not a reduction of the maintained implementation.

Rejected or unintegrated findings are retained:

- A compact verifier gained only1.9% in its native slice after losing direct
  workers. Explicit absence restored workers and reached11.06% in that slice,
  insufficient evidence for a large whole-build rewrite.
- Selective product retry recovered five workers in that modified prototype,
  none in the original hot verifier. Its7.51% slice gain is not a production win.
- A captured renderer constant timed out before IR. Narrower symbol codecs had
  only a3.51% text-size ceiling.
- Upstream C emission succeeded after the dead-capture fix. Both Clang O2 and O1
  acquisitions hit the explicit6GiB process-tree limit. No executable exists;
  there is no same-source C execution comparison.

One guarded CPU3 lane owns target work. Ordinary jobs retain3GiB RSS and16GiB
available-memory bounds. Byte-verified hardlinks recover disk space without
removing old paths or changing artifact contents.

Remaining ablations, generated-program timings and final cost accounting will
be consolidated before this phase closes. Installed/default selection remains
unchanged; the qualified checkpoint is available explicitly. No PR comment was
posted and no recursive research acceleration is claimed.
