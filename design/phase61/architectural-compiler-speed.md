# Phase61: reduce compiler work through representation and pipeline changes

The user authorizes implementation, ambitious architectural experiments, focused
validation and qualified integration, with commits/pushes throughout. The target
is parity with pinned TypeScript compilation, potentially better, while retaining
the compiler written in Bend, correctness and generated-program performance.
No upstream PR comment is authorized. Phase60's information-only restriction
applies to its closed campaign, not this new implementation phase.

## Baseline and target

Phase60 compares genuine Phase58 last01 B2 against pinned upstream
`018751270e800bc222a93dad7f257083ee53a5f7`. The 45 runtime points correspond to
23 distinct library compilations. Clean equal-source import/API/first-request
ratio is 2.4613; compile-only ratio is 3.7943. Later calls remain warming.
Baseline B2 SHA256 is
`a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`;
checked B1 remains
`641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.

Diagnostic per-input stage means give a planning budget, not an optimization
forecast or clean geometric-mean decomposition:

| Work | Current B2 mean ms | Ambitious budget ms |
|---|---:|---:|
| Import/API | 103 | 103 |
| Cache/identity | 192 | 25 |
| Loading | 351 | 160 |
| Checking/completion | 656 | 200 |
| Backend | 457 | 150 |

The illustrative sum 638 ms versus TS's approximately 703 ms would yield first
request parity, but not compile-only parity. Each target needs new measurement.
Do not add overlapping profile-family percentages or claim these budgets have
been attained. Full compiler-image generation remains a separate workload.

## Research-guided changes

Read the existing source-based research in
`research/compilers_architecture_and_techniques/`, the Phase57–60 findings and
`docs/self_hosted/` before borrowing an idea. Existing indexes, native arrays,
substitution stability, literal choices and dependency deduplication are already
implemented. Build on those rather than counting them as missing features.

1. **Environment-backed checking slice.** TS's higher-order binder bodies differ
   from our eager `subst`/`core_rebuild` path. Prototype a separate telescope
   cursor that carries ordered substitutions, materializes the demanded domain,
   and preserves existing normalization on fallback. Start without a public
   KTerm ABI replacement. Prove spans, dependent binding, beta/canonicalization,
   error order and malformed/API behavior; merely finding no matching variable
   is insufficient. Expand only after a real request benefits.
2. **Owned and compact working data.** Current trie nodes reuse full definition
   records and ordered book updates can repeatedly filter linked lists. Begin
   with a batch overlay that preserves exact sequential winners and event order,
   hashes/collisions, BookCache metadata and empty-input identity while rebuilding
   the event list once. A typed compact carrier follows only with an explicit
   ABI/ownership plan; never add conversion to every lookup or turn shared
   snapshots into mutable aliases.
3. **Structured backend transport.** Carry text chunks, demanded-use facts and
   reference facts through statement/definition assembly; render at String
   boundaries. Initially adapt existing expression strings once so existing
   lowering decisions remain authoritative. Preserve exact text when possible,
   ordered evaluation, erasure/liveness, SCC closure, layout context and budgets.
   Do not reuse a rendered body across pruning when its context changed.
4. **Remove generic reconstruction/materialization.** Investigate unchanged
   String-origin reconstruction and direct primitive metadata selection as
   independently measurable complements. Keep canonical ownership, Unicode,
   partial application, demand, shadowed-name and host-boundary refusals.
5. **Shared frontend state and cache transport.** Profile/simplify ordinary
   cache loading without weakening invalidation or payload validation. A fully
   checked Base resume must retain declarations, completed output, specialization
   state, fresh IDs and diagnostic provenance. Both current pipelines recheck
   Base; a source-only cache is not a proof that its events can be skipped.

These are separable experiments. A coherent winner may combine them, but each
candidate first needs a useful counterfactual. Record rejected changes and stop
expanding an architecture whose actual request cost does not improve.

## Fast loop and correctness

Root alone launches compiler/program targets, serially on CPU3, under one
existing guard: 1 GiB Node heap, 2 GiB tree RSS, 4 GiB available-memory floor,
4 MiB stack. Agent source, methods, research and review work uses CPU0. Never
nest guards. Preserve the 103 unrelated files, seven installed files and closed
Phase58–60 raw trees. Fresh Phase61 paths retain all attempts and failures.

The Phase60 two-role loops completed in 17.53 and 49.51 seconds including CLI
preflight but excluding preparation. Rebind them honestly to new candidates:

- Early rejection: numeric recurrence and MapSet, first request only, one round.
- Confirmation: add active raytrace, two rotated rounds.
- Holdouts: Lexer and Evening.
- Integration population: all 23 distinct inputs, with complete failures and
  equal-source statistics; first/later windows remain separate.

Adding a third role or profiling changes cost; do not advertise the old 20/60
durations for a larger queue. Reuse prepared artifacts and TS baselines within
appropriate controlled comparisons, but preserve identities and drift checks.
Measure full request cost, including any new conversion, serialization or state
restoration. Microbenchmarks alone cannot select a change.

Use a genuinely checked B1 for source changes, emit a genuine direct B2 when
measuring B2 changes, and distinguish generator from subject source. Diagnostic
saved-image rewrites may quickly falsify mechanisms but cannot become a release
or fabricated checked artifact. Freeze every consumed producer; successors get
new paths. Baseline output equality is preferred. If output changes, establish
new runtime oracles and generated-program performance rather than silently
accepting text differences.

Run mechanism-specific semantic controls first, then applicable maintained
conformance/native/legacy suites. Qualify the selected candidate with fresh source
checking and exact B2→B3 reproduction. Type acceptance and proof-trust refusal
remain distinct. Promote only after the required gates, preserving the previous
installed release until then. Full program timings are justified for changed
emissions; exact unchanged modules can inherit their qualified behavior.

## Time, ownership and evidence

Independent agents own checker cursor, book/index data, structured emitter,
primitive/String rules, fast measurement methods, validation plans and research
records; root owns design, driver/cache work, integration and target execution.
An independent reviewer challenges semantics and measurement claims. Coordinate
shared file seams before edits. Prefer one combined build for compatible ready
changes, with isolated selectors or patches for attribution.

Record time to first evidence, build/target costs, abandoned hypotheses and
validation/publication cost. Do not repeat broad checks on every edit. Keep the
user informed of findings, setbacks and changes in direction. Commit the design,
meaningful implementation checkpoints and final report; push without additional
permission. No benchmark-specific function names or workload dispatch belong
in production optimization rules.

The final report belongs in `implementation/phase61/`, with exact artifacts,
before/after controls, retained negatives, metric scope and unresolved limits.
Update architecture/user documentation for selected behavior. Close and archive
raw evidence only after all writers stop.
