# Phase92 native-host conformance

Both same-source native compiler roles pass all69 execution fixtures that fit
the frozen D04 entry's contract. All69 emitted complete-C SHA256/length records
agree across roles, and all six focused rejection controls pass. No full-
native100 or frontend conformance claim follows from this subset.

| Native compiler role | Original golden executions | Historical runtime observations | Status |
| --- | ---: | ---: | --- |
| Upstream-C-built B1, `6bb07e94…` | 69/69 | 69/69 exact | Complete |
| Own-C-built native07 B2, `d7c7a479…` | 69/69 | 69/69 exact | Complete |

Both roles use the exact same frozen compiler source `d04ad79c…`. B1 was
checked/emitted by the pinned upstream TypeScript compiler and built at Clang
O2. Native07 retains its native-emitted C lineage and independent JS B2 C
comparison. These are compiler-host roles: both emit this compiler's C backend,
not competing upstream-versus-own program C in this execution gate.

The [frozen preparation](native-conformance-plan.md) audits the original100
selected C fixtures without changing source. Sixty-nine fit its single-source,
canonical-Base/nine-provider contract;31 remain explicit exclusions. Thirty
require other Bend modules and one instead uses a fixture-specific foreign
provider; two module fixtures also have custom foreign providers. They are
neither counted as passes nor silently replaced with flattened programs.

## Execution and provenance evidence

Root ran the original golden-output harness with the native-only adapter,
one case at a time. All138 compilations and Clang O3 program executions pass:
in each role,60 programs return0, while nine deliberately return1 with exactly the expected
runtime diagnostics and output order. These nine expected runtime refusals are
successful conformance cases, not compiler crashes. There are zero unchecked
executions or unexpected exits.

The offline audit independently rerendered every complete output/exit against
the unchanged fixture oracle. All69 in each role also match the corresponding Phase91
JS-hosted candidate's observed status, phase, checked/type-accepted flags,
exit code and complete stdout/stderr/output. That compares execution semantics
on these inputs; it does not claim every possible native-host observation or
diagnostic is exposed by the entry.

Every native compiler command invokes its authenticated B1 or B2 image, with the original source,
exact admitted runtime/Base/provider/cache tuple, one worker and GPU off.
Upstream B1's argv convention omits native07's explicit sentinel. Each successful
native request supplies the actual C file compiled by pinned Clang22.1.4 with
`-std=c11 -O3`; the generated program also runs with one worker/GPU off. Node
orchestrates the processes and unchanged judge; it imports no JS compiler API.

All248 frozen inputs were independently rehashed after both runs. Each retained
raw capture string agrees with its recorded SHA256 and byte count. Each role's69
complete C products total7,868,305 bytes (94,130–186,602 bytes each). Their
recorded digests identify actual emitted products; successful C/ELF files were
removed by the existing `--retain failed` policy after their executions passed.
This keeps the evidence small while preserving source identities, commands,
complete raw outputs and hashes. It is not a claim of rereading deleted C bytes.

The B1 guarded suite finished in207.476 seconds with566,112,256 bytes peak process
tree RSS; B2 finished in214.835 seconds with567,369,728 bytes peak RSS. Both
returned0, without resource stops or changed inputs/artifacts. These are
qualification occupancies including69 Clang builds and executions each, not
compiler latency or generated-program speed measurements. The selected subset is complete;
the original harness correctly leaves its full-suite `complete` flag false.

Raw B1 report:
`selfhost/build/phase92/conformance01/b1/report.json`, SHA256
`646078899ef676c99edf69d6677de81b74d5d7977dcfff35c9c3716a0f39a105`.
Outer guard:
`selfhost/build/phase92/conformance01/b1-guard/process.json`, SHA256
`842414fb9d95af3179bebf6abd4e3bda776822b3905da07ca9bd40282d5cf0ed`.

Raw B2 report:
`selfhost/build/phase92/conformance01/b2/report.json`, SHA256
`5610e7ef6b25d8e7b2cc7ae8dd689c1370c1b2ec0e0475782c5ab894f0c6e258`.
Outer guard:
`selfhost/build/phase92/conformance01/b2-guard/process.json`, SHA256
`31e48dfe3e04fcde39ea9d6248b90395fb147383e2eb382017f41aaf600f040a`.

## Cross-role products and focused rejections

The frozen collector correctly reads each emitted C identity from
`result.nativeHost.output`. The separate
[independent product audit](native69-products01.json) joins those SHA256/length
records by fixture ID and finds69/69 concordant complete C products.
Because successful products are intentionally ephemeral, that comparison must
be described as recorded complete-file hash concordance, not a new bytewise
comparison of retained files.

The malformed-source, type-error and original deep_list_walk controls all pass
in both roles: compiler exit1, no C, the required parse/check phase, and exact
cross-role diagnostic identity. The first two diagnostics also match their
historical native07 text exactly. The six observations took8.286 guarded seconds
and287,981,568 bytes peak RSS, with no resource stop. Their raw source/argv,
stdout/stderr captures and output absence were independently checked offline.

Both native roles return exactly
`check: thm: reflexivity endpoints differ` for deep_list_walk. This shares the
underlying checker message with Phase91's57-character JS fallback, but its whole
text equals neither that fallback nor the12119-character rich page. D04
intentionally discards `DResult.diagnostic` and exposes only the concise checker
error. This result proves the requested negative is rejected without C; it
does not exercise the rich-page renderer or prove its JS stack overflow fixed.

Rejection report:
`selfhost/build/phase92/conformance01/diagnostics/report.json`, SHA256
`1f48ee7a6c11254ac7bea353edd263f9aa50d589e39448800dd6e76a0f5f5c2b`.
The three guarded jobs total430.597 seconds (7m10.6s), including builds,
execution, startup and verification. They are correctness work, not clean speed
samples.

The unchanged native entry exposes no parse-only, check-only or JS emission
mode. Neither this subset nor the rejections qualify the frontend3174,
JS23 outputs, missing31 native100 cases, parallel/GPU execution, unrestricted
imports/foreign providers, or independent proof-kernel correctness.
