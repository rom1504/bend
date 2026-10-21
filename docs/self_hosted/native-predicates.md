# Native predicate transport and address selection

[Phase123](../../implementation/phase123/README.md) extends the checked-hosted
Phase121 direct-QBE candidate. It is separate from the qualified Phase118 native
image and installed production compiler.

Inlining can expose comparisons whose0/1 result is widened into a Term, converted
through a Boolean match, then compared again with1. The native scalar pass already
has a versioned fact index. `predicate/model02.bend` adds a comparison-origin record
there, carrying the original U32 result, inversion and root/destination epochs.
Only an actual comparison seeds it. Copies preserve it; exact Boolean diamonds
can transport/invert it; unknown joins and intervening root writes prevent reuse.
An eligible eq/ne0/1 test becomes a U32 copy/xor, retaining the existing scalar
facts and verifier. This is not inference from low bits or from an arbitrary
runtime value. The ordinary fallback covers every unproved case.

The local identity is small: if the canonical root is `p ∈ {0,1}` and the
transported value is `p xor i`, testing equality with `k ∈ {0,1}` returns
`p xor i xor k xor 1`; inequality returns `p xor i xor k`. This only applies while
the recorded root is live and unchanged. It explains the constant/inversion rule
independently of the finite controls; the existing verifier still checks widths
and uses in every emitted function.

`scaled-address02.bend` changes the existing packed-array address producer's
literal scale operation. QBE1.3's amd64 instruction selector recognizes multiply
by1/2/4/8 when matching x86 indexed addresses. An equivalent shift does not match
that path. The producer uses the recognized operation, so masked index loads
and stores can become `(base,index,4)` instructions. Arithmetic stays U64 modulo
2^64; other shifts remain unchanged. This does not remove array bounds masks,
handle guards, ownership operations or runtime fallback.

Both changes are ordinary Bend declarations composed onto the exact pinned parent.
No Python/JavaScript compiler transformation or modified QBE toolchain is involved.
See the [experiment guide](../../selfhost/tools/performance/phase123/README.md)
for independent finite controls, ordinary-program checks, runtime ablation and
reproduction. Runtime improvement depends on generated shape; an unchanged
workload or a smaller static function does not demonstrate a speedup.

The measured amd64 candidate also uses GNU assembler branch alignment
(`-mbranches-within-32B-boundaries`). A smaller list loop regressed when its
compare/branch pair crossed a32-byte boundary; the same checked QBE recovers
performance with this policy. The [ablation](../../implementation/phase123/branch-alignment.md)
keeps ordinary assembly and hardware-specific conclusions separate. This is a
machine-build option, not a Bend IR rewrite, and is not silently installed.
