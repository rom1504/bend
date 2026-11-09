# P185-006: Bind cold-constructor descriptor facts once

Status: off-path prototype supplied for independent snapshot and gates.
No new machine or runtime result is claimed here.

The first guarded constructor candidate improves tree-bitonic by about 3.8%
over its immediate comparison and regresses map128 by about 1%, with code
growth. The isolated width-two machine oracle executes 16 descriptor-guard
instructions before four cache-test instructions and 14 allocator/copy/pack
instructions. Repeatedly checking known program metadata is material cost.

The selected emitter fixes descriptor ABI 11102 and size 192. Its generated
main passes this descriptor to `p111_rt_main`, whose `p111_bind` validates the
ABI before executing segments and installs one active descriptor per process.
Every selected streaming preparation also applies `p118c_tables`: a zero
cold-constructor byte adds capability 8 to base capability 1, with optional
array/live-register bits 2 and 4. Thus a complete emitted program containing
an admitted cold constructor has capabilities 9, 11, 13, or 15. Standalone
constructor ID maps do not by themselves establish this pairing.

`descriptor-proof.bend` provides `p185cb_bind(ids, finalTables)` for the
existing `p134e_registered` boundary. It checks unique descriptor and
constructor tables, exact ABI and size, supported capabilities, the exact
constructor-table references, declared constructor count and table lengths,
byte shapes, and each constructor ID's actual arity and cold byte. Only a
matching authenticated cold entry with unused value metadata receives the
private proof marker. It inserts no names into either symbol index, leaves
unrelated metadata untouched, and strips its old proof before rebinding.

The selected prepared, ordinary streaming and incremental routes all converge
at `p134e_registered` with their already verified IDs and final capability
tables. The proposed hook binds the renderer's IDs at that point. Older
low-level emitters and manually constructed API IDs remain unqualified and
retain the complete runtime guard. The second hook chooses the existing
cache-only constructor expansion only for a qualified entry. Cache misses
retain the original helper, and all allocation, publication and ownership
operations are unchanged.

Qualification costs a constant number of table-list scans, one paired byte
table pass building a numeric-CID trie, and one constructor-index walk with
bounded trie lookups: O(T + 32(C + I)), with no full-table scan per constructor.
It does not repeat source analysis or runtime verification.

`descriptor-proof-controls.bend` supplies 27 controls for supported and
unsupported capability variants, malformed/mismatched metadata, missing and
duplicate tables, unpaired IDs, proof refresh/revocation, foreign metadata,
guard removal and retained allocator-miss fallback. Its separate machine
oracle has 19 checks for paired hit/miss behavior and the unchanged raw-ID
ABI/capability fallback. Existing 221-check dynamic-guard constructor controls
remain unchanged. The paired oracle invokes that entry only with its bound
descriptor preconditions; it does not claim arbitrary descriptor mutation is
supported after qualification.

The controlled comparison must retain the original guarded source and
measure code size, map128 and tree-bitonic separately. Source/IR acceptance,
machine observations, full-program output conformance and profitability are
distinct gates. No installed selection is changed by this prototype.
