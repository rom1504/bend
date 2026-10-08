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

## Pre-consumption prototype refinement

The cache owner reports root-authorized refinements before prototype v1 was
consumed. This note retains the original review and adds the successor identities:

- Codec: `d2bb79352902e1f2030e32a09b4d136c2e3c99b8bb0ff837377d72461bf93452`.
- Probe: `0fa2941df4102e0d6e6a377975ce458995b1a4d3b3f8f3120e8f6e654cba2922`.

Readback confirms explicit negative-zero numeric-field refusal and a corresponding
control. The manifest now records the baseline graph helper, controller and Node
identities; workers verify those recorded file bytes before decoder timing and
check the imported helper path. The writer's valid-optional-input restriction is
now documented. The original review findings should not be read as an assertion
that this later prototype still lacks these refinements. Actual execution and
isolated timing remain owned and reported by the cache/measurement lane.

## Shared production-helper and strict-controller source review

Reviewed, without target execution:

| Input | SHA-256 |
| --- | --- |
| Isolated `arena-helper-v1.mjs` | `a9c1a88e9c880d87488b15bd74e3ed81d3049103ead97653e630ad33699866f2` |
| `arena-controls-v1.mjs` | `20f38359c9580722962278a172fc792069a7676e269ba0228eb8723533a8c051` |

The new helper extracts existing graph-record construction into a shared function;
the JSON encoder serializes the same record/root arrays. The JSON decoder is
retained. Arena field counts and string/Boolean roles now derive from that schema.
The current world has eight payload fields, with `checkedBound` after `todos`;
legacy six/seven-field worlds remain decoded without inventing absent fields.
The binary constructor mapping preserves this field order. No mechanical transfer
or canonical-input schema defect was found.

The strict controller covers all twelve constructors, maximum unsigned values,
ordinary versus literal Unicode, malformed offsets/fields/ranges, both padding
areas, wrong reference families, historical world fields, unused malformed
records and actual cross-segment roots/sharing. It also compares old/new JSON
encoder bytes. This addresses substantially more of the earlier coverage list;
passing execution is still a separate gate.

One new **claim-scope edge** results from sharing the record interner:
`baseGraphRecords` interns using `JSON.stringify(row)` before arena scalar
validation. If an otherwise equal positive-zero record precedes a negative-zero
record, their keys are equal and the second record can reuse the first, evading
the advertised negative-zero rejection. The single-negative-zero control does
not cover this. Add both `[term(id:0), term(id:-0)]` and the reversed order;
either validate original numeric fields before interning in the arena path, or
explicitly state that scalar validation applies to canonical interned records.
This does not affect authentic compiler-produced U32 values and does not block
the cheap canonical-cache experiment. It prevents describing the current writer
as refusing every noncanonical raw object.

The helper and controller remain unchanged by this reviewer. Production
metadata/capability admission, mandatory/optional frame fallback and real compiler
requests remain the parent and host owner's integration gates.

## Arena v2 closes the pre-intern scalar gap

Read the exact v1→v2 diffs, without executing targets:

- Helper `b58b927ac611f4ead292d4f736cfd427e955b81c1f0efa2f55d1e784755a0119`.
- Controller `99359fa6a8bf1d8e62eadd199a42968650ce9b6bd4687fc77621b9be3b1a09ef`.

`baseGraphRecords` now optionally validates each original unsigned field on its
first visit, before constructing or interning its record key. Only the arena
encoder enables this option; the legacy JSON encoder retains its previous
accepted domain. Distinct positive/negative-zero records therefore cannot bypass
validation by merging. The controller adds both root orders while preserving its
previous controls. The source-level gap identified above is closed; executed
control results remain a separate parent-owned gate. No further source issue was
found in this bounded correction.
