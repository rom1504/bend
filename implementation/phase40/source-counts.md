# Frozen checked06 source accounting

Latest [source-counts02](../../selfhost/build/phase40/source-counts02.json) compares
starting Phase39 checked05 with Phase40 checked06 API
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`.
Earlier [source-counts01](../../selfhost/build/phase40/source-counts01.json) retains
the rejected checked05 source accounting unchanged. These are static observations,
not compiler throughput or generated-program speed measurements.

| Quantity | Phase39 | Checked05 | Checked06 | Change06 /39 |
|---|---:|---:|---:|---:|
| Physical Bend lines |18722|18860|18863|+141|
| Nonblank Bend lines |16031|16153|16156|+125|
| Source bytes |766734|775315|775545|+8811|
| Definitions |2087|2104|2104|+17|
| Laws |640|640|640|0|
| Types |71|71|71|0|
| Modules |70|70|70|0|

Runtime remains byte-identical:663physical/653nonblank lines,53346bytes,
SHA256 `51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49`.
Counts cover manifest Bend modules; generated compiler images and experiment/tool
infrastructure are excluded. Checked06 adds a typed Nat-first/data-result admission
restriction after checked05's ray performance rejection. Retention and installation
still require semantic, cost, timing and release gates bound to the selected API.
