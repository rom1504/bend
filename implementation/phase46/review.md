# Phase46 final review and preservation

Independent reviewer `/root/phase44_analysis` checked the final report against
the raw data without executing targets or changing files. Review passed:

- All 24 timing cells and 24 cold cells, with three observations each, match
  their leaf receipts, artifact identities, output oracles and role order.
- All 72 timed samples have valid clocks and batches at least 100 milliseconds.
  Runs are serial; three rotations are not described as fully balanced.
- All timing/cold medians, normalized durations, ratios, emitted sizes and 48
  acquisition fields match the summary. Array's explicit 15-second allowance,
  one 15.060-second sample and the 11.6% largest observed spread are retained.
- Four V8 profiles and four native counter derivatives/eight runs match their
  identities and checksums. Counter deltas and profile fractions recompute.
  Diagnostic instrumentation is not credited as unmodified-binary behavior.
- All 375 job receipts recompute to 743.546613 summed seconds and 743.544286
  occupied seconds, with 928.941 MiB maximum tree RSS and 25.6109 GiB minimum
  available memory. Unclassified elapsed work is not labeled idle.
- The report distinguishes the common batch protocol, different native runtimes,
  reproduced IO.args failure and unchanged Phase45 corpus score.

Root verified all 1,571 archived members by size and SHA-256 after reopening the
6,239,541-byte capsule, then verified the live files remained identical. The
capsule preserves 50,074,422 uncompressed bytes; rebuildable Python bytecode
caches are excluded. The manifest records exact restoration paths and compiler
prerequisites. Failed and corrected attempts remain separately identifiable.

All 29 checked local documentation links resolve. Compiler API, JS runtime,
native runtime and Base hashes match the starting snapshot. Filtering only the
explicitly owned Phase46/documentation paths leaves exactly the initial Git
status. Whitespace checks pass. No compiler rebuild, broad conformance rerun,
release promotion or PR comment was necessary or performed.

The investigation started at 21:57 UTC and reached report/preservation validation
at 22:34 UTC, within the authorized approximate 90-minute bound. Supervised target
work consumed about 12.39 minutes; other time includes code inspection, harness
construction, coordination, corrections, review and documentation. Publication
follows that cutoff and is not represented as measured target execution.
