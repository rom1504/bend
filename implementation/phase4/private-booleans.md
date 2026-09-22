# Private Boolean matcher specialization

The private compiler still constructs partial handlers for generated `Bool.and`
matchers. The compiler's fixed native Boolean representation and immutable private
function boundary allow two reusable handlers: false returns false, and true
returns its second argument. `Bool.not` can directly negate a native Boolean.
Unknown values retain the original matcher call at the same evaluation point.

This is a measured prototype, not yet a supported package change. Exact hashes
pin both generated matcher bodies; the transform checks their unique definitions
and native constructor metadata. Only one-argument literal call sites in generated
compiler bodies are rewritten. In particular, the first matcher still executes
before evaluation of the second argument, and the second argument remains eager.
The handler objects and their bound arrays are frozen. Public libraries, emitted
programs and the generic runtime retain their original behavior.

The actual image has 610 `Bool.and` and 202 `Bool.not` sites, including private
worker copies. Three hundred direct observations preserve truth values, partial
and overapplication, higher-order results, repeated use, malformed fallback and
first/second argument exception order. Three alternating fresh-process rounds
on CPU1 pass all 24 exact result, diagnostic, emitted-byte and applicable
execution comparisons:

| Workload | Private control request | Boolean candidate request | Reduction |
| --- | ---: | ---: | ---: |
| Tree | 2.101 s | 2.013 s | 4.2% |
| List sort | 3.659 s | 3.498 s | 4.4% |
| Rejected bytes operations | 1.579 s | 1.475 s | 6.6% |
| 312-declaration compiler core | 28.115 s | 25.874 s | 8.0% |

Core process-wall medians are 29.512 and 27.247 seconds. Base caches were
independently validated before timing; output runtime, host and source are
identical. The source is the new checked Phase4 H. Its experiment snapshot
accurately retains the then-pending fixed-point status; a subsequently completed
proof does not retroactively change that record. These subset measurements do
not establish full-source speed or generated-program execution gains.

[Evidence manifest](private-boolean-evidence/manifest.json) links the complete
preparation, all samples and controls. Tools are
`selfhost/tools/performance/phase4/private-booleans{,-prepare,-test}.mjs` and
`private-prepared-compare.mjs`. Each replay needs a fresh preparation and output
directory with matching consumed tools.

## Preceding rejected experiment

Ordinary partial-call-chain flattening found **zero qualifying sites** in this
same H. The existing emitter already batches the ordinary statically known
function arguments. The remaining interesting chains apply generated matchers,
whose field/handler arities differ from ordinary function arity. The guarded
uncurry preparation rejected its unchanged candidate before any benchmark. Seven
semantic tests cover the proposed ordinary-function rewrite; they do not supply
a performance result. Its rejection and consumed original transform are retained
alongside this evidence. Revisit only if a new emitter actually produces eligible
chains, or as a separately proven matcher transformation.
