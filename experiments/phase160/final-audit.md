# Phase160 final independent audit

Bounded read-only review of the report draft, tracked metrics/profiles, concrete
full-request receipts, collection-budget runner diff, previous cross-build
audit and source-closure evidence. No target, build, profile or large-artifact
rehash was performed. This document is the only audit output.

**The principal comparison is supported within its stated experimental scope.**
The complete original Phase156 request route runs in both images; input, Base,
checking, optimization, independent verification and all118,227,421 output bytes
are held fixed. The frozen full-source observations are223.237039s QBE and
167.602304s C, a24.9218% reduction, at1043.355 versus4074.691MiB peak RSS.
This measures one complete compiler request, not image acquisition or machine
construction, and is not a fresh qualified self-build or TypeScript ratio.

## Required final-report reconciliations

At review time the README did not yet include the completed collection-budget
ablation present in metrics.json. It should report138.383461s and5057.328MiB for
the same C02 executable with only `BEND_GC_FACTOR=1` added. That is17.4334% less
time and24.1156% higher peak RSS than the default-policy C observation; the
comparison with the QBE observation is38.0105% less time. These remain single
observations, not paired medians, confidence bounds or a universally preferable
default. The6GiB cap is a limit, not an equal-memory condition between roles.

The preservation paragraph's then-current “actual peak was about4GiB” applies
to default C only. Across the completed full-source campaign the measured peak
is about4.94GiB under the factor policy. Update that wording when incorporating
the ablation. The linked experiments/phase160/README.md was being prepared at
review time and must exist in the final commit.

No other material report correction was identified. The parent was notified
of these pending reconciliations before packaging.

## Checks and limits retained

- The receipts select the same C02 binary hash
  `d202c5c3e3973d4f08c10315a04058d43e8efff2b7b4e8ded814918f671da95f`,
  original `old` route, qualified source hash `027e1504…`, and Base `99ac43f2…`.
  All three full-source observations record successful exit, empty diagnostics
  and complete byte equality with the separate Phase152 N2→N3 oracle
  `1032c6a6…`. Deduplication occurs after the child exits and equality passes.
- The factor runner differs from the ordinary boxed runner only in explicit
  factor selection/admission and its reporting. It clears ambient `BEND_*`
  before adding this one override. This is a meaningful collection-policy
  falsifier on one executable, not a new machine-code optimization. It does not
  directly measure allocation counts, live graph size or eliminated GC time.
- C and QBE source bytes differ by recorded whitespace normalization. Independent
  loaded-book structural equality bridges the change while excluding source
  spans; original source checking is separately bound. This supports “same
  implementation,” not literally byte-identical source files. C also uses the
  documented nine-effect adapter, disabled general unboxing, capped reuse scan,
  Clang-O2 and tracing policy. The comparison bundles these execution mechanisms.
- The accepted100ms capture has1,672 samples, zero loss/overruns and99.94%
  sampled-thread/process CPU coverage. Tracing/collection/rescanning has930
  samples (55.6220%), refill98 (5.8612%), and `apply`133 (7.9545%). The first
  table's categories are disjoint; the separately mentioned all-named-GC total
  is a containing category and must not be added to them. The rejected8ms
  capture has36 overruns and contributes no quantitative attribution.
- The approximate93.19/9.82/13.33 CPU seconds scale a separate clean observation;
  they are not directly timed stages or removable-time promises. A single fixed
  period can alias. The older QBE Phase153 physical profile uses a different
  experimental image, so it is explanatory context, not a matched leaf-by-leaf
  subtraction from the new C capture.
- The source census remains accurate:3,085,157→1,697,879bytes;8,265→5,007rows;
  retained4,163defs/294types/550laws; zero mapped runtime owners lost. The new
  closure-check01 receipt independently checks exactly that source hash, but
  no native output/ABI/fixed-point equivalence is claimed. Static retention does
  not rule out changed constructor IDs, tables or compile-time behavior, and
 44.97% smaller source is not44.97% faster execution.
- The historical published source, current bendc self source and our full input
  are kept separate. Decl counts, runtime-owner groups, generic segments and
  emitted function counts are different units. Output text size is not an
  instruction or runtime-speed ratio. Parser fallback remains prepared/unrun.

The defensible conclusion is that execution representation/runtime policy can
materially improve the same complete compiler computation, while the full graph
exposes tracing and memory costs hidden by smaller inputs. The budget ablation
adds direct policy-sensitivity evidence. It does not establish that eliminating
all tracing is safe, that source checks should be removed, or that the current
compiler is now generally qualified under the alternative runtime.

Root reconciliation after review: the final report now includes the138.383s
policy result and memory tradeoff, states the4.94GiB campaign child peak, and
links the completed reproduction README. No measurement was changed to resolve
these reporting omissions.
