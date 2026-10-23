# Phase128 late borrowed-field template audit

Independent source review; no build, target execution or measurement by this
audit. This is an acceptable bounded experiment under the pinned sequential
CPU runtime. No blocking source-level issue was found. Promotion still needs
ordinary semantic execution and an independent runtime/ABI comparison, including
failure paths. The 21 finite controls are useful structural checks, not that
runtime comparison.

Reviewed files under `selfhost/tools/performance/phase128/borrow/field-read/`:

| File | Bytes | SHA256 |
|---|---:|---|
| `template.bend` | 7669 | `81269437f25e5eecc7a0d0d4b3e2b3aa6ab2295cfcafacbd36e320ec7592e05f` |
| `controls.bend` | 4496 | `014a53ec6de200457824513da99e0d3a4fa4bc459022290b1ecff769d99b4058` |
| `README.md` | 3191 | `90997690f8aa93bac63b94c73c098574d649482fbb3af366194e5c0ad584bd7a` |

Runtime source is `selfhost/build/phase128/runtime-borrow01/runtime.c`, SHA256
`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`.
Its pinned runtime object is
`9b3f57afb46b4db8c63f6f3c5f1af1194e0854a7329de28f25d2e11aef887749`.
The prototype changes neither.

## Original import and narrow admission

`p118_rt_borrow_fields` checks constructor identity/count, then either copies a
packed singleton or reads a boxed constructor through `term_peek`. It copies
fields into the caller's buffer and returns the count. There is no ownership
transition in this operation; the NO reader's retained-root proof is essential.

The late template recognizes only the exact existing import with U64 result,
state pointer named `state`, U64 Term, authenticated local scratch family,
symbolic constructor ID and literal count with zero high word. Count must be
2–8, and emitter metadata must confirm the constructor's same arity and a
16-bit ID. Nullary, packed/single-field, unknown-constructor, wrong-width and
unsupported-buffer forms use the previous emitter.

The scratch-name test alone does not prove pointer safety. The whole original
import must already have passed the unchanged structural verifier, including
actual local-buffer size/provenance and definitely assigned arguments. This
late expansion is not a new permission to construct arbitrary raw pointer IR.

## ABI and RFC decoding

The template matches the selected CPU representation:

- `P111State` begins with `P111Env`, whose first field is the heap pointer.
  Reading a pointer at state offset zero therefore obtains `e.mem`.
- Constructor tag is `(term >> 56) & 0x7f == 2`; bit63 is RFC, not part of the tag.
- Constructor ID is `(term >> 40) & 0xffff`.
- `N111Const{4294967295,255}` is exactly the low-40-bit location mask.
- RFC metadata is `(payload_location << 24) | count`. Zero-extended low/high
  32-bit loads are combined as `(high << 32) | low`, then shifted right by24.
- Locations address 64-bit heap words, so both header and payload offsets are
  multiplied by eight.

The U32 load renderer produces `=l loaduw`; both halves are therefore properly
zero-extended before the 64-bit shift/OR. The high word cannot be lost to a
32-bit shift. Raw/static constructor locations bypass RFC decoding. Final field
loads and scratch stores remain ordered load/store pairs at identical offsets,
and the successful result is exactly the original literal count.

The input Term is snapshotted before any assignment to the result. This also
preserves a legal import where its destination reuses the input local's name.
The buffer and original data remain separate under the verified local-allocation
contract; the expansion creates no new alias or ownership transfer.

## Sequential synchronization premise

The selected runtime's `p111_rt_main` explicitly rejects `threads != 1` and GPU
execution at line4494. CPU `DEVICE=0` is fixed by the recorded GCC command and
runtime preprocessor path. The runtime does have host IO helper threads, but
`io_help` performs the host call; `io_take` packs its Bend result on the event-loop
thread. They do not supply a second Bend evaluator mutating the reader's retained
String/List graph concurrently.

Under that pinned execution contract, replacing `rfc_view`'s atomic loads and
count-one acquire with ordinary loads preserves the observed metadata/payload.
The source reads low then high, while the helper's construction reads the high
and low halves; without concurrent mutation the result is identical. This is
not a concurrency proof for arbitrary foreign runtimes, shared-memory extensions,
multiple Bend workers, Metal or CUDA. Such changes require requalifying this
template or retaining the original helper.

## Guard, fallback and observable failure

Exact tag and constructor checks precede every heap/header/payload dereference.
Failure goes through the complete original import via `p128bf_previous`, not
back through the global expansion hook. This both preserves the original error
checks/order and prevents recursively expanding the fallback inside itself.

The original dynamic constructor-range/arity and nonnull-buffer checks are
already guaranteed on the selected fast path by the same program's constructor
metadata and verified stack buffer. Wrong tags or IDs still reach the original
fail-stop helper. No location-bounds guarantee is newly claimed: the original
helper also relies on valid checked/runtime-created Terms after its shape check.

CPU `p111_rt_fail`/`p111_require` failures reach `_exit(1)` through `err_fail`.
The runtime comparison should verify identical status/stderr and absence of
scratch writes on rejected shapes, using a bounded valid fixture rather than
executing arbitrary malformed pointers.

## Metadata and emitter integration

`p111q_constructor_ids` preserves numeric IDs in `da` and adds constructor arity
to previously unused `dx`. Inspection of the selected source found ordinary
`N111Id` consumers reading only `dk`/`da`; `p111q_id_found` still renders the same
number. Descriptor constructor tables still derive from the original constructor
list. Function ID construction is unchanged. Verifier constructor catalogues are
separately built by `ns_ctor_index`, so their interpretation does not change.

Generated locals use the reserved `p114t_` namespace, rejected by the existing
original/final namespace gate. A fresh site is consumed before guard rendering;
outer and inner branches reserve their label ranges before body emission. The
bounded width-eight template fits comfortably within the 95-counter margin of
the site admission bound. `%t_` memory-offset temporaries and `p114t_` locals
remain distinct. Existing `p111q_if_done` supplies the branch join and the result
local is assigned on both returning paths.

`p128bf_previous` reproduces the selected Phase126/114 dispatch chain. Unsupported
imports retain its existing Nat, float, transport and ordinary statement handling.
The new template does not modify `p118z_runtime` or disable live-bank admission.

## Required evidence before promotion

1. Run the 21 finite controls and compile multiple adjacent/nested expansions,
   inspecting label/local uniqueness and original fallback calls.
2. Compare valid raw, static and RFC roots (count one and shared) against the
   original helper, widths2 and8, payloads using upper 32-bit data, exact scratch
   contents and count result. Include nonzero header high halves.
3. Independently check wrong tag/CID refusal before payload access; retain
   unchanged singleton/packed imports and ordinary ownership/alias/deep inputs.
4. Inspect generated hot reader instructions and measure paired runtime plus
   emission overhead. Exposed pointer reads or removed helper calls alone do not
   establish a program speedup.

This audit permits the bounded experiment, not a blanket raw-memory admission
or a production/runtime-mode change.
