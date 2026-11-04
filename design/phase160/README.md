# Phase160 — explain the self-compilation gap

Start e2b707d, selfhost/bootstrap. The user asks why bendc checks/emits its own
compiler in seconds while ours requires minutes, and what that implies for our
self-compilation. Phase159's allocator ablation is evidence about execution
headroom, not an answer to the complete gap.

Separate two axes: amount of compiler work versus cost of executing the same
work. Prioritize identical compiler implementation, inputs, checking and output
boundaries. A full cross-built compiler is ideal but not worth an unbounded
compatibility port; complete dominant frontend/backend stages are the fallback.

1. Audit whether bendc can compile our maintained compiler or complete stages;
   inspect existing exact extraction, source normalization and IO adapters.
2. Choose the smallest complete real self-compilation stage that accounts for
   meaningful full-source time, with an independent complete result oracle.
   Compare upstream C, our QBE and bendc execution where economical. Count input
   preparation and teardown; separate diagnostic samples from clean timing.
3. Compare the actual pipeline/work representations with historical bendc:
   checked declarations, intermediate forms, passes, ownership and call boundaries.
   Distinguish observed source structure from dynamic hotness and causal evidence.
4. If a complete-stage comparison shows headroom, profile it and name the
   smallest falsifying transformation. Do not start a speculative runtime rewrite
   or qualification campaign. Preserve production source/qualified selections.

Two bounded agents audit feasibility and comparison boundaries. Root owns one
CPU3 target lane,2GiB RSS/16GiB available floor and5GiB disk reserve. Before new
jobs, reclaim only exact archived Phase153 duplicated QBE/object/output files,
retaining source/maps/profiles/reports and all qualified compilers. Retain
authenticated pruning and restoration receipts. No broad deletion by phase age.

Record hypotheses, failures, costs, complete oracles and scope. Commit/push the
investigation and reproducible evidence; no PR comments. Initial target is a
decisive comparison, not a promised whole-compiler speedup or arbitrary run count.
