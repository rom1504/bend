# Phase58: reduce compiler allocation and generated execution cost

## Objective

Implement the concrete opportunities identified in
[Phase57](../../implementation/phase57/README.md), measure each mechanism, and
ship one qualified compiler. Improve compiler throughput and cumulative
allocation without regressing generated programs, language behavior or stack
safety. The compiler remains written in Bend; diagnostic JavaScript derivatives
are experiments, not the maintained implementation.

Starting source is Phase56 string01 at source commit `8d2f4f0`, with the repository
at `43de269`. Checked derived B1 is `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`;
qualified direct B2/B3 is `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`.
Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`, Node 24.18.0.
No upstream migration or PR comment is part of this phase.

## Evidence and falsifiers

Phase57's two-input clean comparison puts B1 at 2.83–3.13× handwritten TypeScript
import-plus-request time and B2 at 4.96–5.45×. The three later requests still warm;
they do not establish steady-state throughput. B2 is faster than raw upstream
output for the same Bend source; B1 includes extra image transformations.

Lexer sampled allocations are 2,178 MB/request for B2, 927 MB for B1 and 59 MB
for TypeScript, including collected objects. Those are cumulative estimates,
not peak RSS. Full-emission profiles put `kt` plus `missing` at 63.683% of
reachability and 51.062% of final-emission self weights. These percentages are
not promises that the corresponding runtime can be removed.

| Hypothesis | Smallest useful discriminator | Failure condition |
| --- | --- | --- |
| Constant computed keys cost avoidable V8 property work | Fixed-source B2 syntax derivative, exact semantics, paired requests and optional filtered constructor dump | No repeatable speed benefit, or changed special-key/evaluation semantics |
| Constructor queries create unnecessary miss records and scan unrelated owners | Separate no-intermediate-miss and checked-owner patches; synthetic lookup boundaries and actual emission | Lookup precedence/fallback changes, or cost shifts without reducing request/allocation work |
| Residual numeric binding reconstructs needless Word graphs | Typed scalar-origin proof, renamed default-binding fixtures, absence/presence controls and allocation profile | Changed bit result, demand, sharing, width, float or default-binding behavior |
| Known literal callbacks can become ordinary branches | Existing structural selector proof reused in direct lowering and tail-call facts | Wrong selector admission, evaluation/throw order, Unit capture or bounded stack behavior |
| Repeated serialization/rebuilding remains avoidable | Count/profile the operation, then isolate a small key-reuse or reconstruction change | No measured opportunity, larger helper cost, or changed reduction/context/error behavior |

## Sequential implementation waves

### 0. Freeze baseline and methods

Preserve all 103 inherited unrelated files, seven installed release files, and
closed Phase54–57 raw trees. New tools/receipts use Phase58 paths and private
driver/runtime/Base-cache copies. Preserve every failed target and consumed
producer. Record start time, exact sources/images, Node, CPU, cache policy and
timing boundaries. Phase57 supplies controlled prior evidence; every new speed
claim uses a fresh paired baseline under the new run's exact method.

Agents prepare isolated patches, fixtures and reviews in parallel. Root alone
applies production changes, freezes checked attempts and executes targets. A
patch prepared against the starting tree does not authorize combining untested
changes accidentally. Sequential ablations are cumulative only when explicitly
labelled; paired baseline and source-delta identities remain visible.

### 1. Literal record fields

Emit ordinary quoted field names for constructors, ordered constructors and host
marshalling clones. Keep `__proto__` computed so it remains an own property rather
than a prototype initializer. Preserve field/value order, duplicates, erasure,
Nat conversion, getters, throws, partial application and reentry. Reuse one small
key-format helper instead of separate policies at each site.

First compare a reversible, hash-bound B2 syntax derivative with its original;
then implement the same rule in Bend and qualify actual emitted programs. AST
shape alone is insufficient: execute special-name and ordering observations.
Generated `for(;;)` and aliases already disappear from optimized `kt`; do not
rewrite them merely because they look verbose.

### 2. Constructor lookup and allocation

First remove intermediate absence-record construction while traversing nested
constructor lists. Keep first-match order, cached-list stop behavior, explicit
Absent matches and final missing-result semantics. This should preserve even
the existing helper's unchecked graph behavior where practical.

Separately use a known normalized matcher owner to recover row telescopes in
checked books, falling back to the original search for unknown shapes or misses.
This targets `j_arm_type`, not Phase55's already implemented typed-arity shortcut.
Preserve constructor uniqueness checks and rejection of malformed definitions;
do not justify unchecked duplicate-owner behavior using a checked-book invariant.

Compare output bytes where this source-only optimization should leave emission
unchanged. Count intermediate probes/miss construction or sample allocation;
record reductions separately from record-syntax effects.

### 3. Native residual numeric bindings

Track the original scalar, fragment position and known prefix through typed
numeric views. Cancel only a structurally proved full-width reconstruction.
Ordinary Word consumers retain their object view; unknown/reordered/modified
fragments retain fallback behavior. Avoid constructing a Word graph solely to
convert the same proven bits immediately back to a scalar.

Start with the evidenced U32 path. Do not infer float equivalence from integer
bit equivalence: retain existing F32 whole-view rules and fall back for uncertain
residuals. Controls cover widths, masks, wraparound, captured default variables,
partial views, demanded versus unused fields and semantic negative examples.
The optimization recognizes representation facts, not `sk_char` or benchmark names.

### 4. Literal-choice lowering

Reuse the maintained structural proof of a Boolean selector. Require the actual
definition, signature/erasure, argument saturation and two literal callbacks;
renamed equivalent definitions may qualify, changed same-name definitions may not.
Reject ordinary calls cheaply before expensive normalization.

Emit direct branches at returns and a small scoped expression form where needed.
Preserve condition evaluation once, chosen Unit binding, callback captures,
demand/errors, partial/overapplication and tail boundaries. Update call-graph/SCC
facts alongside emission so new direct branches cannot bypass stack discipline.
Keep the runtime and legacy selector implementation unchanged unless evidence
requires a separately reviewed change.

### 5. Remaining allocation work and consolidation

Rerun profiles after the primary changes. Follow remaining significant allocation
sites with small discriminators: duplicate canonical-key generation, unnecessary
tree rebuilding, and declaration-event scans. A prepared key-reuse patch may
share one serialization result within an existing branch; it must demonstrate
benefit before retention. Do not introduce context-insensitive caches, pointer
identity assumptions or a broad term-representation rewrite without evidence.

Combine surviving changes, remove superseded implementation scaffolding when
safe, and document the remaining bottlenecks. Rejected or inconclusive proposals
remain explicit results rather than being installed to claim completeness.

## Fast loop and validation

Use a genuine checked B1 build and focused controls for each source ablation.
Use saved-image derivatives only for code-shape causality, with explicit parent,
producer, output and semantic scope; never fabricate checked B2 sidecars.
Fresh ordinary library requests compare each compiler with its own independently
executed output oracle: optimized JavaScript text may legitimately differ.

The first screen uses lexer with baseline/candidate, one fresh process each and
the same first-plus-repeat schedule. Escalate promising results to three rotated
rounds and both lexer/Evening. Keep TypeScript as an explicit role in the final
comparison. Allocation/CPU/V8 captures run separately and never enter clean
medians. Use fixed-source comparisons to isolate code generation and labelled
changed-source comparisons for compiler algorithms; do not pool the two.

Final integration runs the applicable 96 source / 34 numeric / 18 composition /
2 overapplication controls, maintained suites, representative program acquisition
(23 sources / 45 points), native retention and installed interfaces. Validate
changed emitted bytes through their program oracles and measure changed runtime
points; a broad emitter change warrants a new representative aggregate. Retain
known TypeScript oracle failures separately. Run fresh self-check and B2→B3 exact
reproduction once for the selected compiler. Type acceptance and reproduction
remain distinct from proof trust for the explicitly unsafe source.

Install only the qualified selected artifact, preserving previous release bytes.
Update compiler documentation, README, experiment ledger and steering. Commit
and push design, implementation checkpoints and final report under existing user
authorization. No repeated permission request is needed for this work.

## Resources, accounting and success criteria

Heavy targets are serial on CPU3, with a 1 GiB Node heap, 2 GiB process-tree RSS
ceiling and 4 GiB available-memory floor. Do not nest execution guards. Data-only
analysis uses CPU0. Full-emission profiling uses the successful 25 ms/two-stage
method, not the high-memory all-stage 1 ms attempt. Guard failures remain failed
evidence; reduce capture scope before considering a larger resource budget.

The report separates compiler latency, generated-program runtime, allocation
churn, peak memory, code size and source complexity. Report exact observed gains,
scope and uncertainty; no promise of TypeScript parity substitutes for results.
Account recorded execution intervals and elapsed work without labelling all
unrecorded time as waiting. Success is a qualified, documented compiler with
measured useful improvements and preserved semantics, plus clear decisions for
every proposed optimization.
