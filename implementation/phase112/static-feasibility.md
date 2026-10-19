# Typed static images: source feasibility

Status: source audit and interface proposal only. No compiler implementation or
target execution was performed for this note. The scalar, accessor, and worker
candidates are independent.

The Phase111 runtime already implements immutable constructor images. The
missing part is a typed producer in the direct-QBE compiler. Reusing the mature
producer's generated C expressions would cross the wrong boundary; its semantic
admission and traversal can instead be ported directly.

## Evidence

The selected mature compiler is
`selfhost/build/phase102/projection-cost-source01/compiler.bend`, SHA256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`.
Its static pass at lines 36037–36253 corresponds to
`selfhost/src/back/native/static.bend`:

- `ns_ctor` admits exact constructor identity and arity, excluding special
  scalars, arrays, and IO nodes (lines 71–85).
- `ns_constant`, `ns_static_scalar`, and `ns_packed_fields` identify canonical
  U32 words, immediate Bool/Char, nullary constructors, and the restricted
  one-field `$ctor.` immediate representation (lines 88–128, 195–206).
- `ns_intern` deduplicates closed child words and caps the image at 65,536 words;
  an over-budget parent remains dynamic (lines 137–147).
- `ns_static_term` rejects stale input `NStatic`/`NWPattern` nodes and visits
  children before parents (lines 172–180).
- `ns_prepare_cached` disables the pass when `nc_pack_foreign` requires the
  ordinary foreign representation (lines 248–250).

Two details prevent calling `ns_prepare` unchanged: `NS_Image.words` stores C
expression strings produced by `ns_word`; `ns_rebuild` also invokes
`nw_prepare`, which may introduce forms not supported by the generic direct
lowerer. A typed counterpart should reuse the same semantic rules while
omitting that separate optimization.

Phase111 `segment/lower-book.bend:82` currently calls `p111_compile_defs` on the
cached erased book directly. `qbe/program.bend:134` writes zero to descriptor
`static_words` and `static_image`. Neither the segment model nor its machine
operations need an extension to represent a resolved 64-bit constructor word:
`N111Const{lo,hi}` already does so exactly.

The ABI11101 descriptor has the two fields at byte offsets 64 and 152
(`runtime/runtime.h:35,46`). The qualified `runtime-source04/runtime.c`:

- derives `HEAP_OFF` from the image length (lines 308–309);
- copies the exact image to `H + STAT_OFF` at startup (line 2263);
- validates image presence and initial-corpus bounds (lines 3848–3849);
- statically asserts `STAT_OFF == 51413504` (line 4499);
- treats static Terms as trivial for keep/sink (lines 845–889, 1011–1015);
- copies fields from a raw static constructor, and only frees returned spare
  locations at or above `HEAP_OFF` (lines 797–801, 1029–1049, 3900–3911).

Thus a static image needs no new runtime helper or ownership operation. Dynamic
parents can still seal a static child; the existing reference-count wrapper
then unwraps to an immortal location. The static producer itself must contain
only closed immutable children, with no closures, arrays, effects, or mutable
heap pointers.

## Proposed interface

Prefer an additive `P112StaticProgram` facade containing the unchanged
`P111Program` plus a typed image. Do not add a field to `P111Program`: that would
force changes to all six-field patterns in the existing verifier, emitters,
worker facades, and controls without adding semantic value.

The image vocabulary can be small: raw U32 word, packed constructor
identity/payload, and boxed constructor identity/image offset. Build constructor
IDs once from the same ordered constructor catalogue as `p111_finish`; resolve
each image word to `P111QLong{lo,hi}` and each returned literal to
`N111Const{lo,hi}`. This is typed data construction, not C-text parsing.

`p112s_lower_request(request)` should return the facade plus an error. Its fresh
typed preparation attaches only request-local prepared-body facts. Two narrow
lowerer adapters handle the finalized static atom in terminal and let-bound
positions; all other forms delegate to exact original `p111_live` and
`p111_let` bodies. The original request source remains the authority for source
validation, constructor metadata, show metadata, and effects.

The finalized atom should have no recursive children. Mature `NStatic` keeps
those children for NQ product returns, which this generic backend does not use.
Here, retaining them would let `nc_uses_term` traverse the entire literal again
(selected compiler lines 32220–32229). Offset/payload plus the authenticated
request-local image are sufficient. Reject preexisting static atoms before
preparation, and validate every generated atom against its image/catalogue.

`p112s_chunks(facade)` should reuse `p111q_segment_chunks`, including whichever
loop/direct-worker override is selected, and construct a typed static data
table plus the descriptor with the two image fields populated. Existing table
records can be adapted structurally; no emitted QBE or C should be parsed.
The public entry still runs the original `p111_verify_program` and a separate
typed-image validator before rendering. Only `p111_emit_admitted` needs to
choose the static request path. Existing public fixed-program rendering and
all non-static fallbacks remain available for ablation.

The image validator should reject unknown constructors, invalid arity,
out-of-range or non-node offsets, forward/cyclic references, invalid packed
payload forms, inconsistent image length, and a mismatched runtime ABI. A
65,536-word budget and the exact pinned ABI keep all locations in the low U32
half. Overflow must refuse or use the mature dynamic fallback, never truncate.

The worker owner confirmed that the current private/public worker templates do
not assume an empty image or fixed `HEAP_OFF`; they consume the same state and
descriptor and treat literal Terms as ordinary `N111Value`s.

## First discriminating checks

The frozen Unicode wrapper
`selfhost/build/phase93/fixtures01/coverage-unicode-text-64.bend:320` contains
768 codepoints / 1,216 UTF-8 bytes in its expected literal. A direct SCon image
needs 1,536 field words before deduplication, far below the mature limit. A
successful static plan should turn that subtree into one returned immutable
Term and emit those typed field words; the same function's dynamic output
construction remains dynamic.

Before any timing claim, check:

1. Empty and Unicode Strings; repeated suffixes; nullary, unary packed, and
   multi-field user datatypes; keep, sink, and match in both alias release
   orders; static child inside a dynamic parent.
2. Arrays/effects/foreign and unknown constructor or arity retain the exact
   baseline path. Stale image markers and malformed image references refuse.
3. The exact budget boundary and overflow parent fallback preserve output and
   avoid out-of-range image references.
4. Baseline and candidate emitters produce the same complete observations for
   the frozen Unicode workload, while the candidate has nonzero descriptor
   image fields and fewer constructor/helper/continuation operations for the
   closed literal.
5. Compare frontend, static-plan, lowering, verification, and emission stages
   separately. The existing liveness candidate is an independent factor.

The source evidence predicts less literal allocation and less lowering work;
it does not establish that absent static preparation caused either timeout,
nor does it predict a whole-program speedup. Preparation itself must stay
linear in graph size apart from bounded indexed interning and per-node arity.
