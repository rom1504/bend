# Phase61 — cache payload bytes instead of repeated tree serialization

Status: frame01 design retained below; reviewed segmented frame2/combined04 is now
applied to source after host controls. Actual source qualification/throughput and
release selection remain pending. No standalone transport speedup is claimed.
The target is cold Base-cache transport, not permission to reuse checked compiler
state or skip checking. Root owns application and measurement.

## Hypothesis and exact factor

`readBaseCache` parses the cache and then `validateSpanCache` serializes its complete
book again to verify the stored canonical-JSON digest. A new framed disk namespace
can hash the exact payload bytes before parsing, removing that second serialization.
The candidate retains the same metadata, range, literal and Lambda checks. It does
not change the public object validators, remove their cycle/alias support, or infer
checked publication state from `validatedBy: check_book`.

The proposed framing is a metadata JSON line followed by raw book JSON bytes.
The header identifies `bend-base-cache-frame-1`; its `bookSha256` covers exactly
those payload bytes. This is a new wire-format digest definition, not a claim that
arbitrary raw JSON hashes equal canonical tree hashes. A distinct `-frame1.json`
filename prevents treating old JSON cache files as this format. Existing versions
1/2 retain their old format/read validation. Span versions 4/6 use the new framing,
with unchanged compiler/Base/path/span/term ABI identity fields. Unknown metadata
is not interpreted as a proof certificate.

## Boundaries retained

The decoder checks the raw digest before payload parsing, rejects a header that
tries to supply `book`, and reconstructs the cached object with the parsed payload.
The writer serializes the compiler-produced book once, hashes those same bytes and
writes them atomically through the existing staged-file rename. Public
`validateSpanCache` continues its canonical-tree digest semantics for caller objects.
This optimization therefore belongs only to the new disk transport. A hand-written
noncanonical framed payload has a raw digest, not an old public object certificate.

Persistent inspection still reads and hashes the full file every request, clears
memo permission on change/missing input, and freezes a newly admitted book exactly
as before. Compiler/Base/path identity and all validation errors remain checked.
The private span path continues the existing `validateSpanBook` walk; dropping
WeakSet/Object.values is deferred to avoid combining two changes or weakening
validation of arbitrary public objects.

## Gates and stop conditions

[Tiny IO controls](../../selfhost/tools/performance/phase61/cache/controls01.mjs)
exercise private baseline/candidate driver copies without compiler calls: matching
cache values, wrong identities/path/span/term ABI/producer, malformed ranges,
literal/surrogate/Lambda payloads, corruption, memo replacement, disappearance,
legacy formats, header shadowing, and public cycles/aliases/getters. Syntax checking
alone has passed; execution and independent review are pending.

Then compare actual frozen Base-cache decoding with unchanged source/API/Base pins
on first and warmed compiler requests. New framing needs explicit preparation;
exclude that one-time work from reader timing but report it separately. Stop if
cold read savings are below the proposed 50 ms usefulness criterion, request output
or diagnostic order differs, or total first-request/peak-memory cost regresses.
Do not infer savings from fewer source traversals. No new compiler release is implied.

## Bounded follow-on: segment hashes and private JSON traversal

State04 identifies188ms Numeric cache reading (decode65ms, span validation77ms,
state admission22ms; inclusive attribution overlaps). Frame2 separates optional
state bytes from the header, avoiding a2.2MB state reserialization at admission.
Its private JSON-tree walker retains checks while eliminating Object.values and
WeakSet allocations. Public caller-object validator behavior is unchanged.

The exact current implementation, corrected harness lineage and focused56/57-group
host results are in [the implementation report](../../implementation/phase61/cache-transport.md).
This follow-on is a concrete falsifiable transport/host-allocation hypothesis,
not permission to infer a checked state or move compiler algorithms into JS.
