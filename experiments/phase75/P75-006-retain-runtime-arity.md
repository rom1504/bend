# P75-006: retain runtime arity with the erased body

The refreshed B2 numeric profile contains44ms under nd_arity. Each query
repeats the original telescope/leading-lambda calculation. Store that exact
U32 result in the existing private erased/static definition fact. Compute from
the source context before introducing the fact; reuse with no new index, AST
variant or persistent cache. Foreign/native/missing definitions keep the plain
calculation. Raw input still clears caller-supplied native facts. Complete C
must stay identical, including partial applications and erased parameters.

Review correction before promotion: computing the arity in raw static-body
preparation could change demand/error order on malformed public input. Candidate09
therefore carries an explicit arity-present bit and only propagates an arity
already produced by the owned NR request. Ordinary raw static preparation adds
no new telescope evaluation. Candidate08 remains a retained screen, not a release.
