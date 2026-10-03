# Frozen checked05 source accounting

[Static identity/count report](../../selfhost/build/phase40/source-counts01.json)
compares starting Phase39 checked05 with candidate Phase40 checked05. This is
static source accounting; it does not measure compiler throughput or program speed.

| Quantity | Phase39 | Phase40 checked05 | Change |
|---|---:|---:|---:|
| Physical Bend lines |18722|18860|+138|
| Nonblank Bend lines |16031|16153|+122|
| Source bytes |766734|775315|+8581|
| Definitions |2087|2104|+17|
| Laws |640|640|0|
| Types |71|71|0|
| Modules |70|70|0|

Runtime remains byte-identical:663physical/653nonblank lines,53346bytes,
SHA256 `51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49`.
Counts cover manifest Bend modules; generated compiler images and experiment/tool
infrastructure are excluded. Candidate retention and installation still require
all scoped semantic, cost, timing and release gates on this same checked API.
