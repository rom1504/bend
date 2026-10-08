# Phase66 Base and host boundary

Status: initial host compatibility controls passed in the root's serial run.
Owned annotation and custom-Base fallback requalification passed. Root applied
the exact new-Base permission. Image04 genuine B2 qualification also passed;
all four fresh final07 B1/B2 owned/custom controls and their independent receipt
audit now pass after the later backend corrections. No
compiler or runtime target has been executed by this lane; root owns integration
and qualification.

The new upstream reference is
`059266225b77c8ca256ac6b25ee5c21449bab151`. Its Base is 75,064 bytes with SHA256
`99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.
This is a source and IO interface migration, not an optimization measurement.
The prior Base, provider inventory, release, and Phase65 evidence remain separate.

## Provider contract

The new Base has 56 JavaScript foreign declarations backed by 35 exact upstream
provider files. A source-only audit matches every declaration to its provider's
`io_eff(CID(...), ...)` registration, with no missing, duplicate, or extra
registration. The result is
[`provider-contract-v1.json`](../../selfhost/tools/performance/phase66/base-host/provider-contract-v1.json).
The runtime owner independently confirmed all 35 staged provider byte sequences
match this lane's regenerated manifest.

The inventory removes `tcp_poll.js` and `udp_poll.js`. The blocking and timed
channel/TCP/UDP operations now share provider files. `Poll` has `Ready{value}`
and `Wait{rest}` constructors. `Chan.send` returns `Result`, preserving the value
on a closed channel; TCP and UDP send failures likewise preserve unsent data.
The `try_` twins return the blocking result under `Ready`, or unsent data/unit
under `Wait` when their deadline expires. UDP receive returns a datagram result,
including an empty datagram, rather than TCP's end-of-stream `Maybe`.

The nine changed common files are `chan.js`, `file_size.js`, `random_u32.js`,
`sleep.js`, `tcp_accept.js`, `tcp_recv.js`, `tcp_send.js`, `udp_recv_from.js`, and
`udp_send_to.js`. The new file-size implementation avoids loading Bun FFI simply
to choose an overflow errno; random-u32 returns a failure result when WebCrypto
is unavailable. These are upstream behaviors, not local provider rewrites.

The proposed host patch changes the resolver's closed inventory count from 37
to 35 and binds its manifest to the exact new Base and provider bytes. The
manifest format remains version 1; its historical kind string identifies that
format, while the explicit revision and hashes identify the new contents.
The unchanged resolver requires both the exact Base content hash and an import
beside that Base under `effs/`. Custom Base contents, unrelated user paths, and
the removed poll filenames retain ordinary path resolution. This decision is
request-local. The unchanged Apache-2.0 license hash is retained.

## Prepared cache and annotation products

Mandatory prepared-cache admission already keys the actual compiler API, Base
content, canonical source path, term ABI, and source range. This migration does
not change the frame4/world3 schema or reuse an old Base frame under a new key.

The first candidate kept the optional annotation producer qualified only for the
old standard Base hash. A ready checked world alone does
not prove that evaluating an unselected unsafe annotation terminates. Therefore
the new Base initially took ordinary annotation until actual new-Base preparation
and whole-product/whole-module equality controls passed. Both producer and reader
check this content permission before touching optional product dependencies.
Changing the permission hash is a separately reviewed candidate, not a side
effect of copying the new Base. The current source now permits the exact new
Base after the checked-image controls recorded below; changed/custom Base
contents retain the fallback.

Requalification requires a new actual checked-image control input: observe
the new producer's complete terminating result and generic work-threshold key
set; compare each retained annotation with ordinary annotation; exercise actual
owned and public routes, stopped names, loader errors, full-hash collisions,
no-hit body IO, and comment-only custom Base fallback. Do not reuse the old
12-product/7-Map-hit oracle without observing the new Base. Keep producer/API/
Base/source-span/parent-arena bindings exact. Only then update the content gate
and perform a bounded same-image present/absent comparison.

Explicit preparation is `node selfhost/tools/typed-driver.mjs --prepare-base`
with the intended installed API and Base (or their `BEND_TYPED_API`/`BEND_BASE`
overrides). When qualified, this primes optional products as well as mandatory
state. Ordinary compilation prepares mandatory state on a miss with
`backendProducts:false`; it does not manufacture an annotation artifact during
that request. For an unqualified Base, explicit preparation omits the optional
annotation artifact; subsequent compilation annotates normally.

## Candidate and controls

[`base-host-v1.json`](../../selfhost/tools/performance/phase66/base-host/base-host-v1.json)
pins the three before/after files and isolated patch. The patch modifies only
`selfhost/tools/typed-driver.mjs`, the provider manifest, and provider README.
The runtime/provider-byte and Bend request-conversion changes are separate,
coordinated lanes; all must be integrated before whole-program IO qualification.

The root-run bounded command is:

```sh
node selfhost/tools/performance/phase66/base-host/base-host-controls-v1.mjs \
  selfhost/tools/performance/phase66/base-host/base-host-v1.json \
  selfhost/build/phase66/base-host-controls01
```

Run through the root's serial CPU3 resource guard. The controller pins exact
candidate and reference bytes, executes only the selected host resolver and
permission functions, and checks listed-provider redirects, removed filenames,
unrelated user imports, a comment-only custom Base, request-local decisions,
empty imports, invalid inventories, and the disabled new-Base product boundary.
Its scope is host-unit behavior; it does not replace real owned-driver,
provider-execution, bootstrap, or conformance controls. The source-only provider
audit likewise proves registration correspondence, not scheduling or network IO.

The root's `base-host-controls01/report.json` passes all 11 host-unit controls
(SHA256 `4cd067d9e1f5bfc219c0eee3717b147029ab2f30e7607dad3a18f892022e450a`).
Independent source reviews passed for the host patch and controller. The
separate `bootstrap-default-v1.patch` corrects the routine driver's default
checkout from Phase23 to Phase66; explicit selected build configurations already
used the new reference.

## Staged annotation requalification

`annotations-qualified-v1.patch` records the originally isolated proposal changing
only the permitted annotation Base hash, after the bootstrap-default correction.
There is no Bend algorithm, frame format, product threshold, or admission-rule
change. Both checked-image control families passed before root applied it;
the historical proposal's pre-qualification status remains unchanged.

`annotation-controls-v4.mjs` retains the Phase65 owned/public driver, complete
annotation DAG, stopped-object identity, collision/error refusal, and no-hit
body-read controls. It binds the actual checked attempt, bootstrap recipe,
assembled source, all source modules, runtime, Base, and 99 requested exports.
An optional profile7 derivative must bind that exact checked parent and replay
through its pinned `verifyEqualityDerivation` implementation. The historical
controller and failed/raw image evidence are not relabeled.

The controller clones the exact snapshot host closure into a fresh project and
replays both documented host edits there. It observes the new producer rather
than assuming the old 12 keys or seven Map hits. A full independent syntax
occurrence count determines the work-64 set, then every retained annotation is
compared with ordinary annotation under the exact checked Base context. Map must
activate reuse, its whole result must match ordinary and public execution, and
each reused object must be the decoded product object. Numeric and Lexer remain
explicit no-body-read controls if their actual selected names do not intersect
the observed product set. A separate custom-Base successor compares the same
image's ordinary Map module with a comment-only Base and requires two ready
preparations without any optional producer/consumer demand.

Pre-execution peer review corrected the census to count compact `KLiteral`
objects as leaves; only `KTerm` and `KLambda` carry child lists. The old
unexecuted methods remain preserved, and the correction is recorded as an exact
controller derivation rather than a change to consumed evidence.

The frozen actual03 input is `annotation-controls-checked03-input-v4.json`
(`56b0ec2a…bd67`), targeting the strict-36-pass selected profile7 API
`1ed7decc…3094`, with raw checked parent `5f5cd645…5875` and replay verifier
`fcc80fd4…7eb5`. The only executed-host proposal is the isolated exact Base gate
change from snapshot driver `21824aaa…c168` to `e093483d…ec85`. Final peer review
passed the selected `derived-b1` attempt/receipt/API/source joins.

The root's `base-annotations-owned-checked03-01` completed successfully in
11.66 seconds. Its report SHA256 is
`42f2e0aa8141b0723674f9fc351d253a6ffb12154b20bd04044e54a8ce6aa618`.
Independent post-run audit rehashed all 506 recorded inputs and the artifact.
The new prepared Base contains 475 checked definitions. The independent census
finds 12 retained products, all equal to ordinary annotation across 99,261 graph
pairs. The artifact is 438,959 bytes. Actual owned Map compilation reuses seven
decoded definition objects, with 101,907 graph pairs equal to ordinary
annotation, and passes stop, readiness, loader-error, and collision controls.
Lexer and Numeric have no product admission or body reads. All three complete
owned and public driver results agree. These are semantic and demand controls,
not new performance measurements.

The matching `base-annotations-custom-checked03-01` passed in 10.8 seconds
(report SHA256 `503c5b499920a9dacfb55c04f53bcf70de3868f2023e79af6b04a7790a05a736`).
All 505 input pins reverified. A comment-only Base change still produces a ready
world on two preparations, but invokes none of the four optional annotation
entry points and creates no artifact. Its owned Map compilation uses the world
and context routes once each and emits the same complete module as the standard
Base and positive owned test (`ae2b6b4a…9546`, 137,137 bytes).

Root recorded the permission integration in
`selfhost/build/phase66/integration-base-annotations01.json`; the selected live
driver now hashes to `e093483d…ec85`. Genuine B2 successors will bind actual
emission, source/parent image, root admission, tiny split/unsplit equality, and
both eight-case driver comparisons before repeating these product and fallback
checks. They do not relabel the checked/derived B1 evidence as B2 evidence.

The actual final04 B2 is now bound by
`bootstrap-b2-04b/image-pins.json` (`ddfe223d…d4db`), with compiler image
`9ded6e94…6944`. Shared control input
`annotation-controls-b2-04-input-v1.json` (`f56bb5bb…8704`) selects that image,
the final04 runtime, and qualified host `e093483d…ec85`. Both controllers are
frozen and source-reviewed: `annotation-controls-b2-v1.mjs` (`63878a29…f36f`)
and `custom-base-controls-b2-v1.mjs` (`656e4d90…39cd`). Data-only replay checks
passed the genuine emission, tiny equality, two eight-case comparisons, all 99
root declarations, source, admission, and plan inputs. There are no host source
transformations in these B2 controls.

Both B2 targets passed. Independent receipt audit rehashed all 279 owned-control
inputs, all 278 custom-control inputs, and the annotation artifact. The owned
report is `110cd6a7…0cc4`; the custom report is `3df1a819…6112`. The 99 requested
roots are present among the actual image's 3,248 exports. B2 independently finds
the same 12 products and compares all of them exactly (99,261 graph pairs);
owned Map reuses seven products with 101,907 exact pairs. Lexer and Numeric
perform no product admission or body reads. All three complete emitted modules
also equal the passed checked03 modules.

The B2 comment-only custom Base passes two ready preparations, invokes no
optional entry points, creates no artifact, and emits the identical 137,137-byte
Map module through the owned world/context routes. The compact audit and exact
raw receipt links are in
[`evidence/base-annotations-b2.json`](evidence/base-annotations-b2.json).
Earlier methods, failed attempts, and raw receipts remain unchanged. This closes
the JS annotation-product qualification; it makes no claim about unrelated
native ABI repairs or additional speed gains.

## Final07 successor

The later Min, wide-field, and printability fixes change the Bend compiler
source and its B1/B2 images. Image04 results remain preserved and are not
transferred to the new images. Four fresh controls reuse the same reviewed
methods against actual final07 metadata: derived B1 `bb6c6e2a…81a6` and genuine
B2 `0067736c…ed7f`, whose emission pins are `8339978a…4eec`.

`final07-controls-plan.json` (`d71b04c1…93b0`) records four serial CPU3 commands
with a 1 GiB JS heap, 2 GiB RSS ceiling, and 90-second deadline each. B1 input
`a80f0233…fc6e` and B2 input `dbcac2a1…a80a` passed independent metadata review.
Both use the actual final07 frozen qualified driver, runtime, and Base; the B1
host transformation list is empty. The four fresh root-run targets passed in
11.757, 10.752, 10.250, and 9.245 seconds respectively. These are guarded control
durations, not performance benchmark samples.

The peer-reviewed data-only producer `audit-final07.py` rehashed all four raw
input inventories (505, 504, 279, and 278 entries; 735 distinct transitive files),
joined each supervisor's exact planned command and limits, and checked the
selected source, actual derived B1, genuine B2 emission, host, and Base identities.
Its compact receipt is
[`evidence/base-host07.json`](evidence/base-host07.json)
(`371bf09c…bf16`). The consumed plan, controllers, earlier receipts, and failed
attempts remain unchanged.

Both final07 images independently retain the same 12 products from 475 checked
Base definitions and compare them exactly across 99,261 graph pairs. Each
438,959-byte sidecar is bound to its own producer image. Map reuses seven exact
decoded objects with 101,907 annotation pairs and passes all seven private
stop/admission/refusal controls. Lexer and Numeric read no product bodies; the
public injected routes consume no products. Complete modules agree between
ordinary, cached, public, and B1/B2 execution. The actual B2 exports 3,252 names,
including all 99 requested roots.

Both comment-only custom Base controls prepare a ready world twice, call none
of the four optional annotation entry points, and create no sidecar. Their owned
Map compilations use the world/context routes and match the same image's entire
ordinary Map module. This closes the final07 JavaScript product permission and
fallback boundary; native qualification and speed measurements remain separate.
