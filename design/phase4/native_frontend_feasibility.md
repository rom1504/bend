# Native frontend validation: feasibility gate

The proposed mechanism is a finite native parse/check batch with one validated Base prefix, not repeated native program compilation. [P4-017](../../experiments/phase4/P4-017-native-frontend-feasibility.md) records its bounded investigation and decision.

The current native graph host accepts explicit filesystem manifests but exposes only program/library emission. The existing adapter correctly declares parse/check unsupported. Its pipeline uses plain check_book diagnostics, whereas current typed-driver check mode preserves located diagnostic rendering, exact-prefix reuse, TODO/check-phase behavior, specialization errors and driver_report stdout. A mode switch must reproduce all of those boundaries; compile success is not a check observation.

First establish whether a small wrapper can preserve those observable stages, and measure the current fresh-request floor against the already validated B1 workflow. Stop before a C build if the missing lifecycle/protocol is the larger task. Previous measurements already reject uncached native requests as a general small-loop replacement. A useful successor needs explicit in-process Base ownership/cache reuse, ordered per-request source reads and discovery, complete observations, bounded memory and timeout/recycle semantics.

If a wrapper survives that assessment, begin with positive, parse-negative, type-negative, TODO and imported-error controls against current B1, proven H and live pinned TypeScript. Preserve exact port diagnostics; retain known port/TypeScript differences. Only measure full observations that pass their selected-mode gate. No full frontend sweep is justified before a convincing repeated small-batch result.

## Completed feasibility result

The [selected controls](../../implementation/phase4/native-frontend-feasibility.md) confirm that the current native adapter has no frontend lane and its compile diagnostic/report contract differs from current B1/H check. A fresh-process mode switch is not a correct prototype. Stop before a C build; a separate finite-batch wrapper must first preserve seeded Base, detailed diagnostics, ordered discovery and bounded result transport. The existing cached B1 loop remains the recommendation. This decision supplies no native parse/check benchmark.
