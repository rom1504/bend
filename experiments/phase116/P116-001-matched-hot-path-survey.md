# Phase116: locate the remaining QBE execution gap

Start at e096a46 on 2026-10-21, 05:05 UTC. Budget 30–60 minutes. Root owns
one guarded CPU3 lane; two agents perform source/evidence reviews only. No
compiler optimization or installed selection change in this investigation.

Compare the same frozen Phase93 source and complete output oracle across
selected Phase114 QBE, selected Phase102 selfhost C, pinned upstream C, and
fresh upstream/selfhost JavaScript. These backend producers have different
implementation histories; the comparison does not isolate QBE instruction
selection from our lowering. Preserve their identities and exact tool flags.
Use the existing benchmark wrapper and frozen 50ms repetition profile, scaling
iterations uniformly for clearer timings. Record cold process wall time and the
in-program interval separately; three rotated rounds. JS uses the same Node
engine for both producers. This is a deliberately diagnostic subset, not a new
45-program broad score or blind holdout.

Cases cover arrays (local-fold128), trees, lists, tagged lexer state, active ray,
scalar arithmetic, map churn and edit distance. Inspect actual executed symbols
before attributing hot time to static refusals or helper counts. Main-thread
signal-PC sampling reuses the existing benign diagnostic sampler on unchanged
native ELFs, with two periods, exact outputs, recorded overruns/drop counts and
thread CPU coverage. Retain unreliable profiles explicitly; exclude them from
quantitative attribution. Profile intervals are not clean timings. Add bounded
V8 CPU profiles where useful, keeping startup/JIT/GC separate from generated
program work. No fault-injection probes or permission bypasses.

Prefer existing binaries and objects. Disk is constrained: exact hash-checked
hard-link dedup of immutable generated artifacts may retain all paths/bytes.
Do not delete sources, executables, runtimes or evidence. All normal target
runs use the existing serial resource guard (2GiB RSS/16GiB available floor).
No full self-host rebuild. Preserve a compiler workload profile if economical.

Deliver matched timings, actual hot symbols/instructions, alternative explanations,
and ranked general transformations with conditional gain estimates and cheap
falsifiers. Use Amdahl bounds to reject single-category parity claims. Distinguish
program speed, compiler execution, acquisition and experiment cost. Commit/push
methods and bounded evidence; no PR comments.
