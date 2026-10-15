# Phase92: qualify the native compiler chain

## Question and frozen subject

Measure the native host explicitly. Phase91's B1/B2 compilation ratios and
native100 conformance used JavaScript-hosted compilers. They do not answer how
the compiler executable built through C performs or whether its outputs agree.

Use the exact Phase90 native source `compiler-noindent.bend`, SHA256
`d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097`.
Build a new B1 with pinned upstream0592662's C backend and the same Clang22,
O2 and link flags as native07. Compare it with native07, whose unpatched own-C
input and self-emitted C are byte-identical. The source is a native entry/profile
of the shared compiler; it is not the canonical JS entry assembly.

The backend runtimes and executable effect adapters necessarily follow their
respective ABIs. Both compilers receive identical input sources, Base cache,
emission runtime and nine emission effect-provider assets. Record argv handling:
the upstream runtime supplies argv[0], while native07 needs its explicit sentinel.
Do not patch reference output to make backend implementations identical.

## Sequential gates

1. Verify and reclaim only obsolete files present byte-for-byte in committed
   evidence capsules. Preserve receipts and a deterministic restore procedure.
2. Check/load the frozen source with pinned upstream, emit C, build native B1.
   Keep failures and resource ceilings; do not retry an OOM with higher limits.
3. Smoke both hosts, then run a rotated matched six-source compilation screen.
   Measure complete process wall and compiler-reported request time separately.
   Exclude verification from request time and state cache/setup boundaries.
4. Attempt native B1 self emission under a bounded deadline. An exact comparison
   with native07's existing self C connects the two native generations without
   spending another five minutes rebuilding identical C. Report timeout as such.
5. Qualify source-admissible original generated-program benchmarks and native100
   fixtures through both native hosts. Compare full C and observable outputs;
   measure generated-program runtime separately where usable. Keep exclusions
   explicit. The frozen native entry only supports checked C emission of a single
   Base-importing source: it cannot expose parse-only/check-only or JS results.
6. Consolidate all five metrics, limitations, commands, hashes and next steps in
   implementation/phase92 and the native guide. Commit/push design and evidence.

## Interpretation and resources

No numerical carryover from a JS host is labelled a native-host measurement.
C output identity can establish preserved generated code for specified sources;
it does not constitute a new runtime timing campaign. B1/B2 native comparison
and native/upstream TypeScript comparison are distinct denominators. Full compiler
self input is a separate workload from the small-source geometric mean.

Root alone runs guarded targets serially; three offline agents prepare build,
comparison and conformance methods. Normal jobs use CPU3,2GiB RSS/4GiB available;
full Clang uses CPU2,3,6GiB RSS/16GiB available. Maintain160MiB free disk and
regular progress updates. No production compiler changes or PR comments are
planned. A necessary method correction gets a versioned receipt, not a rewritten
historical result. Correctness, measurement and promotion remain separate.
