# P124-002: remaining local-case frame calls

Hypothesis: after ready-helper/local-resume admission, existing frame expansion
misses renamed case scratch buffers and retains avoidable runtime calls. This is
separate from P124-001; reject added complexity if matched execution is neutral.

Static ordinary controls retain one/three frame callsites in list/tree owners.
`p114t_buffer` recognizes old fusion buffers, whereas local tables manufacture
`p114h_case_i_local_scratch`. Globally accepting these strings would be unsound:
the global verifier does not reserve this namespace. The separate Bend overlay
visits only already authenticated H frame lists, requires the actual active buffer
and an exact factory name, and reuses the existing frame template. Original
verifiers/runtime/ownership remain unchanged. See `frame-buffer/README.md`.

Checked source03 and twelve pure admission/refusal controls pass. Paired original
RLE/lexer execution versus ready-only is the decision gate; no full image build.
The actual result and promotion decision will be recorded in the Phase124 report.

Decision: **exclude** from the selected source. Twelve pure predicates and18
ordinary timed outputs pass. RLE median1184/1199ms (1.25% less), lexer514/525ms
(2.10% less); paired two-point ratio0.98326. One RLE candidate sample1272ms exceeds
all parent samples. This is weak profitability evidence for four extra helpers
and a context-specific renderer. Preserve checked source03 and the negative
selection decision; no broad validation or installed promotion of this overlay.
The capability may be useful later with a larger measured case-heavy workload.
