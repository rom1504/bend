# Result-only RFC permission: bounded delta audit

2026-11-06; source/receipt inspection and read-only disassembly only. No target
execution or implementation change. This supplements
[the v13 semantic audit](descendant-v13-semantic-audit.md).

The proposed **result-only** predicate `oldGuard OR RFCbit` is sound for the
pinned single-mutator, valid ordinary Data-state experiment, provided the
existing held-root and reader contracts remain intact. It does not require
changing the runtime helper or weakening its existing root uses.

At this exact call, `oldGuard` is
`p118_rt_borrow_scalar_safe(state, result, 0, 1)`. From
`selfhost/src/runtime/qbe/runtime.c:4794–4805`:

1. Count1 cannot take the two-root alias-refusal branch.
2. `oldGuard=false` therefore means a nontrivial result is either non-RFC or has
   RFC count at most one.
3. Adding `RFCbit=true` excludes the non-RFC alternative. A valid live result
   tied to held roots has a positive reference count, so the newly admitted
   state has **exactly count1**.
4. The next `term_keep` increments the same RFC cell before any owned root is
   dropped (`runtime.c:926–930`). In the pinned single-mutator setting this is
   exactly **1→2**, so the newly admitted transition cannot overflow the RFC
   counter. The held parent field or root reference remains valid until then.
5. Subsequent root release cannot consume the new output credit. Returning a
   root or a descendant of overlapping held roots follows the same accounting.

Keep the original guard call and its arguments; retain root admission, reader
admission, final verification, fallback and keep-before-drop ordering. Restrict
the extra permission to this result-promotion site. Do not OR the RFC bit into
helper guards or the two-root guard, and do not admit raw non-RFC descendants.
Use a canonical integer bit/predicate in the existing verified IR operations.

This is a delta argument. All old-true states retain their previous behavior,
including the prototype's existing near-overflow limitation. A prior error,
malformed heap, dead RFC cell/count0 or concurrent ownership mutation is outside
the stated experiment. Full error-state/source equivalence remains a separate
qualification requirement; this note does not establish it. The predicate
alone cannot validate an arbitrary raw Term: actual-source Data permission and
the reader's retained-root provenance remain essential.

## Diagnostic motivation, separate from the argument

The root-owned v14 report
`selfhost/build/phase171/descendant-find-guard-plan14/execution/report.json`
is complete with exact stdout. Its result site at return address `0x40bc17`
records **20,000 calls, zero passes, 20,000 firstRfc and failedFirstRfc**.
Disassembly of this exact ELF shows the preceding call at `0x40bc12`,
`ecx=1`, `edx=0`, and the later successful branch calling keep before both sinks.
The diagnostic shim tests only bit63 for its additional classification;
it performs no extra heap/header read. Thus **RFC bit observed; count1 inferred
from the unchanged guard and valid-state contract**, not measured directly.

| Evidence | SHA256 |
| --- | --- |
| Diagnostic report | `d152577f690d9bb77e7905319a654109571591fb3f8899c8cf9b1a2d717d62d9` |
| `execution/counts.json` | `4aac1966c4dca5b193a1fae62be2a7316eb8e7144609395558b87b542fbc850d` |
| Diagnostic ELF | `a5919c6f4311166d23e59b4089d4ca4fa4b85f8e29bbaceaa072b604169fc8e4` |
| `tools/descendant-guard-counts-v2.c` | `c6a88992ff97b252bbcc60495d59b8b6fbe5b30aae8e313286387a29871fd77b` |

No new guard, promotion count, speedup, production qualification or formal proof
is claimed here. Re-map any subsequent diagnostic's own ELF and check complete
independent values before interpreting its timing.
