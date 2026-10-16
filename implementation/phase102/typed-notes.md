# Composable native workers

This lane addresses the Phase101 indexing profile without changing the source
application or inventing another optimizer. The installed Phase98 compiler
already admits ordinary C `NF_` workers with scalar parameters, local destinations,
tail loops, and ownership-preserving constructor operations. Admission of the
*caller* is all-or-nothing: a parent with one unsupported dependency remains in
the scheduler even when many of its other callees are admitted direct workers.

## Mechanism and first experiment

In the source index, `index_lines` repeatedly calls small admitted workers such as
`next_mode`, `newline_mode`, `utf8_width` and `is_comment`. The scheduler stores
10–15 live values before each call, enters an NF adapter, then restores the same
values in a continuation. Three such continuation functions accounted for 34.5%
of the accepted Phase101 samples. That is physical instruction attribution, not
a promise that all of that fraction is removable.

[prepare.py](../../selfhost/tools/performance/phase102/typed/prepare.py) implements
a general generated-C ablation. It identifies an existing one-result NF adapter,
an exact save-frame shape, and its exact matching continuation prologue. It
snapshots live values into local C variables, evaluates original arguments in
order, calls that same NF worker, and resumes the same continuation locally.
All original ownership operations are retained. Original device branches and
unrecognized shapes are preserved. No application/helper names select a rewrite.

The initial source-index intervention finds 34 admitted wrappers and 46 expanded
call edges across 22 segments. Its static saved-slot count is 392, including
repeated expansion; it is **not** an execution count. This deliberately isolated
ablation retains the old continuation definitions and grows C by about 16%.
That growth is avoidable in the compiler integration below.

Root's first `typed-index01` screen passed full outputs and reported candidate
times of about 0.730× baseline for generated 10,000-line input and 0.622× for the
real compiler source. Corresponding upstream ratios were about 1.267× and
1.417×. Treat the root's complete receipts as authoritative, and later repeated
screens as the promotion evidence. This lane ran no native/compiler targets.

## Bend compiler integration

[prepare-bend.py](../../selfhost/tools/performance/phase102/typed/prepare-bend.py)
prepares a reversible derivative of the exact installed Phase98 source
`2a72bbdc…`. Initial candidate `52ba3d7e…` added 23 physical lines / 1,747 bytes,
but all three applications emitted their original C: the intended rule did not
activate. Preserve that negative result. Candidate 02, `b5331123…`, adds 59 lines /
3,934 bytes and repairs the discovered permission/planning boundary.
The canonical equivalent is emitted as an isolated `canonical-bridge.bend`;
production modules and installed selections are not changed by this preparation.

The implementation reuses the existing `NFCall` value node:

1. `nf_scheduler_name` accepts only a saturated, non-bang named application with
   the existing `NativeHostWorker` certificate and exact arity.
2. `nf_scheduler_bind` uses existing `nd_bind_value` to evaluate every argument
   once, in original order, before the direct call node.
3. `nf_scheduler_emitted` calls the existing ordinary NF function into a local
   one-word result slot. `nc_let_emitted` resumes the remaining scheduler body
   in the same scope, retaining its existing sharing and dead-value handling.

The emitter validates permission/arity again and requires all arguments to be
bound variables. This eliminates the continuation in the compiler's existing
value-producer abstraction; it does not copy continuation C or grant new
whole-function admission. Partial/dynamic/unknown calls keep `nc_let_cut`.
Ordinary NF workers keep their existing scalar-observer redirects where present.

The failed first candidate exposed a critical Phase98 distinction: source-index
uses File effects and has observer permission, but does **not** have the stronger
packing/sharing permission (`NATIVE_TYPED_SCALARS=0`). Its old pipeline therefore
planned NF workers only *after* scheduler lowering, so the local rule could not
see them. Candidate 02 builds the same existing NF plan before scheduler emission
for observer-qualified books without reachable bangs, then attaches a distinct
`NativeLocalPlan` permission. The old `nf_host_payload` rejects that marker;
factory removal, scalar arrays, constructor packing and sharing gates stay off.
Only the new local-call selector reads it. Existing strongly qualified host plans
remain accepted as before. No worker admission rule is expanded.

Any program containing reachable bangs, any raw unqualified emission and any
failed admission retain the prior route. The raw/bang fallback also retains its
original generic-lowering-before-planning error order. The new checked local lane
plans earlier. This is narrower than the generated-C experiment's CPU-only
intervention in arbitrary already-emitted programs. No new GPU behavior is claimed.

## Correctness obligations and controls

For an admitted callee, the old scheduler adapter already invoked the same NF
function with the same consuming arguments and returned its owned result. The
change removes the intervening storage/dispatch protocol. Its obligations are:

- Evaluate arguments once in their original order; preserve error checks.
- Retain exactly the roots shared with later computation, before transferring
  argument ownership; preserve result drops and escaping children.
- Keep saturation, arity, host permission and ordinary boxed-result ABI gates.
- Preserve unsupported, partial, dynamic and device-capable fallback paths.
- Do not select an optimization through benchmark/application names.

[controls.py](../../selfhost/tools/performance/phase102/typed/controls.py) freezes
independent expected outputs for four runtime-text inputs, aliases/escaped fields,
an unused result, asymmetric argument positions, U32 wraparound, partial calls,
and a dynamically returned function. A separate recursive bang control has the
independent answer 428 at one/two/four workers and requests baseline C identity.
These are finite executable controls, not a whole-compiler or lifetime proof.
Argument *positions* are independently observed; effect/error evaluation order
also relies on structural reuse of the existing ordered argument lowering.

The compiler image must be acquired from the isolated Bend source, then emit and
run the same application inputs. A generated-C win alone is insufficient to
claim a new compiler, native B1/B2 chain or promoted release.

## Device source review and candidate 03

Independent review found a real source-generation defect in candidate 02:
ordinary NF declarations are host-only, but a local call could appear in the
unused device fallback body of a scheduler segment. The no-reachable-bangs
permission prevents offloading these segments at runtime; it does not by itself
make their device C well-formed. CPU measurements remain valid, but candidate 02
is not suitable for promotion.

Candidate 03 reuses the existing `N_Segment.host` field. At `nc_finish`, a request
carrying either exact private local-plan or host-plan marker has its segments
marked host-only. Both markers are attached only after checked provider permission
and an empty reachable-bangs set. Existing `ne_segment` then excludes those cases
from the device switch. Numeric FIDs remain available; the host function dispatch
table is already inside `#if !DEVICE`. Segment bodies, ownership and host execution
are unchanged. This omits unused device bodies for a certified CPU-only request;
it does not claim literal preservation of those bodies. Bang-bearing, raw and
provider-unqualified requests retain the original route and device source.

The marker is request-local: `ns_source` strips the prior cache's appended facts
before request planning. `NativeLocalPlan` remains distinct from the stronger
`NativeHostPlan`, so this correction does not grant packing or layout permission.
The isolated canonical counterpart adds a single `nc_finish` wrapper in
`canonical-book.bend`; the main standalone candidate includes it directly.

Candidate 03 is 80 physical lines / 5,171 bytes larger than installed Phase98,
with source SHA256
`eb949e781f6e9467fd1e3183644ecb0637c4102717665532387aaa7824b54ddd`.
The coordinator owns all execution and validation receipts. Candidate 01 and 02
preparation methods and helpers have exact-hash snapshots alongside their local
build recipes, preserving both the inactive experiment and the device defect.

`typed/admission.mjs` adds read-only diagnostic exports and logging wrappers to
an unchanged checked-API prefix. It records existing NF worker admission errors,
dependency closures and refusal sites without changing their return values. This
supports the next question: which whole-function capability still prevents
`index_lines` itself from becoming an admitted worker after local composition?

## Whole-function admission: proof composition, not a new loop engine

The coordinator ran `typed-admission01`. It confirms the main `index_lines`
candidate already lowers to 11,154 bytes of ordinary C, with no lowering error
and **zero continuation segments**. Its failure is transitive admission, not an
inability to represent the state loop. Two independent dependencies block it:

1. `read_word`, `skip_space` and `read_quoted` pass literal closures to `choose`.
   Their ordinary candidates reject escaping closures; the bounded branch
   specialization lane addresses that mechanism.
2. `String.eq` depends on `String.order`, then `String.cmp`, whose dependency on
   `String.cmp.fin` closes a cycle. Both bodies lower without error, but ordinary
   NF admission requires dependencies to be ready first. Inlining the helper is
   insufficient: its equal-character branch calls `String.cmp.rec` **after**
   recursive comparison to rebuild both original strings. This is non-tail
   recursion, and the single-output constructor-chain TRMC experiment does not
   handle its two reconstructed roots.

The independent text reviewer identified a stronger existing capability:
source-index already emits `$observer.String.cmp` and its **owning adapter**.
The existing symbolic observer proof establishes that the comparison can borrow
the two live roots, compute the scalar observation, and return the original
owned pair plus comparison. The public scheduler entry already uses this
adapter. The ordinary NF dependency graph simply cannot use that proof yet.

`typed/observer-forward.bend` bridges this boundary. After the original NF plan:

- Offer only unready ordinary workers with no lowering error or segments,
  positive arity at most four, and the ordinary one-word result shape.
- Use the original observer schema, symbolic proof, residual validation,
  private-name freshness and worker-pair admission. The existing scalar observer
  ready-owner restriction stays unchanged; this pass accepts owning result
  adapters, not a broader shared/unique scalar policy.
- Replace the original unready worker with a same-name, same-parameter ordinary
  worker that forwards its owned arguments and result slot to the admitted
  owning adapter. Record the adapter dependency explicitly.
- Run ordinary NF admission again. Callers can now become ready through the
  proven adapter without admitting a recursive C call cycle or changing their
  bodies. No application or Base function name selects the transformation.

The first isolated candidate (`typed-observer-source01`, SHA256
`257eac636e9c2654ccb12f62553067f58c0d8080c56f6703ac2c1cff4431af64`)
adds 52 lines / 3,273 bytes to typed candidate 03. Independent static review
passed its ownership, ABI and permission boundaries. Execution remains the
coordinator's responsibility. This prototype conservatively omits late cold-layout
metadata for routes proved early: the private-name collision retains the existing
pair, and the ordinary public adapter invokes the new alias. Missing metadata
keeps normal sealing/ownership overhead; it cannot authorize colder stores.
Base String roots are excluded from that cold-layout mechanism already.

`typed/observer-controls.py` provides five independent complete-output controls:
empty/equal inputs, a proper prefix, Unicode ordering, long equal strings and
late mismatch. Each observes scalar equality, both restored roots and comparison,
held aliases, then the final consumed-root result. These target the owning
adapter boundary rather than merely checking its emitted C spelling.

## Checked integration and emitted activation

Two early source preparation defects were caught before native execution:
observer source02 attempted to scrutinize a local `code` binder with `match`,
which Bend disallows; source03 omitted `+rest` when the list tail was captured
by both branch closures. Source04 uses a separate formal-parameter matching
helper and annotates that shared tail. All new affine binders and match sites
were then audited. The earlier sources and versioned preparation helpers remain
available as failed experiments, rather than being overwritten.

The coordinator's observer API03 check passes for source04
(`f683a56fc1e673af0f486d0f6b025d43e4e3fb60a1fbea8d8ac748466bea52ab`),
which layers the owning-adapter bridge over typed03, bounded branch specialization
and the generic TRMC candidate. `observer-emission03/source-index/emitted/program.c`
is 791,051 bytes, SHA256 prefix `73beff74`. Offline inspection confirms:

- Ordinary and product `index_lines` workers now exist. The ordinary body is
  11,243 bytes and uses a local tail jump, with no direct self call.
- Ordinary `String.cmp` is a 252-byte forwarding body. Its owning adapter is
  1,600 bytes and calls the existing 2,181-byte borrowed loop.
- `String.order` and `String.eq` are ordinary workers; product `read_word`,
  product `read_quoted` and `skip_space` use local tail loops.
- The read-only `typed/activation-v2.py` audit records 65 defined NF functions,
  no missing directly named NF definitions and **no recursive NF call component**.
  The exact C/method hashes, edges and line mappings are retained in
  `observer-emission03/source-index/typed-activation-v2.json`. The successor
  scanner also recognizes the generic `_trmc` helper suffix; the first scanner
  omitted that one helper, without changing its acyclic-call-graph conclusion.

This is emitted-mechanism evidence. Runtime gain, full outputs, stack behavior
and native B1/B2 inheritance still require the coordinator's guarded executions.
The graph audit examines named NF calls and local-loop syntax; it is not a full
C control-flow or whole-compiler proof.

The coordinator's later cheap all-source upstream preflight found two fixture
errors before the final native control executions: the constructor local in
`typed_report` needed an explicit `TypedPair` annotation, and the bang control's
predecessor was consumed twice without a shared binder. Successor fixtures
`controls-v2.bend` and `controls-bang-v2.bend` supply `+pair : TypedPair` and
`Succ{+pred}`. Manifest `typed-controls02/controls.json` retains all five expected
output byte strings, runtime arguments, worker sets and the bang baseline-C
identity requirement exactly. The observer fixture passed that full preflight
unchanged. The failed first fixtures remain available.

## Inline policy and full-image cost check

The coordinator's separate inline source01 changes the existing `nf_inline`
budget from 4,096 to 8,192 codepoints, adding no source lines or admission rule.
`nct_within` walks the rope without flattening, accepts an inclusive limit and
stops once that limit is exceeded. It counts Bend String codepoints, rather than
bytes, and only the worker's own emitted body, rather than transitive expansion.

The C ablation measures the complete definition body, including the 89-character
NF prologue/trailer. Offline inspection finds that this slight policy difference
does not select different workers on the three measured apps. Both policies
newly force-inline six workers for source-index, one for image-render and four
for dependency-plan. Source-index's six are `String.cmp.fin`, `is_name`,
`read_word`, `next_mode`, `count_kind` and the product `read_word` worker. This is
an audit of the observed experiment, not an application-name selection rule.

An additional offline scan of the installed Phase98 compiler self-C identifies
24 newly eligible workers out of 38 ordinary `INLINE` NF workers. Their own
bodies total 120,158 codepoints; a rough one-level syntactic call-site expansion
is 163,831 codepoints, with at most three directly named call sites per worker.
The full source, scanner and rows are recorded in
`inline-source01/installed-inline-budget-audit.json`. These figures suggest
moderate expansion on that old compiler image, but they do not bound transitive
inlining, final Phase102 admission growth, Clang memory or machine-code size.
The final compiler C and actual guarded Clang build must supply those observations.

## Native compiler image activation

The coordinator's final source `trmc-reuse-source02` is
`8b895aec2dc9eac2eaee0036239367f83b53910c309ba26ebab4c9a47fa5affa`.
Its genuine native B1 self-emission passes the complete independent Phase98 B2
diagnostic comparison. These structural comparisons use the **same final source**
on both compilers; the installed compiler's own older source is recorded only
as separate context in `native-compiler-shape01.json`.

| Emitted structure | Phase98 B2 on final source | Final B1 on final source |
| --- | ---: | ---: |
| C bytes | 39,356,447 | 30,080,590 |
| Continuation FIDs | 35,179 | 15,964 |
| Ordinary/product/observer/TRMC NF definitions | 508 | 943 |
| Local NF result slots | 0 | 12,123 |
| Local NF tail jumps | 34 | 216 |
| Generic TRMC helpers | 0 | 47 |

The 435 additional definitions are 335 ordinary workers, 43 product workers,
47 TRMC helpers, five borrowed observers and five owning adapters. Ordinary
`String.cmp` is newly admitted through its existing owning-adapter proof. New
local frontend loops include `f_number`, `f_numeric_error`, `f_path_scan` and
`f_source`; the TRMC helpers include String/List operations, parser list builders,
normalization joins and native argument/schema builders. This is broad compiler
activation, beyond the three applications used for the initial experiments.

All 508 pre-existing NF function **bodies remain byte-identical**, recorded in
`native-nf-body-continuity01.json`. Twenty-six existing functions receive the
larger force-inline hint. Total forced-inline definitions rise from 468 to 883,
and their combined body bytes from 695,195 to 1,979,376 (2.847 times). Their largest
complete body rises from 4,164 to 8,253 characters, consistent with the
8,192-codepoint body budget plus generated prologue/trailer. Ordinary `INLINE`
workers rise from 40 to 60 and their bodies from 284,501 to 930,112 bytes; the
180,880-byte `p88_build` worker is not forced-inline. This gives Clang more direct
and inline optimization work despite the smaller total C, a plausible image-build
cost tradeoff that must be measured separately. The complete NF body text grows from 979,696
to 2,909,488 characters, while the remainder of emitted C falls from 38,376,751
to 27,171,102 bytes. Eliminated scheduler machinery outweighs added direct code.

`activation-v3.py` makes line lookup linear-preparation/logarithmic-query instead
of rescanning the entire file per function; it audits each full compiler C in
about two seconds offline. Both graphs have zero missing directly named NF
definitions and zero recursive components. This still does not prove dynamic
stack use or whole C correctness. Local-call composition and whole-function
admission overlap: 12,123 slots and 19,215 fewer continuations are observable
counts, not independently additive performance contributions. Native B2 build,
fixed point, conformance and timing remain separate coordinator gates.

## Transitive inline expansion, and a bounded successor

The actual final compiler graph reveals a much larger cost than the earlier
old-image, own-body estimate. Reproducible offline method `typed/inline-dag.py`
and result `native-inline-dag02.json` count repeated named NF calls, ignoring
quoted strings/comments. Expanding only forced-inline callees gives 23.23 MB
summed across final NF bodies versus 2.35 MB for the same-source Phase98 output.
At call sites outside the NF definitions, the corresponding repeated expansion
proxy is **115.12 MB versus 1.38 MB**. These are source-byte proxies, not observed
LLVM IR, machine code or actual compilation work: C optimization can eliminate
branches, and ordinary inlining/runtime helpers are not modeled.

The largest outside contributions are `p98_tag_eq` (608 sites × 38,991 expanded
bytes), `p88_string_eq` (703 × 11,487), `kid` (670 × 10,555) and `f_eq`
(523 × 12,006). Small forwarding bodies inherit large forced callee chains.
This explains why a per-function 8 KiB cap does not control compiler build cost
after broad direct-call admission. It is not evidence that the direct-call
architecture itself is ineffective.

The unused `leaf-inline-source01` is retained as an exact reversible experiment.
It forces only dependency-free NC_Code bodies. Inspection then showed that
`next_mode`, which benefited in the app experiment, calls `plain_mode`, which
calls `plain_mode_flags`; leaf-only and depth-one policies would remove that
hint. No application names are used by either proposed policy.

`depth-inline-source01` instead selects bounded leaves and two caller levels
using exactly three immutable passes over admitted NF_Worker dependency lists.
This retains the existing 8 KiB own-code test and fails closed for missing
dependencies. The list is computed once after observer routing and carried
through prototypes, ordinary bodies, TRMC wrappers and TRMC inner loops; no
recursive emitter recomputes it. Worker dependency lists include late scalar
observer redirects that are not present in the inner NC_Code call metadata.
The source is an exact reversible successor of `trmc-reuse-source02`, adding
13 physical lines. It changes hints only, not admission, ownership or bodies.

The direct-C depth-two simulation estimates 25.62 MB of outside forced
expansion and 601 selected definitions, while retaining `next_mode`. The actual
Bend policy folds a TRMC wrapper and inner loop into one worker, so this C-graph
simulation is not asserted byte-identical to the compiler implementation.
Actual checked API emission, app measurements and bounded native image builds
remain the acceptance tests; generated-C ablations alone do not qualify a
self-hosted compiler.

The checked depth-policy API subsequently emitted all three apps. Their entire
C files are byte-identical to the prior candidate after normalizing only the
leading `NF_INLINE`/`INLINE` tokens on function declarations and definitions.
Forced definitions become 45 from 61 for source-index, 23 from 27 for
image-render and 31 from 44 for dependency-plan; `next_mode` remains forced.
`depth-app-hint-continuity01.json` records these exact output hashes. This
confirms hint-only app behavior at the source level, before runtime timing and
native-image construction are considered.

## Actual bounded-policy self emission

Native chain02 B1 self-emits source `535c1f8f...` to 30,124,590 bytes of C
(`30f1fe5b5649a3f586b4616195edd112ae4db75003a2f32b422a4b94d279611a`).
The actual graph has **610 forced definitions**, exactly the logical generated-C
prototype's choice for every surviving named worker: zero hint mismatches.
There are 941 NF definitions, 47 TRMC helpers, 216 local tail jumps and 12,127
local NF output slots. The old `nf_inline` and its product worker disappear
because the source implementation changed; no other NF worker disappears.

Of 941 surviving bodies, 895 are byte-identical to the unbounded candidate.
The other 46 are exactly equal after a bijective renaming of generated
`v_DIGITS` C identifiers; all strings, comments and other tokens are preserved.
There are 139 renamed identifiers. This is a lexical structural audit, not a
replacement for execution checks. `native-depth-body-continuity01.json` records
the source hashes, body hashes and complete renaming lists.

The reproducible DAG audit in `native-inline-dag03.json` measures 26.556 MB of
outside forced expansion, close to the logical prototype's 26.550 MB and
**76.9% below the unbounded image's 115.116 MB**. Summed expanded NF bodies fall
from 23.231 MB to 7.901 MB. The major previous sources of expansion—tag equality,
string equality and accessors with deep dependencies—are no longer forced
through their whole call chains. Ordinary C inlining remains available. Thus
the generated-C prototype accurately predicted the final Bend policy's hint
behavior on the real compiler, as well as on the three apps.

The new policy does perform extra compiler work. Three passes each revisit
candidate workers, check admitted membership and the own-code budget, and test
dependencies against the previous set. With linear list membership the work
is proportional to three passes of worker/admission-set and dependency/set
comparisons; there is no recursive transitive expansion or cost memoization.
The final set is computed once, never once per recursively emitted function.
A later measured refinement could precompute size/admission eligibility once
before the three passes, without changing the selected hints.

Existing telemetry offers mixed, limited evidence about this cost:

| Observation | Unbounded source | Bounded source |
| --- | ---: | ---: |
| Native B1 self request | 126.295 s | 127.333 s |
| API source-index emission | 3.677 s | 3.956 s |
| API image-render emission | 2.151 s | 2.311 s |
| API dependency-plan emission | 3.158 s | 3.425 s |

The self request is 0.82% longer; the three API emission phases are about
7.4–8.4% longer. These are single observations, not interleaved paired runs,
and self inputs differ by 13 lines/1,022 bytes. Even the unchanged Phase98
reference compiler varies from 149.036 s to 186.930 s on these nearby source
versions. Consequently the receipts do not isolate hint-analysis cost or
justify claiming either zero overhead or a precise regression. They show no
large whole-request increase for the actual B1, while leaving a plausible
emitter-local overhead to investigate only if it matters after qualification.
`native-depth-work-observations01.json` records the original receipt paths.
The guarded B2 construction and execution remain separate coordinator gates.
The coordinator subsequently completed B2 construction: the actual Clang guard
records 377.212 s, successful exit and 2,583,298,048 bytes peak tree RSS
(about 2.41 GiB). This is distinct from wrapper elapsed time and is not a paired
speedup against the earlier 420 s timeout or the historical older-source build.
Construction success alone does not establish B2 fixed point or qualification.

## Residual native profile prepared after qualification

`profile-native.py` reuses the already built generic thread sampler from
`observer-profile01`. It authenticates the actual final B2 build and the
completed cached `map_closed` native control. This is the heaviest request in
the existing six-source short compilation suite (about 1.65 s historically),
so eight isolated captures should provide useful evidence in roughly 10–20 s
without a full self-compilation profile. Actual final-image cost may differ.

Run only after the native chain and qualification queue finish:

```sh
python3 -B selfhost/tools/performance/phase102/profile-native.py --build selfhost/build/phase102/native-chain02/b2.json --request-row selfhost/build/phase102/native-chain02/controls/05-cached-map_closed/b2/report.json --sampler-report selfhost/build/phase102/observer-profile01/report.json --rounds 4 --out selfhost/build/phase102/native-map-profile01
```

There is one global 60 s target budget, a 2 GiB process-tree RSS limit, 16 GiB
available-memory floor and 512 MiB initial disk reserve. Each process uses one
worker on CPU 3, GPU off, and the unchanged qualified request arguments apart
from a fresh output prefix. The compiler ELF is never rebuilt or instrumented.
The sampler is loaded at runtime and affects execution cost, so sampled clocks
are not clean speed measurements.

Every capture requires complete C equality and full clock-stripped diagnostic
equality with the same-image control, empty stdout, normal successful exit,
zero sample loss and overruns, intact thread lifecycle, and at least 95% process
CPU coverage. The pool must contain at least 500 samples. Periods of 8 and
13 ms reduce dependence on one sampling interval. Missing/incomplete/lossy
captures stay failed; the tool does not silently rerun them. The result is
physical leaf attribution across startup, compilation and IO, not phase timing,
allocation counts or recovered inline caller stacks. This command is prepared,
not executed by the offline analysis lane.
