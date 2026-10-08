# Phase66 backend migration

The backend lane implements the namespace, external ABI and layout migration
from `0187512` to `0592662`. The compiler algorithms remain in Bend. The
checked 07 snapshot includes the native blocking-ABI repair and the direct
quantity-meet/wide-record fixes. Its five focused source executions and 18
analysis controls pass. The final selected-07 native receipt explicitly admits
the retained native16/source19/syscall7 evidence through unchanged executable
closures and shared-entry checks, plus fresh native3 and an exact diagnostic
replay. Older observations retain their original image identities.
The [native effects guide](../../selfhost/docs/native-effects.md) lists thirteen
new native APIs that remain explicitly unsupported. Release readiness remains
owned by the [combined Phase66 gate index](README.md).

The chronological checkpoints below preserve their original status; later
closures supersede earlier pending statements without erasing failed attempts.

The exact patch inventory, before/after identities, rationale and controls
are in [the backend candidate ledger](../../selfhost/tools/performance/phase66/backend/README.md).
Namespace v1 contains 18 files and was independently reviewed. The first
combined checked build found one parser restriction in its native foreign
namespace fallback; v2 fixes it with an explicit helper argument. No
semantic result is inferred from that failed build.

The central contract is raw internal `namespace:member` identities with
first-colon dotted conversion only at external boundaries. Direct generated
function IDs, native CID/FID identities, graph facts and lookup keys retain
the original names. Readback now matches the selected upstream mixed show
descriptor; IO.OP defaults fail-stop on actual foreign request tags;
normalized equality types are admitted as Array elements without moving
normalization onto previously erased paths.

The separate legacy Node effect candidate updates channel, EOF, Poll and
send-error result shapes. Its four new timed sends explicitly refuse,
because Node cannot cancel queued bytes without risking duplication. An
asynchronous TCP write error cannot recover the exact new-ABI remainder
and is likewise explicitly refused; the ordinary success and preflight
error cases are retained. These limitations are separate from the primary
direct backend, which uses the new pinned providers and runtime. Legacy runtime
controls passed 34/34, followed by the fresh deep-Array fixture and fifteen
wider source controls recorded below.

No compilation-speed, generated-program-speed, conformance-total or size
claim is made by this checkpoint. Those require the selected combined
source, installed image and same-campaign measurements.

Independent review of the legacy candidate found and fixed two timer issues
(expired waiters after busy work, and Node's large-timeout overflow) and the
need for `allowHalfOpen` on both TCP constructors. Source review now passes
legacy v3. Its final controller v4 includes 34 cases, three using real local
TCP/UDP sockets; it does not assume that a TCP read fills its requested
buffer. At this source-review checkpoint the controls had not run; the executed
results are recorded below.

## Executed runtime controls

Root executed `legacy-effects-controls-v4.mjs` against the exact v3 runtime:
**34/34 passed**, including three real local socket tests. The receipt is
`selfhost/build/phase66/legacy-effects-controls01/report.json`. It separates
mocked-network runtime checks from real TCP accepted/client half-close and
UDP binary loopback checks. Root then applied the exact legacy v3 patch.
This is runtime qualification, not yet compiled-source qualification.

A second namespace boundary was found during source audit: printability's
recursion seen set used `kp_show`, so imported `child:Box` and root
`child.Box` could collide and hide an unprintable nested function. The
independently reviewed `printable-key-v1.patch` changes only the two seen
keys to structural `term_key`; user diagnostics keep their display spelling.
Root applied it. Its real imported-source witness and the source execution
recipes await the next combined checked image.

`prepare-source-controls-v1.py` creates guarded recipes from a pinned
checked attempt. It uses the existing conformance judge and adapters, with
an explicit direct-backend adapter change for the primary lane: the ordinary
historical `js` adapter otherwise selects legacy JS. The new upstream pin,
Base bytes, compiler image, snapshot and every derived adapter are explicit.
The legacy catalog records the new timed-send refusal separately, rather
than treating that positive upstream fixture as a passing legacy case.

The actual checked `checked-b1-03` image has now been bound into source
recipes under `backend-source-controls03-recipe`,
`legacy-source-controls03-recipe`, and `backend-native-controls03-recipe`.
They select the current reference, explicit backend lanes and the imported
printability witness. Recipe generation verifies the current ADT own-kind
trust traversal as well as the display-name update; it rejects an older
adapter silently substituted into the new reference lane. Target execution
remains root-owned and is not yet summarized here.

## Actual source checkpoint and legacy Array gap

The 18-case source campaign (17 pinned upstream fixtures plus the imported
printability witness) closed with **18/18 upstream reference passes,
18/18 direct JS passes, and 17/18 legacy JS passes**. The legacy failure is
kept as a failure: `marshal_array_depth` reported `invalid Node at depth 0`.

The new fixture uses explicit `ALeaf` constructors before any Array primitive
has materialized their optional internal array cache. The legacy host
converter inspected that cache alone, so it sent a tagged constructor where
the foreign function expected a JavaScript array. The frozen pre-migration
runtime has exactly that guard, and the fixture is absent from the old pin.
This is evidence of an existing coverage gap exposed by a new test, rather
than a namespace or timing regression; no old-image execution is claimed.
The bound source evidence is in
[evidence/backend-array-classification.json](evidence/backend-array-classification.json).

The isolated `legacy-array-v1` repair uses the already checked Array type
descriptor to call the existing normalization helper. It changes one
condition, leaves unrelated same-named constructors generic, and keeps the
iterative marshalling queue. A source replay controller pins the actual
failed emitted module and changes only that runtime condition; its result
and final checked-image qualification are pending.

## Array repair qualification checkpoint

Root ran the isolated Array controller: **6/6 passed**, including replay of
the actual 20,000-depth source module with only the proposed runtime
condition changed. Root then applied the exact two-file fragment/assembled
runtime patch. The checked `checked-b1-04` image preserves the exact B1 API
hash from 03 (`1ed7decc…3094`), and its selected legacy runtime now has hash
`913b6a85…fc54`.

Fresh 04 recipes are prepared for an optional one-case actual source rebuild
(`backend-legacy-depth04-recipe`), all 18 backend source controls, the 15
retained wider legacy cases, and native/reference source controls. The
one-case recipe closes the specific failure without requiring all 18
repeated observations first. It is still pending execution at this
checkpoint; the six runtime/replay passes alone do not close the release
source gate.

The six private-ending controls have a separate frozen helper closure.
That helper is absent from the checked image snapshot, so the recipe does
not imply it participated in B1 generation; only its explicit source and
Node identities are associated with the 04 checkpoint.

## Native toolchain checkpoint

The first 04 native/reference attempt closed 16 observations in each role:
three expected negative cases passed, while 13 positive cases were marked
unsupported because the guarded process could not locate Clang. These are
retained unsupported observations, not native passes or compiler failures.

`prepare-native-toolchain-v1.py` creates a fresh successor recipe that uses
the exact Clang 16 binary and library environment already qualified in the
Phase65 `final-state10/release/legacy42` receipt. The resolver variable is
`CC`, not `BEND_CC`; all four toolchain environment assignments are inside
the existing guard. The producer pins the compiler and its LLVM/Clang shared
libraries without executing them, preserves the same 04 source snapshots
and selectors, and writes new output destinations. The recipe is
`selfhost/build/phase66/backend-native-controls04-clang01-recipe/recipe.json`
(SHA256 `c9ee8b4fe2358198fee3cd6e5c5a163a7b525ddc17b41c26d7b45c863586c150`).
Its target results remain pending at this checkpoint.

## Native foreign-C ABI checkpoint

With the explicit Clang toolchain, the reference passed **16/16** and Bend
passed **14/16**. Both Bend failures stopped during C compilation, before
program execution. The imported-nullary source now calls `io_eff(cid, run)`;
the old fixture supplied the third `need=0` argument required by our retained
native runtime. This is a missing current-upstream ABI migration. The deep
Array fixture additionally calls `term_peek(Corpus, term)` and `blk_loc`;
those helpers already existed upstream at the old pin, while our runtime
retained `term_peek(Env, term)` and no public `blk_loc`. That part is an older
foreign-helper coverage gap exposed by the newly added deep fixture.

The isolated `native-abi-v1` candidate inserts 19 host-only compatibility
lines immediately before foreign request sources. It preserves both
registration arities and both heap-helper inputs. New two-argument effects
use immediate dispatch (`need=0`); existing readiness/timer registrations
keep their third argument. Memory helpers use the unchanged redirect-cell
and acquire behavior of the retained runtime. Device/runtime code before
this boundary and all Bend compiler code are unchanged.

A guarded replay recipe binds the two failed C artifacts and inserts only
that exact shim, then compiles and runs them against their original stdout,
stderr and exit-code oracles. Its result is pending. Even a replay pass is
separate from a fresh source-emission qualification with the selected runtime.

## Follow-up closures and native blocking migration

The fresh 04 legacy source rebuild of `marshal_array_depth` passed with
`ok`, exit zero. This closes its actual-source failure separately from the
six earlier runtime/replay controls. The wider legacy selection also passed
15/15 selected observations (14 runtime successes and one expected checker
rejection); its deliberately excluded new timed-send fixture remains a
recorded limitation. All six private-ending controls passed under their
separately pinned helper closure.

The native ABI replay passed both programs in 3.42 seconds, with exact
expected outputs. This qualifies the shim on those emitted artifacts;
fresh native source qualification remains a separate gate.

The retained native release checks did not cover ordinary network/channel
ABI changes: `native3` exercised word arithmetic, float arithmetic and an
Array map loop. The ordinary/relocated release fixtures exercised U32,
user closure application and compact Nat. Their passes cannot establish
current Base I/O compatibility.

Source inspection identified six changed ordinary functions in four
families: `Chan.send` must return `Done{Unit}`/`Fail{originalValue}`;
`TCP.recv` and `TCP.recv_bytes` must distinguish `Some{data}` from EOF
`None`; `TCP.send`, `TCP.send_bytes` and `UDP.send_to` failures must return
unsent data. `UDP.recv_from(max=0)` additionally needs immediate EINVAL
without consuming a datagram or parking. The independently reviewed
`native-effects-v1` patch implements these contracts on the retained
scheduler, including parked channel close/transfer ownership and validating
invalid byte lists before consuming them. Its eight native-only files add
81 physical lines. It stacks on the 19-line foreign ABI shim and changes no
Bend source, checked API or JavaScript path.

Eleven new timed calls and two new UDP byte calls are not implemented in
this bounded native migration: `Chan.try_send/try_recv`,
`TCP.try_accept/try_send/try_send_bytes/try_recv/try_recv_bytes`,
`UDP.try_send_to/try_send_bytes_to/try_recv_from/try_recv_bytes_from`,
`UDP.send_bytes_to/recv_bytes_from`. They receive named runtime refusals
when actually dispatched without a registered provider; ordinary custom
providers can still register them. This is a new capability gap, separate
from the fixed ordinary-ABI regressions and the earlier native `IO.args`
limitation.

Nineteen actual-source controls are prepared against both current upstream
and an explicitly overlaid 04 native runtime: fifteen ordinary upstream
cases, two derived max-zero cases with only unsupported timed calls removed,
and two independent parked-close cases that return a nested affine payload
from a zero-capacity/full channel. The overlay's exact native-only scope is
recorded; it does not masquerade as a new checked image. Results and final
selected-snapshot native gates remain pending.

A separate deterministic C control exercises the exact staged TCP provider
with only `send` replaced by a scripted syscall result. Its seven semantic
oracles cover partial string/binary failure suffixes, invalid-byte rejection
returning the original list allocation without a syscall, UTF-8 split-byte
suffix decoding, complete immediate failure, successful partial sends, and
empty sends. It retains the exact generated program scaffold and verifies
that reconstruction before compilation. This complements the real source
network tests; it is not counted as seven additional compiled Bend programs.
The guarded recipe is `native-effects-v1/mocked-send-recipe.json`; execution
remains pending here.

## Nineteen native source controls closed

Both roles passed **19/19 checked native executions** with unchanged inputs
and complete selected results. These include real TCP/UDP loopbacks, exact
invalid-byte list return, peer EOF, zero-max requests before/after queued data,
and channel close with a waiting sender carrying a nested affine payload.
The reference run took 35.14 seconds and Bend 94.97 seconds as supervised
qualification workloads; these are not controlled compiler-speed measurements.

Receipts are under
`selfhost/build/phase66/native-effects-source02-recipe/{typescript-new,bend-direct}/observations/report.json`.
A source audit confirms that the recorded overlaid project matches all 313
selected 05 snapshot files except the deliberately derived direct conformance
adapter, whose separate expected hash is recorded. Its compiler API is also
identical to 05. This admits the recorded 04-API/native-overlay provenance
without relabeling the run as a fresh 05 image execution.

The fresh selected-05 native16 command is prepared in
`backend-native-controls05-clang01-recipe/recipe.json`; it reuses the already
passing TypeScript16 reference and reruns only Bend. The final join producer
`backend/join-native-v1.py` binds this gate, source19, native3 and mocked syscall
controls to selected 05 and lists every unsupported native method explicitly.
The join is not a passing receipt until its required targets have closed.

## Selected-05 native gates closed; full-JavaScript gaps remain separate

The fresh selected-05 native16 run passed **16/16**, including the two foreign
fixtures that originally failed C compilation. The selected-05 native3 gate
also passed, and the deterministic TCP syscall control passed **7/7**. Their
supervised durations (26.17 seconds for native16 and 2.216 seconds for the
mocked control) are qualification costs, not compiler-speed comparisons.
`join-native-v2.py` strengthens the data-only receipt with exact selected-image
and cloned-runtime bindings. It does not transfer native qualification to a
future compiler image automatically.

The data-only join is now **PASS**, with 4025 rehashed inputs:
[`evidence/native-backend05.json`](evidence/native-backend05.json), SHA-256
`47965dd5d79b473cad258d74a45fa4efd18b5591fa360f65c406163e31281430`.
The counts in its overlapping suites are not summed into unique coverage.

The full direct-JavaScript campaign exposed five additional admitted-source
failures: two quantity-meet expressions and three wide-record programs. These
are separate from native runtime compatibility. The TypeScript reference
passes all five.

`min-erasure-v1` adds only the known `Min` tag to direct expression erasure.
Actual reference output returns `null` for the quantity meet while retaining
the original positional argument convention. This is checked quantity evidence,
not runtime arithmetic; the patch neither computes `Math.min` nor evaluates
the erased children. Unknown expression tags still refuse.

`wide-call-fields-v2` removes an independent 64-field ceiling in tail-call
analysis. Its finite telescope lookahead uses the **remaining existing
8192-node per-definition budget** and refuses incomplete counts. The unchanged
body scan receives its original fuel, so field lambdas are not charged twice.
The 4096-definition and graph-edge budgets remain unchanged. The first staged
draft charged the lookahead to body fuel; independent review identified its
near-boundary regression, and that unconsumed draft is retained as rejected.
The successor has source approval and 18 focused diagnostic controls prepared,
plus actual-source execution of the two meet and three wide-record fixtures.
Both patches are integrated with exact after-byte checks; neither has a
target pass at this checkpoint, and a new checked image is required. Two
separate shared-layout timeouts are investigated in their own
lane and are not classified as solved by these patches.

## Checked-07 meet and wide-record controls closed

The subsequent checked-07 image passed the strict build, all **five actual
source executions**, and all **18 private analysis controls**. The source
outputs exactly match the five retained passing reference observations:
`3n`, `1n`, `1`, `501/501`, and `777777!/7/77`. The source suite reports checked
execution for every case and unchanged inputs. The diagnostic controls compare
complete `JDCallScan` values with the original small-width formula, including
exact/just-enough fuel boundaries; they separately establish the newly admitted
65/255/256/300 widths, mixed/erased fields, and incomplete-count refusal.

[`evidence/min-wide07.json`](evidence/min-wide07.json) binds the actual image,
patch source hashes, cloned driver inputs, five source observations and 18
diagnostics. Reference reuse is limited to those five individually passed
observations: the original whole reference report is not marked complete, and
this receipt does not upgrade it. The first data-join draft correctly refused
its stronger whole-report completion assumption; its successor records the
narrower scope explicitly. Native selected-05 qualification remains a separate
receipt until an explicit later-image admission closes.

## Selected-07 native admission closed

[`evidence/native-backend07.json`](evidence/native-backend07.json) is **PASS**,
with 4,661 rehashed inputs and SHA-256
`a1425d8ca6c4f1728814bab0de86032b25362713b180d723116e1800c384b5d3`.
This is an explicit reuse proof plus fresh observations, not a claim that the
whole compiler API is byte-identical or that every old suite was rerun.

Only three of 313 snapshot files changed from 05 to 07: direct expression
lowering, direct call analysis and shared printability validation. All 48
native runtime files remain identical. A strict source-only census of the
actual named compiler images finds the same **646 native-pipeline functions**
with identical bodies, runtime prefix and public export wrappers. It covers
every API referenced by the native annotation/emission branches of the exact
driver. The frontend and IO-classification closures also match. Function
values passed through higher-order helpers are included in this lexical
closure; it is not a sampled execution profile.

Shared entry validation is admitted separately. All 19 effect controls and
seven of the 13 executed native16 cases have actual emitted `MAIN_PURE 0`
classification; the IO entry branch is unchanged. The other six native16
programs pass the same common entry check in the actual 07 direct-JavaScript
campaign, with exact fixture identity. The two early refusals remain covered
by the unchanged frontend closure; the no-main proof-trust case is explicitly
not presented as a fresh JavaScript execution.

The remaining external namespace-collision fixture was rerun in the native
lane on 07. It passed with the exact prior diagnostic:

```
Error: main's type child.Box cannot be printed (a function, a Type, an erased or dependent field)
```

The consumed recipe is
`selfhost/build/phase66/native-admission07-recipe/focused-v2-recipe.json`
(`bff4895070cff9348cfadb4e85cb13f56619c8816b5a50faf5d0dfd032cc826d`).
It preserves the original external fixture's complete ID/lane/file selector.
The first selector draft omitted the external file field; source audit caught
that before execution, and the unused draft remains preserved. The actual
negative check took 5.030 supervised seconds, peaked at 399 MB and ended before
C compilation. These figures describe qualification cost, not compiler speed.

Fresh selected-07 native3 passes and its three emitted C files are byte-equal
to selected 05. The actual checked-B1 and emitted-B2 driver probes also produce
identical native C. These observations complement the source-closure proof;
they do not establish universal native/GPU conformance. The thirteen unavailable
new native APIs listed above remain explicitly unsupported.

The first data-join draft stopped at a too-literal generated-code assertion:
the unchanged Boolean call site had gained parentheses when its `run_loop`
became unnecessary. `join-native07-v2.py` admits exactly that spelling change,
while still requiring byte equality of the IO branch and all native emitter
functions. No target result or semantic oracle was weakened. Installation and
combined release status belong to the [main gate index](README.md).
