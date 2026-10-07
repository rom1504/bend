# Phase63: prepare semantic state and lower once

The user authorized implementation after Phase62's investigation. This design
is recorded before Phase63 target execution; parallel source prototypes began
at 20:04 UTC on 2026-10-07. The objective is fresh-process compilation parity
with pinned TypeScript, retaining Bend implementation, semantics and generated
program performance. Parity is a target, not a predicted or measured result.

## Evidence and budget

The selected Phase61 state08 B2 measures 2.071828 times TS compilation alone,
and 1.433877 times TS including import/API startup on 23 sources. These are
prepared persistent Base-cache requests in fresh processes, not cold OS-cache
or CLI measurements. Phase62 diagnostic arithmetic means are 964.64 ms versus
454.44 ms TS. Their 510.20 ms excess splits into 265.99 ms Base/loading/checking,
241.55 ms backend and 2.65 ms other. Those diagnostic means are not clean
geometric means and cannot substitute for a new controlled comparison.

An ambitious engineering budget is Base 173→40 ms, loading 255→150 ms,
checking/context 172→120 ms and backend 361→140 ms: about453 ms in total.
Each reduction must be demonstrated. 0.5 times TS would require another major
reduction and is not supported by current evidence. Arity caching alone cannot
deliver this: its measured CPU ancestry is approximately2.3%.

## 1. A ready immutable Base world

Current saved checking skips old checks but reconstructs declarations, indexes,
checked history, seen names and bounds. Prepare those structures once with the
existing checked-prefix producer. Keep raw final declarations and checked
emitted declarations distinct. Each compilation extends a persistent index with
its suffix and restores the exact observable definition order. Preserve binder
floors, fresh stamps, instance event order, constructor admission and diagnostics.
Fallback remains full checking when admission fails. Hash collisions that alter
internal bucket ordering may use the existing replay path.

Prepare parser name and constructor indexes as part of the same authenticated
Base seed. Extend them only with appended module definitions. Name lookup uses
the latest declaration event; constructor lookup uses the first depth-first
occurrence. Retain exact source origins, freshness and first-error order. A
private injected carrier is permission to reuse its associated immutable state;
arbitrary public objects do not acquire this permission from a hash alone.

## 2. Transport sharing instead of expanding trees

The frame2 cache parses two JSON trees and validates repeated subtrees. A ready
world serialized naïvely would multiply this work. Prototype a closed-schema
positional DAG with backward references and constructor-specific validation in
the decoder. Intern equivalent nodes during preparation; restore one object per
distinct node. A mandatory book graph and optional prepared graph share nodes.
Malformed book data rejects the cache; invalid optional acceleration falls back.
Retain old frame readers and all API/Base/path/schema identity checks.

This is not a revival of the rejected V8 binary codec: its decode plus mandatory
validation was2.26 times JSON. Measure the new decoder plus validation and then
the whole request. Count preparation separately and keep startup visible. Do not
move request work into import or trust unvalidated data to manufacture a gain.

## 3. One owned lowering plan

Current emitted reachability lowers every visited definition, extracts its
references, discards the text, and later lowers selected definitions again.
Introduce a small Bend-owned plan containing the canonical annotated context,
call/SCC facts, visited definitions and saved output. Build it once, follow its
reference metadata, and emit saved code in source order. Reuse existing JDText,
exact-name index and budgets rather than adding another general IR framework.

The hard semantic obligation is context equivalence: the old final emitter
overlays only retained annotated definitions onto raw declarations. Full
annotations can alter specialization, native classification, host marshalling
and bounded reductions. Matching the23 benchmark modules alone is insufficient.
Review these query contracts, add source counterexamples, preserve refused
cases, and retain the old path for fallback/ablation. Never silently update
output oracles to accept a changed candidate. A byte change needs separate
semantic and runtime qualification before selection.

## Fast discriminating loop and integration

Root runs one guarded target process tree at a time on CPU3:1GiB Node heap,
2GiB total RSS,4GiB available-memory floor and explicit deadlines. Six agents
own world, frontend, backend, transport, correctness and measurement work on
CPU0. They perform source/data work without competing compiler targets. Freeze
each candidate before checking; no editing consumed tools or closed evidence.

1. Codec decode/validation probe; checkedB1 build and focused36 gates.
2. World/frontend full-versus-reused controls, malformed/admission/fallback
   controls, backend graph and actual context-sensitive source controls.
3. Numeric+Map clean screen; Numeric+Map+ray two-round confirmation. Inspect
   whole-request costs before extending a failing idea. Ablate architectural
   components where needed; record combined gains without false attribution.
4. Lexer+Evening heldout and all23 exact emitted modules. Build genuineB2 from
   the checked candidate, then compare frozen state08 B2/candidate B2/pinnedTS
   on23 inputs with three position-balanced rounds. Report compilation and
   import+API+first compilation separately; no profile instrumentation in them.
5. Selected integration: semantic matrix, native/default/legacy routes,
   generated-program witnesses, own-source acceptance, B2/B3 reproduction and
   installed identity. Unsafe trust refusal remains explicit; self reproduction
   is not a proof of compiler correctness. Promote only a qualified candidate.

The measurement successor relocates writable evidence into Phase63 and binds
baseline helpers to their exact frozen snapshots. Historical audit-input path
mapping requires identical bytes; cache format admission is explicit. The
existing timing boundaries and post-return output oracles remain unchanged.

## Deliverables and stopping decisions

Keep one experiment record per hypothesis, all failed/rejected attempts, and a
report linking exact artifacts and timing accounts. Preserve110 inherited
unrelated files and seven installed artifacts until qualified promotion. Track
source size and complexity along with speed; temporary duplicate paths must be
documented. Commit and push design, useful implementation milestones and final
evidence. No upstream update, PR comment or goal creation is part of this task.

The implementation report is [Phase63](../../implementation/phase63/README.md).
Prior evidence is [Phase62](../../implementation/phase62/README.md).
