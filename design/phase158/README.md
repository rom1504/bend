# Phase158 — reproduce bendc's published self-compilation benchmark

Start from `b0481bf`; preserve qualified Phase152 and all production sources.
The published 2.13s C-built / 2.55s AArch64-built self-emission table first appears
in bendc `9c54842eb5756803af599583ca49870d1e09186a`, using an M4 Pro. Its matching
CI Base is Bend2.0.32. Today's bendc main is still56edcc65 but substantially
larger; do not silently use it to validate an older timing. The earlier3.5s/20s
native-vs-Clang full-build claim has a separate source/version boundary.

Acquire exact historical compiler imports, foreign effects, runtime and C seed.
Authenticate release2.0.32 against the author's checksum. Build the seed with
the published Clang-O2 policy. First run the exact Makefile no-check self-emission
policy and compare its entire output to the committed seed. Stop on a real
compatibility/output failure rather than normalize it away. This is reproduction
of a public seed, not DDC, a theorem or a new qualified compiler.

Measure no-check emission, check-only and checked emission separately. The
README omits exact flags/raw receipts for the headline table, so do not infer
whether its emission row includes checking. Best-of-nine emission / best-of-five
checking mirror the published summaries, while also retaining all observations,
medians, CPU and peak RSS. Count successful outputs only. Use small pilots to
set bounds; a resource refusal is not a timing result. Report acquisition and
machine construction separately from execution.

Start with one worker/CPU3/GPU off. Audit the published worker policy before any
separate bounded multicore run. One root target lane, no concurrent measurements,
default2GiB RSS,16GiB available RAM floor,5GiB disk reserve, explicit disk budgets
and guarded fresh roots. Existing verified archives permit journaled reclamation
of closed Phase157 workload products while preserving seed/runtime inputs.

This host is x86_64: bendc's AArch64-only direct native path and Apple GPU timings
cannot be reproduced here. Do not emulate them and present emulation as a speed
comparison. Prefer exact supported measurements and a clear list of unresolved
hardware/recipe differences over another broad optimization campaign. Commit
reproducible evidence and an honest report; do not publish PR comments.
