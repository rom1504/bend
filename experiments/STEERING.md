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

## Phase57 investigation and next work

[Report](../implementation/phase57/README.md) ·
[Recipes](../selfhost/tools/performance/phase57/README.md).
No compiler source or release change; no PR comment. Two clean matrices cover
48 processes / 192 checked requests, not 192 distinct language tests.

Fresh import+request: B1 2.83–3.13× TS; B2 4.96–5.45× TS. B2 takes 23–30% less
later-request time than raw upstream-emitted Bend, but about 1.8× B1 time.
B1 includes extra transforms: equality removes 44–46% of later time, literal
choices another 17–24%, tail choices another 3.6–5% in an ordered-stage comparison.
B2 already has native equality. Later requests still warm; no steady-state claim.

Lexer sampled allocation/request: TS 59 MB, raw 4,385 MB, B1 927 MB, B2 2,178 MB; cumulative
allocation estimates, not peak memory. All three full-source checks preserve 3,012
expected unsafe declarations/type acceptance/trust refusal. No kernel proof.
B2 reproduces exact B3 under 25 ms stage profiling; reach 93.20 s and emission 115.28 s
are diagnostic times. A first 1 ms capture hit the RSS guard after reach returned;
its eight completed profiles and failure remain preserved.

Ranked next experiments:
1. Ordinary literal record fields. Hot kt uses computed constant keys in B2;
   filtered V8 dumps retain map updates and three runtime property calls. B1's literal
   boilerplate is simpler. Preserve __proto__ semantics, evaluate unchanged
   requests, then time a syntax-only ablation before promising gains.
2. Owner-directed numeric-row constructor queries. j_arm_type still globally
   scans nested constructor lists; intermediate misses create missing KDef+2
   KTerms. This differs from Phase55's existing typed-arity shortcut. Count
   callers/owner visits, preserve uniqueness and the original fallback.
3. Scalar-origin facts through residual/default numeric bindings. sk_char
   already has scalar tests but reconstructs temporary Word lists. A switch table
   alone does not cover its demanded default expression.
4. Typed literal-choice lowering with exact demand/error/tail boundaries. The
   B1 effect is measured; the equivalent B2 gain remains unmeasured.
5. Use counters before changing repeated key serialization, declaration-event
   scans, substitution or render/scan/render reachability. Do not replace the
   compiler representation merely on a broad complexity hypothesis.

The public legacy ABI, seed transforms and native backend remain live dependencies.
Keep checked B1 as the faster development compiler. Program execution performance
and compiler throughput remain separate measurements; no fresh full-program-corpus
aggregate was run in this information-gathering phase.

## Working discipline

Use checked build→focused controls→byte comparison→changed-point timing. Broad
gates run once for the selected candidate. Heavy jobs remain serial on CPU3 with
1 GiB heap, 2 GiB tree RSS, 4 GiB available-memory floor. Agents analyze/review/docs in
parallel. Keep direct-image generation, source checking and kernel proof distinct.
Preserve failed attempts and consumed producers; never mutate closed Phase54,
Phase55, Phase56 or Phase57 raw archives. New runs use fresh private driver/runtime/cache
copies and fresh paths. Retain the Clang environment. Preserve the 103 unrelated
files and stage explicit paths. No nested shared execution guards.
