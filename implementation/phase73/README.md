# Phase73 work in progress

[Design](../../design/phase73/native-parity.md). Installed Phase72 is preserved.
The initial experiment tests the cost of the native backend's rejection of
non-tail recursive private workers. Diagnostic images are not release candidates.

## First implementation checkpoint

The first architectural falsifier failed: enabling non-tail C recursion made
list645→970ms,expression450→548ms,Tape899→1298ms. No production recursion
change was made. Counts then identified excess RFC wrappers:5606(list),4254(BST),
16368(Array.map) per16-input cycle relative to the same upstream inputs.

Compiler03 implements general typed constructor-sharing facts. Paired medians:
list646→340ms(upstream301),BST635→407(316),Array.map561→460(300). Compiler04
adds borrowed scalar observers, Tape893→536(upstream298). These are interim
local measurements; final whole-corpus and qualification gates are pending.
Compiler05 also retains checked scalar parameter widths at scheduler entries.
All12 acquisitions return correct smoke checksums; frontend36 and six focused
controls pass, including100k-deep input and a parallel shared root. Fixturev1
incorrectly used an affine scalar twice; both compilers refused it. Version2
adds the required sharing annotation and passes. Original attempts are retained.

Installed Phase72 remains unchanged. No full-conformance, parity, compilation
speed or new release claim is made at this checkpoint. Methods and exact raw
receipts live under `selfhost/tools/performance/phase73` and
`selfhost/build/phase73`; final capsule will freeze the evidence.
