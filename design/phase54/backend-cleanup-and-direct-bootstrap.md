# Phase54: backend boundaries and direct bootstrap

The user authorized the recommended cleanup after direct JavaScript became the
default. Preserve the installed Phase53 semantics and generated-program speed,
make genuinely shared compiler facts independent of the legacy JS emitter, and
retain the existing Bend-written C backend as a foundation for future targets.
Compiler-image migration must be qualified before retiring its legacy path.

Baseline: Phase53 ordered02, commit `29dbaa41fb7988baae8355b1fba24312976d598d`,
API `3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`.
Pinned upstream stays `018751270e800bc222a93dad7f257083ee53a5f7`.
The baseline's complete 45-point/23-source/669-sample comparison is 1.069599×
TypeScript execution time. This phase must not reuse that number as a fresh
measurement of changed generated programs.

## Stage A: establish dependencies and preserve the starting point

Inventory shared helpers, all maintained compiler-image callers, and actual IR
boundaries. Preserve exact source/runtime/API identities and the 103 unrelated
starting files. The current manifest has 21,523 code lines: 7,770 in legacy/shared
JS modules, 2,034 in direct JS, 1,745 in native, and 9,974 elsewhere. Shared and
compatibility obligations mean 7,770 is not a deletion budget.

KTerm/KDef and annotations are the shared semantic boundary. Legacy JIR/JW,
direct JDOrdered prefix/value strings and native C segment bodies are separate
backend representations. None is a universal executable IR. Keep quantity,
erasure, ownership, effect, numeric and demand information available to later
lowerings; introduce no unused general IR or speculative LLVM/assembly emitter.

## Stage B: separate helpers and make existing contracts explicit

Move unchanged typed queries, constructor/telescope facts, native declaration
proofs and literal facts into small common modules. Move JavaScript quoting and
numeric source formatting into shared JS utilities. Preserve function bodies
and names initially; a directory move must not smuggle in semantic changes.
Every helper must have an identified consumer. Avoid forwarding aliases solely
to make the migration appear larger.

Audit maintained compiler-image subprocesses. `conformance/selfhost.mjs` and
`verify-seed.mjs` currently use bare `--library`; select their required legacy
contract explicitly. Existing private images remain frozen and supported.
Historical experiment producers and evidence stay immutable. Test actual route
construction with host-only controls before scheduling a compiler build.

Qualify a checked B1 with strict frontend controls. Compare actual emitted JS
against the selected Phase53 bundle and representative C output against the old
checked compiler. Run focused backend/semantic controls. If output is byte-exact,
another full timing campaign supplies no useful evidence; record identity reuse
instead. An unexpected output difference must be explained before promotion.

## Stage C: replace repeated graph closure with compact analysis

Direct SCC analysis currently stores reachability for every eligible function,
then tests every pair. Replace this with indexed adjacency and explicit-stack
linear graph traversals. Preserve deterministic source-order component members,
same-SCC transfers, self edges and unknown-tail-call propagation. Shared graph
code may contain graph facts; JS-specific tail scanning stays in its backend.

Keep the original bound until small old/new graph facts agree. Independent
controls include DAGs, self/mutual cycles, unknown closure tails, duplicate edges,
isolated roots, rejected targets and ordering. Then exercise checked graphs at
128, 512, 513, 1,024 and compiler scale before replacing the old vertex limit with
explicit node/edge/work budgets. Exact emitted reachability has a separate limit;
do not raise only one cap or drop demand-sensitive pruning. Do not combine this
with an unrelated expression or representation optimization.

## Stage D: prove the direct compiler-image route

First inspect the existing no-G loader contract. A direct image may already fit
the named-field stage0 API; prove this using an isolated restricted compiler API,
typed term/definition transport, parse/check errors and backend calls. Only add
an adapter if a concrete mismatch requires one.

After scale controls pass, emit the actual compiler through the checked Bend
compiler and exercise it against the installed image under the same resource
limits. Full self-reproduction requires successive checked stages and exact
identity/output controls; a callable module or helper microbenchmark alone is
insufficient. Preserve failures. Stack behavior, API exports, private-image
rewriters, host conversion budgets and code size are separate possible blockers.

Promote direct compiler-image generation only for the scopes that pass. Keep
legacy compatibility and any still-required bootstrap route until their users
migrate or compatibility is deliberately discontinued. A concrete failed direct
bootstrap experiment warrants a documented remaining task, not deleting the
working route or silently substituting TypeScript.

## Stage E: consolidate and report

Install only a qualified release. Document the actual backend boundaries and
what future C/LLVM consumers can reuse; retain native ownership/runtime/FFI and
its existing CPU checks. Update misleading current-backend language in the old
JS IR guide. Report code lines, moved versus deleted bodies, dependencies,
qualification, emitted-byte equality, compiler-scale cost and bootstrap status
separately. Preserve all failed attempts in one closed raw archive with compact
replay/qualification summaries; avoid another forest of duplicated evidence.

Use eight agents for independent helper separation, routing, graph work, graph
validation, semantic/native validation, bootstrap investigation, architecture and
review. Root integrates manifests, controls target execution, commits and pushes.
Heavy targets run serially on CPU3, 1 GiB Node heap, 2 GiB process-tree RSS and a
4 GiB available-memory floor. Compilation and compression stay outside clean
timing. Use narrow falsifiers before expensive reproduction, retain timestamps,
and distinguish recorded process occupancy from analysis/review/documentation.
No PR comment is authorized.
