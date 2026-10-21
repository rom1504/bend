# P123-002: finite nested state can remain in field lanes

Status: source ceiling measured; automatic layout change rejected. [Design](../../design/phase123/typed-private-computations.md).

Hypothesis: repeated materialization of RLE's finite nested product state costs
enough to justify general native product-layout admission/representation work.
Test outer-shell-only and full explicit state arguments separately, with identical
algorithm/output and independent empty/mixed/heap-field controls.

Positive source ceilings are not compiler gains. Only implement a general checked
rule after identifying the precise restriction. Recursive/dependent layouts,
ownership and escaped/shared products require their original guards. If shell
removal is neutral, stop before expanding the representation machinery.

Both explicit variants flatten all four lanes, so their10–14% RLE gains do not
isolate shell depth. Independent56-result ordinary controls pass. The bounded
strict-Sigma-subterm rule fails to admit the original nested Pair aliases; keep it
separate. See the layout results and ready-call audit in the Phase123 tools.
