# Next cache transport experiment (proposal only)

State04 Numeric CPU counts put readBaseCache at 27.1% inclusive, frame decoding at
10.9%, span validation at 10.4%, and checked-state admission at 8.0%. These overlap
and must not be added. The allocation capture attributes 22% beneath readBaseCache
and 12% to parsing. This makes transport a stronger immediate hypothesis than an
unmeasured replacement of generic String operations. CPU sampling counts are not
clean stage timings or proof of a prospective speedup.

A bounded next counterfactual is a separate, identity-bound `node:v8` serialized
cache namespace. Serialize the same JSON-owned book and optional states once during
preparation, hash the exact binary payload, and deserialize only after validating
its header/digest. Keep every existing API/Base/path/range/term ABI/producer/shape
and state permission check, including validateSpanBook and deep freeze. Compiler
checking, parsing, state creation and prefix verification remain Bend source.
This is host disk transport only, not a checked proof certificate.

Bind the format to the Node/V8 version and explicit producer schema; mismatch,
malformed bytes, missing state or digest drift must discard/fallback exactly like
the existing cache path. Do not read binary bytes as legacy JSON and do not reuse
old frame1 filenames. The same trusted-local artifact scope applies: a digest is
an integrity binding, not protection against a caller forging payload and digest.
The writer must accept only the already JSON-owned prepared graph; no arbitrary
host objects, custom prototypes, functions or public unchecked graphs enter it.

Measure decode alone and whole readBaseCache on the exact same Numeric/Map/ray
books, including optional checked patches (about300 definitions in this image),
header validation, hashing, span validation and freezing. Compare output/types and
all cache mutation/deletion/error controls, state-fallback behavior, Unicode/span
roundtrips, and first-request wall time. A decode micro-win is insufficient: require
at least50ms whole first-request saving before consumer migration. Preserve old
methods; root chooses and executes any producer. No binary implementation or
performance claim is made by this proposal.

A source-level compact patch representation could reduce bytes further, but must
be produced/replayed in Bend and preserve the exact checked publication contract.
That changes the state schema and needs separate differential proof; it should not
be combined with the first binary-transport discriminator.

## Segmented JSON candidate prepared first

Root selected a lower complexity first discriminator before binary serialization:
`cache/frame2/typed-driver-frame02.mjs` with `controls05.mjs`. The header stores
three exact byte lengths; the body contains book, checked-state and fresh-state
JSON segments. The decoder verifies the book and optional state byte digests before
parsing. A mismatched optional-state digest omits its permission and keeps the
ordinary checker fallback. A privately held record lets admission reuse that exact
raw digest instead of serializing the parsed state again. The new frame2 namespace
retains legacy frame1 decoding/read fallback; writers only create frame2.

The specialized span walker is restricted to decoder-owned fresh JSON trees. It
retains all literal/Lambda/range predicates, scans unknown extra own fields, and
uses array indexes/own enumerable traversal without WeakSet or Object.values.
Public object validators keep their original alias/cycle/getter behavior. JSON
cannot contain cycles/shared references or getter properties; this is the proof
for the narrower private traversal, not a permission to skip validation. Memo
book/state freezing, exact file hashing and mutation/deletion invalidation remain.

Numeric's separate stage capture reports cache188ms, of which decode65ms and state
admission22ms (including state stringify) are observations; span validation77ms
covers both book and patches and overlaps state admission inclusive cost. Allocation
beneath validateSpanBook is16.911MB, with Object.values8.391MB and WeakSet.add8.258MB.
These identify removable work, but no candidate saving is established. Review and
root-controlled IO/ordinary-request qualification are pending. The source state
producer/bridge contract is unchanged. A future carrier prototype is separate.
