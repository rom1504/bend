# Phase129: Bend-native compiler research and refreshed optimization priorities

Starting fork HEAD: `a4ecad0e2e33944814fbad0b53705c2460e60f8a`, 2026-10-23.
Selected compiler: qualified Phase128 source02. This phase researches and ranks
opportunities; it does not change compiler semantics or installed selection.

## Questions and bounded work

1. Audit Bend2's live/dead proof discipline, quantities, erasure, runtime and
   parallelism against primary source. Separate the active `0592662` language
   pin from latest upstream and distinguish Bend2 from older HVM designs.
2. Audit the selected source and manifests, rather than assuming historical
   proofs and prototypes are executed by today's compiler.
3. Refresh physical profiles of three frozen requests using the existing
   qualified N1, sampler and independent whole-QBE oracles. Budget repeats per
   workload to reach useful sample counts; retain all quality failures.
4. Consolidate throughput and generated-program opportunities with conditional
   gain ranges, integration/qualification costs and cheap rejection tests.
5. Propose a small proof-carrying boundary and more ambitious architectures.
   No broad rewrite, new backend, full self-build or production promotion.

Three bounded investigations cover language/proofs, selected-code contracts,
and runtime/parallelism. Root owns synthesis and one guarded target lane.
Disk is limited; retain compact receipts and profiles, not another compiler image.

## Ambition ladder

- **1× scope:** remove repeated measured work and extend existing borrowed
  contracts; add profiler views that answer a concrete decision.
- **10× scope:** a small checked semantic plan shared by multiple analyses and
  emitters; resolved identities and borrowed recursive queries, with a local
  soundness theorem and real performance discriminator.
- **100× scope:** a compiler over immutable, compact, typed units with checked
  transformation certificates and deterministic parallel scheduling. First
  demonstrate one end-to-end useful unit, not a wholesale rewrite.

These are ambition levels, not promised speed multipliers. Rank single-core
request time separately from warm-service throughput, multicore scaling and
generated-program runtime. Source proofs do not automatically establish backend
correctness, raw-pointer safety or dynamic uniqueness.
