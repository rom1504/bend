# Phase173: complete record updates without destructive field transport

Status: checked experimental Bend implementation, 22/22 finite controls, and
independent source audit; not installed or a measured performance improvement.
Root owns all target execution.

## Why this slice

The selected source contains complete allocating record transformations in
`selfhost/src/core/term.bend`: `k_with_children`, `k_with_span`, `k_rebuild`, and
related immutable updates. The actual Phase171 generated direct workers for
`k_with_span` and `k_with_children` take an eight-field constructor, load its
fields, drop replaced children when necessary, copy retained fields through
locals and scratch, then call the constructor helper. The final returned record
preserves most source fields. This is an allocating transformation, unlike
Phase171's read-only descendant selectors.

The generic take releases unique record storage; the subsequent constructor
allocates storage and reseals every field. For a shared record, take instead
acquires field credits and drops the parent's credit. Parent uniqueness does
not imply child uniqueness.

`nc_erase` and `nr_walk` are much larger consumers. `nc_erase` also calls
weak-head normalization, substitutes dependent telescopes and changes variant
or child shape. `nr_walk` builds a reachable-definition closure and retained
erased-body facts. Neither can honestly be replaced by a record-update helper
alone. The first experiment tests a reusable execution primitive that these
consumers may benefit from; it does not claim a borrowed implementation of the
whole eraser or optimizer.

## Implemented interface

The maintained preparation tool inserts `borrow-prelude.bend`, then appends
`borrow-record.bend`, `borrow-emission.bend`, and `borrow-controls.bend`.
The first checked API used `borrow-entry.bend`, replacing `p113w_stmts` only.
Production source and the protected independent verifier remain unchanged.

A subsequent selected-emitter audit found additional direct-body dispatchers:
`p134e_private` selects `p126i_emit_one` in mode2. Typed buffers/table calls then
use `p126i_stmts`, while ordinary functions generally reach `p113e_private` and
`p113w_stmts` through `p113ah_function`/`p126s_prior_function`. The typed lane
dispatcher `p126l_stmts` also emits scalar statements without entering
`p113w_stmts`. Therefore absence of a template in API02 output is not by itself
evidence of universal shape refusal across all selected dispatch paths.

The separate `borrow-entry02.bend` adds those two exact dispatcher replacements;
`borrow-prelude02.bend` and `borrow-dispatch02.bend` provide a shared
`p173b_attempt` interface reusing the same plan and template. The original typed
dispatch receives exactly the previous context, facts and code on refusal.
An accepted region returns, so it has no outgoing typed-fact state to preserve.
No float operation or other typed group is admitted inside the region.
`p173b_dispatch_controls` adds eight direct/nested-dispatch and refusal-identity
controls. This variant requires a new frozen acquisition; API02 is unchanged.

`p173b_plan(body, ids)` returns either a refusal or a semantic record-update
plan: source owner, constructor identity, width, final field origins, and
ordered consumed-field indices. It does not contain QBE text or a benchmark
name. `p173b_profitable` separately requires at least one change and preservation
of at least half the fields. The QBE template is a separate final-emission step.

The admitted complete region is:

1. Take one ordinary constructor into an authenticated local scratch buffer.
2. Load fields, copy local aliases, and sink selected replaced fields.
3. Store each final field once, preserving old fields only at the same offset.
4. Construct the same known layout and immediately return its sole result.

The scan is bounded to 256 statements and widths 2–16. Unknown calls, effects,
branches, permutations, escaping roots, duplicate sinks/stores, unsupported
types, incomplete output, and overwritten external identities refuse. A source
field omitted from both retention and explicit sinks must dynamically prove
trivial before overwrite; this covers unused scalar fields.

## Runtime choice and guarantees

The fast arm requires the same constructor ID and privately owned dynamic
storage: raw ownership or an RFC wrapper with count exactly one, with the
decoded payload beyond the active program's computed heap boundary. Every
retained field must already be sealed or non-CTR. Shared and static sources use
the entire unchanged region. The first version fell back for every capability-8
program; revision04 refines this to the exact per-constructor publication rule
described in the experiment log below.

All old fields are snapshotted before any sink. Original sink order is retained.
Preserved fields remain in the original owner; they are neither taken nor
resealed nor copied into another allocation. A raw dynamic replacement is
sealed through existing `keep` followed by `sink` of the returned wrapper,
changing its count from two to one. Raw static replacements use fallback.
Replacements are installed in original constructor-index order. The existing
owner is returned, including an existing unique wrapper when present.

No runtime import, C compiler algorithm, allocator modification, host stack
recursion, or protected112 verifier edit is introduced. The template is pinned
to the current sequential CPU ABI and one heap mutator. It is not GPU/parallel
qualification and does not preserve allocation identities or failure due to
resource exhaustion.

**Trust boundary:** the independent final verifier continues checking the
original P113D program. The new memory-operation template extends trusted
emission, so that check alone does not establish its correctness. See the
separate [independent audit](borrow-audit.md), ordinary source oracles and
execution evidence before considering promotion. These finite checks are not
a BendTT proof or an affine-ownership proof for arbitrary hand-written IR.

## Cheap gates and expected falsification

`p173b_controls` contains 22 finite admission/rendering controls, including
external-identity overwrite, aliases, field permutation, duplicate disposal,
missing output, unknown effects and unknown direct calls. They manipulate
compiler data; none executes malformed runtime values.

`borrow-workload.bend` is an ordinary checked-source candidate containing
repeated five-field span updates, owned raw replacements, aliased children,
shared/static parents, a unique-wrapper case, and a recursive persistent-tree
consumer of a four-field update. Independent arithmetic expected values are
`[200045,111,20,177,51,71,22,88,10044]`, returned as a complete list rather than
only a hash. `borrow-alias-workload.bend` separately returns complete records
before/after shared, static, uniquely owned and child-alias updates. Source
checking and an upstream oracle must confirm these before using them as
execution gates. They are transfer/control workloads, not representative
full-compiler benchmarks.

`borrow-compiler-workload.bend` and its separate main module drive the actual
unchanged `f_span_created` and `g_share_head` algorithms, plus ordinary
`k_with_children`/`k_with_span` composition. Assemble their dependencies from the
canonical source rather than substituting toy implementations. The result
contains complete KTerm, GResult and GHeap values, including origin boundaries,
removed-name lists and lambda quantity-presence flags. This is an actual-pass
semantic/admission control; a broader checker workload remains necessary to
estimate compilation relevance.

The root's target sequence should first source-check and run finite controls,
then emit baseline/candidate for the same ordinary workload, inspect actual
template admission and publication flags, check independent output, and time
complete acquisition plus generated execution separately. A body merely
containing a fast branch does not establish that any execution takes it.
Actual unique/shared hit counts or a controlled dynamic ablation are required
before extrapolation. Use the same existing runtime/toolchain and resources.

Do not acquire a full self-hosting image if the representative consumer is
neutral, mostly falls back, or template expansion costs outweigh saved work.
The historical caller profile does not establish that these setters dominate
the complete request. A credible whole-build ceiling remains **unmeasured**;
there is no defensible 2× or 10× claim from this slice.

## What this does not yet solve

The larger target is borrowing immutable input through a complete allocating
pass and returning independently owned output, rather than repeatedly taking,
keeping and reconstructing input. The current slice retains ownership only
inside a terminal private update. Shared roots still take the old path; calls
inside the region refuse; whole-tree producer/consumer fusion is not present.

A shared-root borrowed-copy arm could keep only escaping fields, build the
owned result, and finally release the input root. It avoids temporary credits
for replaced children but still copies retained fields, so its gain ceiling may
be low. A more consequential extension needs borrowed lifetime and ownership
summaries across allocating calls/continuations. That should follow measured
whole-consumer evidence rather than another unqualified recognizer expansion.

Useful semantic information to retain if this succeeds is small: field-origin
mapping, complete disposal obligations, pre-region owned replacements, source
layout identity and a terminal owned result. It can be backend-independent;
the unique-storage guard and exact RFC sealing remain runtime-specific.

## Experiment state

The first API snapshot failed parsing a computed `match` in one finite-control
helper. It was replaced with a match on a helper parameter; all other module
match subjects were audited as variables. The second root-controlled acquisition
passed source checking: `selfhost/build/phase173/borrow-api02/report.json`,
source SHA256 `1279146f6b09635e73d4522f4e15d716328e428cfe85e6791402a97c3cd28930`.
Acquisition took 14.881s; this is setup, not a generated compiler speed metric.
`selfhost/build/phase173/borrow-finite01/report.json` records 22/22 passing finite
controls and preserves the exact template in `template.txt`. The runtime and
whole-consumer gates remain separate and pending. Keep the failed snapshot in
the root's evidence ledger; no native speedup is claimed from these checks.

The first real verifier-source emission is a useful negative:
`selfhost/build/phase173/borrow-verifier-emission01/report.json` records a
30.447s complete hosted request and **byte-identical** 2,309,376-byte QBE, SHA256
`8be3a072b84dfc8bb85ddb9478c00d05179f7de89c8d4079af9ca3a5190bfbfb`.
No record-update template was emitted. Root correctly skipped rebuilding the
identical machine program. This workload cannot measure benefit from the new
capability; it establishes neither speedup nor lack of speedup on actual term
updates. It reinforces the need to inspect admission before native builds.

API03 adds the typed dispatcher hooks and passes the original 22 plus eight
dispatcher controls. The actual compiler-pass driver then emits templates in
`$direct.k_with_children` and `$direct.k_with_span`. Its candidate QBE is 469,691
bytes versus the baseline's 432,563 bytes, 8.58% larger. Single hosted requests
took 10.098s and 9.466s respectively; these unpaired setup observations are not
a throughput result. Receipts are `borrow-compiler-candidate01/report.json` and
`borrow-compiler-baseline01/report.json` under `selfhost/build/phase173`.

Inspection caught a decisive eligibility problem **before a machine build**:
the descriptor has capabilities13, so the conservative global cold-mode guard
blocks all those fast arms. The actual guarded constructor IDs150/151/152 are
KTerm/KLambda/KLiteral and all three have `cid_hot=1`. Existing runtime semantics
already seal their fields even with capability8. Revision04 therefore admits
`capability8 absent OR authenticated constructor hot`, preserving fallback for
cold, missing, legacy or inconsistent metadata. The selected ID index had
discarded the hot bit; an explicit source-only index override now preserves it
using the previously audited Phase172 metadata slots, without changing numeric
IDs or arities. Eight additional finite policy controls accompany the change.
The independent audit documents why this index and `cid_hot` table derive from
the same final verified constructor list. API03 remains frozen evidence.

Independent full-value oracle transport is in `borrow-oracle.mjs`: it accepts
only an upstream-checked workload API exporting `main`, verifies all pinned
inputs and exact source type declarations, evaluates `main` once, and serializes
the complete schema-checked value as constant Bend source. It does not implement
the compiler algorithms in JavaScript. The compiler driver observation is saved
in `borrow-compiler-oracle-observe01`: 320 observed value nodes, depth13, complete
JSON SHA256 `8bef701279b3278c88f6141c0d3b5a8ae03f01dced7206523a349d9d2decbdea`.
Its 2,369-byte constant oracle has SHA256
`64ea7ffa9d9af0b37836cfc90b112fc241654ebb4896ad58a0e7118520455ccf`.
The unchanged compiler must independently check/build that constant; subsequent
native complete readbacks, actual fast-arm execution and timing remain distinct
gates. Static source inputs can still cause legitimate fallback after the hot
policy is fixed, so template presence alone is insufficient.

`selfhost/tests/phase173/events.py` is the bounded observation transport for this
gate. It authenticates the complete native build, retained QBE, exact linked
diagnostic runtime product, reversible profiler plan, runtime compilation job,
and all pinned inputs/outputs. The root runs it within the existing Phase173
CPU3 guard, with one Bend heap mutator and GPU disabled. It requires independently
established complete stdout bytes and empty stderr; the event output is a fresh
exclusive path, and incomplete/overflowed or invalid-context captures fail.
It neither modifies the runtime nor implements a compiler algorithm in Python.
The helper's syntax and finite metadata/schema checks passed without executing
any target. Native capture and performance evidence remain root-owned.

The useful counters are `ctr_take_calls`, `heap_alloc_calls`, and requested heap
words, with keep/sink/drop counts as explanatory details. An admitted update
should avoid the original parent's take/reconstruction and associated runtime
allocation. These are runtime hook counts, **not** a dedicated branch-hit
counter: generated inline operations bypass them, and private calls retain the
outer dispatch identity. Same-source baseline/candidate changes with exact
independent output can demonstrate avoided runtime work but do not attribute
every change to a particular source field. Counter timings must not be reported
as clean performance. The existing ordinary workload's repeated span updates
over dynamically allocated children are a stronger positive-coverage control
than the mostly closed compiler driver. A minimal actual-compiler extension is
a repeated unchanged `k_with_span` call over a dynamically constructed KTerm,
returning the complete final term and an untouched shared alias, before trying
larger recursive compiler computations.
