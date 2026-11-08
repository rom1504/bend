# Phase182 — upstream 2.0.40 migration

**Migration in progress; full bootstrap chains and release qualification are
pending.** The maintained source now targets upstream
`9a4223d577ba56a0cb53d1fd952d2b481c38930f`, replacing the previous active pin
`059266225b77c8ca256ac6b25ee5c21449bab151`. The upstream merge is `6c6365e`; the checked compatibility port is `10ab239`.
Historical checkouts, ABI11101 images/runtime objects and the installed selection
remain available. This report records completed migration gates; it does not
promote the candidate or carry old performance results onto changed products.

[Maintained workflow](../../docs/self_hosted/workflow.md) ·
[Build tools](../../selfhost/tools/build/README.md) ·
[Metric definitions](../../docs/self_hosted/METRICS.md).

## Current source and artifact identities

The current assembled source is
[`snapshot07/compiler.bend`](../../selfhost/build/phase182/snapshot07/compiler.bend),
3,179,064 bytes and 8,509 mapped declarations, SHA256
`f10b51e2e96692e871c6ca2af2a27252a02f4f0f1f499d12b45670a4c550320a`.
Both current APIs were independently checked against the new upstream before
emission; they are upstream-built **B1**, not self-emitted B2.

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| New Base | 87,698 | `ff90fb27ed19d5c7a6165170f28ad81562bf345b9a9e6134e5c2e326beff9de4` |
| [Typed API05](../../selfhost/build/phase182/typed-api05/report.json) | 3,370,049 | `f6c39365b663143bad18c7e7e9dea7fa10eab2b7c580e86004b391536b427084` |
| [QBE API05](../../selfhost/build/phase182/qbe-api05/report.json) | 3,440,082 | `6cec5479551dc35a98f0add12b578bba416b07e7503aaaef2d033b7cb418a893` |
| [Runtime object02](../../selfhost/build/phase182/runtime-build02/report.json) | 125,264 | `67141c4505a0355901d857c4ba81dfc17559329e536818a843ce68615384d13e` |
| [Prepared Base04, P130; snapshot07 binding](../../selfhost/build/phase182/base-carrier04/report.json) | 2,827,018 | `fe48f505b53ba4596040f2395d5727858784ea32489222c7141b6523d923e38a` |

Base identity includes its canonical path under
`selfhost/.bootstrap/upstream-phase182/bend2/base.bend`. Moving the same bytes
requires a fresh prepared identity. The runtime object is a new explicit asset,
built with GCC `-O2 -std=gnu11 -ffp-contract=off
-DP144_SINGLE_MUTATOR_RFC=1`; it does not overwrite an older qualified object.

## Compatibility changes

The frontend now distinguishes declaration and constructor namespaces according
to syntax. Generated sugar resolves the current module's own declaration or
constructor before Base, independently of import aliases. Dependent lets avoid
a redundant kind check except when a safe reusable binding requires Data.
Unicode escapes accept the new full-U32 Char domain. The
[namespace fixtures](../../selfhost/tests/phase182/namespaces/README.md) describe
the exact obligations and upstream changes.

Equality sharing now keeps an equivalence-class relation separate from evaluation
values. Joining equal cells changes neither their values nor their identities;
only completed EQ obligations publish a join, while directional LE success
does not. The persistent parent/rank representation avoids redirecting a value
through a representative and creating a value cycle. Our relation remains scoped
to one `norm_convert`; this does not reproduce upstream's cache lifetime across
separate comparisons. See the
[sharing invariants](../../selfhost/tests/phase182/sharing/README.md).

Snapshot07 also fixes a narrow reflexivity-check path: expose an equality goal
and compare its endpoints within the same private graph instead of expanding raw
let values before comparison. Both rigid and full-book attempts start from the
same immutable input state. The successful result retains the original goal;
heap-local cells do not escape into checking results. The old diagnostic path
remains on failure, and no protected declaration is changed by this fix.

The direct JavaScript runtime and pinned effect providers adopt Number-valued Nat
host conversion, packed full-U32 Char transport with scalar replacement at text
boundaries, F32 conversion/parsing behavior, qualified constructor/effect names,
export hygiene, tail-call/effect entry behavior and current RTS arguments.
The [paired ABI controls](../../selfhost/tests/phase182/js/README.md) distinguish
library values, foreign execution and direct runtime checks. The legacy
descriptor JS runtime is not qualified against the new upstream by these gates.

Native C and QBE retain their existing heap/ownership implementation while porting
the Base-facing behavior: argv[0], `+RTS`/`-RTS`/`--RTS` and `BENDRTS`, quiet Exit,
Unicode output replacement, F32 text termination, byte argv/path, line reads and
positioned writes. Exit/Halt reject codes above 255 before host conversion; valid
packed Exit payloads use the appropriate representation. Runtime review and
executed valid-status controls remain separate from failure-runtime testing.

QBE's semantic ABI is **11102**. Primitive 86 implements full-width
`F32.from_nat`; IDs 1–85 retain their meanings and descriptor/state layouts stay
unchanged. `Array.get_unchecked` is admitted through the existing native guard
and canonicalized to `array_get`, reusing its arity, ownership, layout checks and
QBE opcode 72. It retains Array.get's wrapping implementation and is correct for
the unchecked API's documented in-bounds calls; no unchecked-address optimization
is claimed. Ordinary `popcount`/`ctz` definitions remain ordinary definitions.

Tooling records the runtime argument convention per actual image/provider.
Old executables keep legacy invocation; new runtime products use RTS framing and
include argv[0]. The C public wrapper has an explicit runtime-convention switch.
Maintained entry mains consume the new argv[0] convention. Bootstrap selection
is explicit manifest data, so old reference checkouts and runtime bindings are
not silently reinterpreted as current ones.

## Completed gates and their limits

| Evidence | Completed observation | Boundary |
| --- | --- | --- |
| [Source-check05](../../selfhost/build/phase182/source-check05/report.json) | Snapshot04 accepted with zero unresolved holes. | Earlier source; not relabeled as snapshot06. |
| [Typed API04](../../selfhost/build/phase182/typed-api04/report.json), [QBE API04](../../selfhost/build/phase182/qbe-api04/report.json) | Snapshot06 checked and both APIs emitted successfully. | Source/API acquisition, not a bootstrap or compiler theorem. |
| [Typed API05](../../selfhost/build/phase182/typed-api05/report.json), [QBE API05](../../selfhost/build/phase182/qbe-api05/report.json) | Snapshot07 checked and both APIs emitted successfully. | New reflexivity fix; earlier gate receipts retain their original source bindings. |
| [Sharing-values01](../../selfhost/build/phase182/sharing-values01/report.json) | All 22 finite complete-value observations pass, including retained heaps, class relations and EQ/LE controls. | Finite source-level controls, not a general normalization theorem. |
| [JS runtime02 guard](../../selfhost/build/phase182/js-runtime02-guard/process.json) | Direct runtime controls exit 0. | Isolated finite runtime checks. |
| [JS-paired04](../../selfhost/build/phase182/js-paired04/report.json) | All seven stages pass: four independent compilations, library comparison and both foreign executions. | Snapshot06/API04 direct JS; no broad performance campaign. |
| [Native-preflight03](../../selfhost/build/phase182/native-preflight03/report.json) | All 10 current top-level native fixtures accepted by unchanged upstream, each with zero holes. | No emitted-code, runtime-output or kernel claim. |
| [Native-controls01](../../selfhost/build/phase182/native-controls01/report.json) | Seven of nine cases pass: Char/F32 output, argv/bytes, files, open errors, Exit 23, Exit 255 and Halt 7. | Earlier source/API; overall receipt is incomplete because two cases failed. |
| [Native-controls02](../../selfhost/build/phase182/native-controls02/report.json) | All three follow-up cases pass: numeric, scalar unchecked read 98, boxed unchecked read `"rightleft"`. | Snapshot06/API04 emits QBE, then machine products execute; this is not a rerun of all ten on every backend. |
| [Frontend-threeway03](../../selfhost/build/phase182/frontend-threeway03/report.json) | The previously resource-limited three-way sharing case passes independently against upstream with the narrow graph fix. | One selected case only; `fullCorpusPass:false`. |
| [Proof-algebra03](../../selfhost/build/phase182/proof-algebra03/report.json) | All 23 named algebra laws elaborate and pass the current Lean 4.34/BendTT kernel; an unequal-label control is rejected. | Standalone source closure, `sourceBinding:null`; neither whole-compiler correctness nor native ownership is proved. |

The JS foreign programs agree exactly on `42`, `65533`, `1065353217`, `9`.
Library controls compare independently emitted functions, host conversion,
aggregate/constructor interchange and qualified exports; mere compilation does
not stand in for this comparison.

The native controls use one worker with GPU off. They are QBE-generated
executables from a JS-hosted checked B1 compiler. They do not establish that a
new native compiler generation executes the same requests correctly, nor do
they constitute emitted-C backend qualification.

The earlier broader frontend gate was incomplete. `frontend02` records 21 matching
observations before its 2 GiB process-tree guard stops the candidate during
`conversion_shared_cells_three_way`. `frontend-last-two02`, using API04, reaches
the 4 GiB guard on that case before completing a row. The separate
[`frontend-once01`](../../selfhost/build/phase182/frontend-once01/report.json)
passes its one selected case. These cannot be combined into a completed 23-case
corpus.

The later [frontend-threeway03](../../selfhost/build/phase182/frontend-threeway03/report.json)
resolves that focused resource failure. Both compilers accept the case; the entire
paired guarded job takes 12.321s and peaks at 417.6 MiB process-tree RSS. The retained
candidate observation is 8.354s; upstream is 0.431s under its distinct worker
boundary. These are one-case correctness/resource observations, not a balanced
compiler-throughput gain. The fresh [frontend03](../../selfhost/build/phase182/frontend03/report.json) now completes all 23 comparisons with no mismatch; `fullCorpusPass:true`. This is a finite frontend gate, not full upstream conformance.

## Fresh prepared Base

The maintained producer and offline serializer restore prepared development mode
without importing retired compiler snapshots. `base-prepare.mjs` runs current
Bend loading/checking/preparation with a fresh private cache directory and optional
annotations disabled. `base-carrier.mjs` authenticates frame/API/Base/path and
transports its complete graph into P88 and P130. The P130 transcode proves exact
inverse byte identity; hashes are provenance bindings, not semantic proofs.

[Base preparation03](../../selfhost/build/phase182/base-prepare03/report.json),
[carrier03](../../selfhost/build/phase182/base-carrier03/report.json) and
[verification03](../../selfhost/build/phase182/base-verify03/report.json) all
complete for snapshot06/API04. The graph has 51,566 nodes and 945 strings. Verification compares every
prepared root and source identity across frame, fresh `p86_prepare`, P88 and P130
`p88_cache_prepare`; both decoded canonical products are 1,277,476 bytes with
SHA256 `f2e12bd3eb34a338d99868742907e13d5b25c5a6dacb5fd77bb62364a4afe612`.
Term ABI1, span ABI3, world version3, source interval 1..87700, aliases and readiness
are checked explicitly. Native admission and actual request qualification remain
separate gates.

Snapshot07/API05 requires a fresh producer/cache binding; Base03 is not relabeled
as its prepared artifact. The fresh [Base04](../../selfhost/build/phase182/base-verify04/report.json) completes that binding and repeats complete-value equality for snapshot07/API05. Preparation takes13.164s and verification12.695s; node/string counts and the complete graph remain unchanged.

Preparation took 13.116s and hosted full-value verification 12.290s in these
observations. These are setup/validation clocks, not compiler latency improvements.
The producer keeps every write under its fresh guard roots and never falls back
to an older frame. The [build-tool guide](../../selfhost/tools/build/README.md#prepare-a-new-base-carrier)
records the three commands and historical transport provenance.

## Retained failures and corrections

- Source-check01/02 named a missing snapshot01 file; source-check03 exposed an
  unsupported term-position match in the proposed port. Later source checks and
  checked API acquisition retain separate fresh receipts.
- JS-paired01 exposed both an invalid compound type fixture and the missing
  full-U32 escape support. JS-paired02 correctly rejected a Type-valued pair where
  Array.new requires Data. JS-paired03 found a real constructor-tag mismatch:
  imported `Box` was emitted as `namespace.Box`. JS-paired04 supplies the
  completed corrected gate. Earlier failures remain visible rather than being
  counted as passes.
- The first isolated JS runtime fixture incorrectly expected F32 inputs `1.`
  and `1.e2` to be refused; the pinned grammar accepts both. Runtime02 passes the
  corrected assertions and retains rejection checks for trailing/non-ASCII space.
- Numeric-qbe01/02 used oversized Nat literal tokens and unsupported prefix-minus
  syntax. The [rejected fixtures and correction](../../selfhost/tests/phase182/native/numeric-compatibility.md)
  preserve the exact attempts. Native-controls01 then exposed a golden-format
  error (`True` versus the actual `True{}` rendering), corrected before controls02.
- Native-controls01 found a real Array.get_unchecked compilation gap: its ordinary
  generic body reached an open element layout. The shared native alias and
  call-site layout guard fix this; controls02 executes scalar and boxed cases.
- Runtime-build01 is superseded after reviewed Halt/Exit payload/range and RTS
  bounds fixes. Its original successful construction receipt remains intact;
  runtime-build02 is the current object. Construction alone is not qualification.
- Proof-algebra01 used an old Bool.or-based law against the new List.any.if;
  proof-algebra02 consumed an affine head more than once. Both failures precede
  the completed updated proof closure in03.
  Current kernel acceptance and the negative control are the proof evidence;
  an accepted compiler source is not substituted for them.

## Five metrics and remaining work

| Metric | Phase182 status at this checkpoint |
| --- | --- |
| Compiled-program speed | No fresh performance or parity claim. Finite output/ABI controls pass in the stated lanes; changed runtimes invalidate automatic inheritance of historical timings. |
| B1 compilation speed | Checked current APIs exist. API05 acquisition times 11.669s/13.893s are build/setup observations, not a balanced compiler-request benchmark. |
| B2 compilation speed | Pending genuine self-emitted generation and its independently identified requests. B1 timings do not stand in for B2. |
| Conformance | Completed focused source, sharing, JS, native and algebra gates above; the three-way resource failure is fixed, the full23 frontend corpus also passes, while integration remains pending. |
| Simplicity | Maintained recipe contains 218 Bend modules and five entry profiles. At this checkpoint those module files total 3,179,064 bytes/68,619 physical lines; runtime/host tools and generated assembled images are separate counts. No simplicity reduction is claimed. |

Full native generation/reproduction, JS/C self-emission chains, current-source
integration qualification, public CLI execution and any release promotion remain
pending. Root will append their exact receipts and outcomes; no pending chain is
implicitly marked complete by source acceptance or prepared-Base equality.

QBE still supports one Bend heap mutator, one CPU worker and GPU off, with its
pinned provider table rather than arbitrary C embedding/callbacks. C GPU/device
paths, display/network/subprocess coverage and parallel execution are not qualified
here. Window.fullscreen remains explicitly unsupported in the relevant native
path. Direct JS retains the unresolved extreme-depth multiword Array.new layout
limit. Historical experimental x86 results are not requalified by this migration.

All executed evidence belongs to the root-owned guarded lane. Failure/resource
receipts are retained. Final chain accounting, retention sealing and publication
are still pending; no total research cost, billing estimate or new performance
ratio is inferred from this checkpoint.
