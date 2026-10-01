# Zig: compact stages and explicit invalidation

Research date: 2026-10-01. Documentation only; no compiler experiments were run.
This extends the [Phase31 study](../../phase31/zig-lessons.md), with the installed
[Phase37 result](../../../implementation/phase37/README.md) as the Bend baseline.
The implementation pin here is **Zig 0.15.1**, a historical release, not a claim
about the latest Zig version. All proposed gains below are unmeasured Bend estimates.

## What Zig's history actually establishes

Zig 0.10 made its self-hosted compiler the default. Its published self-build
comparison reported about 40 versus 43 seconds, but 2.8 versus 9.6 GiB peak memory.
That particular milestone was primarily a memory and architecture improvement;
it does not establish that switching implementation language makes compilation
orders of magnitude faster. [Official 0.10 release notes](https://ziglang.org/download/0.10.0/release-notes.html).

Zig 0.15.1's own x86 backend reduced Debug compilation time by roughly fivefold
relative to its LLVM path in the reported comparisons, while explicitly accepting
slower generated code. That release also described experimental incremental
compilation and important correctness limitations. These are different tradeoffs:
backend latency, execution quality and avoiding repeated work cannot be collapsed
into one “compiler speed” figure. [Official 0.15.1 release notes](https://ziglang.org/download/0.15.1/release-notes.html).

For Bend, lowering generated-program overhead is currently the larger opportunity,
but the compiler itself also matters: Phase37 checked-request medians remain
5.06–5.61× TypeScript for three measured sources. The recent optimization added
2.47% and 6.40% to local-row and tree request medians, with disjoint ranges.
These are request measurements, not isolated backend costs or universal ratios.
[Compiler-cost evidence](../../../implementation/phase37/compiler-cost.md).

## Implementation examined

| Pinned source | Concrete mechanism | Useful inference for Bend |
| --- | --- | --- |
| [ZIR, 0.15.1](https://github.com/ziglang/zig/blob/0.15.1/lib/std/zig/Zir.zig) | `MultiArrayList` instructions, shared string bytes and `u32` extra storage; later stages normally need no AST/source access except diagnostics | Store frequently consumed facts once, with explicit references to diagnostic material |
| [AIR, 0.15.1](https://github.com/ziglang/zig/blob/0.15.1/src/Air.zig) | Typed analyzed operations, including distinct arithmetic behavior and instructions that must lower despite unused results | Preserve semantic distinctions before selecting concise output |
| [InternPool, 0.15.1](https://github.com/ziglang/zig/blob/0.15.1/src/InternPool.zig) | Canonical typed indices and separate dependency categories for source hashes, values, types and namespace information | Cache identity and invalidation need more detail than a definition's spelling |

These files were inspected, not merely inferred from release headlines. ZIR's
compact storage is suited to Zig's allocator and machine-code pipeline. A Bend
list of numeric indices is not automatically a compact array in generated JS;
its traversal and construction cost must be measured before copying this layout.

The transferable principle is to place a stable boundary between analysis and
consumption. It does not require copying Zig's IR count or introducing a new
public compiler representation. Zig's explicit wrapping, saturating and other
arithmetic forms also warn against treating “same arithmetic expression” as one
universal rewrite rule across U32, Nat, F32 and host JavaScript.

## First candidate: request-local analysis facts

Current [`finite.bend`](../../../selfhost/src/back/js/finite.bend) checks bounded
shape, typed prefixes, signatures and whole-graph purity before admission.
The plausible repeated work is determining the same definition's eligibility
at several call sites. Its existence in source does **not** establish its share
of measured compile time; counters and a compiler profile must establish that.

The smallest proposal is a request-local table of immutable analysis answers:

1. Freeze the checked book for one emission request and assign a request identity.
2. Key reusable answers by definition identity, query kind and relevant options.
3. Keep environment-dependent or partially instantiated answers separate.
4. Distinguish an established refusal from a search stopped by fuel/depth limits.
5. Discard the table at request completion; preserve the existing emitted bytes.

For example, all saturated calls to `choose(tree, flag)` could consult one
definition-level finite-prefix answer. Argument ownership and the active proof
scope remain call-site facts. A positive cached prefix does not authorize a
public call, getter-bearing value or mutated native descriptor to bypass checks.
An interrupted recursion proof must not be reused as a context-independent result.

This cache concerns compiler analysis. It cannot memoize runtime host guard
outcomes across arbitrary calls: JavaScript descriptors and callbacks can change.
Conflating those two caches would recreate the semantic failures already caught
by the [Phase37 owner controls](../../../implementation/phase37/optimizer/final-scope-owner-report.md).

## Second candidate: one compact private emission plan

If two experiments need the same facts, create one bounded per-definition plan
containing call arity, original typed match prefix, effect/demand classification,
required host dependencies and supported recursive edges. Have existing emitters
consume it, and remove their replaced scans. Keep original terms for diagnostics.

The concrete win sought is one traversal that answers several existing questions,
not renaming each old proof into a new pass. For instance, constructor ownership
and saturation could be recorded alongside the prefix used by both direct calls
and finite selection, while unsupported nodes carry an explicit fallback reason.

Start with tagged immutable records using current representations. Compare an
indexed representation only if allocation/traversal measurements justify it.
It is possible for a denser encoding to reduce bytes while increasing lookups,
decode branches and debugging cost. That is a failed tradeoff for this project.

## Third candidate: incremental edit requests

A longer-lived compiler could reuse unchanged parsed/checked modules after edits.
The difficult part is dependency soundness: a type change, definition addition,
name disappearance, changed import or native implementation can invalidate users
even when their source bytes are unchanged. Failed queries and diagnostics also
have dependencies. Zig's pool separates several such categories explicitly.

Rust's independent query design likewise treats unchanged query results as a
reason to avoid propagating invalidation, rather than equating an edited input
with every dependent result changing. That is a useful comparison, not a ready
implementation for Bend. [Rust incremental query documentation](https://rustc-dev-guide.rust-lang.org/queries/incremental-compilation-in-detail.html).

For our current short-lived checked workflow, begin with module reuse in a
single controlled server experiment. Do not redesign the public CLI first.
Cache identity must bind source, compiler/API, runtime, Base, options, imports and
the semantic representation version. Preserve cold requests as a separate series.

## Estimates and cheapest discriminating tests

Ranges are planning estimates conditional on finding the proposed cost. A value
of 1.00× means no improvement. They are not Zig's speedups transferred to Bend,
and overlapping proposals must not be multiplied or added.

| Proposal | Estimated Bend benefit | Complexity and first implementation | First falsifiable experiment |
| --- | --- | --- | --- |
| Request-local fact reuse | 1.00–1.20× checked-request speed; output execution unchanged if bytes match | Low/medium, 1–2 days; one cache lifetime and explicit query keys | 2–4 hours to count duplicate work and time three normal requests; then exact-output and refusal controls |
| Shared private plan | 1.10–1.50× the affected analysis/emission portion, not the whole compiler; no automatic execution gain | Medium, 3–7 days; useful only if old scans are removed | One definition family, old/new facts compared, allocation and emitted-byte checks; one working day before wider integration |
| Incremental module queries | Possibly 1.5–5× warm edit requests when most modules are reusable; cold speed may worsen | High, 1–3 weeks; dependency graph, persistence and invalidation tests | 2–3 days for a tiny edit trace with unchanged, type-changing, missing-name and import-changing edits |

For example, making a phase that occupies 20% of a request 1.5× faster improves
the complete request only about 1.071×. Measure the fraction before forecasting.
The emitted compiler being a large Bend program does not make that fraction known.

## Admission, stopping and complexity

- Stop fact caching if repeated eligible queries account for under 5% of request
  time, or key construction and retained data erase the saving. Record a null result.
- Reject any changed diagnostic order, stale answer, output mismatch or observable
  host-boundary difference. A cache hit rate is not correctness evidence.
- Stop the compact-plan experiment if it adds a parallel proof system or needs
  whole-language lowering before two independent clients can use it.
- For incremental work, compare against clean recompilation after every edit;
  include errors becoming valid and valid programs becoming errors.
- Keep RSS and compiler-request time visible. Parallel compilation is deferred
  until memory headroom is established; it is not a remedy for duplicated work.

Source simplification is plausible only in the shared-plan case, where obsolete
walkers are actually deleted. A cache generally adds a concept and some code.
Neither change automatically increases language conformance; the main conformance
effect is the risk of invalidating a correct refusal or diagnostic boundary.

Recommended order: measure duplicate analysis, try request-local reuse if material,
then consolidate facts demanded by successful runtime experiments. Incremental
compilation is a separate developer-loop project, not an explanation for the
remaining 57–209× gaps in selected tree/BST generated programs.
