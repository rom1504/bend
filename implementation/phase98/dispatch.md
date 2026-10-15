# Phase98: shared term observations and dispatch

Hypothesis H98-D1: repeated `tg(t)` calls in the actual checker dispatchers add
shared constructor projection and disposal work. Cache the immutable total tag
once, retaining the original term for the selected branch. The first isolated
candidate changes only `infer_node` (12 observations to one) and `check_node`
(eight observations to one). It adds two source lines and preserves each ordered
comparison, diagnostic string, and branch expression exactly.

Preparation is data-only through
`selfhost/tools/performance/phase98/dispatch/prepare.py`. Its frozen receipt binds
the D04 compiler SHA `d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097`
to exact canonical declarations in `selfhost/src/check/kernel.bend`, applying only
the established `String.eq` to `p88_string_eq` translation. Forward construction
and exact reverse replay establish patch identity. No canonical file is edited.

`tg` is total on all three KTerm variants and preserves arbitrary generic tags.
The extra observation on `check_node`'s literal path is permitted only by that
totality; literal identity is still decided by `core_literal`, not tag text. This
candidate leaves nested `kc` thunk allocation in place. A later candidate may
replace those with explicit typed dispatch stages, but will be frozen separately.

Phase97's unpromoted `f_find` optimization is not bundled.

## Frozen candidates and source cost

| Snapshot | Mechanism | Edited callers | Extra lines | Compiler SHA256 |
| --- | --- | ---: | ---: | --- |
| dispatch-frozen01 | Cache checker tags |2|2|`84a460ebdcb53bb08bf69de83f0b918b907119e56e1c4b01caa91a781572451a`|
| dispatch-frozen02 | Ordered selector + direct branch match |4|252|`501643ae9d4577e2320318b6e0a5bf0fd1ff3668cd85d28ee1df02340aa071aa`|
| dispatch-frozen03 | Selectors + bounded conditional lifting |19|525|`514b58b4d7c974a20f4ef95ba8a81428ed1e19f427e7562d9c1fefa3c7ad6f4b`|

All are under `selfhost/build/phase98/`, with complete compiler sources, exact
canonical module copies/patches, immutable methods and before/after receipt
spans. Canonical production and historical artifacts remain unchanged.

H98-D2 removes the discarded thunk branches in `infer_node`, `check_node`,
`ka_node` and `ka_type_node`. Four safe selectors return full nullary enum values
in the original comparison order. Each typed Bool stage matches a parameter;
the original unsafe branch expressions then run in a separate parameter match.
No computed-match syntax is used. The literal gates remain before tag selection;
infer's original fallback remains intact. Syntactic `tg(t)` sites38→5. The extra
252 lines are a real simplicity cost, not hidden generated-code savings.

H98-D3 extends the closure mechanism to `core_rebuild`, `core_apply_span`,
`core_beta`, `compare`, `norm_compare`, `norm_ref`, `infer_ref`, `infer_app`,
`infer_app_type`, `infer_adt`, `check_fits`, `check_lam`, `check_lam_done`,
`check_ctr` and `nc_lower_live_to`. It lifts only complete outer conditional trees
into typed Bool-parameter helpers and preserves the complete original branch
expressions and condition order. No extra eager observer is introduced. Across
all19 edited callers, `kc` occurrences64→7 and `nt_choose`28→0:85 removed choice
calls. Native lowering already cached its tag; its saving hypothesis concerns
capturing/discarding book, term, environment and target. The D04 bridge retains
the historical `nct_leaf` wrappers on two NC_Code fields exactly. Its additional
273 lines bring the combined source increase to525.

## Hoist outcome and actual generated C

The root's `dispatch-screen01/report.json` records48 exact complete C outputs and
48 exact diagnostics across six original sources and four balanced rounds.

| Source | Baseline request ms | Hoist request ms | Ratio |
| --- | ---: | ---: | ---: |
| small |57.5|57.5|1.0000|
| numeric_closed |100|99|0.9900|
| lexer_original |357|362|1.0140|
| map_closed |1467.5|1471|1.0024|
| functions65 |229|230|1.0044|
| unicode |57.5|59.5|1.0348|

Equal-case request geometric ratio is1.007493; process-wall ratio1.004350.
This is neutral/slightly slower, with ordinary run noise; no hoist promotion.
It establishes no candidate B2, full-self or product-runtime gain.

`dispatch/hoist-c-shapes01.json` pins the actual upstream baseline C and the
root-acquired `dispatch-checked01/program.c`, and retains the exact `spin_1`
constructor observer body. Within the generated infer family, syntactic tag
observer calls fall15→4, while heap allocations remain99 and closure constructor
occurrences128. The check family falls16→9 observer calls while allocations136
and closure occurrences164 remain unchanged. These families include inlined
branch work, hence their totals differ from the edited source bodies. They are
static occurrences, not dynamic operation counts.

At the infer entry (`program.c:418046`), the cached tag gains its own retain and
the false-branch closure grows15→16 fields. The original shared term observer
still calls `ctr_take` over all fields and sinks non-tag boxed fields. Hoisting
removes repeated projections but leaves closure ownership work and adds a tag
capture, consistent with the neutral screen. Dispatch/direct candidates seek
the remaining closure cost; their performance is still pending.

## Law and finite-control boundaries

`dispatch-proof-check01/report.json` accepts four public full-enum selector laws
with33 stage lemmas and no opaque definitions. The exact frozen02 selectors are
unchanged in frozen03; their33 ordered reference conditions were separately
audited against original D04 callers. This proves selected enum equality for
arbitrary String tags. It does not universally equate recursive unsafe callers,
prove that a selected enum is mapped to the correct branch body, or establish
generated C ownership.

`dispatch-controls01/manifest.json` freezes41 finite expectations before target
outcomes. The independent Python specification has explicit tag membership maps,
not values generated from candidate selectors. Each result includes all four
branch indices, complete escaped tag, actual constructor literal discriminator,
and the surviving complete KTerm with metadata, duplicate children/removals and
source spans. It covers every recognized tag, generic Lit/Efq/FUnboundVar,
unknown/prefix/suffix/case/NUL/Unicode strings, both lambda quantity flags and
three literal kinds. Native and genuine-JS execution remain root-owned. These
controls exercise selectors and observation aliases, not recursive branch bodies.

`dispatch-production01/manifest.json` separately reuses the unchanged226 Phase96
full-value expectations and32 native selections. It replaces only the parent
extraction's `core_rebuild` and `core_apply_span` with their exact frozen03 bodies
and helpers, adding exact D04 comparator dependencies. Production substitution
reaches these actual changed operations. The parent corpus does not extract or
invoke `core_beta`; the other17 changed wide callers remain outside this bridge.
All expected values, original inputs and native stdout remain byte-identical to
the independently accepted Phase96 parent. Execution is pending root evidence.

## Qualification path

The separate `selfhost/tools/performance/phase98/qualification/` methods bind an
explicit new source/image/emission/Clang receipt without changing public native
admission or hardcoding D04 as the candidate source. The first runnable immutable
snapshot is `qualification-methods01/methods/`; offline build authentication of
the hoist image passed in `qualification-bind-preflight02.json`. No new target
was run for that preflight.

The separately frozen `qualification-methods02` changes the full-Clang default
and maximum to6GiB RSS with16GiB available-memory floor, matching the current
guard. Snapshot01 and its existing binding evidence remain intact. A deliberate
backend change that changes generated C needs new independently frozen output
oracles and actual program execution; the historical exact-C mode is deliberately
insufficient for that case.

The runner derives candidate self-C and its full unsafe-dependency diagnostic
from an independent maintained native B2 reference, then compares candidate B1
and B2 self-emissions exactly. Build authentication leaves image qualification
false until the root combines self-consistency with semantic gates. Separate
methods cover4live+4cached controls,3 exact rejections,45 complete C identities,
and the unchanged native69+3 harness with31 explicit exclusions. No successful
self-emission is labeled a whole-compiler proof.
