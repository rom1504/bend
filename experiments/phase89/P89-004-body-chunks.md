# P89-004: defer nested native body strings

Status: isolated prototype authorized after the operation-count discriminator.
Map appends 26,639,166 characters and makes 72,050,847–849 allocator requests
per compilation, producing 895 KB of C. Calls 2–5 perform identical counted work
while growing slower. This motivates less work; it does not prove allocator
locality or imply all append work belongs to body composition.

Replace only NC_Code's intermediate body String with ordered Data pieces.
Keep N_Segment, final C, runtime and external APIs unchanged. The initial source
inventory finds 35 constructors, 29 body calls and nine direct patterns across
43 definitions in ten modules. Eight named consumers require actual strings;
two inspect emptiness or the 4096-character inline threshold. Compose trees in
constant time, render at the existing string boundaries, inspect emptiness and
bounded length without rendering. Use explicit Data/worklist traversal, never
a shared affine continuation. Preserve first errors, fresh counters, complete
segment/call order and exact whitespace. Layer on the separately frozen owned
match candidate; preserve both baselines for attribution.

First gate: standalone ordered/nested/empty/Unicode/length controls. Then fully
check an isolated full compiler source and compare actual lowering products
after observing the new body through its final String interface. One image build
only after these pass. Require complete C equality on Map and a non-Map source,
then paired six-source cold/five-call comparisons. Broaden only for a material
gain; preserve neutral or refused attempts. No representation change may silently
alter scalar/array/effect permission or the qualified cache consumer identity.

Expected direction: fewer repeated character copies and drops. Size of the gain
is unknown until measured; the operation counts do not identify a removable
percentage. Record physical/source complexity and do not retain a new text
representation for a neutral result. Keep native B2 feasibility independent.
