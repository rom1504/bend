This is a fresh follow-up corpus frozen before the final seven-choice policy
selection. It contains eleven new graphs, all with new `final-` names. The
original twenty-nine cases and eighteen original held-outs remain unchanged;
those older held-outs are reused regressions for the new selection.

Seven graphs use Unicode scalar boundaries, embedded NUL, combining marks,
supplementary characters and deep odd lengths. Lists cover unique ownership,
shared roots, shared tails and retained opaque String heads; Strings cover
unique, root-shared and tail-shared paths. Four further graphs replay the full
compiler parser source as List<String> lines and checker kernel source as String
characters, each with distinct unique/shared ownership. Dataset bytes are
snapshotted and pinned. They are representative payloads, not measured hotness.

The mathematical reference code and harness source are exact copies of the
original frozen versions. The existing preparation engine is reused with only
two directory-depth/ABI-path adjustments; the complete delta is pinned. Prepared
`controls-final-heldout01/harness.c` and `abi.h` are byte-identical to `train01`.
Graph construction, timing boundaries, observations, alias release order and
zero-live-word gates therefore stay exactly the same. The reference oracle was
computed without candidate output or any compiler/target execution.

Default repetitions are fixed at two for every case. All eleven workloads have
equal weight in a separately reported geometric mean; retain individual ratios
and label any later timing confirmation separately. Root freezes its selected
candidate before evaluation. No candidate choice, source repair or dataset
weighting may use these held-out results.

Prepare another fresh copy with `prepare.py --out FRESH_PHASE110_DIR --variant
reverse --split heldout`. The prepared `expected.jsonl` contains the complete
independent observations for those eleven names. No original oracle was edited.
