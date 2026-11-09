# P186-006: local XMM homes and U32-to-F32 call removal

The 2026-11-09 candidate passes its focused controls and shows a provisional
ray improvement in a three-case runtime screen. Separate XMM/conversion
ablations and a repeated screen remain necessary. These are checked-B1 emitted
programs; no new native compiler reproduction, broad45 qualification, installed
selection, backend proof or C parity claim follows.

The [sixth-candidate ray profile](../../selfhost/build/phase186/profile-candidate-ray01/plan/summary.md)
has 1,401 accepted samples, no unknown leaves, and a separate clean observation
of 7.1144 CPU seconds. Period-weighted leaf shares are 36.88% in
`$product.nearest`, 14.76% in `$direct.nearest.t`, 21.69% in `p111_rt_op`, 6.36%
in `$product.trace`, and 15.96% across `sr/sz/sx/sy`. This profile predates the
candidate below. It identifies work to investigate, not a deletion forecast.

Reading the two retained sample-IP files against the exact linked runtime
places 105 of the 302 primitive-helper samples in entry/dispatch, 88 in the
common epilogue, 69 in opcode23's conversion body, and 27 in opcode36's sqrt
body; 13 are elsewhere. These are raw sample counts, not time shares: the two
captures use different periods. The function-relative ranges are respectively
`[0,0x33)`, `[0xe4,0xf6)`, `[0xd00,0xd1e)`, and `[0xe30,0xe4f)`.

The hypothesis has two parts. First, retaining canonical low32 F32 results in
XMM registers should remove repeated GPR/stack-to-XMM transfers within admitted
arithmetic chains. Second, directly selecting opcode23 should remove a much
larger call boundary than its arithmetic requires. The sixth ray assembly has
244 static opcode23 calls and 18 sqrt calls. Hot-owner inventories are
`nearest` 12/2, `nearest.t` 12/2, `trace` 42/2 and `pixel` 73/4 for opcode23/36.
Alternative branches are included; these are not dynamic execution counts.

`selfhost/src/back/x86/float-registers.bend` assigns up to 14 homes in
`xmm2..xmm15` to bounded, closed F32/canonical-copy regions. Parameters, setup
values, names crossing cuts, and names with any noncanonical definition remain
excluded. Inclusive intervals require the prior endpoint to precede the next
start; all writes count. `xmm0/xmm1` remain scratch. Right operands are captured
before overwriting an aliased destination. Canonical zero-extended word
semantics permit MOVD publication; arbitrary full64 words are not silently
narrowed. Original GPR frame metadata and conservative fallbacks remain.

`selfhost/src/back/x86/u32-float.bend` recognizes only the exact verified
`p111_rt_op` U64 signature with canonical state, opcode23/high0, a local buffer,
and count1/high0. Original verification still proves the readable eight-byte
cell. The emitter reads it, clears the upper32, performs `cvtsi2ssq`, and
publishes the zero-extended result with a full64 store. The pinned runtime
performs the same unsigned-low32-to-signed64 conversion instruction. Other
passes still classify this unary IR as a call: this first screen does not
compose new unary effect knowledge with XMM placement or private-memory passes.

The [checked API](../../selfhost/build/phase186/xmm-live-api02/report.json)
binds source SHA256 `4a4235c5193f95999c61a17096a619e6fd51c3e4873c509c76d20c5e59918424`.
The complete [focused-control report](../../selfhost/build/phase186/xmm-live-controls01/report.json)
passes XMM17, unary18, inline16 and operand15 metadata rows. Its observers pass
730 XMM, 105 unary, 590 inline and 45 operand checks; dependent groups repeat
some observations, so these totals are not unique test coverage. Unary results
come from seven exact frozen Phase112 case labels, including rounding ties,
UINT32_MAX, bit31 and ignored upper words. Five forced placements and three
upper-word variants exercise stack, callee-saved/transient registers, input
overwrite and pointer/result aliasing. Custom placement controls are explicitly
separate from original-IR verifier admission.

Read-only inspection of the [new emission](../../selfhost/build/phase186/xmm-live-x86-emit01/report.json)
against the [sixth emission](../../selfhost/build/phase186/sixth-x86-emit01/report.json)
confirms all 244 opcode23 calls disappear and 244 `cvtsi2ssq` sites appear.
Every other primitive ID/count remains unchanged: 41 helper sites remain,
including 18 sqrt sites. Ray assembly text shrinks 724,076→690,960 bytes.

| Owner | Static instructions, before→candidate | MOVD, before→candidate | Candidate XMM-home references |
|---|---:|---:|---:|
| `$product.nearest` | 1,098→896 | 132→72 | 106 |
| `$direct.nearest.t` | 967→765 | 132→72 | 106 |
| `$product.trace` | 2,578→2,187 | 317→359 | 0 |
| `$direct.pixel` | 2,340→2,015 | 202→275 | 0 |

Each nearest owner adds 56 MOVAPS instructions. Trace/pixel do not receive XMM
homes in this candidate; their changes cannot establish an XMM benefit.
RBP/RSP memory-operand counts are unchanged in all four owners. Counts include
address formation and all branches, not executed instructions or memory traffic.
Read-only ELF inspection gives `.text` 175,025→165,649 bytes, including runtime;
the exact old/new ELF hashes are in the runtime analysis below.

The [same-campaign runtime analysis](../../implementation/phase186/xmm-live-x86-runtime01-analysis.json)
revalidates 34 pilot and 27 timed outputs. Three position-balanced rounds compare
mature C, sixth (`before`) and this combined candidate on unchanged inputs:

| Case | Candidate/before median | Dispersion review |
|---|---:|---|
| active ray | 0.652618 | Flagged because the C reference varies; before/candidate spreads are 1.016/1.024 |
| numeric recurrence256 | 0.948484 | Unflagged |
| local fold | 1.005795 | Candidate spread 1.137; flagged |

Retain these as provisional bundle results. The ray change is 34.74% less median
time in this screen, but it does not separate XMM homes from opcode23 removal,
establish significance, or measure the full45 catalog. Repeat flagged cases and
measure emitted-code-verified ablations before acceptance. In particular, verify
zero XMM-home references in the disabled product. The current production route
is `x185_function_copied` → `x186_float_function` → `x186_f_place` →
`x186_x_select_frame`, which checks `x186_xmm_enabled`. The separate
`x186_x_function` route deliberately forces XMM for focused fixtures.

Sqrt remains deferred. Its source uses `(float)sqrt(float)`; the pinned runtime
actually emits SQRTSS for nonnegative/unordered inputs and calls `sqrtf` for
negative inputs. A bare replacement would remove that exceptional helper path.
The frozen corpus has only sqrt4, insufficient for NaN payload/class, negative
zero, infinity, subnormal and negative-input obligations. Opcode58 also remains
unchanged: its range/NaN guards precede truncating float-to-U32 conversion.

The accessor opportunity is separate. Each current `sr/sz/sx/sy` uses a
2,288-byte frame and eight sequential comparisons, materializing each Boolean
with CMP/SETcc/MOVZX before TEST/branch. Their constants are already folded;
`sr` remains identical assembly with 119 instructions in both emissions (ELF
padding prefixes differ). Generic comparison/branch selection and avoiding
unused implicit leaf buffers are plausible next hypotheses. No new accessor
optimization or accessor speedup is claimed here.
