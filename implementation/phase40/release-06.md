# Phase40 checked06 release

Checked06 is installed. Installation, local release verification and all42
ordinary/relocated CLI checks pass. The [final audit](final-conformance/gates.json)
closes15 groups and227 unchanged canonical snapshot identities;
[integration](integration.md) records the separate semantic scopes and preserved
failures. The small [release receipt](release-06.json) binds existing report hashes.

Installed API SHA256:
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`.
Runtime SHA256 remains
`51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49`.
Canonical checked source SHA256 is
`541bcc50ebc8b51659dac1fbbf252ab19f91888c6de542292805740e989642b8`.
The installed release is `equality-derived-b1`, with `newBootstrap=false`,
retaining genuine checked B1 parent
`a4a8f2805dc7afa45a244cc722311fa329bf5a90a5a2a8a81d6b433ae2ddfe07`.
This is checked-parent derivation and installed verification; no new bootstrap
or fixed-point claim is made.

The release retains the direct unfused List and Nat-to-data continuations,
canonical `List<&2,U32>` proof, original tagged intermediates, dependency/host
guards and public fallbacks. Nat-to-scalar entry preserves existing scalar
island selection. Lexer changes remain a saved-JavaScript experiment.

Phase39 checked05 API
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`
and its closed history remain preserved. Checked05 Phase40's raytrace regression
and inherited diagnostic failures remain evidence; the selected corrected06
45-point record explicitly combines42 byte-identical reused points and three
fresh measurements. It does not represent45 newly timed points.

Source counts remain those of the frozen corrected06 report:70 modules,
18863 physical/16156 nonblank Bend lines,2104 definitions,640 laws and71 types.
Relative to Phase39 this is+141 physical/+125 nonblank lines,+17 definitions;
law/type/module counts are unchanged. Runtime remains53346bytes. These static
counts exclude generated APIs and experiment tooling and make no speed claim.

The ordinary/relocated smoke takes50.700s with607404032bytes peak process-tree
RSS. The final audit supervisor takes7.034s. These are validation durations,
separate from compiler-request and generated-program execution measurements.
