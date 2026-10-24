# Phase135 — A validated incremental rebuild of the compiler

Started 2026-10-24 from `17a9e437b9440f63c26cc6f990627320393356c3`.
Continue the [Phase134 plan](../phase134/README.md), using its qualified bounded
emitter and separately checked native session prototype. Installed selections
remain unchanged. This phase targets a real compiler edit, not cache-hit counts.

## Objective

Reduce complete source-edit → independently validated native executable time.
First establish what existing semantic reuse saves on a real compiler source
edit; then remove a measured earlier preparation category and connect emitted
units to machine-object reuse without the Phase132 whole-file rescan.

A faster warm request must include lookup, invalidation, checking, final
verification, rendering, output, machine builds and linking. Report one-time
acquisition and qualification separately. Report cold overhead and program-speed
changes as well as the favorable warm result. No unmeasured 10-second target or
full incremental frontend claim.

## Frozen references and experiments

1. Authenticate Phase134 qualified source/core N2 and the separate source04
   session image, Phase131/132 compiler-edit evidence, runtime, compact Base,
   QBE and machine flags. Keep the old and edited source and independent products.
   Prefer the already independently checked one-function emitter edit for the
   first full-scale comparison, then a compiler-derived fast fixture and a
   second distinct edit/dependency challenge. Path-sensitive source identity
   and static-placement changes must be checked, never normalized silently.
2. Run the existing native warm session on the full compiler source if its
   memory/output bounds permit. Record A acquisition, B update, prior hits,
   peak memory, exact QBE and retained cache costs. This is a direct test of
   transfer from the small Lexer/Map results. Add an equal-preparation no-cache
   or cache-reset reference where needed to establish net adoption benefit.
3. Audit raw private-candidate preparation before adding another cache. Its
   complete semantic context includes prepared static bodies, owner definitions,
   callee bodies/types, constructor/ownership information, signatures and
   readiness/absence queries. Exact-input reuse is acceptable; a Ref-only
   call graph is not sufficient. Preserve order, global fresh IDs and fallback
   behavior. First test a fast real compiler computation and adversarial edits.
4. Use existing sealed cursor structure to emit explicit transport unit markers
   and definitions. Host tooling only transports/hashes bytes and builds objects;
   it must not infer optimization legality or parse source to choose dependencies.
   The existing `legacy_end` flag is a newline boundary, not a function-unit
   boundary. Private/legacy/public/data paths all need explicit coverage.
5. Reuse unchanged object units under exact unit bytes and complete tool/runtime/
   visibility policy identities. Initially keep global data current and all
   relevant definitions link-visible under an explicit closed-image ABI.
   Compare cached output to a fresh partitioned build, and compare both to the
   ordinary monolithic compiler. Stable semantic binding is a later change if
   measured ID/static churn dominates. Do not mask relocation/machine differences.
6. Integrate only demonstrated useful boundaries, acquire once through the
   qualified native parent, and validate actual compiler requests and resulting
   programs. Use independent full source checking, source-connected finite
   controls, exact output oracles, ownership/refusal gates and native generation
   gates appropriate to the scope. Never promote the session prototype merely
   because it reproduces an output or obtains a favorable timing.

## Fast loop and resource discipline

One coordinator owns resource-intensive execution on CPU3. Independent source
reviews, data-only tooling and small checked API controls can proceed in parallel;
quiet timing blocks have no competing target jobs. Guard every large run with
RSS, available-memory, deadline and file-size limits. Preserve rejected attempts,
partial receipts and exact method inputs. Do not delete historical artifacts to
make a benchmark pass. Avoid another full image acquisition until the small
boundary experiment establishes a reason.

The first checkpoint is a measured full-source cache result plus a compiler-
produced object-unit transport prototype. If preparation reuse is unsafe or
unprofitable, preserve that finding and choose the narrower measured seam;
do not expand the cache until it accidentally appears useful.

## Metrics and decision gates

- Complete cold acquisition and warm validated edit latency; actual work skipped.
- N1/N2 ordinary request speed when a new integrated image warrants qualification.
- Generated-program speed: reuse evidence only for exact products; measure changed
  machine layouts against independent fresh and monolithic references.
- Semantic/admission/ownership correctness, invalidation challenges and bootstrap
  scope. A cache hit or matching generations is not a correctness theorem.
- Peak memory, serialized/live IR, retained cache/object disk, source complexity.
- Experiment execution, failed attempts, qualification and acquisition overhead.

Keep legality, profitability and final byte emission separate. Unknown semantic
facts force recomputation. Reused entries are produced by one fixed compiler
inside its process; no untrusted or cross-producer state is admitted. Whole-book
checking/final verification remain until separately justified narrow reuse exists.

Deliver design, implementation, honest report, immutable compact evidence and
usable commands; commit and push validated milestones. No PR comments.
