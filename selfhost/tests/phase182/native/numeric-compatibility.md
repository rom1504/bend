# Numeric fixture correction

The original `numeric.bend` was invalid source under upstream `9a4223d` as well
as the self-hosted parser. Upstream `bend2/bend.ts:2275` recognizes separate
U32, Nat and F32 literal forms. Its `parse_term_num` explicitly rejects a Nat
literal whose decimal value exceeds `4294967295` (`bend.ts:2300`). Native Nat
values can be wider than the source literal syntax permits.

The first failure is retained at
`selfhost/build/phase182/numeric-qbe01/report.json` and
`selfhost/build/phase182/numeric-qbe01/compiler.stderr`. The exact original
fixture is preserved as `rejected/numeric-invalid-nat.bend`; it is intentionally
invalid and must not be treated as a passing native fixture.

The corrected fixture replaces four oversized Nat literal tokens with valid
operations:

| Required value | Valid expression |
| --- | --- |
| 4294967296 | `Nat.add(4294967295n, 1n)` |
| 4294967553 | `Nat.add(4294967295n, 258n)` |
| 4294967808 | `Nat.add(4294967295n, 513n)` |
| 281474976710655 | `Nat.add(Nat.mul(65536n, 4294967295n), 65535n)` |

The final expression stays within 48 bits at every intermediate step. Building
2^48 first and subtracting one would be wrong under bounded native Nat
arithmetic, because the intermediate may already wrap.

Wide float literals remain unchanged. `f_literal` selects `f_float` for tokens
containing a decimal point; `f_float` calls `F32.read`, followed by the existing
finite-value check. There is no U32 integer-part limit on that path. The reported
`invalid or unsupported numeric literal` message originates in `f_number`,
which correctly enforces the same literal bound as upstream.

No parser/kernel/namespace code changed. The twelve expected Boolean results
are unchanged. This correction was inspected as source only; root owns the
fresh checked compilation and execution result. The old failing receipt remains
immutable and does not qualify the corrected fixture.

The next attempt, `selfhost/build/phase182/numeric-qbe02/report.json`, exposed
two more invalid fixture expressions: prefix `-1.0` and `-0.5`. Upstream's
`parse_term_base` (`bend.ts:1817`) has no prefix-minus case, and the numeric
literal regex (`bend.ts:2275`) has no leading sign. Negative F32 values are
written with `F32.neg`, as in upstream `tests/base/f32_round_zero.bend` and
`tests/base/f32_to_nat_wide.bend`. The exact failing fixture is preserved in
`rejected/numeric-invalid-prefix-minus.bend`. The maintained fixture now uses
`F32.to_u32(F32.neg(1.0))` and `F32.round(F32.neg(0.5))`. This is another fixture
correction, with no parser change or altered expected results.

Before compiling native controls, run the independent source preflight from
the repository root, inside the root-owned guarded lane:

```sh
selfhost/.assets/bin/bun selfhost/tests/phase182/native-preflight.mjs \
  --out selfhost/build/phase182/native-preflight01
```

The output directory must be fresh. Optional `--manifest`, `--upstream`, and
`--assets` arguments select explicit pinned inputs; the default manifest must
select Phase182 upstream `9a4223d577ba56a0cb53d1fd952d2b481c38930f`. The script
checks every top-level `native/*.bend` with upstream `book_load`, `book_valid`,
and zero unresolved holes, excluding `rejected/`. It preserves per-file source
pins, classifications and diagnostics in `report.json`, returns nonzero on any
refusal/crash, and does not emit or execute programs. Source acceptance does
not establish runtime output, expected exit behavior, or a BendTT proof. The
script was prepared without running the source preflight; root owns that result.
