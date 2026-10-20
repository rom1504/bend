# Ordinary unary-constructor packing controls

Four small positive Bend sources and independent literal stdout are frozen by
`manifest02.json`. Root first runs the existing Phase114 frontend preflight:

```
BUN selfhost/tools/performance/phase114/controls/frontend-preflight.mjs \
  CHECKED_API selfhost/tools/performance/phase114/controls/packing/manifest02.json \
  selfhost/build/phase114/packing-frontend02
```

Then the existing `controls/prepare-jobs-v2.py --manifest ...` prepares normal
checked emission/build/complete-output observation jobs for the four cases.
No compiler API or generated target was run by the control author.

The original `manifest01.json` and Nat fixture remain unchanged. Parent-run
`packing-preflight01` checked the other three sources, but rejected the original
Nat fixture because its decimal literals exceeded the frontend's U32 literal
accumulator. Version 2 builds the same boundary values using `Nat.mul`,
`Nat.add` and `Nat.sub` on supported literals. Every intermediate stays within
the Nat limit, and all independent expected stdout bytes are unchanged. Its
manifest pins the failed receipt and original source; the new source still
requires its own frontend check.

- `unary-scalars`: zero, one, signed boundary and maximum U32; two distinct unary
  constructor identities; neutral arithmetic identities; Char and F32 fields.
- `unary-nat-boundaries`: 0, 2^40−1, 2^40 and 2^48−1, plus repeated extraction of
  shared values formed by ordinary arithmetic on either side of the limit.
- `unary-owned-strings`: empty, literal and allocated strings; nested unary
  wrappers; two constructor identities; retained external aliases and release.
- `unary-nested-tree-list`: constructor-sensitive scalar leaves inside lists
  and binary trees, U32 wrap, and repeated traversal of a shared constructed tree.

Phase68 was inspected before writing these sources. Its useful controls were
raw-core programs and C instrumentation, rather than reusable ordinary Bend
fixtures. This suite transfers the exact numeric boundary and alias questions
into positive checked-source programs. It does not reuse instrumentation,
foreign declarations, fail-stop cases or malformed ABI inputs.

Expected tree/list values are independent arithmetic: the mixed list totals202
modulo2^32; the small tree totals108; 128 leaves worth103 total13184. Other outputs
are literal numeric readbacks and Unicode string operations. Complete outputs
prove finite semantic agreement, not that packing actually occurred; admission
and emitted-code observations remain separate.
