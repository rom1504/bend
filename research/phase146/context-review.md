# Independent review of the retained verification context

Reviewed 2026-10-27. Scope: frozen `context-v01.bend`, `controls-v02.bend`,
their composed source02 and the actual original call graph. This reviewer ran
only static source/receipt inspection, not a compiler, test or target program.
The supplemental controls described below are source only until their separate
root-owned receipt exists.

**Conclusion:** no source-level soundness blocker found in this bounded private
entry. The change removes repeated checking of an unchanged accepted original;
it does not remove fresh checking of the transformed direct functions. The
original 24 controls had a real fallback-coverage gap, addressed by eight new
factory controls awaiting their own execution. Source checking and these finite
controls do not establish whole-compiler correctness or a performance gain.

## Exact change and evidence

| Artifact | SHA256 |
| --- | --- |
| Qualified Phase144 final04 source | `865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed` |
| Phase146 source02 | `87fe349e9f1ad084fb8b7e9a376a149144762d3ececffe49b075ff13c23828f7` |
| Context module v01 | `bfefe9546ab0c1f573610ef7437a92d399733d89771d1b0da249fa929b05b521` |
| Controls v02 | `ef5c1c3b05c3dbee98f93e97616b3ccfc47bb518d1de38ce07794d0ba82f00de` |
| Checked source02 API | `3351b25c4af38c342fac328b9542b9310870c21d0d7617ddadb18a1c6db7eefd` |

The paths are
[`final04-source01/compiler.bend`](../../selfhost/build/phase144/final04-source01/compiler.bend),
[`source02/manifest.json`](../../selfhost/build/phase146/source02/manifest.json),
[`context-v01.bend`](../../selfhost/tools/performance/phase146/context-v01.bend),
[`controls-v02.bend`](../../selfhost/tools/performance/phase146/controls-v02.bend),
and [`p146-api02/report.json`](../../selfhost/build/phase111/p146-api02/report.json).
The API receipt records a successful checked acquisition in 14.461752 seconds.
The composition manifest's `checked: false` describes composition itself; it
does not contradict the subsequent checked-API receipt.

An independent declaration comparison confirmed exactly one changed original
declaration, `p128raw_session_finish`; no originals were removed. Sixteen
declarations were added: five private implementation/ablation helpers and eleven
control helpers. Every other original declaration, including the public
verifiers and eleven inherited proof-connected declarations, is unchanged after
removing comments/blank lines. The source grows by 8,349 bytes and 151 lines,
including controls. The selected serial runtime is unchanged.

## Why the shortcut is valid at this entry

Line references below are to the pinned final04 source, unless stated otherwise.

1. **Acceptance is established locally.** `p114s_open` (48271) invokes
   `p112s_verify` on the actual raw/static original. Only an empty error reaches
   `p114s_ids` and the initial ordered direct-function check. The resulting
   `P114SBoundary.valid` is true only after both judgments succeed. Nonempty
   lowering errors instead enter `p114s_unchecked` through
   `p114s_open_lowered` (48315), retaining a false validity flag.
2. **Original and IDs stay paired.** `p114s_inline`, `p114s_commit` and
   `p134v_commit` (57808) retain the exact original and IDs on acceptance and
   rollback. They can change only the function list. Invalid boundaries stay
   invalid. Final04's outer `p114s_ranges` is identity. The new finish helper
   reconstructs the checked/emitted program through the unchanged
   `p114s_close_lowered` and `p113a_finish` from this same boundary.
3. **The held IDs are exactly the required IDs.** `p114s_ids` (48241) and the
   old `p113e_verify_original` (44570) construct the same
   `N111Ids{p113e_originals(segments,missing()),
   ns_ctor_index(constructors,missing())}`. No raw-verifier, emitter or static
   constructor map is substituted merely because it has the same carrier type.
4. **Transformed-body checking is fresh.** `p146c_functions` calls the unchanged
   `p113e_functions(functions,ids,missing())`. Every actual final function is
   checked in order, with a newly constructed ready-prefix map. This preserves
   forward-call/cycle rejection, signatures, public ABI, schema/flow, duplicate
   identities, memory accesses and all original body admission conditions.
   It does not reuse optimizer acceptance as final body verification.
5. **Namespace checks and diagnostic order remain.** The new verifier retains
   `p113a_verify_after` and then `p114t_verify_done`. Direct errors precede array
   namespace errors, which precede transport namespace errors. The former checks
   direct functions when the array certificate enables it; the latter checks
   both raw segments and direct functions. Static effect exclusions remain
   established by the original check: `p112s_block_effects` (41595) changes an
   effectful constructor's indexed kind so `p112s_constructor_ok` rejects it.
6. **Rejected openings use the complete old path.** `p146c_closed` uses the
   shortcut only when the lowering error is empty **and** the retained boundary
   is valid. Otherwise it passes the same `P113ALowered` to `p128raw_lowered`
   (55977). This retains raw/static-before-direct error order and both emission
   prefixes. `p140b_session` (62122) reaches this entry only on its nonempty-error
   branch; its successful incremental-cache path is unchanged.

The later observer/flat closure and `p126bp_complete` verification are also
unchanged. No new recursion, allocator, runtime ABI, externally accepted cache,
digest comparison or native-stack policy is introduced. Holding IDs longer may
change retention/reclamation cost; only complete-request measurements can price
that tradeoff.

## Authority and limits

The authority is the actual private production call graph, not a theorem or a
sealed capability type. `P114SBoundary` can be constructed in Bend, and
`p146c_verify` would be unsound as a general verifier accepting arbitrary
caller-supplied IDs. In source02 its only production caller is the retained
boundary chain; the other references are the explicit finite tests. No
`p146c_*` helper is exported by the checked API. A future public export, external
snapshot, independently supplied original/IDs or different mutation boundary
requires a new admission contract.

The original source verifier remains callable and unchanged. Bend source
checking validates the candidate implementation's language obligations; it does
not prove that an unsafe optimization or native backend preserves semantics.
This review establishes a source-level invariant argument, not an independent
BendTT proof, end-to-end equivalence theorem or native qualification.

## Controls: useful coverage and the closed gap

The 24 existing controls exercise accepted openings, actual inline/range
composition, changed invalid bodies, callee order, public ABI, duplicate direct
identities, certificate-dependent array names and unconditional transport names.
For valid openings they compare **complete errors** from public, held-ID and
raw-only verifiers. They independently require expected opening and final
acceptance status.

However, `p146ct_judgment` selects the public verifier for both alternatives
when `valid` is false. Its invalid-raw/static/effect/header/ABI rows therefore
test the original rejection and intended comparison model, but cannot detect a
bug in `p146c_closed`'s actual fallback. The raw/static-order row also lacked an
independently fixed expected diagnostic. Only the lowering-error control called
the actual request factory.

The new additive
[`supplemental-controls-v03.bend`](../../selfhost/tools/performance/phase146/supplemental-controls-v03.bend)
adds five test declarations and exports `p146cf_controls` with eight cases:

- Invalid raw return, invalid static offset and invalid first direct function.
- Simultaneously invalid raw return, static image and transport namespace,
  requiring the exact raw error `main: segment return must be U64`.
- Effectful static constructor rejection.
- Array namespace rejection on an otherwise accepted opening, using a reserved
  **direct parameter**; raw array names alone are not checked by this gate.
- Transport namespace rejection on an accepted opening, using a raw local.
- A prior lowering error taking precedence even over an invalid raw program.

Each case calls the actual `p128raw_session_finish`, supplies no forged boundary,
and requires `P111Emission{Nil{},exact_expected_error}`. The unprefixed expected
diagnostic is also compared with the unchanged public verifier. These fixtures
must fail before observer preparation/emission; malformed target code is never
executed. Accepted full requests still need the separate frozen-output/native
gates. The new module changes none of the frozen implementation or 24 controls.

## Qualification recommendation

Run the eight supplemental controls together with the 24 context controls and
existing optimizer-boundary controls. Require frozen whole-QBE equality on the
ordinary requests already used for the parent, then compare complete native
request cost and complete self-hosting output through the usual independent
gates. Record acquisition, raw-only/held-ID attribution, memory retention and
native execution separately. No broader cache or reduced transformed-body
checking is justified by this review.

## Subsequent receipt review

After the source-only review above, the coordinator acquired source03
(`96c40c9dd273e2fae5fabfe68093aa7fb8f25f075e2317bed06ff46d4feaab80`)
with the unchanged implementation and the additive eight-case supplement.
[`source03/controls/report.json`](../../selfhost/build/phase146/source03/controls/report.json)
records all 76 controls passing: 24 context, eight actual-factory, 26 prior
reuse and 18 prior scaling controls. The source01 failed check remains retained;
the correction was fixture type annotations, not a change to the implementation.
The reviewer inspected these receipts without rerunning their targets.
