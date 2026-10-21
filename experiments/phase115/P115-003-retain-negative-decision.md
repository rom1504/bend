# P115-003: keep a rejected H decision in control flow

The retained-plan experiment passes six exact policy matrices and saves22–36%
of four-policy emission work. However, materializing every alternative is
unnecessary for an ordinary compilation. Test a smaller implementation: after
H has rejected, try the original R and G routes, then generic/fused fallback
without invoking H again. R/G admission, precedence, ownership, generic code
and all final verification remain unchanged.

The pure H query sees identical segment/index/ready inputs at the original first
and repeated call. Its first negative result is therefore sufficient to choose
the second fallback. Retain that fact in the branch structure rather than adding
a global cache, option record or trusted external certificate.

Compose only this three-declaration overlay onto qualified source 02: replace
p114hf_planned and add two private fallback helpers. Compare full ordinary QBE
emission against the independent unchanged API on all six frozen inputs, five
rotated paired rounds after one warmup. Both engines receive the same checked,
verified IR; all common emission work stays inside the timed call. Preserve every
output, and require exact equality before assigning a timing. This measures full
emission, not whole requests or native compiler execution. Reuse machine evidence
only when exact QBE identity to an already checked product is established.

Do not automatically promote or run a full native rebuild for a small gain.
This tests whether the experiment yields a simpler useful compiler change, not
whether recursive research acceleration has already been demonstrated.
