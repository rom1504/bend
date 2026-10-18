# Structured IR implementation notes

The first slice lives entirely under
`selfhost/tools/performance/phase106/ir/`; no selected compiler, profile or release
was modified. It supplies an explicit typed graph in Bend, a structural/type
verifier, a shared constant-folding pass, and C/JSON consumers. The common native
runner owns runtime inputs, repeat count, checksum and timing for both consumers.

The real compiler connection is intentionally narrow: two exact lexical
classifier algorithms from `front/lexer.bend` are reconstructed as typed IR and
used in text scanning. General KTerm-to-IR lowering, reference-counted runtime
values, task/GPU scheduling, foreign effects and complete compiler self-builds
remain future work. Allocation/tree/list/explicit-closure workloads exercise more
than scalar arithmetic but use a small experimental malloc/free representation.

The verifier guarantees structural/type properties only. Aligned in-bounds memory,
unique ownership, valid indirect-call signatures and lifetime are fixture contracts.
The C backend and Cranelift adapter use ordinary platform ABI; explicit loops
provide self-tail behavior, while arbitrary return-calls are ordinary calls.
IR shift counts are masked; they are not a claim about large-count Base shifts.

The separately owned law suite targets the exact safe `nx_fold_bin` helper.
Recursive optimization, emission and runtime correctness require independent
finite controls. Root owns all compiler builds and benchmarks; this note alone
does not claim validation, measured speed or promotion.

The later `shared`/`shared_borrow` pair follows the fresh profile's attribution of
`span_fade` to shared constructor destructuring. Each observation in `shared`
retains the parent, reads/retains its child, drops the temporary parent, reads the
child payload and drops the child reference. `shared_borrow` omits that traffic
only because the fixture's original owner keeps the entire immutable aggregate
alive through the loop. Both final refcounts contribute to the checksum before
the two cells are freed. This is a bounded, matched representation ablation;
it neither ports the production RC ABI nor proves a general borrowing pass.

`selfhost/tools/performance/phase106/build_producer.py` snapshots the eight input
files (including the independently owned law bridge), authenticates the installed
Phase103 native compiler and its sixteen runtime assets, emits producer C through
that Bend compiler and builds the executable with pinned Clang O2. It reuses the
existing startup adapter with `BEND_NATIVE_HOST=1` so the producer receives one
program-name slot and runs with one worker/GPU disabled. Both target steps use
the campaign's serial guard and high-resolution child receipts, with separate
emission/build clocks and retained failures. Preparing a snapshot runs no targets.
It does not install or select any new compiler. Root owns scheduled execution.

## Executed result

The final producer-native02 build and44 emitted artifacts completed. Final
controls04 passes both consumers, raw/fold outputs, memory-model observations
and malformed-input refusals. The identifier-verifier repair leaves all44
previous output artifacts byte-identical. See the [completed report](README.md)
and [evidence capsule](evidence/README.md) for precise clocks, source identities
and the separate performance/proof boundaries.
