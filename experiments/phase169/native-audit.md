# Phase169 native streaming/publication source audit

Read-only review, 2026-11-06. No compiler or generated target executed. Reviewed
the actual acquisition source
`selfhost/build/phase169/native-source01/compiler.bend`,1,503,932 bytes,SHA256
`df8d64754dab2736983c6f96fcfa192e1063b12edb2f33152f59f4061879760d`.
All source-input pins in its manifest match the current files. The selected
source has4,444 declaration blocks/3,896 distinct names.

**No blocking ownership, verification-order, fallback or native transport defect
was found in the reviewed path.** One concrete source-preparation/reporting
mistake was found below; the normal dependency extractor removes its unused
declaration, so it does not invalidate or require restarting this acquisition.
This is source review, not a native qualification or proof of equivalence.

## The actual admission chain remains ahead of output

[`native-entry.bend`](../../selfhost/tests/phase169/native-entry.bend) reads input
and Base text, chooses unchanged `p88_cache_prepare` or `p86_prepare`, and calls
the original checked `p86_plan`. In
[`streaming.bend`](../../selfhost/tests/phase169/streaming.bend), the successful
chain is:

```
p169s_plan -> p111_runtime_admission
  -> p168_request_mode(1, request)
  -> p167ob_final(actual book, bangs, adapters, private program)
  -> p168v_functions(actual functions, authenticated adapters)
  -> p118b_verify_functions(callable view, actual original program)
  -> import-seeded registry and cursor preparation
  -> one File writer
```

Each stage checks its actual error before constructing the next successful
result. `p167ob_final` retains source/header/final-worker adapter obligations,
exact adapter bodies, ordinary generic segment checking, static-image checking
and actual private borrowed/direct function checking. The callable renderer view
is constructed **after** that private-program gate, then independently checked.
There is no validity bit replacing these judgments.

The view can mark a function callable only through a `P164Adapter` with matching
identity/arity/result and a source reference. All prior semantic workers are
required private by `p167ob_final`, so replacing their public flags does not erase
an already-required public ABI. Import eligibility additionally checks zero
incoming state/flags, one result, bounded arity and the actual callable signature.
Each imported rank-zero `p112w` name has a real generated forwarder to its checked
`p113d` function. Imported owners are excluded from redundant region candidates;
the complete fusion index remains. No unchecked recursive-ready entry is added.

The imported/direct body verification and frame/suspension restrictions remain
the Phase168 mechanisms. Lowering or admission refusal returns an error rather
than silently selecting the original backend. Native transfer must therefore
record unsupported cases as refusals; this experimental entry is not a default
compiler selection.

## Streaming preserves order and lifetime responsibilities

`p169s_seeded` retains the same program IDs, full fusion index, static tables,
constructor metadata, mode0/1 decision, live-register eligibility and
import-seeded registry as `p168j_seeded`. It returns a maintained cursor instead
of invoking `p134e_collect_cursor`. The actual retained bodies match their
reviewed module definitions; source extraction omitted the hosted collection and
control helpers from this native image.

Forwarder Strings are written first, each with the same LF previously appended
when printing collected chunks. Cursor pieces then use unchanged
`p134w_drain/p134w_step/p134wn_text/p134wn_end`: text is written in order and a LF
is appended exactly at `legacy_end`. Therefore pending pieces formerly joined
into one collected chunk have the same concatenated bytes. The maintained cursor
always closes its final main piece; this review does not claim arbitrary
fabricated malformed cursors have a stronger contract.

One `File` owns prefix and cursor writes, avoiding reordering between buffered
`IO.print` and separate descriptor output. Success transfers that handle to the
next action; each write-error path closes it and propagates the original error;
normal completion closes it and returns0. The cursor keeps the structured data
needed by later consumers alive; its ownership is not replaced by raw addresses
or a new arena lifetime. Prefix forwarding text is still collected, so the
change is not claimed to eliminate every retained output String.

## Native command contract

`p169n_args` accepts exactly six Strings: command token,input,Base,mode,carrier,
stamp. Input and Base must be absolute; cache mode also requires an absolute
carrier path. Live mode does not read the carrier and uses the normal live
preparation. Cached mode passes actual Base bytes,carrier and stamp to the
existing authenticator. It does not manufacture cache authority or relocate the
bound Base. Wrong mode/shape returns usage status2. The first command token is
ignored, as in the single-request transport contract; it does not grant session
support. Session/batch shapes are explicitly rejected. The launcher must retain
the runtime's separate one-worker/GPU-off arguments.

All verification/preparation errors reach `IO.die` before opening the output
file. Ordinary write errors may leave partial stdout, as with the existing
streaming compiler; producer nonzero status remains mandatory for acquisition.
The entry ignores the successful plan's proof-report verdict in the same way as
the previous native QBE path. That is a checked compilation path, not a claim
that all source `@unsafe` dependencies have kernel proofs.

## Publication invariant survives this extraction

Among names retained from the exact Phase152 parent, normalized declarations
differ only at **`main` and `p143cb_resume_state`**. The fresh-book initializer
`p143cp_seed_ready` is unreachable from this native entry and is omitted. All
nine reachable publication definitions match their intended Phase156 function
bodies. The following reviewed mutation sites remain identical to the parent:
`check_template_open`, `kw_restore_definition`, `kw_bound_book`,
`kw_temporary_fresh`, `kw_owner_fresh`, `sp_live_body`, `sp_live_done`, and
`check_definition_world`. Original `p143cp_result`, `p111v_segment`,
`p118b_verify_functions` and the cursor IO functions also remain exact under the
maintained normalized declaration comparison.

Thus the existing invariant still applies: dirty startsTrue; a normal canonical
publication establishesFalse; childless logging setsTrue; a skipped publication
preserves it. Complete cache/raw-tail coherence is required. Ordinary mutations
preserve that state or restore the check's entry book. The unchanged finalizer
canonicalizes outward logging results on both success and failure. Existing
prepared-world/hash-disjoint, suffix threshold, declaration order, fresh and bound
arithmetic remain in the retained original callers. See the
[Phase156 invariant](../../research/phase156/publication-invariant.md) and
[independent review](../../research/phase156/semantic-review.md).

## Concrete correction to the extraction report

My earlier [publication extraction receipt](publication-extraction.json) counted
only `def` headers. Its reported79-line/4,147-byte module actually contains
**ten definitions and one unused trailing `P156CLoadResult` type**, plus that
type's comment. The byte and file hashes are correct; the assertions of ten
total declarations/no new type/minimality were incorrect. The last recorded
function span included the following type because the scan looked for the next
`def`. The inverse-byte test consequently did not detect this extra declaration.

The real maintained declaration parser identifies it correctly. Normal native
dependency extraction omits the unused type and its constructors entirely; they
are absent from frozen source`df8d6475…`. It also omits the unreachable fresh-book
initializer as noted above. No consumed source or receipt was edited during the
running acquisition. Preserve the old report as the failed minimality claim.

A future source-only corrected subset is the first73 lines/3,883 bytes, SHA256
`49f9aaa3d9c665ff88df5a7b09c81fec520aee4f57a7b8d0f57f0ffd57af3cb6`.
Offline maintained parsing confirms exactly ten `def` blocks and their unchanged
normalized original bodies, with zero types. A successor extraction receipt can
record that correction after active inputs are released; no new native
acquisition is justified solely to remove a type already absent from its source.
