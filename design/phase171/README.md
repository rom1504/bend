# Phase171 — 100-second full maintained-source compilation

Start: `25dda2f`, branch `selfhost/bootstrap`. The user authorizes implementation
work toward **100 seconds** for the full maintained QBE compiler. This requires
89.329 seconds (47.18%) less than Phase170's 189.329-second observation. It is a
target, not an estimate or a reason to omit required work.

## Fixed objective

Freeze Phase170's 3,150,535-byte canonical source, SHA256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Compare candidate compiler execution on these exact bytes, authenticated prepared
Base, serial runtime, QBE/toolchain and CPU 3. Include emission, QBE construction,
assembly and linking. Separately report candidate self-builds if their source
changes. A smaller source extraction or a warm cache is not this metric.

The qualified native image is `selfhost/dist/qbe/bend`, SHA256 `0dba3d4d…`.
Current complete request-only observation is 164.616 seconds; compiler+QBE relay
is 183.373 seconds; assembler/linker take 4.615/0.241 seconds. These come from
separate observations and overlapping phases. Their difference is not a measured
QBE CPU duration. Independent source checking and prepared-Base acquisition are
separate costs under the existing metric.

## Investigation and implementation order

1. Preserve the installed release and obtain bounded resource headroom using
   authenticated retention plans. No age-based directory deletion.
2. Refresh current native stage/owner attribution with a diagnostic relink of the
   exact retained N2 object, avoiding another compiler build. Qualify stage-marker
   order and complete output on Map, then capture one full source request. Keep
   diagnostic clocks separate from clean timings; retain unknown attribution.
3. Pick one structural experiment with a credible measured envelope. Parallel
   read-only audits examine semantic preparation, direct/scheduled composition,
   and profiling/resource methods. Do not repeat neutral index zippers, isolated
   tag/equality rewrites, or the already integrated publication/verification work.
4. The first backend candidate is an early verified callable interface for an
   existing closed resumable region. Test whether it unblocks direct callers
   before constructing their generic families. Preserve actual ownership,
   stack-safe frames, source/ABI checks and the independent final verifier.
   No empty-body certificate or arbitrary recursive machine calls.
5. If needed, use the evidence to replace duplicated direct/scheduled production
   with one semantic function graph, or a producer-to-consumer semantic book.
   These are alternatives, not mandatory simultaneous rewrites. Charge conversion,
   invalidation, verification, fallback and destruction in their complete cost.
6. Start with current Lexer/Map requests and a real checker/verifier workload.
   First show removed work and complete output/semantic correctness; then compare
   balanced clean runs. Spend on one full current-source request only after a
   useful transfer result. If no small transfer occurs, reject or revise promptly.
7. Measure an integrated full build, repeat promising measurements, then qualify
   native reproduction and relevant generated-program behavior. Preserve exact
   QBE products where promised; otherwise require independent output oracles and
   representative runtime comparisons. Promote only a separately qualified result.

## Ambition levels and rejection gates

- **1× scope:** measured work elimination in an existing pipeline boundary. A
  small gain may be retained, but it is not presented as the 100-second solution.
- **10× scope:** early callable resumable regions plus one shared function graph,
  avoiding failed candidate bodies, generic family reconstruction and late
  rediscovery. Require transfer beyond one compiler helper before widening.
- **100× scope:** a durable checked semantic representation with demand-driven
  bodies and independently verified units, consumed without building parallel
  legacy representations. Pursue only a working vertical slice; no wholesale IR
  rewrite or new backend on architectural appeal alone.

Reject a primary hypothesis whose measured whole-build ceiling is only a few
percent. Count retained work, not just removed bytes/functions. A lower allocation
count is not a timing result. A valid but unprofitable transformation stays off.
Maintain current supported JS/C/QBE behavior and explicit error/ownership bounds;
minor performance noise is distinct from a material generated-program regression.

## Cost discipline

One root-owned guarded execution lane, CPU 3, explicit deadlines/RSS/disk budgets
and the 5 GiB reserve. Agents own disjoint bounded investigations/prototypes; they
run no targets independently. Close and retain every attempt, including failures.
Use profiling, decisive small falsifiers and exact-code evidence to avoid broad
qualification after each iteration. Record prediction versus outcome, target-lane
cost, source/code growth and remaining uncertainty. Commit and push designs,
validated changes and the honest final report; no PR comments.
