# Phase140 integration: promotion and evidence audit

Source-only audit against the [Phase139 gates](../../design/phase139/validation-gates.md). This note does not change the installed compiler or execute targets. It distinguishes the first native experiment from later candidate source revisions.

## Current decision

Retain an experimental checkpoint and continue the bounded integrated checks. Production promotion is not justified by the first native edit result alone. That result is valuable evidence that expensive work can be avoided across actual compiler revisions; it does not establish arbitrary-edit reuse, a fivefold rebuild, or full native qualification of a later candidate.

The source09 manifest pins source `d0dd8e74ea944f2cf3226662a95ae693d02d0d36b7d64d164f013846e61901bc`. Only the experimental CLI dispatcher overrides an existing declaration; protected verifier and eleven existing proof declarations are retained. Its [API09 attempt](../../selfhost/build/phase111/p140-native-api09/report.json) failed parsing a new catalogue control. This failed attempt is preserved; later corrected sources require their own checked identities and cannot inherit the earlier native source03 execution evidence.

## Dependency review

- Late observer v3 now compares the global scalar catalogue exactly and includes erased-fact references explicitly in dependency edges. The [independent audit](late-cache-audit.md) records the two earlier omissions and their fixes. Initial worker reuse leaves retry, helper closure and the original final projected verifier in place.
- The proposed owner `core-v05` / `reverse-v04` guard conservatively disables owner reuse whenever dependency closure reaches an owner containing an ADT, including nested ADTs. This addresses global constructor/layout queries whose inputs can change through an alias body while headers remain equal. It must run after source closure and after erased-fact closure. Current edges and reverse state are still rebuilt for the next revision after refusal.
- Exact ordered headers preserve first-match and absence observations; exact individual bodies/facts and current static/signature/bang contexts govern the narrower owner hits. These are private same-producer caches, not certificates accepted from arbitrary external objects.
- Failed pure requests retain the prior complete session cache. The current native batch exits on a frontend error; native recovery within one continuing daemon has not been established.

This is an independent source review, not a proof that every possible compiler query is covered. Controls must demonstrate the new dirty-ADT miss, erased-fact changes and edge removal across three revisions before integrating that new guard into a native candidate.

## What the native product experiment establishes

The [session receipt](../../selfhost/build/phase140/full-product01/report.json) records actual A acquisition followed by B, where B changes compiler product policy. B's closed-frame compiler stages total **153.551s**. The independent incumbent [fresh B request](../../selfhost/build/phase130/p140-reference-product01/report.json) takes **333.144s** including request orchestration, and its exact QBE equals B's 106,285,793-byte output, SHA `a5149b2410d70546b7a28ff907aa312b6431cf8c5348107e7b675b9e9f54702e`.

The session's original `independentProductsExact=false` predates that subsequent independent comparison; join the two receipts rather than rewriting the earlier evidence. A and B differ, so this is not merely returning A's output.

The emitted B [machine build](../../selfhost/build/phase111/p140-product-b01/report.json) succeeds in **13.816s**. B transport/materialization separately costs **7.500s**, recorded in the session receipt. Therefore the available warm subtotal is **174.867s**, before focused smoke and any separately charged source-input overhead. Fresh request plus the identical machine-build cost is **346.960s**, or **1.984×** this warm subtotal. Using the incumbent outer guard's 334.544s gives **1.992×**. The approximately 2.18× figure describes compiler emission stages, not the complete `Tbuild`/`Tready` contract.

This is close to the G3 threshold, but the existing single block does not establish a strict twofold complete rebuild. Do not repeat the block merely to cross a threshold. Charge the new candidate's acquisition, A seeding, failures and qualification independently; do not subtract them from research cost. A separate built-compiler execution receipt is needed for `Tready` and the G3 independent-request obligation.

## Fast-path scope and remaining limits

| Edit/input class | Current treatment or remaining obligation |
| --- | --- |
| Local body edit preserving actual freshened headers | Intended fast path; exact prefix, dependency and downstream state gates still apply. Only measured edits have performance evidence. |
| New binders, changed header/quantity/flag/Foreign body, declaration insertion/removal/order | Conservative checkpoint/owner refusal and fresh recomputation. Balanced binder changes are not accepted merely because final fresh bounds match. |
| Parser edit before the retained completed declaration or changed lookahead | Prefix miss; actual parser state and first suffix token must match before reuse. Hints select possible boundaries, not correctness permission. |
| Type-alias edit affecting a constructor/layout | Proposed dirty-ADT global refusal, even if an unrelated owner's own body is unchanged. This deliberately narrows fast-path coverage. |
| Changed static image, signatures, candidate order or bang set | Raw or later caches refuse according to their exact global contexts; no stable-literal relocation scheme is claimed. |
| Changed compiler, checker, Base, runtime, policy or process epoch | Reacquire private state. No cross-producer or persistent semantic cache is qualified. |
| Long edit history, failed edit followed by continuing native recovery, eviction | Small pure controls are useful but do not establish steady-state native behavior or bounded long-lived memory. Batch length is bounded, not a daemon qualification. |

The new cache machinery is substantially `@unsafe`; source checking is not a replay-equivalence theorem. Retaining eleven existing laws does not prove the new parser/checker/owner/cache transitions, the runtime, or whole-compiler correctness.

Before promotion, join the corrected candidate's own G1 controls and exact independent edited outputs; same-image cold/warm cost; focused independent requests and rejection cases from the produced B compiler; appropriate native reproduction; and ordinary45/focused19 or a valid complete identity bridge. The frozen generated-program guardrails and the cold-overhead limit remain in force. A changed candidate does not inherit exact-output coverage solely because an earlier candidate passed.
