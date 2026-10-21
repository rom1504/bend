# Phase118 guarded F32-to-U32 projection

Source-only implementation/audit; no compiler or target runs. The existing
ordinary numeric recurrence calls `p111_rt_op(58)` once per iteration. This
overlay removes that call through the existing post-verification renderer hook.
It does not add a generic IR instruction or relax verification.

The exact accepted shape is a U64-result call to `p111_rt_op` with the literal
state local, literal U32 operation58, an existing `p114t_buffer` local, and
literal U32 count1. Original verification still establishes runtime-import
signature, buffer capacity and source provenance. The final renderer's existing
reserved `p114t_` namespace supplies all temporaries. Three branch labels use
the shared site counter, which advances by3; a `next <= 4294967292` gate prevents
counter wrap. Every other statement delegates to `p118f_original_stmt`, captured
verbatim from current `u32-divmod.bend` except its declaration name. Existing
div/mod, transport and sized-call behavior therefore remain available.

The reviewed runtime source is
`selfhost/build/phase118/runtime-u32-01/runtime.c`, whose `f32_to_u32` computes
`v >= 0.0f && v < 4294967296.0f ? (u32)v : 0`, with a low32 bitcast to single.
The projection loads exactly one full64 argument word, copies its low32 bits,
and casts those bits to a QBE single. It compares with exact single constants0
and2^32. Conversion occurs only in the accepted branch; the other branch writes
a full64 zero. The valid branch uses word-result `stoui`, then explicit `extuw`
to the original full64 destination. No integer or float input is re-evaluated,
no scratch store is removed, and the argument is read before the destination is
assigned. The primitive is scalar and transfers no owned value.

For finite `0 <= v < 2^32`, truncation toward zero lies in U32 and matches C's
conversion. Negative zero passes the bounds and produces zero. Negative values,
both infinities, NaNs and values at/above2^32 take zero. The largest finite F32
below2^32 is4294967040. The comparisons are single precision, use no fast-math
assumptions, and preserve the current runtime's numeric result. Both comparisons
are pure here; the Bend/runtime boundary does not expose floating environment
flags or enable traps. No NaN payload-preservation or FP-environment equivalence
claim is made.

Pinned QBE1.3 `doc/il.txt` documents `cast`, `cges`/`clts`, `stoui` and `extuw`.
`amd64/isel.c` swaps less-than operands and uses ordered above/above-equal
conditions; unordered operands do not pass these guards. Its word-result
`Ostoui` path converts through a signed64 result, then copies the word. Every
guarded input fits that signed64 range; explicit `extuw` preserves U32 values
at and above2^31 at the full64 ABI. The parser accepts `s_4294967296` as a
single constant, and this power of two is exact. No pinned QBE changes are made.

`f32-to-u32-controls.bend` is an ordinary argv-seeded source, with 13 literal
expected output lines: positive/negative zero, negative integer/fraction,
positive fraction/truncation,2^31, the largest F32 below2^32,2^32,2^33, both
infinities, and arithmetic NaN. Infinity/NaN use the same ordinary `F32.div`
construction as the retained Phase52 `float_specials.bend`. Default seed1 gives
the frozen oracle; numeric argv intentionally changes inputs. This is neither
a malformed-IR probe nor a test of native failure behavior.

Root should first check the composed Bend/API, then check/emission/build/full
output of this source and the existing numeric recurrence, inspecting that
op58 reaches `stoui` and disappears from its hot loop. Original div/mod controls
also check fallback composition. Complete native output is required before
timing; source inspection predicts removal of call/switch/save overhead, not a
measured benefit. The original numeric slowdown audit remains independent and
does not establish that div/mod caused its observed screen median difference.
