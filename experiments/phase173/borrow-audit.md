# Phase173 whole-record reuse: independent correctness audit

Status: source audit of the experimental scanner and emitter, before execution
qualification. No compiler, target, malformed-runtime probe, or benchmark was
executed by this audit. This is not a proof of compiler correctness or permission
to replace the qualified compiler.

Audited files:

- `selfhost/tests/phase173/borrow-record.bend`
- `selfhost/tests/phase173/borrow-emission.bend`
- `selfhost/tests/phase173/borrow-controls.bend`
- Selected `selfhost/src/runtime/qbe/runtime.c` ownership/constructor operations.
- Existing QBE statement emission and checked ABI boundaries.

## Proposed equivalence and its scope

The original region takes an owned record into scratch fields, drops selected
old fields, writes a complete same-layout constructor into scratch, constructs
that record, and returns it. The fast region keeps a private record allocation,
retains unchanged fields in place, drops replaced fields, installs independently
owned replacements, and returns the retained owner. Shared/static/unsupported
cases execute the original region.

The intended equivalence is source-visible value and ownership behavior on
valid checked Bend programs, with the selected sequential runtime. Allocation
counts, addresses, wrapper shape, allocation-failure behavior and diagnostic
allocator traces are deliberately not identical. Original final verification is
retained; the new postverification emission template remains trusted compiler
code, like existing postverification templates. Neither structural N111
verification nor these finite controls proves affine ownership for arbitrary
hand-written N111 programs.

## Runtime facts used

The relevant definitions are in `selfhost/src/runtime/qbe/runtime.c`:

- `LOC_MASK` is 40 bits; `HEAP_OFF = STAT_OFF + PAGE_UP(STAT_LEN)` is dependent on
  the active program, not just a fixed constant.
- `term_triv` (around line 849) accepts scalar/packed values, `TERM_HOLE`, and
  locations below the heap boundary.
- `rfc_seal` (around line 863) wraps a raw constructor at count one, including a
  raw static constructor. Already-wrapped constructors and other tags pass
  through unchanged.
- `term_keep` (around line 926) increments an existing wrapper, returns trivial
  raw terms unchanged, and wraps a nontrivial raw term at count two.
- `term_sink`, `span_fade`, and `ctr_take` (around lines 1055–1094) distinguish
  unique raw owners, unique wrappers, and shared wrappers. Taking a unique
  wrapper frees that wrapper; a shared take creates independent field credits
  before dropping the parent's credit.
- `p111_rt_ctor` (around line 3936) checks the constructor arity and either seals
  fields or, with capability 8 and a cold constructor, copies fields raw.
- `p111_rt_take` (around line 3951) checks the actual constructor arity and tag,
  then copies fields and releases the input payload when unique.
- The Phase144 single-mutator contract permits non-atomic RFC operations only
  for the pinned sequential runtime and audited effect providers. This pilot
  must not silently apply to CPU parallel, GPU, or unknown-provider execution.

## Necessary guards and what the current implementation does

| Obligation | Audited implementation / qualification boundary |
| --- | --- |
| Same constructor, not merely same width | Exact output constructor ID is checked against the root; its width is known from verified constructor metadata. Width is restricted to 2–16. |
| Parent is privately mutable heap storage | Root tag is exactly raw CTR (`2`) or wrapped CTR (`130`). Raw roots use their own location; wrapped roots decode the payload and require count exactly one. Payload must be at or above the computed active heap boundary. |
| Static wrapped payloads are also excluded | The heap check is on the decoded payload, not only on the wrapper location. |
| No speculative mutation before fallback | All type/identity/ownership/field guards execute before any sink or store. The false branch retains the original scalar statements and final return. |
| Unchanged fields retain their ownership | Every preserved field must occupy the same final offset and must not appear among explicit sinks. Every final offset appears exactly once. |
| A preserved field must not lose required publication | The emitter refuses every retained raw CTR, static or dynamic (`tag == 2`). This is conservative even for cold constructors and avoids skipping a required original seal. `term_triv` alone would be insufficient here because static raw constructors are trivial but still sealed by the ordinary hot constructor. |
| Replaced old fields are consumed exactly once | Each explicit sink is tied to one loaded field; duplicate sinks are refused. Missing explicit sinks require a dynamic `term_triv` check before overwrite. |
| Dropping a field cannot invalidate later loads | All old fields used by the fast path are snapshotted before any sink. Original sink order is preserved. |
| Replacement values are real pre-region values | Alias copies resolve to their original external value; the final scan rejects an external identifier rebound within the region, direct root references, state/scratch, and unresolved origins. |
| Raw dynamic replacements become publishable | `keep(raw heap CTR)` creates count two, and `sink(the returned wrapper)` decreases it to one; the returned wrapper is stored. Sinking the original raw value instead would be wrong. |
| Raw static replacements do not use an invalid seal recipe | They use the original fallback because `keep` of a trivial raw static term would not wrap it. |
| Cold publication policy remains unchanged | The emitter requires `(program.capabilities & 8) == 0` before payload access; all capability-8 programs use the original fallback. |
| Effects and escape remain absent | Unknown calls, direct helper calls, control flow, cross-offset field permutation, duplicate stores, and incomplete constructors are refused. Only the complete terminal result is replaced. |
| Stack safety and return ABI | The fast path adds bounded straight-line/conditional work and existing stack-safe sinks. Only singleton terminal `P113DResult` is admitted; its existing emitter is a scalar QBE return. Multi-result ABI transport is not admitted. |

No additional obvious ownership bug was found in the current guarded template.
This conclusion depends on the valid-source ownership assumptions below and on
the execution controls still required; it is not a promotion result.

## Aliasing and ownership assumptions that must remain explicit

1. A private parent does **not** imply private children. Preserved wrapped
   children can remain shared; their reference credits are retained unchanged.
   A replaced child may have surviving aliases and must receive exactly its
   original sink, not a forced destruction.
2. A replacement can equal an old child only if it carries a separate legal
   ownership credit. The existing source lowering must establish that credit.
   The scanner does not prove ownership simply by seeing two different local
   names. Likewise, an external alias of the root is expected to make the root
   shared and cause fallback; unchecked raw-pointer aliases are outside the
   source language contract.
3. The valid heap graph is acyclic. Dropping an owned descendant cannot reach
   and free the retained parent. The grammar also refuses a direct root-as-field
   replacement. This is not protection for forged cyclic runtime values.
4. An RFC-count-one input returns with its original wrapper, whereas the
   original take/new-constructor sequence normally returns a new raw root.
   Generic tag/peek/take/keep/sink consumers accept both representations.
   Any caller optimization that assumes this function returns an unwrapped
   fresh constructor would need its own audit; no such cross-call guarantee was
   found in the inspected relevant QBE paths.
5. The initial emitter sealed replacements even in capability-8 cold mode,
   while the original constructor could copy those fields raw. This was raised
   during audit. The implementation now conservatively requires capability 8
   to be absent, using the complete original fallback otherwise. Extending the
   fast path to cold mode later requires matching its publication rule and
   auditing specialized consumers; generic runtime support alone would not
   establish exact compatibility with every optimization assumption.

## Cheap decisive controls

Run ordinary checked Bend source programs through the unchanged baseline and
candidate, using an independent upstream output oracle where available. These
are positive semantic cases, not invalid-memory probes. Check that generated
code contains the admitted template; a test that only executes fallback cannot
establish the fast arm's correctness.

1. Update one scalar field of a dynamically built record, retaining at least
   half its fields. Include the compiler's actual `k_with_children` or
   `k_with_span` shape and an unrelated record/tree update.
2. Update an RFC-count-one parent obtained through ordinary sharing and release,
   then consume/duplicate the result normally. This tests retained-wrapper
   behavior.
3. Keep an alias of the original parent alive, update one ownership branch, and
   observe both complete records. This must exercise shared fallback and leave
   the old value unchanged.
4. Update an ordinary static record and, separately, a wrapped reference to a
   static payload; verify the original static value remains unchanged.
5. Preserve an aliased child, replace another child whose alias survives, and
   observe both surviving aliases. Then test replacing a field by another
   legally owned reference to that same child. These distinguish parent
   uniqueness from child ownership.
6. Supply raw dynamic, already-wrapped, scalar, and raw static replacements.
   Exercise both hot and capability-8 cold publication behavior.
7. Exercise a same-width different-constructor input in a legal source sum type
   whose original branch is valid. The identity guard must select fallback.
8. Include bounded repeated updates and a deep nested value; compare complete
   outputs and normal teardown. This catches delayed ownership errors without
   requiring a full compiler image rebuild.

Existing compiler-data controls cover accepted shape, copy chains, unchanged
unprofitable records, retained/double drops, root references, permutations,
missing/duplicate fields, effects, helper calls, and external-local overwrite.
They are useful admission tests, but string presence in emitted QBE is not a
semantic execution test. Add an identifier-reuse control for a sink destination
if scanner freshness rules change.

## Qualification recommendation

Proceed with bounded source checking, admission controls, QBE construction and
the positive semantic cases above before paying for a full native compiler
image. Preserve the qualified compiler and exact source/runtime identities.
First inspect actual admission and fast-path work removed; a fully correct but
never-admitted template, or a guard whose overhead exceeds the saved work,
does not establish an architectural improvement.

The final independent original-IR verifier must remain enabled. A later
integrated implementation should explicitly document the small ownership
argument for this template and its single-mutator/publication assumptions;
calling the recognizer a verified plan does not by itself make that argument a
BendTT proof.

## Revision04: per-constructor hot-publication refinement

Follow-up source audit covers `borrow-entry04.bend`,
`borrow-emission04.bend`, `borrow-dispatch04.bend`, and
`borrow-hot-controls04.bend`. No target execution was performed by this audit.

The prior global capability-8 refusal was too conservative: capability 8 means
that **some** constructors may use cold publication. The runtime still seals
every field of a constructor whose own `cid_hot` entry is one. Revision04
permits the existing fast path when capability 8 is absent **or** the exact
matched constructor is known hot. Unknown, legacy, wrong-kind, wrong-width or
cold metadata supplies no exemption. All uniqueness, static-payload,
same-constructor, retained-field, replacement-sealing and drop guards remain.

The private emitter ID index now preserves `N_Constructor.hot` in
`KDef.native`, with `KDef.unsafe = True` meaning that this metadata is present.
These are storage fields on a private `kind == "N111Id"` record; they do not
mark a source definition native/unsafe or confer any verification permission.
`p173bh_hot` requires the N111Id kind, a 16-bit numeric identity, matching arity,
presence, and hot value before using the fact. Exact-name lookup and the same
ID index used to emit `N111CtorId` tie the fact to the runtime header guard.

The compatibility audit found no existing N111Id consumer that uses these two
Boolean fields as source native/unsafe flags. Existing emitter ID consumers
read the name/kind/numeric ID/arity; `p128bf_known` continues to check the same
kind, ID range and arity. The generic Patricia index treats entries as payloads
and does not branch on their native/unsafe bits. Source-book uses of `db`/`du`
operate on distinct source-definition records. Verifier constructor metadata
uses `NativeStaticCtor` records from `ns_ctor_index`, not these private emitter
records, so this does not weaken or replace independent verification.

The selected emission path preserves table provenance:

1. `p169c_selected` applies the existing request-derived cold policy before
   `p169c_output` dispatches to `p169a_seeded` / `p169s_seeded`.
2. Both seeded emitters derive `p111q_ids(program)` and
   `p111q_tables(program, ids)` from the **same resulting P111Program**.
3. `p111q_constructor_ids` and `p111q_ctor_table` enumerate its same constructor
   list in the same order. One retains the hot Boolean; the other serializes
   the actual `p111_cid_hot` byte consumed by `cid_hot` in the runtime.
4. Static-image, scalar-array, live-region and cold-capability table patches do
   not replace the constructor hot table or reorder its IDs. The cold-capability
   patch changes the descriptor's capability bit, which the guard still reads.

Thus the refinement matches the runtime's actual publication condition without
adding effects or changing the source workload. It is appropriate for the
bounded pilot. The metadata is a trusted emitter fact derived from the checked
program, not an independently verified certificate supplied by a caller.

The added finite controls check hot/cold/missing/legacy/wrong-arity behavior and
numeric-ID stability. Useful extra low-cost controls are a wrong record kind,
an out-of-range ID, and a table-consistency assertion that every advertised hot
entry agrees with the emitted byte at its numeric ID. Execution qualification
should specifically confirm an actual capability-8/hot-constructor fast arm,
alongside capability-8/cold fallback; previous capability-8 fallback-only
results cannot establish the refined arm's runtime correctness.
