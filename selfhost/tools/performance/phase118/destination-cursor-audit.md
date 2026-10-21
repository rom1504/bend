# Phase118 generalized destination cursor: unselected prototype

This is source implementation and a conditional audit, not qualification or a
performance claim. `destination-cursor.bend` replaces five producer/contract
definitions after `trmc-v4`; `runtime-destination-cursor.c` adds two helpers.
Generic Take, borrowing, original fallback segments, source admission, public
signatures and descriptor layout remain unchanged. Do not compose with the
separate cell-reuse producer.

## Representation and exact behavior

The existing hidden `p118_parent` word now contains the pending heap word index
in bits0..39 and its parent's seal requirement in bit63. Bits40..62 must be zero;
zero is the no-destination sentinel. The separate hidden `p118_root` remains the
ordinary owned raw constructor Term. No extra formal, state-global storage or
input-cell ownership credit is introduced.

`extend_cursor(state,cursor,cid,prefix,count)` retains the original constructor
arity/count/prefix checks and allocation. It computes the new parent's policy
once: seal unless capability8 is set and this CID is cold. It reads every prefix
field, initializes fields under that policy, and writes the pending hole. It
then fills the preceding cursor with the new ordinary node Term using that
cursor's recorded policy. Finally it writes the new `(location+count)|policy`
to `prefix[0]` and returns the node Term. The caller immediately loads this fresh
word and carries it on the backedge; root initialization still uses the Term.

`finish_cursor` retains the zero-cursor/root consistency and raw-root checks,
fills the final slot, and returns the same root/result as before. The fill helper
checks the cursor encoding, dynamic heap range using the existing atomic H_CAP
read convention, and actual `TERM_HOLE`. It branches only on the stored policy;
it performs no old-parent CID/arity lookup. Mixed arity and mixed hot/cold steps
are supported because each cursor records the node's own offset and policy.
Legacy capability1/3 always records sealing; no additional capability is needed.

## Ownership and alias obligations

This is the same trusted source-produced unpublished-root protocol as TRMCv4.
Every terminal source result uses the new finish; every extend uses the new
cursor; ordinary self-tail steps preserve it. Wrapper initialization remains
zero/zero. The hidden words never enter source liveness or source owners.
The parent cursor is borrowed from the live unpublished root and cannot escape
to arbitrary source calls. Range/hole checks alone do not prove that invariant.

A hot predecessor may seal the newly allocated node through an RFC wrapper.
The returned ordinary node Term remains a private borrowed view for locating its
hole, exactly as the old parent-Term cursor did; it is not a second source owner.
The chain is not published until finish, so no external observer can see or
duplicate an incomplete node. A cold parent can receive a hot/already-shared
child without changing its recorded parent policy. Retained source aliases are
handled by the existing source sharing and constructor semantics.

The prefix parameter becomes a writable in/out local buffer. Existing producer
evaluations establish all prefix and recursive argument words in SSA locals
before storing the prefix; overwriting scratch[0] cannot change those values.
All prefix reads complete before the output write. The same verified count1..7
and prefix capacity imply at least eight writable bytes, while existing direct
IR pointer restrictions exclude state/heap aliases. The new contract explicitly
includes the first-word write; it is not semantically the old readonly import.
The next cursor is loaded before any further scratch use.

Original generic program verification remains separate. Candidate verification
recognizes the exact new runtime signatures and constructor/buffer capacities;
the full source factory supplies protocol provenance. Neither verifier alone
proves arbitrary caller-supplied cursor integers correct. Checked source and
matching runtime must be pinned together; old runtimes lack the new symbols.

## Composition and finite controls

`cursor-transport.bend` separately extends the exact v3 runtime whitelist with
the two cursor imports. Inspection establishes that they access state->e and
program metadata, never the register bank or scheduler transitions. Their output
buffer is a verified non-state local. All other transport gates remain intact;
omitting this overlay would conservatively disable capability4 and confound a
performance comparison.

`destination-cursor-controls.bend` checks the output-load/backedge correspondence,
new terminal helper, unchanged formal count and import admission. It updates
only the previous terminal-producer control's helper name; original source
admission/refusal laws remain. Reuse complete construction, mixed-arity,
shared-child, deep-chain, empty/base and refusal fixtures. Include legacy/hot
and certified-cold policies, and ensure the emitted product actually uses the
new helpers. No malformed runtime failure inputs are needed.

`runtime-destination-cursor.py --out <new-directory> --extra
selfhost/tools/performance/phase118/runtime-destination-cursor.c` appends the
helpers to pinned `runtime-extend01`; root owns running it. Recipe AST and Bend
delimiter checks passed here; no compiler, target or benchmark was executed.

The new generic cursor helper initially bypasses allocation-only extend1..7
specializations. Compare against the generic allocation-only route as well as
the selected sized route, or restore constant counts in a separate ablation.
Otherwise the already measured count-specialization benefit obscures the cursor
effect. The extra scratch output/load and heap-range check are real costs; this
prototype may lose despite removing metadata reconstruction. Preserve that
negative result rather than removing semantic guards to manufacture a win.
