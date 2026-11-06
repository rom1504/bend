# Phase172: can static constructors remain unwrapped when published?

Independent source audit,2026-11-06. No source/runtime patch or target execution
was performed for this audit. The question arose after the sealed-field inline
experiment was approximately neutral on the real verifier while increasing QBE.

## Conclusion and exact scope

For **valid programs admitted by the current static-image verifier and the
pinned ordinary host runtime**, returning an already raw static constructor
unchanged from `rfc_seal` has a strong source-level justification. No downstream
consumer examined requires a static constructor to gain an RFC wrapper merely
because it is stored in a dynamic object. Existing runtime operations already
treat raw static constructors as immortal, freely retainable values.

This is not justified merely by a low pointer. The essential additional fact is
that the checked static image is **transitively immutable and contains no owned
dynamic children**. Preserve that final verifier. Do not generalize the rule to
raw heap constructors, arbitrary embedded runtime descriptors, unverified
foreign words, or an unqualified GPU/concurrent runtime.

The minimal experimental behavior would be: after the existing tag/RFC checks,
recognize a raw static constructor and return it unchanged. Keep every already
RFC value unchanged, including an existing wrapper whose payload is static.
`term_loc(t)<HEAP_OFF` agrees with the current `term_triv` classification for
valid terms. An even narrower initial contract can require the actual static
image interval `[STAT_OFF, STAT_OFF+STAT_LEN)`; padding and other low addresses
are then excluded. In either case, heap/static bounds are descriptor-dependent,
not a hard-coded assumption that `HEAP_OFF==STAT_OFF`.

This would remove real work: wrapper allocation, header initialization, later
wrapper bumps/decrements, wrapper reclamation, and some repeated indirect
location reads. It does **not** remove dynamic parent allocation, actual dynamic
child ownership, or the compiler's underlying traversals.

## The static-image invariant

`selfhost/src/back/qbe/static-data.bend` supplies the important proof boundary:

-`p112s_word` renders raw words as32-bit values with high half zero, packed
  immediate constructors, or `TAG_CTR` words at `STAT_OFF+offset`.
-`p112s_constructor_ok` authenticates exact constructor identity/arity and
  excludes special mutable arrays and runtime effect constructors.
-`p112s_word_valid` accepts only U32 raw values, eligible packed values, or a
  box referring to an already authenticated static node.
-`p112s_nodes_error`/`p112s_node_error` validate each node against **prior** nodes,
  with contiguous offsets and a bounded image size. Self cycles, forward
  references, dynamic pointers, arbitrary RFC headers, and runtime arrays
  cannot enter a valid static image through this representation.
-`p112s_image_error` also blocks the actual registered effect constructors.

Consequently, destructuring a static node returns only immediate or recursively
static values. Copying those fields without incrementing dynamic child counts
is correct. The existing finite `p112s_control_report` includes backward Unicode
graphs and rejects forward references, cycles, arrays and registered effects.

## Downstream audit

All references below are in `selfhost/src/runtime/qbe/runtime.c` unless noted.

| Consumer | Existing behavior and why raw static publication is compatible |
|---|---|
| `term_triv`849 | Already classifies any valid static node below `HEAP_OFF` as trivial. |
| `term_keep`926 | Raw static values return unchanged; an existing RFC wrapper is still bumped. The proposed change does not unwrap existing RFC values. |
| `term_sink`1055 / `term_drop`969 | Static values are skipped. Dynamic parents still release all nontrivial dynamic children. A static graph cannot conceal a dynamic owned child under the verified-image invariant. |
| `ctr_take`1073 / `spare_free`801 | Raw static nodes copy their fields and return a static location; `spare_free` refuses to free it. Returned fields are themselves immortal/immediate. |
| `span_fade`1061 | Explicitly accepts a child that is either RFC or trivial. A raw static child passes `term_triv`; no error or retain is required. |
| `term_peek`937 | Raw values use their location; RFC values dereference their wrapper. Both forms already work. |
| `p118_rt_borrow_fields`4668 and `p128bf` template | Read-only borrowing accepts both raw and RFC constructors. The QBE template already selects either raw location or acquired RFC payload location. |
| `p118_rt_borrow_scalar_safe`4792 | Intentionally accepts trivial roots. A newly unwrapped static root can be admitted more often, but its immutable transitive children cannot be destroyed by the borrowed observer. |
| `p118_destination_fill`4626 | Requires a private raw constructor **at or above `HEAP_OFF`**, plus a hole in its destination. Static nodes cannot become writable destinations. |
| `p125_rt_concat_typed`4720 | Refuses raw static spine nodes. It also separately refuses a heap RFC wrapper whose underlying payload is static. Removing the wrapper preserves that refusal; it cannot enable mutation of the static spine. |
| `blk_keep`, `blk_copy`, `blk_node`, `blk_half`1168–1259 | Arrays may contain static constructor elements. Retaining an element calls `term_keep`, which already permits raw static values. Array handles themselves use ARR/BUF tags and are unaffected. |
| `blk_new`1261 | Replicated static elements already bypass dynamic reference counting via `term_triv`. The new representation makes publication consistent with this existing case. |
| `native_array_get/set/swap`1291–1311 | Get retains through `term_keep`; set sinks old elements and seals new ones; swap transfers the old value. Static elements obey all three contracts without wrappers. |
| QBE direct array templates | `verified-plan.bend:p113a_template` and `scalar-arrays.bend:p117h_metadata` require the array tag and a dynamic heap location. A static constructor does not become a mutable array. |
| `io_cstr` / ordinary I/O readers | Consume String spines through `ctr_take` and `spare_free`, already compatible with raw static String tails. Effect payload lifetime remains governed by the existing provider. |
| `window_pix`1726 | Uses raw-or-RFC location selection and only reads constructor fields. No additional wrapper invariant. |

Captureless closures, tasks, packed values and native scalar values are not new
cases: the existing `rfc_seal` already returns non-CTR tags unchanged. There is
no language-visible pointer-identity primitive added by this experiment. Any
internal physical identity shortcut must still preserve value semantics.

## Prior results do not already reject this hypothesis

The Phase163 cold-constructor experiments changed source-derived constructor
publication policy and demonstrated useful recovery on some pure kernels.
They did not change `rfc_seal`'s treatment of raw static fields. Phase169's shared
take and warm-helper experiments also left sealing unchanged. Their negative
or small gains therefore do not falsify static-wrapper elimination.

Conversely, those earlier gains are not evidence for this new change. The
existing all-hot compiler metadata does not block a runtime static-location
rule, because immortality follows from the final static image, not the global
cold-constructor permission. The full physical profile's wrapper share is not
the dynamic fraction attributable to static values.

## Cheapest valid controls and rejection gates

Use ordinary checked Bend programs and existing exact oracles. Do not manufacture
invalid pointers or add unrelated failure probes.

1. Publish a literal Unicode String and a nested immutable literal product in a
   dynamic constructor, retain the parent twice, destructure/drop in differing
   orders, and fully observe both surviving results. Require the actual static
   image to contain those fields; source literals alone do not prove lowering.
2. Publish the same static value twice in one parent; keep/drop that parent and
   retain/read its children. Compare complete source values, not pointer words.
3. Mix a static field with a genuinely dynamic child and a shared dynamic child.
   The dynamic children must retain normal sealing/count transitions. This is
   the boundary most likely to expose an overbroad guard.
4. Store literal Strings/products in ordinary uniform arrays, clone, get,
   set and swap them while retaining aliases; read complete contents from both
   original and cloned arrays. Leave array representation policies unchanged.
5. Append with a static literal spine and retained alias. The typed destructive
   concat must refuse the static spine; ordinary fallback must preserve both
   originals. Also combine a dynamic prefix with a static tail.
6. Reuse independently checked borrowed-observer and constructor-tail controls
   with static inputs. A private destination remains newly allocated and a
   borrowed static root remains immutable.
7. Include File/IO operations on literal paths/text plus a real compiler request:
   this changes neither cold permission nor source/effect admission.
8. In a private diagnostic runtime, count raw static CTRs at the existing
   `rfc_seal` boundary versus all new wraps, then compare actual logical
   allocations and wrapper activity. Instrumentation is not clean timing.
   A low fraction rejects large-gain expectations before a new compiler image.

The runtime can be relinked against existing generated objects for the first
comparison, since ABI and generated QBE do not change. This is substantially
cheaper than rebuilding the compiler to test the idea. Preserve the original
runtime/object identities and independently compare complete outputs.

Exact allocation traces, addresses, memory exhaustion timing and artificial
RFC-count exhaustion are expected to differ when unnecessary wrappers vanish.
Do not claim byte-identical heap state or identical resource-failure timing.
Ordinary successful value/effect semantics, actual dynamic ownership and all
supported behavior remain the correctness requirements. No speedup or full
compiler qualification is established by this audit alone.
