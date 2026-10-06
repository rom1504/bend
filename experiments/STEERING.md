# Current compiler: Phase55 host02

**Host02 is installed and verified.** Direct JavaScript remains the default;
explicit legacy JavaScript and native C remain available. Ordinary compilation
runs Bend code without a TypeScript fallback. The current task resolved the full
direct compiler-image timeout. No PR comments are authorized.

[Design](../design/phase55/direct-compiler-image-throughput.md) ·
[Report](../implementation/phase55/README.md) ·
[Image workflow](../docs/self_hosted/compiler-image-generation.md) ·
[Publication](../selfhost/tools/performance/phase55/publication.json).

Selected checked attempt: `selfhost/build/phase55/checked-host02`.
API: `cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62`.
Source: `e4383fa08d621716acac437224de182af52e0b16c32b3f29b2614fc1ad1d6710`.
Direct runtime: `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.
Legacy runtime: `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Upstream pin: `018751270e800bc222a93dad7f257083ee53a5f7`.

## Findings and preservation

Use existing checked facts before adding caches or new representations. Typed
matcher ownership replaces repeated global constructor search during arity
recovery, retaining the old unannotated fallback. A completed whole-signature
no-Nat proof skips repeated component host-conversion analysis; Nat-positive and
budget-exhausted signatures retain the original path. Only two Bend files change:
+27 physical / +19 code lines, four definitions. No runtime/native/driver edits.
Source totals: 26,286 physical / 21,617 code lines, 3,019 definitions, 100 types,
107 modules. Phase54's shared helper ownership and 4,096-definition SCC analysis
remain in place; its separate source-scaling results are historical evidence.

Fixed Phase54 source: old full image exceeded 240 seconds; arity01 completes in
198.49 seconds; host02 completes in 96.23 seconds with exactly the same complete
3,895,592-byte image. Export generation falls from 121.39 to 20.92 seconds.
These are CPU-pinned diagnostic observations, not a warmed throughput campaign.
Host02 emits its own source in 103.95 seconds. Both emitted images pass eight
exact ordinary-driver observations; the fixed-image host02 gate reuses the
identical arity01 bytes. All selected exports remain present.

Source 96 / numeric 34 / composition 18 / overapplication 2 / direct census 26 /
maintained 8 pass. All 33 semantic and 45 benchmark point modules remain exact.
Native 3 passes exact C and 6 CPU goldens. Installed 42 legacy + 24 default/relocated
checks, integrity and tamper restoration pass; 7 prior-release files are preserved.
Counts overlap. Dated Phase53 runtime results (1.069599× TS per point,
1.078076× per source; 669 samples) apply only to retained identical modules.
No new generated-program speedup is claimed.

## Next separate gates

The new images inherit the exact checked bootstrap's source proof. Fresh full
self-checking and B2→B3 exact emission equality are not executed. A next bounded
B2→B3 experiment should use the ordinary unsplit API and require the own-source
emission/driver receipts, preserve full bytes and keep those proof claims separate.
Only after those clients are qualified should legacy image transforms be retired.
The installed checked B1 still descends from the pinned seed and reviewed transforms.

Further performance work should profile the remaining balanced costs (loading,
emitted reachability, definitions and export generation) before implementing
SCC body caching or IO-shadow sharing. The prepared per-export v2 diagnostic was
not needed or executed. Do not mistake its plan for measurement evidence.

## Working discipline

Keep checked source and generator identities separate. Run small witnesses first,
then complete byte comparisons; repeat the large runtime campaign only if emitted
code changes or a new timing question warrants it. Final broad gates run once for
the selected candidate. Heavy jobs remain serial on CPU3 with 1 GiB heap, 2 GiB tree
RSS and 4 GiB available-memory floor. Agents can analyze/review in parallel.

Use the retained Clang environment. Sandbox child-process EPERM gets an unchanged
permission retry into fresh outputs, not an oracle or compiler workaround. Preserve
failed attempts and consumed producers; Phase54 and Phase55 closed archives must
not receive new files. Preserve the 103 inherited unrelated files and stage explicit
paths. Documentation and compact publication indexes link authoritative results.
