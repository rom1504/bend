# P85-003: captured contexts from expression choices

Registered after default bytecode/optimized-code inspection, before paired
candidate execution. Lexer bytecode allocates block contexts; its optimized
TurboFan OSR body retains an80-byte context on the common cursor path before
the EOF branch. Four generated zero-argument immediate arrows are plain
if/return/else/return expressions and can be lowered to lazy ternary expressions.
One declaration-bearing arrow is rejected by the bounded transformer.

Test one exact-hash-bound disposable image, no Bend/production changes. Genuinely
prepare its own Base cache; interleave three rounds against original B2 over
Numeric/Map/Functions65/Lexer with five ordinary full requests each. Require exact
C on every call. This is a code-shape diagnostic, not selfhosting qualification
or a guarantee that all expression choices can be changed safely. Reinspect
bytecode/optimized output to verify the proposed mechanism changed, and report
both first and later request effects without extrapolating four sites to all code.

Method: `selfhost/tools/performance/phase85/lexer-choice.py`; original image
`098320e8…`, disposable `cf15ec8c…`. Full source/hash derivation is retained under
`selfhost/build/phase85/lexer-choice01`, with own preparation and paired plans.
