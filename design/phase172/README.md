# Phase172 — another measured attempt at100s cold self-compilation

Start `fbdf8a0`, branch `selfhost/bootstrap`. The target remains the complete,
fixed3,150,535-byte Phase170 source → native executable, prepared Base, identical
runtime/toolchain and one CPU3 lane. Installed Phase170 remains qualified. The
best experimental Phase171 observation is180.677s versus188.620s;100s requires a
further44.65% reduction. A smaller compiler closure or warm reuse is not success.

## What the earlier investigation rules out

Bendc is a contrasting architecture, not an apples-to-apples few-second oracle.
Its fast self-source differs. On our larger source, tracing and repeated
collection became major costs. It also lowers/raises IR, transforms loaded
functions repeatedly, builds maps and flattens documents. Do not attribute its
speed to work it actually retains. Prior reciprocal experiments rule out copying
our existing String equality or adding memoization as the missing large gain.

Our prepared bodies already share compaction; admitted direct owners already
avoid their generic bodies. The Phase171 borrowed selector now reaches99.535% of
selected verifier calls but saves only1.25%; three smaller cleanup screens are
neutral. No further selector variants or full images are justified by those
results. The new runtime-caller profile identifies actual string construction,
but its5% observed whole-request subset cannot by itself explain80 seconds.

## Two implementation experiments, one controlled execution lane

1. **Deferred pattern rows.** Preserve each row's original body and ordered
   substitutions through pattern-matrix splitting; construct the surviving body
   only at its terminal consumer. Keep freshening, checking and later consumers
   unchanged. This tests removal of complete temporary term trees, not a new
   lookup cache or the earlier unsuccessful compact-App node. Compare complete
   loader results including spans, binder IDs and diagnostics. The whole current
   parse/load region is about30 seconds; that is a ceiling, not a forecast.
2. **Expose ordinary memory fast paths to QBE.** Bendc/mature C can inline cheap
   constructor/allocation/take paths into generated workers. Our verified p125
   ABI still makes external C calls; earlier runtime-C/helper tweaks did not test
   QBE call-site inlining. Test a general postverification emitter expansion for
   source-certified cold construction and/or unique ordinary constructor take.
   Retain the exact original helper on every unadmitted case before mutation.
   Pin runtime layout, capability, static-heap boundary and allocator policy.
   Preserve publication/sealing, copy-before-free, error-state behavior and
   bounded native stack use. No runtime layout or unsupported device/parallel
   contract is silently generalized.

Both implementations remain explicit experimental Bend modules. Transport and
measurement scripts do not implement the compiler transformation. Independent
agents audit bendc assumptions and the ownership/runtime boundary; root owns
all target execution and integration. Shared semantic lowering remains an
alternative if these fail: first establish a real blocked family paying for
both projections and later region reconstruction. A universal IR is not adopted
without that evidence.

## Gates and economics

- Before targets: exact source/ABI contract, independently reviewed fallbacks,
  checked-source acquisition and finite complete-record/output controls. Use
  valid ordinary runtime programs; no malformed runtime/failure probes.
- Fast transfer: actual compiler verifier, loader/checker and lookup computations,
  plus unrelated Map/pattern fixtures as applicable. Host preparation, generated
  runtime and complete request timings remain different metrics. Preserve exact
  complete QBE where the source-work transformation promises it. Runtime emission
  changes require independent complete outputs and actual machine inspection.
- Reject a neutral complete consumer promptly. Prefer at least10% complete
  runtime gain, or a substantial measured reduction in the affected complete
  frontend stage, before acquiring a full compiler. Small wins may remain
  documented without being presented as the100s route.
- For a material winner: combine with the four Phase171 overlays, acquire one
  native candidate, and measure it against the unchanged fixed source/oracle.
  Charge compiler execution, overlapping QBE relay, assembly/link and acquisition
  separately. Repeat a promising clean result. Do not add overlapping profile
  shares or independent gains arithmetically.
- Promotion only after independently justified native reproduction and relevant
  generated-program gates. Preserve protected verifier/proof declarations. Source
  checking, finite testing and BendTT proof remain distinct.

First spend bounded parallel effort on source/provenance and implementation,
then serial small checks; reserve full builds for observed transfer. Record failed
attempts and total guarded execution separately from agent/research time. Use the
retention tools to recover verified obsolete bulk before approaching the5GiB
reserve. No unbounded campaigns, benchmark changes or new backend.

## Ambition without unsupported forecasts

The bounded experiments remove work in the frontend and expose lower-level
optimization across all affected generated functions. The more ambitious route
combines producer/consumer representation changes with a cheaper native execution
ABI, rather than expecting one pass to halve the compiler. The largest route is
one durable checked function representation whose direct/scheduled projections
are demanded only when needed. Current evidence does not yet demonstrate that
any of these delivers100s. The goal is a working, transferable improvement and a
complete cold comparison, not another promise based on static counts.
