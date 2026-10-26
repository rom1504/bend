# Raw-owner witness: independent correctness audit

Source-only review against Phase141 integrated source02,
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`,
and the Phase142 design. No targets, compiler runs or production changes.
This note first records the existing seam and proposed construction contract;
implementation review is recorded separately below.

## Existing computation and the admissible projection

`p140og_old` reuses an actual previous `P111Code` only when the existing global
gate, owner name, incoming fresh counter and dependency-clean judgment all
permit it. Keep those conditions exactly. Recomputed-but-equal products need
not receive a witness; the old equality route can still admit them later.

`p140og_record` rebuilds segment containers around that retained code:

* The entry calls `p111_segment(nc_ref_name(book,name),[],0,0,body)`.
  With these exact arguments, its body is the fixed
  `N111Alloca{"scratch",2048,8}` followed by the retained body. There are no
  parameter loads or stack-pop prefix in this entry case.
* Continuation segment bodies already belong to the retained `P111Code`.
* `p111_mark_segments` reconstructs each header and sets the bang flag; it
  preserves each body. The subsequent reversals preserve final owner/run order.

Therefore retaining `P111Code` establishes body identity for that owner's exact
segment run, including the regenerated fixed entry prefix. It does **not** alone
establish wrapper/header identity. The unchanged `p140v_context` compares the
entire ordered raw header list—name, arity, result, incoming, flags—and complete
ordered constructor catalogue. Keep that gate before trusting any witness.

`p140or_finish` adds current show/effect descriptors; `p112s_finish` wraps the
static nodes; `p113d_finish` attaches separately prepared private functions.
None rewrites the raw segment bodies before the first `p140v_open`. The private
candidate/readiness pass can change direct functions, so this argument does not
apply to those functions or to later transformed representations.

The first raw verifier's body judgment depends on the body, segment metadata,
and function/constructor ID context. The fixed producer/runtime contract is an
additional premise. Static-image validity remains checked afresh. Show/effect
descriptors are not secretly part of `p111v_segment`; their existing admission
and descriptor validation must nevertheless remain in place.

## Required provenance contract

The proposed `P142WSession` owns frontend, raw and backend state as one capsule.
One request derives both its old raw entries and its first-open verifier cache
from that capsule, produces local evidence, and consumes it before returning.
Only complete success constructs a new committed capsule; errors retain the
exact previous one. Empty construction has no reusable judgments.

This is sufficient for a fixed-producer, trusted in-process experiment without
making revision numbers authoritative. Reusing a copied valid capsule for two
branches is also sound: both branches still derive products and judgments from
their own shared base. A numeric counter, owner name or fresh-ID equality alone
would not bind independently supplied raw and verifier caches.

The requirement is a construction invariant, not a language-enforced opaque or
cryptographic seal. Bend Data constructors can be forged. Do not deserialize
capsules, export a witness-plus-unrelated-cache admission API, or import old
`P140` component caches independently. Internal fast-open helpers are not
authority for arbitrary callers. A future native adapter must thread the whole
capsule rather than reconstructing its component state separately. Explicit
epoch/stale-base validation is needed before extending this to external retained
state or a request service; the current prototype does not establish that API.

## Verification and failure boundaries

Witnesses may replace deep equality only on the first raw-body walk after the
existing context gate succeeds. Preserve ordered metadata checks and diagnostic
priority: function scan, constructor scan, zero-argument main, first invalid raw
segment, static-image error, then direct functions. Misses use the existing
comparison/checking behavior; missing or malformed witness coverage must fall
back rather than infer an unchanged suffix.

Keep direct-function admission, the second `p140v_array` route and final observer
verification unchanged. In particular, `p126bp_complete` calls
`p118b_verify_functions`, which projects/checks direct functions; it does not
alone recheck every raw body. The second existing raw comparison/check is an
important independent safeguard. Calling only the last observer gate a complete
raw verifier would overstate the source contract.

Existing `p140s_finished` publishes frontend/raw/backend together only for
successful output. Standalone lowering/backend helpers can return partial caches
before later failure, so their mere return does not grant a successful-revision
witness. Native IO failure currently terminates rather than demonstrating a
recoverable service transaction; do not claim cancellation/recovery semantics
that the new adapter has not tested.

## High-information falsifiers

Use the old complete `p140v_segment` comparison and context gate as an independent
diagnostic oracle for every claimed new hit. A witness hit must imply both;
the timed route must exclude this duplicate diagnostic scan.

1. Actual retained entry and continuation bodies, with the fixed scratch prefix.
   Recomputed equal bodies should be allowed to miss without affecting output.
2. Changed bang, mapped name, arity, incoming count, result or constructor
   catalogue while the old body is retained: context refuses witness admission.
3. A previous owner changes continuation count, or balanced changes restore a
   later fresh counter: verify exact run alignment and the complete header gate.
4. Raw state from revision A paired with first-verifier state B, empty/evicted
   judgment state, or a deliberately false witness: diagnostic comparison must
   reject. Production construction must not permit that pair to become trusted.
5. Unchanged headers with an invalid or changed literal/static image: retain
   fresh image validation and its original error precedence.
6. Dependency/alias/layout edits, negative lookup becoming present, cold reset,
   edit/revert, and failure followed by recovery. Preserve the dirty-ADT refusal.
7. A failure after the first verifier succeeds: the next update must still use
   the previous fully successful raw/verifier pair, not partially new evidence.

These controls and source correspondence support a bounded implementation
decision. They are not a new formal compiler-correctness proof or a reason to
weaken any existing final gate.

## Implementation review: initial v01 modules

Read `model-v01.bend`, `generic-v01.bend`, `raw-bridge-v01.bend`,
`verifier-v01.bend` and `session-v01.bend` under
`selfhost/tools/performance/phase142/witness/`. No source-semantic blocker found
for this initial experiment, subject to checking and the differential gates.
One possible affine annotation omission in `p142b_session` was sent to the
implementer and corrected before `assembly-v01.json` froze the sources; this
audit does not substitute for the checker. The assembly identifies the reviewed
module hashes and exposes only seed/request/diagnostic/control entrypoints.

The generic producer preserves the original owner predicates and error branches.
`p142og_reverse` counts the run during the already-required segment reversal;
it does not inspect statement bodies to create evidence. Runs are reversed with
the owner sequence, so they describe the final flattened segment order. Fresh
owners receive `retained=False`. Per-owner run allocation/reversal is additional
work and remains part of the measured candidate cost.

The consumer obtains `raw` admission and metadata through unchanged
`p140v_reuse`. Only `reuse && retained && left>0` skips the old comparator in
normal mode. Diagnostic mode calls the old complete comparator, returns a
distinct mismatch, and does not publish a successful first-verifier cache on a
false claim. Missing/exhausted runs fall back to comparison/checking. A zero or
maximum-U32 run discards all remaining evidence and compares the suffix, without
attempting to realign later claims. The producer's exact run-length invariant
is required: arbitrary overlong claims
are not accepted as external input; diagnostic tests deliberately violate that
invariant to show the independent oracle detects a changed body.

The session owns the actual `P86Seed` in addition to the complete prior cache.
`p142b_opened` explicitly stops on a diagnostic mismatch **before** optimization,
and `p142w_publish` returns the exact previous session on error. This is necessary
because the ordinary optimization boundary retains only `valid`, not the first
verifier's original error text. No first-boundary witness reaches the array
verifier or final observer checks.

Independent finite controls are in `witness/controls-v01.bend`, export
`p142wt_controls` (25 rows). They use genuine old verifier caches and diagnostic
mode only. Valid-but-unequal and invalid-body claims require mismatch1, invalid
boundary and no published cache; context-change rows require zero witness
admissions. These controls have been written, not executed by this reviewer.
Root's complete-source screen is responsible for actual failure/recovery capsule
equality and exact edited products; these finite fixtures do not simulate a
complete real frontend session or certify arbitrary forged capsules.
