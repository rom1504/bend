# Earlier unchecked prototype survey

Pinned upstream: `6018e28ecc67cf1fffc0c20c64b11023474c2df8`.

This is an output-comparison survey of a declared subset, not full language or proof-checker conformance.

| Namespace | Exact output matches | Selected programs |
|---|---:|---:|
| run | 64 | 69 |
| compile | 95 | 95 |
| base | 22 | 23 |
| show | 2 | 7 |
| **Total** | **183** | **194** |

## Non-passing cases

| Test | Observed limitation |
|---|---|
| `run/harness_cache_compile_double.bend` | Function-value readback is not implemented. |
| `run/harness_cache_purity_grow.bend` | Function-value readback is not implemented. |
| `run/harness_cache_purity_shrink.bend` | Function-value readback is not implemented. |
| `run/harness_cache_stats_flip.bend` | Function-value readback is not implemented. |
| `run/nat_overflow.bend` | Nat overflow is detected; error prefix/exit formatting differs from the upstream harness. |
| `base/read_bounds.bend` | File-open errno/message formatting differs. |
| `show/char_unicode.bend` | Character, tuple, string escape, or array readback differs. |
| `show/literal_readback.bend` | Character, tuple, string escape, or array readback differs. |
| `show/nullary_adt_scalar.bend` | Type-value readback is not implemented. |
| `show/nullary_adt_table.bend` | Type-value readback is not implemented. |
| `show/string_escape.bend` | Character, tuple, string escape, or array readback differs. |

The raw report preserves expected and observed output, stderr, and exit status for every selected test.

## Local and bootstrap validation

64/64 local checks pass. Nineteen named positive fixtures were accepted by the upstream checker; five malformed/unsupported inputs must be rejected by the rewrite, and forty additional cases check wrapping U32 arithmetic. Stages 2, 3, and 4 of the compiler agree byte-for-byte.

The upstream checker was not used inside the self-hosted compiler or during its normal compilation of these upstream programs. Its role was checking/bootstrap-compiling the compiler source and independently checking the nineteen local positive fixtures.
