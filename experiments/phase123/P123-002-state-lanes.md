# P123-002: finite nested state can remain in field lanes

Status: planned. [Design](../../design/phase123/typed-private-computations.md).

Hypothesis: repeated materialization of RLE's finite nested product state costs
enough to justify general native product-layout admission/representation work.
Test outer-shell-only and full explicit state arguments separately, with identical
algorithm/output and independent empty/mixed/heap-field controls.

Positive source ceilings are not compiler gains. Only implement a general checked
rule after identifying the precise restriction. Recursive/dependent layouts,
ownership and escaped/shared products require their original guards. If shell
removal is neutral, stop before expanding the representation machinery.
