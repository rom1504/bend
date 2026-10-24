# P131-003 — expose and retain static facts across helper boundaries

Status: missing-value/literal exposure and selector V02 are native-qualified
in the final composition. Prepared-nullary selector V03 remains unqualified.

Hypothesis: existing static preparation already eliminates constant construction,
but helper boundaries hide the closed constructor tree or reintroduce literals
after preparation. Improve those boundaries before adding another cache/pass.

Exposing the exact missing-value body cuts its constructor calls3→0 and a mixed
hit/miss native lookup proxy takes9.81% less time. The broader source experiment
exposes419 remaining literal calls in the actual composed source, with explicit
erased type ascriptions. It preserves91 protected verifier declarations and11
proof-connected bodies exactly. Initial missing type inference is preserved as
a rejected attempt. Source byte growth is not runtime allocation growth.

Separately, a general small-selector admission fix lets the unchanged proved
max/min query compile as a local loop. Native proxy time falls0.245831→0.099911s
(59.36%). It retains ordering, callback-use and size limits. Ordinary text/shared
capture controls pass. Merge is unchanged, isolating the lookup mechanism.

Evidence: `selfhost/build/phase131/missing-mixed01`, `selector-jobs01`,
`selector-transfer-jobs01`, `literal-atoms-request02`,
`combined-literals-source01`, `combined-literals-admission01.json`;
[constant research](../../research/phase131/immutable-constants.md),
[selector research](../../research/phase131/safe-codegen.md).
