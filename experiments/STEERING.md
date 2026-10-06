# Current compiler: Phase56 string01

**String01 is installed and verified.** Direct JavaScript remains the default;
explicit legacy JavaScript and native C remain available. Ordinary compilation
runs Bend code without a TypeScript fallback. No PR comments are authorized.

[Design](../design/phase56/qualification-and-simplification.md) ·
[String design](../design/phase56/native-string-equality.md) ·
[Report](../implementation/phase56/README.md) ·
[Image workflow](../docs/self_hosted/compiler-image-generation.md) ·
[Publication](../selfhost/tools/performance/phase56/publication.json).

Selected checked attempt: `selfhost/build/phase56/checked-string01`.
API: `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`.
Source: `5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244`.
Qualified direct B2/B3: `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`.
Direct runtime: `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.
Legacy runtime: `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Upstream pin: `018751270e800bc222a93dad7f257083ee53a5f7`.

## Findings and preservation

Seven legacy helpers have no maintained consumers and were removed. Their checked
and derived API bytes remained identical. Definition-only native String.eq then
adds two lines, without runtime or call-site ordering changes. The original direct
image's self-check profile put 17.6% of ticks in String.cmp and its recursive helper.
String equality now uses native primitive comparison at the function definition;
ordinary calls retain pending-argument order. All 484 UTF-16 pairs and callback,
partial, throw, native-name and refusal controls pass. Net source change is
−40 physical / −32 code lines and seven definitions; total 26,246 physical /
21,585 code, 3,012 definitions, 100 types, 107 modules. All 17 native modules,
both runtimes and typed driver remain exact. No new compiler representation/pass.

Checked B1 emits the direct compiler image in 84.43 s. B2 freshly type-checks its
full source in 29.68 s (35.39 s overall) and emits a byte-identical B3 in 250.72 s.
The old direct B2 exceeded 300 s. Its 55.84 s check was profiled; do not compute a
controlled speedup from that and the new unprofiled time. All 3,012 expected unsafe
declarations cause proof-trust refusal; type acceptance and self-reproduction
are not mathematical proof validity. The installed artifact remains checked B1.
Do not give an emitted B2 a checked bootstrap sidecar.

Fresh B2 source 96 / numeric 34 / composition 18 / overapplication 2 pass. B1 focused 36
and maintained 8 pass. B2 checks 23 benchmark sources and matches B1 on all 45 point
modules. Installed 42 legacy + 24 default/relocated checks, integrity and tamper
restoration pass. Counts overlap. Known TS failures remain separate oracle defects.

44/45 points retain host02 bytes. Changed map/set median 20.8518 → 17.5360 µs, compared
with TS 20.5952 µs: 15.9% less time in five fresh rounds, 15 correct samples.
No new full-corpus aggregate. Unchanged point measurements retain dated Phase53
support; its whole-corpus 1.069599× result stays historical.

## Next work

Compiler throughput is now the larger gap. Two-input three-round import+request
screen: B1 2.84–3.11× TS, direct B2 5.08–5.55× TS, B2 ≈1.79× B1. The checked B1 path
remains the faster development loop. This is not cold user CLI timing or a universal
compiler ratio. Follow the recorded warm-base-cache and preflight scope.

Within B2 reproduction, emitted reachability 89.03 s and unsplit emission 111.68 s
are the largest measured pieces. Profile those stages and the actual direct-image
code before adding caches or global rewrites. These are stage timings, not proven
internal causes. Guard string/order semantics and retain the fixed-point gate.

Legacy client migration can now build on actual direct B2 qualification, but it
still requires each maintained client's contract and provenance gates. The public
legacy JS ABI, seed transforms and native backend are live dependencies. No mass
legacy deletion is justified by the seven dead helpers or B2 byte equality alone.

## Working discipline

Use checked build→focused controls→byte comparison→changed-point timing. Broad
gates run once for the selected candidate. Heavy jobs remain serial on CPU3 with
1 GiB heap, 2 GiB tree RSS, 4 GiB available-memory floor. Agents analyze/review/docs in
parallel. Keep direct-image generation, source checking and kernel proof distinct.
Preserve failed attempts and consumed producers; never mutate closed Phase54,
Phase55 or Phase56 raw archives. New runs use fresh private driver/runtime/cache
copies and fresh paths. Retain the Clang environment. Preserve the 103 unrelated
files and stage explicit paths. No nested shared execution guards.
