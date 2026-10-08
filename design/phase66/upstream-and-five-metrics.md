# Phase66: upstream migration and five separate compiler metrics

Registered October 8, 2026 from `ef7c657`, starting at 05:02:20 UTC. The user
has authorized updating to upstream `059266225b77c8ca256ac6b25ee5c21449bab151` and qualifying the result. The
initial inventory spans 95 upstream commits beyond pinned
`018751270e800bc222a93dad7f257083ee53a5f7`. The exact target commit and file
identities must be recorded in the acquisition receipt before target execution;
a moving branch name is not the reference.

The compiler remains implemented in Bend. Upstream's human-written
`bend2/bend.ts` may arrive through the authorized upstream update; do not
hand-edit it. Preserve Phase65 and earlier evidence, the old installed package,
and unrelated work. Existing authorization permits committing and pushing the
completed phase to the fork. It does not authorize a new PR comment.

## Baseline and outcome boundaries

Phase65 State10 is installed as an equality-derived checked B1 (`3a7fedb7…`). Its
separately qualified genuine B2 is `239f7970…`, and assembled Bend source is
`310c9d07…`. The [Phase65 report](../../implementation/phase65/README.md) and
[final size audit](../../implementation/phase65/size.md) remain the historical
baseline, not evidence that a new upstream pin is compatible.

The last Phase65 balanced 23-source campaign measured genuine-B2 compilation at
**1.28945× its pinned TypeScript reference** and imports plus compilation at
**0.969256×**, with 207 exact module comparisons. Those are different clocks.
Neither is generated-program execution speed, installed B1 CLI latency, a new
upstream comparison or universal conformance. Keep their denominators unchanged.

Maintain a scoreboard with five axes, even if an axis is blocked or unmeasured:

| Axis | Primary observation | Required comparison and distinction |
| --- | --- | --- |
| Generated-program runtime | Correct complete computations from the broader maintained program corpus; absolute per-program times, medians/ranges and ratios | Phase66-produced programs versus Phase65-produced programs and new-upstream-produced programs on the same compatible inputs. Separate first call, specified warm execution and whole-process scopes. |
| B1 compiler latency | Fresh requests served by the exact checked/equality-derived B1 role | Same-campaign Phase65 B1, Phase66 B1 and new TypeScript. Compilation alone is primary; imports plus compilation and preparation are separate clocks. |
| B2 compiler latency | Fresh requests served by an independently identified genuine self-emitted B2 | Same-campaign Phase65 B2, Phase66 B2 and new TypeScript. Never substitute B1, a host-rewritten image or a reused historical ratio for B2. |
| Conformance | Exact outcomes against the new pinned reference, plus source acceptance, selected backend execution and self-reproduction | Count the new denominator, passes, mismatches, reference refusals, environment limits, skips and unrun opportunities separately. Historical passing scopes do not silently transfer. |
| Simplicity | Manifest-listed Bend source, separate host/runtime support, generated-image sizes and a qualitative contract inventory | Phase65 to Phase66 deltas with unchanged counting rules; a separate new-upstream implementation inventory. Lines, concepts and image bytes are different measures. |

No parity target is promised by this migration. Any new reference may improve or
regress independently. Report absolute costs and same-campaign ratios rather
than dividing results from different historical campaigns. Improvements on one
axis do not imply improvement on another.

## Stage 1: freeze and run the smallest useful baseline

Before production edits, retain exact Phase65 source/manifest, B1/B2, runtime,
Base, driver, transport helpers and prepared-product identities. Record the
selected upstream commit, its dependency closure, changed tests and semantic
surface. Record original working-tree/protected-path inventories and installed
release identities. Do not reopen or mutate closed raw trees.

Start with the shortest maintained compilation and program-output screens that
can discriminate a broken migration: existing representative Numeric, Lexer,
Map and Raytrace compilation sources, plus selected arithmetic, collections,
closures and pattern-matching executions. The initial screen is bounded and does
not replace the eventual broader suite. Old artifacts remain the old baseline;
new reference failures are retained and categorized before changing fixtures.

Capture preparation, import and request boundaries, cache presence, Node,
affinity, limits and source bytes. Prefer an unchanged intersection corpus for
like-for-like performance. If an upstream syntax or API change requires a source
adapter, retain both versions, document the mapping and establish equivalent
observable work before using it in an explicitly labeled migration comparison.
Do not count a silently edited fixture as byte-identical input.

## Stage 2: migrate names, Base and runtime contracts

Inventory upstream renames and behavior changes before applying compatibility
changes to the Bend implementation and its host boundary. Separate mechanical
name updates from semantic changes in elaboration, native primitives, effects,
representations, errors and export/loader behavior. Retain focused witnesses for
each changed contract instead of inferring semantics from name similarity.

New Base content invalidates the old optional annotation-product permission.
The Phase65 content gate must continue to fail closed: old prepared products
cannot be admitted under a new Base, API, source/span ABI or parent graph.
Initially use ordinary request-demanded annotation for the new Base. Qualify and
permit optional prepared products only after fresh producer, ownership,
activation, fallback and malformed/stale-artifact controls pass. Do not loosen
an identity check to recover speed. Regenerate mandatory preparation under the
new identities and record its cost outside request timing.

Keep compiler decisions in Bend. JavaScript may transport and validate
Bend-produced data and implement the established runtime boundary; it must not
become a hidden fallback to the TypeScript compiler.

## Stage 3: produce a genuinely checked new B1

Build the migrated canonical source with the selected new upstream compiler.
Record the exact source, Base, runtime, host/tool closure, raw checked output,
export list and any approved equality-derived image separately. Require genuine
checking, strict focused outcome gates and source/API identity verification.
An emitted unchecked artifact or a patched old image is not this checkpoint.

Use short B1 controls to isolate failures before another build. Preserve every
failed build and preflight with its original status. A corrected attempt receives
a new identity; do not rewrite failure receipts as successful.

## Stage 4: qualify focused compatibility and the fast loop

Run source-level witnesses and backend executions for each changed upstream
boundary. Include argument evaluation and erasure, partial/overapplication,
constructor ownership/native admission, arithmetic boundaries, source origins,
prepared-world behavior, malformed artifact refusal and current error order
where those contracts are affected. Compare complete outputs and normalized
verdict fields, not only exit codes or a final checksum when fuller output is
available.

Run a small controlled B1 latency screen against preserved Phase65 and the new
reference after correctness succeeds. Failed reference acquisition is not a
candidate conformance failure; an old fixture's changed specification is not a
license to adjust its expected result without an explicit record. Advance on
qualified semantics and acceptable cost, not on attractive instrumented counters.

## Stage 5: qualify a genuine B2 before attributing B2 performance

Have the checked migrated compiler emit the compiler's complete canonical source.
Bind the resulting B2 to that checked parent, source closure, exports, runtime,
Base and host inputs. Run own-source type acceptance, required checked/B2
semantic controls and B2-to-B3 reproduction with the established exact boundary.
If the new upstream changes an expected reproducibility boundary, document and
resolve it rather than calling a merely similar image exact.

The installed checked B1 package and measured genuine B2 remain separate roles.
A B1 speedup is provisional for B2 until fresh B2 measurement. Reuse a program
execution result across emitter roles only through explicit equality of complete
emitted module and runtime bytes and the same invocation contract.

## Stage 6: measure all five axes against the qualified target

Freeze all candidate/reference roles before clean timing. Reuse established
sources and oracles where still applicable, retaining the source identity and
compatibility status for every case. Complete the broad maintained program
runtime, B1 request, genuine-B2 request and conformance scopes in bounded batches.
First run the small correctness/activation screen; expensive integration follows
only for a surviving state.

For request campaigns, alternate or balance role order in fresh processes on the
same CPU and use the same preparation policy. Retain per-source absolute
samples, ranges, ratios, imports and request durations. State the aggregation
rule and source weights; do not silently omit failed cases or publish a surviving
subset as the whole corpus. Runtime timings retain their prospectively specified
warmup and startup boundaries; prior V8 warmup sensitivity makes first-call and
warm-loop measurements complementary, not interchangeable.

For conformance, acquire a fresh new-reference inventory and preserve every
observed mismatch or unsupported boundary. Distinguish frontend acceptance from
emission and generated-program behavior, and distinguish JS from native/device
coverage. Exact self-reproduction and finite passing tests do not prove compiler
soundness or full-language conformance.

The [simplicity method](../../implementation/phase66/simplicity.md) retains the
Phase65 manifest-only Bend series and separately inventories host, runtime,
upstream and generated artifacts. Explain any added concept or compatibility
layer and any retired duplicate responsibility. A measured line increase is an
explicit cost, not a simplification claim.

## Stage 7: release, preservation and report

Promote one coherent qualified version only after the required identity,
semantic, self-hosting, host and release gates pass. Preserve the old package,
verify installation before and after CLI smoke tests, and bind the selected
release to the same inputs measured above. Keep any unreached axis explicitly
unmeasured or blocked; never fill it with a ratio from another phase.

The [implementation report](../../implementation/phase66/README.md) must include
all five axes, migration changes, retained failures, unresolved boundaries,
reproduction commands, exact artifact roles and durable evidence recovery.
Verify protected and closed historical inputs unchanged, audit captured bytes,
commit and push the scoped phase. No new PR comment is part of this work.

## Execution guard and stop conditions

Only root runs compiler, profiler, generated-program or benchmark targets: one
supervised target tree at a time on CPU3, with 1 GiB heap, 2 GiB tree RSS and a
4 GiB available-memory floor. Source, metadata and review agents stay on CPU0.
Diagnostics and compilation do not overlap clean timing. A deadline, memory
limit, interrupted process or invalid artifact is an explicit observation.

Stop a candidate's advancement when it changes a required semantic boundary,
borrows stale prepared data, fails checked-image provenance or cannot complete
within the registered resource limits. Make the smallest discriminating repair
or report the remaining blocker; do not hide it by changing the denominator.
