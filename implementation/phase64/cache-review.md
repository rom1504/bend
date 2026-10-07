# Phase64: independent indexed-cache codec review

Review mode: **source-only**, no Node process, compiler target, benchmark or
production edit. Reviewed the frozen eager prototype against the selected frame3
reader and its fixed constructor graph decoder. This is an admission to a cheap
isolated experiment, not approval for production integration.

| Input | SHA-256 |
| --- | --- |
| `indexed-codec-v1.mjs` | `b3f3efe9c39201133ca1395a831c8725a17284554806b46f11b9089cbe2b9371` |
| `indexed-probe-v1.mjs` | `13d09c772c395abf7f4d41325e60685d9874b7f0fda86a341c3ff5d79e53f297` |

## Conclusion

No source-level blocker was found for transcoding an authentic, canonical frame3
artifact produced by the current writer. Eager validation and exact object
sharing are retained by the proposed decoder. The cheap falsifier may proceed.
Two issues need explicit handling before claiming broad equivalence or qualified
measurement: negative zero lies outside the producer's canonical numeric domain
but inside the existing decoder's accepted domain, and the probe does not yet
bind the baseline driver's imported graph-decoder dependency.

## Findings

1. **Accepted-input domain is slightly narrower than structural equivalence.**
   Both the old graph decoder and new packer recognize U32 values with
   `(x >>> 0) === x`. JavaScript accepts `-0` under that test. The old JSON decoder
   can retain a `-0` field, whereas `writeUInt32LE` stores zero and unpack returns
   positive zero. The probe's `Object.is` scalar oracle would distinguish them.
   The actual frame3 writer uses `JSON.stringify`, which emits `0`, so authentic
   producer artifacts cannot exhibit this case. Explicitly document canonical
   producer input, reject noncanonical negative zero in the transcoder, or make
   a deliberate compatibility decision; do not claim identical roundtrip values
   for every JSON wire accepted by the old reader without a control.

2. **Baseline implementation dependency is missing from the probe binding.**
   The manifest hashes the driver file and experimental codec, but frame3 decode
   calls the driver's imported `base-cache-graph.mjs`. Its bytes can change while
   the driver's hash stays fixed. Record `driver.baseCacheGraphPath` and verify
   that identity before each worker imports the driver. Also retain the probe
   and Node identity in the manifest or explicitly bind them in the outer guard.
   This is an evidence-identity gap, not a demonstrated algorithm failure.

3. **Encoder and decoder have deliberately different error domains.**
   `decodeIndexedFrame` retains the book when optional bytes have the wrong hash
   or fail full validation. `encodeIndexedFrame` instead requires valid JSON and
   matching hashes for both input frame3 segments. It cannot currently transcode
   every damaged frame3 file that the old reader would accept with optional
   fallback. That is fine for a preparation-only writer over canonical input;
   automatic migration of arbitrary old cache files must preserve fallback or
   regenerate optional state explicitly.

These findings were sent to the cache owner and parent. The prototype files
remain unchanged by this review.

## Checked invariants

- **UTF16 strings:** packing uses UTF16LE bytes, offsets count code units and
  slicing uses JavaScript code-unit positions. Ordinary string values retain
  embedded NULs, astral pairs and unpaired surrogates; string boundaries remain
  independent even if a high surrogate ends one entry and a low surrogate starts
  the next. String interning preserves values, not object-node identities.
- **Literal Unicode:** `KLiteral` String text still uses the old `for...of`
  codepoint check rejecting isolated surrogate codepoints and requires number
  zero. Numeric literal kinds retain the old allowed set and empty-text rule.
  Span and ABI checks run even on unreferenced records.
- **Scalar bounds:** binary fields are Uint32 values. Constructor-specific
  boolean slots require zero or one. Header ranges require valid U32 endpoints
  and preserve zero/zero versus positive contained-span rules. Total node/string
  counts, field-count ceilings, byte bounds and terminal offset checks bound
  typed-array construction. Offset differences of the wrong sign/size fail a
  constructor's exact length check; string offsets must be monotonic and bounded.
- **Graph identity:** each decoded record appends one object to the shared nodes
  table. A reference must target an already appended node and the correct kind
  mask. Prepared records begin from a shallow copy of the mandatory node array,
  preserving cross-root object identity. No definition or term is reconstructed
  independently for each root. Duplicate string values do not merge ADT records.
- **Eager corruption checks:** every mandatory record is decoded and validated,
  including records not reachable from the exported book. Mandatory failure
  throws. Optional decode is staged in local arrays; failure publishes no optional
  roots, leaving the book usable. Checked/fresh/world/frontend roots are all
  published only after the complete optional graph succeeds.
- **Clock scope:** the worker times input read, hash checking, parsing,
  schema/range/reference validation and complete materialization after module
  imports. It hashes both input files before timing, so the explicit statement
  that this is not OS-cold storage is necessary and correct. Exact graph checking
  is after the clock. This does not establish whole-compiler speed or semantic
  admission: API/Base/path/producer identity and private capability binding stay
  with the driver.

The probe's graph oracle checks both directions of object correspondence across
all five roots, so equal values with broken sharing cannot silently pass. It
compares property keys/order and scalar `Object.is`, but intentionally does not
establish equality/admission of outer metadata. That limitation is already
listed in the probe and must remain in any result claim.

## Controls before production selection

The frozen probe has useful real-artifact, unaligned-buffer, invalid-tag,
backreference, span, boolean, string-ID, offset, unused-mandatory and world-version
controls. It is sufficient for a cheap falsifier, not complete input validation
coverage. Add a successor controller, preserving consumed v1, for:

- exact ordinary-string roundtrips: ASCII, empty, NUL, BMP, astral, isolated high
  and low surrogates, and adjacent pool entries split across a surrogate pair;
- valid maximum U32 values in unconstrained scalar fields, encoder rejection of
  fractions/negative/out-of-range fields, and an explicit negative-zero policy;
- invalid String literal surrogate, unknown literal kind, nonzero String number,
  nonempty numeric literal text, and term-ABI mismatch;
- decreasing/out-of-bounds string offsets, truncated pools, wrong field lengths,
  nonzero padding, mandatory hash mismatch and optional hash mismatch;
- a self/forward reference, wrong list-family reference, and an **unused malformed
  optional record** whose result keeps the exact mandatory book and no states;
- immutable input bytes and authenticated driver admission/fallback once the
  format is actually integrated, including stale API/Base/path/span/producer
  identities and old version1 versus new version2 world metadata.

Do not infer that a good isolated decode time justifies lazy objects or a new
production format. The next gate after this eager falsifier is a fresh real
compiler request with exact module bytes, unchanged state admission and fallback,
and all format overhead included.
