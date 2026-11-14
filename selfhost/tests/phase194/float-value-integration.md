# Phase194 closed float definition identities

Experimental, not promoted. No compiler or target execution was performed by the author. Parent owns checked-API, machine-control and runtime qualification. `float-value-controls.c` passed host C syntax checking; that is not a semantic pass.

## Hook and scope

Add `float-value-experimental.bend` after the existing x86 float pipeline in the checked source closure, and override `x186_float_function` with `float-value-hook.bend`. The separate patch documents the one maintained call-site substitution if selected. The transform runs after `x186_f_ready` scratch pruning and before `x186_f_place`, so both GPR frame metadata and XMM homes see the same renamed definitions. Never transform the fake integer placement rows as executable IR. `x194fv_enabled()` is the off switch; `x194fv_when(False{},...)` tests it independently.

For each FloatValues destination, rename this definition only if the next write to the original destination occurs within 32 FloatValues/U64-copy rows before an ordinary operation or control boundary. Rewrite intervening reads to its fresh identity. The final write remains under the original name. This distinguishes a closed canonical float lifetime from unrelated same-name integer/noncanonical definitions without replacing the register allocator or introducing general SSA.

Operand reads resolve through the previous alias map before changing the destination binding. U64 copies preserve their full-word source, original destination and order; they kill that destination's alias. Calls, loads, stores, integer operations, U32 sets, returns, backedges and branches end a region. Branch arms start independently, with distinct path prefixes. A renamed definition cannot remain live at a cut: its suffix certificate requires another write first, and repeated renamings form a finite chain whose last write retains the original name. No boundary flush, call convention or floating operation changes.

Fresh names include the node position and branch path. A complete scan of setup, parameters and body local reads/writes rejects an existing `p194fv_` prefix. Reserved destinations are not renamed. Functions with at least4096 setup/placement rows fall back; suffix work is bounded by32 rows per FloatValues node. Existing XMM canonical-word restrictions and capacity14 remain authoritative. A float result promoted to XMM always represents the same canonical zero-extended64 word. NaN payloads, signed zero, rounding modes, exception flags and operand order must remain unchanged.

## Current machine witness and falsifier

The retained **final budget** Phase193 image, not just the earlier Phase192 witness, still contains three adjacent cross-bank round trips in `direct.p37.numeric`:

- `coverage-numeric-recurrence-256/machine/program`, SHA256 `392b2edea06a22fe2fc26335dc66b6e0514bdf1a9def925a574530c90a57f498` under `selfhost/build/phase193/budget-native45-02`.
- `0x4083f0/0x4083f4`: xmm0 → edi → xmm2.
- `0x40840f/0x408413`: xmm0 → edi → xmm1.
- `0x40844a/0x40844e`: xmm0 → edi → xmm0.

The corresponding budget-final ray-active64/2440 executable (SHA256 `cc676008ed8cee847c06517e6d5cb516c2fef0eafc13861b61c7f970572ad3db`) has130 adjacent pairs across its complete text. Examples appear in `direct.clamp01.hi`, `direct.isect.t` and `direct.isect.go2`. This is static applicability evidence, **not130 hot opportunities**; boundary escapes may prevent many from receiving the certificate.

Cheap rejection gate: emit numeric and active ray with the float hook alone, compare selected hot functions, and count renamed definitions actually assigned XMM homes. Numeric should eliminate cross-bank transfers in the indicated straight-line chains. If the pass merely adds names/frame slots or pairs remain unchanged, reject before broad timing. Then compare balanced paired runtime with the current final baseline. Also inspect frame growth and spills: each fresh name enters GPR metadata even if XMM selection succeeds, so extra frame bookkeeping may erase a machine win. No measured gain or complete-suite ceiling is claimed; these are short scalar chains, and this slice cannot remove heap operations, branches or calls. Large suite gains remain unsupported by the witness.

## Finite controls

Freeze the three Bend files together with their module/hook dependencies. Required API exports: `p194fvc_controls`, `p194fvc_emit`, `x188_many`, `x188_render`, `x188_assemble`. Run `float-value-controls.mjs` through the parent's single guarded CPU3 lane with checked API/assets/source-manifest and a fresh output directory.

Twenty structural rows cover alias-before-rebind, XMM admission, final original publication, canonical copies, full raw U64 overwrites, U32 cut, calls/stores, independent branches, reserved-prefix collisions in body/setup/parameters, explicit off, return/backedge/load cuts and the32-row bound. The paired emitter produces ten baseline and ten candidate functions.

The separately written C observer checks28,880 input/condition/rounding combinations per emitted route, including infinities, signed zeros, subnormals, quiet/signalling NaNs and arbitrary upper32 bits. Baseline and candidate must agree exactly on all result/state bits and MXCSR. A separate arithmetic observer checks finite results and accepts equivalent NaN classifications only for its independently computed expected value; paired emitted NaN payloads must still match exactly. Both direct ELF and rendered GNU-as routes derive from the same selected instruction sequence and are not independent compiler implementations.
