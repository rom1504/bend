Affine fallback fixture correction
===================================

The original fallback source incorrectly declared `+f: U32 -> U32` and reused
that closure. Function types have kind `Type`; a `+` parameter requires `Data`.
This is the exact rejected rule documented by `tests/grade/reject_closure.bend`.
The retained native45 `coverage-closures-64.bend` instead consumes every closure
once. The failed original source and its checked-run evidence stay unchanged.

`recursive-controls-fallback-v2.bend` passes a linear `f` to the next recursive
call and applies it once at the base. A duplicable Boolean selects the same
per-level arithmetic contribution used by the original independent sum oracle.
For each fixed input, `f` and that Boolean select the same function (xor85 or
multiply19), so all three literal outputs and the independent oracle file are
unchanged. No template parameter or unchecked closure duplication is introduced.

An indirect call still lies below pending recursive and external continuations.
The admission gate remains: record an actual planner refusal, or classify the
case as independently specialized/no-hit if ordinary preparation resolves it.
Output agreement alone does not count as evidence that a fallback path executed.

Use the existing v3 transport with:

    --metadata selfhost/tests/phase192/recursive-controls-v3.json --cases fallback

The new metadata keeps schema version2 and adds revision3. It pins the corrected
fallback, the already corrected sharing fixture, the four other original sources
and the original oracle, and records both source corrections. No driver or
previously used input was edited. No compiler or target job was run by the author.
