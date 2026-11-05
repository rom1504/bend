# Phase165 independent emitted-memo audit

The intended ablation is present in the acquired C: all six native checker memo
edges disappear, while the compiler's native-recognition table remains exact.
This is a source/emission audit, not a claim that the candidate completes the
same checker workload or is faster. No compiler, machine build or workload was
executed by this audit. Exact pins and static observations are in
[`emitted-memo-audit.json`](emitted-memo-audit.json).

## Acquisition identity and policy

`tools/acquire.py` audited SHA256:
`4c0ef9640c30206792e8e33309b5e2ce5e70ca924e9b6fc51cf0a530e90d0119`.
The concrete source and Base inputs match the original preparation and additive
support receipts. All acquisition input pins were independently reread and
verified. The failed `original01` remains a failure: zero C bytes, exit 2,
`No such file or directory`. The four-file effect closure was then added under
the separate `source-effects01` receipt; no earlier manifest was rewritten.

`original02` checked emission reproduces the 4,628,175-byte seed C exactly,
SHA256 `b41edf49ccdb3846853955e5b89cf13c199b38e5d6fbe54d2c492a84fef519e3`.
`memo01` checked emission produces 4,626,981 bytes,
SHA256 `9ac086b9102248545cb978d0bd9fe6998893bfd22566798be9bf80c81ace5f48`.
Both finish with empty stderr. These acquisition checks execute the original
seed's checker, not the newly generated candidate checker.

The executing seed is the pinned Phase160 bounded-search-GC image
`1f41eadeb854ab06f2b81b8fb0d11ae7178c79022cd2e56494d700546f612f39`.
Emission has no `--no-check`; it fixes `--threads 1 --gpu off`, clears ambient
`BEND_*` settings and sets `BEND_RC=0`, `BEND_NO_FREE=1`, `BEND_AUTO_PAR=0`.
Machine acquisition uses the same pinned Clang `-O2` command and include order
as that seed, differing only in C input and output paths. The capped runtime
header precedes the vendor include directory; its inverse one-line substitution
reconstructs the pinned original header exactly. Candidate acquisition finished
with empty machine stderr; binary SHA256 is
`94c88365f9d1c37dee4d2af575fb29c15d192a035ce0b394863d7cb565259e01`.

One tooling limit remains: `--preparation` and `--support` are pinned as files,
but `acquire.py` does not itself interpret their product records. The independent
input-to-receipt comparisons above close that gap for these concrete two runs;
the tool alone is not a general source-provenance validator. Resource admission
belongs to the outer guard, not this acquisition script.

## Actual checker call sites

The audit masks C strings/comments, then locates executable calls in generated
function bodies. Original C contains twelve memo calls: six operational edges
and six `W_Chk_dmemo_d*` wrappers. Candidate C has **zero** `F_Chk_dmemo_d*`
identifiers outside strings/comments, and no residual `F_Chk_dp165memo_d*`
helpers: the trivial Bend fallbacks were folded into their callers.

| Source operation | Original C | Candidate C |
| --- | --- | --- |
| `term_cell`, check.bend:1762 | `F_Chk_dterm__cell`, line 20194, allocates native memo for a new cell | line 20185 uses `K349()`; line 20184 constructs constant `C1(8, IMM(0))`, the `Qnt{NoSp{}}` fallback |
| Cell forcing, check.bend:2194 | `D_Chk_dwnf_drun`, line 19613, calls `has/get` and may reuse the memo | line 19608 directly follows the `v`/`FVar` path; cache-hit branch absent |
| Force return, check.bend:2238 | same worker calls `set` | candidate line 20001 returns `term_cellv` into the state directly |
| Cell comparison, check.bend:5423–5431 | `F_Chk_dcmp_drun`, line 64705, calls `same/link` | line 64692 lacks the identity shortcut and link; complete value comparison remains |

`F_Natives` still returns a byte-identical constant body (only its generated
function name changes). It retains all six `Chk.memo.*` strings, so the candidate's
policy for compiling future programs is unchanged. The complete lexical
`F_Map_d*`/`F_String_d*` function inventory is also identical. This last check is
a static unchanged-frontier screen, including declarations, not a dynamic work
count or proof that all unrelated machine instructions are identical.

The runtime header still defines native memo functions unconditionally. Their
presence is not an executed checker edge. Conversely, the no-memo Bend fallbacks
are intentionally not equivalent at their direct memo API: `same` always returns
false and `get` is identity. Required semantic observations are complete checker
outcomes and exact reports, including invalid-body refusal; timeout, exhausted
fuel, early failure or a partial unsafe report cannot count as a fast result.
