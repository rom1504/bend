# Phase91: current-release generated-program continuity

Both current compiler roles pass the complete original performance-corpus
continuity gate: **46/46 exact JavaScript modules** and **24/24 exact optimized
C preprocessor outputs**. This closes the Phase90 artifact-coverage gap without
running another program-speed benchmark. The 23-source JavaScript corpus and
12-family C corpus are separate; the earlier catalog-derived CPP45 alone did
not establish this result.

| Current emitter | Exact JS modules | Exact C preprocessing | Guard occupancy | Peak tree RSS |
| --- | ---: | ---: | ---: | ---: |
| Checked/equality-derived B1 `6bf8e093…` | 23/23 | 12/12 | 18.603 s | 489,320,448 bytes |
| Genuine compiler07 B2 `284f6e9b…` | 23/23 | 12/12 | 14.018 s | 498,769,920 bytes |

All 35 current B1 outputs are also byte-identical to their B2 counterparts.
The offline summary independently re-read those products and reverified all
813 plan input pins. Guard occupancy totals 32.620 s; these shared-process gate
clocks include preparation, emission, verification and preprocessing. They are
not the fresh-request B1/B2 compiler-latency metric and should not be divided to
claim an optimization. Retained evidence occupies about 12.8 MB.

## What now carries forward

| Generated-program target | Last measured upstream-relative result | Current qualification |
| --- | --- | --- |
| JavaScript | Phase66: 1.049282× equal-point; 1.046987× equal-source | Exact current B1/B2 modules for all 23 sources / 45 points; identical Base, legacy runtime and direct runtime bytes |
| Native C | Phase78: 1.066776× equal-family | Exact current B1/B2 optimized CPU preprocessor output for all twelve timed batch fixtures |

The JS result comes from 669 historical samples. Its execution clock excludes
compilation, imports, first call and warmup. The C result comes from 108
historical intervals with one thread and GPU off, excluding acquisition, Clang
and warmup. These remain dated measurements whose tested program artifacts are
now covered by current-release continuity. **There are no new execution timings
in this phase's continuity gate**, and neither aggregate predicts every program.

JavaScript is compared with the raw Phase66 module bytes preserved through the
Phase82 join. Current B1 and B2 both match every byte. The source/runtime/invocation
mapping for the existing 45 observer points is unchanged; equality checks do not
count as additional execution samples.

C uses the actual twelve batch fixtures: Numeric, Array, Closures, Tree, Map,
Lexer, List pipeline, BST, Expression, Array.map, Tape observer and String order.
These are not the related catalog observation wrappers. The complete raw C
changes on all twelve sources, primarily because final indentation was removed
and the canonical runtime text changed. The current C totals 4,335,323 bytes per
role, versus 4,561,691 historical bytes. Raw-C equality is therefore not claimed.

## Exact native comparison boundary

Both versions are passed through the exact recorded Clang using the historical
`-isystem …/include/clang -std=c11 -O3` flags followed by
`-x c -E -P -fminimize-whitespace -H -`. They use the same `<stdin>` filename,
working directory, cleaned environment and regular-file descriptors. Every
preprocessor output byte matches. There is no custom C-token rewrite, string
stripping, ignored function or foreign-code exclusion. All observed headers
match on both sides, are rechecked against the prebound set of 173 headers,
and number 163 per invocation.

All twelve FID counts remain unchanged, between 136 and 490. The final runtime's
large-table accessor is inactive below 4096; the O0 fallback guard likewise does
not alter optimized code. Preparation separately verified the exact two approved
runtime edits against each old C oracle. The complete comparison demonstrates
that formatting and the inactive runtime changes preserve the optimized CPU
translation input on this corpus. Matching temporary preprocessor files were
fully byte-compared, hashed and removed, leaving their identities, stderr/header
records, original oracles and current C outputs in evidence.

This is stronger than spot-checking output tokens but is not an ELF-binary
identity proof. The historical execution result remains relevant under the same
Clang recipe/runtime behavior; no fresh machine-code timing or GPU result is
inferred. The historical C score also hides slower Tree, Expression and Array.map
families. Current native compiler-host speed and self-compilation are different
metrics and do not replace generated-program performance.

## Reproduction and evidence

[Method and commands](../../selfhost/tools/performance/phase91/continuity/README.md),
[design](../../design/phase91/continuity.md), and
[data-only summary](continuity.json).

The frozen plan is `selfhost/build/phase91/continuity01/plan.json`, SHA
`b1af8a22d2143eeedc00ea91790d765da2d72a9326c803f46286917fe9bea18d`.
Root executed the two commands serially under the existing 180-second / 2-GiB /
CPU3 guards. Both completed successfully without resource stops. Agent work
was restricted to preparation, source audit and offline result verification.

Raw current reports are
[B1](../../selfhost/build/phase91/continuity01/b1/report.json) and
[B2](../../selfhost/build/phase91/continuity01/b2/report.json).
Historical measurements are
[Phase66 JS](../phase66/evidence/runtime-selected07-full.json) and
[Phase78 C12](../phase78/runtime.json). No compiler source, runtime, oracle or
installed release was modified by this gate.
