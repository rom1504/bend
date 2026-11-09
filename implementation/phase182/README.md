# Phase182 — upstream 2.0.40 migration

**Upstream2.0.40 is installed across JS B2, public C-emitting native N1 and
QBE N2.** The maintained source and selected artifacts target upstream
`9a4223d577ba56a0cb53d1fd952d2b481c38930f`, replacing
`059266225b77c8ca256ac6b25ee5c21449bab151`. The upstream merge is `6c6365e`;
the compatibility port is `10ab239`. Native and JS self-reproduction and the
stated finite qualification gates and fresh-checkout checks pass. Full JS self-emission uses the explicit
pinned-Bun7MiB stack policy described below. Historical checkouts, binaries and
installation rollback copies are retained. Historical speed scores are not
carried onto changed products.

[Maintained workflow](../../docs/self_hosted/workflow.md) ·
[Build tools](../../selfhost/tools/build/README.md) ·
[Metric definitions](../../docs/self_hosted/METRICS.md).

## Current source and artifact identities

The current assembled source is
[`snapshot08/compiler.bend`](../../selfhost/build/phase182/snapshot08/compiler.bend),
3,179,190 bytes and 8,509 mapped declarations, SHA256
`06dcc91b2df46978607b6dd50707aca3c8ddd59dd1a91fbf71a9e6b0ed61605c`.
API06 independently checks this source against the new upstream before emission.
The earlier native chain and JS self-emission bind snapshot07, 3,179,064 bytes,
SHA256 `f10b51e2e96692e871c6ca2af2a27252a02f4f0f1f499d12b45670a4c550320a`;
their results are not silently rebound to snapshot08.

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| New Base | 87,698 | `ff90fb27ed19d5c7a6165170f28ad81562bf345b9a9e6134e5c2e326beff9de4` |
| [Checked API06, snapshot08](../../selfhost/build/phase182/typed-api06/report.json) | 5,198,207 | `f5634ca05180c6aff6abb979e121012d288e17dea3a4eab58139072f2b76e71d` |
| [QBE API05, snapshot07](../../selfhost/build/phase182/qbe-api05/report.json) | 3,440,082 | `6cec5479551dc35a98f0add12b578bba416b07e7503aaaef2d033b7cb418a893` |
| [Runtime object02](../../selfhost/build/phase182/runtime-build02/report.json) | 125,264 | `67141c4505a0355901d857c4ba81dfc17559329e536818a843ce68615384d13e` |
| [Prepared Base05, P130; snapshot08 binding](../../selfhost/build/phase182/base-carrier05/report.json) | 2,827,018 | `3b1d2d23ac05818fea2ee13442a02b6ef8f57eb6b4b1842851e8900238f539b9` |

Base identity includes its canonical path under
`selfhost/.bootstrap/upstream-phase182/bend2/base.bend`. Moving the same bytes
requires a fresh prepared identity. The runtime object is a new explicit asset,
built with GCC `-O2 -std=gnu11 -ffp-contract=off
-DP144_SINGLE_MUTATOR_RFC=1`; it does not overwrite an older qualified object.

## Corrected native qualification

Snapshot08 now completes [N1/N2/Q3 reproduction](evidence/native-chain04.json) in
528.642s. The two complete native builds take183.857s and183.056s; they reproduce
identical QBE, assembly and object bytes. ELF bytes differ. These are acquisition
observations for the new source, not a same-source speedup comparison.
Actual N2 passes [64/64](evidence/qbe6402.json) and
[all ten new runtime controls](evidence/native-controls04.json), including the
three I/O paths that failed before the seven-name admission fix.
[Early-entry controls](evidence/early-controls01.json) independently preserve
unknown-foreign rejection.

The same N2 passes the [six native session controls](evidence/native-session-bootstrap01.json)
and the [normal session adapter](evidence/native-session-normal01.json).
All six products match their same-mode cold references; a real edit changes the
product, no-op requests exercise reuse, and the generated programs print `3` and
`5`. These are finite reuse controls, not a general invalidation theorem.
The separate current-source hosted QBE API preserves all 23 installed exports and
passes [19/19 focused controls](evidence/qbe-hosted19.json). The current hosted C
lane also passes [ten new-language controls](evidence/c-current01.json).

The [public C package](evidence/cli-package01.json) completes construction in
444.860s from the public profile of snapshot08, retaining unmodified generated C.
Its 24,097,056-byte executable has SHA256
`9cdee58d7423be70fe120ddaa0eac3675674292d2a0832447907051d4cc9e607`.
Construction itself is unqualified; the subsequent independent gates pass
[16 focused cases](evidence/cli-focused01.json),
[ten current-language cases](evidence/cli-current01.json) and
[15 CLI interface controls](evidence/cli-controls01.json). The interface gate
executes the identical image from a relocated package, checks two independent
complete-output oracles, exact live/cache product equality and refusal controls,
and records `qualified:true`, `installed:false`. It does not claim incumbent
product-byte equality, universal conformance or performance parity.

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

Snapshot08 changes exactly one declaration relative to snapshot07:
`no_effect_foreign_allowed` admits seven additional supported providers:
`IO.args_bytes`, `File.open_bytes`, `File.read_line`, `File.read_bytes`,
`File.read_at`, `File.write_bytes` and `File.write_at`. The existing
`trusted && filled` conditions remain. This corrects an early source-admission
omission; runtime files, primitive IDs and verifier conditions are unchanged.

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

Native-controls01/02 use QBE-generated executables from a JS-hosted checked B1.
The later [native-controls03](../../selfhost/build/phase182/native-controls03/report.json)
runs the actual snapshot07 native N2 compiler: seven of ten cases pass, including
numeric, both arrays, Char output and valid Exit/Halt statuses. `argv`, `files`
and `open-errors` are refused before executable construction with
`early scalar source permission refused`. Snapshot08's seven-name admission
change addresses that omission; [native-controls04](evidence/native-controls04.json)
now passes all ten on actual snapshot08 N2. These native controls use one worker
with GPU off; the separate C gates above supply their own evidence.

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

[Base preparation05](../../selfhost/build/phase182/base-prepare05/report.json),
[carrier05](../../selfhost/build/phase182/base-carrier05/report.json) and
[verification05](../../selfhost/build/phase182/base-verify05/report.json) all
complete for snapshot08/API06. The graph has 51,566 nodes and 945 strings. Verification compares every
prepared root and source identity across frame, fresh `p86_prepare`, P88 and P130
`p88_cache_prepare`; both decoded canonical products are 1,277,476 bytes with
SHA256 `f2e12bd3eb34a338d99868742907e13d5b25c5a6dacb5fd77bb62364a4afe612`.
Term ABI1, span ABI3, world version3, source interval 1..87700, aliases and readiness
are checked explicitly. Native admission and actual request qualification remain
separate gates.

Earlier [Base03](../../selfhost/build/phase182/base-verify03/report.json) and
[Base04](../../selfhost/build/phase182/base-verify04/report.json) retain their
snapshot06/API04 and snapshot07/API05 bindings. Each source/API update receives
a fresh receipt; unchanged graph values do not permit relabeling an old carrier.
Base05 preparation took 13.181s and hosted full-value verification 12.905s.
These are setup/validation clocks, not compiler latency improvements.
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

## Full-image acquisition boundary

The first hosted full-image attempt, [native-chain02](../../selfhost/build/phase182/native-chain02-guard/process.json), stopped at the4GiB process-tree limit after360.076s before emitting QBE. No native image or fixed-point result was produced. This is retained resource evidence, not a source rejection. The whole-process peak was4.005GiB with19.75GiB available memory remaining; the guard prevented an unbounded run.

A native-only bridge is prepared by [native-bridge.py](../../selfhost/tests/phase182/native-bridge.py).
It authenticates retained Phase175 N2 and ABI11101 runtime, keeps the new
Base/prepared carrier, and changes only the transitional compiler's `main`
argument handling. Other canonical source bytes stay exact, including the
ABI11102 emitter. Independent
[bridge source acceptance](../../selfhost/build/phase182/native-bridge-check01/report.json)
and [N0 construction](../../selfhost/build/phase182/native-bridge-n001/report.json)
pass; construction takes 184.975s. This N0 remains linked to its old runtime and
uses legacy arguments. It is a transition tool, not an installed candidate.

[Native-chain03](../../selfhost/build/phase182/native-chain03/report.json) completes
N0 → N1 → N2 → Q3 on canonical snapshot07 in 536.379s. The emitted QBE reaches
an exact fixed point; N1/N2 assembly and objects also match. Whole ELF files
differ, and that raw mismatch remains recorded. The actual N2 then passes all
64 independent complete-output cases in
[qbe6401](../../selfhost/build/phase182/qbe6401/report.json), with zero failures or
unsupported cases. That is finite single-worker QBE qualification, separate from
the seven-of-ten new IO/intrinsic controls above. Neither receipt installs the
compiler. The later snapshot08 [native-chain04](evidence/native-chain04.json)
and [qbe6402](evidence/qbe6402.json) establish the corrected source's separate
reproduction and 64-case result described above.

JS self-emission attempt [js-b201](../../selfhost/build/phase182/js-b201-guard/process.json) reached emitted reachability but stopped at the300s deadline, with a2461MiB peak. The initial bound was too short relative to the historical319.747s Phase174 B2 acquisition. This is a retained interrupted attempt, not a pass or evidence of incorrect generated JavaScript.

[JS-b202](../../selfhost/build/phase182/js-b202/report.json) subsequently completes
snapshot07 B2 self-emission in 363.153s, producing a 4,993,341-byte API, SHA256
`640eb6ec8d872a7f3042d79df22e2696d023bff798c7a783264e58c398f59da5`.
It inherits the exact upstream source-check authority; `freshSelfCheck:false`
does not claim another full check during that emission. Its source binding remains
snapshot07.

The later [JS-b203](evidence/js-b203.json) completes snapshot08 B2 self-emission
in 367.500s, producing a 4,993,656-byte API, SHA256
`9c90beef94e6cc4b3d892c0d0b6b9aaa581b96b8ef9fdee592cf6c5d55ba5730`.
It inherits API06's exact source-check authority and records `freshSelfCheck:false`.
The subsequent [JS-b301 attempt](evidence/js-b301.json) freshly checks that same
complete source successfully (`typeAccepted:true`; 107.599s for the check), but
fails after 347.317s overall. Its [stage receipt](evidence/js-b301-progress.jsonl)
records a stack overflow during `public-library-emission`; the error stack repeats
`$jd$index_95_remove$scc` in the B2 image. No B3 image or complete B2/B3 equality is
established. The [bounded-stack retry](evidence/js-b302.json) subsequently passes in351.802s,
including fresh own-source checking and complete B2/B3 byte equality. The same
source and B2 image are used under an explicit pinned-Bun7MiB stack policy.
See [the diagnostic and limits](js-stack.md). This is not a compiler speedup or
an arbitrary-depth stack-safety result. The selected B2 independently passes
[JS18](evidence/js-focused01.json) and [C18](evidence/js-c-focused01.json) at the
default host stack.

## Profiler compatibility controls

The RTS-aware instrumentation preparation reverses exactly to the original
runtime and the instrumented object builds successfully. Both
[normal](../../selfhost/build/phase182/profiler-rts-controls01/normal/report.json)
and [drop](../../selfhost/build/phase182/profiler-rts-controls01/drop/report.json)
controls pass with counters off and on: disabled counters emit zero rows;
enabled counters match every expected per-function row and preserve output.
The drop control positively exercises one iterative drop traversal of two uniquely
owned Tuple cells. This validates the bounded instrumentation hooks and current
invocation contract, not all shared-reference paths, logical ancestry attribution,
profiler overhead or a new compiler-performance profile.

## Five metrics and remaining work

| Metric | Phase182 status at this checkpoint |
| --- | --- |
| Compiled-program speed | No fresh performance or parity claim. Finite output/ABI controls pass in the stated lanes; changed runtimes invalidate automatic inheritance of historical timings. |
| B1 compilation speed | Checked API06 exists; its 14.455s acquisition is a build/setup observation, not a balanced compiler-request benchmark. |
| B2 compilation speed | Snapshot08 JS B2 exists after 367.500s self-emission. B3 freshly checks its own source and reproduces B2 at the recorded7MiB host cap; clean request benchmarks remain unmeasured. Native reproduction has its own generation/target boundary. |
| Conformance | Snapshot07 passes the 23-case frontend gate. Snapshot08 passes native QBE 64/64, current runtime 10/10 and six session controls; the separate hosted QBE 19/19 and public C 16/16, 10/10 and CLI gates pass. These remain finite gates, not full conformance. |
| Simplicity | Maintained recipe contains 218 Bend modules and five entry profiles. At this checkpoint those module files total 3,179,190 bytes/68,619 physical lines; runtime/host tools and generated assembled images are separate counts. Snapshot08 adds seven allowed names in one declaration; no simplicity reduction is claimed. |

Snapshot08 native and JS reproduction, the stated backend/CLI gates and audited
release installation are complete. Earlier source bindings, failed attempts and
finite backend scopes remain explicit. Fresh-checkout verification passes separately from promotion (below).

QBE still supports one Bend heap mutator, one CPU worker and GPU off, with its
pinned provider table rather than arbitrary C embedding/callbacks. C GPU/device
paths, display/network/subprocess coverage and parallel execution are not qualified
here. Window.fullscreen remains explicitly unsupported in the relevant native
path. Direct JS retains the unresolved extreme-depth multiword Array.new layout
limit. Historical experimental x86 results are not requalified by this migration.

All executed evidence belongs to the root-owned guarded lane. Failure/resource
receipts are retained. Each completed guarded run has a retention receipt. No billing estimate or new
performance ratio is inferred from this migration.


## Publication

The [preparation receipt](evidence/release-preparation.json) binds the exact
completed gates. The unchanged release auditor admits them, and the
[installation transaction](evidence/release-install.json) preserves rollback
copies before publishing the current selector. All three operational maps
(native, session and C requests) were then published and every advertised pin
verified. [Installed verification](evidence/installed-verification.json) confirms
the maintained source and actual installed identities.

The [seven public JS controls](evidence/js-public02.json) run unchanged CLI code
from an exact [staged package](evidence/js-cli-stage01.json), using its default
provider selection and an explicitly test-only JS selector. This avoids touching
the installed selector before qualification. The initial direct attempt correctly
refused the old selector's stale runtime pin; [that failure](evidence/js-public01.json)
is retained. The staged selector is not an installable whole-compiler release;
actual publication uses the independent three-component release audit above.

Current C GPU/device, arbitrary QBE foreign providers, multiple heap mutators,
and the experimental assembly backend remain outside this migration's scope.
The public native `--version` text retains its old implementation banner; use the
current selector and upstream pin for authoritative release identity.

The [ordinary installed live QBE request](evidence/publication-live01.json) matches
the qualified cache-mode QBE product exactly and executes its independent stdout
oracle. This validates ordinary live preparation through the new default assets;
it is distinct from the native session's cold-reference comparisons.


## Fresh checkout and campaign closure

The [fresh sparse-worktree gate](evidence/fresh-worktree02.json) passes at release
commit `a8ab5ed`: maintained source reassembly, current selector, selected assets,
JS execution, public native C emission/build/execution and ordinary live QBE
build/execution all succeed. Each executable prints `42`. The gate takes16.979s
and explicitly copies137,503,214 bytes of pinned artifacts; it retains external
Base and machine-tool identities. It is a finite relocation check, not a standalone
source bootstrap or broad conformance result.

The first checkout omitted `selfhost/tests/compiler` and `selfhost/tests/phase149`,
which the canonical manifest includes. Its [failure](evidence/fresh-worktree01-failed.json)
is retained. The corrected [checkout command](evidence/fresh-worktree02.sh)
includes those directories. Both worktrees are retained explicitly; the failed
closure was sealed keeping the tree, because the public `selfhost/bend` symlink
is not suitable for the archive inventory's regular-file-only policy.

The final [guard accounting](evidence/guarded-costs.json) covers 102 completed
resource-guard jobs: 78 succeeded and24 failed, with 99.5 minutes summed inside
the guarded lane. This includes failed acquisition and diagnostic attempts;
it excludes agent reasoning, metadata work and network/setup time. It is not
an estimate of total research cost or consumed model quota.

All requested migration and publication work is complete. Remaining performance,
stack-safety and broad language/backend coverage limitations are listed above;
no old benchmark score is presented as a measurement of the new release.
