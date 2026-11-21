# Placement cost boundary

The existing-pool policy performs one candidate selection, one fixed-point
liveness solve, one interference-graph construction, one coloring and the
existing post-color validation. It does not compute two full allocations or
emit two alternative functions to choose between them. The original32-name,
9-color,256-statement and64-parameter limits remain.

Additional work is one bounded walk collecting tail affinities, one lookup per
colored name, and future-partner/color checks where a tail-affinity mask is nonzero.
Zero affinity masks return immediately. Identity self bits can still trigger a
short future-name scan, but cannot reserve another endpoint. A conservative bound is32×32 partner
positions and9 color checks per possible partner, but most names have no tail
partner; the unchanged legality validator remains authoritative.

These structural bounds are not a measured native compiler overhead. Initial
policy hosted select times were6.665s(editdist),2.039s(fold),2.041s(heldoutfold)
and3.816s(Mandelbrot), recorded in loops-emission01/loops/report.json. Historical
Phase197 combined observations were6.208s(editdist) and3.663s(Mandelbrot), but
these are separate campaigns with different warmup/order and cannot establish a
causal compiler-throughput ratio. The initial policy also rescored admission;
the narrower policy removes that walk. Cold compilation and native image
qualification remain future gates if the runtime screen justifies promotion.
