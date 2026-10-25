# Reusable checked compiler units: a concrete path to5× rebuilds

2026-10-25, investigation at `df803e9`, selected compiler Phase137 N3. This is a
source-grounded proposal, not implemented incremental compilation. The four
[architectural options](../../design/phase139/compilation-speed-options.md) remain
conditional estimates. [Offline inventory](inventory.json) · [Inventory method](inventory.py) ·
[Prior measured costs](../../implementation/phase138/README.md).

## Decision

Choose **early reuse of checked source owners and their generated implementations**.
This has the strongest plausible return for local compiler edits: unchanged work
can disappear from several expensive stages together. Start with conservative
sequential checker checkpoints and one reusable owner, then refine dependency
tracking. Existing source files and positional object groups are not independent
semantic modules.

The target is an actual newly runnable compiler after a source edit, first below
69.3s (5× the346.391s cold reference), eventually below20s. Cold compilation and
complete independent qualification remain separate objectives and costs. This
proposal does not establish a5× cold-build improvement or guarantee every edit
will be local.

## New evidence and corrections to the earlier outline

### The source is modular for authors, not for independent compilation

The frozen source contains58,569 physical lines and7,291 lexical declaration
starts:6,337 `def`,273 `type`,681 `law`. A law count is not a count of proved
mathematical properties. There are133 distinct immediately attributed provenance
paths;98 occur in multiple disjoint declaration runs. Another2,547 declarations
lack an immediately preceding `# Module` marker. That does not mean their origins
are unknowable or their source is unqualified; the lexical inventory deliberately
does not infer missing metadata.

Consequently, treating each authoring file as a contiguous checker prefix is
wrong. Declaration assembly, earlier laws and later fills cross those boundaries.
Keep authoring modules, semantic units and machine batches distinct.

### Textually unchanged headers are not enough

In the selected source, `declared` at9030 erases a definition's value but retains
its type, complete constructor/child tree, arity, template count and native/unsafe
flags. `check_declarations`9081 retains a Foreign definition's entire body.
`signature_mode`9065 observes the first later matching declaration, while initial
declaration installation uses sequential replacement. Equal final signature maps
therefore do not preserve all observations; ordered declaration views matter.

More fundamentally, `ffd_type`14552, `ffd_value`14559 and `ffd_frame`14575 thread
one fresh-ID counter through types, bodies, children and subsequent definitions.
A new binder in a body can renumber later types without changing their text.
Balanced binder additions/removals can preserve the final maximum while changing
intermediate identities. The conservative first contract must compare actual
post-freshening declarations, not textual signatures plus one maximum value.

These are source-level falsifications of weaker proposed admission rules. They
were found without running a compiler campaign. The strengthened rule below
still needs a proof and native experiments.

### Stable symbol spelling is not sufficient either

The selected QBE reproduction contains63,377 function definitions,49,013 dispatch
entries and592 data declarations. The lexical scan finds222,146 direct call sites
and no textual indirect QBE call. The runtime still performs indirect dispatch;
absence of `call %pointer` in QBE does not establish a closed direct-call graph.
The existing owner map attributes62,667 functions and leaves710 unknown; it is
profiling metadata, not a semantic unit certificate.

Most public/helper symbols already derive from semantic names. Continuation
freshness, numeric function/constructor IDs and static literal placement remain
global. The earlier real spelling edit changed476 generated functions and two
data declarations.377 functions differed only in recognized numeric copy
operands, with1,732 observed shifts of+12. Literal movement is a strong hypothesis,
but exact graph correspondence has not yet been established, and the other99
changed functions remain to be classified.

`p112s_word`42107 encodes boxed literals with low word `51413504 + offset` and
high word `(2 << 24) | (constructor_id << 8)`. `p112s_intern`42164 assigns offsets
in encounter order. The runtime copies the static image into its own heap.
These are tagged heap-relative integers, not ordinary native pointers; making
the static blob a linker symbol does not solve the relocation problem.

The current image contains46,071 eight-byte static words, independently matched
to descriptor slot8, against the65,536-word admission limit. There are19,465 words
of current headroom. Stable append-only literal slots are therefore a bounded
experiment, not an indefinitely growing cache. Admission on budget exhaustion
changes generated code and must remain part of the dependency contract.

## The unit and its interfaces

A semantic owner is initially one source definition plus its generated closures,
continuations, selected private workers and fallbacks. A recursive or mutually
dependent optimization region may require an explicit group. The compiler must
produce this membership; a host script must not reconstruct it from symbol names.

Conceptual interface, not new Bend syntax:

```text
Epoch       = builder + checker + Base + runtime ABI + policy + schema + tools
HeaderView  = ordered post-freshening projected declaration events
Checkpoint  = epoch + header/prefix identity + bound + complete KWorld + seen
OwnerInput  = stable source owner + checked body/type + consumed semantic facts
NamedUnit   = existing erased/lowered IR + local names + symbolic external refs
VerifiedUnit= NamedUnit + successful existing checks + checked environment
BoundUnit   = VerifiedUnit + current FID/CID/literal bindings + emitted artifact
```

Use only fields required by the active experiment. Immutable compiler state
stays in Bend, initially in one resident process; host code may transport bytes,
supervise resources and link objects. Avoid serializing large checked graphs
into JSON or implementing a second compiler in the supervisor.

```mermaid
flowchart LR
  A[Current source revision] --> B[Validate reuse conditions]
  B --> C[Resume checking and rebuild dirty facts]
  C --> D[Lower dirty owners]
  E[Unchanged verified units] --> F[Current binding and cross-unit checks]
  D --> F
  F --> G[Emit changed units and link]
  H[Unchanged objects] --> G
  G --> I[Focused independent validation]
```

## A sufficient candidate checker contract

Define `H(d)` as the complete definition for Foreign bodies, otherwise
`declared(d)`. Consider revisions `P ++ S0` and `P ++ S1` after the actual parser
and freshener. The first prototype admits reuse only when:

1. Both pass the ordinary frontend validation preceding the checkpoint.
2. Their prefix `P` is exactly equal, including term variants and source spans.
3. Their ordered projected suffixes `map(H,S0)` and `map(H,S1)` are exactly equal.
4. Their complete-book fresh-ID bound is equal.
5. Prepared Base, checker implementation and epoch are unchanged.
6. The checkpoint captures the actual complete `KWorld` and `seen` at
   `dg_check_events`16522, not reconstructed approximations.

`KWorld` includes the book, specialization memo, fresh state and checked outputs.
`sp_live_memo`10137 and `sp_live_body`10156 show why memo entries, active recursion
markers and generated instances cannot be dropped. `dg_event_publish`16550
observes later-name absence. Resume using `S1`, and finalize diagnostics, TODO
accounting and origins from revision B—not revision A's completed result.

The existing `f_fresh_prefix_exact_defs`15841 provides exact comparison including
variants, literals, quantity presence, spans and children. Conversion equality
would be weaker than the contract. Full comparison/re-freshening has real cost:
measure it. This first step keeps parsing fresh and cannot alone reach5×.

The initial proof obligation is replay equivalence under those premises, linked
to the actual transition wrapper. A generic list-fold theorem or successful
source checking alone would not establish checkpoint completeness. A proved
checkpoint rule would preserve fresh checker behavior; it would not prove the
checker, erasure, QBE runtime or complete compiler correct. The current checker
transitions are marked `@unsafe`; writing a new law declaration does not make
them independently proved. A checked traversal model needs an explicit production
bridge, or a justified extraction of the relevant transition into the checked
fragment. Keep that obligation separate from the first differential prototype.

## Carry reuse through the expensive stages

| Existing boundary | Retain | Dependencies that must be explicit |
|---|---|---|
| Parser/freshener | Parsed event fragment and local state | Namespace, aliases, prior names/constructors, binder allocation, spans and unsafe flag |
| `dg_check_events`16522 | Complete successful prefix state | Ordered headers, bound, Base, memo/fresh state and later publication/fill facts |
| `annotate_selected`10805 | Annotated definition | Reducible bodies, type/telescope queries, reachability/stops and ownership |
| `nr_visit`36288 | Existing `NativeErasedBody` | Checked definition, arity, constructor/primitive facts and referenced definitions |
| `p128raw_prepared`56420 / `p111_compile_defs`40050 | Named owner lowering and alternatives | Call signatures, helper readiness/refusal, effects, layout, ownership and inlining inputs |
| `p134v_commit`58336 and emission | Verified unit and rendered bytes | Exact verifier environment, current bindings, runtime ABI and selected worker graph |

The earliest safe hit must occur **before** the expensive producer is executed.
Comparing a newly generated erased body or QBE string with its cached copy does
not avoid its production. Record consumed queries while producing the first unit;
on a revision, validate those facts before invoking its producer. Unknown read
families force recomputation. Initially key a larger explicit environment where
necessary, while reporting the lost reuse honestly.

Global optimization may combine owners. `p131p_closed`57620 retries against the
merged available-helper signatures, including absence. Do not reuse a refused
candidate when a newly available helper could change admission. Group mutually
dependent decisions, or invalidate their consumers. Preserve the current final
verifier while establishing reusable checks and separate current cross-unit
obligations. There is no proof today that all final verification can be skipped.

## Two stages of binding, and two different reuse claims

**Stage A: semantic reuse with canonical final binding.** Retain symbolic
FID/CID/literal references and owner-local continuation names. Existing
`N111FuncId`/`N111CtorId` already preserve names until rendering; keep that useful
boundary and extend it to literal DAG identities. Rebind against the current
canonical image. Require exact fresh-reference products initially. Binding
changes may still invalidate emitted bytes and objects even when analysis is
reused. Charge that cost; do not call it a machine-cache hit.

**Stage B: stable bindings within a fixed producer epoch.** Test append-only
function/constructor/literal slots to preserve unaffected objects. Define
deletion/tombstones, literal deduplication, capacity, constructor-layout changes
and compaction. The current static verifier expects contiguous image nodes;
stable layout must satisfy that invariant or introduce a separately justified
verifier change. Do not silently accept holes or stale references.

Two histories of edits may then produce different layouts. Reproducibility must
include the binding manifest, and comparison against a canonical clean build may
be semantic rather than byte-identical. Keep this distinction explicit. Prefer
immediate runtime IDs with stable compile-time binding over new runtime table
lookups; adding loads to preserve objects could regress generated-program speed.

Before implementing Stage B, decode the historical1,732 shifted literals and
classify the other99 changed functions. This is a cheap artifact-only falsifier
of how much stable binding would actually preserve. Do not normalize arbitrary
numeric constants and declare equivalence.

Machine batching is independent of semantic identity. QBE can compile complete
functions independently, but launching63,377 separate compiler/assembler jobs
would waste time. Group stable semantic units to amortize startup. Phase135's
1,000-bundle positional groups are transport units, not semantic owners; insertions
must not renumber every later cache key. Preserve exact calling conventions,
symbol visibility, relocation meaning and selected runtime references.

## The proposed experiment sequence and stopping rules

**A. Checker falsification, roughly2–4h of implementation/testing.** Add one
checkpoint location, not snapshots at every declaration. Start with small actual
checker workloads and the retained spelling edit. Add a genuine numeric policy
edit, such as a same-width change to the512-size admission threshold in
`p113i_eligible`, compiled by the fixed builder. Compare complete fresh/resumed
worlds and diagnostics. The spelling edit alone is insufficient transfer.

Reject or fall back on new binders, changed Foreign bodies, child definitions,
flags, law fills, declaration ordering or spans. Include balanced binder edits
with unchanged final bound, invalid-edit recovery and a template-instantiation
case sensitive to memo/fresh state. Stop if the proposed premises fail to capture
an observed dependency; do not weaken comparisons to get a hit.

**B. One reusable prepared/lowered owner, roughly1–2 focused working days for a
prototype, with substantial uncertainty.** Retain an actual `NativeErasedBody`
and its named lowering/verification result. Challenge body/type/layout,
absent→present helper, effects, continuation insertion and literal changes.
Compare freshly generated output under both revisions. Count skipped producers,
not merely equal results. A cache must avoid a material share of work after
charging dependency checks, binding, memory retention and destruction.

**C. Integrate output/object reuse.** Use the existing framed QBE machinery with
stable semantic membership and current cross-unit checks. Measure full edit to
executable and focused validation. Require5× only on a declared localized-edit
set, and publish fallback/global-edit costs too. Binder-changing and type edits
must remain in the suite even when they intentionally take the slow path.
Implementation duration is unknown until A/B expose the remaining global work.

**D. Broaden and improve cold compilation.** Introduce stable frontend identity
or checked renaming only if binder churn frequently rejects useful edits. Expand
query families and merge/split owner groups based on measured dirty time. Then
compact the retained representations and parallelize independent units. These
are earned extensions, not prerequisites for the first falsifier.

Keep the qualified builder fixed across candidate revisions. A change to the
candidate optimizer is input to that builder, not automatically a producer-epoch
change. Adoption of a newly qualified builder intentionally starts a new epoch.
Candidate call dependencies can still cause wide invalidation within the old
epoch; neither rule makes arbitrary changes cheap.

## Time budgets that make the gain falsifiable

Use the illustrative model `Tedit = F + d*C`, where `F` is fixed edit overhead,
`C` is avoidable work and `d` is the remaining fraction of **time**, not owners.
These examples allocate the346.4s baseline; they are not measured decompositions.

| Fixed overhead F | Avoidable C | Dirty fraction d | Predicted edit | Ratio to346.4s |
|---:|---:|---:|---:|---:|
|10s|336.4s|50%|178.2s|1.94×|
|10s|336.4s|25%|94.1s|3.68×|
|10s|336.4s|15%|60.5s|5.73×|
|10s|336.4s|5%|26.8s|12.9×|
|5s|341.4s|4%|18.7s|18.6×|

The20s target requires both low fixed work and very strong weighted locality.
Leaving the historical roughly65s rendering boundary or fresh53s checking stage
unchanged defeats it. Fewer machine objects alone cannot establish it either.
Every experiment must report preparation, invalidation, reused/dirty stage time,
binding/emission, machine construction, validation, peak memory and acquisition.
Also report total research cost including failed attempts and periodic qualification.

Retain at most a bounded number of revisions; never keep every historical world.
Start with current/pending transactional state and explicit eviction. Enforce the
existing4GiB process-tree/16GiB available-memory policy for compiler-sized work.
Do not infer retained-cache size from the current approximately1GB cold peak.
Cache updates publish only after all required work succeeds; failed edits keep
the previous successful state usable. Bind disk budgets as well as RAM.

## Correctness and generated-program performance

Reuse preserves decisions; this plan does not achieve speed by disabling
optimizations. Check exact QBE when canonical binding permits; otherwise compare
the complete current executable against a separately fresh build, including
runtime results and the appropriate ABI/ownership/relocation gates. Reuse
unchanged benchmark evidence only through exact relevant artifact identities.
Runtime/performance checks remain necessary where code or layout actually changes.

A structural IR verifier cannot detect every stale semantic result. A hash is
an identity mechanism, not a theorem. A narrow replay/index/dependency law should
be independently checked and connected to the actual implementation. Whole
compiler correctness and foreign/runtime correctness are not established by it.
Keep expensive proof construction outside routine edits, and measure admission
cost before claiming proofs accelerate research.

## What this investigation did

Saved the four ambitious options, traced the current checker/freshener, erasure,
lowering, literal binding and object boundaries, and performed a reproducible
offline inventory of frozen source/QBE. Two bounded read-only agents independently
audited checker contracts and machine binding. No compiler was rebuilt, no target
benchmark ran, no new proof was checked and no production source changed.

The strongest new conclusion is that **the useful architecture is two-stage:
reuse checked/named work first, then preserve machine bindings where profitable**.
Textual signatures, source-file boundaries and stable linker symbols each omit
information the current compiler actually uses. The next implementation should
prove and test one precise boundary before expanding it.
