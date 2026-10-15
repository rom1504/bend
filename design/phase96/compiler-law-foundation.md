# Phase96: reusable laws before further compiler optimization

Baseline: `d048d01`, unchanged Phase90 installed compiler, pinned upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. The user requests many laws and asks us
to learn from the upstream Lean proof. This phase builds constraints and a fast
verification loop; it does not optimize or replace the production compiler.

## Method learned from upstream

Read the actual `bend2/bendtt.lean` proof and record its source identity. Separate
declarative semantics, executable algorithms, invariants and bridging theorems.
In particular, `ren_ren`, substitution composition, and the `subk_sub`/`sub_subz`
bridge show how a simple specification can constrain a faster implementation.
Do not infer that this verifies our distinct compiler, its unsafe helpers, C
runtime, scheduler or GPU. No kernel changes, new axioms or admitted proof bodies.

## Deliverables

1. A safe algebra package, initially about10–12 public laws: ordered append,
   reverse/filter identities, and environment preparation. Use actual Base
   operations and the already proved Phase94 helper where appropriate; label
   that helper as an unpromoted candidate, not current production.
2. A representation contract package: projections, children replacement, spans,
   preserved metadata and update composition. Extract exact maintained KTerm
   declarations and helper bodies. Try removing only `@unsafe` annotations in
   the proof extraction, then require source and independent kernel acceptance.
   Record this transformation; do not change production or claim that unrelated
   unsafe callers become proved. Preserve constructor exceptions such as literal
   leaves ignoring children replacement.
3. Executable production contracts, initially12–16 families: lookup/shadowing,
   membership, substitution, occurrence/liveness bookkeeping, environment/drop
   partition and representation/encoding behavior. Generate independent full
   expected values, including order, duplicate IDs and source metadata. Exercise
   exact extracted production definitions with identity checks. These finite
   tests remain distinct from universal theorems.
4. Mutation controls that violate each important contract family. A rejected
   mutation must be well-formed and reach the intended semantic check; parser
   failure alone does not demonstrate a useful law. Preserve unexpected passing
   mutations and counterexamples rather than weakening the law silently.
5. A fast command, a law catalog with coverage/trust boundaries, an upstream
   research note, documentation and an implementation report with exact evidence.

Public contracts, supporting lemmas, executable families and generated cases have
separate counts. Equality to the same implementation is not an independent
oracle. Laws should survive representation changes and constrain the intended
semantics, rather than freeze incidental allocation or output formatting.

## Execution and resource policy

Three agents prepare algebra, production properties and upstream/trust review
offline. Root owns representation proofs, integration and all guarded target
execution. Freeze each attempt before checking; retain rejected attempts and
separate preparation/source errors from semantic mutation rejection. Reuse the
authenticated official Lean4.34.0 and unchanged cached BendTT module from Phase94.
Run small source checks first, then complete elaboration and independent checking.
Do not repeatedly rebuild a compiler or rerun performance suites for proof-only
changes. Keep all targets serial, time/RSS bounded, and monitor disk/memory.

## Admission and scope

The suite is usable only when a single documented command exercises the accepted
contracts and required negative controls, authenticates their production source
connection and records failed attempts. For a universal proof, enumerate actual
elaborated theorem bodies and the dependency closure; opaque template parameters
must be explicit. Test relevant production behavior in generated code separately.
Do not claim full compiler correctness, a performance improvement or new broad
conformance. The five production metrics remain unchanged unless a separately
authorized and qualified source change becomes necessary.

Commit/push design and final laws, tools and report. No PR comments.
