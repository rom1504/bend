# P78-004: injective compact C symbols

Current FID identifiers encode every code point as decimal text; identifiers take
26–30% of the three emitted files. Preserve ASCII letters/digits and escape all
other code points with `_decimal_`, including underscore. A fixed `FID_n` prefix
separates generated symbols from runtime-reserved names. This is an injective
encoding, not a hash: there is no probabilistic collision argument.

Expected benefit: fewer encoding allocations and fewer characters in rendering,
layout, hashing and downstream C parsing. Compare complete emitted C after
independently translating old FID tokens using a C-aware token scan; independently
check native semantics and execution timing before promotion. Do not compare
untranslated bytes or claim runtime gain from source size alone.
