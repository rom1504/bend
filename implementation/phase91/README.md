# Phase91: current compiler scoreboard

The installed Phase90 compiler retains the previously qualified program outputs.
Fresh compilation ratios are **1.408× B1 / 1.307× B2 for JS**, and
**1.454× B1 / 1.230× B2 for C**, against pinned upstream TypeScript under Node.
The broad frontend refresh exposes one pre-existing B2 error-page mismatch:
**3,173/3,174 exact reference agreements**. The invalid proof is still rejected;
its deep diagnostic overflows B2's JavaScript stack and falls back to short text.

[Design](../../design/phase91/five-metric-refresh.md) ·
[Machine-readable scoreboard](summary.json) ·
[Definitions and fast validation](../../docs/self_hosted/METRICS.md).
No compiler implementation, runtime or installed image changed in this phase.

## The five axes

Ratios are our elapsed time divided by upstream elapsed time; lower is better.
B1 is checked/equality-derived `6bf8e093…`; B2 is genuine self-emitted and installed
`284f6e9b…`; source is `4ffae2a3…`. Upstream remains pinned at
`059266225b77c8ca256ac6b25ee5c21449bab151`; this is not a new upstream migration.

| Axis | Current result | Scope and freshness |
| --- | --- | --- |
| Compiled JS program speed | **1.049×** upstream JS (1.047× equal-source) | Historical 669 samples /45 points /23 sources, now joined to both current roles by complete module equality |
| Compiled C program speed | **1.067×** upstream C | Historical 108 intervals /12 families, now joined through complete historical-Clang O3 preprocessing equality |
| B1 compilation request | **JS 1.408×; C 1.454×** | Fresh three rotated rounds, original JS23 and C3 corpora, Node24.18/CPU3 |
| B2 compilation request | **JS 1.307×; C 1.230×** | Fresh genuine B2, same request boundaries and sources |
| Conformance | **Frontend 3,173/3,174 exact; selected C 100/100 pass** | Fresh B2 candidate against verified historical reference; one diagnostic fidelity gap, not false proof acceptance |
| Simplicity | **32,692 physical /26,693 code lines; 132 Bend modules** | Fresh manifest-only census; no source reduction or numeric concept-reduction claim |

The two generated-program rows are one axis with two targets. Those speeds are
**carried-forward historical measurements, not new execution timings**. The
fresh continuity gate checks 46 complete JS modules and 24 complete optimized C
preprocessor outputs. All 35 B1 outputs also equal B2 byte-for-byte. The C source
text changes, but its entire preprocessed input to the original Clang recipe is
identical. This does not claim ELF identity, another optimization level or GPU
coverage. See [continuity](continuity.md).

## Compilation: request work versus loading

| Target | B1 request /TS | B2 request /TS | B1 imports+API+request /TS | B2 imports+API+request /TS |
| --- | ---: | ---: | ---: | ---: |
| JS23 | 1.408445× | 1.306596× | 0.969726× | 0.981387× |
| C3 | 1.453748× | 1.230042× | 1.167128× | 1.039948× |

The combined clock excludes process launch, benchmark checks and Base setup;
it is not whole-process CLI latency. Base decoding stays inside ordinary Bend
requests; TS ordinarily loads/checks Base. B1/B2 JS preparation includes its
qualified annotation product; C preparation preserves the original mandatory-
cache-only policy. All roles use the same Node binary. Three-sample ranges are
descriptive, not confidence intervals.

All 234 timed complete-output checks pass, as do the 78 role/source setup
outputs. [Per-source medians, ranges and complete samples](compilation.md)
show where aggregate parity is still missing. JS B2 Map takes 1,019 ms versus
562 ms upstream (1.815×), active raytrace 907 versus 503 ms (1.804×), while
Numeric recurrence takes 218 versus 333 ms (0.654×). Both generations win on
5/23 JS request medians. On C3, B2 ratios range from 1.144× Array to 1.302× Lexer.

Historical request ratios were JS 1.402×/1.321× and C 1.673×/1.328×. The fresh
C figures are lower, but no old compiler was measured alongside the current one:
this refresh does not causally attribute a percentage improvement to Phase90.

## Conformance and the newly exposed gap

The full 1,587-fixture frontend run finished every parse/check observation. It
preserves the four shared check-oracle exceptions for fixtures whose expected
rejection belongs to a later stage. One additional exact mismatch is
`page/deep_list_walk.bend`: B2 returns a 57-character fallback instead of the
12,119-character expected error page. Both correctly reject the invalid proof.

Four isolated traced controls reproduce the difference: current B1 and TypeScript
print the full error, while current B2 and preserved Phase82 B2 both log
`diagnostic rendering unavailable: Maximum call stack size exceeded` and return
the same fallback. The gap predates Phase90 and is specific to the B2 execution
shape under the qualified 4-MiB stack. No larger-stack workaround or compiler
patch was substituted into the scoreboard. Full self-reproduction and unchanged
frontend source do not establish equal diagnostic behavior across generations.

The selected C execution run freshly passes **100/100**, with all observations
unchanged from the earlier qualified candidate. The retained TypeScript reference
remains 93/100; its seven historical failures are not candidate failures and
were not rerun. The [strict original collection](conformance-results01.json)
correctly refuses an all-pass frontend claim; the
[observational collection](conformance-results02.json) is complete with
`passed:false` and retains the exact discrepancy. See the
[isolated diagnostic audit](deep-list-diagnostic.md).

[Conformance evidence](conformance.md) keeps the historical JS union separate:
1,045 distinct golden passes, 123 unprintable-main exemptions, one shared
Process.run failure and one graphics deferral. It was not rerun here. Thirteen
unsupported native APIs remain; native/GPU/parallel completeness and independent
kernel proof are not established by these finite gates. The separate native07
public compiler host still supports its documented single-source, canonical-Base,
nine-effect contract.

## Simplicity and the native compiler host

The [census](simplicity.md) verifies the exact checked snapshot and installed
release. There are 3,876 definitions, 658 laws and 146 types; these are structural
counts, not semantic-concept counts. Separate host/runtime/provider sizes and
image bytes are listed without double-counting generated source. Since Phase66,
maintained Bend source grew about 14.7%. This phase adds zero compiler lines.

Native07 is a different host/source profile from the JS B1/B2 latency campaign.
Its separate Phase90 six-source result remains 0.678× TS/Bun process time,
with differing Base and worker boundaries; Map loses at 1.706×. Full native
self-emission remains 164.322 s versus a separate JS B2 observation of 51.672 s.
Neither number replaces the fresh original-corpus ratios above. They are not
new measurements in this phase.

## What to do next

First make the diagnostic printer stack-safe with this one negative fixture as
the fast control, then qualify the change in both B1 and genuine B2. That closes
a concrete visible conformance gap without broadening the compiler language.
For compilation performance, keep the native07 Map/Base investigation and the
controlled same-source upstream-C versus own-C comparison from Phase90; the
fresh JS corpus also identifies Map and raytrace requests as useful controls.
There is no evidence here that another broad rewrite or fresh runtime campaign
would be a better first step. Generated-code changes should keep passing the
roughly 33-second original-corpus continuity gate.

## Preservation and reproduction

Root ran target processes serially under the existing execution lock and memory
limits. Three agents prepared methods, counted source and audited results
without running targets. No compiler rebuild or full self-compilation was
needed. Failed observations and the strict failed conformance collection are
preserved rather than relabeled passing. The [execution ledger](execution-ledger.json) records 249 completed guarded jobs,
737.680 seconds (12m18s) of target execution, zero overlap/resource stops and
598,233,088 bytes peak RSS (570.5 MiB). The interval between the first and last
guarded job was 19m27s; this excludes earlier method preparation and later report
work, and is not quota usage. Three nonzero exits preserve the broad frontend
discrepancy and its two B2 reproductions. The
[verified raw capsule](../../selfhost/tools/performance/phase91/evidence01/receipt.json)
retains reports, progress, observed failures, inputs and current generated outputs.

[Reclamation](reclamation.json) records three obsolete Phase90 raw C copies
removed only after equality against a committed archive. All final native07
inputs/outputs and installed images remain. Recover the exact obsolete copies
into a fresh directory if needed:

```sh
python3 -B selfhost/tools/performance/phase91/reclaim.py restore \
  --out /tmp/phase91-restored-historical-c
```

Use the [continuity commands](../../selfhost/tools/performance/phase91/continuity/README.md)
and [compilation commands](../../selfhost/tools/performance/phase91/compilation/README.md)
with fresh output directories. Keep reference identities, clocks and corpus
weights unchanged. Unrelated Phase6/68 work is preserved. No PR comment was posted.
