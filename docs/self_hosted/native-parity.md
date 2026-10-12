# Native C performance and iteration

The compiler written in Bend emits C directly, using the retained native
runtime and Clang. **Phase70 compiler03 is now installed**, checked B1
`386ae358…` and genuine B2 `d069204f…`, with own-source checking and exact B3.
Read the [current report](../../implementation/phase70/README.md),
[observer guide](NATIVE_OBSERVERS.md) and
[expanded runtime results](../../implementation/phase70/native-runtime-results.md)
for its qualification and current metrics. Installed identity is recorded in
`selfhost/dist/release.json`.

This page retains the **historical Phase69 typed10** campaign, pass contracts
and frozen iteration commands. Its B1 API is
`674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553`;
its B2 is `c858dfa5…`. Commands tied to these old plans reproduce historical
artifacts. Use fresh plans bound to the installed API for new measurements.

[Phase design](../../design/phase69/native-parity.md) ·
[Implementation and qualification report](../../implementation/phase69/README.md) ·
[Exact commands and method versions](../../selfhost/tools/performance/phase69/methods/README.md).

## What the speed number measures

These numbers compare execution of **B1-emitted C programs** against C emitted
by upstream's TypeScript compiler at
`059266225b77c8ca256ac6b25ee5c21449bab151`. Both use the pinned Clang22 toolchain,
CPU3, one native thread and GPU off. They are not B1/B2 compiler latency,
TypeScript/JavaScript program execution, or physical GPU results.

The six-family typed10 campaign has 54 correct, qualified intervals: three
balanced positions for candidate, compiler23 and upstream. Each timed workload
lasts at least 100 ms; fixed work and independent digest checks are shared
between roles. Acquisition and Clang time are outside the execution clock.

| Family | Candidate median | Upstream median | Candidate / upstream |
| --- | ---: | ---: | ---: |
| Numeric | 253 ms | 257 ms | 0.984× |
| Arrays | 170 ms | 170 ms | 1.000× |
| Closures | 169 ms | 566 ms | 0.299× |
| Tree | 390 ms | 273 ms | 1.429× |
| Map | 697 ms | 437 ms | 1.595× |
| Lexer | 445 ms | 245 ms | 1.816× |
| Equal-family geometric mean | — | — | **1.0332×** |

Lower is faster. The closure advantage offsets remaining tree/Map/lexer gaps;
the mean does not establish parity for every family. This is a deliberately
small mechanism corpus, distinct from the 45-point JS corpus and from native
semantic conformance. In this same campaign, the geometric-mean compiler23 /
candidate ratio is 1.4794×. Historical ratios from different campaigns must not
be substituted for this paired baseline.

The raw comparison is
`selfhost/build/phase69/typed10-comparison/report.json`; the phase report retains
its portable evidence and archive identity. Do not combine different fixed-work
plans or credit changes to byte-identical generated C as an optimization gain.

## Implemented passes and contracts

The generic representation remains a one-word `Term`, with continuation segments
shared by host and device code. Private host workers expose additional facts to
Clang where the compiler can establish their preconditions.

| Pass | Implementation | Admission and fallback |
| --- | --- | --- |
| Reachable parallel calls | `book.bend`, `flat.bend` | Derive bang facts from the actual main-reachable erased bodies, using the same domain for scheduler and worker decisions. Unreachable imported mains no longer force pool mode. Live bang references remain visible. |
| Immutable constructor images | `static.bend`, `bridge.bend` | Closed graphs with known constructor identity, exact erased arity and constant fields are interned into the existing static image. Arrays, runtime IO constructors, unknown/nonconstant forms and user-foreign books keep ordinary allocation. |
| Known partial applications | `direct.bend` | An actual leading-lambda telescope permits construction of the remaining closure directly with evaluated captures. Unknown, bang, foreign and unsupported applications retain the normal closure dispatcher. |
| Bounded combinator simplification | `direct.bend` | A closed, linear App/Var body with at most eight parameters can expose literal lambda captures to demand-preserving beta lowering. Fresh identities and syntax-only substitution prevent capture and premature evaluation. |
| Cold user-constructor stores | `scalar-array.bend`, `emit.bend` | A checked conservative no-sharing certificate permits plain field stores for qualified non-Base parents. Base nodes, closures, tasks and generic/raw emission retain their ownership protocol. |
| Typed private parameters | `flat.bend`, `product.bend` | Trusted Base U32/F32/Char/Bool parameters become C `u32` under the checked-entry certificate. F32 keeps its bits; Nat, user enums, unknown types and flattened product fields remain `Term`. Scheduler registers and raw calls retain the generic ABI. |

The typed parameters are especially useful together with constructor packing
and cold stores: Clang can prove scalar values fit the immediate representation
and remove redundant keep/seal/range branches. Their prototypes and definitions
share one stored `N_Param` kind list; there is no parallel handwritten signature
schema. Original type telescopes are queried once per worker, with bounded
resolution and alignment checks.

The public `nc_compile` entry remains conservative for permission-based scalar
and ownership changes. `nc_compile_checked` requires checked, specialized,
annotated input, validated layouts and trusted effect/runtime ABI. Its independent
facts control `NATIVE_TYPED_SCALARS`, `NATIVE_COLD_USER_CTORS`,
`NATIVE_SCALAR_ARRAYS` and `NATIVE_UNSHARED_ARRAYS`. Caller-supplied type names or
raw annotations do not grant these permissions. The existing scalar-array and
private-product optimizations remain in place; this phase does not replace the
scheduler with unrestricted C recursion.

### Static data and request-local preparation

`static.bend` prepares each reachable ordinary definition after erasure and
compaction, then shares that prepared body between scheduler and worker
lowering. Its `NativeStaticContext` is a fresh second BookCache payload; the
original source index and definitions remain exact for type and arity queries.
Prior private payloads are discarded. An interior BookCache sentinel causes
preparation to decline, preserving its original lookup behavior. Native and
foreign bodies keep their original temporary-ID-dependent preparation.

Image nodes are interned bottom-up by constructor identity and exact field
words. The image is capped at **65,536 words**; subsequent non-fitting nodes
remain dynamic and may contain already admitted static children. Packed nullary
and fitting scalar-field constructors need no image cells. The existing
`term_triv`, `ctr_take` and `spare_free` rules make static storage immortal;
only immutable constructors and immediate words enter it. Product destinations
can still receive the constant fields directly instead of rebuilding a box.

This is an image-size bound, not an arbitrary AST-depth guarantee. A long
String source control exercises the full lowering path; separate boundary
queries test exact fit, refusal and reuse at the real cap. Raw source cannot
supply a trusted `NStatic` image offset or reuse a forged previous payload.

### Investigations that are not implemented passes

The saved-C lexer state/product transport experiment, Map multiword-return
island, root-preserving observers and scoped constructor spares are separately
recorded investigations. They must not be counted as features of typed10.
In particular, the current consuming match still takes/frees constructor
storage; it does not yet retain lexical spares for reconstruction. See the
[observer design](../../design/phase69/root-preserving-observers.md) and
[spare design](../../design/phase69/scoped-native-spares.md) for their additional
identity, ownership and lifetime obligations.

## A reproducible short iteration loop

Use the [maintained method instructions](../../selfhost/tools/performance/phase69/methods/README.md)
for complete commands, exact parent methods, CPU/memory guards and image roles.
Run commands from the repository root. Paths below are fresh-output placeholders;
choose new names for every attempt, including retries after failure.

1. Freeze a checked B1 through the development workflow. Its `attempt.json`
   identifies the exact snapshot, checked API and equality-derived API. A native
   source module must be listed in **both** its native manifest and
   `selfhost/src/compiler.json`; the latter drives the complete compiler image.
2. Run the smallest independent correctness witnesses for the changed mechanism.
   Acquire only affected families once, compiling their emitted C once. For
   example, after preparing the recipe:

   ```sh
   python3 -B selfhost/tools/performance/phase67/benchmark/run.py acquire \
     --recipe selfhost/build/phase69/candidateNN-recipe.json \
     --out selfhost/build/phase69/candidateNN-acquire \
     --cases tree,lexer --roles selfhost
   ```

3. Reuse the qualified binaries for clean timing. The controlled successor
   compares the candidate with saved compiler23 and upstream acquisitions:

   ```sh
   python3 -B selfhost/build/phase69/methods01/compare-native-v2.py \
     --candidate selfhost/build/phase69/candidateNN-acquire \
     --cases tree,lexer --rounds 3 \
     --out selfhost/build/phase69/candidateNN-runtime
   ```

   This gives 18 intervals, while all six families give 54. Timing does not
   repeat compiler bootstrap or Clang acquisition. If intervals become shorter
   than 100 ms, create a reviewed common-work plan and rerun all roles.
4. Gather allocation counts, generated-code/assembly evidence or profiles only
   when they discriminate competing causes. Preserve diagnostic C separately;
   instrumented clocks are never clean benchmark samples. Phase69's
   `count-selected-v2.py` reuses verified historical counters and runs only the
   newly changed candidate.
5. After selection, broaden to all six families, the selected native suite,
   targeted raw/demand/thread controls, JS continuity, genuine B2, and separate
   B1/B2 C-request timing. Own-source checking, B3 reproduction and installation
   are final integration gates rather than part of every small edit.

Only one guarded CPU3 target tree runs at a time: 2 GiB tree RSS ceiling,
4 GiB available-memory floor, 1 GiB Node heap and 4 MiB stack. Source/data work
uses CPU0; agents can prepare independent patches, controls and reviews while
the target lane runs. Do not nest guards. The methods README distinguishes
summed process time, guard occupancy and elapsed work; none measures billed
model quota.

Physical GPU execution and whole-language native conformance remain separate
coverage questions. Report every qualification's actual scope, preserve failures,
and use `selfhost/dist/release.json` plus the implementation report to identify
the installed version instead of assuming that the latest measured candidate
has been promoted.
