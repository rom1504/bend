# Bounded whole-segment traversal

After the static-image repair, both checked B1 and its self-emitted B2 overflow
while `nf_wrap_segments` traverses the full compiler's continuation list. The
100-frame B2 failure trace confirms repeated calls to that function; the last
small name-encoding call in the earlier B1 trace was not the root cause.

Use an accumulator and final reversal for `nf_wrap_segments`,
`no_wrap_registered`, and `no_entry_defs`. The latter two handle the corresponding
observer paths for large programs. Head work, refusal conditions, every product
field and output order stay exact. Together these changes add12 physical lines
in two modules and introduce no new data representation or compiler pass.

Actual full-library API controls pass24 small old/new product comparisons and
four65,536-segment cases. The large cases check complete products, order and
retained inputs, including9,363 flat/observer wrappers and14,044 composed wrappers.
The guarded process takes8.799s and558.8MiB peak RSS; this is a correctness test,
not a compiler speed comparison. The genuinely checked `compiler04` also passes
36 frontend cases, tiny split/ordinary JS equality and eight driver comparisons.
See [receipts](segment-controls.json) and
[runner](../../selfhost/tools/performance/phase90/bootstrap/segment-controls.mjs).

Failed iterations remain: compiler02 has a missing constructor brace, compiler03
has an affine-use rejection requiring `+entries` for capture by two alternatives.
They fail checking in7.725/8.842s, before emitting a compiler. Compiler04 fixes both.

Full-source B1 emission then reaches its120s deadline without C at1.111GiB peak
RSS. This is not a completed self-compilation and does not establish absence of
other scale limits. The next diagnostic uses its faster self-emitted B2, while
the separate native table-builder candidate targets the long append plateau.
The installed JS release and qualified native89 image are still unchanged.
