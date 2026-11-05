# Closed direct-library prototype

Source: `selfhost/tests/phase163/direct-first.bend` and
`selfhost/tests/phase163/direct-controls.bend`. This is additive experimental Bend
code. At preparation, only delimiter/declaration metadata checks were run; root
owns independent source checking, machine construction and complete-output tests.

## API and responsibility

```text
p163d_library(request: NR_Request, roots: List<String>) -> P163DLibrary
p163d_plan(request: NR_Request, roots: List<String>) -> P163DLibrary
p163d_error(library) -> String
p163d_text(library) -> String
p163d_summary(library) -> String
p163dc_controls() -> List<String>
```

The request must come from the existing **checked** prepared-request pipeline.
`nc_compile_error_known` retains its ordinary source/ownership/binder-bound
checks; it is not itself a dependent type checker. Nonempty requested roots must
have ordinary admitted boxed one-result entries. Start with
`["book_final_reverse"]` or the separate real-helper workload roots. The library
returns empty text with a refusal when a required root cannot be admitted.

Actual root reachability uses `nr_walk` and its erased facts. `ns_attach_book`
installs those facts in a fresh context; `p112s_prepare` produces the existing
authenticated static bodies/image. Constructor order uses the same actual
`p144o_constructors` source/catalogue as ordinary requests. No `p111_compile_defs`
call, generic segment, executable descriptor or fabricated body is used.

Existing `p113pl_candidates`, `p126sc_candidates` and `p113d_passes(...,32)` do
candidate construction, existing tail-SCC transformation and ordered admission.
Optional failed candidates may be omitted by those existing algorithms, but
**every requested root must have its correctly named, arity-matched boxed entry**
and every emitted direct dependency must pass the final verifier. All admitted
auxiliary workers from this selected closure may be retained; no claim of minimal
dead-code elimination is made. Unsupported recursion, dynamic application,
escaping closures or unresolved dependencies do not acquire generic fallbacks.

The prototype emits private workers unchanged except for `public=False`, meaning
there is no claim of a scheduled adapter. Ordinary exports are constructed only
after requested root identity, arity and one-result checks. This is not disabling
the body verifier. Its exact inputs are:

- `p111v_constructors` on the actual ordered constructor catalogue, checking
  duplicate names, widths and limits;
- `p112s_nodes_error` on the fresh static nodes, checking offsets, constructor
  widths, immutable words and references only to prior nodes;
- unchanged `p113e_functions`, with an **empty scheduled-function map** and the
  actual constructor schema, checking every emitted function in dependency order.

An empty scheduled-function map asserts zero FIDs, rather than inventing generic
function metadata. `N111FuncId`, external symbols and closure construction cannot
be resolved by it. Typed direct-call signatures are inserted only as functions
pass. QBE emission gets a separate actual CID-to-number map: verifier schema
arity fields are not mistaken for emitter numeric IDs. No original-program
verification certificate is claimed. Root's complete semantic oracles remain
required before any runtime assertion.

## Ordinary exported machine interface

Each source root at ordinalN gets:

```text
export function l $p163_entry_N(l state, l arg0, ...) -> l
```

`P163DExport{source,owner,arity}` records its source spelling, exact worker and
argument count. State is borrowed; owning argument words and the one returned
word follow the existing consuming runtime convention. This wrapper makes an
ordinary direct call and returns the result. It never calls a scheduler.

The text also exports:

| Symbol | Contents |
| --- | --- |
| `p163_library_meta` | Four u64 words:16301, constructor count, logical static-image word count, export count |
| `p163_cid_arity` | Constructor arities in the exact CID order |
| `p163_cid_hot` | Corresponding hot flags |
| `p163_cid_names` | Pointers to NUL-terminated UTF-8 constructor names |
| `p163_static_image` | Existing encoded immutable Term image; empty image has a storage placeholder but logical count0 |

This is **not** runtime ABI11101's executable descriptor. A future root-owned
harness must bind these exact constructor tables and static image before calls,
then consume/show and release the complete returned value. It cannot bind a
different catalogue from another program or compare raw Term pointers as output.
There is no default `main` and no startup/time result from this library alone.

A separate additive module, `selfhost/tests/phase163/direct-executable.bend`, now
provides `p163d_executable(request) -> P111Emission`. It requires exactly one
ordinary pure source `main`, arity zero and one boxed result. Its only scheduled
entry is **the unchanged** `p113e_public(derived_owner, 0)`; a separately written
fixed zero-argument text contract rejects any change to that adapter ABI. The
derived owner comes from the actual prepared book, not an assumed spelling.
`p163x_controls()` adds four positive/mutated-adapter controls.

This module emits unchanged verified private workers, the one real adapter,
actual `p111_show` readback information, constructor/static tables and ordinary
`p111q_main`. The descriptor's one segment records the real adapter body and
arity/results. A metadata-only `main -> 0` entry alias selects it even if its
derived owner is named differently. That alias is never supplied to direct-worker
verification or emission: their scheduled FID map remains empty. Thus workers
cannot acquire hidden closure/dispatch dependencies from the entry adapter.

The existing generic verifier does not recognize arbitrary direct-worker imports,
so no generic-program certificate is claimed or forged. Descriptor helpers read
only the genuine adapter's metadata; its fixed contract governs the body. This is
still an experimental boundary pending root-owned source and native checking.
Source02 separates `p163d_plan` from rendering. Planning performs reachability,
static preparation, candidate lowering, admission and final verification once,
returning the same result carrier with empty `text`. `p163d_library` then renders
the standalone library; `p163d_executable` directly consumes the semantic plan
and renders the executable once. It does not build unused library text or repeat
candidate lowering. Source01, already captured by root, had duplicate rendering
in its executable route; any results from that version must retain this caveat.

## Structural controls and remaining checks

Fourteen controls cover valid word return and ordered dependencies, missing and
forward calls, duplicate workers, scheduled FIDs, external symbols, missing or
duplicate constructors, false public-adapter claims, unterminated paths, static
offsets, self references and a valid static prefix. These are verifier-reuse
controls, not a theorem about new ownership transformations.

The implementation does not alter recursion admission, ownership insertion,
scratch size, scalar representation or emitted algorithm bodies. Its first
measurement tests whether direct-library construction can avoid generic body
production for an already-admissible real helper cluster. Broad scheduled hot
owners identified in `direct-abi-audit.md` remain later coverage work. Freeze this
source before acquisition; retain failures and do not label metadata checks as a
successful compiler or native-execution run.
