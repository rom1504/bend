# Phase145 — compare compiler work before changing architecture

2026-10-27, starting at `d283c10`. The user requests actual operation/cost
comparison and architectural insight. This is an evidence campaign, not a new
optimizer or production compiler promotion. Preserve qualified Phase144 final04,
its source/API/runtime identities, original final verifiers and installed defaults.

## Questions and comparisons

1. Same Bend compiler source, input, prepared Base and ordinary policy, executed
   through current checked JS API versus qualified QBE-native N2. Require complete
   identical QBE output. Compare fresh process cost, preparation, useful request,
   output and cleanup; separate diagnostic observations from clean timings.
2. Our compiler versus pinned upstream TypeScript compiler on identical Bend
   inputs. Align parsing/checking and source definitions where contracts permit.
   Upstream C emission and selfhost QBE emission perform different work; do not
   label their whole emission ratio target parity. Independent results, failures
   and supported behavior remain separate gates.
3. For a measured hot complete computation, determine whether work is repeated,
   its representation is expensive, execution lowers badly, or it establishes
   additional guarantees. These explanations imply different changes.

Do not compare whole Go/Rust/Zig builds as if they checked the same language.
Existing research may identify candidate architectures; this campaign must
produce evidence from the actual compiler and exact pinned upstream.

## Small measured loop

Reuse retained checked API, native object, ordinary output references and frozen
real Lexer/Map/closure workloads. Add a larger real compiler slice only if the
small cases finish within resource bounds and the slice has an independent full
result/error oracle. Pilot first, then at least three alternating clean pairs for
stable cases. Mark small samples exploratory, not statistical guarantees.

Native operation accounting initially reuses the profiler's16 runtime channels
and exact source/ELF bindings. Record allocations/words, ownership operations,
constructor take, register transport and dispatch. Private/inlined operations may
bypass hooks. Counts are a bounded observation, never a complete source-call graph.

JS diagnostic copies may instrument selected declarations inside the generated
API/transpiled artifacts so internal recursion is visible. Never edit protected
`bend2/bend.ts`, historical upstream checkouts or the checked original API.
Authenticate reversible changes and compare all outputs to pristine execution.
Document loops/inlining, inclusive/exclusive overlap and JIT perturbation.

Count useful semantic work where the same contract can be identified: visits,
queries and probes, characters processed, reconstructed fields, verifier/pass
invocations, output fragments/bytes. Record RC and GC separately; raw object counts
across different representations are not directly equivalent. Report normalization
by source tokens/definitions or verified instructions only when denominators match.

## Architectural falsifiers

- More visits/probes on the same semantic task supports algorithm/fact reuse.
- Comparable semantic work but a large same-source native/JS gap supports a
  representation, lowering or runtime investigation, not an algorithm conclusion.
- A lower operation count without lower clean time rejects count-only profitability.
- The existing compact verifier's11.06% slice gain does not establish a large
  whole-compiler gain. Any proposed replacement must cover producer, conversion,
  joins, consumer and teardown, with transfer beyond one fixture.
- Extra independent verification is a different guarantee. Identify its cost
  without deleting it to manufacture an upstream comparison.

## Resources and division of work

Root owns every compiler/benchmark/profiler target in one CPU3 lane. Ordinary
limits:3GiB process-tree RSS,16GiB available-memory floor,64MiB file cap and
bounded per-job deadlines. Disk starts near597MiB free; avoid full compiler images,
large raw traces and whole-C/Clang acquisitions. Previous full C attempts hit6GiB.
Metadata-only agents may inspect, prepare methods and independently review results.
No competing target lanes or nested guards. Do not repeat full self-host qualification
when production source and selected runtime are unchanged.

Use approximately60–90 minutes for the first decisive evidence and extend only
if a specific finding needs a small discriminator. Keep a file per hypothesis,
failed receipts, exact source/tool identities and a concise cost record. Commit
and push the design, completed methods, evidence and report. Report measured facts,
inferences and architectural hypotheses separately; do not claim a50s route from
local counters or old profile percentages.
