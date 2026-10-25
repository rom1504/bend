# Phase140: early incremental compiler sessions

The three-hour campaign produced a checked, native incremental prototype with
**about 2.8× faster warm compiler rebuilds**, not the requested 10×.
The final real compiler edit takes 101.030s of native compilation. Including
output reconstruction, the measured machine build and all shared session overhead
charged to the edit gives 124.679s versus 346.960s fresh. These are single controlled
observations on a late same-width edit, not a general speed guarantee.

Both complete 106,285,793-byte products match independent qualified fresh builds.
The generated code is unchanged for the compared inputs. The cache-seeding cold
request became 8.70% slower than the initial prototype, and full native adoption
qualification was deliberately deferred. **Phase137 N3 remains qualified; the
installed selection is unchanged.** This is a predeclared batch interface, not
an interactive incremental build service.

[Design](../../design/phase140/README.md) · [Candidate identities](candidate.json) ·
[Joined metrics](metrics.json) · [Remaining work](remaining-work.md) ·
[Native batch guide](../../selfhost/tools/performance/phase140/session/batch-README.md).

## Actual rebuild comparison

A is qualified Phase137 source SHA`2620d59a…ecf38`,2,701,952 bytes. B changes the
product-policy bound in`p131rg_width` from16 to15, SHA`46d2d164…3a93`.
A fixed candidate compiler processes A then B with the same logical source path.
A separate qualified Phase137 N3 compiles B from scratch. The output differs
between A and B, so this is a substantive edit rather than a no-op benchmark.

| Cost boundary | Fresh qualified B | Initial prototype warm B | Final prototype warm B |
| --- | ---: | ---: | ---: |
| Native request / revision stages |331.943s|153.551s|101.030s|
| Fresh request supervisor total |333.144s|—|—|
| Warm output reconstruction |—|7.500s|5.522s|
| Exact-product QBE + assembly + link |13.816s|13.816s|13.816s|
| Available-executable subtotal |346.960s|174.867s|120.368s|
| Warm subtotal speedup |—|1.984×|2.883×|
| Final warm estimate charging all shared session overhead |—|—|124.679s /2.783×|

The machine cost is one actual build of the byte-identical B product, reused
consistently in these joined estimates. It was not redundantly rebuilt for every
cache implementation. The conservative final estimate additionally charges all
session preparation, unassigned native/runner time and B source IO to B. Outer
resource-guard overhead, acquiring the experimental compiler, priming A and
qualification remain separate. See the reproducible
[receipt join](../../selfhost/tools/performance/phase140/session/summarize-pair.py).

The rebuilt B executable compiled Lexer, Map churn and a closure workload to
exact frozen QBE in5.815s total. That focused check is separate from build time.
The independent B output SHA is
`a5149b2410d70546b7a28ff907aa312b6431cf8c5348107e7b675b9e9f54702e`.

## Where time disappeared—and where it did not

| Warm native stage | Initial source03 | Source17 | Final source18 |
| --- | ---: | ---: | ---: |
| Frontend |51.394s|31.319s|30.966s|
| Raw lowering |44.820s|14.161s|13.306s|
| Optimization and verification |35.266s|40.652s|40.079s|
| Registry |12.805s|11.389s|9.902s|
| Rendering and close |9.266s|7.707s|6.777s|
| Total |153.551s|105.228s|101.030s|
| Cache-seeding cold A |334.286s|364.129s|363.377s|

The initial prototype already reused checking and late output. Subsequent work
removed much more preparation/lowering and some comparison/registry work.
However, backend optimization/verification became slower than in the first
prototype. High cache hit counts did not guarantee cheap requests. The final
first-order comparison experiment improved warm total by3.99% against source17;
this single comparison does not establish a precise isolated causal gain.

The earlier source15 three-edit batch measured133.647/136.411/139.365s native
warm time for inline/continuation/product changes. Its checkpoint preceded the
first edit, unlike the matched product-only pairs. Inline and continuation
products lack independent full references and remain exploratory. Two further
six-minute reference builds were deferred because the5× milestone was not close.

## Implemented in Bend

The private fixed-producer session retains actual parser and checker checkpoints,
including freshened declaration/context identities; it does not trust an owner
hint as proof. Prepared/erased owner products retain exact reverse dependencies
and body-reference lists. Indexed reachability preserves original order.
Same-request constructor catalogues and successful verifier metadata are reused.

Static preparation may resume reuse after an edited owner only when the complete
post-owner static image exactly converges. It restores the current revision's
fact prefix, never the old prefix. Late observer admission retains consumed
scalar-layout and body-reference dependencies. Registry metadata and rendered
units reuse exact contextual products; the original final verifier still runs.

Two independent audits found missing global read dependencies during development:
scalar layout can change through aliases, and constructor lookup can depend on a
datatype through an alias. The corrected path gates on the exact layout catalogue
and conservatively invalidates all owner reuse for a dirty datatype. Earlier
attempts remain recorded, not silently relabeled sound.

The last experiment replaces private generic equality callbacks with typed Bend
comparisons. Actual QBE confirms closure application disappears and matching
statement-list continuation storage drops48→24 bytes. Scheduler transitions
remain; these are not tight native loops. See the
[source audit](../../research/phase140/typed-comparison-audit.md) and
[machine evidence](../../research/phase140/typed-comparison-machine.md).

Host tools freeze jobs, supervise resources, reconstruct authenticated output
pieces and compare evidence. Parsing, checking, dependency decisions, lowering,
optimization, verification and emission execute Bend. No host-side compiler,
pointer-equality bypass or probabilistic semantic cache was introduced.

## Correctness, performance and adoption are distinct

Final source18 passes independent source checking and 255 focused control rows.
Complete Lexer/Map comparisons cover fresh/cached output, actual executable
edits, complete frontend plans, type/parse failures and successful recovery.
Four native Lexer revisions A→B→A→B match independent outputs. Both full compiler
A/B products match qualified references; the resulting B compiler passes three
independent compiler-request checks.

These establish finite/differential evidence, not a mathematical cache-soundness
proof or complete compiler-correctness theorem. Existing protected proof bodies
remain byte-identical; no new theorem is claimed. The native CLI exits on invalid
source, whereas the pure session API retains state and recovers. A live request
protocol with retained state after errors remains to be implemented.

There is no new broad45 runtime score, upstream speed comparison or N1/N2
self-reproduction qualification. Exact QBE plus the same runtime/toolchain
preserves generated code in the checked comparisons. Early edits, new binders,
changed declarations/imports or literal layouts do not inherit the speed claim;
conservative refusal remains part of correctness.

The ordered hosted cold-overhead screen exceeds its 5% threshold: final Lexer
+7.07%, Map+33.69% versus original fresh requests for the same inputs. These
are single ordered hosted observations, not calibrated native regression scores.
Separately, native cache seeding costs363.377s versus334.286s in the initial
prototype (+8.70%). That comparison is between two cache-building prototypes,
not candidate versus ordinary incumbent cold compilation. A native ordinary
cold-overhead gate remains unestablished. The research exception was recorded
before expensive follow-up. No installed promotion follows from warm gains.

## Cost, complexity and reproducibility

Final source18 has 64,408 physical lines versus 58,569 in the parent: +5,839,
including experimental adapters and embedded controls. This is an experimental
composition, not a simplification result. Consolidate successful interfaces and
remove test-only exports from a future production composition before adoption.
Sampled peak process-tree RSS is about 2.31GB. Heavy runs used one controlled
CPU3 lane with a4GiB maximum and16GiB available-memory floor; no OOM occurred.

The [intermediate cost review](cost-review.md) preserves the20:34 snapshot.
The [final cost inventory](cost-final.md) counts101 completed guarded workflows:
92.49min summed,91.40min interval union;29 failed attempts cost132.41s of guarded
execution. Four candidate acquisitions cost24.59min, four complete edit loops
37.87min, the independent full oracle5.58min, and the final profile8.00min.
These are nested workflow categories, not additions to stage clocks. Unmeasured
wall time is not reported as idle time or token cost.

The [fresh profile](profile.md) has23,157 samples, zero reported loss and99.4%
main-thread coverage. In an approximate conservative warm window, reclamation
is24.33%, ownership/product helpers13.03%, string equality11.27% and ordering
4.81%. These are physical observations, not additive promised savings.

The [final evidence capsule](evidence/README.md) preserves990 files, including
raw receipts, snapshots and this capture, with zero identity mismatches.
Raw paths identify workspace artifacts; hashes alone are not a fresh-clone
bootstrap package.

Reproduce the source with`prepare.py` and the exact ordered
`session/modules-native-v18.json`, preserving only the declared
`p111_native_args` experimental override. The checked API, native acquisition
from qualified N3, aligned machine build and batch commands are recorded in the
pinned receipts. Full reproduction requires the qualified Phase137 source/image,
Base carrier, runtime and toolchain referenced by those receipts. Keep those
identities fixed and use fresh output/guard directories.

## What this changes about the next experiment

The strongest result is evidence that early semantic reuse works on the full
compiler. The strongest negative result is that independently rediscovering
unchanged state at every stage still consumes most of the warm budget.

Carry exact producer-owned change evidence from raw lowering into verifier
admission first, with unchanged context checks and the independent final gate.
Then test reuse of frontend book/index products. Do not add another independent
cache or claim10× from hit counts. The
[next-boundary audit](../../research/phase140/next-reuse-boundary.md) and
[remaining-work budget](remaining-work.md) explain the falsifier and why several
whole-program traversals—not just one backend helper—must disappear.
