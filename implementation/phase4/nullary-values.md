# Private nullary-value experiment

Deferred. Sharing immutable `Nil` and `Unit` values helped small requests, but
the real compiler-core result was too small to justify another production
transform during this pass. The supported private image remains unchanged.

The ablation replaces 659 `Nil` and 2,596 `Unit` literal construction sites in
deferred compiler worker bodies. It verifies the exact constructor runtime and
both zero-field constructor metadata records, then uses frozen private singleton
objects and frozen empty field arrays. Arbitrary constructors, the host ABI
encoder, public runtime and emitted programs retain their original behavior.
Object identity/sharing changes make this valid only inside the compiler's
data-only process boundary; it is not a public-library optimization.

Three alternating fresh-process repetitions on CPU 0 passed all 24 exact
result/emission/execution observations. Both images derive from the same checked
Phase 3 H; the control is byte-identical to canonical private release3. Base
caches were separately validated before timing. All other host/runtime/source
inputs stayed unchanged.

| Request median | Private control | Shared nullary values | Reduction |
| --- | ---: | ---: | ---: |
| Tree emission | 2.449 s | 2.355 s | 3.8% |
| List-sort emission | 4.498 s | 4.154 s | 7.6% |
| Bytes rejection | 1.752 s | 1.703 s | 2.8% |
| Compiler-core library, 312 declarations | 39.267 s | 38.704 s | 1.4% |

The three core pairs improved by approximately 3.4%, 1.5%, and 0.0%; the last
candidate was slightly slower. This is weaker evidence than the accepted private
call changes and the source telescope candidate. An independent review found no
semantic blocker for this exact frozen image, but recommended prioritizing batch
startup amortization and final integration over this small uncertain gain.

The [complete comparison](evidence/nullary-comparison.json.gz) and
[preparation report](evidence/nullary-preparation.json.gz) preserve every sample,
input identity, cache policy, image hash and consumed tool snapshot location.
The experiment remains reproducible through `nullary-prepare.mjs` and
`private-prepared-compare.mjs`; these are experimental tools, not supported
compiler modes.
