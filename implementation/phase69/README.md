# Phase69: native execution approaches upstream parity

The selected compiler, **typed10**, runs the six C diagnostic families at an
equal-family geometric mean of **1.0332× upstream execution time**. In the same
campaign compiler23 takes **1.5285×**: the implementation removes **32.40% of
runtime**, a **1.4794× speedup**. This is aggregate near parity, not parity for
every family. Tree, Map and lexer remain slower.

Compiler algorithms remain written in Bend. No benchmark-name recognition,
TypeScript fallback, handwritten generated-C patch or runtime ABI change is
part of the selected implementation.

[Design](../../design/phase69/native-parity.md) ·
[Backend documentation](../../docs/self_hosted/native-parity.md) ·
[Portable evidence](evidence/summary.json) ·
[Iteration methods](../../selfhost/tools/performance/phase69/methods/README.md) ·
[Intermediate results and failures](checkpoint.md).

## Controlled execution comparison

These are native programs emitted by the **checked B1** Bend compiler and built
with Clang, compared with the same programs emitted by pinned upstream's
TypeScript **C backend** and built with the same recipe. They are not JavaScript
execution or compiler-request timing. B2 emission continuity is separate.

| Family | Compiler23 ms | Selected typed10 ms | Upstream ms | Selected/upstream |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 252 | 253 | 257 | 0.984× |
| Arrays | 171 | 170 | 170 | 1.000× |
| Closures | 729 | 169 | 566 | 0.299× |
| Tree | 664 | 390 | 273 | 1.429× |
| Map | 722 | 697 | 437 | 1.595× |
| Lexer | 612 | 445 | 245 | 1.816× |
| Equal-family geometric mean | | | | **1.0332×** |

`typed10-comparison/report.json`: 54 qualified observations, six families,
three roles and three balanced rotations. Each interval is at least 100 ms,
uses identical work within its family and passes three independent digest
checks. CPU3, one native thread, GPU off, Clang22 `-std=c11 -O3`, identical
headers/link inputs. Counts: numeric 77,504; arrays 61,440; closures 57,888;
tree 1,280; Map 1,152; lexer 448. Warmups are one eighth, rounded to 16.

This mechanism corpus is not the 45-point JavaScript set, full test suite or
arbitrary Bend programs. Closures strongly outperform upstream and pull down
the mean; the tail must remain visible. Historical compiler23 **1.724×** used a
different campaign whose closure/tree clocks differ. Do not credit its entire
cross-campaign change to this implementation.

## Implemented mechanisms

1. **Reachable parallelism facts.** `nc_bangs_names` uses the existing reachable
   graph; unused imported bangs no longer force pool scheduling. Live bangs
   retain scheduling. Initial implemented comparison: tree 664→560 ms,
   lexer 613→544 ms. Corrected facts also permit appropriate private workers.
2. **Immutable constructor images.** New `static.bend` prepares ordinary bodies
   once and interns closed constructor DAGs into existing `STAT_IMG`. Arrays,
   runtime IO, user foreign code, unknown values and image overflow retain
   ordinary lowering. Source/cache identities and child shapes are preserved.
3. **Known closure factories and tiny linear combinators.** Actual leading
   lambdas permit constructing the final captured closure directly. Bounded
   App/Var combinators specialize literal lambda arguments using syntax-only
   substitution. Capture order, argument demand, exactly-once parameter use and
   fresh-ID hygiene remain explicit. Factory-only closures 747→536 ms; the final
   combined campaign reaches 169 ms. Unsupported calls retain normal lowering.
4. **Owned user-constructor stores.** The existing checked no-sharing certificate
   avoids redundant sealing. Shared parents/captures, raw and uncertain cases retain
   fallback. The saved-C tree discriminator gave mode 570→cold 459.5 ms; the
   general cold-store rule was integrated. Storage reuse remains a prototype.
5. **Native scalar worker parameters.** Existing `N_Param` and word kinds carry
   trusted Base U32/F32/Char/Bool facts into private `u32` signatures. Full arity
   and expanded product widths must agree. Nat, user ADTs and flattened fields
   remain `Term`; raw APIs never narrow. Tree diagnostic cold 459.5→typed 397 ms.

These changes compose through existing lowering and certificates without a
new general IR. Review rejected a combinator version that could erase demanded
work. Syntax-only substitution and its `nd_beta` prerequisite retain raw
first-error behavior; the controls do not prove a separately observable
compiler23 bug.

## Allocation evidence

Counts are deltas between 17 and one workload repetitions, including the fixed
wrapper's delta. Instrumented timing earns no performance credit. Historical
compiler23/upstream counts were reused only after reproducing both transforms
and matching the diagnostic C bytes; selected counts are fresh.

| Family / count | Compiler23 | Selected | Upstream |
| --- | ---: | ---: | ---: |
| Closures: allocations | 12,318 | 4,110 | 8,214 |
| Closures: generic entries | 16,432 | 4,120 | 8,224 |
| Closures: host segment entries | 65,783 | 20,639 | 28,845 |
| Lexer: allocations | 1,596,879 | 1,105,389 | 734,878 |
| Lexer: redirect wrappers | 597,839 | 364,367 | 364,367 |
| Tree: allocations | 640,908 | 434,132 | 231,426 |
| Tree: redirect wrappers | 204,801 | 1 | 1 |

Static data removes lexer constants and redirects, but its state product still
allocates. Tree avoids sealing unique constructors but reconstructs more nodes
than upstream. The residual is not simply allocator speed.
Raw: `typed10-counts02/report.json`.

## Experiments not integrated

| Direction | Isolated result | Decision |
| --- | --- | --- |
| Scalar lexer loop state | Static/mode 482→432 ms, upstream 246 | 10.4% gain; defer 100–200 lines and demand/ownership controls |
| Scoped tree storage reuse | Cold 459.5→426.5 ms | 7.2% incremental; retain prototype |
| Scheduler product-result island | Map 722→677 ms, upstream 430 | 6.2% despite wide allocation coverage; defer ABI expansion |
| Borrowed traversal preserving roots | Map 722→390 ms, upstream 429 | Strong **0.909× upstream prototype**, not a compiler pass |
| Scalar result facts | Final lexer 448→446 ms | 0.45%, overlapping samples; reject added complexity |
| Packed input facts | Final lexer 448→444 ms | 0.89%, overlapping samples; reject added complexity |

The borrowed Map prototype combines bit traversal and String comparison;
individually 488/620 ms. Shared-error/poll behavior, representation and general
analysis still need qualification. The
[reviewed observer design](../../design/phase69/root-preserving-observers.md)
specifies bounded return-identity analysis, branch-local field origins, private
read-only workers and original owned roots retained at the generic wrapper.
Estimate: 350–600 Bend lines, 4.5–9 hours including controls. Analysis/refusal
witnesses come first; no Base or benchmark names may determine admission.

## Correctness

- Checked B1 and 36 selected frontend observations pass.
- **71 paired native source cases** pass in both reference and candidate,
  including the previous 37 integration cases plus independent bang, closure,
  static sharing, 2,000-char string, cold-refusal and scalar-width controls.
- **28 raw report rows** meet their output/error oracles, with one/four-thread
  runtime witnesses. First errors agree exactly where specified; unsupported
  core controls require rejection rather than identical diagnostic wording.
  These are role/error rows, not 28 distinct programs. Raw
  falsely annotated U32/Bool values preserve Nat 4294967303 without narrowing.
- **Seven static-image helper queries** test actual 65,534/65,535-word prefixes,
  exact fit, refusal, reuse and dynamic-parent/static-child behavior. This is
  internal boundary evidence, not a giant source benchmark.
- **2,992 reachable frontend/JS functions** and runtime/public wrappers remain
  identical, preserving prior finite evidence. No fresh full 45-point JS timing
  campaign is claimed.
- Genuine B2 generation and **eight driver observations** pass: exact JS/C
  emitted bytes and JS execution. Driver C is emitted, not executed.

The [independent final review](../../selfhost/tools/performance/phase69/methods/final-review.md)
matches the live typed patch to its checked snapshot and audits all 71 emitted
C files: scalar permission 68 on/3 off; cold permission off in all four refusal
controls. All 36 retained raw C files leave typed permission undefined.
Physical GPU execution, full-suite conformance and new native effect coverage
are not claimed. Existing 13 native API gaps and proof-trust limits remain.

## Simplicity, iteration and preserved failures

Registered Bend source: **29,821→30,261 physical lines** (+440, 1.48%),
**24,424→24,768 code lines** (+344, 1.41%), 120→121 modules,
3,471→3,533 definitions, 122→126 types. Static images add 262 physical lines;
seven pre-existing native modules change. Frontend, host and runtime algorithms
remain unchanged. Experimental scaffolding is separate from maintained source.
This is a modest complexity increase for speed, not a line-reduction claim.

Five source/method lanes and an independent review lane supported root's single
target lane. CPU0 source/data; CPU3 targets; 2 GiB process-tree cap, 1 GiB Node heap,
4 GiB memory floor. Saved-C discriminators preceded compiler integration.
Checked B1 loops took about 34 s; broad native and self-hosting gates ran only on
the stable selection. Target time and total elapsed are reported separately.

Preserved failures include module registration, Bend match restrictions, affine
binders, invalid new fixtures, a Map prototype register-shadow bug, Node pipe
EPERM inside the sandbox and Python3.9's unsupported `zip(strict=True)`.
Successors preserve original methods/raw; no golden was weakened. The unchanged
Node harness ran with approved sandbox escalation and the same resource guard.

## Final qualification and release

**Selected typed10 is installed and verified**, committed as `f1655d0`.
Selected equality-derived checked B1:
`674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553`.
Genuine B2 and its byte-identical 4,365,136-byte B3:
`c858dfa5424c534444a2b733c0336a7009fc260da272d64c52f33a188d3f066e`.
Checked source: `75e10b92c0c55594b9c02de6d1c8cae56a5ebc129eb31004ef77dc86d23cedc8`.
Pinned upstream: `059266225b77c8ca256ac6b25ee5c21449bab151`.

B2 freshly accepts all 3,533 compiler definitions in a 19.22 s self-check
request (13.66 s checking) and reproduces B3 in 29.54 s. These are diagnostic
request durations, not balanced throughput.
All definitions retain explicit unsafe trust refusal: type acceptance and a
fixed point do not establish a mathematical proof. Installed integrity before
and after testing, legacy42/default24/helper5 all pass. Every previous installed
file is preserved exactly in `selfhost/dist/release-history/c76f1113…/`.

### C compilation is a separate remaining gap

The fresh three-source screen has 27 exact-output requests: B1, genuine B2 and
TypeScript, three balanced positions per source. Bend Base preparation occurs
before measured requests (3.272s B1/2.921s B2); TS ordinary Base checking remains
inside its request. Imports, Clang and program execution are separate clocks.

| Source | B1 request ms | B2 request ms | TS request ms | B1/TS | B2/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric | 2,268 | 1,549 | 713 | 3.182× | 2.173× |
| Array | 2,340 | 1,559 | 716 | 3.267× | 2.177× |
| Lexer | 2,873 | 1,946 | 885 | 3.245× | 2.198× |
| Geometric mean | | | | **3.231×** | **2.183×** |

All 27 requests and two preparations pass. Four optional profiler jobs were
deliberately omitted; the inherited all-campaign analyzer therefore remains
`complete:false`, with the clean subset explicitly complete. These ratios do
not replace broad historical JS compiler metrics or establish a paired
compiler23 latency improvement. The earlier C request ratios 3.389×/2.284× are
separate observations, not controls in this campaign.

Generated C shrinks, e.g. lexer 1,314,022→1,240,671 bytes and
tree 1,173,400→1,122,458 bytes. Their recorded Clang durations are respectively
8.473→5.332 s and 7.643→5.499 s, but old/new acquisitions were separate: these are
single-run build receipts, not a fresh balanced C-build speed claim.

### Time, publication and next step

The final accounting finds 453 guarded process receipts, **21m44s occupied by
guarded targets** across a **51m29s first-to-last-target span**, peak 1.516 GiB,
11 preserved failed receipts and no pending targets. Source work, reviews,
design, integration and documentation are outside guard occupancy; it is not
an exact model-quota or billing measure. Packaging/publication occur afterward.

The [verified capsule](../../selfhost/tools/performance/phase69/artifacts/evidence01/README.md)
preserves Phase69 raw files, methods and failed variants. It identifies external
historical compiler/toolchain dependencies; it is not a hermetic environment.
Design `5b5c93a`, first implementation `48a0dd4`, and qualified compiler
`f1655d0` were pushed to `selfhost/bootstrap`. No PR comment was posted.

The strongest next runtime opportunity is **general root-preserving observers**,
with the demonstrated 0.909× Map prototype as a falsifiable target. Tree reuse
and unboxed lexer state follow. Expand native coverage alongside these changes;
neither aggregate 1.033× nor the Map prototype establishes every-program parity.
