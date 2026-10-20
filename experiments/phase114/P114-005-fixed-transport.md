# P114-005 — expose fixed continuation transport to QBE

Hypothesis: opaque frame/pop/get calls prevent QBE from combining small runtime
operations with surrounding code. Expand exact verified operations in final
structured statement rendering, with unchanged fallback, runtime and register
bank. Source factories establish scratch separation; spelling alone does not.

The Bend implementation passes checking, exact source/runtime admission,12
structural groups and11 ordinary complete-output programs. Two independent
source reviews found no concrete defect. The original final verifier remains
first; an additional namespace check prevents temporary collisions.

Three paired rounds, milliseconds:

| Program | Source31 | Transport01 |
|---|---:|---:|
| tree-bitonic |555|523|
| lexer |358|345|
| list-pipeline128 |707|674|
| expression128 |489|451|

The four-case geometric mean elapsed ratio is0.94529, about5.47% less time;
still9.830× upstream on this selected subset. All36 output/count observations
pass. This is a bounded final-emission improvement, not broad parity. It does
not touch G/public builders that emit helper calls directly as QBE strings.

Evidence beneath `selfhost/build`: `phase114/transport-admission01`,
`phase114/transport-structural01`, `phase113/p114-transport-screen01-jobs`,
`phase112/p114-transport-screen01-measure`. Source SHA256:
`535249cc65d1b4fd03eef25819959eeb35644cb0d93ab109b37d0c8ea3a4de90`.

Next combine with packing and recursive regions. A broader jump/return change
requires explicit logical-width context and unchanged inactive-word clearing;
it is not authorized by these frame templates alone.
