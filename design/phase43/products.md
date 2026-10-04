# Phase43 products: residual BST dispatch versus zipper allocation

Owner: products. Domain: emitted user-program JavaScript. Root integrated the
general direct-dispatch and fresh pair-state lane; full compact zipper triples
remain a saved-output opportunity ceiling. Checked16 BST64 is 6.651× TypeScript with 2.77× sampled allocation;
`apply` is 19.65% self CPU and `bst.down` is 72.27% sampled allocation. These motivate
separate ablations, not an inferred causal speedup.

Hypothesis A: admitting the existing computed U32 prefix in the structural build
worker removes meaningful residual generic build/insertion dispatch. Saved-JS
`direct` evaluates the same U32 expression once in the same iteration, calls the
unchanged private down/up workers, and preserves native pair/List/BF representation.
Hypothesis B: once A is active, keeping private down state in locals and zipper
triples in one array removes substantial temporary Tuple/BF/Con allocation. `products`
shares A's build and output constructors. Its path never escapes the insertion.
Expected discrimination: A should reduce executed `apply`; B should reduce estimated
allocation relative to A. A 20% family runtime improvement is a useful screen;
no parity forecast. Zero reduction or any complete-value/host mismatch falsifies.

Only the existing guarded ordinary bench branch is rewritten. Its two conditional
inorder alternatives duplicate the same build expression; both are replaced. The
public fallback and all G descriptor identities remain original. Instrumented and
clean modules are separate; timing must use clean modules.

The smallest source candidate is computed-prefix admission, not compact zipper
lowering. `computed-u32-prefix.patch` retains `j_linear_alias` for scalar/flat audits,
adds a separate prefix predicate at linear analysis/emission, and admits only live
one-RHS Bind nodes, no self reference, canonical U32 vars/lits and exact native
add/sub/mul/mod. Depth128 refuses exhaustion. Existing component bounded-source
and full JPure graph checks remain prerequisites. The original binder emitter
retains once-only evaluation and original order. No String/F32/Sigma proof widens.

Records require String/read/show, specialized Map/Maybe and exact native Sigma2/2
inside List2; existing owned Sigma1/1 is insufficient. Coordinate with String/Map
owners. Raytrace already has scalar islands in nearest/rowf; preserve their precedence.
A blanket closed-native graph extension risks replacing working float islands and
requires a separate complete floating-point result/order proof. Neither family is
covered by this BST experiment.

The surviving saved-JS screen establishes useful separate dispatch and container
headroom (exact results/ranges in implementation report). A general smaller
pair-state prototype now exists, with positive-entry fresh buffer and immediate
Tuple destructure preventing buffer escape. It preserves all source field/path
allocations; full compact zipper fusion remains a separate proof. Compiler-side
boolean shape gates must use `kc` before recursion: strict `&&` caused a preserved
180-second source acquisition failure in the initial prefix proposal.

Final proof boundary: positive source workers execute from ordinary owned roots
in actual BST, renamed prefix build, and conditional ignored-field BST derivative.
Original standalone U32/ADT pair examples retain stronger scalar slot workers and
are explicit negative pair-activation controls. A binary consumer alone cannot
disable that independent helper selection; do not change precedence to force it.
The general lane preserves all path BF/Con/List and leaf construction, allocates
a fresh outer pair only for positive countdown, and keeps source field aliases.
Final promotion requires fresh selected-image owner execution and measured gain.
