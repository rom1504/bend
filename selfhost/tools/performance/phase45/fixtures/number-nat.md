# Independent Number-Nat controls

`number-nat.bend` contains 16 public test functions and five small helpers.
The catalog acquires the source through `bench(7) = 6`; it does not encode
BigInt values or replace the untimed boundary controller.

The selfhost public ABI represents Nat as BigInt. Pinned TypeScript uses Number
internally. Compare normalized mathematical values across compilers; compare
exact JavaScript values, errors and host-hook effects between the selfhost
predecessor and candidate. All valid Nat values below the 48-bit maximum are
exactly representable by Number.

Let `B = 4294967296n` and `M = 281474976710655n`.

| Operation | Independent expected result |
| --- | --- |
| identity at 0, 1, B−1, B, B+1, M−1, M | The same Nat, retaining BigInt at the selfhost public boundary. |
| constructed(1) | B; the source computes it from the largest permitted compact literal. |
| constructed(M−B+1) | M. |
| successor(M−1), add(M−1,1), add(M,0) | M. |
| subtract(0,M), subtract(M,M) | 0. |
| subtract(M,B) | 281470681743359. |
| quotient(M,B), remainder(M,B) | 65535 and 4294967295. |
| quotient(M,3), remainder(M,3) | 93824992236885 and 0. |
| quotient(M,M−1), remainder(M,M−1) | 1 and 1. |
| quotient(value,0), remainder(value,0) | 0 and value. |
| to_word(B), to_word(B+1), to_word(M) | 0, 1 and 4294967295. |
| from_word(4294967295) | 4294967295 as a Nat. |
| shift_left/right(word,0) | The original word. |
| shift_left/right(word,count), count ≥ 32 | 0, including counts B and M. |
| nested(M−1) | M after construction/projection through a private tagged Counter. |
| public_counter(B) | Ordinary public Counter with a BigInt field; no private Number object may escape. |

Also check shift counts 1 and 31 against independent BigInt shifts masked to
32 bits, and `less` around B and M against mathematical integer comparison.
Do not use JavaScript bitwise operations as a Nat arithmetic oracle.

`successor(M)`, `add(M,1)`, `constructed(M−B+2)`, `nested(M)` and
`error_check(M)` must overflow. Selfhost's current error is an `Error` with
message `a Nat past the largest immediate 2^48-1`. Pinned TypeScript throws a
string; raw thrown-object identity is not a cross-compiler assertion. Compare
the selfhost predecessor/candidate Error-constructor hook event order, one
error construction, reentry into `error_check(0) = 1`, and a successful replay
`error_check(7) = 8` after unwinding. Number fallback must not duplicate an
observable error or retain an active private proof during the hook.

Values such as negative BigInt or M+1 are malformed at the language boundary,
but the existing generic public JavaScript path can sometimes return them
unchanged. Compare predecessor/candidate observations rather than asserting
that every export rejects them. These are ABI fallback controls, not evidence
that the language admits such Nats.

Both parsers cap compact source Nat literals at 4294967295n. The separate
`number-nat-too-large.bend` must refuse 4294967296n rather than truncate it.
Check refusal with the checked frontend harness separately from acquisition of
the valid fixture. Do not confuse this compact-literal cap with the 48-bit
runtime arithmetic limit.

No target compiler execution was performed while authoring these controls.
