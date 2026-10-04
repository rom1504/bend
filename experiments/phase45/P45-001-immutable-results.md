# P45-001: immutable native results at contextual-worker entry

Status: isolated checked candidate acquired; five-round stronger replay passed
with a positive performance signal and remaining drift. Actual-record boundary
controls are pending.
Independent static review passed: scalar argument admission and dependent-tail
traversal match the previous signature check; the extra old scalar result test
duplicated its terminal check. Emitted worker presence and actual runtime branch
entry are tracked separately below.

The selected Phase44 contextual-instance entry requires both scalar arguments and
a scalar result. This blocks any native String-returning entry before its existing
whole-graph and component proofs run. Record aggregation is one observed example:
its scalar-input `bench` returns String and stays generic, whereas upstream emits
direct calls, field matches and a loop. The rule applies equally to unrelated
String-returning programs.

Change `j_instance_root` in `selfhost/src/back/js/jpure.bend` to use a dedicated
signature proof. Every live argument still requires `j_region_scalar`; the final
result must pass either that same scalar proof or `j_string_string`. The latter
checks the exact native String owner, constructors and Char/tail field telescope;
a user type with the same spelling is insufficient. `j_region_scalar`,
`j_region_signature`, all public argument checks and runtime code stay unchanged.

The remaining admission chain is intact: source-definition identity, arity bound,
an actually erased call, exact contextual substitutions, complete purity graph,
component-prefix/recursion support, covered-call audit and emitted-instance checks.
At runtime the existing exact entry token, scalar input checks, descriptor guards,
`regionHostGuard` and `stringHostGuard` remain mandatory. Rejection keeps the same
generic implementation. There is no source/export-name recognition or new cache.

Native strings are already a proved internal representation and component result.
Returning such a primitive needs no public object reconstruction, ownership transfer
or lazy-field change. The patch does not admit String inputs, records, arrays or
closures as contextual root results. Broadening those types requires separate
ownership and public-representation reasoning. Later proof gates can still reject
a String-returning program; removing the early gate does not guarantee activation.

The independent fixture is
`selfhost/tools/performance/phase45/fixtures/immutable-results.bend`. Check fresh
baseline/candidate/TypeScript outputs for at least:

| Export and input | Expected result |
| --- | --- |
| `bench(0, 7)` | `""` |
| `bench(1, 7)` | `"λ7;"` |
| `bench(3, 7)` | `"λ9;λ8;λ7;"` |
| `bench(3, 4294967295)` | `"λ1;λ0;λ4294967295;"` |
| `selected(false, 7)` | `"empty"` |
| `selected(true, 7)` | `"🧭7"` |
| `non_scalar_input("kept")` | `"kept"`, unchanged generic admission |
| `returned_closure(10)(7)` | `"17"`, unchanged closure-return admission |

Activation must be inspected in emitted output, separately from equal results.
Retain descriptor/global mutation, Function.prototype.call, String method mutation,
constructor/native-provenance, overapplication and reentry controls. In particular,
guard refusal must fall back before producing observable effects; a modified global
helper or String host method must not silently use the captured worker behavior.

The isolated `checked-immutable01` candidate passed its checked build. API SHA-256:
`6e75ea4ef0de6d14ea7bb7724b43149c90d8df748b0c1223e180ba4a0f1cfe55`.
Its six-source acquisition changed only record aggregation relative to Phase44:
BST, closures, lexer, list pipeline and Map output bytes remained identical.
Record output grew from 126,483 to 256,878 bytes and now contains one contextual
worker entry. This establishes new generated code, not a runtime activation count.
The candidate record module SHA-256 is
`a8f894e9ea8e26b86f6a565380d2a9945d1752b05eeb7c0cb6ae5cdb3ec25022`.

The independent fixture passed eight exact output observations against the baseline
and pinned TypeScript plus 44 mutation/reentry differential boundaries in
`selfhost/build/phase45/fixture-controls01/report.json`. Its `rootShapes` fields
incorrectly report no contextual workers: the controller searched only the first
line of each `G[name]` assignment, while generated declarations span several lines.
Read-only inspection of the exact bound candidate module
(`a3592079d43b0504ee14721e862f990c58090a6cc063a2cd13fe21dddfc67963`)
finds contextual entries for `bench` and `selected`, at lines 811 and 818. The
String-input and closure-result exports stay generic. The passing behavioral
observations remain evidence; the false shape classification is not evidence of
nonactivation. A counter derivative is needed to establish actual branch entry.

The timings measure only `coverage-record-aggregation-256`, with fresh
TypeScript/Phase44/isolated-candidate roles; the first two runs have three rounds
per role, and the third has five:

| Run / preset | TS median ms | Phase44 median ms | Candidate median ms | Phase44/candidate | Candidate/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| `runtime-immutable01` / 20 s | 1.722551 | 85.311991 | 74.621102 | 1.1433× | 43.3201× |
| `runtime-immutable02` / 60 s | 1.316262 | 111.279509 | 29.838330 | 3.7294× | 22.6690× |
| `runtime-immutable03` / 600 s | 1.248865 | 84.056331 | 29.822644 | 2.8185× | 23.8798× |

The first two runs completed nine passing samples each. Their warmup/target windows differ:
100/50 ms in the 20-second preset and 350/150 ms in the 60-second preset. Candidate
within-sample half drift was +284% to +348% in the first run, and +15.5% to +21.9%
in the second; second-run baseline drift was −32.4% to −29.3%. Missing first-run
baseline drift stays missing. The markedly different ratios are a reason to extend
warmup, not to select the more flattering number as a settled gain.
`runtime-immutable03` completed 15 passing samples in 27.11 seconds with the
600-second preset: at least 1,000 ms warmup and a 300 ms measurement target. Its
five candidate samples ranged from 28.6495 to 29.9260 ms, compared with baseline
samples from 80.3060 to 92.3743 ms. The resulting 2.8185× ratio is a positive signal
for this general admission rule on this point, but remaining baseline half drift
reached −21.1% and candidate drift +30.3%. It does not establish a precise universal
gain; candidate execution remains 23.8798× the same-run TypeScript median.

`selfhost/tools/performance/phase45/record-result-controls.mjs` is prepared for the
actual changed record modules. It checks four literal output oracles and public
helper/global/code/env/String/Error mutation/reentry differentials, then separately
uses a counter-only derivative to witness entry and guard refusal. Its execution is
pending. Instrumented modules never supply timing evidence.

Root owns execution and the next private-worker build. No full-corpus speedup,
parity or release qualification follows from these screens. General owned-result
reconstruction for records and arrays remains a read-only proposal until the first
boundary experiment has been measured and qualified. Raw evidence paths above are
local campaign artifacts; none modifies closed Phase44 evidence.
