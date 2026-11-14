# Phase194 independent combined-source audit

Read-only compiler review on 2026-11-14, followed by separately requested v3
stress fixture preparation. The reviewer did not run target compilation or
execution jobs. Root owns all checked acquisition and machine observations.
No concrete wrong-code or ABI blocker was found in the reviewed implementation.
This is a bounded source audit and finite evidence assessment, not a proof.

## Source and integration boundary

Maintained `src/back/x86/predicate-select.bend` matches experimental v3 exactly.
Its only change from v2 is the required borrowed `+code` parameter on fallback.
Maintained `float-identities.bend` matches the experimental float module plus
hook, apart from one blank line. The old `x186_float_function` definition was
removed from `float-values.bend`; its replacement runs identities after scratch
planning/pruning and before GPR/XMM placement. `compiler.json` registers both
new modules. The branch hook preserves the old adjacent-pair `da` counts and
stores the new complete-use counts separately in `dx`.

Reviewed maintained file SHA256 identities:

| File under selfhost/ | SHA256 |
| --- | --- |
| src/back/x86/predicate-select.bend | e8de35f78fb9e0ac63b210f03b34be862ea8bb23944b898dba8f4f22cfec30b6 |
| src/back/x86/float-identities.bend | cde1cb77df13b8242a496a17c1c00aae9710e4dc9d1309e1ad6ef96ca7f85898 |
| src/back/x86/branch-selection.bend | 724efaaadc04400c59cd2da193df7b5fb530540a09d75945fa6db3cc1062ac11 |
| src/back/x86/float-values.bend | 3d468247ffb89c259a1d33174e71b724d7eb7e85fa0edf2c375536ffe775165d |
| src/compiler.json | b383771a7335832749d7cf55c6430ab4c2db3d78f11a471c4ba7f67dbee59d9f |

The two mechanisms use different final emission paths. Functions admitted to
the float-node pipeline emit ordinary nodes through `x181_stmt`; they do not
run `x190_stmts` and the new predicate selector. Predicate fusion applies to
the ordinary-function fallback route. Combining the modules does not establish
predicate fusion inside float-admitted functions. This is an applicability
boundary, not a semantic defect.

## Semantic review

The predicate recognizer accounts for each removed copy/inversion read and
each crossed exact empty If read. Its list may repeat a name, intentionally:
the count must reflect occurrences, not distinct names. Select inputs and
comparison operands cannot be removed locals; selected outputs cannot be
removed locals either. Original use counts include both branch forms,
continuations, calls and Again arguments. A corridor cannot overlap another
comparison-producing corridor inside its accepted copy/xor/empty-If span.

CMP uses the comparison width; CMOV and input truncation use the independent
select width. Current Local/Const loads and masks are MOV/MOVABS/LEA operations
that preserve flags. Original reserved scratch registers and operand snapshots
protect source/output aliasing. These properties depend on existing helpers,
frame allocation, pure-arm certification and complete read collection staying
consistent. The bounded function size keeps paired-read counts far below U32
saturation; no modular-count argument is needed for these admitted bodies.

Float operand aliases are resolved before destination rebinding. An ordinary
U64 copy retains its full-word source, original destination and order, then
kills that destination alias. The bounded suffix certificate ensures each
renamed definition is overwritten before a cut; repeated renamings terminate
in an original-name publication. Fresh branch paths and a complete reserved
prefix scan prevent name collisions. Existing canonical-word admission and
inclusive XMM ranges remain authoritative; a fresh name alone does not justify
discarding upper bits, extending a lifetime across a call, or changing rounding.

## Stress02: successful semantics did not imply intended admission

The original combined-api01 acquisition failed source checking on an unannotated
fixture list in `p194st_corridor`; it is not a semantic pass. Its diagnostics
remain in `selfhost/build/phase194/combined-api01`.

The annotated v2 fixture passed through combined-api02. The root-run
[stress02 report](../../selfhost/build/phase194/combined-stress-controls02/report.json)
records eight exact raw control rows and 968 independent C observations on each
direct-object and GNU-as route, zero failures, 8.702 seconds. Both routes share
the same selected instruction sequence.

Independent inspection of its
[final assembly](../../selfhost/build/phase194/combined-stress-controls02/stress/fixture-0.s)
shows the following. Raw admission means the fixture's matcher/facts query
before the full preparation pipeline; it is distinct from final admission.

| Mode | Raw certificate expectation | Final machine evidence |
| --- | --- | --- |
| 0: repeated definitions | Admit both corridors | Two CMP/SETcc/TEST/CMOV sequences; new fusion not exercised |
| 1: inversion, empty If, scalar select | Admit | CMP/CMOVB with inverted inputs, no SETcc or TEST; fusion exercised |
| 2: external copy read | Refuse | SETB/TEST/CMOVNE retained; fallback exercised |
| 3: external wide read | Refuse | SETB/TEST/CMOVNE retained; fallback exercised |
| 4: setup-protected condition | Refuse | SETB/TEST/CMOVNE retained; fallback exercised |
| 5: parameter-protected condition | Refuse | SETB/TEST/CMOVNE retained; fallback exercised |
| 6: seven copies plus empty If, fuel 8 | Admit | SETB/TEST/CMOVNE retained; new fusion not exercised |
| 7: eight copies plus empty If, fuel 9 | Refuse | SETB/TEST/CMOVNE retained; fallback exercised |

Preparation can remove or rewrite copies and Boolean operations. The exact
reason for each final refusal was not instrumented, so this table does not
assert that a raw refusal condition survived unchanged to the final selector.
In particular, modes 0 and 6 cannot be counted as machine validation of
repeated-definition fusion or its admitted fuel boundary.

Stress02 report SHA256:
`3f69226f1d10464842704c5ce2c6e40097f7e7a30a37853408a1a6b7763538d5`.
Assembly SHA256:
`66f919e236b4e8454d16debec0e42c4cb87f3a0c668fada4aba54304768e5eb0`.

## Separate v3 path-coverage controls

`predicate-stress-v3.bend` preserves the eight full-pipeline workers and adds
`p194str_0` and `p194str_6` through `x191_ordinary`, retaining the original
corridor rows while using actual facts, placement and hooked final selection.
`predicate-stress-v3.c` independently observes all ten workers: 1,210 cases per
route. `predicate-stress-driver-v3.mjs` requires exact CMP/SETcc/TEST/CMOV patterns
for each emitted function. Raw mode0 must contain CMOVB and CMOVA, raw mode6
CMOVB, and neither may contain SETcc or TEST. Assembly is retained before those
assertions so failed admission remains reviewable. V2 artifacts are unchanged.

Root subsequently acquired the checked v3 API and executed
[stress-controls03](../../selfhost/build/phase194/stress-controls03/report.json).
This reviewer inspected the complete receipt and
[retained assembly](../../selfhost/build/phase194/stress-controls03/stress/fixture-0.s):
all eight raw control rows and ten final-selection assertions pass; both direct
and GNU-as routes report 1,210 observations and zero failures. The guarded job's
driver duration is 8.738 seconds. `p194str_0` contains two CMPs followed by
CMOVB/CMOVA, `p194str_6` one CMP/CMOVB, and neither contains SETcc or TEST.
The eight original full-pipeline functions retain the patterns in the table.
This closes the finite machine-path gap for straight-line repeated definitions
and the admitted eight-row corridor. It does not establish that full preparation
preserves those particular raw corridors.

Stress03 report SHA256:
`3391d1ecdf9be2d999751ffea5f14e8876d43e869f8a35524224cb699288091e`.
Assembly SHA256:
`42f5117f086d0d4ea85b4dd93fd8267debfec12fe88f4d2c6d98fbf73d439ea9`.

## Remaining trust boundaries and useful adversaries

The float fixture invokes identities and placement directly, bypassing the
actual planning/pruning hook. It checks exact baseline/candidate result bits,
state, NaN payloads and MXCSR; the independent arithmetic oracle accepts NaN
classification equivalence and does not independently specify exception flags.
Exceptions are masked and FTZ/DAZ settings inherited. No general floating
environment or trapping guarantee follows from those finite observations.

Neither fixture explicitly tests all callee-saved registers with sentinels or
forces XMM/GPR allocation saturation. The strongest remaining float adversary
is an ordinary-source actual-hook workload with more than 14 simultaneously
live canonical values, raw old-value snapshots, a noncanonical overwrite and
a subsequent call/publication boundary. For predicates, repeated names across
nested arms/Again with an external copy/wide observation remain useful beyond
the straight-line stress cases. The finite controls, source acceptance,
original final verifier, emitted instruction encoding and runtime qualification
are separate trust boundaries; no new compiler theorem is claimed.
