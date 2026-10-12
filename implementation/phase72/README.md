# Phase72: native product transport

Implementation checkpoint; installed Phase70 remains unchanged until release
qualification completes. [Design](../../design/phase72/product-transport.md).
One agent, no delegation or PR comments.

The saved-C BST falsifier reduced694→644ms (7.20%), versus335ms upstream.
Compiler01 reproduced that mechanism with a one-line result-shape query change:
688→640ms (6.98%), versus331ms upstream. Compiler02 adds checked private-worker
admission for products discarded on some exit paths. Its Array.map measurement
is733→559ms (23.74%), versus302ms upstream. The hot backedge stays flat and the
discarding exit retains its ordinary materialization. Raw admission is unchanged.

The second BST campaign was noisy: medians690→698ms, while the two candidate
BST C files and executable binaries are byte-identical. All timings are retained;
the broader final measurement will determine the reported runtime result.

Production changes so far: +13 net Bend lines across two existing modules;
no new production module or runtime change. Checked B1 frontend36 and the
raw31 controls pass;2,992 non-native generated functions are exact. Eighteen
inherited focused native cases pass, as do the two corrected new scalar/array
loop controls. Three early versions of the new array fixture were rejected by
both compilers (annotation, illegal sharing of Type, computed match); these
are preserved fixture failures, not compiler regressions. Broader validation,
compiler-cost measurement and release qualification are pending.
