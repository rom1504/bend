# Remaining cache and startup opportunities (proposal only)

State06 is the source baseline for this investigation. No new source or host change
is proposed for immediate application; canonical workflow-sync02 remains unapplied.
Root reports the three-case combined ratio about1.47×TS (Numeric near parity,
Map1.85×, ray1.65×). These are bundled outcomes, not isolated cache contributions.

Fresh Numeric attribution supplied by root: readBaseCache21.27% inclusive,
module parsing16.26%, seeded checking18.60%, decoder11% self, private span walk6.11%.
The existing [count capture](../../selfhost/build/phase61/state06-b2-latency01/cpu-map-numeric01/numeric-recurrence-0-candidate-profile/summary-counts.json)
likewise identifies cache and module loading, but exact percentages differ between
captures. Inclusive child percentages overlap; neither capture predicts a gain.

| Priority | Smallest discriminator | Contract retained | Main uncertainty |
| --- | --- | --- | --- |
|Rejected|Generic node:v8 serialization vs current segmented JSON, exact same book/state|Same integrity identities, span/payload/state validation, memo freeze and fallback|Deserialization may be slower; shape checks remain necessary|
|2|Node module compile cache for the actual API import|Ordinary module/API loading remains inside measured request; code runs unchanged|Prepared subsequent processes differ from fully cold cache generation|
|3|Explicit persistent compile/library inspector|Same source loading/checking/emission per request; only existing immutable Base/API ownership reused|Current memo API intentionally covers parse/check only|
|4|One request-local prefix maximum query instead of two|Bend-only pure graph analysis and exact full checker fallback|Likely smaller saving; source-state proof still required|

##1 — Binary host transport, not a compiler implementation

A private namespace must bind format schema, Node/V8 identity, compiler hash, exact
Base/path/interval/ABI and preparation method. Hash the complete raw binary payload
before deserializing the exact compiler-produced book and optional states. Preserve
all public validators, private literal/Lambda/span checks, state shape/producer
checks, recursive memo freezing, and missing/corrupt/incompatible ordinary fallback.
Node-specific bytes must never masquerade as frame2 or legacy JSON. The same
trusted-local model applies; hashes do not authenticate a deliberately forged state.

Use generic serialization of the already JSON-owned prepared graph, with no
handwritten AST parser, elaboration, checking or specialization in JavaScript.
Initial preparation may decode frame2 once before serializing, preserving its exact
JSON-roundtrip value semantics rather than preserving previously omitted undefined
fields or host objects from the raw API output. Binary formats can express aliases
and cycles, unlike JSON, so begin with the generic cycle-safe validator; do not
reuse the JSON-tree shortcut merely because the payload hash matched. Keep unknown
extra own fields, field order, Unicode strings and alias structure; reject unsupported
non-data objects. Compare exact decoded graph and actual source diagnostics/output,
not merely cache byte size. First compare decode+validation+freeze and whole first
request on Numeric/Map/ray, including state patches. Require a useful whole-reader
saving before migrating consumers. Preserve JSON fallback and corruption tests.

##2 — Test Node's existing code-cache facility

Node24.18 documentation confirms ESM compile caching via NODE_COMPILE_CACHE or
module.enableCompileCache; first creation can cost more, subsequent loads can reuse
code. The cache is version-sensitive and absolute module paths matter by default.
See [the pinned official module documentation](https://github.com/nodejs/node/blob/v24.18.0/doc/api/module.md#module-compile-cache).

Measure three separately labeled states: empty code cache and generation; prepared
code cache in a new process; repeated import/request in one process. Apply equivalent
policy to TS when comparing ratios. Include actual import/loadApi time, cache setup,
flush and disk bytes; do not subtract the observed16% module-parsing subtree. Use
normal dynamic import, not a custom vm wrapper. This optimizes host startup only;
all compiler algorithms remain Bend. Node cache failure must remain an ordinary
load, never a required compiler-state certificate. Coverage runs should disable it.

##3 — Reuse that already exists, and the narrow extension

`tools/typed-driver.mjs:createPersistentInspector` already loads an identity-bound
API once and memoizes an immutable decoded book/state. `readBaseCache` rereads and
hashes bytes each request, then skips decode/validation on an exact memo hit.
Therefore another parsed-Base memo for check/parse is redundant. Ordinary inspect
loads through Node's module cache but does not share that persistent Base memo.

An explicit compile/library batch extension could reuse this same ownership model:
keep per-request API identity checks and Base/cache rehashing, override caller API
options, load every user/import/foreign/runtime input anew, and run ordinary Bend
checking/emission each time. Cache no request result or open checker world. Test
changed/deleted cache, changed API/Base path/bytes, imports/errors/FFI and output
exactness. This improves repeated process requests; it cannot improve the first
request of a fresh process without moving preparation costs.

##4 — Small Bend-only repeated-query opportunity

`src/check/prefix-state.bend:base_prefix_resume` computes norm_max_book on the
prefix+suffix, then `base_prefix_admitted_final` computes norm_max_book(prefix)
again. A request-local prefix maximum plus suffix maximum can avoid one prefix
traversal if the existing maximum fold is proved compositional. Keep the actual
prefix-bound equality and all suffix/world/namespace guards; do not replace them
with a trusted host guess. This is a cheap source-query proposal, not a persistent
open-world cache. The current carrier counts/drops top-level event cells; Numeric
count profiles put f_prefix_drop below1% self, so that alone is a lower priority.

Avoid process-global parsed-book reuse based only on paths/mtime or immutable API:
Base and cache bytes can still change. Avoid caching entire checked worlds without
accounting for the suffix-dependent fresh bound, replay stamp and rebased patches.
No implementation, target execution, gain or release promotion is claimed here.

## Binary discriminator outcome

Root's [codec result](../../implementation/phase61/cache-codec.md) rejects binary
migration under the required generic validation policy: JSON99.840ms vs binary
225.676ms median across five alternating samples each, full values/metadata equal.
Smaller binary bytes did not produce a useful codec saving. No production format
change or further codec iteration is warranted without strong new evidence.
Remaining startup/reuse proposals above are untested and independent of this null.
