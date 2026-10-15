# Phase94: a production-connected law-backed optimization

## Question and baseline

Can a small, independently checked specification constrain a real native
compiler optimization without making the iteration loop prohibitively slow?
This is a bounded pilot, not a whole-compiler correctness or parity claim.

Baseline is `90f40c4`, with the Phase90 installed release and Phase92 native
source D04 unchanged. Phase93 reports native generated-program runtime of
1.114840x upstream over 44 measurable points, 1.139377x when weighting the
23 original sources equally. Full-source native compilation observations are
140.262s for upstream-built B1, 152.191s for own-built B2, and 48.394s for
TypeScript/Bun. B2/B1 is only 1.085x on that source. A local backend improvement
must not be presented as explaining the whole native compilation deficit.

## 1. Establish independent verification

Provision the actual upstream-required Lean 4.34.0 locally in the build tree,
using official release assets, with bounded disk and memory consumption.
Preserve source/tool identities and failed attempts. Do not patch the pinned
kernel or substitute assumptions to obtain a successful verdict.

Run the existing Phase67 safe elaboration through the unmodified BendTT kernel,
then require rejection of its deliberately false equality. This repairs the
existing verification foundation but proves only the historical model. It does
not establish a connection to the production emitter.

## 2. Select and measure a tractable operation

The first candidate is native environment preparation in `bridge.bend`.
`nc_let_atom` and `nc_let_emitted` filter the old environment for body liveness,
append a new binding, then partition the already-filtered environment with the
same liveness predicate. Investigate eliminating redundant list construction
and membership work while preserving order and the new binding's drop action.

Use a small extracted control compiled by the actual native toolchain, operation
counts/scaling, and existing native compilation workloads. Distinguish helper
speed from end-to-end compiler speed. Profile or count real calls before
claiming the operation is an important bottleneck. Preserve slow/failing cases.

## 3. State a law connected to production

Define a simple reference operation independently of its optimized implementation.
The theorem must cover arbitrary finite ordered input, including empty lists,
duplicate binding identities, retained/dead new bindings, and all liveness
decisions admitted by the abstraction. Preserve both the live environment and
the ordered drop information. Avoid proving only an incidental example or a
function's ordinary return type.

Prefer a small safe generic helper imported by proofs and called by production.
The exact helper bytes checked by the kernel must be bound to the candidate
compiler source. Unsafe predicate/representation adapters, liveness analysis,
ownership rendering, C semantics, errors, scheduler, and allocation remain
explicit trust boundaries unless separately proved. Do not assert verification
of those boundaries by association.

Freeze the reference law before optimizing. Changes to the specification require
a recorded justification, not merely a failing proof. Require deliberate
mutations such as reordering retained bindings or omitting the required drop
to be rejected by proof or separately identified boundary controls. A normal
compiler regression suite is evidence of finite conformance, not a proof.

## 4. Optimize, measure, and decide

Use tiny proof/check controls and extracted native loops first. Only a feasible
production-connected candidate earns a checked compiler build. Compare complete
generated C against the existing compiler on focused semantic fixtures and the
original corpus. Exact products preserve their existing program performance;
changed products require selected execution/performance checks.

Measure compilation with balanced baseline/candidate ordering and retained raw
samples. Do not claim a gain from a helper microbenchmark alone. A small or
neutral gain may still answer the proof-methodology question; a performance or
complexity regression is grounds to retain the experiment without promoting it.

Reserve full native self-emission/rebuild, broad conformance and release
installation for a candidate whose benefit justifies their cost. The pilot can
finish with an independently checked, production-linked isolated candidate and
an explicit non-promotion decision. Do not silently replace qualified images.

## Resource and reporting policy

Root runs compiler, proof and benchmark targets serially under the maintained
process-tree guard. Two agents may inspect proof design and methodology offline;
they do not run targets or duplicate builds. Initial feasibility is timeboxed
to half a day; a first complete production-connected proof could take 2-5 working
days. This estimate is not a promise of speedup or a requirement to consume time.

Keep at least 512MiB disk reserve for toolchain provisioning and prefer the
minimal runnable official distribution. Use fresh run directories, preserve
failures, hash checked artifacts, and record guard occupancy separately from
elapsed research time. No quota percentage is inferred from tool use.

Record each hypothesis in `experiments/phase94`, reusable proof/benchmark
instructions in `selfhost/proofs/phase94` and `selfhost/tools/performance/phase94`,
and outcomes in `implementation/phase94`. Report proof scope, mutation rejection,
compiled-program continuity, compilation speed, conformance and source complexity
separately. Commit and push the design and completed evidence; no PR comment.
