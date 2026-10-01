# Direct recursive component investigation

Status: design authored; no Phase39 execution or compiler change yet.

[Design](../../design/phase39/components.md) and
[prospective experiment](../../experiments/phase39/P39-003-components.md).
The baseline is installed Phase37 checked03; previous Phase37 prototype timings
are not measurements of this rebase. Root owns all target execution.

Read-only findings: tree-bitonic has four saturated `warp` sites (three normal,
one tail) inside the existing guarded scalar bench. Finite leaf/zip selectors
are already present. The expression family already has an iterative direct
`eval` fold, so its independent experiment must target the still-generic tagged
constructor producer instead of claiming that existing optimization as new.

Results, failures, controls and promotion decision will be appended here after
root execution. No production admission rule is established at this point.
