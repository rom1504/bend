# Phase129: Bend capability audit and current N1 profile refresh

**No new compiler was implemented or promoted.** We audited the selected Phase128
compiler, read pinned and latest upstream sources, refreshed three native-request
profiles and consolidated the next optimization choices. The conclusion is to
keep QBE and test one small reusable semantic/proof boundary, not start a rewrite.

[Research synthesis](../../research/phase129/README.md) ·
[Ranked opportunities and 1×/10×/100× proposals](../../research/phase129/qbe-opportunities.md) ·
[Design](../../design/phase129/README.md) ·
[Measurements](measurements.json) · [Evidence archive](evidence/index.json).

## What we learned

1. **The compiler underuses Bend's proof/type capabilities.** Its 680 `law`
   declarations are forward signatures, not mathematical optimization laws.
   Most assembled bodies have `@unsafe`; its plans are ordinary unindexed data.
   Historical safe helper proofs remain useful, but do not imply a Phase128
   whole-compiler preservation theorem. Proof erasure does not erase runtime
   analysis of unknown user source.
2. **Bend's ownership semantics are already useful.** Phase128's borrowed calls
   and held roots exploit them. Affine source use still does not prove a heap
   node is unshared. The compiler must preserve strict evaluation and avoid
   introducing copies of affine closures/resources.
3. **The largest new practical signal is fixed preparation work.** Every request
   performs the same 1,087,899 decimal-parser entries and 324,069 number-reader
   entries. The cached Base carrier is decoded anew. A genuinely compact/static
   preparation representation can remove work rather than accelerate a helper.
4. **Current unknown libc cost is register copying.** All 218 physical libc
   samples authenticate to the copy region with `p111_set_regs` as caller.
   Register clearing is already zero. Do not repeat Phase127's solved experiment.
5. **Parallelism is not currently a QBE capability.** It needs a fork/join ABI,
   deterministic unit boundaries and requalification of the Phase128 ordinary
   RFC-load template's sequential premise. The mature C backend is the cheaper
   place to test whether a compiler analysis scales before adding QBE workers.

## Measured current-image evidence

Same qualified N1 ELF, frozen source/Base carrier and prior independently
qualified whole-QBE output oracles. Three clean repetitions per input, 8ms/13ms
physical captures, then an opt-in diagnostic runtime linked to the exact same
program object. No full-source compiler build or upstream repeat was needed.

| Request | Clean wall median | Physical / context samples | Decimal active contexts | Usage-query active contexts | String.order active contexts | Physical reclamation | Copy + set_regs leaves |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| lexer | 2.1842s | 886 / 974 | 10.47% | 0.30% | 7.25% | 21.95% | 12.32% |
| closures | 0.6025s | 717 / 832 | 38.84% | 0 sampled | 2.45% | 11.73% | 12.78% |
| Map churn | 2.9052s | 1,176 / 1,275 | 8.74% | 10.97% | 9.29% | 24.28% | 9.25% |

“Decimal” groups `p88_digits`, `p88_digit`, `p88_number`; “usage” groups
`nq_uses`/`nq_uses_list`. Their active-owner buckets are disjoint within a capture,
but overlap physical reclamation/copy categories. Private calls retain the outer
dispatch, and separately dispatched helpers change it. None is an inclusive
source-function cost. Zero sampled usage in closures does not mean zero calls.

The full, explicitly enumerated carrier-decoder definition set occupies
16.04% lexer, 53.53% closures and 11.90% Map diagnostic contexts. This identifies
a larger ceiling than decimal arithmetic alone, not a promised removable share.
The exact names and grouping method are recorded in `measurements.json`.

The event run observes 9.94–35.14 million dispatches, 9.55–34.59 million heap
allocation calls and 21.02–66.87 million requested register words copied per
request. Every case reports zero requested words cleared. Counts are executed
hook events, not live heap volume, DRAM bandwidth or CPU time. Inlined operations
may bypass hooks. Entry-segment counts are not universal source-function calls.

All **55** complete outputs match their frozen QBE oracle with empty stderr.
All 40 sampled captures pass loss/coverage/delivery checks; pooled sample counts
exceed the existing 500-sample screening threshold for each variant/input.
Physical-only clean/scanned medians differ by approximately −0.25% to +2.76%.
Context-only overhead observations are +9.57–17.24%; counter overhead is
+62.09–76.64%. Diagnostic timing is excluded from speed claims. Period-level
variation is retained; these sample counts do not establish narrow confidence
intervals for small functions.

Exact FID table binding covers 48,251 segments. Lexical source-owner grouping
remains conditional on the documented emitter contract; it is not independently
proved source provenance. Four remaining unresolved leaf samples map by exact
disassembly to `memmove@plt`. See the [physical audit](../../research/phase129/profiler-audit.md)
for authenticated callers and per-period stability.

## Profiler changes and cost

We reused the existing generic sampler, runtime hooks, CFI recovery, output
checking, owner binding, quality gates and comparison tools. New Phase129 tools:

- Allocate sample repeats per workload using prior clean duration, instead of
  spending equal repeats on long and tiny requests.
- Bind the selected qualified N1 and exact old oracles automatically.
- Prepare a reversible diagnostic-runtime relink of the retained program object.
- Pool authenticated active-owner contexts across compatible captures and retain
  the corresponding event counts, unknowns and limitations.
- Produce one compact decision table from physical/context/counter evidence.

The next proposed addition is an artifact-bound origin/transition-width sidecar
only where it helps choose a specific transformation. No new stack sampler,
unbounded event stream, or all-pairs transition table was built. Compiler
semantics remain in Bend; Python here orchestrates and analyzes experiments.

Guarded execution: **58.03s physical campaign + 2.54s diagnostic runtime build +
60.06s diagnostic campaign = 120.62s**. Peak guarded process-tree RSS was
154,079,232 bytes (147 MiB). Source/machine audits, literature research,
aggregation and writing are outside that execution clock. Four bounded
investigations ran alongside the coordinator's single target lane. Exact
model-token/quota use is unavailable.

The unchanged generic profiler's **80 offline tests pass**. The first diagnostic
preparation correctly refused a missing `primitives.h` manifest entry before
building anything; the corrected preparation enumerates all quoted headers.
An initial report-only aggregation used the wrong guard-receipt filename and
was corrected to `process.json`; no target reran for either correction.

## Research scope and next work

Primary sources include the local guide, checker, compiler/runtime, Base,
BendTT kernel/translation and paper sources; fresh upstream reads identify the
October 22 equality-adequacy theorem absent from our active pin. Exact selected
source, historical proof bridges, language comparisons and Bend1/HVM exclusions
are recorded in the four audits. Direct recent X posts were not reliably
retrieved; no technical conclusion relies on a mirror quotation.

Keep the Phase128 metrics as the performance frontier: approximately 2× upstream
compiler-request time and 1.65× generated-program runtime. These fresh profiles
do not replace either comparative benchmark or prove new speed gains.

Next choose between the **Base decode/materialization ceiling** and a **complete
borrowed scalar query**; favor the latter for equal gains because it transfers
to generated user programs. A batched use-summary proof supplies a small way
to test whether Bend-native contracts improve both reliability and analysis
reuse. The [ranked plan](../../research/phase129/qbe-opportunities.md) gives
conditional gains, implementation/qualification estimates and rejection tests.
