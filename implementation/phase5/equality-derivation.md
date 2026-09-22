# Equality derivation across checked builds

The maintained helper in
[`selfhost/tools/development/equality.mjs`](../../selfhost/tools/development/equality.mjs)
applies the Phase4 equality substitution to newly checked B1 APIs. It leaves the
original API, its bootstrap report, public H, compiler sources, runtime and
default distribution untouched. This first gate establishes selected correctness
and applicability; **no Phase5 performance comparison has run**.

## Contract and recognition

Run from `selfhost/` after a genuine normal bootstrap, choosing a fresh directory:

```sh
node tools/development/equality.mjs \
  build/dev/attempt/api.mjs build/dev/attempt/api.mjs.bootstrap.json \
  build/dev/attempt/equality
```

The output is `equality/api.mjs` plus `api.mjs.derivation.json`, explicitly marked
`newBootstrap: false`. No bootstrap sidecar is copied or fabricated. The maintained
development workflow can select this profile explicitly; checked B1 remains its
default. Its API-specific validated Base cache must be separate from the original
compiler's cache.

`deriveEquality({api, bootstrapReport, outputDirectory})` verifies the genuine
bootstrap's API/source/module/input identities, completed provenance, canonical
upstream path and pinned Base/parser/emitter. It requires the reviewed assembly
and checked-library recipe, the exact generated runtime prefix, and eleven exact
equality dependency bodies. The supported source assembly imports Base once and
must not declare replacements for the String/Char/Cmp families. A strict scanner
checks actual top-level function/export boundaries, uniqueness and protected
function/variable/parameter bindings; a quoted function declaration is not a
binding. Unknown structures or bodies refuse instead of guessing.

Only primitive well-formed strings use JavaScript equality; all other inputs
execute the untouched generated body. The contract is compiler-host data under
standard unmodified JavaScript built-ins. It does not claim equivalence under
arbitrary prototype monkeypatching, reflective function observation or proxies.
The original API's exports and argument adapters are retained. H's existing
String.eq intrinsic is not touched; its artifact does not satisfy this B1
bootstrap/body contract.

`verifyEqualityDerivation(report)` verifies retained identities and independently
replays the transformation against the original checked API. The recorded tool
snapshot must match the original transform hash; the original tool's mutable
location need not remain unchanged after development. Current verifier code
reconstructs the output exactly rather than executing the archived tool. Original
bootstrap inputs, original API/report and the recorded Node binary must still
verify. This is lineage validation, not cryptographic authentication of a
maliciously fabricated build report. A fresh-destination failure retains a
structured `complete:false` report; an existing directory is refused without
overwriting it.

## Two genuine source builds

Both normal bootstraps ran in isolated copied projects on CPU2, Node24.18.0, with
4 MiB stack and 4 GiB heap. The second copy deliberately prefixes the fallback
diagnostic message in `dg_no_report`; this source change is only a recognition
witness and is never promoted to production. Both expose the normal 54 roots.

| Build | Checked source SHA256 | Checked API SHA256 | Derived API SHA256 |
| --- | --- | --- | --- |
| A | `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122` | `a3a287c25470a5a55d7c49085fce9a4a72aee3dfa6d15d3d5674c7c36566b2a2` | `6611ba5f5e9f9b81bf2157ccf3d084d8b461a8eef4b5c1cf4198b54be5304970` |
| B | `ebae1650faa73d18f7eb026a78884566728c2e68dd10c31bcbc5d829cd9e311c` | `5debf3d5db549abfc4d1a5e6eeb203ff3a85bd962b9e0a5a99f69822c1433136` | `09d0c8cc307bfa2845f913443cc606fef3e6158eb4eb653a2ab73a72b5064fe4` |

Each build passes ten focused test groups: 900 value pairs plus nine long-prefix
pairs; scalar/non-BMP/combining/embedded-NUL inputs; malformed UTF-16 demand and
early mismatch/exhaustion; exact thrown values; non-string fallback and staged
arguments; changed bodies/runtime, duplicate/nested/rebound/shadowed bindings;
provenance refusal, exact replay and changed-output refusal. Run with:

```sh
EQUALITY_TEST_API=/absolute/api.mjs \
EQUALITY_TEST_BOOTSTRAP=/absolute/api.mjs.bootstrap.json \
  node --stack-size=4096 --max-old-space-size=4096 \
  --test --test-isolation=none tools/development/equality.test.mjs
```

The selected compiler gate records **24 complete observations**: six fixtures
through original and derived APIs for each source build. Cases cover successful
U32 and Unicode programs, parse/type rejection, a successful module import and
an imported type error. All full observation objects agree between corresponding
original/derived builds. Six emitted program pairs are byte-identical and execute
with the expected result. These are not upstream conformance or whole-source
proof claims. Base caches are API-specific and may already exist from earlier
correctness attempts; their preparation is not a controlled timing comparison.

The first attempt used a malformed import fixture without the required alias;
the second exposed a probe directory naming collision. Their failures and exact
consumed tools remain archived. The corrected third attempt passes. Independent
workflow-owner review requested extra protected-parameter guards; both final
ten-group runs pass, and the strengthened verifier reproduces the previously
successful derived bytes exactly. No broad/full-source gate or timing was added.

## Preservation and next gate

[The compact summary](equality-evidence/summary.json) and
[archive manifest](equality-evidence/manifest.json) retain 284 file identities in
129 verified gzip objects (1,109,321 bytes): both genuine bootstrap reports,
consumed source/tool inputs and generated APIs, selected observations and emitted
programs, failure attempts, old/new test/helper versions and final replay. Each
object decompresses to its manifest SHA256; original absolute paths are historical
identities. Node is an external hash-identified tool; regenerable validated Base
caches are omitted. The selected compiler probe is
`tools/performance/phase5/equality-probe.mjs PREPARED_TWO_PROJECTS FRESH_OUTPUT`.

The next decision belongs to root: review the optional maintained workflow,
validate the combined current source and schedule a controlled timing slot.
Phase4's exact-image speed result is motivation, not a new measurement of these
different builds.
