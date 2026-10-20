# Independent source review, modules01

No concrete semantic defect was found in the frozen `facts`, `emit` and `entry`
modules. Inventory SHA-256:
`7939f8425d94d4a1d666689ec4bf676c96af37b2b0dec2c86d70b5268795fe37`.
The review checked the exact module, parent source/admission/API, runtime source
and runtime object hashes. Only `p114so_stmts` is replaced; original IR,
verification, whole-buffer audit, runtime and public/recursive ABIs are retained.
An offline declaration comparison against composed source SHA-256
`a1185c8db5c5ca4b8e1ebbe7b8dc473cde5afa5e372589058a05484e14cfeb9e`
confirmed that sole parent replacement and 18 added declarations.

Each fact means that the current U64 local's low 32 bits are the bit
representation of an already emitted immutable QBE `s` temporary. Facts arise
only from the actual output of conversion 23 or arithmetic 26–29, or an exact
unchanged U64 local copy. They do not follow parameter kinds, loads, memory,
unrecognized operations or arbitrary U64 definitions. At most 16 are retained;
eviction reduces reuse without altering emitted values.

The group renderer reads both operands from the old fact list, while the result
step removes any old destination binding and installs the newly emitted lane.
Comparison results remove the destination fact without inventing a float lane.
The same-name input/result case therefore uses the previous input value. A copy
looks up its source before rebinding its destination, including self-copy. An
alias may retain an old lane after another word local is overwritten because
the cached QBE temporary itself is immutable and has a distinct reserved name.

ID 23 deliberately uses the original scalar-operands text: it converts the low
32-bit unsigned integer, even when its input has a cached float interpretation.
Its output temporary is exactly `site + 4`, as required by the fact producer.
Other supported operations retain the selected F32 operator and still emit
every original word result with bitcast and `extuw`. Reuse removes only the
word-to-F32 bitcast round trip; it does not combine arithmetic or bypass an F32
operation's rounding. No new arithmetic NaN payload guarantee is claimed.

Only uninterrupted recognized groups and exact copies preserve facts. Every
other statement, width pair, unsupported call, branch or control transfer uses
`p114so_old`; that path recurses through the overridden entry with an empty fact
list. Nested branch rendering remains original. This also prevents facts from
crossing loop edges or lacking dominance at later uses. The emitter keeps the
parent room check and reserves nine slots in the shared counter per group,
whether or not all operand temporaries are needed.

The ordinary `copy-chain.bend` fixture includes copies, lexical rebinding,
unsigned conversion, a branch and unsupported `sqrt`. Its complete output alone
does not establish that lowering retained actual N111 copies or repeated
eligible destination names: lexical shadowing may become fresh IR names. The
author's diagnostic must report those route occurrences separately before
claiming copy/rebind path coverage. The review ran no compiler, API, native
program or benchmark and makes no performance or qualification claim.
